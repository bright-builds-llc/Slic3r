# Parity Package

`packages/parity` owns migration visibility surfaces.

## Current Surface

- `bazel run //packages/parity:status` prints the current parity status table.
- `bazel run //packages/parity:cli_version_parity` runs the shared fixture
  comparison for the supported `--version` slice.
- `bazel run //packages/parity:cli_help_parity` runs the shared fixture
  comparison for the supported `--help` slice.
- `bazel run //packages/parity:cli_config_persistence_parity` runs the shared
  fixture comparison for the scoped config persistence slice.
- `bazel run //packages/parity:export_workflows_parity` runs the shared fixture
  comparison for the scoped export workflows.
- `bazel run //packages/parity:transform_workflows_parity` runs the shared
  fixture comparison for the scoped transform/info workflows.
- `bazel run //packages/parity:macos_packaged_launcher_parity` runs the shared
  parity evidence for the scoped macOS packaged launcher slice, including one
  representative packaged config persistence flow.
- `bazel run //packages/parity:linux_runtime_parity` runs the shared parity
  evidence for the supported Linux launcher/runtime slice.
- `bazel run //packages/parity:windows_runtime_parity` runs the shared parity
  evidence for the supported Windows runtime slice.
- `bazel run //packages/parity:linux_packaged_launcher_parity` runs the shared
  parity evidence for the scoped Linux packaged launcher tree.
- `bazel run //packages/parity:windows_packaged_launcher_parity` runs the
  shared parity evidence for the scoped Windows packaged launcher tree.
- `bazel run //packages/parity:prusaslicer_profile_schema_parity` runs the
  shared fixture comparison for the narrow Prusa profile-schema parser/config
  evidence slice backed by `expected-summary.tsv`.
- `bazel run //packages/parity:prusaslicer_project_file_parity` runs the
  shared fixture comparison for the narrow Prusa project-file expected-summary
  evidence slice backed by `expected-project-summary.tsv`.
- `bazel run //packages/parity:prusaslicer_gcode_output_parity` runs the
  shared fixture comparison for marker, structural, and semantic
  expected-summary evidence through the existing Rust summary binary. It is
  backed by `expected-gcode-summary.tsv`,
  `expected-gcode-structural-summary.tsv`, and
  `expected-gcode-semantic-summary.tsv`.
  Public proof: marker, structural, and semantic expected-summary evidence.
- `bazel run //packages/parity:prusaslicer_arc_fitting_parity` runs the shared
  fixture comparison for the narrow Prusa arc-fitting checked-in summary
  evidence slice backed by `expected-arc-summary.tsv`. Public proof:
  checked-in arc summary evidence only.
- `bazel run //packages/parity:prusaslicer_wall_seam_parity` runs the shared
  fixture comparison for the narrow Prusa wall-seam checked-in summary evidence
  slice backed by `expected-wall-seam-summary.tsv`. Public proof: checked-in
  wall-seam summary evidence only.
- `status.tsv` is the checked-in data source for those commands and status
  rows.

Linux and Windows runtime validation now publish as their own status rows.
Linux and Windows packaged launcher parity now has runnable shared evidence and
checked-in status rows:

- `linux.packaged-launcher` ->
  `//packages/parity:linux_packaged_launcher_parity`
- `windows.packaged-launcher` ->
  `//packages/parity:windows_packaged_launcher_parity`

## Scope

- Keep status reporting conservative.
- Do not mark a slice `verified` until the shared fixture comparison exists.

## Fork Status Rows

`fork.prusaslicer.profile-schema` is verified only for the narrow Prusa
profile-schema parser/config evidence slice. The evidence command is
`bazel run //packages/parity:prusaslicer_profile_schema_parity`, and the checked
expectation is
`packages/parity-fixtures/forks/prusaslicer/prusaslicer.profile-schema/expected-summary.tsv`.

That evidence traces to
`prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961`,
source path `resources/profiles/PrusaResearch.ini`, fixture path
`packages/parity-fixtures/forks/prusaslicer/prusaslicer.profile-schema/PrusaResearch.ini`,
checklist path `packages/prusa-baseline/profile-schema-checklist.md`, and
checklist status `future-candidate`.

`fork.prusaslicer.project-file` is verified only for the narrow
`prusaslicer.project-file` expected-summary evidence slice. The evidence
command is `bazel run //packages/parity:prusaslicer_project_file_parity`,
backed by
`packages/parity-fixtures/forks/prusaslicer/prusaslicer.project-file/expected-project-summary.tsv`.
That evidence is backed by the Phase 42 fixture and the Phase 43 Rust summary
boundary:
`//packages/slic3r-rust/crates/slic3r_flavors:prusa_project_file_summary`.
It traces `prusaslicer.project-file` to
`prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961`, source
path `src/libslic3r/Format/3mf.cpp`, fixture path
`packages/parity-fixtures/forks/prusaslicer/prusaslicer.project-file/seam_test_object.3mf`,
and status row `fork.prusaslicer.project-file`.

`fork.prusaslicer.gcode-output` is verified only for the narrow semantic
`prusaslicer.gcode-output` evidence slice. The evidence command is
`bazel run //packages/parity:prusaslicer_gcode_output_parity`, backed by
`packages/parity-fixtures/forks/prusaslicer/prusaslicer.gcode-output/expected-gcode-summary.tsv`,
`packages/parity-fixtures/forks/prusaslicer/prusaslicer.gcode-output/expected-gcode-structural-summary.tsv`,
and
`packages/parity-fixtures/forks/prusaslicer/prusaslicer.gcode-output/expected-gcode-semantic-summary.tsv`.
That command validates marker, structural, and semantic expected-summary
evidence through the existing Rust summary binary while publishing only the
narrow semantic Prusa G-code evidence slice. The evidence follows the Phase 53
closed semantic scope contract, the Phase 54 semantic fixture summary, the
Phase 55 Rust semantic parser/readiness boundary, and the Phase 56 public
parity command:
`//packages/slic3r-rust/crates/slic3r_flavors:prusa_gcode_output_summary`.
The Phase 56 public parity command proves executable semantic evidence/status
wiring through status row `fork.prusaslicer.gcode-output`. The broad
`generated-outputs` row remains `in progress`. It traces
`prusaslicer.gcode-output` to
`prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961`, fixture
path `packages/parity-fixtures/forks/prusaslicer/prusaslicer.gcode-output/`,
expected summary path
`packages/parity-fixtures/forks/prusaslicer/prusaslicer.gcode-output/expected-gcode-summary.tsv`,
expected structural summary path
`packages/parity-fixtures/forks/prusaslicer/prusaslicer.gcode-output/expected-gcode-structural-summary.tsv`,
expected semantic summary path
`packages/parity-fixtures/forks/prusaslicer/prusaslicer.gcode-output/expected-gcode-semantic-summary.tsv`,
and Rust boundary
`packages/slic3r-rust/crates/slic3r_flavors/src/prusa_gcode_output.rs`.

`fork.prusaslicer.arc-fitting` is verified only for the narrow Prusa
arc-fitting checked-in summary evidence slice. The evidence command is
`bazel run //packages/parity:prusaslicer_arc_fitting_parity`, and the checked
artifact is
`packages/parity-fixtures/forks/prusaslicer/prusaslicer.arc-fitting/expected-arc-summary.tsv`.
That command validates the checked-in artifact through the Rust boundary
`slic3r_flavors::prusa_arc_fitting` and helper
`prusa_arc_fitting_summary_lines`. The evidence chain is Phase 57 scope contract, Phase 58 fixture corpus, Phase 59 Rust parser/readiness boundary, and Phase 60 public command/status/docs. The broad `generated-outputs` row remains `in progress`, and existing semantic Prusa G-code output evidence remains separate under `fork.prusaslicer.gcode-output`.

`fork.prusaslicer.wall-seam` is verified only for the narrow Prusa wall-seam
checked-in summary evidence slice. The evidence command is
`bazel run //packages/parity:prusaslicer_wall_seam_parity`, and the checked
artifact is
`packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/expected-wall-seam-summary.tsv`.
That command validates the checked-in artifact through the Rust boundary
`slic3r_flavors::prusa_wall_seam` and helper
`prusa_wall_seam_summary_lines`. The evidence chain is Phase 62 scope contract, Phase 63 fixture corpus, Phase 64 Rust parser/readiness boundary, and Phase 65 public command/status/docs. The broad `generated-outputs` row remains `in progress`, existing semantic Prusa G-code output evidence remains separate under `fork.prusaslicer.gcode-output`, and existing Prusa arc-fitting evidence remains separate under `fork.prusaslicer.arc-fitting`.

Future fork status tokens should use `fork.<inventory_id>` or an
inventory-derived stable slug that traces back to `packages/fork-inventories`.
A fork row may become `verified` only when maintainers can rerun a real
`//packages/parity:*_parity` evidence command for that fork slice.

Source pins, inventories, checklist records, flavor metadata, and static
fixtures are planning inputs only. They do not prove full PrusaSlicer support,
fork runtime support, GUI support, network/device/cloud/credential behavior,
profile auto-update execution, non-free plugin ingestion, vendor sync
automation, fork release packaging, or status evidence by themselves.

Byte-for-byte G-code parity, full generated-output parity, broad
generated-output verification, full wall-seam algorithm equivalence, wall-seam
geometry equivalence, seam visibility, full ArcWelder algorithm equivalence,
tolerance or geometry parity, toolpath geometry, extrusion, timing, support
generation, arc fitting behavior, STEP import, full 3MF import/export, full
PrusaSlicer runtime support, printer-runtime behavior, firmware behavior,
printability, GUI project behavior, GUI export or viewer behavior, binary
G-code, thumbnails, post-processing, host upload, network/device integration,
profile auto-update execution, fork release builds, Bambu Studio, OrcaSlicer,
upstream source imports, release behavior, sync automation, and non-Prusa fork
behavior remain deferred.
