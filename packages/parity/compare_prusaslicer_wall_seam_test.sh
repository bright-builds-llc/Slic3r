#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -n "${TEST_SRCDIR:-}" && -n "${TEST_WORKSPACE:-}" ]]; then
	workspace_root="${TEST_SRCDIR}/${TEST_WORKSPACE}"
else
	workspace_root="$(cd "${script_dir}/../.." && pwd)"
fi

comparator="${workspace_root}/packages/parity/compare_prusaslicer_wall_seam.sh"
summary_binary="${workspace_root}/packages/slic3r-rust/crates/slic3r_flavors/prusa_wall_seam_summary"
if [[ ! -x "${summary_binary}" ]]; then
	summary_binary="${workspace_root}/bazel-bin/packages/slic3r-rust/crates/slic3r_flavors/prusa_wall_seam_summary"
fi
fixture_dir="${workspace_root}/packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam"
expected_wall_seam_summary="${fixture_dir}/expected-wall-seam-summary.tsv"
fixture_provenance="${fixture_dir}/fixture-provenance.tsv"

tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/compare-prusaslicer-wall-seam-test.XXXXXX")"
trap 'rm -rf "${tmp_dir}"' EXIT

fail() {
	printf 'FAIL: %s\n' "$1" >&2
	exit 1
}

assert_contains() {
	local file="${1}"
	local pattern="${2}"

	if ! grep -Fq "${pattern}" "${file}"; then
		printf 'missing pattern: %s\n' "${pattern}" >&2
		printf '%s contents:\n' "${file}" >&2
		sed -n '1,160p' "${file}" >&2
		exit 1
	fi
}

assert_executable() {
	local label="${1}"
	local path="${2}"

	if [[ ! -x "${path}" ]]; then
		fail "${label} is not executable: ${path}"
	fi
}

assert_file() {
	local label="${1}"
	local path="${2}"

	if [[ ! -f "${path}" ]]; then
		fail "${label} is missing: ${path}"
	fi
}

mutate_wall_seam_value() {
	local path="${1}"
	local wall_seam_field="${2}"
	local replacement="${3}"
	local tmp_file="${path}.tmp"

	awk -v wall_seam_field="${wall_seam_field}" -v replacement="${replacement}" '
		BEGIN {
			FS = OFS = "\t"
		}
		$3 == wall_seam_field {
			$5 = replacement
			changed++
		}
		{
			print
		}
		END {
			if (changed != 1) {
				exit 1
			}
		}
	' "${path}" >"${tmp_file}"
	mv "${tmp_file}" "${path}"
}

mutate_wall_seam_boundary() {
	local path="${1}"
	local wall_seam_field="${2}"
	local replacement="${3}"
	local tmp_file="${path}.tmp"

	awk -v wall_seam_field="${wall_seam_field}" -v replacement="${replacement}" '
		BEGIN {
			FS = OFS = "\t"
		}
		$3 == wall_seam_field {
			$6 = replacement
			changed++
		}
		{
			print
		}
		END {
			if (changed != 1) {
				exit 1
			}
		}
	' "${path}" >"${tmp_file}"
	mv "${tmp_file}" "${path}"
}

move_wall_seam_row_before() {
	local path="${1}"
	local moved_field="${2}"
	local before_field="${3}"
	local tmp_file="${path}.tmp"

	awk -v moved_field="${moved_field}" -v before_field="${before_field}" '
		BEGIN {
			FS = OFS = "\t"
		}
		{
			lines[NR] = $0
			fields[NR] = $3
			if ($3 == moved_field) {
				moved_index = NR
				moved_count++
			}
			if ($3 == before_field) {
				before_index = NR
				before_count++
			}
		}
		END {
			if (moved_count != 1 || before_count != 1) {
				exit 1
			}
			for (i = 1; i <= NR; i++) {
				if (i == before_index) {
					print lines[moved_index]
				}
				if (i != moved_index) {
					print lines[i]
				}
			}
		}
	' "${path}" >"${tmp_file}"
	mv "${tmp_file}" "${path}"
}

run_comparator() {
	local expected_artifact="${1}"
	local stdout_file="${2}"
	local stderr_file="${3}"

	set +e
	"${comparator}" \
		"${summary_binary}" \
		"${expected_wall_seam_summary}" \
		"${expected_artifact}" \
		"${fixture_provenance}" >"${stdout_file}" 2>"${stderr_file}"
	local status="$?"
	set -e

	return "${status}"
}

assert_wall_seam_value_mutation_fails() {
	local wall_seam_field="${1}"
	local replacement="${2}"
	local case_dir="${tmp_dir}/${wall_seam_field}"
	local mutated_wall_seam_expected="${case_dir}/expected-wall-seam-summary.tsv"
	local stdout_file="${case_dir}/mutated-wall-seam.out"
	local stderr_file="${case_dir}/mutated-wall-seam.err"

	mkdir -p "${case_dir}"
	cp "${expected_wall_seam_summary}" "${mutated_wall_seam_expected}"
	mutate_wall_seam_value "${mutated_wall_seam_expected}" "${wall_seam_field}" "${replacement}"

	if run_comparator "${mutated_wall_seam_expected}" "${stdout_file}" "${stderr_file}"; then
		fail "mutated expected-wall-seam-summary.tsv passed for ${wall_seam_field}"
	fi

	assert_contains "${stderr_file}" "expected-wall-seam-summary.tsv"
	assert_contains "${stderr_file}" "${wall_seam_field}"
}

assert_wall_seam_boundary_mutation_fails() {
	local wall_seam_field="${1}"
	local replacement="${2}"
	local required_diagnostic="${3}"
	local case_dir="${tmp_dir}/${wall_seam_field}-boundary"
	local mutated_wall_seam_expected="${case_dir}/expected-wall-seam-summary.tsv"
	local stdout_file="${case_dir}/mutated-wall-seam.out"
	local stderr_file="${case_dir}/mutated-wall-seam.err"

	mkdir -p "${case_dir}"
	cp "${expected_wall_seam_summary}" "${mutated_wall_seam_expected}"
	mutate_wall_seam_boundary "${mutated_wall_seam_expected}" "${wall_seam_field}" "${replacement}"

	if run_comparator "${mutated_wall_seam_expected}" "${stdout_file}" "${stderr_file}"; then
		fail "mutated expected-wall-seam-summary.tsv boundary passed for ${wall_seam_field}"
	fi

	assert_contains "${stderr_file}" "expected-wall-seam-summary.tsv"
	assert_contains "${stderr_file}" "${wall_seam_field}"
	assert_contains "${stderr_file}" "${required_diagnostic}"
}

assert_wall_seam_row_order_mutation_fails() {
	local moved_field="${1}"
	local before_field="${2}"
	local case_dir="${tmp_dir}/${moved_field}-before-${before_field}"
	local mutated_wall_seam_expected="${case_dir}/expected-wall-seam-summary.tsv"
	local stdout_file="${case_dir}/mutated-wall-seam.out"
	local stderr_file="${case_dir}/mutated-wall-seam.err"

	mkdir -p "${case_dir}"
	cp "${expected_wall_seam_summary}" "${mutated_wall_seam_expected}"
	move_wall_seam_row_before "${mutated_wall_seam_expected}" "${moved_field}" "${before_field}"

	if run_comparator "${mutated_wall_seam_expected}" "${stdout_file}" "${stderr_file}"; then
		fail "mutated expected-wall-seam-summary.tsv row order passed for ${moved_field}"
	fi

	assert_contains "${stderr_file}" "expected-wall-seam-summary.tsv"
	assert_contains "${stderr_file}" "${moved_field}"
}

assert_executable "comparator" "${comparator}"
assert_executable "summary binary" "${summary_binary}"
assert_file "expected-wall-seam-summary.tsv" "${expected_wall_seam_summary}"
assert_file "fixture-provenance.tsv" "${fixture_provenance}"

assert_wall_seam_value_mutation_fails \
	"seam_transition_observations" \
	"seam_markers:seam_start;transition_count:1"
assert_wall_seam_value_mutation_fails \
	"layer_context_observations" \
	"layer_index:1;z_values:0.300"
assert_wall_seam_value_mutation_fails \
	"travel_context_observations" \
	"travel_moves:2;travel_from:12.500,8.000;travel_to:14.000,8.750"
assert_wall_seam_value_mutation_fails \
	"coordinate_bounds" \
	"x_min:12.500;x_max:15.500;y_min:8.000;y_max:9.500;z_min:0.200;z_max:0.200"
assert_wall_seam_value_mutation_fails \
	"extrusion_observations" \
	"e_values:0.12000,0.32000;e_axis_observed:true"
assert_wall_seam_value_mutation_fails \
	"retraction_observations" \
	"e_marker_values:0.28000,0.20000;retraction_marker_observed:true"
assert_wall_seam_value_mutation_fails \
	"source_ref" \
	"prusaslicer:version_2.9.5@0000000000000000000000000000000000000000"
assert_wall_seam_value_mutation_fails \
	"fixture_id" \
	"wall-seam-unreviewed.gcode"
assert_wall_seam_value_mutation_fails \
	"fixture_path" \
	"packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/unreviewed.gcode"
assert_wall_seam_row_order_mutation_fails \
	"retraction_observations" \
	"extrusion_observations"
assert_wall_seam_boundary_mutation_fails \
	"seam_transition_observations" \
	"full generated-output parity verified" \
	"full generated-output parity"

assert_contains "${expected_wall_seam_summary}" $'prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961\tpackages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/wall-seam-observations.gcode\tfixture_id\tfixture identity\twall-seam-observations.gcode\tFixture identity string only for the Phase 63 checked-in fixture.'
assert_contains "${expected_wall_seam_summary}" $'prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961\tpackages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/wall-seam-observations.gcode\tfixture_path\tfixture identity\tpackages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/wall-seam-observations.gcode\tChecked-in fixture path under `packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/` only.'
assert_contains "${expected_wall_seam_summary}" $'prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961\tpackages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/wall-seam-observations.gcode\tseam_transition_observations\tseam transition observations\tseam_markers:seam_start,seam_resume;transition_count:2\tObserved seam transition facts from the checked-in summary only; no wall-seam algorithm equivalence, seam visibility, or byte-for-byte G-code parity.'
assert_contains "${expected_wall_seam_summary}" $'prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961\tpackages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/wall-seam-observations.gcode\ttravel_context_observations\ttravel context observations\ttravel_moves:1;travel_from:12.500,8.000;travel_to:14.000,8.750\tObserved travel context facts from the checked-in summary only; no path-planning equivalence, GUI behavior, or printer-runtime behavior claim.'
assert_contains "${expected_wall_seam_summary}" $'prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961\tpackages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/wall-seam-observations.gcode\tcoordinate_bounds\tcoordinate bounds\tx_min:12.500;x_max:15.250;y_min:8.000;y_max:9.500;z_min:0.200;z_max:0.200\tBounded coordinate observations only; no wall-seam geometry equivalence, tolerance, or printability claim.'
assert_contains "${expected_wall_seam_summary}" $'prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961\tpackages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/wall-seam-observations.gcode\textrusion_observations\textrusion observations\te_values:0.12000,0.28000;e_axis_observed:true\tSummary extrusion observations only; no material-use, runtime, or printability claim.'
assert_contains "${expected_wall_seam_summary}" $'prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961\tpackages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/wall-seam-observations.gcode\tretraction_observations\tretraction observations\te_marker_values:0.28000,0.24000;retraction_marker_observed:true\tSummary retraction observations only; no firmware, printer-runtime, or printability claim.'

printf 'ok: prusaslicer_wall_seam_parity_failure_test\n'
