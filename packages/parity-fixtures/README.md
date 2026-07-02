# Parity Fixtures Package

`packages/parity-fixtures` is the home for shared legacy-versus-Rust fixture
corpora.

## Fixture Rules

- Group fixtures by contract surface first, then by scenario.
- Record provenance for every fixture: the legacy command, source file, or other
  contract anchor that produced it.
- Update the relevant `docs/port/` surfaces whenever a fixture-backed parity
  workflow is added or changed.

## Fork Fixture Namespace

Fork parity fixtures are reserved under:

```text
packages/parity-fixtures/forks/<vendor_id>/<inventory_id-or-slug>/<scenario>/
```

Phase 38 creates the first real fork fixture namespace at
`packages/parity-fixtures/forks/prusaslicer/prusaslicer.profile-schema/`.
It contains raw static `PrusaResearch.ini` and `PrusaResearch.idx` inputs from
`prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961`.
Phase 40 adds `expected-summary.tsv` as the checked-in expected artifact for the
narrow Prusa profile-schema parser/config evidence slice only, verified by
`bazel run //packages/parity:prusaslicer_profile_schema_parity`.

Phase 42 adds the Prusa project-file fixture namespace at
`packages/parity-fixtures/forks/prusaslicer/prusaslicer.project-file/`. It
contains the checked-in `seam_test_object.3mf` fixture,
`fixture-provenance.tsv`, and `expected-project-summary.tsv` for the fixture
surface only. The fixture bundle target is
`//packages/parity-fixtures:prusa_project_file_bundle`, and maintainers can
verify the fixture surface with
`bazel run //packages/parity-fixtures:verify_prusa_project_file_fixture`.
Phase 43 now consumes `expected-project-summary.tsv` through the
`slic3r_flavors::prusa_project_file` Rust parser/metadata boundary with
`parse_prusa_project_file_summary`, while fixture verification remains local to
this package. Phase 44 publishes executable project-file parity through
`bazel run //packages/parity:prusaslicer_project_file_parity` and the exact
`fork.prusaslicer.project-file` status row for the narrow expected-summary
evidence slice only.

Phase 46 adds the Prusa G-code output fixture namespace at
`packages/parity-fixtures/forks/prusaslicer/prusaslicer.gcode-output/`. It
contains the checked-in `gcodewriter-set-speed.gcode` fixture,
`fixture-provenance.tsv`, and `expected-gcode-summary.tsv` for the fixture
surface only. The fixture bundle target is
`//packages/parity-fixtures:prusa_gcode_output_bundle`, and maintainers can
verify the Phase 46 fixture surface with
`bazel run //packages/parity-fixtures:verify_prusa_gcode_output_fixture`.
The selected fixture is derived from source-controlled
`GCodeWriter::set_speed` expected-output literals at
`tests/fff_print/test_gcodewriter.cpp#L20-L35` under
`prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961` because
the accepted upstream tree has no checked-in `.gcode` blob. The Phase 49 closed
structural scope contract defines the allowed structural field set. Phase 50
adds `expected-gcode-structural-summary.tsv` to the same fixture namespace and
bundle as the source-pinned structural sidecar. Phase 51 consumes that sidecar
through the Rust structural parser/readiness boundary. Phase 52 verifies the
narrow structural evidence slice through
`bazel run //packages/parity:prusaslicer_gcode_output_parity` plus the exact
`fork.prusaslicer.gcode-output` status row. Phase 53 closes the semantic field
contract. Phase 54 adds `expected-gcode-semantic-summary.tsv` to the same
fixture namespace and `//packages/parity-fixtures:prusa_gcode_output_bundle`.
Phase 56 consumes `expected-gcode-semantic-summary.tsv` through
`bazel run //packages/parity:prusaslicer_gcode_output_parity` and the exact
`fork.prusaslicer.gcode-output` status row; the artifact remains checked-in
fixture evidence only, and the broad `generated-outputs` row remains
`in progress`.

Phase 58 adds the Prusa arc-fitting fixture namespace at
`packages/parity-fixtures/forks/prusaslicer/prusaslicer.arc-fitting/`. It
contains the checked-in `arc-fitting-observations.gcode` fixture,
`fixture-provenance.tsv`, and `expected-arc-summary.tsv` for the fixture
surface only. The fixture bundle target is
`//packages/parity-fixtures:prusa_arc_fitting_bundle`, and maintainers can
verify the fixture corpus with
`bazel run //packages/parity-fixtures:verify_prusa_arc_fitting_fixture`.
The source ref is
`prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961`, and
the source path is `src/libslic3r/Geometry/ArcWelder.cpp`. Phase 59 owns
`slic3r_flavors::prusa_arc_fitting`. Phase 60 publishes bazel run //packages/parity:prusaslicer_arc_fitting_parity and the fork.prusaslicer.arc-fitting status row for checked-in arc summary evidence only. Phase 58 does not update public port docs, broad
`generated-outputs` remains `in progress`, and the existing
`fork.prusaslicer.gcode-output` row remains limited to the Phase 53 through
Phase 56 semantic evidence slice.

Phase 63 adds the Prusa wall-seam fixture namespace at
`packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/`. It
contains the checked-in `wall-seam-observations.gcode` fixture,
`fixture-provenance.tsv`, and `expected-wall-seam-summary.tsv` for the fixture
surface only. The fixture bundle target is
`//packages/parity-fixtures:prusa_wall_seam_bundle`, and maintainers can
verify the fixture corpus with
`bazel run //packages/parity-fixtures:verify_prusa_wall_seam_fixture`. The
source ref is
`prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961`, and
the source path is `src/libslic3r/GCode/SeamAligned.cpp`. Phase 64 owns `slic3r_flavors::prusa_wall_seam` checked-in summary parser/readiness work. Phase 65 publishes bazel run //packages/parity:prusaslicer_wall_seam_parity and the fork.prusaslicer.wall-seam status row for checked-in wall-seam summary evidence only. Phase 63 does not update `packages/parity/status.tsv`, public parity behavior, Rust crates, or `docs/port/*`. The broad `generated-outputs` status remains `in progress`, the `fork.prusaslicer.gcode-output` row remains limited to the Phase 53 through Phase 56 semantic evidence slice, and the `fork.prusaslicer.arc-fitting` row remains limited to the Phase 57 through Phase 60 checked-in arc summary evidence slice.

The G-code fixture namespace itself does not prove byte-for-byte G-code
parity, full generated-output parity, broad generated-output verification, full
wall-seam algorithm equivalence, wall-seam geometry equivalence, seam
visibility, toolpath geometry, extrusion, timing, support generation, arc
fitting behavior, STEP import, full 3MF import/export, printer-runtime
behavior, firmware behavior, printability, GUI behavior, GUI export or viewer
behavior, binary G-code, thumbnails, post-processing, host upload,
network/device integration, profile auto-update execution, fork release builds,
Bambu Studio, OrcaSlicer, non-Prusa fork behavior, upstream source imports,
release behavior, or sync automation remain deferred.

Update route: update only after a reviewed intake change updates packages/fork-vendors/forks.tsv and the Prusa checklist/baseline gate.
Branch-head observations remain drift-only.
Fixture verification does not fetch upstream source, run profile auto-update execution, or ingest plugins.
Fixture verification checks checked-in artifacts only; it does not fetch upstream source, generate fixtures, upload G-code, run slicer runtime behavior, execute printer behavior, sync sources, or publish public status.

This fixture package does not introduce Bambu Studio fixtures, OrcaSlicer fixtures, network/device integration, cloud behavior, credentials, profile auto-update execution, non-free plugin ingestion, full PrusaSlicer runtime support, GUI support, sync automation, or fork release packaging. The narrow parser/config evidence is verified, and full PrusaSlicer runtime support remains deferred.

The fixture provenance cites the accepted upstream source URLs and
`metadata-only-not-legal-review`; it is provenance for static fixture inputs,
not legal-review completion.

Other fork fixture namespaces remain future-only until a fork feature has an
executable parity command, a reviewed checklist, and a matching future status
row. Source pins, inventories, templates, and registry metadata do not justify
additional fixture files by themselves.

## Current State

- Phase 7 defines the package and workflow rules.
- Phase 8 seeds the first shared CLI fixture corpus for `--version`.
- Phase 11 expands the shared fixture corpus to cover `--help` and scoped
  config persistence behavior.
- Phase 14 expands the shared fixture corpus to cover the scoped export
  workflows and the scoped transform/info workflows.
- Phase 19 expands the shared fixture corpus to cover the scoped macOS packaged
  launcher slice.
- Phase 20 extends the packaged launcher fixtures to cover representative
  packaged config persistence through the startup shim.
- Phase 22 adds a Linux runtime parity bundle that reuses the verified
  help/version/config/export/transform fixtures for the preferred Linux launcher path.
- Phase 25 adds a Windows runtime parity bundle that reuses the verified
  help/version/config/export/transform fixtures for the preferred Windows
  runtime path.
- Phase 29 adds Linux and Windows packaged launcher fixture bundles:
  `linux-packaged-launcher` is verified by
  `//packages/parity:linux_packaged_launcher_parity`, and
  `windows-packaged-launcher` is verified by
  `//packages/parity:windows_packaged_launcher_parity`.
- Phase 38 adds the Prusa profile-schema fixture bundle under
  `packages/parity-fixtures/forks/prusaslicer/prusaslicer.profile-schema/`,
  exported as `//packages/parity-fixtures:prusa_profile_schema_bundle` and
  checked by `//packages/parity-fixtures:verify_prusa_profile_schema_fixture`.
- Phase 40 adds `expected-summary.tsv` to that bundle and verifies it through
  `bazel run //packages/parity:prusaslicer_profile_schema_parity`.
- Phase 42 adds the Prusa project-file fixture namespace under
  `packages/parity-fixtures/forks/prusaslicer/prusaslicer.project-file/`,
  exported as `//packages/parity-fixtures:prusa_project_file_bundle` and
  checked by
  `bazel run //packages/parity-fixtures:verify_prusa_project_file_fixture`.
  Phase 43 consumes the checked-in `expected-project-summary.tsv` through the
  Rust parser boundary, and Phase 44 verifies the narrow expected-summary
  evidence slice through
  `bazel run //packages/parity:prusaslicer_project_file_parity` plus the exact
  `fork.prusaslicer.project-file` status row.
- Phase 46 adds the Prusa G-code output fixture namespace under
  `packages/parity-fixtures/forks/prusaslicer/prusaslicer.gcode-output/`,
  exported as `//packages/parity-fixtures:prusa_gcode_output_bundle` and
  checked by
  `bazel run //packages/parity-fixtures:verify_prusa_gcode_output_fixture`.
  Phase 49 closes the structural field contract, Phase 50 adds the checked-in
  `expected-gcode-structural-summary.tsv` sidecar, Phase 51 consumes the
  structural sidecar through the Rust parser/readiness boundary, and Phase 52
  verifies the narrow structural evidence slice through
  `bazel run //packages/parity:prusaslicer_gcode_output_parity` plus the exact
  `fork.prusaslicer.gcode-output` status row.
  Phase 53 closes the semantic field contract, and Phase 54 adds
  `expected-gcode-semantic-summary.tsv` to the same fixture namespace and
  `//packages/parity-fixtures:prusa_gcode_output_bundle`.
  Phase 56 consumes `expected-gcode-semantic-summary.tsv` through
  `bazel run //packages/parity:prusaslicer_gcode_output_parity` and the exact
  `fork.prusaslicer.gcode-output` status row while keeping the artifact as
  checked-in fixture evidence only.
- Phase 58 adds the Prusa arc-fitting fixture namespace under
  `packages/parity-fixtures/forks/prusaslicer/prusaslicer.arc-fitting/`,
  with `arc-fitting-observations.gcode`, `fixture-provenance.tsv`, and
  `expected-arc-summary.tsv` exported as
  `//packages/parity-fixtures:prusa_arc_fitting_bundle` and checked by
  `bazel run //packages/parity-fixtures:verify_prusa_arc_fitting_fixture`.
  The source ref is
  `prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961`, and
  the source path is `src/libslic3r/Geometry/ArcWelder.cpp`. Phase 59 owns
  `slic3r_flavors::prusa_arc_fitting`. Phase 60 publishes bazel run //packages/parity:prusaslicer_arc_fitting_parity and the fork.prusaslicer.arc-fitting status row for checked-in arc summary evidence only.
- Phase 63 adds the Prusa wall-seam fixture namespace under
  `packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/`, with
  `wall-seam-observations.gcode`, `fixture-provenance.tsv`, and
  `expected-wall-seam-summary.tsv` exported as
  `//packages/parity-fixtures:prusa_wall_seam_bundle` and checked by
  `bazel run //packages/parity-fixtures:verify_prusa_wall_seam_fixture`.
  The source ref is
  `prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961`, and
  the source path is `src/libslic3r/GCode/SeamAligned.cpp`. Phase 64 owns `slic3r_flavors::prusa_wall_seam` checked-in summary parser/readiness work. Phase 65 publishes bazel run //packages/parity:prusaslicer_wall_seam_parity and the fork.prusaslicer.wall-seam status row for checked-in wall-seam summary evidence only. Phase 63 does not update `packages/parity/status.tsv`, public parity behavior, Rust crates, or `docs/port/*`.
  The broad `generated-outputs` status remains `in progress`, the
  `fork.prusaslicer.gcode-output` row remains limited to semantic G-code
  evidence, and the `fork.prusaslicer.arc-fitting` row remains limited to
  checked-in arc summary evidence.
