#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -n "${TEST_SRCDIR:-}" && -n "${TEST_WORKSPACE:-}" ]]; then
	workspace_root="${TEST_SRCDIR}/${TEST_WORKSPACE}"
else
	workspace_root="$(cd "${script_dir}/../.." && pwd)"
fi

verifier="${workspace_root}/packages/parity-fixtures/verify_prusa_wall_seam_fixture.sh"
source_fixture_dir="${workspace_root}/packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam"
source_status_file="${workspace_root}/packages/parity/status.tsv"

tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/verify-prusa-wall-seam-fixture-test.XXXXXX")"
trap 'rm -rf "${tmp_dir}"' EXIT

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

assert_contains_all() {
	local file="$1"
	shift
	local pattern
	for pattern in "$@"; do
		assert_contains "${file}" "${pattern}"
	done
}

assert_file_equals() {
	local file="$1"
	local expected="$2"
	local actual
	actual="$(cat "${file}")"
	if [[ "${actual}" != "${expected}" ]]; then
		printf 'expected: %s\nactual: %s\n' "${expected}" "${actual}" >&2
		exit 1
	fi
}

remove_line_containing() {
	local file="$1"
	local pattern="$2"
	local tmp_file
	tmp_file="${file}.tmp"
	awk -v pattern="${pattern}" 'index($0, pattern) == 0 { print }' "${file}" >"${tmp_file}"
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

status_row_for_surface() {
	local file="$1"
	local surface="$2"

	awk -F '\t' -v surface="${surface}" '$1 == surface { print; exit }' "${file}"
}

move_wall_seam_row_before() {
	local file="$1"
	local moved_field="$2"
	local before_field="$3"
	local tmp_file
	tmp_file="${file}.tmp"
	awk -F '\t' -v moved_field="${moved_field}" -v before_field="${before_field}" '
		NR == 1 { header = $0; next }
		$3 == moved_field { moved_row = $0; next }
		$3 == before_field { before_row = $0; before_seen = 1; next }
		!before_seen { prefix = prefix $0 "\n"; next }
		{ suffix = suffix $0 "\n" }
		END {
			print header
			printf "%s", prefix
			if (moved_row != "") {
				print moved_row
			}
			if (before_row != "") {
				print before_row
			}
			printf "%s", suffix
		}
	' "${file}" >"${tmp_file}"
	mv "${tmp_file}" "${file}"
}

write_valid_package_readme() {
	local readme_file="$1"

	mkdir -p "$(dirname "${readme_file}")"
	cat >"${readme_file}" <<'README'
# Parity Fixtures

## Fork Fixture Namespace

Phase 63 adds the Prusa wall-seam fixture namespace at `packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/` with fixture `wall-seam-observations.gcode`, provenance `fixture-provenance.tsv`, expected artifact `expected-wall-seam-summary.tsv`, bundle target `//packages/parity-fixtures:prusa_wall_seam_bundle`, and verification command `bazel run //packages/parity-fixtures:verify_prusa_wall_seam_fixture`. The fixture is source-pinned to `prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961` and source path `src/libslic3r/GCode/SeamAligned.cpp`.

## Current State

Phase 64 owns `slic3r_flavors::prusa_wall_seam`. Phase 65 owns `bazel run //packages/parity:prusaslicer_wall_seam_parity` and `fork.prusaslicer.wall-seam`. Phase 63 does not update `packages/parity/status.tsv`, public parity behavior, Rust crates, or `docs/port/*`.

The broad `generated-outputs` status remains `in progress`, the existing `fork.prusaslicer.gcode-output` row remains limited to semantic G-code evidence, and the existing `fork.prusaslicer.arc-fitting` row remains limited to checked-in arc summary evidence.
README
}

write_valid_fixture_copy() {
	local dir="$1"
	local fixture_dir="${dir}/packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam"

	mkdir -p \
		"${fixture_dir}" \
		"${dir}/packages/parity"
	cp "${source_fixture_dir}/.gitattributes" "${fixture_dir}/.gitattributes"
	cp "${source_fixture_dir}/README.md" "${fixture_dir}/README.md"
	cp "${source_fixture_dir}/wall-seam-observations.gcode" "${fixture_dir}/wall-seam-observations.gcode"
	cp "${source_fixture_dir}/expected-wall-seam-summary.tsv" "${fixture_dir}/expected-wall-seam-summary.tsv"
	cp "${source_fixture_dir}/fixture-provenance.tsv" "${fixture_dir}/fixture-provenance.tsv"
	cp "${source_status_file}" "${dir}/packages/parity/status.tsv"
	write_valid_package_readme "${dir}/packages/parity-fixtures/README.md"
}

run_verifier() {
	local dir="$1"
	local stdout_file="$2"
	local stderr_file="$3"
	local maybe_verifier="${4:-${verifier}}"
	local fixture_dir="${dir}/packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam"

	set +e
	"${maybe_verifier}" \
		"${fixture_dir}/README.md" \
		"${fixture_dir}/fixture-provenance.tsv" \
		"${fixture_dir}/expected-wall-seam-summary.tsv" \
		"${fixture_dir}/wall-seam-observations.gcode" \
		"${dir}/packages/parity/status.tsv" \
		"${dir}/packages/parity-fixtures/README.md" \
		"${dir}" >"${stdout_file}" 2>"${stderr_file}"
	local status="$?"
	set -e

	return "${status}"
}

if [[ ! -x "${verifier}" ]]; then
	fail "verifier is not executable: ${verifier}"
fi

test_valid_fixture_passes() {
	# Arrange
	local dir="${tmp_dir}/valid"
	write_valid_fixture_copy "${dir}"

	# Act
	if ! run_verifier "${dir}" "${tmp_dir}/valid.out" "${tmp_dir}/valid.err"; then
		sed -n '1,200p' "${tmp_dir}/valid.err" >&2
		fail "valid wall-seam fixture failed"
	fi

	# Assert
	assert_file_equals "${tmp_dir}/valid.out" "ok: Prusa wall-seam fixture verification passed"
}

test_missing_wall_seam_row_fails() {
	# Arrange
	local dir="${tmp_dir}/missing-wall-seam-row"
	local summary_file="${dir}/packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/expected-wall-seam-summary.tsv"
	write_valid_fixture_copy "${dir}"
	remove_line_containing "${summary_file}" $'\tcoordinate_bounds\t'

	# Act
	if run_verifier "${dir}" "${tmp_dir}/missing-wall-seam-row.out" "${tmp_dir}/missing-wall-seam-row.err"; then
		fail "missing wall-seam row fixture passed"
	fi

	# Assert
	assert_contains_all "${tmp_dir}/missing-wall-seam-row.err" "expected-wall-seam-summary.tsv" "coordinate_bounds"
}

test_duplicate_wall_seam_row_fails() {
	# Arrange
	local dir="${tmp_dir}/duplicate-wall-seam-row"
	local summary_file="${dir}/packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/expected-wall-seam-summary.tsv"
	local duplicate_row
	write_valid_fixture_copy "${dir}"
	duplicate_row="$(awk -F '\t' '$3 == "seam_transition_observations" { print; exit }' "${summary_file}")"
	printf '%s\n' "${duplicate_row}" >>"${summary_file}"

	# Act
	if run_verifier "${dir}" "${tmp_dir}/duplicate-wall-seam-row.out" "${tmp_dir}/duplicate-wall-seam-row.err"; then
		fail "duplicate wall-seam row fixture passed"
	fi

	# Assert
	assert_contains_all "${tmp_dir}/duplicate-wall-seam-row.err" "expected-wall-seam-summary.tsv" "duplicate wall-seam field" "seam_transition_observations"
}

test_out_of_order_wall_seam_row_fails() {
	# Arrange
	local dir="${tmp_dir}/out-of-order-wall-seam-row"
	local summary_file="${dir}/packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/expected-wall-seam-summary.tsv"
	write_valid_fixture_copy "${dir}"
	move_wall_seam_row_before "${summary_file}" "retraction_observations" "extrusion_observations"

	# Act
	if run_verifier "${dir}" "${tmp_dir}/out-of-order-wall-seam-row.out" "${tmp_dir}/out-of-order-wall-seam-row.err"; then
		fail "out-of-order wall-seam row fixture passed"
	fi

	# Assert
	assert_contains_all "${tmp_dir}/out-of-order-wall-seam-row.err" "expected-wall-seam-summary.tsv" "wall-seam rows out of order" "retraction_observations"
}

test_unsupported_wall_seam_field_fails() {
	# Arrange
	local dir="${tmp_dir}/unsupported-wall-seam-field"
	local summary_file="${dir}/packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/expected-wall-seam-summary.tsv"
	write_valid_fixture_copy "${dir}"
	printf '%s\n' $'prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961\tpackages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/wall-seam-observations.gcode\twall_seam_geometry_equivalence\tunsupported\tverified\tUnsupported wall-seam field must fail closed.' >>"${summary_file}"

	# Act
	if run_verifier "${dir}" "${tmp_dir}/unsupported-wall-seam-field.out" "${tmp_dir}/unsupported-wall-seam-field.err"; then
		fail "unsupported wall-seam field fixture passed"
	fi

	# Assert
	assert_contains_all "${tmp_dir}/unsupported-wall-seam-field.err" "expected-wall-seam-summary.tsv" "unsupported wall-seam field" "wall_seam_geometry_equivalence"
}

test_unsupported_broad_claim_text_fails() {
	# Arrange
	local dir="${tmp_dir}/unsupported-broad-claim-text"
	local summary_file="${dir}/packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/expected-wall-seam-summary.tsv"
	write_valid_fixture_copy "${dir}"
	printf '\nbyte-for-byte G-code parity verified\n' >>"${summary_file}"

	# Act
	if run_verifier "${dir}" "${tmp_dir}/unsupported-broad-claim.out" "${tmp_dir}/unsupported-broad-claim.err"; then
		fail "unsupported broad claim fixture passed"
	fi

	# Assert
	assert_contains_all "${tmp_dir}/unsupported-broad-claim.err" "expected-wall-seam-summary.tsv" "forbidden"
}

test_wrong_source_ref_fails() {
	# Arrange
	local dir="${tmp_dir}/wrong-source-ref"
	local summary_file="${dir}/packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/expected-wall-seam-summary.tsv"
	write_valid_fixture_copy "${dir}"
	replace_first_line_containing \
		"${summary_file}" \
		$'\tsource_ref\tsource identity\t' \
		$'prusaslicer:version_2.9.4@0000000000000000000000000000000000000000\tpackages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/wall-seam-observations.gcode\tsource_ref\tsource identity\tprusaslicer:version_2.9.4@0000000000000000000000000000000000000000\tAccepted PrusaSlicer source identity only.'

	# Act
	if run_verifier "${dir}" "${tmp_dir}/wrong-source-ref.out" "${tmp_dir}/wrong-source-ref.err"; then
		fail "wrong source ref fixture passed"
	fi

	# Assert
	assert_contains_all "${tmp_dir}/wrong-source-ref.err" "expected-wall-seam-summary.tsv" "source_ref"
}

test_wrong_fixture_identity_fails() {
	# Arrange
	local dir="${tmp_dir}/wrong-fixture-identity"
	local summary_file="${dir}/packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/expected-wall-seam-summary.tsv"
	write_valid_fixture_copy "${dir}"
	replace_first_line_containing \
		"${summary_file}" \
		$'\tfixture_id\tfixture identity\twall-seam-observations.gcode\t' \
		$'prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961\tpackages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/wall-seam-observations.gcode\tfixture_id\tfixture identity\twrong-wall-seam-fixture.gcode\tFixture identity string only for the Phase 63 checked-in fixture.'

	# Act
	if run_verifier "${dir}" "${tmp_dir}/wrong-fixture-identity.out" "${tmp_dir}/wrong-fixture-identity.err"; then
		fail "wrong fixture identity passed"
	fi

	# Assert
	assert_contains_all "${tmp_dir}/wrong-fixture-identity.err" "expected-wall-seam-summary.tsv" "fixture_id" "wrong-wall-seam-fixture.gcode"
}

test_wrong_fixture_path_fails() {
	# Arrange
	local dir="${tmp_dir}/wrong-fixture-path"
	local summary_file="${dir}/packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/expected-wall-seam-summary.tsv"
	write_valid_fixture_copy "${dir}"
	replace_first_line_containing \
		"${summary_file}" \
		$'\tfixture_path\tfixture identity\t' \
		$'prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961\tpackages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/wrong.gcode\tfixture_path\tfixture identity\tpackages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/wrong.gcode\tChecked-in fixture path only.'

	# Act
	if run_verifier "${dir}" "${tmp_dir}/wrong-fixture-path.out" "${tmp_dir}/wrong-fixture-path.err"; then
		fail "wrong fixture path fixture passed"
	fi

	# Assert
	assert_contains_all "${tmp_dir}/wrong-fixture-path.err" "expected-wall-seam-summary.tsv" "fixture_path"
}

test_stale_namespace_readme_reference_fails() {
	# Arrange
	local dir="${tmp_dir}/stale-namespace-readme-reference"
	local readme_file="${dir}/packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/README.md"
	write_valid_fixture_copy "${dir}"
	remove_line_containing "${readme_file}" "expected-wall-seam-summary.tsv"

	# Act
	if run_verifier "${dir}" "${tmp_dir}/stale-namespace-readme.out" "${tmp_dir}/stale-namespace-readme.err"; then
		fail "stale namespace README fixture passed"
	fi

	# Assert
	assert_contains_all "${tmp_dir}/stale-namespace-readme.err" "fixture README" "expected-wall-seam-summary.tsv"
}

test_stale_package_readme_reference_fails() {
	# Arrange
	local dir="${tmp_dir}/stale-package-readme-reference"
	local readme_file="${dir}/packages/parity-fixtures/README.md"
	write_valid_fixture_copy "${dir}"
	remove_line_containing "${readme_file}" "Phase 63 adds the Prusa wall-seam fixture namespace"

	# Act
	if run_verifier "${dir}" "${tmp_dir}/stale-package-readme.out" "${tmp_dir}/stale-package-readme.err"; then
		fail "stale package README fixture passed"
	fi

	# Assert
	assert_contains_all "${tmp_dir}/stale-package-readme.err" "packages/parity-fixtures/README.md" "Phase 63 adds the Prusa wall-seam fixture namespace"
}

test_provenance_mismatch_fails() {
	# Arrange
	local dir="${tmp_dir}/provenance-mismatch"
	local provenance_file="${dir}/packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/fixture-provenance.tsv"
	write_valid_fixture_copy "${dir}"
	replace_first_line_containing "${provenance_file}" "prusaslicer.wall-seam" "wall-seam-observations.gcode\tprusaslicer\twrong.wall-seam"

	# Act
	if run_verifier "${dir}" "${tmp_dir}/provenance-mismatch.out" "${tmp_dir}/provenance-mismatch.err"; then
		fail "provenance mismatch fixture passed"
	fi

	# Assert
	assert_contains_all "${tmp_dir}/provenance-mismatch.err" "fixture-provenance.tsv" "provenance"
}

test_fixture_checksum_drift_fails() {
	# Arrange
	local dir="${tmp_dir}/fixture-checksum-drift"
	local gcode_file="${dir}/packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/wall-seam-observations.gcode"
	write_valid_fixture_copy "${dir}"
	replace_first_line_containing "${gcode_file}" "G1 X15.250" "G1 X15.500 Y9.500 E0.28000 F1800 ; seam_resume"

	# Act
	if run_verifier "${dir}" "${tmp_dir}/fixture-checksum-drift.out" "${tmp_dir}/fixture-checksum-drift.err"; then
		fail "fixture checksum drift passed"
	fi

	# Assert
	assert_contains_all "${tmp_dir}/fixture-checksum-drift.err" "wall-seam-observations.gcode" "SHA-256"
}

test_generated_outputs_status_promotion_fails() {
	# Arrange
	local dir="${tmp_dir}/generated-outputs-status-promotion"
	local status_file="${dir}/packages/parity/status.tsv"
	write_valid_fixture_copy "${dir}"
	replace_first_line_containing \
		"${status_file}" \
		"generated-outputs" \
		$'generated-outputs\tverified\t//packages/parity:generated_outputs_parity\tOverbroad generated-output promotion.'

	# Act
	if run_verifier "${dir}" "${tmp_dir}/generated-outputs-status-promotion.out" "${tmp_dir}/generated-outputs-status-promotion.err"; then
		fail "generated-outputs status promotion passed"
	fi

	# Assert
	assert_contains_all "${tmp_dir}/generated-outputs-status-promotion.err" "packages/parity/status.tsv" "generated-outputs"
}

test_missing_wall_seam_status_row_fails() {
	# Arrange
	local dir="${tmp_dir}/missing-wall-seam-status-row"
	local status_file="${dir}/packages/parity/status.tsv"
	write_valid_fixture_copy "${dir}"
	remove_line_containing "${status_file}" "fork.prusaslicer.wall-seam"

	# Act
	if run_verifier "${dir}" "${tmp_dir}/missing-wall-seam-status-row.out" "${tmp_dir}/missing-wall-seam-status-row.err"; then
		fail "missing fork.prusaslicer.wall-seam status row passed"
	fi

	# Assert
	assert_contains_all "${tmp_dir}/missing-wall-seam-status-row.err" "packages/parity/status.tsv" "fork.prusaslicer.wall-seam"
}

test_duplicate_wall_seam_status_row_fails() {
	# Arrange
	local dir="${tmp_dir}/duplicate-wall-seam-status-row"
	local status_file="${dir}/packages/parity/status.tsv"
	local wall_status_row
	write_valid_fixture_copy "${dir}"
	wall_status_row="$(status_row_for_surface "${status_file}" "fork.prusaslicer.wall-seam")"
	printf '%s\n' "${wall_status_row}" >>"${status_file}"

	# Act
	if run_verifier "${dir}" "${tmp_dir}/duplicate-wall-seam-status-row.out" "${tmp_dir}/duplicate-wall-seam-status-row.err"; then
		fail "duplicate fork.prusaslicer.wall-seam status row passed"
	fi

	# Assert
	assert_contains_all "${tmp_dir}/duplicate-wall-seam-status-row.err" "packages/parity/status.tsv" "fork.prusaslicer.wall-seam"
}

test_wrong_wall_seam_status_target_fails() {
	# Arrange
	local dir="${tmp_dir}/wrong-wall-seam-status-target"
	local status_file="${dir}/packages/parity/status.tsv"
	local wrong_status_row
	write_valid_fixture_copy "${dir}"
	wrong_status_row="$(status_row_for_surface "${status_file}" "fork.prusaslicer.wall-seam")"
	wrong_status_row="${wrong_status_row//\/\/packages\/parity:prusaslicer_wall_seam_parity/\/\/packages\/parity:prusaslicer_arc_fitting_parity}"
	replace_first_line_containing "${status_file}" "fork.prusaslicer.wall-seam" "${wrong_status_row}"

	# Act
	if run_verifier "${dir}" "${tmp_dir}/wrong-wall-seam-status-target.out" "${tmp_dir}/wrong-wall-seam-status-target.err"; then
		fail "wrong fork.prusaslicer.wall-seam evidence target passed"
	fi

	# Assert
	assert_contains_all "${tmp_dir}/wrong-wall-seam-status-target.err" "packages/parity/status.tsv" "//packages/parity:prusaslicer_wall_seam_parity"
}

test_gcode_output_status_widening_fails() {
	# Arrange
	local dir="${tmp_dir}/gcode-output-status-widening"
	local status_file="${dir}/packages/parity/status.tsv"
	local wrong_status_row
	write_valid_fixture_copy "${dir}"
	wrong_status_row="$(status_row_for_surface "${status_file}" "fork.prusaslicer.gcode-output")"
	wrong_status_row="${wrong_status_row//semantic Prusa G-code evidence slice/semantic Prusa G-code and wall-seam evidence slice}"
	replace_first_line_containing "${status_file}" "fork.prusaslicer.gcode-output" "${wrong_status_row}"

	# Act
	if run_verifier "${dir}" "${tmp_dir}/gcode-output-status-widening.out" "${tmp_dir}/gcode-output-status-widening.err"; then
		fail "widened fork.prusaslicer.gcode-output status row passed"
	fi

	# Assert
	assert_contains_all "${tmp_dir}/gcode-output-status-widening.err" "packages/parity/status.tsv" "fork.prusaslicer.gcode-output"
}

test_arc_fitting_status_widening_fails() {
	# Arrange
	local dir="${tmp_dir}/arc-fitting-status-widening"
	local status_file="${dir}/packages/parity/status.tsv"
	local wrong_status_row
	write_valid_fixture_copy "${dir}"
	wrong_status_row="$(status_row_for_surface "${status_file}" "fork.prusaslicer.arc-fitting")"
	wrong_status_row="${wrong_status_row//narrow Prusa arc-fitting checked-in summary evidence slice/narrow Prusa arc-fitting and wall-seam checked-in summary evidence slice}"
	replace_first_line_containing "${status_file}" "fork.prusaslicer.arc-fitting" "${wrong_status_row}"

	# Act
	if run_verifier "${dir}" "${tmp_dir}/arc-fitting-status-widening.out" "${tmp_dir}/arc-fitting-status-widening.err"; then
		fail "widened fork.prusaslicer.arc-fitting status row passed"
	fi

	# Assert
	assert_contains_all "${tmp_dir}/arc-fitting-status-widening.err" "packages/parity/status.tsv" "fork.prusaslicer.arc-fitting"
}

test_forbidden_verifier_behavior_fails() {
	# Arrange
	local dir="${tmp_dir}/forbidden-verifier-behavior"
	local verifier_copy="${dir}/verify_prusa_wall_seam_fixture.sh"
	write_valid_fixture_copy "${dir}"
	cp "${verifier}" "${verifier_copy}"
	chmod +x "${verifier_copy}"
	printf '\n# curl should never appear in verifier behavior\n' >>"${verifier_copy}"

	# Act
	if run_verifier "${dir}" "${tmp_dir}/forbidden-verifier-behavior.out" "${tmp_dir}/forbidden-verifier-behavior.err" "${verifier_copy}"; then
		fail "forbidden verifier behavior passed"
	fi

	# Assert
	assert_contains_all "${tmp_dir}/forbidden-verifier-behavior.err" "verify_prusa_wall_seam_fixture.sh" "forbidden verifier behavior term"
}

for test_name in \
	test_valid_fixture_passes \
	test_missing_wall_seam_row_fails \
	test_duplicate_wall_seam_row_fails \
	test_out_of_order_wall_seam_row_fails \
	test_unsupported_wall_seam_field_fails \
	test_unsupported_broad_claim_text_fails \
	test_wrong_source_ref_fails \
	test_wrong_fixture_identity_fails \
	test_wrong_fixture_path_fails \
	test_stale_namespace_readme_reference_fails \
	test_stale_package_readme_reference_fails \
	test_provenance_mismatch_fails \
	test_fixture_checksum_drift_fails \
	test_generated_outputs_status_promotion_fails \
	test_missing_wall_seam_status_row_fails \
	test_duplicate_wall_seam_status_row_fails \
	test_wrong_wall_seam_status_target_fails \
	test_gcode_output_status_widening_fails \
	test_arc_fitting_status_widening_fails \
	test_forbidden_verifier_behavior_fails; do
	"${test_name}"
done

printf 'ok: Prusa wall-seam fixture mutation tests passed\n'
