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
	readme_file="${script_dir}/README.md"
	scope_file="${script_dir}/wall-seam-scope.md"
	inventory_file="${checkout_root}/packages/fork-inventories/prusaslicer.tsv"
	category_map_file="${checkout_root}/packages/fork-inventories/category-map.tsv"
	status_file="${checkout_root}/packages/parity/status.tsv"
elif [[ "$#" -eq 5 ]]; then
	readme_file="$1"
	scope_file="$2"
	inventory_file="$3"
	category_map_file="$4"
	status_file="$5"
elif [[ "$#" -eq 6 ]]; then
	readme_file="$1"
	scope_file="$2"
	inventory_file="$3"
	category_map_file="$4"
	status_file="$5"
	checkout_root="$6"
else
	error "usage: verify_prusa_wall_seam_scope.sh [README wall-seam-scope inventory category-map parity-status [checkout-root]]"
fi

readonly ACCEPTED_SOURCE_IDENTITY="prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961"
readonly WALL_SEAM_INVENTORY_ROW=$'prusaslicer.wall-seam\tprusaslicer\tprusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961\tsrc/libslic3r/GCode/SeamAligned.cpp\twall-seam\twall-seam\tshared-downstream\tmedium\tgenerated-outputs\tfuture-candidate\tnone\tWall seam planning row; future parity requires geometry and output fixtures before behavior is claimed.'
readonly SEAM_CATEGORY_MAP_ID="seam.shared"
readonly GCODE_OUTPUT_STATUS_ROW=$'fork.prusaslicer.gcode-output\tverified\t//packages/parity:prusaslicer_gcode_output_parity\tShared fixture comparison proves the narrow semantic Prusa G-code evidence slice backed by the Phase 53 closed semantic scope contract, Phase 54 semantic fixture summary, Phase 55 Rust semantic parser/readiness boundary, and Phase 56 public parity command only; byte-for-byte G-code parity, full generated-output parity, toolpath geometry, extrusion behavior, timing, support generation, wall seam behavior, arc fitting, STEP import, full 3MF import/export, printer-runtime behavior, firmware or printability, GUI export or viewer behavior, binary G-code, thumbnails, post-processing, host upload, network/device integration, profile auto-update execution, fork release builds, Bambu Studio, OrcaSlicer, upstream source imports, release behavior, and sync automation remain deferred'
readonly ARC_FITTING_STATUS_ROW=$'fork.prusaslicer.arc-fitting\tverified\t//packages/parity:prusaslicer_arc_fitting_parity\tShared fixture comparison proves the narrow Prusa arc-fitting checked-in summary evidence slice backed by the Phase 57 scope contract, Phase 58 fixture corpus, Phase 59 Rust parser/readiness boundary, and Phase 60 public parity command only; byte-for-byte G-code parity, full generated-output parity, broad generated-output verification, full ArcWelder algorithm equivalence, tolerance or geometry parity, printability, firmware behavior, printer-runtime behavior, GUI behavior, support generation, wall seam behavior, STEP import, full 3MF import/export, binary G-code, thumbnails, post-processing, host upload, network/device behavior, profile auto-update execution, fork release builds, Bambu Studio, OrcaSlicer, upstream source imports, release behavior, sync automation, and non-Prusa fork behavior remain deferred'
readonly WALL_SEAM_STATUS_ROW=$'fork.prusaslicer.wall-seam\tverified\t//packages/parity:prusaslicer_wall_seam_parity\tShared fixture comparison proves the narrow Prusa wall-seam checked-in summary evidence slice backed by the Phase 62 scope contract, Phase 63 fixture corpus, Phase 64 Rust parser/readiness boundary, and Phase 65 public command/status/docs only; byte-for-byte G-code parity, full generated-output parity, broad generated-output verification, full wall-seam algorithm equivalence, wall-seam geometry equivalence, seam visibility, printability, firmware behavior, printer-runtime behavior, GUI behavior, support generation, arc fitting behavior, STEP import, full 3MF import/export, binary G-code, thumbnails, post-processing, host upload, network/device behavior, profile auto-update execution, fork release builds, Bambu Studio, OrcaSlicer, upstream source imports, release behavior, sync automation, and non-Prusa fork behavior remain deferred'
readonly SCOPE_RECORD_SECTION="## Scope Record"
readonly SOURCE_ROW_SECTION="## Source Row Details"
readonly WALL_SEAM_FIELD_SECTION="## Approved Wall-Seam Evidence Fields"
readonly TRACEABILITY_SECTION="## Wall-Seam Traceability"
readonly STATUS_WORDING_SECTION="## Published Status Wording"

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
		error "${label}: forbidden Prusa wall-seam scope claim: ${pattern}"
	fi
}

require_section_table_row() {
	local file="$1"
	local label="$2"
	local section="$3"
	local field="$4"
	local value="$5"
	local row="| ${field} | ${value} |"

	require_section_table_exact_row "${file}" "${label}" "${section}" "${row}"
}

require_section_table_exact_row() {
	local file="$1"
	local label="$2"
	local section="$3"
	local row="$4"

	if ! awk -v section="${section}" -v row="${row}" '
		$0 == section { in_section = 1; next }
		in_section && /^## / { exit }
		in_section && $0 == row { found = 1; exit }
		END { exit found ? 0 : 1 }
	' "${file}"; then
		error "${label}: missing required table row in ${section}: ${row}"
	fi
}

require_section_table_body_row_count() {
	local file="$1"
	local label="$2"
	local section="$3"
	local expected_count="$4"
	local count

	count="$(awk -v section="${section}" '
		$0 == section { in_section = 1; next }
		in_section && /^## / { exit }
		in_section && /^[[:space:]]*\|[[:space:]]*Wall-Seam Field[[:space:]]*\|/ { next }
		in_section && /^[[:space:]]*\|[[:space:]]*---[[:space:]]*\|/ { next }
		in_section && /^[[:space:]]*\|/ { count++ }
		END { print count + 0 }
	' "${file}")"

	if [[ "${count}" != "${expected_count}" ]]; then
		error "${label}: ${section}: expected exactly 12 wall-seam evidence field rows, found ${count}; required fields include seam_transition_observations"
	fi
}

require_exact_tsv_row_once() {
	local file="$1"
	local label="$2"
	local expected_row="$3"
	local count

	count="$(awk -v expected_row="${expected_row}" '$0 == expected_row { count++ } END { print count + 0 }' "${file}")"
	if [[ "${count}" != "1" ]]; then
		error "${label}: expected exact row once: ${expected_row}"
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

require_category_reference_count() {
	local file="$1"
	local label="$2"
	local id="$3"
	local expected_count="$4"
	local count

	count="$(awk -F '\t' -v id="${id}" '
		/^#/ || NF == 0 { next }
		{
			split($5, inventory_ids, ";")
			for (idx in inventory_ids) {
				if (inventory_ids[idx] == id) {
					count++
				}
			}
		}
		END { print count + 0 }
	' "${file}")"

	if [[ "${count}" != "${expected_count}" ]]; then
		error "${label}: expected ${expected_count} category-map reference(s) to ${id}, found ${count}"
	fi
}

verify_readme() {
	require_text "${readme_file}" "README.md" \
		"\`packages/prusa-wall-seam-scope\` owns the Phase 62 reviewed scope contract for \`prusaslicer.wall-seam\`."
	require_text "${readme_file}" "README.md" \
		"bazel run //packages/prusa-wall-seam-scope:verify"
}

verify_scope_record() {
	require_section_table_row "${scope_file}" "wall-seam-scope.md" \
		"${SCOPE_RECORD_SECTION}" "Inventory row ID" "\`prusaslicer.wall-seam\`"
	require_section_table_row "${scope_file}" "wall-seam-scope.md" \
		"${SCOPE_RECORD_SECTION}" "Accepted source identity" "\`${ACCEPTED_SOURCE_IDENTITY}\`"
	require_section_table_row "${scope_file}" "wall-seam-scope.md" \
		"${SCOPE_RECORD_SECTION}" "Inventory row source" "\`packages/fork-inventories/prusaslicer.tsv\`"
	require_section_table_row "${scope_file}" "wall-seam-scope.md" \
		"${SCOPE_RECORD_SECTION}" "Source path" "\`src/libslic3r/GCode/SeamAligned.cpp\`"
	require_section_table_row "${scope_file}" "wall-seam-scope.md" \
		"${SCOPE_RECORD_SECTION}" "Fixture namespace decision" "Phase 63 planned namespace \`packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/\`; no fixture bytes are checked in during Phase 62."
	require_section_table_row "${scope_file}" "wall-seam-scope.md" \
		"${SCOPE_RECORD_SECTION}" "Expected-summary contract" "Phase 63 planned \`packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/expected-wall-seam-summary.tsv\` with the approved Phase 62 wall-seam evidence fields; no expected wall-seam summary artifact is checked in during Phase 62."
	require_section_table_row "${scope_file}" "wall-seam-scope.md" \
		"${SCOPE_RECORD_SECTION}" "Candidate Rust boundary" "Phase 64 planned \`slic3r_flavors::prusa_wall_seam\` pure data-in/data-out boundary over caller-supplied checked-in wall-seam summaries; no Rust parser implementation is created in Phase 62."
	require_section_table_row "${scope_file}" "wall-seam-scope.md" \
		"${SCOPE_RECORD_SECTION}" "Public evidence command" "Phase 65 published \`bazel run //packages/parity:prusaslicer_wall_seam_parity\`; Phase 62 only planned the target and did not create it."
	require_section_table_row "${scope_file}" "wall-seam-scope.md" \
		"${SCOPE_RECORD_SECTION}" "Published narrow status row" "Phase 65 published \`fork.prusaslicer.wall-seam\` after executable evidence passed; Phase 62 only planned the row and did not publish it."
	require_section_table_row "${scope_file}" "wall-seam-scope.md" \
		"${SCOPE_RECORD_SECTION}" "Docs touched" "\`packages/prusa-wall-seam-scope/README.md\`; \`packages/prusa-wall-seam-scope/wall-seam-scope.md\`"
	require_section_table_row "${scope_file}" "wall-seam-scope.md" \
		"${SCOPE_RECORD_SECTION}" "Security note" "No secrets, credentials, private data, runtime file discovery, Git, network, device, host upload, release, sync, upstream import, or printer-runtime behavior is introduced by the Phase 62 wall-seam scope contract."
	require_section_table_row "${scope_file}" "wall-seam-scope.md" \
		"${SCOPE_RECORD_SECTION}" "Deferred scope" "Byte-for-byte G-code parity; broad generated-output verification; full wall-seam algorithm or geometry equivalence; seam visibility; printability; firmware behavior; printer-runtime behavior; GUI behavior; support generation; STEP import; full 3MF import/export; binary G-code; thumbnails; post-processing; host upload; network/device behavior; profile auto-update execution; fork release builds; Bambu Studio; OrcaSlicer; upstream source imports; release behavior; sync automation; non-Prusa fork behavior."
	require_section_table_row "${scope_file}" "wall-seam-scope.md" \
		"${SCOPE_RECORD_SECTION}" "Reviewer signoff" "Peter Ryszkiewicz, 2026-06-26 UTC"
}

verify_source_row_details() {
	require_section_table_row "${scope_file}" "wall-seam-scope.md" \
		"${SOURCE_ROW_SECTION}" "Source path" "\`src/libslic3r/GCode/SeamAligned.cpp\`"
	require_section_table_row "${scope_file}" "wall-seam-scope.md" \
		"${SOURCE_ROW_SECTION}" "Feature surface" "\`wall-seam\`"
	require_section_table_row "${scope_file}" "wall-seam-scope.md" \
		"${SOURCE_ROW_SECTION}" "Feature category" "\`wall-seam\`"
	require_section_table_row "${scope_file}" "wall-seam-scope.md" \
		"${SOURCE_ROW_SECTION}" "Ownership" "\`shared-downstream\`"
	require_section_table_row "${scope_file}" "wall-seam-scope.md" \
		"${SOURCE_ROW_SECTION}" "Complexity" "\`medium\`"
	require_section_table_row "${scope_file}" "wall-seam-scope.md" \
		"${SOURCE_ROW_SECTION}" "Parity dependency" "\`generated-outputs\`"
	require_section_table_row "${scope_file}" "wall-seam-scope.md" \
		"${SOURCE_ROW_SECTION}" "Inventory decision" "\`future-candidate\`"
	require_section_table_row "${scope_file}" "wall-seam-scope.md" \
		"${SOURCE_ROW_SECTION}" "Caution flags" "\`none\`"
	require_section_table_row "${scope_file}" "wall-seam-scope.md" \
		"${SOURCE_ROW_SECTION}" "Inventory note" "Wall seam planning row; future parity requires geometry and output fixtures before behavior is claimed."
}

verify_wall_seam_field_contract() {
	require_section_table_body_row_count "${scope_file}" "wall-seam-scope.md" "${WALL_SEAM_FIELD_SECTION}" "12"
	require_section_table_exact_row "${scope_file}" "wall-seam-scope.md" "${WALL_SEAM_FIELD_SECTION}" \
		"| source_ref | source identity | Accepted PrusaSlicer source identity only: \`${ACCEPTED_SOURCE_IDENTITY}\`. |"
	require_section_table_exact_row "${scope_file}" "wall-seam-scope.md" "${WALL_SEAM_FIELD_SECTION}" \
		"| inventory_source_paths | source identity | Inventory source paths only: \`src/libslic3r/GCode/SeamAligned.cpp\`. |"
	require_section_table_exact_row "${scope_file}" "wall-seam-scope.md" "${WALL_SEAM_FIELD_SECTION}" \
		"| source_anchor | source identity | Reviewed source anchor text or line reference only; no upstream import, Git access, or runtime source discovery. |"
	require_section_table_exact_row "${scope_file}" "wall-seam-scope.md" "${WALL_SEAM_FIELD_SECTION}" \
		"| fixture_id | fixture identity | Fixture identity string only for the Phase 63 checked-in fixture. |"
	require_section_table_exact_row "${scope_file}" "wall-seam-scope.md" "${WALL_SEAM_FIELD_SECTION}" \
		"| fixture_path | fixture identity | Checked-in fixture path under \`packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/\` only. |"
	require_section_table_exact_row "${scope_file}" "wall-seam-scope.md" "${WALL_SEAM_FIELD_SECTION}" \
		"| seam_transition_observations | seam transition observations | Observed seam transition facts from the checked-in summary only; no wall-seam algorithm equivalence, seam visibility, or byte-for-byte G-code parity. |"
	require_section_table_exact_row "${scope_file}" "wall-seam-scope.md" "${WALL_SEAM_FIELD_SECTION}" \
		"| layer_context_observations | layer context observations | Observed layer context facts from the checked-in summary only; no planner, geometry, printability, or printer-runtime behavior claim. |"
	require_section_table_exact_row "${scope_file}" "wall-seam-scope.md" "${WALL_SEAM_FIELD_SECTION}" \
		"| travel_context_observations | travel context observations | Observed travel context facts from the checked-in summary only; no path-planning equivalence, GUI behavior, or printer-runtime behavior claim. |"
	require_section_table_exact_row "${scope_file}" "wall-seam-scope.md" "${WALL_SEAM_FIELD_SECTION}" \
		"| coordinate_bounds | coordinate bounds | Bounded coordinate observations only; no wall-seam geometry equivalence, tolerance, or printability claim. |"
	require_section_table_exact_row "${scope_file}" "wall-seam-scope.md" "${WALL_SEAM_FIELD_SECTION}" \
		"| extrusion_observations | extrusion observations | Summary extrusion observations only; no material-use, runtime, or printability claim. |"
	require_section_table_exact_row "${scope_file}" "wall-seam-scope.md" "${WALL_SEAM_FIELD_SECTION}" \
		"| retraction_observations | retraction observations | Summary retraction observations only; no firmware, printer-runtime, or printability claim. |"
	require_section_table_exact_row "${scope_file}" "wall-seam-scope.md" "${WALL_SEAM_FIELD_SECTION}" \
		"| evidence_boundary | boundary text | Explicit statement of what the summary proves and what remains deferred; no executable public status claim before Phase 65. |"
}

verify_traceability_record() {
	require_section_table_row "${scope_file}" "wall-seam-scope.md" \
		"${TRACEABILITY_SECTION}" "Inventory row" "\`prusaslicer.wall-seam\` in \`packages/fork-inventories/prusaslicer.tsv\`"
	require_section_table_row "${scope_file}" "wall-seam-scope.md" \
		"${TRACEABILITY_SECTION}" "Category-map row" "\`${SEAM_CATEGORY_MAP_ID}\` in \`packages/fork-inventories/category-map.tsv\` references \`prusaslicer.wall-seam\` exactly once"
	require_section_table_row "${scope_file}" "wall-seam-scope.md" \
		"${TRACEABILITY_SECTION}" "Accepted source identity" "\`${ACCEPTED_SOURCE_IDENTITY}\`"
	require_section_table_row "${scope_file}" "wall-seam-scope.md" \
		"${TRACEABILITY_SECTION}" "Source path" "\`src/libslic3r/GCode/SeamAligned.cpp\`"
	require_text "${scope_file}" "wall-seam-scope.md" "src/libslic3r/GCode/SeamAligned.cpp#L16"
	require_text "${scope_file}" "wall-seam-scope.md" "src/libslic3r/GCode/SeamAligned.cpp#L115-L148"
	require_text "${scope_file}" "wall-seam-scope.md" "src/libslic3r/GCode/SeamAligned.cpp#L272-L313"
	require_text "${scope_file}" "wall-seam-scope.md" "src/libslic3r/GCode/SeamAligned.cpp#L463-L525"
	require_section_table_row "${scope_file}" "wall-seam-scope.md" \
		"${TRACEABILITY_SECTION}" "Planned fixture namespace" "\`packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/\`"
	require_section_table_row "${scope_file}" "wall-seam-scope.md" \
		"${TRACEABILITY_SECTION}" "Planned expected summary" "\`packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/expected-wall-seam-summary.tsv\`"
	require_section_table_row "${scope_file}" "wall-seam-scope.md" \
		"${TRACEABILITY_SECTION}" "Planned Rust boundary" "\`slic3r_flavors::prusa_wall_seam\`"
	require_section_table_row "${scope_file}" "wall-seam-scope.md" \
		"${TRACEABILITY_SECTION}" "Public evidence command" "\`bazel run //packages/parity:prusaslicer_wall_seam_parity\`"
	require_section_table_row "${scope_file}" "wall-seam-scope.md" \
		"${TRACEABILITY_SECTION}" "Published narrow status row" "Phase 65 published \`fork.prusaslicer.wall-seam\` as the narrow v1.16 checked-in wall-seam summary evidence slice backed by the Phase 62 scope contract, Phase 63 fixture corpus, Phase 64 Rust parser/readiness boundary, and Phase 65 public parity command."
	require_section_table_row "${scope_file}" "wall-seam-scope.md" \
		"${TRACEABILITY_SECTION}" "Existing G-code status row" "\`fork.prusaslicer.gcode-output\` stays limited to the existing semantic Prusa G-code evidence slice backed by Phase 53 through Phase 56."
	require_section_table_row "${scope_file}" "wall-seam-scope.md" \
		"${TRACEABILITY_SECTION}" "Existing arc-fitting status row" "\`fork.prusaslicer.arc-fitting\` stays limited to the existing arc-fitting evidence slice backed by Phase 57 through Phase 60."
	require_section_table_row "${scope_file}" "wall-seam-scope.md" \
		"${TRACEABILITY_SECTION}" "Broad status row" "\`generated-outputs\` stays \`in progress\` in \`packages/parity/status.tsv\`."
}

verify_published_status_wording() {
	require_text "${scope_file}" "wall-seam-scope.md" "${STATUS_WORDING_SECTION}"
	require_text "${scope_file}" "wall-seam-scope.md" \
		"The Phase 65 published status token is \`fork.prusaslicer.wall-seam\`."
	require_text "${scope_file}" "wall-seam-scope.md" \
		"Phase 65 published \`fork.prusaslicer.wall-seam\` as the narrow v1.16"
	require_text "${scope_file}" "wall-seam-scope.md" \
		"and Phase 65 public parity command."
}

verify_inventory_row() {
	require_exact_tsv_row_once "${inventory_file}" "packages/fork-inventories/prusaslicer.tsv" "${WALL_SEAM_INVENTORY_ROW}"
	require_first_field_count "${inventory_file}" "packages/fork-inventories/prusaslicer.tsv" "prusaslicer.wall-seam" "1"
	require_category_reference_count "${category_map_file}" "packages/fork-inventories/category-map.tsv" "prusaslicer.wall-seam" "1"

	local category_row_count
	category_row_count="$(awk -F '\t' -v map_id="${SEAM_CATEGORY_MAP_ID}" '$1 == map_id { count++ } END { print count + 0 }' "${category_map_file}")"
	if [[ "${category_row_count}" != "1" ]]; then
		error "packages/fork-inventories/category-map.tsv: expected exactly one ${SEAM_CATEGORY_MAP_ID} row, found ${category_row_count}"
	fi
}

verify_status_boundaries() {
	local generated_count

	generated_count="$(awk -F '\t' '$1 == "generated-outputs" && $2 == "in progress" { count++ } END { print count + 0 }' "${status_file}")"
	if [[ "${generated_count}" != "1" ]]; then
		error "packages/parity/status.tsv: expected generated-outputs to remain in progress"
	fi
	require_first_field_count "${status_file}" "packages/parity/status.tsv" "generated-outputs" "1"

	require_exact_tsv_row_once "${status_file}" "packages/parity/status.tsv" "${GCODE_OUTPUT_STATUS_ROW}"
	require_first_field_count "${status_file}" "packages/parity/status.tsv" "fork.prusaslicer.gcode-output" "1"

	require_exact_tsv_row_once "${status_file}" "packages/parity/status.tsv" "${ARC_FITTING_STATUS_ROW}"
	require_first_field_count "${status_file}" "packages/parity/status.tsv" "fork.prusaslicer.arc-fitting" "1"

	require_exact_tsv_row_once "${status_file}" "packages/parity/status.tsv" "${WALL_SEAM_STATUS_ROW}"
	require_first_field_count "${status_file}" "packages/parity/status.tsv" "fork.prusaslicer.wall-seam" "1"
}

reject_overclaiming_text() {
	local checked_file
	local checked_label
	local forbidden_claim
	local overclaim_term_then_verb_pattern
	local overclaim_terms
	local overclaim_verbs
	local overclaim_verb_then_term_pattern

	overclaim_terms='byte-for-byte G-code parity|full generated-output parity|broad generated-output parity|broad generated-output verification|full wall-seam algorithm or geometry equivalence|full wall-seam algorithm equivalence|wall-seam geometry equivalence|seam visibility|printability|firmware behavior|printer-runtime behavior|GUI behavior|support generation|STEP import|full 3MF import/export|binary G-code|thumbnails|post-processing|host upload|network/device behavior|profile auto-update execution|fork release builds|Bambu Studio|OrcaSlicer|upstream source imports|release behavior|sync automation|non-Prusa fork behavior'
	overclaim_verbs='proves|verified|verifies|validates?|confirms?|claims?|establishes?|demonstrates?|certifies?'
	overclaim_verb_then_term_pattern="Phase 62[^.]*[^[:alnum:]_](${overclaim_verbs})[^[:alnum:]_][^.]*(${overclaim_terms})"
	overclaim_term_then_verb_pattern="Phase 62[^.]*(${overclaim_terms})[^.]*[^[:alnum:]_](${overclaim_verbs})[^[:alnum:]_]"

	for checked_file in "${readme_file}" "${scope_file}"; do
		checked_label="$(basename "${checked_file}")"
		for forbidden_claim in \
			"Phase 62 proves byte-for-byte G-code parity" \
			"Phase 62 proves broad generated-output parity" \
			"Phase 62 verifies broad generated-output verification" \
			"Phase 62 verifies full wall-seam algorithm equivalence" \
			"Phase 62 validates wall-seam geometry equivalence" \
			"Phase 62 confirms seam visibility" \
			"Phase 62 confirms printability" \
			"Phase 62 claims printer-runtime behavior" \
			"Phase 62 establishes firmware behavior" \
			"Phase 62 demonstrates support generation" \
			"Phase 62 proves GUI behavior" \
			"Phase 62 proves release behavior" \
			"Phase 62 proves network/device behavior" \
			"Phase 62 proves non-Prusa fork behavior" \
			"Phase 62 proves Bambu Studio support" \
			"Phase 62 proves OrcaSlicer support" \
			"Phase 62 proves upstream source imports" \
			"Phase 62 proves sync automation" \
			"byte-for-byte G-code parity verified by Phase 62" \
			"full generated-output parity verified" \
			"broad generated-output parity verified by Phase 62" \
			"full wall-seam algorithm equivalence certified by Phase 62" \
			"wall-seam geometry equivalence certified by Phase 62" \
			"seam visibility verified by Phase 62" \
			"Bambu Studio support verified by Phase 62" \
			"OrcaSlicer support verified by Phase 62"; do
			reject_text "${checked_file}" "${checked_label}" "${forbidden_claim}"
		done
		if grep -Eiq -- "${overclaim_verb_then_term_pattern}|${overclaim_term_then_verb_pattern}" "${checked_file}"; then
			error "${checked_label}: forbidden Prusa wall-seam scope overclaim"
		fi
	done
}

reject_stale_publication_wording() {
	local planned_prefix="Planned"
	local phase_65_plan_prefix="Phase 65 plan"

	for stale_pattern in \
		"${planned_prefix} evidence command" \
		"${planned_prefix} status token" \
		"${planned_prefix} public evidence command" \
		"${planned_prefix} narrow status token" \
		"## ${planned_prefix} Status Wording" \
		"${phase_65_plan_prefix}ned \`fork.prusaslicer.wall-seam\`"; do
		reject_text "${scope_file}" "wall-seam-scope.md" "${stale_pattern}"
	done
}

verify_deferred_scope_terms() {
	for deferred_term in \
		"Byte-for-byte G-code parity" \
		"broad generated-output verification" \
		"full wall-seam algorithm or geometry equivalence" \
		"seam visibility" \
		"printability" \
		"firmware behavior" \
		"printer-runtime behavior" \
		"GUI behavior" \
		"support generation" \
		"STEP import" \
		"full 3MF import/export" \
		"binary G-code" \
		"thumbnails" \
		"post-processing" \
		"host upload" \
		"network/device behavior" \
		"profile auto-update execution" \
		"fork release builds" \
		"Bambu Studio" \
		"OrcaSlicer" \
		"upstream source imports" \
		"release behavior" \
		"sync automation" \
		"non-Prusa fork behavior"; do
		require_text "${scope_file}" "wall-seam-scope.md" "${deferred_term}"
	done
}

main() {
	require_file "${readme_file}" "README.md"
	require_file "${scope_file}" "wall-seam-scope.md"
	require_file "${inventory_file}" "packages/fork-inventories/prusaslicer.tsv"
	require_file "${category_map_file}" "packages/fork-inventories/category-map.tsv"
	require_file "${status_file}" "packages/parity/status.tsv"

	verify_readme
	verify_scope_record
	verify_source_row_details
	verify_wall_seam_field_contract
	verify_traceability_record
	verify_published_status_wording
	verify_inventory_row
	verify_status_boundaries
	reject_overclaiming_text
	reject_stale_publication_wording
	verify_deferred_scope_terms

	printf 'ok: Prusa wall-seam scope verification passed\n'
}

main "$@"
