#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -n "${TEST_SRCDIR:-}" && -n "${TEST_WORKSPACE:-}" ]]; then
	workspace_root="${TEST_SRCDIR}/${TEST_WORKSPACE}"
	verifier="${workspace_root}/packages/prusa-wall-seam-scope/verify_prusa_wall_seam_scope.sh"
else
	workspace_root="$(cd "${script_dir}/../.." && pwd)"
	verifier="${script_dir}/verify_prusa_wall_seam_scope.sh"
fi

source_readme="${workspace_root}/packages/prusa-wall-seam-scope/README.md"
source_scope="${workspace_root}/packages/prusa-wall-seam-scope/wall-seam-scope.md"
source_inventory="${workspace_root}/packages/fork-inventories/prusaslicer.tsv"
source_category_map="${workspace_root}/packages/fork-inventories/category-map.tsv"
source_status="${workspace_root}/packages/parity/status.tsv"

if [[ ! -x "${verifier}" ]]; then
	printf 'error: verifier is not executable: %s\n' "${verifier}" >&2
	exit 1
fi

tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/verify-prusa-wall-seam-scope-test.XXXXXX")"
trap 'rm -rf "${tmp_dir}"' EXIT

readonly WALL_SEAM_INVENTORY_ROW=$'prusaslicer.wall-seam\tprusaslicer\tprusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961\tsrc/libslic3r/GCode/SeamAligned.cpp\twall-seam\twall-seam\tshared-downstream\tmedium\tgenerated-outputs\tfuture-candidate\tnone\tWall seam planning row; future parity requires geometry and output fixtures before behavior is claimed.'

fail() {
	printf 'FAIL: %s\n' "$1" >&2
	exit 1
}

assert_contains() {
	local file="$1"
	local pattern="$2"
	if ! grep -Eq -- "${pattern}" "${file}"; then
		printf 'missing pattern: %s\n' "${pattern}" >&2
		printf '%s contents:\n' "${file}" >&2
		sed -n '1,200p' "${file}" >&2
		exit 1
	fi
}

remove_line_containing() {
	local file="$1"
	local pattern="$2"
	local tmp_file
	tmp_file="${file}.tmp"
	grep -Fv -- "${pattern}" "${file}" >"${tmp_file}"
	mv "${tmp_file}" "${file}"
}

replace_first_line_containing() {
	local file="$1"
	local pattern="$2"
	local replacement="$3"
	local tmp_file
	tmp_file="${file}.tmp"
	awk -v pattern="${pattern}" -v replacement="${replacement}" '
		!replaced && index($0, pattern) { print replacement; replaced = 1; next }
		{ print }
	' "${file}" >"${tmp_file}"
	mv "${tmp_file}" "${file}"
}

replace_text() {
	local file="$1"
	local pattern="$2"
	local replacement="$3"
	local tmp_file
	tmp_file="${file}.tmp"
	awk -v pattern="${pattern}" -v replacement="${replacement}" '
		{ gsub(pattern, replacement); print }
	' "${file}" >"${tmp_file}"
	mv "${tmp_file}" "${file}"
}

status_row_for_surface() {
	local file="$1"
	local surface="$2"

	awk -F '\t' -v surface="${surface}" '$1 == surface { print; exit }' "${file}"
}

insert_line_before() {
	local file="$1"
	local pattern="$2"
	local inserted_line="$3"
	local tmp_file
	tmp_file="${file}.tmp"
	awk -v pattern="${pattern}" -v inserted_line="${inserted_line}" '
		!inserted && index($0, pattern) { print inserted_line; inserted = 1 }
		{ print }
		END { exit inserted ? 0 : 1 }
	' "${file}" >"${tmp_file}"
	mv "${tmp_file}" "${file}"
}

write_valid_fixture() {
	local dir="$1"
	mkdir -p \
		"${dir}/packages/fork-inventories" \
		"${dir}/packages/parity"

	cp "${source_readme}" "${dir}/README.md"
	cp "${source_scope}" "${dir}/wall-seam-scope.md"
	cp "${source_inventory}" "${dir}/packages/fork-inventories/prusaslicer.tsv"
	cp "${source_category_map}" "${dir}/packages/fork-inventories/category-map.tsv"
	cp "${source_status}" "${dir}/packages/parity/status.tsv"
}

run_verifier() {
	local dir="$1"
	local stdout_file="$2"
	local stderr_file="$3"

	set +e
	"${verifier}" \
		"${dir}/README.md" \
		"${dir}/wall-seam-scope.md" \
		"${dir}/packages/fork-inventories/prusaslicer.tsv" \
		"${dir}/packages/fork-inventories/category-map.tsv" \
		"${dir}/packages/parity/status.tsv" \
		"${dir}" >"${stdout_file}" 2>"${stderr_file}"
	local status="$?"
	set -e

	return "${status}"
}

test_valid_fixture_passes() {
	# Arrange
	local dir="${tmp_dir}/valid"
	write_valid_fixture "${dir}"

	# Act
	if ! run_verifier "${dir}" "${tmp_dir}/valid.out" "${tmp_dir}/valid.err"; then
		sed -n '1,200p' "${tmp_dir}/valid.err" >&2
		fail "valid fixture failed"
	fi

	# Assert
	assert_contains "${tmp_dir}/valid.out" '^ok: Prusa wall-seam scope verification passed$'
}

test_missing_required_scope_row_fails() {
	# Arrange
	local dir="${tmp_dir}/missing-required-scope-row"
	write_valid_fixture "${dir}"
	remove_line_containing "${dir}/wall-seam-scope.md" "| Reviewer signoff |"

	# Act
	if run_verifier "${dir}" "${tmp_dir}/missing-scope-row.out" "${tmp_dir}/missing-scope-row.err"; then
		fail "missing required scope row fixture passed"
	fi

	# Assert
	assert_contains "${tmp_dir}/missing-scope-row.err" '^error:'
	assert_contains "${tmp_dir}/missing-scope-row.err" 'Reviewer signoff'
}

test_missing_wall_seam_field_fails() {
	# Arrange
	local dir="${tmp_dir}/missing-wall-seam-field"
	write_valid_fixture "${dir}"
	remove_line_containing "${dir}/wall-seam-scope.md" "| seam_transition_observations |"

	# Act
	if run_verifier "${dir}" "${tmp_dir}/missing-field.out" "${tmp_dir}/missing-field.err"; then
		fail "missing wall-seam field fixture passed"
	fi

	# Assert
	assert_contains "${tmp_dir}/missing-field.err" '^error:'
	assert_contains "${tmp_dir}/missing-field.err" 'expected exactly 12 wall-seam evidence field rows'
}

test_unsupported_wall_seam_field_fails() {
	# Arrange
	local dir="${tmp_dir}/unsupported-wall-seam-field"
	write_valid_fixture "${dir}"
	insert_line_before \
		"${dir}/wall-seam-scope.md" \
		"| evidence_boundary |" \
		"| unsupported_wall_seam_field | unsupported | Unsupported wall-seam field. |"

	# Act
	if run_verifier "${dir}" "${tmp_dir}/unsupported-field.out" "${tmp_dir}/unsupported-field.err"; then
		fail "unsupported wall-seam field fixture passed"
	fi

	# Assert
	assert_contains "${tmp_dir}/unsupported-field.err" '^error:'
	assert_contains "${tmp_dir}/unsupported-field.err" 'expected exactly 12 wall-seam evidence field rows'
}

test_duplicate_wall_seam_field_fails() {
	# Arrange
	local dir="${tmp_dir}/duplicate-wall-seam-field"
	write_valid_fixture "${dir}"
	insert_line_before \
		"${dir}/wall-seam-scope.md" \
		"| layer_context_observations |" \
		"| seam_transition_observations | seam transition observations | Observed seam transition facts from the checked-in summary only; no wall-seam algorithm equivalence, seam visibility, or byte-for-byte G-code parity. |"

	# Act
	if run_verifier "${dir}" "${tmp_dir}/duplicate-field.out" "${tmp_dir}/duplicate-field.err"; then
		fail "duplicate wall-seam field fixture passed"
	fi

	# Assert
	assert_contains "${tmp_dir}/duplicate-field.err" '^error:'
	assert_contains "${tmp_dir}/duplicate-field.err" 'expected exactly 12 wall-seam evidence field rows'
}

test_inventory_row_drift_fails() {
	# Arrange
	local dir="${tmp_dir}/inventory-row-drift"
	write_valid_fixture "${dir}"
	replace_text "${dir}/packages/fork-inventories/prusaslicer.tsv" "src/libslic3r/GCode/SeamAligned.cpp" "src/libslic3r/GCode/WrongSeamAligned.cpp"

	# Act
	if run_verifier "${dir}" "${tmp_dir}/inventory-drift.out" "${tmp_dir}/inventory-drift.err"; then
		fail "inventory row drift fixture passed"
	fi

	# Assert
	assert_contains "${tmp_dir}/inventory-drift.err" '^error:'
	assert_contains "${tmp_dir}/inventory-drift.err" 'expected exact row once'
}

test_duplicate_inventory_row_fails() {
	# Arrange
	local dir="${tmp_dir}/duplicate-inventory-row"
	write_valid_fixture "${dir}"
	printf '%s\n' "${WALL_SEAM_INVENTORY_ROW}" >>"${dir}/packages/fork-inventories/prusaslicer.tsv"

	# Act
	if run_verifier "${dir}" "${tmp_dir}/duplicate-inventory.out" "${tmp_dir}/duplicate-inventory.err"; then
		fail "duplicate inventory row fixture passed"
	fi

	# Assert
	assert_contains "${tmp_dir}/duplicate-inventory.err" '^error:'
	assert_contains "${tmp_dir}/duplicate-inventory.err" 'expected exact row once'
}

test_missing_seam_category_reference_fails() {
	# Arrange
	local dir="${tmp_dir}/missing-seam-category-reference"
	write_valid_fixture "${dir}"
	replace_text "${dir}/packages/fork-inventories/category-map.tsv" "prusaslicer.wall-seam" "missing.wall-seam"

	# Act
	if run_verifier "${dir}" "${tmp_dir}/missing-category-reference.out" "${tmp_dir}/missing-category-reference.err"; then
		fail "missing seam category reference fixture passed"
	fi

	# Assert
	assert_contains "${tmp_dir}/missing-category-reference.err" '^error:'
	assert_contains "${tmp_dir}/missing-category-reference.err" 'category-map reference'
}

test_generated_outputs_promotion_fails() {
	# Arrange
	local dir="${tmp_dir}/generated-outputs-promotion"
	write_valid_fixture "${dir}"
	replace_first_line_containing \
		"${dir}/packages/parity/status.tsv" \
		"generated-outputs" \
		$'generated-outputs\tverified\t//packages/parity:generated_outputs_parity\tOverbroad generated-output status.'

	# Act
	if run_verifier "${dir}" "${tmp_dir}/generated-promotion.out" "${tmp_dir}/generated-promotion.err"; then
		fail "generated-outputs promotion fixture passed"
	fi

	# Assert
	assert_contains "${tmp_dir}/generated-promotion.err" '^error:'
	assert_contains "${tmp_dir}/generated-promotion.err" 'expected generated-outputs to remain in progress'
}

test_missing_wall_seam_status_row_fails() {
	# Arrange
	local dir="${tmp_dir}/missing-wall-seam-status-row"
	write_valid_fixture "${dir}"
	remove_line_containing "${dir}/packages/parity/status.tsv" "fork.prusaslicer.wall-seam"

	# Act
	if run_verifier "${dir}" "${tmp_dir}/missing-wall-seam-status-row.out" "${tmp_dir}/missing-wall-seam-status-row.err"; then
		fail "missing wall-seam status row fixture passed"
	fi

	# Assert
	assert_contains "${tmp_dir}/missing-wall-seam-status-row.err" '^error:'
	assert_contains "${tmp_dir}/missing-wall-seam-status-row.err" 'fork\.prusaslicer\.wall-seam'
}

test_duplicate_wall_seam_status_row_fails() {
	# Arrange
	local dir="${tmp_dir}/duplicate-wall-seam-status-row"
	local wall_status_row
	write_valid_fixture "${dir}"
	wall_status_row="$(status_row_for_surface "${dir}/packages/parity/status.tsv" "fork.prusaslicer.wall-seam")"
	printf '%s\n' "${wall_status_row}" >>"${dir}/packages/parity/status.tsv"

	# Act
	if run_verifier "${dir}" "${tmp_dir}/duplicate-wall-seam-status-row.out" "${tmp_dir}/duplicate-wall-seam-status-row.err"; then
		fail "duplicate wall-seam status row fixture passed"
	fi

	# Assert
	assert_contains "${tmp_dir}/duplicate-wall-seam-status-row.err" '^error:'
	assert_contains "${tmp_dir}/duplicate-wall-seam-status-row.err" 'fork\.prusaslicer\.wall-seam'
}

test_wrong_wall_seam_status_target_fails() {
	# Arrange
	local dir="${tmp_dir}/wrong-wall-seam-status-target"
	local wrong_status_row
	write_valid_fixture "${dir}"
	wrong_status_row="$(status_row_for_surface "${dir}/packages/parity/status.tsv" "fork.prusaslicer.wall-seam")"
	wrong_status_row="${wrong_status_row//\/\/packages\/parity:prusaslicer_wall_seam_parity/\/\/packages\/parity:prusaslicer_arc_fitting_parity}"
	replace_first_line_containing "${dir}/packages/parity/status.tsv" "fork.prusaslicer.wall-seam" "${wrong_status_row}"

	# Act
	if run_verifier "${dir}" "${tmp_dir}/wrong-wall-seam-status-target.out" "${tmp_dir}/wrong-wall-seam-status-target.err"; then
		fail "wrong wall-seam evidence target fixture passed"
	fi

	# Assert
	assert_contains "${tmp_dir}/wrong-wall-seam-status-target.err" '^error:'
	assert_contains "${tmp_dir}/wrong-wall-seam-status-target.err" '//packages/parity:prusaslicer_wall_seam_parity'
}

test_stale_scope_status_label_fails() {
	# Arrange
	local dir="${tmp_dir}/stale-scope-status-label"
	write_valid_fixture "${dir}"
	replace_text "${dir}/wall-seam-scope.md" "Published narrow status row" "Planned narrow status token"

	# Act
	if run_verifier "${dir}" "${tmp_dir}/stale-scope-status-label.out" "${tmp_dir}/stale-scope-status-label.err"; then
		fail "stale scope status label fixture passed"
	fi

	# Assert
	assert_contains "${tmp_dir}/stale-scope-status-label.err" '^error:'
	assert_contains "${tmp_dir}/stale-scope-status-label.err" 'Published narrow status row'
}

test_stale_published_status_section_fails() {
	# Arrange
	local dir="${tmp_dir}/stale-published-status-section"
	write_valid_fixture "${dir}"
	replace_text "${dir}/wall-seam-scope.md" "## Published Status Wording" "## Planned Status Wording"

	# Act
	if run_verifier "${dir}" "${tmp_dir}/stale-published-status-section.out" "${tmp_dir}/stale-published-status-section.err"; then
		fail "stale published status section fixture passed"
	fi

	# Assert
	assert_contains "${tmp_dir}/stale-published-status-section.err" '^error:'
	assert_contains "${tmp_dir}/stale-published-status-section.err" 'Published Status Wording'
}

test_gcode_output_status_drift_fails() {
	# Arrange
	local dir="${tmp_dir}/gcode-output-status-drift"
	write_valid_fixture "${dir}"
	replace_text \
		"${dir}/packages/parity/status.tsv" \
		"narrow semantic Prusa G-code evidence slice" \
		"narrow semantic Prusa G-code and wall-seam evidence slice"

	# Act
	if run_verifier "${dir}" "${tmp_dir}/gcode-status-drift.out" "${tmp_dir}/gcode-status-drift.err"; then
		fail "G-code output status drift fixture passed"
	fi

	# Assert
	assert_contains "${tmp_dir}/gcode-status-drift.err" '^error:'
	assert_contains "${tmp_dir}/gcode-status-drift.err" 'fork\.prusaslicer\.gcode-output'
}

test_arc_fitting_status_drift_fails() {
	# Arrange
	local dir="${tmp_dir}/arc-fitting-status-drift"
	write_valid_fixture "${dir}"
	replace_text \
		"${dir}/packages/parity/status.tsv" \
		"narrow Prusa arc-fitting checked-in summary evidence slice" \
		"narrow Prusa arc-fitting and wall-seam checked-in summary evidence slice"

	# Act
	if run_verifier "${dir}" "${tmp_dir}/arc-status-drift.out" "${tmp_dir}/arc-status-drift.err"; then
		fail "arc-fitting status drift fixture passed"
	fi

	# Assert
	assert_contains "${tmp_dir}/arc-status-drift.err" '^error:'
	assert_contains "${tmp_dir}/arc-status-drift.err" 'fork\.prusaslicer\.arc-fitting'
}

test_missing_deferred_scope_term_fails() {
	# Arrange
	local dir="${tmp_dir}/missing-deferred-scope-term"
	write_valid_fixture "${dir}"
	replace_text "${dir}/wall-seam-scope.md" "sync automation" "sync process"

	# Act
	if run_verifier "${dir}" "${tmp_dir}/missing-deferred-term.out" "${tmp_dir}/missing-deferred-term.err"; then
		fail "missing deferred scope term fixture passed"
	fi

	# Assert
	assert_contains "${tmp_dir}/missing-deferred-term.err" '^error:'
	assert_contains "${tmp_dir}/missing-deferred-term.err" 'sync automation'
}

test_runtime_overclaim_fails() {
	# Arrange
	local dir="${tmp_dir}/runtime-overclaim"
	write_valid_fixture "${dir}"
	printf '\nPhase 62 claims printer-runtime behavior.\n' >>"${dir}/README.md"

	# Act
	if run_verifier "${dir}" "${tmp_dir}/runtime-overclaim.out" "${tmp_dir}/runtime-overclaim.err"; then
		fail "runtime overclaim fixture passed"
	fi

	# Assert
	assert_contains "${tmp_dir}/runtime-overclaim.err" '^error:'
	assert_contains "${tmp_dir}/runtime-overclaim.err" 'forbidden Prusa wall-seam scope claim'
}

test_printability_overclaim_fails() {
	# Arrange
	local dir="${tmp_dir}/printability-overclaim"
	write_valid_fixture "${dir}"
	printf '\nPhase 62 confirms printability.\n' >>"${dir}/README.md"

	# Act
	if run_verifier "${dir}" "${tmp_dir}/printability-overclaim.out" "${tmp_dir}/printability-overclaim.err"; then
		fail "printability overclaim fixture passed"
	fi

	# Assert
	assert_contains "${tmp_dir}/printability-overclaim.err" '^error:'
	assert_contains "${tmp_dir}/printability-overclaim.err" 'forbidden Prusa wall-seam scope claim'
}

test_seam_visibility_overclaim_fails() {
	# Arrange
	local dir="${tmp_dir}/seam-visibility-overclaim"
	write_valid_fixture "${dir}"
	printf '\nPhase 62 confirms seam visibility.\n' >>"${dir}/README.md"

	# Act
	if run_verifier "${dir}" "${tmp_dir}/seam-visibility-overclaim.out" "${tmp_dir}/seam-visibility-overclaim.err"; then
		fail "seam visibility overclaim fixture passed"
	fi

	# Assert
	assert_contains "${tmp_dir}/seam-visibility-overclaim.err" '^error:'
	assert_contains "${tmp_dir}/seam-visibility-overclaim.err" 'seam visibility'
}

test_algorithm_equivalence_overclaim_fails() {
	# Arrange
	local dir="${tmp_dir}/algorithm-overclaim"
	write_valid_fixture "${dir}"
	printf '\nPhase 62 verifies full wall-seam algorithm equivalence.\n' >>"${dir}/README.md"

	# Act
	if run_verifier "${dir}" "${tmp_dir}/algorithm-overclaim.out" "${tmp_dir}/algorithm-overclaim.err"; then
		fail "algorithm equivalence overclaim fixture passed"
	fi

	# Assert
	assert_contains "${tmp_dir}/algorithm-overclaim.err" '^error:'
	assert_contains "${tmp_dir}/algorithm-overclaim.err" 'full wall-seam algorithm equivalence'
}

test_valid_fixture_passes
test_missing_required_scope_row_fails
test_missing_wall_seam_field_fails
test_unsupported_wall_seam_field_fails
test_duplicate_wall_seam_field_fails
test_inventory_row_drift_fails
test_duplicate_inventory_row_fails
test_missing_seam_category_reference_fails
test_generated_outputs_promotion_fails
test_missing_wall_seam_status_row_fails
test_duplicate_wall_seam_status_row_fails
test_wrong_wall_seam_status_target_fails
test_stale_scope_status_label_fails
test_stale_published_status_section_fails
test_gcode_output_status_drift_fails
test_arc_fitting_status_drift_fails
test_missing_deferred_scope_term_fails
test_runtime_overclaim_fails
test_printability_overclaim_fails
test_seam_visibility_overclaim_fails
test_algorithm_equivalence_overclaim_fails

printf 'ok: verify_prusa_wall_seam_scope_test\n'
