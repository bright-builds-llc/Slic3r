#!/usr/bin/env bash
set -euo pipefail

if [[ "$#" -ne 4 ]]; then
	printf 'error: expected summary_binary rust-wall-seam-input.tsv expected-wall-seam-summary.tsv fixture-provenance.tsv\n' >&2
	exit 2
fi

summary_binary="${1}"
rust_wall_seam_input="${2}"
expected_artifact="${3}"
fixture_provenance="${4}"

assert_file() {
	local label="${1}"
	local path="${2}"

	if [[ ! -f "${path}" ]]; then
		printf 'error: missing %s: %s\n' "${label}" "${path}" >&2
		exit 1
	fi
}

assert_file "summary binary" "${summary_binary}"
if [[ ! -x "${summary_binary}" ]]; then
	printf 'error: summary binary is not executable: %s\n' "${summary_binary}" >&2
	exit 1
fi
assert_file "rust-wall-seam-input.tsv" "${rust_wall_seam_input}"
assert_file "expected-wall-seam-summary.tsv" "${expected_artifact}"
assert_file "fixture-provenance.tsv" "${fixture_provenance}"

first_wall_seam_raw_mismatch_label() {
	local expected_file="${1}"
	local actual_file="${2}"

	awk -F '\t' '
		NR == FNR {
			expected[FNR] = $0
			expected_count = FNR
			next
		}
		{
			actual_count = FNR
			if (!found && expected[FNR] != $0) {
				if (expected[FNR] != "") {
					split(expected[FNR], fields, "\t")
					if (fields[3] != "") {
						print fields[3]
					} else {
						print fields[1]
					}
				} else if ($3 != "") {
					print $3
				} else if ($1 != "") {
					print $1
				} else {
					print "line"
				}
				found = 1
				exit
			}
		}
		END {
			if (!found && expected_count != actual_count) {
				print "line_count"
			}
		}
	' "${expected_file}" "${actual_file}"
}

first_wall_seam_summary_mismatch_label() {
	local expected_file="${1}"
	local actual_file="${2}"

	awk -F '\t' '
		NR == FNR {
			expected[FNR] = $0
			expected_count = FNR
			next
		}
		{
			actual_count = FNR
			if (!found && expected[FNR] != $0) {
				if (expected[FNR] != "") {
					split(expected[FNR], fields, "\t")
					if (fields[1] != "") {
						print fields[1]
					} else {
						print "line"
					}
				} else if ($1 != "") {
					print $1
				} else {
					print "line"
				}
				found = 1
				exit
			}
		}
		END {
			if (!found && expected_count != actual_count) {
				print "line_count"
			}
		}
	' "${expected_file}" "${actual_file}"
}

field_value() {
	local key="${1}"
	local path="${2}"

	awk -v key="${key}" -F '\t' '
		$1 == key {
			print $2
			found = 1
			exit
		}
		END {
			if (!found) {
				exit 1
			}
		}
	' "${path}"
}

assert_field() {
	local key="${1}"
	local expected_value="${2}"
	local path="${3}"
	local actual_value

	actual_value="$(field_value "${key}" "${path}")" || {
		printf 'error: %s missing from actual wall-seam summary\n' "${key}" >&2
		exit 1
	}
	if [[ "${actual_value}" != "${expected_value}" ]]; then
		printf 'error: expected %s %s, got %s\n' "${key}" "${expected_value}" "${actual_value}" >&2
		exit 1
	fi
}

temp_root="$(mktemp -d /tmp/slic3r-prusa-wall-seam.XXXXXX)"
trap 'rm -rf "${temp_root}"' EXIT
actual_summary="${temp_root}/actual-wall-seam-summary.tsv"
expected_summary_lines="${temp_root}/expected-wall-seam-summary-lines.tsv"

if ! "${summary_binary}" "${rust_wall_seam_input}" >"${actual_summary}"; then
	printf 'error: rust-wall-seam-input.tsv failed Rust wall-seam validation for %s\n' \
		"${rust_wall_seam_input}" >&2
	exit 1
fi

if ! "${summary_binary}" "${expected_artifact}" >"${expected_summary_lines}"; then
	mismatch_label="$(first_wall_seam_raw_mismatch_label "${rust_wall_seam_input}" "${expected_artifact}")"
	printf 'error: expected-wall-seam-summary.tsv failed Rust wall-seam validation at %s in %s\n' \
		"${mismatch_label}" "${expected_artifact}" >&2
	if ! diff_output="$(diff -u "${rust_wall_seam_input}" "${expected_artifact}")"; then
		printf 'diff -u %s %s\n' "${rust_wall_seam_input}" "${expected_artifact}" >&2
		printf '%s\n' "${diff_output}" >&2
	fi
	exit 1
fi

if ! diff_output="$(diff -u "${expected_summary_lines}" "${actual_summary}")"; then
	mismatch_label="$(first_wall_seam_summary_mismatch_label "${expected_summary_lines}" "${actual_summary}")"
	printf 'error: expected-wall-seam-summary.tsv mismatch at %s in %s\n' \
		"${mismatch_label}" "${expected_artifact}" >&2
	printf 'diff -u %s %s\n' "${expected_summary_lines}" "${actual_summary}" >&2
	printf '%s\n' "${diff_output}" >&2
	exit 1
fi

assert_field "wall_seam_summary_path" "packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/expected-wall-seam-summary.tsv" "${actual_summary}"
assert_field "wall_seam_row_count" "12" "${actual_summary}"
assert_field "source_ref" "prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961" "${actual_summary}"
assert_field "inventory_source_paths" "packages/fork-inventories/prusaslicer.tsv;src/libslic3r/GCode/SeamAligned.cpp" "${actual_summary}"
assert_field "source_anchor" "SeamAligned.cpp#L16;SeamAligned.cpp#L115-L148;SeamAligned.cpp#L272-L313;SeamAligned.cpp#L463-L525" "${actual_summary}"
assert_field "fixture_id" "wall-seam-observations.gcode" "${actual_summary}"
assert_field "fixture_path" "packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/wall-seam-observations.gcode" "${actual_summary}"
assert_field "seam_transition_observations" "seam_markers:seam_start,seam_resume;transition_count:2" "${actual_summary}"
assert_field "layer_context_observations" "layer_index:0;z_values:0.200" "${actual_summary}"
assert_field "travel_context_observations" "travel_moves:1;travel_from:12.500,8.000;travel_to:14.000,8.750" "${actual_summary}"
assert_field "coordinate_bounds" "x_min:12.500;x_max:15.250;y_min:8.000;y_max:9.500;z_min:0.200;z_max:0.200" "${actual_summary}"
assert_field "extrusion_observations" "e_values:0.12000,0.28000;e_axis_observed:true" "${actual_summary}"
assert_field "retraction_observations" "e_marker_values:0.28000,0.24000;retraction_marker_observed:true" "${actual_summary}"
assert_field "evidence_boundary" "checked-in-wall-seam-summary-only" "${actual_summary}"

printf 'ok: fork.prusaslicer.wall-seam checked-in summary evidence passed\n'
printf 'source_ref: prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961\n'
printf 'fixture: packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/wall-seam-observations.gcode\n'
printf 'expected_wall_seam_summary: packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/expected-wall-seam-summary.tsv\n'
printf 'wall_seam_rows: 12\n'
printf 'seam_transition_observations: seam_markers:seam_start,seam_resume;transition_count:2\n'
printf 'layer_context_observations: layer_index:0;z_values:0.200\n'
printf 'travel_context_observations: travel_moves:1;travel_from:12.500,8.000;travel_to:14.000,8.750\n'
printf 'coordinate_bounds: x_min:12.500;x_max:15.250;y_min:8.000;y_max:9.500;z_min:0.200;z_max:0.200\n'
printf 'extrusion_observations: e_values:0.12000,0.28000;e_axis_observed:true\n'
printf 'retraction_observations: e_marker_values:0.28000,0.24000;retraction_marker_observed:true\n'
printf 'evidence_boundary: checked-in-wall-seam-summary-only\n'
