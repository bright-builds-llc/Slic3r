# Phase 65: Executable Wall-Seam Evidence - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md - this log preserves the alternatives considered.

**Date:** 2026-07-02T21:16:54.050Z
**Phase:** 65-Executable Wall-Seam Evidence
**Mode:** Yolo
**Areas discussed:** Public wall-seam evidence command, Public mutation guards, Status and public docs publication, Verification scope and sequencing

## Public wall-seam evidence command

| Option | Description | Selected |
| --- | --- | --- |
| Exact arc-fitting mirror | Add `compare_prusaslicer_wall_seam.sh`, `//packages/parity:prusaslicer_wall_seam_parity`, and a new `:prusa_wall_seam_summary` Rust binary. | yes |
| Shared generic checked-summary comparator | Refactor arc-fitting and wall-seam into a generic comparator. | |
| Delegate to fixture verifier or shell-only checks | Reuse fixture verification without a Rust-backed public summary command. | |
| Rust-only public parity binary | Move the public parity command into a Rust binary instead of the existing shell comparator pattern. | |

**User's choice:** Auto-selected exact arc-fitting mirror.
**Notes:** This is the lowest-risk match for Phase 65 because it validates the checked-in wall-seam summary through the Rust boundary while preserving existing public command contracts.

## Public mutation guards

| Option | Description | Selected |
| --- | --- | --- |
| Minimal command-drift guards | Prove target wiring only. | |
| Full mirrored arc-fitting mutation suite | Copy the arc-fitting public mutation shape without expanding for every wall-seam drift class. | |
| Targeted wall-seam-specific guard expansion | Cover the SEAMEV-02 drift classes on the public command surface. | yes |

**User's choice:** Auto-selected targeted wall-seam-specific guard expansion.
**Notes:** Public guards should mutate seam transition, layer context, travel context, coordinate bounds, extrusion, retraction, source identity, fixture identity/path, row order, and deferred-behavior claim text.

## Status and public docs publication

| Option | Description | Selected |
| --- | --- | --- |
| Minimal status row only | Add only `fork.prusaslicer.wall-seam` to `packages/parity/status.tsv`. | |
| Status plus parity README | Add the status row and make the public command discoverable in `packages/parity/README.md`. | |
| Status plus full port docs and verifier guards | Publish the status row, parity README, and relevant port docs while guarding existing rows and broad generated-output boundaries. | yes |

**User's choice:** Auto-selected status plus full port docs and verifier guards.
**Notes:** Phase 65 success criteria require maintainers to inspect status, package docs, and port docs, so package-only publication would be incomplete.

## Verification scope and sequencing

| Option | Description | Selected |
| --- | --- | --- |
| Focused Bazel public command/test/doc verifier checks | Prove the exact public Phase 65 surface only. | |
| Rust plus Bazel aggregate verification | Run focused public checks plus Rust and Bazel aggregate checks for changed Rust wiring. | yes |
| Full package/milestone verification | Run broad legacy/package/runtime suites. | |

**User's choice:** Auto-selected Rust plus Bazel aggregate verification.
**Notes:** The public command consumes Rust output, so verification should include the new public command/test, existing wall-seam fixture/scope verifiers, focused Rust coverage, Bazel Rust aggregate verification, and the Rust 1.94.1 Cargo suite when Rust wiring changes.

## the agent's Discretion

- Exact helper names and diagnostics inside the new shell comparator and test.
- Exact wording of public success output, provided it stays fact-oriented and narrow.
- Exact placement of doc/status guard assertions, provided they fail closed on broad generated-output or sibling-row widening.

## Deferred Ideas

None.
