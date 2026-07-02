#!/usr/bin/env bash
set -euo pipefail

error() {
	printf 'error: %s\n' "$*" >&2
	exit 1
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

default_checkout_root() {
	if [[ -n "${BUILD_WORKSPACE_DIRECTORY:-}" ]]; then
		printf '%s\n' "${BUILD_WORKSPACE_DIRECTORY}"
		return
	fi

	cd "${script_dir}/../.." && pwd
}

checkout_root="$(default_checkout_root)"

if [[ "$#" -eq 0 ]]; then
	package_dir="${checkout_root}/packages/parity-fixtures"
	fixture_dir="${package_dir}/forks/prusaslicer/prusaslicer.wall-seam"
	fixture_readme="${fixture_dir}/README.md"
	provenance_file="${fixture_dir}/fixture-provenance.tsv"
	wall_summary_file="${fixture_dir}/expected-wall-seam-summary.tsv"
	gcode_file="${fixture_dir}/wall-seam-observations.gcode"
	status_file="${checkout_root}/packages/parity/status.tsv"
	package_readme="${package_dir}/README.md"
elif [[ "$#" -eq 6 || "$#" -eq 7 ]]; then
	fixture_readme="$1"
	provenance_file="$2"
	wall_summary_file="$3"
	gcode_file="$4"
	status_file="$5"
	package_readme="$6"
	if [[ "$#" -eq 7 ]]; then
		checkout_root="$7"
	fi
else
	error "usage: verify_prusa_wall_seam_fixture.sh [fixture-README fixture-provenance expected-wall-seam-summary wall-seam-observations-gcode parity-status parity-fixtures-README [checkout-root]]"
fi

readonly SOURCE_REF="prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961"
readonly FIXTURE_PATH="packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/wall-seam-observations.gcode"
readonly FIXTURE_ID="wall-seam-observations.gcode"
readonly SOURCE_PATH="src/libslic3r/GCode/SeamAligned.cpp"
readonly SOURCE_ANCHOR="SeamAligned.cpp#L16;SeamAligned.cpp#L115-L148;SeamAligned.cpp#L272-L313;SeamAligned.cpp#L463-L525"
readonly EXPECTED_SHA="9a6306f382e64365ec6e11952f360195bca37fa442f29c7c7f616e1705a6bdad"
readonly EXPECTED_SIZE="360"
readonly EXPECTED_LINE_COUNT="7"
readonly WALL_SEAM_SUMMARY_HEADER=$'source_ref\tfixture_path\twall_seam_field\twall_seam_category\twall_seam_value\tevidence_boundary'
readonly WALL_SEAM_SUMMARY_ROW_COUNT="13"
readonly WALL_SEAM_REQUIRED_FIELDS="source_ref inventory_source_paths source_anchor fixture_id fixture_path seam_transition_observations layer_context_observations travel_context_observations coordinate_bounds extrusion_observations retraction_observations evidence_boundary"
readonly PROVENANCE_HEADER=$'fixture_id\tvendor_id\tinventory_id\tsource_ref\taccepted_tag\tpeeled_commit\tsource_path\tsource_anchor\tbytes\tsha256\tline_endings_encoding\trole\tphase62_scope_record\tupdate_route\tstatus_scope\tprivacy_post_processing_exclusions\tbroad_deferrals'
readonly PROVENANCE_ROW=$'wall-seam-observations.gcode\tprusaslicer\tprusaslicer.wall-seam\tprusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961\tversion_2.9.5\t9a583bd438b195856f3bcf7ea99b69ba4003a961\tsrc/libslic3r/GCode/SeamAligned.cpp\tSeamAligned.cpp#L16;SeamAligned.cpp#L115-L148;SeamAligned.cpp#L272-L313;SeamAligned.cpp#L463-L525\t360\t9a6306f382e64365ec6e11952f360195bca37fa442f29c7c7f616e1705a6bdad\tascii-lf\treviewed-wall-seam-observation-fixture\tpackages/prusa-wall-seam-scope/wall-seam-scope.md\treviewed-intake-change-updates-packages/fork-vendors/forks.tsv-packages/fork-inventories/prusaslicer.tsv-and-packages/prusa-wall-seam-scope/wall-seam-scope.md\tPhase-63-fixture-corpus-only-no-parity-status\tno-generator-no-runtime-no-network-no-sync-no-host-upload-no-post-processing-no-thumbnail-no-printability-no-gui\tno-byte-for-byte-gcode-parity-no-full-wall-seam-algorithm-equivalence-no-seam-visibility-no-generated-output-status-promotion-no-printer-runtime-no-firmware-no-support-no-arc-fitting-no-release-no-bambu-no-orca-no-upstream-source-import-no-sync'
readonly GCODE_OUTPUT_STATUS_ROW=$'fork.prusaslicer.gcode-output\tverified\t//packages/parity:prusaslicer_gcode_output_parity\tShared fixture comparison proves the narrow semantic Prusa G-code evidence slice backed by the Phase 53 closed semantic scope contract, Phase 54 semantic fixture summary, Phase 55 Rust semantic parser/readiness boundary, and Phase 56 public parity command only; byte-for-byte G-code parity, full generated-output parity, toolpath geometry, extrusion behavior, timing, support generation, wall seam behavior, arc fitting, STEP import, full 3MF import/export, printer-runtime behavior, firmware or printability, GUI export or viewer behavior, binary G-code, thumbnails, post-processing, host '$'upload, network/device integration, profile auto-update execution, fork release builds, Bambu Studio, OrcaSlicer, upstream source imports, release behavior, and sync automation remain deferred'
readonly ARC_FITTING_STATUS_ROW=$'fork.prusaslicer.arc-fitting\tverified\t//packages/parity:prusaslicer_arc_fitting_parity\tShared fixture comparison proves the narrow Prusa arc-fitting checked-in summary evidence slice backed by the Phase 57 scope contract, Phase 58 fixture corpus, Phase 59 Rust parser/readiness boundary, and Phase 60 public parity command only; byte-for-byte G-code parity, full generated-output parity, broad generated-output verification, full ArcWelder algorithm equivalence, tolerance or geometry parity, printability, firmware behavior, printer-runtime behavior, GUI behavior, support generation, wall seam behavior, STEP import, full 3MF import/export, binary G-code, thumbnails, post-processing, host '$'upload, network/device behavior, profile auto-update execution, fork release builds, Bambu Studio, OrcaSlicer, upstream source imports, release behavior, sync automation, and non-Prusa fork behavior remain deferred'
readonly WALL_SEAM_STATUS_ROW=$'fork.prusaslicer.wall-seam\tverified\t//packages/parity:prusaslicer_wall_seam_parity\tShared fixture comparison proves the narrow Prusa wall-seam checked-in summary evidence slice backed by the Phase 62 scope contract, Phase 63 fixture corpus, Phase 64 Rust parser/readiness boundary, and Phase 65 public command/status/docs only; byte-for-byte G-code parity, full generated-output parity, broad generated-output verification, full wall-seam algorithm equivalence, wall-seam geometry equivalence, seam visibility, printability, firmware behavior, printer-runtime behavior, GUI behavior, support generation, arc fitting behavior, STEP import, full 3MF import/export, binary G-code, thumbnails, post-processing, host '$'upload, network/device behavior, profile auto-update execution, fork release builds, Bambu Studio, OrcaSlicer, upstream source imports, release behavior, sync automation, and non-Prusa fork behavior remain deferred'
readonly GCODE_LINE_1="; wall-seam observation fixture"
readonly GCODE_LINE_2="; source_anchor:SeamAligned.cpp#L16;SeamAligned.cpp#L115-L148;SeamAligned.cpp#L272-L313;SeamAligned.cpp#L463-L525"
readonly GCODE_LINE_3="; layer_context:layer=0;z=0.200"
readonly GCODE_LINE_4="G1 X12.500 Y8.000 Z0.200 E0.12000 F1800 ; seam_start"
readonly GCODE_LINE_5="G0 X14.000 Y8.750 F9000 ; travel_after_seam"
readonly GCODE_LINE_6="G1 X15.250 Y9.500 E0.28000 F1800 ; seam_resume"
readonly GCODE_LINE_7="G1 E0.24000 F2100 ; retraction_marker"
readonly WALL_SEAM_SOURCE_REF_ROW=$'prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961\tpackages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/wall-seam-observations.gcode\tsource_ref\tsource identity\tprusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961\tAccepted PrusaSlicer source identity only: `prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961`.'
readonly WALL_SEAM_INVENTORY_SOURCE_PATHS_ROW=$'prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961\tpackages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/wall-seam-observations.gcode\tinventory_source_paths\tsource identity\tpackages/fork-inventories/prusaslicer.tsv;src/libslic3r/GCode/SeamAligned.cpp\tInventory source paths only: `packages/fork-inventories/prusaslicer.tsv` and `src/libslic3r/GCode/SeamAligned.cpp`.'
readonly WALL_SEAM_SOURCE_ANCHOR_ROW=$'prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961\tpackages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/wall-seam-observations.gcode\tsource_anchor\tsource identity\tSeamAligned.cpp#L16;SeamAligned.cpp#L115-L148;SeamAligned.cpp#L272-L313;SeamAligned.cpp#L463-L525\tReviewed source anchors only; no upstream import, Git access, or runtime source discovery.'
readonly WALL_SEAM_FIXTURE_ID_ROW=$'prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961\tpackages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/wall-seam-observations.gcode\tfixture_id\tfixture identity\twall-seam-observations.gcode\tFixture identity string only for the Phase 63 checked-in fixture.'
readonly WALL_SEAM_FIXTURE_PATH_ROW=$'prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961\tpackages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/wall-seam-observations.gcode\tfixture_path\tfixture identity\tpackages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/wall-seam-observations.gcode\tChecked-in fixture path under `packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/` only.'
readonly WALL_SEAM_TRANSITION_ROW=$'prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961\tpackages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/wall-seam-observations.gcode\tseam_transition_observations\tseam transition observations\tseam_markers:seam_start,seam_resume;transition_count:2\tObserved seam transition facts from the checked-in summary only; no wall-seam algorithm equivalence, seam visibility, or byte-for-byte G-code parity.'
readonly WALL_SEAM_LAYER_CONTEXT_ROW=$'prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961\tpackages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/wall-seam-observations.gcode\tlayer_context_observations\tlayer context observations\tlayer_index:0;z_values:0.200\tObserved layer context facts from the checked-in summary only; no planner, geometry, printability, or printer-runtime behavior claim.'
readonly WALL_SEAM_TRAVEL_CONTEXT_ROW=$'prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961\tpackages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/wall-seam-observations.gcode\ttravel_context_observations\ttravel context observations\ttravel_moves:1;travel_from:12.500,8.000;travel_to:14.000,8.750\tObserved travel context facts from the checked-in summary only; no path-planning equivalence, GUI behavior, or printer-runtime behavior claim.'
readonly WALL_SEAM_COORDINATE_BOUNDS_ROW=$'prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961\tpackages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/wall-seam-observations.gcode\tcoordinate_bounds\tcoordinate bounds\tx_min:12.500;x_max:15.250;y_min:8.000;y_max:9.500;z_min:0.200;z_max:0.200\tBounded coordinate observations only; no wall-seam geometry equivalence, tolerance, or printability claim.'
readonly WALL_SEAM_EXTRUSION_ROW=$'prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961\tpackages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/wall-seam-observations.gcode\textrusion_observations\textrusion observations\te_values:0.12000,0.28000;e_axis_observed:true\tSummary extrusion observations only; no material-use, runtime, or printability claim.'
readonly WALL_SEAM_RETRACTION_ROW=$'prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961\tpackages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/wall-seam-observations.gcode\tretraction_observations\tretraction observations\te_marker_values:0.28000,0.24000;retraction_marker_observed:true\tSummary retraction observations only; no firmware, printer-runtime, or printability claim.'
readonly WALL_SEAM_EVIDENCE_BOUNDARY_ROW=$'prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961\tpackages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/wall-seam-observations.gcode\tevidence_boundary\tboundary text\tchecked-in-wall-seam-summary-only\tChecked-in wall-seam fixture summary evidence only; no executable public status claim before Phase 65.'
readonly WALL_SEAM_EXPECTED_ROWS="${WALL_SEAM_SOURCE_REF_ROW}"$'\n'"${WALL_SEAM_INVENTORY_SOURCE_PATHS_ROW}"$'\n'"${WALL_SEAM_SOURCE_ANCHOR_ROW}"$'\n'"${WALL_SEAM_FIXTURE_ID_ROW}"$'\n'"${WALL_SEAM_FIXTURE_PATH_ROW}"$'\n'"${WALL_SEAM_TRANSITION_ROW}"$'\n'"${WALL_SEAM_LAYER_CONTEXT_ROW}"$'\n'"${WALL_SEAM_TRAVEL_CONTEXT_ROW}"$'\n'"${WALL_SEAM_COORDINATE_BOUNDS_ROW}"$'\n'"${WALL_SEAM_EXTRUSION_ROW}"$'\n'"${WALL_SEAM_RETRACTION_ROW}"$'\n'"${WALL_SEAM_EVIDENCE_BOUNDARY_ROW}"

require_file() {
	local file="$1"
	local label="$2"
	if [[ ! -f "${file}" ]]; then
		error "${label} file not found: ${file}"
	fi
}

require_text() {
	local file="$1"
	local label="$2"
	local pattern="$3"
	if ! grep -Fq -- "${pattern}" "${file}"; then
		error "${label}: missing required text: ${pattern}"
	fi
}

reject_text() {
	local file="$1"
	local label="$2"
	local pattern="$3"
	if grep -Fq -- "${pattern}" "${file}"; then
		error "${label}: forbidden text: ${pattern}"
	fi
}

require_exact_header() {
	local file="$1"
	local label="$2"
	local expected_header="$3"
	local actual_header
	IFS= read -r actual_header <"${file}" || error "${label}: missing header"
	if [[ "${actual_header}" != "${expected_header}" ]]; then
		error "${label}: expected header ${expected_header}"
	fi
}

require_line_count() {
	local file="$1"
	local label="$2"
	local expected_count="$3"
	local actual_count
	actual_count="$(wc -l <"${file}" | tr -d ' ')"
	if [[ "${actual_count}" != "${expected_count}" ]]; then
		error "${label}: expected ${expected_count} rows, got ${actual_count}"
	fi
}

require_size() {
	local file="$1"
	local label="$2"
	local expected_size="$3"
	local actual_size
	actual_size="$(wc -c <"${file}" | tr -d ' ')"
	if [[ "${actual_size}" != "${expected_size}" ]]; then
		error "${label}: expected ${expected_size} bytes, got ${actual_size}"
	fi
}

require_sha256() {
	local file="$1"
	local label="$2"
	local expected_sha="$3"
	local actual_sha
	actual_sha="$(shasum -a 256 "${file}" | awk '{ print $1 }')"
	if [[ "${actual_sha}" != "${expected_sha}" ]]; then
		error "${label}: expected SHA-256 ${expected_sha}, got ${actual_sha}"
	fi
}

require_exact_line() {
	local file="$1"
	local label="$2"
	local expected_line="$3"
	local description="$4"
	if ! grep -Fxq -- "${expected_line}" "${file}"; then
		error "${label}: missing required row for ${description}: ${expected_line}"
	fi
}

require_first_field_count() {
	local file="$1"
	local label="$2"
	local id="$3"
	local expected_count="$4"
	local count

	count="$(awk -F '\t' -v id="${id}" '$1 == id { count++ } END { print count + 0 }' "${file}")"
	if [[ "${count}" != "${expected_count}" ]]; then
		error "${label}: expected ${expected_count} row(s) with first field ${id}, found ${count}"
	fi
}

require_ascii_lf() {
	local file="$1"
	local label="$2"
	if ! LC_ALL=C awk '
		index($0, "\r") { exit 1 }
		{
			for (i = 1; i <= length($0); i++) {
				character = substr($0, i, 1)
				if (character == "\t") {
					continue
				}
				if (character < " " || character > "~") {
					exit 1
				}
			}
		}
	' "${file}"; then
		error "${label}: expected US-ASCII text with LF line endings"
	fi
}

require_tsv_column_count() {
	local file="$1"
	local label="$2"
	local expected_count="$3"
	awk -F '\t' -v label="${label}" -v expected_count="${expected_count}" '
		NR == 1 { next }
		NF != expected_count {
			printf "error: %s: expected %d columns on line %d, got %d\n", label, expected_count, NR, NF > "/dev/stderr"
			exit 1
		}
	' "${file}"
}

reject_verifier_behavior_terms() {
	local verifier_file="${BASH_SOURCE[0]}"
	local term_http term_git_space term_git_tab term_cl term_ft
	local term_prusaslicer term_slic3r term_send_gcode term_host_upload
	local forbidden_term

	term_http="cu""rl "
	term_git_space="g""it "
	term_git_tab="$(printf 'g%s\t' "it")"
	term_cl="cl""one"
	term_ft="fet""ch"
	term_prusaslicer="PrusaSlicer ""--"
	term_slic3r="slic3r ""--"
	term_send_gcode="send-""gcode"
	term_host_upload="host ""upload"

	for forbidden_term in \
		"${term_http}" \
		"${term_git_space}" \
		"${term_git_tab}" \
		"${term_cl}" \
		"${term_ft}" \
		"${term_prusaslicer}" \
		"${term_slic3r}" \
		"${term_send_gcode}" \
		"${term_host_upload}"; do
		if grep -Fq -- "${forbidden_term}" "${verifier_file}"; then
			error "verify_prusa_wall_seam_fixture.sh: forbidden verifier behavior term present"
		fi
	done
}

reject_overclaiming_text() {
	local checked_file
	local checked_label
	local forbidden_claim

	for checked_file in "${fixture_readme}" "${package_readme}" "${provenance_file}" "${wall_summary_file}" "${BASH_SOURCE[0]}"; do
		checked_label="$(basename "${checked_file}")"
		for forbidden_claim in \
			"verified Prusa wall-seam ""parity" \
			"byte-for-byte G-code parity ""verified" \
			"full generated-output parity ""verified" \
			"broad generated-output verification ""verified" \
			"full wall-seam algorithm equivalence ""verified" \
			"wall-seam geometry equivalence ""verified" \
			"seam visibility ""verified" \
			"printability ""verified" \
			"firmware behavior ""verified" \
			"printer-runtime behavior ""verified" \
			"GUI behavior ""verified" \
			"support generation ""verified" \
			"release behavior ""verified" \
			"host ""upload verified" \
			"Bambu Studio support ""verified" \
			"OrcaSlicer support ""verified" \
			"upstream import ""verified" \
			"sync automation ""verified"; do
			reject_text "${checked_file}" "${checked_label}" "${forbidden_claim}"
		done
	done
}

verify_gcode_file() {
	require_ascii_lf "${gcode_file}" "wall-seam-observations.gcode"
	require_line_count "${gcode_file}" "wall-seam-observations.gcode" "${EXPECTED_LINE_COUNT}"
	require_size "${gcode_file}" "wall-seam-observations.gcode" "${EXPECTED_SIZE}"
	require_sha256 "${gcode_file}" "wall-seam-observations.gcode" "${EXPECTED_SHA}"
	require_exact_line "${gcode_file}" "wall-seam-observations.gcode" "${GCODE_LINE_1}" "line 1 fixture label"
	require_exact_line "${gcode_file}" "wall-seam-observations.gcode" "${GCODE_LINE_2}" "line 2 source anchor"
	require_exact_line "${gcode_file}" "wall-seam-observations.gcode" "${GCODE_LINE_3}" "line 3 layer context"
	require_exact_line "${gcode_file}" "wall-seam-observations.gcode" "${GCODE_LINE_4}" "line 4 seam start"
	require_exact_line "${gcode_file}" "wall-seam-observations.gcode" "${GCODE_LINE_5}" "line 5 travel after seam"
	require_exact_line "${gcode_file}" "wall-seam-observations.gcode" "${GCODE_LINE_6}" "line 6 seam resume"
	require_exact_line "${gcode_file}" "wall-seam-observations.gcode" "${GCODE_LINE_7}" "line 7 retraction marker"
}

verify_provenance() {
	require_ascii_lf "${provenance_file}" "fixture-provenance.tsv"
	require_exact_header "${provenance_file}" "fixture-provenance.tsv" "${PROVENANCE_HEADER}"
	require_tsv_column_count "${provenance_file}" "fixture-provenance.tsv" "17"
	require_exact_line "${provenance_file}" "fixture-provenance.tsv" "${PROVENANCE_ROW}" "${FIXTURE_ID} provenance"
	require_line_count "${provenance_file}" "fixture-provenance.tsv" "2"
}

require_wall_seam_allowed_fields() {
	awk -F '\t' -v label="expected-wall-seam-summary.tsv" '
		NR == 1 { next }
		$3 != "source_ref" &&
			$3 != "inventory_source_paths" &&
			$3 != "source_anchor" &&
			$3 != "fixture_id" &&
			$3 != "fixture_path" &&
			$3 != "seam_transition_observations" &&
			$3 != "layer_context_observations" &&
			$3 != "travel_context_observations" &&
			$3 != "coordinate_bounds" &&
			$3 != "extrusion_observations" &&
			$3 != "retraction_observations" &&
			$3 != "evidence_boundary" {
			printf "error: %s: unsupported wall-seam field: %s\n", label, $3 > "/dev/stderr"
			exit 1
		}
	' "${wall_summary_file}"
}

require_wall_seam_field_counts() {
	awk -F '\t' \
		-v label="expected-wall-seam-summary.tsv" \
		-v required_fields="${WALL_SEAM_REQUIRED_FIELDS}" '
		BEGIN {
			required_count = split(required_fields, required, " ")
		}
		NR == 1 { next }
		{
			counts[$3]++
		}
		END {
			failed = 0
			for (i = 1; i <= required_count; i++) {
				field = required[i]
				actual = counts[field] + 0
				if (actual == 1) {
					continue
				}
				if (actual > 1) {
					printf "error: %s: duplicate wall-seam field: %s count %d, expected 1\n", label, field, actual > "/dev/stderr"
				} else {
					printf "error: %s: missing wall-seam field: %s count %d, expected 1\n", label, field, actual > "/dev/stderr"
				}
				failed = 1
			}
			exit failed
		}
	' "${wall_summary_file}"
}

require_wall_seam_provenance_alignment() {
	awk -F '\t' \
		-v label="expected-wall-seam-summary.tsv" \
		-v source_ref="${SOURCE_REF}" \
		-v fixture_path="${FIXTURE_PATH}" '
		NR == 1 { next }
		$1 != source_ref || $2 != fixture_path {
			printf "error: %s: provenance mismatch for %s\n", label, $3 > "/dev/stderr"
			exit 1
		}
	' "${wall_summary_file}"
}

require_wall_seam_value() {
	local field="$1"
	local expected_value="$2"
	local actual_value
	actual_value="$(awk -F '\t' -v field="${field}" '$3 == field { print $5; exit }' "${wall_summary_file}")"
	if [[ "${actual_value}" != "${expected_value}" ]]; then
		error "expected-wall-seam-summary.tsv: wall-seam value mismatch for ${field}: expected ${expected_value}, got ${actual_value}"
	fi
}

require_wall_seam_exact_rows() {
	local actual_row
	local actual_field
	local expected_field
	local expected_row
	local row_number

	row_number=2
	while IFS= read -r expected_row; do
		actual_row="$(awk -v row_number="${row_number}" 'NR == row_number { print; exit }' "${wall_summary_file}")"
		if [[ "${actual_row}" == "${expected_row}" ]]; then
			row_number=$((row_number + 1))
			continue
		fi

		expected_field="$(printf '%s\n' "${expected_row}" | awk -F '\t' '{ print $3 }')"
		actual_field="$(printf '%s\n' "${actual_row}" | awk -F '\t' '{ print $3 }')"
		if [[ -n "${actual_field}" && "${actual_field}" != "${expected_field}" ]]; then
			error "expected-wall-seam-summary.tsv: wall-seam rows out of order near ${actual_field}"
		fi
		error "expected-wall-seam-summary.tsv: missing required row for ${expected_field}"
	done <<<"${WALL_SEAM_EXPECTED_ROWS}"
}

verify_wall_seam_summary() {
	require_ascii_lf "${wall_summary_file}" "expected-wall-seam-summary.tsv"
	require_exact_header "${wall_summary_file}" "expected-wall-seam-summary.tsv" "${WALL_SEAM_SUMMARY_HEADER}"
	require_tsv_column_count "${wall_summary_file}" "expected-wall-seam-summary.tsv" "6"
	require_wall_seam_allowed_fields
	require_wall_seam_field_counts
	require_wall_seam_provenance_alignment
	require_wall_seam_value "source_ref" "${SOURCE_REF}"
	require_wall_seam_value "inventory_source_paths" "packages/fork-inventories/prusaslicer.tsv;${SOURCE_PATH}"
	require_wall_seam_value "source_anchor" "${SOURCE_ANCHOR}"
	require_wall_seam_value "fixture_id" "${FIXTURE_ID}"
	require_wall_seam_value "fixture_path" "${FIXTURE_PATH}"
	require_wall_seam_value "seam_transition_observations" "seam_markers:seam_start,seam_resume;transition_count:2"
	require_wall_seam_value "layer_context_observations" "layer_index:0;z_values:0.200"
	require_wall_seam_value "travel_context_observations" "travel_moves:1;travel_from:12.500,8.000;travel_to:14.000,8.750"
	require_wall_seam_value "coordinate_bounds" "x_min:12.500;x_max:15.250;y_min:8.000;y_max:9.500;z_min:0.200;z_max:0.200"
	require_wall_seam_value "extrusion_observations" "e_values:0.12000,0.28000;e_axis_observed:true"
	require_wall_seam_value "retraction_observations" "e_marker_values:0.28000,0.24000;retraction_marker_observed:true"
	require_wall_seam_value "evidence_boundary" "checked-in-wall-seam-summary-only"
	require_wall_seam_exact_rows
	require_line_count "${wall_summary_file}" "expected-wall-seam-summary.tsv" "${WALL_SEAM_SUMMARY_ROW_COUNT}"
}

verify_namespace_readme() {
	require_text "${fixture_readme}" "fixture README" "# PrusaSlicer Wall-Seam Fixture"
	require_text "${fixture_readme}" "fixture README" "This namespace is \`prusaslicer.wall-seam\`."
	require_text "${fixture_readme}" "fixture README" "${SOURCE_REF}"
	require_text "${fixture_readme}" "fixture README" "\`wall-seam-observations.gcode\` is the small reviewed wall-seam observation"
	require_text "${fixture_readme}" "fixture README" "\`fixture-provenance.tsv\` pins the fixture to"
	require_text "${fixture_readme}" "fixture README" "\`expected-wall-seam-summary.tsv\` records exactly the Phase 62 approved"
	require_text "${fixture_readme}" "fixture README" "\`packages/prusa-wall-seam-scope/wall-seam-scope.md\` remains the reviewed"
	require_text "${fixture_readme}" "fixture README" "Update this namespace only after a reviewed intake change updates"
	require_text "${fixture_readme}" "fixture README" "\`packages/fork-vendors/forks.tsv\`"
	require_text "${fixture_readme}" "fixture README" "\`packages/fork-inventories/prusaslicer.tsv\`"
	require_text "${fixture_readme}" "fixture README" "\`packages/prusa-wall-seam-scope/wall-seam-scope.md\`"
	require_text "${fixture_readme}" "fixture README" "Phase 63 owns only the checked-in \`prusaslicer.wall-seam\` fixture namespace"
	require_text "${fixture_readme}" "fixture README" "Phase 64 owns"
	require_text "${fixture_readme}" "fixture README" "\`slic3r_flavors::prusa_wall_seam\` Rust parser/readiness work"
	require_text "${fixture_readme}" "fixture README" "Phase 65 owns"
	require_text "${fixture_readme}" "fixture README" "\`bazel run //packages/parity:prusaslicer_wall_seam_parity\`"
	require_text "${fixture_readme}" "fixture README" "\`fork.prusaslicer.wall-seam\` status row"
}

verify_package_readme() {
	require_text "${package_readme}" "packages/parity-fixtures/README.md" "Phase 63 adds the Prusa wall-seam fixture namespace"
	require_text "${package_readme}" "packages/parity-fixtures/README.md" "packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/"
	require_text "${package_readme}" "packages/parity-fixtures/README.md" "wall-seam-observations.gcode"
	require_text "${package_readme}" "packages/parity-fixtures/README.md" "fixture-provenance.tsv"
	require_text "${package_readme}" "packages/parity-fixtures/README.md" "expected-wall-seam-summary.tsv"
	require_text "${package_readme}" "packages/parity-fixtures/README.md" "//packages/parity-fixtures:prusa_wall_seam_bundle"
	require_text "${package_readme}" "packages/parity-fixtures/README.md" "bazel run //packages/parity-fixtures:verify_prusa_wall_seam_fixture"
	require_text "${package_readme}" "packages/parity-fixtures/README.md" "${SOURCE_REF}"
	require_text "${package_readme}" "packages/parity-fixtures/README.md" "${SOURCE_PATH}"
	require_text "${package_readme}" "packages/parity-fixtures/README.md" "Phase 64 owns"
	require_text "${package_readme}" "packages/parity-fixtures/README.md" "\`slic3r_flavors::prusa_wall_seam\`"
	require_text "${package_readme}" "packages/parity-fixtures/README.md" "Phase 65 owns"
	require_text "${package_readme}" "packages/parity-fixtures/README.md" "\`bazel run //packages/parity:prusaslicer_wall_seam_parity\`"
	require_text "${package_readme}" "packages/parity-fixtures/README.md" "\`fork.prusaslicer.wall-seam\`"
	require_text "${package_readme}" "packages/parity-fixtures/README.md" "Phase 63 does not update \`packages/parity/status.tsv\`"
	require_text "${package_readme}" "packages/parity-fixtures/README.md" "broad \`generated-outputs\` status remains \`in progress\`"
	require_text "${package_readme}" "packages/parity-fixtures/README.md" "\`fork.prusaslicer.gcode-output\` row remains limited"
	require_text "${package_readme}" "packages/parity-fixtures/README.md" "\`fork.prusaslicer.arc-fitting\` row remains limited"
}

verify_status_boundaries() {
	local generated_outputs_count

	generated_outputs_count="$(awk -F '\t' '$1 == "generated-outputs" && $2 == "in progress" { count++ } END { print count + 0 }' "${status_file}")"
	if [[ "${generated_outputs_count}" != "1" ]]; then
		error "packages/parity/status.tsv: expected one generated-outputs in progress row, got ${generated_outputs_count}"
	fi
	require_first_field_count "${status_file}" "packages/parity/status.tsv" "generated-outputs" "1"

	require_exact_line "${status_file}" "packages/parity/status.tsv" "${GCODE_OUTPUT_STATUS_ROW}" "fork.prusaslicer.gcode-output status"
	require_first_field_count "${status_file}" "packages/parity/status.tsv" "fork.prusaslicer.gcode-output" "1"

	require_exact_line "${status_file}" "packages/parity/status.tsv" "${ARC_FITTING_STATUS_ROW}" "fork.prusaslicer.arc-fitting status"
	require_first_field_count "${status_file}" "packages/parity/status.tsv" "fork.prusaslicer.arc-fitting" "1"

	require_exact_line "${status_file}" "packages/parity/status.tsv" "${WALL_SEAM_STATUS_ROW}" "fork.prusaslicer.wall-seam status"
	require_first_field_count "${status_file}" "packages/parity/status.tsv" "fork.prusaslicer.wall-seam" "1"
}

for required_file in \
	"${fixture_readme}" \
	"${provenance_file}" \
	"${wall_summary_file}" \
	"${gcode_file}" \
	"${status_file}" \
	"${package_readme}"; do
	require_file "${required_file}" "input"
done

reject_verifier_behavior_terms
reject_overclaiming_text
verify_gcode_file
verify_provenance
verify_wall_seam_summary
verify_namespace_readme
verify_package_readme
verify_status_boundaries

printf 'ok: Prusa wall-seam fixture verification passed\n'
