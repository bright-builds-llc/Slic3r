# Migration Guidance

This guide explains how to use the Phase 4 contract inventory while the port is
still mostly `legacy-only`. Read
[`contract-inventory.md`](./contract-inventory.md) for the detailed contract
rows and [`package-map.md`](./package-map.md) for the current and future package
boundaries.

## Launcher Replacement

- Treat the user-visible launch contract as the thing that must survive. The
  legacy evidence is `packages/legacy-slic3r/slic3r.pl`,
  `packages/legacy-slic3r/package/osx/startup_script.sh`,
  `packages/legacy-slic3r/package/linux/startup_script.sh`, and
  `packages/legacy-slic3r/package/common/shell.cpp`.
- The replacement does not need to preserve Perl internals. It does need to
  preserve argument handoff, visible entrypoints, packaged startup behavior, and
  the surrounding packaging-visible expectations those scripts and wrappers
  encode.
- `packages/launcher` is the future owner boundary for this surface. Until that
  package contains real code, the launcher contract remains defined by the
  retained legacy entrypoints and the Phase 4 docs.
- Keep any temporary shell shims thin. Bazel should stay the top-level build and
  test entrypoint, while Rust owns long-term behavior and shell only bridges the
  smallest necessary handoff.

## Parity Strategy

- Treat parity evidence as a ladder rather than one undifferentiated blob:
  legacy source of truth, trusted check, then weaker or deferred evidence.
- A surface stays `legacy-only` until a real Rust-backed implementation exists.
  A surface becomes `in progress` only when implementation work has started but
  is not yet the trusted path. A surface becomes `rust-backed` only when the
  Rust implementation provides the behavior but parity still needs more proof. A
  surface becomes `verified` only after the tracked proof for that scope passes.
- The current trusted oracle is `//:legacy_oracle_smoke`. It proves the retained
  macOS CLI help path is alive. `//:legacy_oracle_test` remains broader but
  weaker or deferred evidence until the retained XS loader path is stabilized.
- Do not claim Rust-backed parity because a package boundary exists, because a
  Rust crate exists, or because a broader retained legacy test happens to exist.
  Concrete implementation and verification evidence must move together.

## Fixture Update Protocol

- The shared fixture home is `packages/parity-fixtures`. It now contains
  fixture corpora for the verified help/version/config/export/transform slices,
  Linux and Windows runtime paths, the scoped macOS packaged launcher bundle,
  and the scoped Linux and Windows package-shaped launcher trees.
- `packages/parity-fixtures/README.md` is the package-local fixture workflow
  reference and should stay aligned with this guide.
- Every future fixture should record provenance: which legacy command or source
  generated it, which contract item it supports, and any platform or scope
  limits.
- Fixture naming should follow the contract surface first, then the scenario.
  For example, launcher fixtures should not be mixed into generated-output or
  config fixture names.
- Future fork fixture work is reserved under
  `packages/parity-fixtures/forks/<vendor_id>/<inventory_id-or-slug>/<scenario>/`.
  Phase 38 creates
  `packages/parity-fixtures/forks/prusaslicer/prusaslicer.profile-schema/` for
  the Prusa profile/config evidence slice.
- `prusaslicer.project-file` fixture work must start from
  [`packages/prusa-project-file-scope`](../../packages/prusa-project-file-scope)
  and its reviewed Phase 41 scope record. The Phase 42 fixture now exists at
  `packages/parity-fixtures/forks/prusaslicer/prusaslicer.project-file/`, uses
  `seam_test_object.3mf`, and is checked by
  `bazel run //packages/parity-fixtures:verify_prusa_project_file_fixture`.
  The accepted source identity remains
  `prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961` from
  `src/libslic3r/Format/3mf.cpp`.
- `prusaslicer.gcode-output` fixture work starts from
  [`packages/prusa-gcode-output-scope`](../../packages/prusa-gcode-output-scope)
  and its Phase 53 closed semantic scope contract. Phase 46 created
  `packages/parity-fixtures/forks/prusaslicer/prusaslicer.gcode-output/`,
  `gcodewriter-set-speed.gcode`, and `expected-gcode-summary.tsv`; Phase 50
  adds `expected-gcode-structural-summary.tsv`, and Phase 54 adds
  `expected-gcode-semantic-summary.tsv`. Updates require reviewed intake
  changes to `packages/fork-vendors/forks.tsv`,
  `packages/fork-inventories/prusaslicer.tsv`, and
  `packages/prusa-gcode-output-scope/gcode-output-scope.md`. The accepted
  source identity remains
  `prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961` from
  `src/libslic3r/GCode.cpp`, with fixture bytes derived from
  `tests/fff_print/test_gcodewriter.cpp#L20-L35`.
- Phase 49 through Phase 52 remain the historical structural evidence rungs.
  The current published Prusa G-code evidence chain is Phase 53 closed semantic
  scope contract, Phase 54 semantic fixture summary, Phase 55 Rust semantic
  parser/readiness boundary, and Phase 56 public parity command.
- The narrow semantic Prusa G-code evidence slice is verified through
  `bazel run //packages/parity:prusaslicer_gcode_output_parity` and the exact
  `fork.prusaslicer.gcode-output` status row, backed by
  `expected-gcode-summary.tsv`, `expected-gcode-structural-summary.tsv`,
  `expected-gcode-semantic-summary.tsv`, `prusa_gcode_output_summary_lines`,
  `prusa_gcode_output_structural_summary_lines`, and
  `prusa_gcode_output_semantic_summary_lines`. Fixture updates still route
  through `packages/prusa-gcode-output-scope` and its Phase 53 closed semantic
  scope contract.
- The verified `prusaslicer.gcode-output` evidence slice does not prove
  byte-for-byte G-code parity, broad generated-output verification, toolpath
  geometry, printability, printer-runtime behavior, support generation, wall
  seam behavior, arc fitting, GUI behavior, release behavior, sync automation,
  or non-Prusa fork behavior. STEP import, full 3MF import/export, binary
  G-code, thumbnails, post-processing, host upload, network/device integration,
  profile auto-update execution, fork release builds, Bambu Studio, OrcaSlicer,
  and upstream source imports also remain deferred.
- Deferred Phase 56 G-code terms: byte-for-byte G-code parity, broad
  generated-output verification, toolpath geometry, printability,
  printer-runtime behavior, support generation, wall seam behavior, arc
  fitting, GUI behavior, release behavior, sync automation, non-Prusa fork
  behavior, STEP import, full 3MF import/export, binary G-code, thumbnails,
  post-processing, host upload, network/device integration, profile
  auto-update execution, fork release builds, Bambu Studio, OrcaSlicer,
  upstream source imports.
- `prusaslicer.arc-fitting` fixture work starts from
  [`packages/prusa-arc-fitting-scope`](../../packages/prusa-arc-fitting-scope)
  and its Phase 57 scope contract. Phase 58 created
  `packages/parity-fixtures/forks/prusaslicer/prusaslicer.arc-fitting/`,
  `arc-fitting-observations.gcode`, `fixture-provenance.tsv`, and
  `expected-arc-summary.tsv`; Phase 59 owns
  `slic3r_flavors::prusa_arc_fitting` and
  `prusa_arc_fitting_summary_lines`; Phase 60 publishes
  `bazel run //packages/parity:prusaslicer_arc_fitting_parity` and
  `fork.prusaslicer.arc-fitting` for the narrow Prusa arc-fitting checked-in
  summary evidence slice. The evidence chain is Phase 57 scope contract, Phase
  58 fixture corpus, Phase 59 Rust parser/readiness boundary, and Phase 60
  public command/status/docs. Broad `generated-outputs` remains `in progress`,
  and the existing `fork.prusaslicer.gcode-output` row remains separate.
- The verified `prusaslicer.arc-fitting` evidence slice does not prove
  byte-for-byte G-code parity, full generated-output parity, broad
  generated-output verification, full ArcWelder algorithm equivalence,
  tolerance or geometry parity, printability, firmware behavior,
  printer-runtime behavior, GUI behavior, support generation, wall seam
  behavior, STEP import, full 3MF import/export, binary G-code, thumbnails,
  post-processing, host upload, network/device behavior, profile auto-update
  execution, fork release builds, Bambu Studio, OrcaSlicer, upstream source
  imports, release behavior, sync automation, or non-Prusa fork behavior.
- `prusaslicer.wall-seam` fixture work starts from
  [`packages/prusa-wall-seam-scope`](../../packages/prusa-wall-seam-scope)
  and its Phase 62 scope contract. Phase 63 created
  `packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/`,
  `wall-seam-observations.gcode`, `fixture-provenance.tsv`, and
  `expected-wall-seam-summary.tsv`; Phase 64 owns
  `slic3r_flavors::prusa_wall_seam` and
  `prusa_wall_seam_summary_lines`; Phase 65 publishes
  `bazel run //packages/parity:prusaslicer_wall_seam_parity` and
  `fork.prusaslicer.wall-seam` for the narrow Prusa wall-seam checked-in
  summary evidence slice. The evidence chain is Phase 62 scope contract, Phase
  63 fixture corpus, Phase 64 Rust parser/readiness boundary, and Phase 65
  public command/status/docs. Broad `generated-outputs` remains `in progress`,
  `fork.prusaslicer.gcode-output` remains separate, and
  `fork.prusaslicer.arc-fitting` remains separate.
- The verified `prusaslicer.wall-seam` evidence slice does not prove
  byte-for-byte G-code parity, full generated-output parity, broad
  generated-output verification, full wall-seam algorithm equivalence,
  wall-seam geometry equivalence, seam visibility, printability, firmware
  behavior, printer-runtime behavior, GUI behavior, support generation, arc
  fitting behavior, STEP import, full 3MF import/export, binary G-code,
  thumbnails, post-processing, host upload, network/device behavior, profile
  auto-update execution, fork release builds, Bambu Studio, OrcaSlicer,
  upstream source imports, release behavior, sync automation, or non-Prusa fork
  behavior.
- The Phase 38 Prusa fixture namespace update route is: update only after a reviewed intake change updates packages/fork-vendors/forks.tsv and the Prusa checklist/baseline gate.
  Branch-head observations remain drift-only.
- When a change adds, removes, or materially alters a fixture-backed parity
  surface, update the relevant rows in `docs/port/contract-inventory.md` and
  `docs/port/parity-matrix.md`. If the protocol itself changes, update this
  guide in the same change.

## Future Fork Parity Status

- The complete v1.9 fork-parity deferral list lives in
  [`README.md#v19-fork-parity-deferrals`](./README.md#v19-fork-parity-deferrals).
  Link to that block instead of repeating the full list in every package doc.
- Future fork status tokens should use `fork.<inventory_id>` or an
  inventory-derived stable slug, and `verified` requires a real
  `//packages/parity:*_parity` evidence command.
- `fork.prusaslicer.profile-schema` is verified for this narrow Prusa
  profile-schema parser/config evidence slice only. Its executable evidence is
  `bazel run //packages/parity:prusaslicer_profile_schema_parity`, backed by
  `packages/parity-fixtures/forks/prusaslicer/prusaslicer.profile-schema/expected-summary.tsv`.
- `fork.prusaslicer.project-file` is verified for the narrow
  `prusaslicer.project-file` expected-summary evidence slice only. Its
  executable evidence is
  `bazel run //packages/parity:prusaslicer_project_file_parity`, backed by
  `packages/parity-fixtures/forks/prusaslicer/prusaslicer.project-file/expected-project-summary.tsv`.
  The evidence chain includes the Phase 42 fixture and the Phase 43 Rust summary
  boundary through
  `slic3r_flavors::prusa_project_file`,
  `parse_prusa_project_file_summary`, `prusa_project_file_metadata`, and
  `prusa_project_file_summary_lines`.
- `fork.prusaslicer.gcode-output` is verified for the narrow semantic Prusa
  G-code evidence slice only. Its executable evidence is
  `bazel run //packages/parity:prusaslicer_gcode_output_parity`, backed by
  `packages/parity-fixtures/forks/prusaslicer/prusaslicer.gcode-output/expected-gcode-summary.tsv`
  and
  `packages/parity-fixtures/forks/prusaslicer/prusaslicer.gcode-output/expected-gcode-structural-summary.tsv`
  and
  `packages/parity-fixtures/forks/prusaslicer/prusaslicer.gcode-output/expected-gcode-semantic-summary.tsv`.
  The evidence chain includes Phase 53 closed semantic scope contract, Phase 54
  semantic fixture summary, Phase 55 Rust semantic parser/readiness boundary
  through `slic3r_flavors::prusa_gcode_output`,
  `prusa_gcode_output_summary_lines`,
  `prusa_gcode_output_structural_summary_lines`, and
  `prusa_gcode_output_semantic_summary_lines`, and the Phase 56 public parity
  command/status wiring.
- `fork.prusaslicer.arc-fitting` is verified for the narrow Prusa arc-fitting
  checked-in summary evidence slice only. Its executable evidence is
  `bazel run //packages/parity:prusaslicer_arc_fitting_parity`, backed by
  `packages/parity-fixtures/forks/prusaslicer/prusaslicer.arc-fitting/expected-arc-summary.tsv`,
  `slic3r_flavors::prusa_arc_fitting`,
  `prusa_arc_fitting_summary_lines`, the Phase 57 scope contract, Phase 58
  fixture corpus, Phase 59 Rust parser/readiness boundary, and Phase 60 public
  command/status/docs. Broad `generated-outputs` remains `in progress`, and
  existing semantic Prusa G-code output evidence remains separate under
  `fork.prusaslicer.gcode-output`.
- The verified `fork.prusaslicer.arc-fitting` evidence slice does not prove
  byte-for-byte G-code parity, full generated-output parity, broad
  generated-output verification, full ArcWelder algorithm equivalence,
  tolerance or geometry parity, printability, firmware behavior,
  printer-runtime behavior, GUI behavior, support generation, wall seam
  behavior, STEP import, full 3MF import/export, binary G-code, thumbnails,
  post-processing, host upload, network/device behavior, profile auto-update
  execution, fork release builds, Bambu Studio, OrcaSlicer, upstream source
  imports, release behavior, sync automation, or non-Prusa fork behavior.
- `fork.prusaslicer.wall-seam` is verified for the narrow Prusa wall-seam
  checked-in summary evidence slice only. Its executable evidence is
  `bazel run //packages/parity:prusaslicer_wall_seam_parity`, backed by
  `packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/expected-wall-seam-summary.tsv`,
  `slic3r_flavors::prusa_wall_seam`,
  `prusa_wall_seam_summary_lines`, the Phase 62 scope contract, Phase 63
  fixture corpus, Phase 64 Rust parser/readiness boundary, and Phase 65 public
  command/status/docs. Broad `generated-outputs` remains `in progress`,
  existing semantic Prusa G-code output evidence remains separate under
  `fork.prusaslicer.gcode-output`, and existing Prusa arc-fitting evidence
  remains separate under `fork.prusaslicer.arc-fitting`.
- The verified `fork.prusaslicer.wall-seam` evidence slice does not prove
  byte-for-byte G-code parity, full generated-output parity, broad
  generated-output verification, full wall-seam algorithm equivalence,
  wall-seam geometry equivalence, seam visibility, printability, firmware
  behavior, printer-runtime behavior, GUI behavior, support generation, arc
  fitting behavior, STEP import, full 3MF import/export, binary G-code,
  thumbnails, post-processing, host upload, network/device behavior, profile
  auto-update execution, fork release builds, Bambu Studio, OrcaSlicer,
  upstream source imports, release behavior, sync automation, or non-Prusa fork
  behavior.
- Phase 39 creates parser/metadata readiness only through
  `slic3r_flavors::prusa_profile`, `parse_prusa_profile_bundle`, and
  `prusa_profile_schema_metadata`. It traces `prusaslicer.profile-schema` to
  `prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961`,
  source path `resources/profiles/PrusaResearch.ini`, fixture path
  `packages/parity-fixtures/forks/prusaslicer/prusaslicer.profile-schema/PrusaResearch.ini`,
  checklist path `packages/prusa-baseline/profile-schema-checklist.md`, and
  checklist status `future-candidate`.
- Future fork status requires executable parity evidence. Source pins,
  inventories, templates, checklist completion, and registry metadata remain
  planning inputs only.

Phase 37 routes PrusaSlicer baseline review through `packages/prusa-baseline`;
that package is a baseline/checklist gate only. Phase 38 creates static Prusa
inputs only, Phase 39 creates Rust parsing, and Phase 40 creates executable
parity/status publication for the narrow slice.

## Scope Now vs Deferred

- Current verified scope now includes the preferred Rust-backed launcher slice,
  Linux and Windows runtime paths, scoped packaged launcher trees, and scoped
  base release build artifacts:
  - `//packages/parity:linux_packaged_launcher_parity` verifies the Linux
    package-shaped launcher tree for the supported help/version/config/export/
    transform slice.
  - `//packages/parity:windows_packaged_launcher_parity` verifies the Windows
    package-shaped launcher tree for the supported help/version/config/export/
    transform slice.
  - `.github/workflows/release-build-artifacts.yml` uploads macOS, Linux, and
    Windows base package archives with `release-provenance.txt` after running
    the matching packaged launcher parity target.
- Deferred to later phases:
  - broader CLI behavior beyond the verified slice
  - GUI replacement work
  - full PrusaSlicer runtime support, network/device/cloud/credential behavior,
    profile auto-update execution, non-free plugin ingestion, vendor sync
    automation, and fork release packaging
  - generated-output parity for the Prusa profile-schema slice
  - release-grade package formats such as AppImage, MSI, and DMG
  - installers, signing, notarization, native/cross-compiled release binaries,
    broad bundled dependency layout, downstream fork work, fork-flavor builds,
    GitHub Release publishing, and release channels
- The docs should prefer plain statements of what is deferred over optimistic
  wording. If the repo cannot prove a surface today, keep it `legacy-only` and
  say so.
- Full PrusaSlicer runtime support remains deferred. GUI support remains
  deferred, generated-output parity remains deferred, fork release builds remain
  deferred, profile auto-update execution remains deferred, network/cloud/
  credential behavior remains deferred, non-free plugin ingestion remains
  deferred, and sync automation remains deferred.
- For `prusaslicer.project-file`, full 3MF import/export, full PrusaSlicer
  runtime support, GUI project behavior, generated-output parity, STEP import,
  support generation, arc fitting, wall seam behavior, network/device
  integration, profile auto-update execution, fork release builds, Bambu
  Studio, OrcaSlicer, upstream source imports, and sync automation remain
  deferred until later executable evidence deliberately covers one of those
  surfaces.
