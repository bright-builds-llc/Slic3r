# Prusa Wall-Seam Scope Contract

`packages/prusa-wall-seam-scope` owns the Phase 62 reviewed scope contract for `prusaslicer.wall-seam`.

Run `bazel run //packages/prusa-wall-seam-scope:verify` to check the reviewed
Phase 62 wall-seam scope contract.

Phase 62 recorded the accepted source identity, inventory row, source anchors,
planned fixture namespace, planned expected wall-seam summary, planned Rust
boundary, security note, deferred generated-output scope, and reviewer signoff
for the narrow `prusaslicer.wall-seam` evidence slice.

Phase 65 now publishes
`bazel run //packages/parity:prusaslicer_wall_seam_parity` and
`fork.prusaslicer.wall-seam` for checked-in wall-seam summary evidence only.

Phase 62 creates no fixture bytes, expected wall-seam summary, Rust parser,
public parity command, verified `fork.prusaslicer.wall-seam` status row,
upstream source import, network/device behavior, printer-runtime behavior, GUI
behavior, Bambu Studio support, OrcaSlicer support, or release artifact.

The existing `fork.prusaslicer.gcode-output` status row remains limited to the
Phase 53 through Phase 56 semantic Prusa G-code evidence slice. The existing
`fork.prusaslicer.arc-fitting` status row remains limited to the Phase 57
through Phase 60 Prusa arc-fitting checked-in summary evidence slice. Broad
`generated-outputs` remains `in progress`.

## Records

- [`wall-seam-scope.md`](wall-seam-scope.md) records the Phase 62 maintainer
  scope contract, approved wall-seam evidence field list, traceability,
  published Phase 65 command/status wording, security note, and deferred scope for
  `prusaslicer.wall-seam`.

## Boundary

This package is metadata and verifier owned. It creates no generated-output
fixture corpus, executable Rust parser, runtime behavior, printability
evidence, upstream source import, or external integration.
