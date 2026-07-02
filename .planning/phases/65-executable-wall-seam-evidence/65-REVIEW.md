---
phase: 65-executable-wall-seam-evidence
reviewed: 2026-07-02T23:00:10Z
depth: standard
files_reviewed: 19
files_reviewed_list:
  - docs/port/README.md
  - docs/port/migration-guidance.md
  - docs/port/package-map.md
  - docs/port/parity-matrix.md
  - packages/parity-fixtures/README.md
  - packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/README.md
  - packages/parity-fixtures/verify_prusa_wall_seam_fixture.sh
  - packages/parity-fixtures/verify_prusa_wall_seam_fixture_test.sh
  - packages/parity/BUILD.bazel
  - packages/parity/README.md
  - packages/parity/compare_prusaslicer_wall_seam.sh
  - packages/parity/compare_prusaslicer_wall_seam_test.sh
  - packages/parity/status.tsv
  - packages/prusa-wall-seam-scope/README.md
  - packages/prusa-wall-seam-scope/verify_prusa_wall_seam_scope.sh
  - packages/prusa-wall-seam-scope/verify_prusa_wall_seam_scope_test.sh
  - packages/prusa-wall-seam-scope/wall-seam-scope.md
  - packages/slic3r-rust/crates/slic3r_flavors/BUILD.bazel
  - packages/slic3r-rust/crates/slic3r_flavors/src/bin/prusa_wall_seam_summary.rs
findings:
  critical: 0
  warning: 3
  info: 0
  total: 3
status: issues_found
---

# Phase 65: Code Review Report

**Reviewed:** 2026-07-02T23:00:10Z
**Depth:** standard
**Files Reviewed:** 19
**Status:** issues_found

## Summary

Reviewed the Phase 65 wall-seam docs, shell verifiers/tests, Bazel wiring, parity status row, and Rust summary CLI. The public Bazel target and targeted tests pass, but the no-overclaiming guards are incomplete for deferred wall-seam surfaces, and the new Rust CLI can panic before its error path on non-UTF-8 arguments.

Material guidance loaded: `AGENTS.md`, `AGENTS.bright-builds.md`, `standards-overrides.md`, `standards/index.md`, `standards/core/architecture.md`, `standards/core/code-shape.md`, `standards/core/testing.md`, `standards/core/verification.md`, and `standards/languages/rust.md`.

Verification run during review:

```bash
bazel test //packages/parity-fixtures:verify_prusa_wall_seam_fixture_test //packages/prusa-wall-seam-scope:verify //packages/prusa-wall-seam-scope:verify_prusa_wall_seam_scope_test //packages/parity:prusaslicer_wall_seam_parity_failure_test //packages/slic3r-rust/crates/slic3r_flavors:prusa_wall_seam_test //packages/slic3r-rust/crates/slic3r_flavors:rustfmt_check //packages/slic3r-rust/crates/slic3r_flavors:clippy
bazel run //packages/parity:prusaslicer_wall_seam_parity
```

Both commands completed successfully.

## Warnings

### WR-01: Fixture Overclaim Guard Misses Deferred Claims

**File:** `packages/parity-fixtures/verify_prusa_wall_seam_fixture.sh:250`
**Issue:** `reject_overclaiming_text` only rejects a curated set of exact `... verified` phrases. It does not reject important deferred claims such as `profile auto-update execution`, `full 3MF import/export`, `binary G-code`, `thumbnails`, `post-processing`, or `non-Prusa fork behavior`, and it misses alternate overclaim verbs such as `proves`. A temporary mutation that appended `Phase 63 proves profile auto-update execution.` to the wall-seam fixture README still passed `verify_prusa_wall_seam_fixture.sh`.
**Fix:** Use a single deferred-term list plus an overclaim-verb regex, and add mutation tests for every deferred term.

```bash
overclaim_terms='byte-for-byte G-code parity|full generated-output parity|broad generated-output verification|full wall-seam algorithm equivalence|wall-seam geometry equivalence|seam visibility|printability|firmware behavior|printer-runtime behavior|GUI behavior|support generation|arc fitting behavior|STEP import|full 3MF import/export|binary G-code|thumbnails|post-processing|host upload|network/device behavior|profile auto-update execution|fork release builds|Bambu Studio|OrcaSlicer|upstream source imports|release behavior|sync automation|non-Prusa fork behavior'
overclaim_verbs='proves|verified|verifies|validates?|confirms?|claims?|establishes?|demonstrates?|certifies?'
if grep -Eiq -- "(${overclaim_verbs}).*(${overclaim_terms})|(${overclaim_terms}).*(${overclaim_verbs})" "${checked_file}"; then
  error "${checked_label}: forbidden Prusa wall-seam fixture overclaim"
fi
```

### WR-02: Scope Overclaim Guard Omits Published Deferred Surfaces

**File:** `packages/prusa-wall-seam-scope/verify_prusa_wall_seam_scope.sh:347`
**Issue:** The scope verifier's regex protects some deferred wall-seam terms, but it omits several terms that the same contract publishes as deferred, including `profile auto-update execution`, `full 3MF import/export`, `binary G-code`, `thumbnails`, `post-processing`, and `fork release builds`. A temporary mutation that appended `Phase 62 proves profile auto-update execution.` to the scope README still passed `verify_prusa_wall_seam_scope.sh`.
**Fix:** Make `overclaim_terms` match the complete deferred-scope vocabulary and extend `verify_prusa_wall_seam_scope_test.sh` with at least one mutation per deferred surface.

```bash
overclaim_terms='byte-for-byte G-code parity|broad generated-output verification|full wall-seam algorithm or geometry equivalence|full wall-seam algorithm equivalence|wall-seam geometry equivalence|seam visibility|printability|firmware behavior|printer-runtime behavior|GUI behavior|support generation|STEP import|full 3MF import/export|binary G-code|thumbnails|post-processing|host upload|network/device behavior|profile auto-update execution|fork release builds|Bambu Studio|OrcaSlicer|upstream source imports|release behavior|sync automation|non-Prusa fork behavior'
```

### WR-03: Rust CLI Can Panic On Non-UTF-8 Arguments

**File:** `packages/slic3r-rust/crates/slic3r_flavors/src/bin/prusa_wall_seam_summary.rs:8`
**Issue:** The CLI uses `env::args()`, which can panic while iterating process arguments that are not valid Unicode. That bypasses the explicit `ExitCode::FAILURE` error path and produces a crash instead of the intended diagnostic. This is an edge case for Bazel runfiles, but it is still a direct CLI input path.
**Fix:** Use `env::args_os()` and pass `OsStr`/`Path` through the same error-returning flow.

```rust
use std::{env, ffi::OsStr, fs, path::Path, process::ExitCode};

fn main() -> ExitCode {
    let args: Vec<_> = env::args_os().collect();
    let result = match args.as_slice() {
        [_, expected_wall_seam_summary] => run_summary(expected_wall_seam_summary),
        _ => Err("expected expected-wall-seam-summary.tsv".to_owned()),
    };
    /* existing result handling */
}

fn run_summary(path_arg: &OsStr) -> Result<(), String> {
    let path = Path::new(path_arg);
    let input = fs::read_to_string(path)
        .map_err(|error| format!("failed to read {}: {error}", path.display()))?;
    /* existing summary handling */
    Ok(())
}
```

_Reviewed: 2026-07-02T23:00:10Z_
_Reviewer: the agent (gsd-code-reviewer)_
_Depth: standard_
