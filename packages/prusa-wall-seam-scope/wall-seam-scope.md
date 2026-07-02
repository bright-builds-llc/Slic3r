# Prusa Wall-Seam Scope Contract

This Phase 62 scope record prepares the narrow `prusaslicer.wall-seam`
evidence contract. Completing this record does not prove executable wall-seam
parity, generated-output parity, byte-for-byte G-code parity, full wall-seam
algorithm or geometry equivalence, seam visibility, printability,
printer-runtime behavior, GUI behavior, support generation, STEP import,
release behavior, upstream imports, sync automation, or non-Prusa fork
behavior.

## Scope Record

| Required Field | Maintainer Entry |
| --- | --- |
| Inventory row ID | `prusaslicer.wall-seam` |
| Accepted source identity | `prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961` |
| Inventory row source | `packages/fork-inventories/prusaslicer.tsv` |
| Source path | `src/libslic3r/GCode/SeamAligned.cpp` |
| Fixture namespace decision | Phase 63 planned namespace `packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/`; no fixture bytes are checked in during Phase 62. |
| Expected-summary contract | Phase 63 planned `packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/expected-wall-seam-summary.tsv` with the approved Phase 62 wall-seam evidence fields; no expected wall-seam summary artifact is checked in during Phase 62. |
| Candidate Rust boundary | Phase 64 planned `slic3r_flavors::prusa_wall_seam` pure data-in/data-out boundary over caller-supplied checked-in wall-seam summaries; no Rust parser implementation is created in Phase 62. |
| Public evidence command | Phase 65 published `bazel run //packages/parity:prusaslicer_wall_seam_parity`; Phase 62 only planned the target and did not create it. |
| Published narrow status row | Phase 65 published `fork.prusaslicer.wall-seam` after executable evidence passed; Phase 62 only planned the row and did not publish it. |
| Docs touched | `packages/prusa-wall-seam-scope/README.md`; `packages/prusa-wall-seam-scope/wall-seam-scope.md` |
| Security note | No secrets, credentials, private data, runtime file discovery, Git, network, device, host upload, release, sync, upstream import, or printer-runtime behavior is introduced by the Phase 62 wall-seam scope contract. |
| Deferred scope | Byte-for-byte G-code parity; broad generated-output verification; full wall-seam algorithm or geometry equivalence; seam visibility; printability; firmware behavior; printer-runtime behavior; GUI behavior; support generation; STEP import; full 3MF import/export; binary G-code; thumbnails; post-processing; host upload; network/device behavior; profile auto-update execution; fork release builds; Bambu Studio; OrcaSlicer; upstream source imports; release behavior; sync automation; non-Prusa fork behavior. |
| Reviewer signoff | Peter Ryszkiewicz, 2026-06-26 UTC |

## Source Row Details

| Field | Value |
| --- | --- |
| Source path | `src/libslic3r/GCode/SeamAligned.cpp` |
| Feature surface | `wall-seam` |
| Feature category | `wall-seam` |
| Ownership | `shared-downstream` |
| Complexity | `medium` |
| Parity dependency | `generated-outputs` |
| Inventory decision | `future-candidate` |
| Caution flags | `none` |
| Inventory note | Wall seam planning row; future parity requires geometry and output fixtures before behavior is claimed. |

## Approved Wall-Seam Evidence Fields

This table is a closed contract for the Phase 63 checked-in wall-seam summary
and the Phase 64 typed Rust boundary. Unknown fields must fail closed.

| Wall-Seam Field | Category | Evidence Boundary |
| --- | --- | --- |
| source_ref | source identity | Accepted PrusaSlicer source identity only: `prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961`. |
| inventory_source_paths | source identity | Inventory source paths only: `src/libslic3r/GCode/SeamAligned.cpp`. |
| source_anchor | source identity | Reviewed source anchor text or line reference only; no upstream import, Git access, or runtime source discovery. |
| fixture_id | fixture identity | Fixture identity string only for the Phase 63 checked-in fixture. |
| fixture_path | fixture identity | Checked-in fixture path under `packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/` only. |
| seam_transition_observations | seam transition observations | Observed seam transition facts from the checked-in summary only; no wall-seam algorithm equivalence, seam visibility, or byte-for-byte G-code parity. |
| layer_context_observations | layer context observations | Observed layer context facts from the checked-in summary only; no planner, geometry, printability, or printer-runtime behavior claim. |
| travel_context_observations | travel context observations | Observed travel context facts from the checked-in summary only; no path-planning equivalence, GUI behavior, or printer-runtime behavior claim. |
| coordinate_bounds | coordinate bounds | Bounded coordinate observations only; no wall-seam geometry equivalence, tolerance, or printability claim. |
| extrusion_observations | extrusion observations | Summary extrusion observations only; no material-use, runtime, or printability claim. |
| retraction_observations | retraction observations | Summary retraction observations only; no firmware, printer-runtime, or printability claim. |
| evidence_boundary | boundary text | Explicit statement of what the summary proves and what remains deferred; no executable public status claim before Phase 65. |

## Wall-Seam Traceability

| Required Link | Exact Target |
| --- | --- |
| Inventory row | `prusaslicer.wall-seam` in `packages/fork-inventories/prusaslicer.tsv` |
| Category-map row | `seam.shared` in `packages/fork-inventories/category-map.tsv` references `prusaslicer.wall-seam` exactly once |
| Accepted source identity | `prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961` |
| Source path | `src/libslic3r/GCode/SeamAligned.cpp` |
| Source anchor | `src/libslic3r/GCode/SeamAligned.cpp#L16` names the `Slic3r::Seams::Aligned` namespace. |
| Source anchor | `src/libslic3r/GCode/SeamAligned.cpp#L115-L148` covers `get_seam_options` as source-pinned anchor text. |
| Source anchor | `src/libslic3r/GCode/SeamAligned.cpp#L272-L313` covers `get_seam_candidate` as source-pinned anchor text. |
| Source anchor | `src/libslic3r/GCode/SeamAligned.cpp#L463-L525` covers `get_object_seams` as source-pinned anchor text. |
| Planned fixture namespace | `packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/` |
| Planned expected summary | `packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/expected-wall-seam-summary.tsv` |
| Planned Rust boundary | `slic3r_flavors::prusa_wall_seam` |
| Public evidence command | `bazel run //packages/parity:prusaslicer_wall_seam_parity` |
| Published narrow status row | Phase 65 published `fork.prusaslicer.wall-seam` as the narrow v1.16 checked-in wall-seam summary evidence slice backed by the Phase 62 scope contract, Phase 63 fixture corpus, Phase 64 Rust parser/readiness boundary, and Phase 65 public parity command. |
| Existing G-code status row | `fork.prusaslicer.gcode-output` stays limited to the existing semantic Prusa G-code evidence slice backed by Phase 53 through Phase 56. |
| Existing arc-fitting status row | `fork.prusaslicer.arc-fitting` stays limited to the existing arc-fitting evidence slice backed by Phase 57 through Phase 60. |
| Broad status row | `generated-outputs` stays `in progress` in `packages/parity/status.tsv`. |
| Docs touched | `packages/prusa-wall-seam-scope/wall-seam-scope.md`; `packages/prusa-wall-seam-scope/README.md` |

## Published Status Wording

The Phase 65 published status token is `fork.prusaslicer.wall-seam`.

Phase 65 published `fork.prusaslicer.wall-seam` as the narrow v1.16 checked-in
wall-seam summary evidence slice backed by the Phase 62 scope contract, Phase
63 fixture corpus, Phase 64 Rust parser/readiness boundary, and Phase 65
public parity command.

`generated-outputs` stays `in progress`, `fork.prusaslicer.gcode-output` stays
limited to the existing semantic Prusa G-code evidence slice, and
`fork.prusaslicer.arc-fitting` stays limited to the existing arc-fitting
evidence slice.

## Boundary

This scope record is consumed by Phase 63 fixture corpus work, Phase 64 Rust
wall-seam boundary work, and Phase 65 public executable evidence/status/docs
publication. It still does not prove byte-for-byte G-code parity, broad
generated-output verification, full wall-seam algorithm or geometry
equivalence, seam visibility, printability, printer-runtime behavior, firmware
behavior, support generation, GUI behavior, release behavior, network/device
behavior, non-Prusa fork behavior, upstream source imports, or sync automation.
