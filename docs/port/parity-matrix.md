# Parity Matrix

Use this file as the high-level status dashboard. Use
[`contract-inventory.md`](./contract-inventory.md) for the detailed contract
rows and [`migration-guidance.md`](./migration-guidance.md) for launcher,
parity, and fixture rules.

| Surface | Current Source of Truth | Status | Detailed Inventory | Notes |
| --- | --- | --- | --- | --- |
| CLI behavior | Mixed: retained legacy CLI plus the preferred Rust-backed launcher slice | `in progress` | [`contract-inventory.md#cli-behavior`](./contract-inventory.md#cli-behavior) | `--version`, `--help`, config persistence, scoped export workflows, and the scoped info/repair/split slice are now verified through shared fixtures; broader CLI behavior remains legacy-owned |
| Linux runtime path | Preferred Linux launcher/runtime shim plus the existing Rust-backed CLI slice | `verified` | [`contract-inventory.md#launcher-path`](./contract-inventory.md#launcher-path) | The preferred Linux launcher path is verified for representative help/version/config/export/transform flows through shared parity evidence; the scoped Linux packaged launcher tree is separately verified as `linux.packaged-launcher` through `//packages/parity:linux_packaged_launcher_parity` |
| Windows runtime path | Preferred Windows runtime target plus the existing Rust-backed CLI slice | `verified` | [`contract-inventory.md#launcher-path`](./contract-inventory.md#launcher-path) | The preferred Windows runtime target is verified for representative help/version/config/export/transform flows through `//packages/parity:windows_runtime_parity`, and the scoped Windows packaged launcher tree is separately verified as `windows.packaged-launcher` through `//packages/parity:windows_packaged_launcher_parity` |
| Config semantics | `packages/legacy-slic3r/lib/Slic3r/Config.pm` and related legacy config code | `in progress` | [`contract-inventory.md#config-semantics`](./contract-inventory.md#config-semantics) | The scoped save/load/datadir slice is verified through shared fixtures; broader config semantics remain legacy-only |
| Supported file formats | Mixed: retained legacy runtime plus the scoped Rust-backed export slice | `in progress` | [`contract-inventory.md#supported-file-formats`](./contract-inventory.md#supported-file-formats) | The preferred launcher now verifies the scoped export families for G-code, STL, OBJ, AMF, 3MF, and SVG outputs; broader format parity remains legacy-only |
| Generated outputs | Mixed: retained legacy output pipeline plus the scoped Rust-backed export and transform slice | `in progress` | [`contract-inventory.md#generated-outputs`](./contract-inventory.md#generated-outputs) | The preferred launcher now verifies scoped output naming and artifact creation for supported exports plus repair/split utilities, `fork.prusaslicer.gcode-output` is verified only for the narrow semantic Prusa G-code evidence slice through `bazel run //packages/parity:prusaslicer_gcode_output_parity`, `fork.prusaslicer.arc-fitting` is verified only for the narrow Prusa arc-fitting checked-in summary evidence slice through `bazel run //packages/parity:prusaslicer_arc_fitting_parity`, and `fork.prusaslicer.wall-seam` is verified only for the narrow Prusa wall-seam checked-in summary evidence slice through `bazel run //packages/parity:prusaslicer_wall_seam_parity`. Phase 53 closed semantic scope contract, Phase 54 semantic fixture summary, Phase 55 Rust semantic parser/readiness boundary, and Phase 56 public parity command define the current verified Prusa G-code evidence chain; Phase 57 scope contract, Phase 58 fixture corpus, Phase 59 Rust parser/readiness boundary, and Phase 60 public command/status/docs define the current verified Prusa arc-fitting evidence chain; Phase 62 scope contract, Phase 63 fixture corpus, Phase 64 Rust parser/readiness boundary, and Phase 65 public command/status/docs define the current verified Prusa wall-seam evidence chain. Broad `generated-outputs` remains `in progress` because byte-for-byte G-code parity, full generated-output parity, broad generated-output verification, full ArcWelder algorithm equivalence, full wall-seam algorithm equivalence, tolerance or geometry parity, wall-seam geometry equivalence, seam visibility, printability, firmware behavior, printer-runtime behavior, GUI behavior, support generation, arc fitting behavior, STEP import, full 3MF import/export, binary G-code, thumbnails, post-processing, host upload, network/device behavior, profile auto-update execution, fork release builds, Bambu Studio, OrcaSlicer, upstream source imports, release behavior, sync automation, non-Prusa fork behavior, and broad generated-output content parity are still deferred |
| Launcher path | Mixed: retained legacy launcher plus the preferred Rust-backed launcher package | `in progress` | [`contract-inventory.md#launcher-path`](./contract-inventory.md#launcher-path) | `packages/launcher` now serves the supported Rust-backed CLI slice, the verified Linux runtime shim, the verified Windows runtime target, the scoped macOS packaged launcher surface, and the scoped Linux and Windows packaged launcher trees |
| Packaging-visible behavior | Mixed: retained legacy packaging scripts plus scoped macOS, Linux, and Windows packaged launcher slices | `in progress` | [`contract-inventory.md#packaging-visible-behavior`](./contract-inventory.md#packaging-visible-behavior) | The scoped macOS packaged launcher bundle is parity-verified for the supported slice; each Linux and Windows scoped packaged launcher tree has its own status row: `linux.packaged-launcher` is verified through `//packages/parity:linux_packaged_launcher_parity`, and `windows.packaged-launcher` is verified through `//packages/parity:windows_packaged_launcher_parity`; AppImage, MSI, DMG, installers, signing, GUI packaging, release archives, native/cross-compiled release binaries, broad dependency bundling, and release channels remain deferred |

## Oracle Interpretation

- `//:legacy_oracle_smoke` is the current trusted macOS oracle check. It proves
  the retained CLI entry path is buildable and that `slic3r.pl --help` runs.
- `//:legacy_oracle_test` exists as broader retained legacy evidence, but it is
  still weaker or deferred evidence until the retained XS loader path is fully
  stabilized.
- `bazel run //packages/parity:status` is the current parity visibility command,
  and `packages/parity/status.tsv` is its checked-in data source.
- Phase 4 inventories all six parity surface families now. Later phases are
  responsible for moving individual surfaces from `legacy-only` to `in progress`, `rust-backed`, and eventually `verified`.

## Fork Parity Interpretation

- Future fork rows should use `fork.<inventory_id>` or an inventory-derived
  stable slug only after executable parity evidence exists.
- A future fork row reaches `verified` only when backed by a real
  `//packages/parity:*_parity` evidence command.
- Do not infer fork runtime support from source pins, inventories, templates,
  checklist completion, or flavor registry metadata.
- `packages/prusa-baseline` is the Phase 37 PrusaSlicer baseline/checklist gate.
  Its records do not create Prusa runtime support, executable fork parity, fork
  status rows, or Prusa fixture files.
- Phase 39 adds parser/metadata readiness only through
  `slic3r_flavors::prusa_profile`, `parse_prusa_profile_bundle`, and
  `prusa_profile_schema_metadata` for `prusaslicer.profile-schema`. The
  boundary traces to
  `prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961`,
  `resources/profiles/PrusaResearch.ini`,
  `packages/parity-fixtures/forks/prusaslicer/prusaslicer.profile-schema/PrusaResearch.ini`,
  `packages/prusa-baseline/profile-schema-checklist.md`, and
  `future-candidate` status.
- `fork.prusaslicer.profile-schema` is verified in
  `packages/parity/status.tsv` for the narrow Prusa profile-schema parser/config
  evidence slice only. The evidence command is
  `bazel run //packages/parity:prusaslicer_profile_schema_parity`, backed by
  `packages/parity-fixtures/forks/prusaslicer/prusaslicer.profile-schema/expected-summary.tsv`.
- `fork.prusaslicer.project-file` is verified in
  `packages/parity/status.tsv` for the narrow `prusaslicer.project-file`
  expected-summary evidence slice only. The evidence command is
  `bazel run //packages/parity:prusaslicer_project_file_parity`, backed by
  `packages/parity-fixtures/forks/prusaslicer/prusaslicer.project-file/expected-project-summary.tsv`,
  the Phase 42 fixture, and the Phase 43 Rust summary boundary.
- Phase 43 supplies `slic3r_flavors::prusa_project_file` parser/metadata
  readiness through `parse_prusa_project_file_summary`,
  `prusa_project_file_metadata`, `prusa_project_file_summary_lines`,
  `//packages/slic3r-rust/crates/slic3r_flavors:prusa_project_file_test`, and
  `//packages/slic3r-rust/crates/slic3r_flavors:prusa_project_file_summary`.
- `packages/prusa-gcode-output-scope` owns the Phase 49 structural history and
  the Phase 53 closed semantic scope contract for `prusaslicer.gcode-output`.
  It records the accepted source identity, the allowed semantic field set, the
  Phase 54 semantic fixture summary, the Phase 55 Rust semantic
  parser/readiness boundary, the Phase 56 public parity command/status
  publication, and deferred scope.
- Phase 49 through Phase 52 remain the historical structural evidence rungs.
  The current published chain is Phase 53 closed semantic scope contract, Phase
  54 semantic fixture summary, Phase 55 Rust semantic parser/readiness boundary,
  and Phase 56 public parity command.
- Phase 46 fixture artifacts exist at
  `packages/parity-fixtures/forks/prusaslicer/prusaslicer.gcode-output/` with
  `gcodewriter-set-speed.gcode`, `fixture-provenance.tsv`, and
  `expected-gcode-summary.tsv`, plus the Phase 50
  `expected-gcode-structural-summary.tsv` and the Phase 54
  `expected-gcode-semantic-summary.tsv`, verified by
  `bazel run //packages/parity-fixtures:verify_prusa_gcode_output_fixture`.
- `fork.prusaslicer.gcode-output` is verified in `packages/parity/status.tsv`
  only for the narrow semantic Prusa G-code evidence slice through
  `bazel run //packages/parity:prusaslicer_gcode_output_parity`, backed by
  `expected-gcode-summary.tsv`, `expected-gcode-structural-summary.tsv`,
  `expected-gcode-semantic-summary.tsv`, `prusa_gcode_output_summary_lines`,
  `prusa_gcode_output_structural_summary_lines`,
  `prusa_gcode_output_semantic_summary_lines`, the Phase 53 closed semantic
  scope contract, the Phase 54 semantic fixture summary, the Phase 55 Rust
  semantic parser/readiness boundary, and the Phase 56 public parity command.
  Broad `generated-outputs` remains `in progress`.
- The verified G-code evidence slice does not prove byte-for-byte G-code
  parity, broad generated-output verification, toolpath geometry,
  printability, printer-runtime behavior, support generation, wall seam
  behavior, arc fitting, STEP import, full 3MF import/export, GUI behavior,
  binary G-code, thumbnails, post-processing, host upload, network/device
  integration, profile auto-update execution, fork release builds, Bambu
  Studio, OrcaSlicer, upstream source imports, release behavior, sync
  automation, or non-Prusa fork behavior.
- Deferred Phase 56 G-code terms: byte-for-byte G-code parity, broad
  generated-output verification, toolpath geometry, printability,
  printer-runtime behavior, support generation, wall seam behavior, arc
  fitting, STEP import, full 3MF import/export, GUI behavior, binary G-code,
  thumbnails, post-processing, host upload, network/device integration, profile
  auto-update execution, fork release builds, Bambu Studio, OrcaSlicer,
  upstream source imports, release behavior, sync automation, non-Prusa fork
  behavior.
- `fork.prusaslicer.arc-fitting` is verified in `packages/parity/status.tsv`
  only for the narrow Prusa arc-fitting checked-in summary evidence slice
  through `bazel run //packages/parity:prusaslicer_arc_fitting_parity`, backed
  by
  `packages/parity-fixtures/forks/prusaslicer/prusaslicer.arc-fitting/expected-arc-summary.tsv`,
  `slic3r_flavors::prusa_arc_fitting`,
  `prusa_arc_fitting_summary_lines`, the Phase 57 scope contract, Phase 58
  fixture corpus, Phase 59 Rust parser/readiness boundary, and Phase 60 public
  command/status/docs. Broad `generated-outputs` remains `in progress`, and the
  existing `fork.prusaslicer.gcode-output` row remains separate.
- The verified arc-fitting evidence slice does not prove byte-for-byte G-code
  parity, full generated-output parity, broad generated-output verification,
  full ArcWelder algorithm equivalence, tolerance or geometry parity,
  printability, firmware behavior, printer-runtime behavior, GUI behavior,
  support generation, wall seam behavior, STEP import, full 3MF import/export,
  binary G-code, thumbnails, post-processing, host upload, network/device
  behavior, profile auto-update execution, fork release builds, Bambu Studio,
  OrcaSlicer, upstream source imports, release behavior, sync automation, or
  non-Prusa fork behavior.
- `fork.prusaslicer.wall-seam` is verified in `packages/parity/status.tsv`
  only for the narrow Prusa wall-seam checked-in summary evidence slice through
  `bazel run //packages/parity:prusaslicer_wall_seam_parity`, backed by
  `packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/expected-wall-seam-summary.tsv`,
  `slic3r_flavors::prusa_wall_seam`,
  `prusa_wall_seam_summary_lines`, the Phase 62 scope contract, Phase 63
  fixture corpus, Phase 64 Rust parser/readiness boundary, and Phase 65 public
  command/status/docs. Broad `generated-outputs` remains `in progress`,
  `fork.prusaslicer.gcode-output` remains separate, and
  `fork.prusaslicer.arc-fitting` remains separate.
- The verified wall-seam evidence slice does not prove byte-for-byte G-code
  parity, full generated-output parity, broad generated-output verification,
  full wall-seam algorithm equivalence, wall-seam geometry equivalence, seam
  visibility, printability, firmware behavior, printer-runtime behavior, GUI
  behavior, support generation, arc fitting behavior, STEP import, full 3MF
  import/export, binary G-code, thumbnails, post-processing, host upload,
  network/device behavior, profile auto-update execution, fork release builds,
  Bambu Studio, OrcaSlicer, upstream source imports, release behavior, sync
  automation, or non-Prusa fork behavior.
- The verified `prusaslicer.project-file` row does not prove full 3MF
  import/export or full PrusaSlicer runtime support. GUI project behavior,
  generated-output parity, STEP import, support generation, arc fitting, wall
  seam behavior, network/device integration, profile auto-update execution,
  fork release builds, Bambu Studio, OrcaSlicer, upstream source imports, and
  sync automation remain deferred.
- Full PrusaSlicer runtime support remains deferred. GUI support remains
  deferred, generated-output parity remains deferred, fork release builds remain
  deferred, profile auto-update execution remains deferred, network/cloud/
  credential behavior remains deferred, non-free plugin ingestion remains
  deferred, and sync automation remains deferred.
