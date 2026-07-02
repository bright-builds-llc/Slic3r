# Rust Port Control Plane

This directory is the source of truth for the Slic3r Rust port during the migration.

Phase 1 establishes the monorepo scaffold, the retained legacy reference
package, and the documentation surfaces reviewers should use to understand
current progress. Phase 2 turns the retained legacy package into a Bazel-wrapped
oracle surface on macOS, but keeps that package explicitly reference-only.
Phase 3 makes `packages/slic3r-rust` a real Bright Builds-compliant Rust
workspace with Bazel-native build and verify surfaces. Phase 4 adds the
contract inventory and migration guidance that later implementation phases must
follow. Until automation exists, any Rust-port or parity-surface change is
expected to update the relevant docs here in the same change.

## Documents

- [`checklist.md`](./checklist.md) - migration-surface checklist for what
  exists, what is pending, and which docs or package boundaries already exist
- [`cli-slice.md`](./cli-slice.md) - currently supported Rust-backed macOS CLI
  workflow and explicitly unsupported arguments
- [`contract-inventory.md`](./contract-inventory.md) - evidence-backed registry
  of the externally visible contracts the Rust port must preserve
- [`entrypoint-architecture.md`](./entrypoint-architecture.md) - Rust, Bazel,
  launcher-package, and future shell-shim responsibilities for the first CLI
  slice
- [`migration-guidance.md`](./migration-guidance.md) - launcher replacement,
  parity evidence, fixture protocol, and scope-now-versus-deferred rules
- [`packaged-launcher-slice.md`](./packaged-launcher-slice.md) - scoped macOS
  packaged launcher bundle and startup layout expectations
- [`release-build-automation.md`](./release-build-automation.md) - scoped
  GitHub Actions release build artifacts, provenance, and evidence gates
- [`windows-launcher-slice.md`](./windows-launcher-slice.md) - scoped Windows
  runtime launcher surface and its deferred packaging boundaries
- [`parity-matrix.md`](./parity-matrix.md) - contract-surface status using the
  shared migration vocabulary
- [`package-map.md`](./package-map.md) - package roles, root-owned areas, and
  future owner boundaries in the monorepo

## Status Vocabulary

- `legacy-only` - only the retained legacy package currently provides the surface
- `in progress` - migration work exists, but the Rust path is not yet the trusted implementation
- `rust-backed` - the Rust implementation provides the surface, but parity still needs deeper proof
- `verified` - parity has been checked and accepted for the tracked scope

## Review Expectation

When a change touches Rust-port behavior, parity surfaces, launcher boundaries,
fixture protocol, or package ownership, reviewers should expect the relevant
file in `docs/port/` to move with it. If the docs do not change, the review
should explicitly explain why.

## Current Legacy Oracle State

- `//:legacy_oracle_build` is the Bazel-wrapped retained legacy build surface on macOS
- `//:legacy_oracle_smoke` is the current trusted oracle check
- `//:legacy_oracle_test` exists, but remains a deferred broader legacy test surface until the retained XS loader issues are fully resolved

This means the retained legacy package is now usable as a buildable oracle on macOS, but the trusted oracle set is intentionally narrower than the full historical test tree.

## Current Rust Workspace State

- `packages/slic3r-rust` now contains a real `slic3r_core` crate
- `//packages:rust_build` is the root-facing Bazel build entrypoint for the Rust package
- `//packages/slic3r-rust:verify` is the package-level verification surface
- Bazelisk is the expected local Bazel launcher on macOS because the repo pins Bazel in `.bazelversion`

Phase 3 changes the Rust workspace/tooling surface only. User-facing parity surfaces remain legacy-only until later phases.

## Current Entrypoint Architecture State

- `packages/slic3r-rust/crates/slic3r_contracts` is the stable contract-oriented
  launcher crate
- `packages/slic3r-rust/crates/slic3r_cli` is the launcher-facing Rust CLI
  scaffold
- `packages/launcher` is now a real package boundary that points at that Rust
  entrypoint scaffold
- Phase 6 makes `--version` the first supported Rust-backed macOS CLI workflow
  through `bazel run //packages/launcher:slic3r -- --version`
- Phase 21 adds the preferred Linux runtime path through
  `bazel run //packages/launcher:linux_slic3r -- --help`
- Phase 24 adds the preferred Windows runtime path through
  `bazel run //packages/launcher:windows_slic3r -- --help`
- Phase 18 adds a scoped macOS packaged launcher bundle through
  `bazel run //packages/launcher:macos_packaged_launcher_bundle`
- Phase 27 and Phase 28 add scoped Linux and Windows packaged launcher trees;
  Phase 29 verifies those package-shaped launcher trees through
  `//packages/parity:linux_packaged_launcher_parity` and
  `//packages/parity:windows_packaged_launcher_parity`
- Phase 31 adds scoped GitHub Actions release build artifacts for the base
  package through `.github/workflows/release-build-artifacts.yml`, with
  provenance embedded in each uploaded package tree.

## Current Contract Inventory State

- `docs/port/contract-inventory.md` is the detailed Phase 4 registry for CLI
  behavior, config semantics, supported file formats, generated outputs,
  launcher path, and packaging-visible behavior
- `docs/port/migration-guidance.md` explains how later phases should replace the
  launcher, interpret parity evidence, and evolve the future fixture corpus
- Phase 4 does not change any parity status by itself. It documents the contract
  surfaces and defers implementation claims to later phases
- `docs/port/packaged-launcher-slice.md` now documents the scoped macOS package
  bundle layout and startup expectations for the preferred launcher surface
- `docs/port/linux-launcher-slice.md` now documents the scoped Linux runtime
  handoff for the preferred launcher surface
- `docs/port/windows-launcher-slice.md` now documents the scoped Windows
  runtime handoff for the preferred launcher surface without claiming packaging
  parity

## Current Parity Visibility State

- `bazel run //packages/parity:status` is the current parity visibility command
- `bazel run //packages/parity:cli_version_parity` is the current shared fixture
  comparison command for the supported `--version` slice
- `bazel run //packages/parity:cli_help_parity` is the shared fixture
  comparison command for the supported `--help` slice
- `bazel run //packages/parity:cli_config_persistence_parity` is the shared
  fixture comparison command for the scoped config persistence slice
- `bazel run //packages/parity:export_workflows_parity` is the shared fixture
  comparison command for the verified scoped export workflows
- `bazel run //packages/parity:transform_workflows_parity` is the shared
  fixture comparison command for the verified scoped transform/info workflows
- `bazel run //packages/parity:macos_packaged_launcher_parity` is the shared
  parity command for the verified scoped macOS packaged launcher slice
- `bazel run //packages/parity:linux_runtime_parity` is the shared parity
  command for the verified scoped Linux runtime slice
- `bazel run //packages/parity:windows_runtime_parity` is the shared parity
  command for the verified scoped Windows runtime slice
- `bazel run //packages/parity:linux_packaged_launcher_parity` is the shared
  parity command for the verified scoped Linux packaged launcher tree
- `bazel run //packages/parity:windows_packaged_launcher_parity` is the shared
  parity command for the verified scoped Windows packaged launcher tree
- `bazel run //packages/parity:prusaslicer_gcode_output_parity` is the shared
  public command for the narrow semantic Prusa G-code evidence slice backed by
  the Phase 53 closed semantic scope contract, Phase 54 semantic fixture
  summary, Phase 55 Rust semantic parser/readiness boundary, and Phase 56
  public parity command/status wiring. The broad generated-outputs status
  remains in progress.
- `bazel run //packages/parity:prusaslicer_arc_fitting_parity` is the shared
  public command for the narrow Prusa arc-fitting checked-in summary evidence
  slice backed by the Phase 57 scope contract, Phase 58 fixture corpus, Phase
  59 Rust parser/readiness boundary, and Phase 60 public command/status/docs.
- `bazel run //packages/parity:prusaslicer_wall_seam_parity` is the shared
  public command for the narrow Prusa wall-seam checked-in summary evidence
  slice backed by the Phase 62 scope contract, Phase 63 fixture corpus, Phase
  64 Rust parser/readiness boundary, and Phase 65 public command/status/docs.
- `linux.packaged-launcher` and `windows.packaged-launcher` are checked-in
  status rows in `packages/parity/status.tsv`
- `packages/parity/status.tsv` is the checked-in status data source
- `packages/parity-fixtures/README.md` defines the package-local fixture update
  rules, and the fixture package now contains seeded corpora for:
  - `cli.version`
  - `cli.help`
  - `config.persistence`
  - `linux.runtime`
  - `windows.runtime`
  - `export.workflows`
  - `transform.workflows`
  - `launcher-packaging`
  - `linux.packaged-launcher`
  - `windows.packaged-launcher`
  - `prusaslicer.arc-fitting`
  - `prusaslicer.wall-seam`

## Current Fork Vendor Intake State

- `packages/fork-vendors/forks.tsv` is the checked-in vendor source registry
  for PrusaSlicer, Bambu Studio, and OrcaSlicer.
- `bazel run //packages/fork-vendors:verify` validates the selected stable tags
  and peeled commits recorded for those forks.
- Selected stable tags and peeled commits are the accepted source baseline for
  Phase 32. Branch heads are drift-only observations and are not accepted
  release-pin evidence.
- Source pins, source path inventories, license metadata, provenance notes, and
  branch observations are intake evidence only; they do not mark fork parity as verified.
- Non-free and network-plugin cautions remain scope and provenance warnings.
  They do not create runtime fork parity, online integration, credential, cloud,
  or plugin ingestion support.

## Current Fork Feature Inventory State

- `packages/fork-inventories` owns source-pinned feature inventory templates
  and per-fork inventory TSVs for PrusaSlicer, Bambu Studio, and OrcaSlicer.
- Run `bazel run //packages/fork-inventories:verify` to validate TSV shape,
  source pins, enum values, required surface coverage, parity dependencies, and
  category-map references without fetching, cloning, building, or importing
  upstream fork source trees.
- Inventories are source-observed planning inputs only. They do not prove executable parity, user-facing behavior, GUI support, fork release builds, or support for non-free/network plugins.

## Current Fork Template Package State

- `packages/fork-templates` owns the Phase 36 fork parity checklist,
  launcher-shape template, and manual drift-refresh protocol for later
  PrusaSlicer, Bambu Studio, and OrcaSlicer parity milestones.
- Run `bazel run //packages/fork-templates:verify` to check required template
  labels and reserved non-overclaiming wording. template verification does not prove fork parity.
- The manual drift protocol lives at
  `packages/fork-templates/manual-drift-refresh-protocol.md` and uses
  `bazel run //packages/fork-vendors:verify` as the current comparison tool.
- Source pins, inventories, templates, and registry metadata are planning
  inputs only. They do not prove fork runtime support, user-facing fork
  behavior, fork release builds, or support for online/cloud integrations,
  profile auto-update execution, credentials, or non-free plugin ingestion.

## Current Prusa Baseline Gate State

- `packages/prusa-baseline` owns the Phase 37 PrusaSlicer baseline and checklist
  gate for the narrow v1.10 profile schema/config evidence slice.
- Run `bazel run //packages/prusa-baseline:verify` to check the recorded
  `version_2.9.5` source pin, peeled commit
  `9a583bd438b195856f3bcf7ea99b69ba4003a961`, and
  `prusaslicer.profile-schema` checklist gate.
- Phase 37 verification does not prove Prusa runtime support.
- Phase 37 verification does not prove executable fork parity.
- Phase 37 creates no Prusa fixture files, fork parity status rows, executable
  Prusa parity targets, upstream source imports, runtime fork support, GUI
  support, sync automation, or fork release packaging.

## Current Prusa Fixture/Status Preparation State

- `packages/parity-fixtures/forks/prusaslicer/prusaslicer.profile-schema/`
  owns the Phase 38 static fixture namespace for the narrow Prusa profile
  schema/config evidence slice.
- `//packages/parity-fixtures:prusa_profile_schema_bundle` exports the raw
  fixture README, provenance TSV, `expected-summary.tsv`, `PrusaResearch.ini`,
  and `PrusaResearch.idx` files.
- `//packages/parity-fixtures:verify_prusa_profile_schema_fixture` checks the
  fixture files, source pin, sizes, SHA-256 values, provenance text, namespace
  boundary, and exact `fork.prusaslicer.profile-schema` status publication.
- `PrusaResearch.ini` and `PrusaResearch.idx` are static fixture inputs from
  `prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961`.
- `fork.prusaslicer.profile-schema` is now verified in
  `packages/parity/status.tsv` only for the narrow Prusa profile-schema parser/
  config evidence slice backed by `expected-summary.tsv`.
- Phase 38 supplies static fixture inputs, Phase 39 supplies Rust parsing, and
  Phase 40 supplies executable parity evidence through
  `bazel run //packages/parity:prusaslicer_profile_schema_parity`.
- Phase 40 still adds no upstream source-tree import, vendor sync automation,
  profile auto-update execution, Bambu Studio fixtures, OrcaSlicer fixtures,
  network/cloud/credential fixtures, non-free plugin fixtures, GUI support,
  generated-output parity, fork release builds, or full PrusaSlicer runtime
  support.

## Current Prusa Rust Boundary State

- Phase 39 creates parser/metadata readiness only through
  `slic3r_flavors::prusa_profile`, `parse_prusa_profile_bundle`, and
  `prusa_profile_schema_metadata`.
- The Rust boundary and Phase 40 summary evidence trace
  `prusaslicer.profile-schema` to
  `prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961`,
  source path `resources/profiles/PrusaResearch.ini`, fixture path
  `packages/parity-fixtures/forks/prusaslicer/prusaslicer.profile-schema/PrusaResearch.ini`,
  expected artifact path
  `packages/parity-fixtures/forks/prusaslicer/prusaslicer.profile-schema/expected-summary.tsv`,
  checklist path `packages/prusa-baseline/profile-schema-checklist.md`, and
  checklist status `future-candidate`.
- The exact current command is
  `bazel run //packages/parity:prusaslicer_profile_schema_parity`.
- `fork.prusaslicer.profile-schema` verifies the narrow Prusa profile-schema
  parser/config evidence slice only.
- Full PrusaSlicer runtime support remains deferred. GUI support remains
  deferred, generated-output parity remains deferred, fork release builds remain
  deferred, profile auto-update execution remains deferred, network/cloud/
  credential behavior remains deferred, non-free plugin ingestion remains
  deferred, and sync automation remains deferred.

## Current Prusa Project-File Scope Gate State

- `packages/prusa-project-file-scope` owns the Phase 41 checked-in scope gate
  for `prusaslicer.project-file`; run
  `bazel run //packages/prusa-project-file-scope:verify` to check the reviewed
  contract.
- The accepted source identity is
  `prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961`, with
  source path `src/libslic3r/Format/3mf.cpp`.
- The Phase 42 fixture path contract is
  `packages/parity-fixtures/forks/prusaslicer/prusaslicer.project-file/`; no
  fixture bytes or expected artifacts exist in Phase 41.
- The Phase 43 Rust boundary is planned as
  `slic3r_flavors::prusa_project_file`, but Phase 41 creates no Rust parser.
- The Phase 44 command is planned as
  `bazel run //packages/parity:prusaslicer_project_file_parity`, and the Phase
  44 status token is planned as `fork.prusaslicer.project-file`; neither the
  command nor the status row exists in Phase 41.
- The deferred scope keeps full PrusaSlicer runtime support, GUI project
  behavior, full 3MF import/export, generated-output parity, STEP import,
  support generation, arc fitting, wall seam behavior, network/device
  integration, profile auto-update execution, fork release builds, Bambu
  Studio, OrcaSlicer, upstream source imports, and sync automation outside the
  Phase 41 scope gate.

## Current Prusa Project-File Fixture Surface State

Phase 42 adds fixture bytes, fixture provenance, expected-project-summary.tsv, and bazel run //packages/parity-fixtures:verify_prusa_project_file_fixture for prusaslicer.project-file.
The fixture namespace lives at
`packages/parity-fixtures/forks/prusaslicer/prusaslicer.project-file/` and
contains `seam_test_object.3mf`, `fixture-provenance.tsv`, and
`expected-project-summary.tsv`.

## Current Prusa Project-File Rust Boundary State

Phase 43 supplies parser/metadata readiness only through
`slic3r_flavors::prusa_project_file`,
`parse_prusa_project_file_summary`, `prusa_project_file_metadata`, and
`prusa_project_file_summary_lines`. The focused Rust verification target is
`//packages/slic3r-rust/crates/slic3r_flavors:prusa_project_file_test`.

The boundary consumes caller-supplied TSV text from
`packages/parity-fixtures/forks/prusaslicer/prusaslicer.project-file/expected-project-summary.tsv`
and traces `prusaslicer.project-file` to
`prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961`,
source path `src/libslic3r/Format/3mf.cpp`, fixture path
`packages/parity-fixtures/forks/prusaslicer/prusaslicer.project-file/seam_test_object.3mf`,
scope record `packages/prusa-project-file-scope/project-file-scope.md`, and
status token `fork.prusaslicer.project-file`.

Phase 44 provides executable parity and status publication. The exact command
is `bazel run //packages/parity:prusaslicer_project_file_parity`, and the exact
status row is `fork.prusaslicer.project-file` in
`packages/parity/status.tsv`. The verified slice is the narrow
`prusaslicer.project-file` expected-summary evidence backed by
`packages/parity-fixtures/forks/prusaslicer/prusaslicer.project-file/expected-project-summary.tsv`,
the Phase 42 fixture, and the Phase 43 Rust summary boundary.

Full 3MF import/export, full PrusaSlicer runtime support, GUI project behavior,
generated-output parity, STEP import, support generation, arc fitting, wall
seam behavior, network/device integration, profile auto-update execution, fork
release builds, Bambu Studio, OrcaSlicer, upstream source imports, and sync
automation remain deferred.

## Current Prusa G-code Output Evidence State

- `packages/prusa-gcode-output-scope` owns the Phase 49 structural history and
  the Phase 53 closed semantic scope contract for `prusaslicer.gcode-output`;
  run `bazel run //packages/prusa-gcode-output-scope:verify` to check the
  reviewed semantic contract and no-overclaiming boundary.
- The accepted source identity is
  `prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961`, with
  source path `src/libslic3r/GCode.cpp` and companion API evidence
  `src/libslic3r/GCode.hpp`.
- Phase 49 through Phase 52 remain the historical structural evidence rungs.
  The current published evidence chain is Phase 53 closed semantic scope
  contract, Phase 54 semantic fixture summary, Phase 55 Rust semantic
  parser/readiness boundary, and Phase 56 public parity command.
- The fixture namespace is
  `packages/parity-fixtures/forks/prusaslicer/prusaslicer.gcode-output/`, with
  the source-pinned `gcodewriter-set-speed.gcode` fixture,
  `fixture-provenance.tsv`, `expected-gcode-summary.tsv`, and
  `expected-gcode-structural-summary.tsv`, plus the Phase 54
  `expected-gcode-semantic-summary.tsv`.
- The Rust boundary is `slic3r_flavors::prusa_gcode_output` in
  `packages/slic3r-rust/crates/slic3r_flavors/src/prusa_gcode_output.rs`, with
  `prusa_gcode_output_summary_lines` and
  `prusa_gcode_output_structural_summary_lines` and
  `prusa_gcode_output_semantic_summary_lines` over caller-supplied checked-in
  TSV artifacts.
- Phase 56 publishes
  `bazel run //packages/parity:prusaslicer_gcode_output_parity` and the exact
  `fork.prusaslicer.gcode-output` row in `packages/parity/status.tsv` for the
  narrow semantic Prusa G-code evidence slice. The broad generated-outputs
  status remains in progress.
- The semantic evidence does not prove byte-for-byte G-code parity, broad
  generated-output verification, toolpath geometry, printability,
  printer-runtime behavior, support generation, wall seam behavior, arc
  fitting, GUI behavior, release behavior, sync automation, or non-Prusa fork
  behavior. STEP import, full 3MF import/export, binary G-code, thumbnails,
  post-processing, host upload, network/device integration, profile
  auto-update execution, fork release builds, Bambu Studio, OrcaSlicer, and
  upstream source imports remain outside the Phase 56 evidence slice.

## Current Prusa Arc-Fitting Evidence State

- `packages/prusa-arc-fitting-scope` owns the Phase 57 scope contract and
  verifier for `prusaslicer.arc-fitting`.
- The accepted source identity is
  `prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961`, with
  source path `src/libslic3r/Geometry/ArcWelder.cpp`.
- The fixture namespace is
  `packages/parity-fixtures/forks/prusaslicer/prusaslicer.arc-fitting/`, and the
  expected artifact is `expected-arc-summary.tsv`.
- The Rust boundary is `slic3r_flavors::prusa_arc_fitting`, with helper
  `prusa_arc_fitting_summary_lines` over caller-supplied checked-in TSV
  artifacts.
- Phase 60 publishes
  `bazel run //packages/parity:prusaslicer_arc_fitting_parity` and the exact
  `fork.prusaslicer.arc-fitting` row in `packages/parity/status.tsv` for the
  narrow Prusa arc-fitting checked-in summary evidence slice.
- Evidence chain: Phase 57 scope contract, Phase 58 fixture corpus, Phase 59 Rust parser/readiness boundary, and Phase 60 public command/status/docs.
- The existing `fork.prusaslicer.gcode-output` row remains separate, and broad
  `generated-outputs` remains `in progress`.
- The arc-fitting evidence does not prove byte-for-byte G-code parity, full
  generated-output parity, broad generated-output verification, full ArcWelder
  algorithm equivalence, tolerance or geometry parity, printability, firmware
  behavior, printer-runtime behavior, GUI behavior, support generation, wall
  seam behavior, STEP import, full 3MF import/export, binary G-code, thumbnails,
  post-processing, host upload, network/device behavior, profile auto-update
  execution, fork release builds, Bambu Studio, OrcaSlicer, upstream source
  imports, release behavior, sync automation, or non-Prusa fork behavior.

## Current Prusa Wall-Seam Evidence State

- `packages/prusa-wall-seam-scope` owns the Phase 62 scope contract and
  verifier for `prusaslicer.wall-seam`.
- The accepted source identity is
  `prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961`, with
  source path `src/libslic3r/GCode/SeamAligned.cpp`.
- The fixture namespace is
  `packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/`, and the
  expected artifact is `expected-wall-seam-summary.tsv`.
- The Rust boundary is `slic3r_flavors::prusa_wall_seam`, with helper
  `prusa_wall_seam_summary_lines` over caller-supplied checked-in TSV
  artifacts.
- Phase 65 publishes
  `bazel run //packages/parity:prusaslicer_wall_seam_parity` and the exact
  `fork.prusaslicer.wall-seam` row in `packages/parity/status.tsv` for the
  narrow Prusa wall-seam checked-in summary evidence slice.
- Evidence chain: Phase 62 scope contract, Phase 63 fixture corpus, Phase 64 Rust parser/readiness boundary, and Phase 65 public command/status/docs.
- Existing `fork.prusaslicer.gcode-output` and
  `fork.prusaslicer.arc-fitting` remain separate, and broad
  `generated-outputs` remains `in progress`.
- The wall-seam evidence does not prove byte-for-byte G-code parity, full
  generated-output parity, broad generated-output verification, full wall-seam
  algorithm equivalence, wall-seam geometry equivalence, seam visibility,
  printability, firmware behavior, printer-runtime behavior, GUI behavior,
  support generation, arc fitting behavior, STEP import, full 3MF
  import/export, binary G-code, thumbnails, post-processing, host upload,
  network/device behavior, profile auto-update execution, fork release builds,
  Bambu Studio, OrcaSlicer, upstream source imports, release behavior, sync
  automation, or non-Prusa fork behavior.

## v1.9 Fork Parity Deferrals

Phase 36 keeps the complete v1.9 fork-parity deferral list here so package
docs can link to one stable control-plane statement. The following work is out
of scope for v1.9:

- full fork parity ports
- GUI migration
- fork-flavor release builds
- signing
- installers
- release channels
- nightly vendor sync
- cloud or network device integrations
- profile auto-update execution
- non-free plugin ingestion

These deferrals remain in force even when source pins, inventories, templates,
and flavor registry metadata exist. Future fork work needs executable parity
evidence before maintainers can publish fork fixture files, fork status rows, or
runtime support claims.

## Current Flavor Registry Boundary State

- `packages/slic3r-rust/crates/slic3r_flavors` consumes the Phase 34 typed
  contracts from `slic3r_contracts` and exposes `FlavorRegistryEntry`,
  `FlavorCapability`, `FlavorProvenance`, `all_flavors()`,
  `maybe_flavor(FlavorId)`, and capability filtering helpers.
- Rust flavor registry entries are planning and architecture metadata only.
  They do not mark fork behavior as verified or supported.
- The registry boundary is side-effect free static Rust metadata. No Git,
  filesystem, network, process, environment, clock, release,
  launcher-dispatch, runtime TSV parsing, online/cloud, credential, or plugin
  ingestion behavior belongs in this boundary.
