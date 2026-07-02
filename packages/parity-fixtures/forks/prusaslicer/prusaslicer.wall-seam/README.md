# PrusaSlicer Wall-Seam Fixture

This namespace is `prusaslicer.wall-seam`. It contains the Phase 63 checked-in
wall-seam observation fixture and expected wall-seam summary for the accepted
source ref
`prusaslicer:version_2.9.5@9a583bd438b195856f3bcf7ea99b69ba4003a961`.

## Artifacts

- `wall-seam-observations.gcode` is the small reviewed wall-seam observation
  fixture.
- `fixture-provenance.tsv` pins the fixture to
  `src/libslic3r/GCode/SeamAligned.cpp`, accepted tag `version_2.9.5`, and
  peeled commit `9a583bd438b195856f3bcf7ea99b69ba4003a961`.
- `expected-wall-seam-summary.tsv` records exactly the Phase 62 approved
  wall-seam fields for this checked-in fixture.
- `packages/prusa-wall-seam-scope/wall-seam-scope.md` remains the reviewed
  scope contract for this fixture surface.

## Update Route

Update this namespace only after a reviewed intake change updates
`packages/fork-vendors/forks.tsv`, `packages/fork-inventories/prusaslicer.tsv`,
and `packages/prusa-wall-seam-scope/wall-seam-scope.md`.
Branch-head observation, upstream import, live generation, network access, and
sync behavior do not update these checked-in fixture bytes or summary rows.

## Phase Boundary

Phase 63 owns only the checked-in `prusaslicer.wall-seam` fixture namespace,
provenance, and expected summary. Phase 64 owns
`slic3r_flavors::prusa_wall_seam` Rust parser/readiness work. Phase 65 publishes bazel run //packages/parity:prusaslicer_wall_seam_parity and the fork.prusaslicer.wall-seam status row for checked-in wall-seam summary evidence only.

This namespace does not add byte-for-byte G-code parity, full generated-output
parity, broad generated-output verification, full wall-seam algorithm
equivalence, wall-seam geometry equivalence, seam visibility, printability,
firmware behavior, printer-runtime behavior, GUI behavior, support generation,
arc fitting behavior, STEP import, full 3MF import/export, binary G-code,
thumbnails, post-processing, host upload, network/device behavior, profile
auto-update execution, fork release builds, Bambu Studio, OrcaSlicer, upstream
source import, release behavior, sync behavior, or non-Prusa fork behavior. The
generated-output status promotion boundary remains outside this checked-in
fixture corpus.
