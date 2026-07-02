---
phase: 65-executable-wall-seam-evidence
plan: "02"
subsystem: parity-mutation-guards
tags: [bash, bazel, prusa, wall-seam, parity, mutation-testing]

requires:
  - phase: 65-01
    provides: Rust-backed public wall-seam comparator and Bazel parity command
provides:
  - Public fail-closed mutation guard script for D-06 wall-seam drift classes
  - Bazel `//packages/parity:prusaslicer_wall_seam_parity_failure_test` target
  - Temp-copy mutation coverage for value, row-order, and unsupported boundary drift
affects:
  - 65-executable-wall-seam-evidence
  - packages/parity

tech-stack:
  added: []
  patterns:
    - Bash temp-copy TSV mutation tests invoking the public Rust-backed comparator
    - Bazel `sh_test` wiring with explicit comparator, summary binary, expected summary, and provenance runfiles

key-files:
  created:
    - packages/parity/compare_prusaslicer_wall_seam_test.sh
  modified:
    - packages/parity/BUILD.bazel

key-decisions:
  - "Kept Bash limited to temp mutation orchestration and diagnostics; Rust remains the wall-seam validation authority."
  - "Copied every mutation case to a temp file named `expected-wall-seam-summary.tsv` so public diagnostics name the maintainer-facing artifact."
  - "Recorded the TDD RED check without committing a failing state because repo guidance requires passing verification before commits."

patterns-established:
  - "Public generated-output feature slices get a sibling mutation `sh_test` beside their public comparator."
  - "Mutation guards assert both artifact name and changed field or unsupported boundary phrase in stderr."

requirements-completed: [SEAMEV-02]
generated_by: gsd-execute-plan
lifecycle_mode: yolo
phase_lifecycle_id: 65-2026-07-02T21-16-54
generated_at: 2026-07-02T22:08:42Z

duration: 5 min
completed: 2026-07-02
---

# Phase 65 Plan 02: Fail-Closed Wall-Seam Mutation Guards Summary

**Public wall-seam mutation suite proving named checked-in summary drift fails through the Rust-backed comparator**

## Performance

- **Duration:** 5 min
- **Started:** 2026-07-02T22:03:44Z
- **Completed:** 2026-07-02T22:08:42Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- Added `compare_prusaslicer_wall_seam_test.sh`, covering all D-06 value drift fields plus row-order and unsupported boundary text mutations.
- Wired `//packages/parity:prusaslicer_wall_seam_parity_failure_test` with explicit Bazel runfiles.
- Verified the new mutation target, public wall-seam command, and existing Prusa G-code output and arc-fitting public command/test contracts.

## Task Commits

Each task was committed atomically:

1. **Task 1: Add wall-seam-specific temp-copy mutation cases** - `40995d62c` (`test`)
2. **Task 2: Wire the public mutation suite into Bazel and run regressions** - `47781d4c8` (`test`)

**Plan metadata:** committed after SUMMARY self-check.

## Files Created/Modified

- `packages/parity/compare_prusaslicer_wall_seam_test.sh` - Public mutation guard suite that mutates temp copies and invokes `compare_prusaslicer_wall_seam.sh`.
- `packages/parity/BUILD.bazel` - Added `prusaslicer_wall_seam_parity_failure_test`.

## Decisions Made

- Followed the existing arc-fitting public mutation-test pattern instead of introducing a shared Bash test framework.
- Kept every mutation assertion on the public comparator path so Bash does not duplicate Rust wall-seam validation logic.
- Kept verification scoped to the planned Bazel and shell surfaces plus repo-required Rust commit gates.

## Deviations from Plan

### Process Adjustments

**1. [AGENTS.md - Commit Policy] Skipped failing RED commit**
- **Found during:** Task 1
- **Issue:** The TDD flow asks for a failing RED commit, but repo guidance requires passing verification before commits.
- **Fix:** Ran the RED missing-file grep, then committed only the passing mutation guard script after shell checks, direct script execution, and Rust commit gates passed.
- **Files modified:** `packages/parity/compare_prusaslicer_wall_seam_test.sh`
- **Verification:** `rg -n 'seam_transition_observations' packages/parity/compare_prusaslicer_wall_seam_test.sh` failed before the file existed; later `bash -n`, `shfmt -l -d`, direct script execution, and Rust gates passed.
- **Committed in:** `40995d62c`

**Total deviations:** 1 process adjustment.
**Impact on plan:** No behavior or scope change. The mutation coverage matches the plan while commit timing follows repo policy.

## Issues Encountered

None.

## Verification

Passed:

- `rg -n 'seam_transition_observations' packages/parity/compare_prusaslicer_wall_seam_test.sh` failed before the test file existed.
- `bash -n packages/parity/compare_prusaslicer_wall_seam_test.sh`
- `shfmt -l -d packages/parity/compare_prusaslicer_wall_seam_test.sh`
- `bazel build //packages/slic3r-rust/crates/slic3r_flavors:prusa_wall_seam_summary`
- `packages/parity/compare_prusaslicer_wall_seam_test.sh`
- `rg -n 'assert_wall_seam_value_mutation_fails' packages/parity/compare_prusaslicer_wall_seam_test.sh`
- `rg -n 'seam_transition_observations|layer_context_observations|travel_context_observations|coordinate_bounds|extrusion_observations|retraction_observations|source_ref|fixture_id|fixture_path' packages/parity/compare_prusaslicer_wall_seam_test.sh`
- `rg -n 'assert_wall_seam_row_order_mutation_fails|retraction_observations' packages/parity/compare_prusaslicer_wall_seam_test.sh`
- `rg -n 'full generated-output parity verified' packages/parity/compare_prusaslicer_wall_seam_test.sh`
- `rg -n 'expected-wall-seam-summary.tsv' packages/parity/compare_prusaslicer_wall_seam_test.sh`
- `bazel query //packages/parity:prusaslicer_wall_seam_parity_failure_test`
- `bazel test --cache_test_results=no //packages/parity:prusaslicer_wall_seam_parity_failure_test --test_output=errors`
- `bazel run //packages/parity:prusaslicer_wall_seam_parity`
- `bazel run //packages/parity:prusaslicer_gcode_output_parity`
- `bazel run //packages/parity:prusaslicer_arc_fitting_parity`
- `bazel test //packages/parity:prusaslicer_gcode_output_parity_failure_test --test_output=errors`
- `bazel test //packages/parity:prusaslicer_arc_fitting_parity_failure_test --test_output=errors`
- `rg -n 'name = "prusaslicer_wall_seam_parity_failure_test"' packages/parity/BUILD.bazel`
- `rg -n 'compare_prusaslicer_wall_seam_test.sh' packages/parity/BUILD.bazel`
- `rg -n $'seam_transition_observations\\tseam transition observations\\tseam_markers:seam_start,seam_resume;transition_count:2' packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/expected-wall-seam-summary.tsv`
- `git diff --check -- packages/parity/compare_prusaslicer_wall_seam_test.sh packages/parity/BUILD.bazel`
- `rustup run 1.94.1 cargo fmt --manifest-path packages/slic3r-rust/Cargo.toml --all`
- `rustup run 1.94.1 cargo clippy --manifest-path packages/slic3r-rust/Cargo.toml --workspace --all-targets --all-features -- -D warnings`
- `rustup run 1.94.1 cargo build --manifest-path packages/slic3r-rust/Cargo.toml --workspace --all-targets --all-features`
- `rustup run 1.94.1 cargo test --manifest-path packages/slic3r-rust/Cargo.toml --workspace --all-features`

## Known Stubs

None - stub scan found no placeholder, TODO/FIXME, mock, or empty UI-flow values in the created or modified plan files.

## Threat Flags

None - the plan added only local temp-file mutation tests and Bazel test wiring over existing checked-in runfiles. No new network endpoint, auth path, source import, host upload, device behavior, or runtime discovery surface was introduced.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Ready for Plan 65-03 to publish the exact `fork.prusaslicer.wall-seam` status row and verifier guards on top of the passing public command and mutation suite.

## Self-Check: PASSED

- Found summary file at `.planning/phases/65-executable-wall-seam-evidence/65-02-SUMMARY.md`.
- Parsed summary frontmatter with `requirements-completed: [SEAMEV-02]`.
- Found created mutation test at `packages/parity/compare_prusaslicer_wall_seam_test.sh`.
- Found modified Bazel file at `packages/parity/BUILD.bazel`.
- Found task commit `40995d62c`.
- Found task commit `47781d4c8`.

*Phase: 65-executable-wall-seam-evidence*
*Completed: 2026-07-02*
