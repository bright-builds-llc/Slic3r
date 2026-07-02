---
generated_by: gsd-discuss-phase
lifecycle_mode: yolo
phase_lifecycle_id: 65-2026-07-02T21-16-54
generated_at: 2026-07-02T21:16:54.050Z
---

# Phase 65: Executable Wall-Seam Evidence - Context

**Gathered:** 2026-07-02
**Status:** Ready for planning
**Mode:** Yolo

<domain>
## Phase Boundary

Phase 65 publishes the executable public evidence surface for the narrow
PrusaSlicer wall-seam checked-in summary slice. It adds the public command,
public fail-closed mutation guards, the exact `fork.prusaslicer.wall-seam`
status/docs publication, and verification evidence that the command validates
the checked-in wall-seam summary through the Rust boundary.

This phase must not broaden `generated-outputs`, `fork.prusaslicer.gcode-output`,
or `fork.prusaslicer.arc-fitting`. It must keep byte-for-byte G-code parity,
full wall-seam algorithm equivalence, wall-seam geometry equivalence, seam
visibility, printability, firmware/runtime behavior, GUI behavior, release
behavior, sync automation, upstream imports, and non-Prusa fork behavior
deferred.

</domain>

<decisions>
## Implementation Decisions

### Public wall-seam evidence command

- **D-01:** Mirror the Phase 60 arc-fitting public command pattern. Add a
  Rust summary binary equivalent to `prusa_arc_fitting_summary`, expected as
  `//packages/slic3r-rust/crates/slic3r_flavors:prusa_wall_seam_summary`,
  backed by `slic3r_flavors::prusa_wall_seam_summary_lines`.
- **D-02:** Add a thin public comparator in `packages/parity`, expected as
  `compare_prusaslicer_wall_seam.sh`, and expose it through
  `bazel run //packages/parity:prusaslicer_wall_seam_parity`.
- **D-03:** The public comparator should validate
  `expected-wall-seam-summary.tsv` through the Rust wall-seam boundary, diff
  expected summary lines against actual summary lines, assert the 12
  wall-seam facts, and print a clear `ok:` success line plus the public
  evidence facts maintainers should inspect.
- **D-04:** Do not refactor the existing arc-fitting or G-code output public
  commands into a shared generic comparator in this phase. Consolidation can
  be a later cleanup only after this narrow publication is verified.

### Public mutation guards

- **D-05:** Add a wall-seam-specific public mutation test instead of only a
  minimal command-wiring check. The test should reuse the style of
  `compare_prusaslicer_arc_fitting_test.sh` while mutating wall-seam-specific
  fields and boundaries.
- **D-06:** Public mutation coverage must include seam-transition observation
  changes, layer-context changes, travel-context changes, coordinate-bound
  changes, extrusion observation changes, retraction observation changes,
  source identity drift, fixture identity/path drift, row-order drift, and
  unsupported deferred-behavior claim text.
- **D-07:** The public mutation test complements, but does not replace, the
  existing fixture verifier and Rust parser tests. Lower layers still own byte
  and parser invariants; the new public test proves the public command fails
  closed for Phase 65's named drift classes.
- **D-08:** Failure diagnostics should name the changed wall-seam field or
  boundary where practical, matching the existing arc-fitting comparator's
  maintainer-friendly diagnostics.

### Status and public docs publication

- **D-09:** Publish exactly one new status row:
  `fork.prusaslicer.wall-seam` with evidence
  `//packages/parity:prusaslicer_wall_seam_parity`. The row text must describe
  only the narrow Prusa wall-seam checked-in summary evidence slice backed by
  Phase 62 scope, Phase 63 fixture corpus, Phase 64 Rust boundary, and Phase
  65 public command/status/docs.
- **D-10:** Preserve `generated-outputs` as exactly one `in progress` row.
  Preserve the existing `fork.prusaslicer.gcode-output` and
  `fork.prusaslicer.arc-fitting` row meanings and do not add wall-seam claims
  to either row.
- **D-11:** Update `packages/parity/README.md` so maintainers can discover the
  wall-seam public command beside the existing Prusa fork evidence commands.
- **D-12:** Update public port docs that currently describe generated-output
  and Prusa fork evidence status, including `docs/port/package-map.md`,
  `docs/port/parity-matrix.md`, and `docs/port/migration-guidance.md`.
  Update `docs/port/README.md` as needed if its current Prusa evidence list
  would otherwise become stale.
- **D-13:** Add verifier/test guards where the touched public command and docs
  make sense so docs/status drift does not silently widen `generated-outputs`
  or existing Prusa rows.

### Verification scope and sequencing

- **D-14:** Use a narrow-to-aggregate verification sequence for Phase 65:
  first the new public command and public mutation test, then existing wall-seam
  fixture/scope verifiers, then Rust/Bazel aggregate checks for the summary
  binary and crate wiring.
- **D-15:** Expected checks include the new
  `//packages/parity:prusaslicer_wall_seam_parity` run target, the new public
  parity failure test, `bazel run //packages/parity-fixtures:verify_prusa_wall_seam_fixture`,
  `bazel test //packages/parity-fixtures:verify_prusa_wall_seam_fixture_test`,
  `bazel run //packages/prusa-wall-seam-scope:verify`,
  `bazel test //packages/prusa-wall-seam-scope:verify_prusa_wall_seam_scope_test`,
  focused Rust wall-seam coverage, and `bazel test //packages/slic3r-rust:verify`
  when Rust/Bazel wiring changes.
- **D-16:** Run the Rust 1.94.1 Cargo suite for the Rust workspace when adding
  the summary binary or changing crate wiring:
  `rustup run 1.94.1 cargo test --manifest-path packages/slic3r-rust/Cargo.toml --all-features`.
- **D-17:** Do not run broad legacy, launcher runtime, packaging, or
  `bazel test //...` suites unless implementation escapes the Phase 65
  surfaces above or verification evidence points to a cross-surface risk.

### the agent's Discretion

- Choose exact helper function names in the new shell comparator/test, provided
  the scripts use `#!/usr/bin/env bash`, `set -euo pipefail`, deterministic
  diagnostics, and repo-local paths consistent with existing `packages/parity`
  scripts.
- Choose exact success output wording, provided maintainers can identify the
  source ref, fixture path, expected summary, row count, wall-seam observation
  facts, and narrow evidence boundary.
- Choose whether doc guards live in the public parity test, existing verifiers,
  or a focused helper, provided the status/docs publication cannot drift into
  broad generated-output or sibling-row claims without a failing check.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase scope

- `.planning/ROADMAP.md` - Phase 65 goal, requirements, success criteria, and
  planned six-plan breakdown.
- `.planning/REQUIREMENTS.md` - SEAMEV-01, SEAMEV-02, SEAMEV-03, and future
  generated-output requirements that remain deferred.
- `.planning/PROJECT.md` - v1.16 wall-seam evidence ladder, current-state
  constraints, and status publication boundary.
- `.planning/STATE.md` - current focus and accumulated wall-seam handoff notes.

### Locked prior phase decisions

- `.planning/phases/62-wall-seam-scope-contract/62-CONTEXT.md` - approved
  wall-seam scope contract, planned command/status token, field set, and
  no-overclaiming boundary.
- `.planning/phases/63-wall-seam-fixture-corpus/63-CONTEXT.md` - fixture
  namespace, expected summary shape, fixture verifier, and Phase 65 handoff.
- `.planning/phases/64-rust-wall-seam-evidence-boundary/64-CONTEXT.md` -
  Rust parser/readiness boundary, summary helper, registry metadata, and
  Phase 65 publication ownership.

### Wall-seam source, fixture, and Rust boundary

- `packages/prusa-wall-seam-scope/wall-seam-scope.md` - reviewed source
  identity, source anchors, approved fields, and planned public command/status.
- `packages/prusa-wall-seam-scope/verify_prusa_wall_seam_scope.sh` - scope
  verifier and status-boundary checks.
- `packages/prusa-wall-seam-scope/verify_prusa_wall_seam_scope_test.sh` -
  scope mutation precedent for wall-seam status and claim drift.
- `packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/expected-wall-seam-summary.tsv`
  - checked-in summary artifact the public command validates through Rust.
- `packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/fixture-provenance.tsv`
  - source identity, source anchors, fixture identity, and update route.
- `packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/README.md`
  - fixture namespace documentation and no-overclaiming language.
- `packages/parity-fixtures/verify_prusa_wall_seam_fixture.sh` - fixture
  verifier enforcing exact rows, field order, status restraints, and forbidden
  claim text.
- `packages/parity-fixtures/verify_prusa_wall_seam_fixture_test.sh` - fixture
  mutation coverage for wall-seam drift.
- `packages/slic3r-rust/crates/slic3r_flavors/src/prusa_wall_seam.rs` -
  pure Rust wall-seam parser/readiness boundary and summary-line helper.
- `packages/slic3r-rust/crates/slic3r_flavors/tests/prusa_wall_seam.rs` -
  Rust fail-closed parser and public declaration coverage.
- `packages/slic3r-rust/crates/slic3r_flavors/BUILD.bazel` - crate-local
  Rust binary/test/clippy/rustfmt wiring.
- `packages/slic3r-rust/BUILD.bazel` - package aggregate verification target.

### Public parity precedent and docs to preserve

- `packages/parity/compare_prusaslicer_arc_fitting.sh` - closest public
  comparator pattern for checked-in feature summary evidence.
- `packages/parity/compare_prusaslicer_arc_fitting_test.sh` - public mutation
  test pattern for a feature-specific generated-output slice.
- `packages/parity/BUILD.bazel` - public parity command and sh_test wiring.
- `packages/parity/status.tsv` - checked-in public status rows, including
  `generated-outputs`, `fork.prusaslicer.gcode-output`, and
  `fork.prusaslicer.arc-fitting`.
- `packages/parity/README.md` - public parity package documentation that must
  list the new wall-seam command without overclaiming.
- `docs/port/package-map.md` - package ownership and generated-output evidence
  ladder documentation.
- `docs/port/parity-matrix.md` - public status wording and generated-output
  matrix boundary.
- `docs/port/migration-guidance.md` - maintainer-facing guidance for Prusa
  fixture, Rust, and parity evidence boundaries.
- `docs/port/README.md` - public port documentation index and current Prusa
  evidence list.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets

- `packages/parity/compare_prusaslicer_arc_fitting.sh`: public comparator
  pattern for validating checked-in feature summaries through a Rust summary
  binary and diffing generated summary lines.
- `packages/parity/compare_prusaslicer_arc_fitting_test.sh`: public mutation
  test pattern with temp copies and field-specific diagnostics.
- `packages/slic3r-rust/crates/slic3r_flavors/src/bin/prusa_arc_fitting_summary.rs`:
  simple Rust summary CLI pattern to copy for wall seam.
- `packages/slic3r-rust/crates/slic3r_flavors/src/prusa_wall_seam.rs`:
  already exposes the wall-seam parser and summary-line helper needed by the
  public command.
- `packages/parity-fixtures/verify_prusa_wall_seam_fixture.sh`: already
  knows the exact wall-seam rows, fixture identity, status restraints, and
  forbidden claim text.

### Established Patterns

- Public parity commands live in `packages/parity/BUILD.bazel` as
  `sh_binary` targets with explicit `data` dependencies and `args`.
- Public parity failure guards live beside their comparator scripts as
  `sh_test` targets.
- Feature-specific Prusa generated-output evidence slices publish separate
  status rows and do not widen the broader `generated-outputs` row.
- Rust summary binaries are tiny imperative shells over pure
  `slic3r_flavors` summary helpers.

### Integration Points

- Add the missing wall-seam summary binary in
  `packages/slic3r-rust/crates/slic3r_flavors/src/bin/` and wire it in
  `packages/slic3r-rust/crates/slic3r_flavors/BUILD.bazel`.
- Add the public comparator, mutation test, status row, and README text in
  `packages/parity/`.
- Update port docs under `docs/port/` so maintainer-facing docs match the
  new public status row and command.

</code_context>

<specifics>
## Specific Ideas

- Prefer `compare_prusaslicer_wall_seam.sh` and
  `compare_prusaslicer_wall_seam_test.sh` names for local consistency.
- Keep the public command output fact-oriented: source ref, fixture path,
  expected summary path, row count, seam transition observations, layer/travel
  context observations, coordinate bounds, extrusion/retraction observations,
  and `checked-in-wall-seam-summary-only`.
- Keep all wording tied to "checked-in wall-seam summary evidence" rather
  than "wall-seam behavior" or "wall-seam parity".
- Treat public docs updates as part of the publication surface, not optional
  follow-up, because SEAMEV-03 asks maintainers to inspect status, package
  docs, and port docs.

</specifics>

<deferred>
## Deferred Ideas

None - discussion stayed within phase scope.

</deferred>

***

*Phase: 65-executable-wall-seam-evidence*
*Context gathered: 2026-07-02*
