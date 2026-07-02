# Phase 65: Executable Wall-Seam Evidence - Research

**Researched:** 2026-07-02 [VERIFIED: system date]
**Domain:** Bazel public parity command, Rust wall-seam summary binary adapter, fail-closed Bash mutation guards, status/docs publication [VERIFIED: .planning/phases/65-executable-wall-seam-evidence/65-CONTEXT.md]
**Confidence:** HIGH [VERIFIED: local codebase inspection; VERIFIED: Bazel query audit; VERIFIED: environment availability audit]

<user_constraints>
## User Constraints (from CONTEXT.md)

The following locked decisions, discretion areas, and deferred ideas are copied from `.planning/phases/65-executable-wall-seam-evidence/65-CONTEXT.md`. [VERIFIED: .planning/phases/65-executable-wall-seam-evidence/65-CONTEXT.md]

### Locked Decisions

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

### Deferred Ideas (OUT OF SCOPE)

None - discussion stayed within phase scope.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| SEAMEV-01 | Maintainer can run public Prusa wall-seam parity evidence that validates the checked-in wall-seam summary artifact through the Rust boundary while preserving the existing public Prusa G-code output and arc-fitting command contracts. [VERIFIED: .planning/REQUIREMENTS.md] | Add `prusa_wall_seam_summary`, `compare_prusaslicer_wall_seam.sh`, and `//packages/parity:prusaslicer_wall_seam_parity` by mirroring the Phase 60 arc-fitting command pattern while leaving existing G-code and arc-fitting targets unchanged. [VERIFIED: packages/parity/compare_prusaslicer_arc_fitting.sh; VERIFIED: packages/parity/BUILD.bazel; VERIFIED: packages/slic3r-rust/crates/slic3r_flavors/src/prusa_wall_seam.rs] |
| SEAMEV-02 | Maintainer can see fail-closed mutation guards for wall seam drift classes such as seam-transition observation changes, layer or travel context changes, coordinate-bound changes, extrusion or retraction observation changes, source identity drift, fixture identity drift, row-order drift, and unsupported deferred-behavior claims. [VERIFIED: .planning/REQUIREMENTS.md] | Add a public mutation test beside the comparator that mutates temp copies and invokes the public Rust-backed comparator, covering all D-06 fields plus row-order and unsupported boundary text. [VERIFIED: packages/parity/compare_prusaslicer_arc_fitting_test.sh; VERIFIED: packages/slic3r-rust/crates/slic3r_flavors/tests/prusa_wall_seam.rs; VERIFIED: packages/parity-fixtures/verify_prusa_wall_seam_fixture_test.sh] |
| SEAMEV-03 | Maintainer can inspect parity status, package docs, and port docs that describe the exact narrow `fork.prusaslicer.wall-seam` evidence slice while keeping broad `generated-outputs` in progress, preserving existing Prusa row meanings, and keeping deferred generated-output/runtime/GUI/release/sync/non-Prusa surfaces explicit. [VERIFIED: .planning/REQUIREMENTS.md] | Publish exactly one `fork.prusaslicer.wall-seam` status row, update parity/fixture/scope/docs surfaces to published wording, and update exact verifier guards that currently reject premature wall-seam publication. [VERIFIED: packages/parity/status.tsv; VERIFIED: packages/parity-fixtures/verify_prusa_wall_seam_fixture.sh; VERIFIED: packages/prusa-wall-seam-scope/verify_prusa_wall_seam_scope.sh; VERIFIED: docs/port/parity-matrix.md] |
</phase_requirements>

## Summary

Phase 65 should be planned as a publication layer over completed wall-seam scope, fixture, and Rust boundary work: Phase 62 defined the closed scope contract, Phase 63 added the checked-in wall-seam fixture and expected summary, and Phase 64 exposed `parse_prusa_wall_seam_summary` plus `prusa_wall_seam_summary_lines`. [VERIFIED: .planning/ROADMAP.md; VERIFIED: packages/prusa-wall-seam-scope/wall-seam-scope.md; VERIFIED: packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/expected-wall-seam-summary.tsv; VERIFIED: packages/slic3r-rust/crates/slic3r_flavors/src/prusa_wall_seam.rs]

The public wall-seam Bazel target and Rust summary binary are absent today, matching the Phase 64 handoff. [VERIFIED: `bazel query //packages/parity:prusaslicer_wall_seam_parity`; VERIFIED: `bazel query //packages/slic3r-rust/crates/slic3r_flavors:prusa_wall_seam_summary`] The closest implementation precedent is Phase 60 arc-fitting: a tiny Rust summary binary, a thin Bash comparator in `packages/parity`, a sibling `sh_test` mutation suite, exact status-row publication, and package/port docs updates. [VERIFIED: packages/slic3r-rust/crates/slic3r_flavors/src/bin/prusa_arc_fitting_summary.rs; VERIFIED: packages/parity/compare_prusaslicer_arc_fitting.sh; VERIFIED: packages/parity/compare_prusaslicer_arc_fitting_test.sh; VERIFIED: .planning/milestones/v1.15-phases/60-executable-arc-fitting-evidence/60-01-PLAN.md]

**Primary recommendation:** Add a wall-seam-specific Rust summary binary and public comparator first, then add public mutation guards, then publish exactly one wall-seam status row and update package/fixture/scope/port docs with exact verifier guards. [VERIFIED: .planning/phases/65-executable-wall-seam-evidence/65-CONTEXT.md; VERIFIED: Phase 60 arc-fitting precedent inspection]

## Project Constraints (from AGENTS.md)

- The repo requires reading `AGENTS.md`, `AGENTS.bright-builds.md`, `standards-overrides.md` when present, and relevant standards pages before planning or implementation. [VERIFIED: AGENTS.md; VERIFIED: AGENTS.bright-builds.md; VERIFIED: standards/index.md]
- Repo-local summary frontmatter rules apply to later execution summaries: use `requirements-completed`, keep it synchronized, and do not run `mdformat` over phase `*-SUMMARY.md` files. [VERIFIED: AGENTS.md]
- Bright Builds verification guidance requires relevant repo-native verification before commit and prefers repo-owned verify/check entrypoints where available. [VERIFIED: standards/core/verification.md]
- Bright Builds testing guidance requires unit tests for pure/business logic, one concern per unit test, and clear Arrange/Act/Assert structure. [VERIFIED: standards/core/testing.md]
- Bright Builds code-shape guidance prefers early returns, guard constructs, `maybe` names for optional internal values, and not hiding substantial foreign-language logic in strings. [VERIFIED: standards/core/code-shape.md]
- Bright Builds Rust guidance prefers thin adapters around pure cores, `let...else` for guard extraction, `maybe_` naming for optional internals, and invariants encoded with types. [VERIFIED: standards/languages/rust.md]
- `standards-overrides.md` exists and contains only placeholder override rows, so no active local exception changes the applicable guidance. [VERIFIED: standards-overrides.md]
- No `.claude/skills/` or `.agents/skills/` project skill directories with `SKILL.md` files were found. [VERIFIED: `find .claude/skills .agents/skills -maxdepth 2 -name SKILL.md`]

## Standard Stack

### Core

| Library/Tool | Version | Purpose | Why Standard |
|--------------|---------|---------|--------------|
| Bazel/Bazelisk | Repo pin `8.6.0`; local `bazel` and `bazelisk` report `bazel 8.6.0`. [VERIFIED: .bazelversion; VERIFIED: `bazel --version`; VERIFIED: `bazelisk --version`] | Wire `rust_binary`, `sh_binary`, and `sh_test` targets for the public command and mutation guards. [VERIFIED: packages/parity/BUILD.bazel; VERIFIED: packages/slic3r-rust/crates/slic3r_flavors/BUILD.bazel] | Existing public Prusa commands and Rust summary binaries are Bazel targets. [VERIFIED: packages/parity/BUILD.bazel; VERIFIED: packages/slic3r-rust/crates/slic3r_flavors/BUILD.bazel] |
| Rust `slic3r_flavors` crate | Crate version `0.1.0`; Phase 65 requires Rust/Cargo `1.94.1`, which is installed through rustup. [VERIFIED: packages/slic3r-rust/crates/slic3r_flavors/Cargo.toml; VERIFIED: `rustup run 1.94.1 cargo --version`; VERIFIED: `rustup run 1.94.1 rustc --version`] | Own the typed wall-seam parser and summary-line helper. [VERIFIED: packages/slic3r-rust/crates/slic3r_flavors/src/prusa_wall_seam.rs; VERIFIED: packages/slic3r-rust/crates/slic3r_flavors/src/lib.rs] | Phase 64 already exposes the pure Rust boundary, so Phase 65 should adapt it instead of re-validating facts in Bash. [VERIFIED: .planning/phases/64-rust-wall-seam-evidence-boundary/64-VERIFICATION.md] |
| Bash | Local Bash `3.2.57(1)-release`. [VERIFIED: `bash --version`] | Orchestrate runfiles, temp mutation copies, `diff`, field assertions, and maintainer-facing output. [VERIFIED: packages/parity/compare_prusaslicer_arc_fitting.sh; VERIFIED: packages/parity/compare_prusaslicer_arc_fitting_test.sh] | Existing parity scripts use `#!/usr/bin/env bash` and `set -euo pipefail`. [VERIFIED: packages/parity/compare_prusaslicer_arc_fitting.sh] |
| macOS text tools | `awk`, `diff`, and `shasum` are available; `shasum` reports `6.02`, and `diff` reports Apple diff. [VERIFIED: `command -v awk`; VERIFIED: `diff --version`; VERIFIED: `shasum -v`] | Support deterministic TSV checks, diffs, and fixture integrity verifiers. [VERIFIED: packages/parity-fixtures/verify_prusa_wall_seam_fixture.sh] | Existing verifiers and comparators already depend on these tools. [VERIFIED: packages/parity-fixtures/verify_prusa_wall_seam_fixture.sh; VERIFIED: packages/parity/compare_prusaslicer_arc_fitting.sh] |

### Supporting

| Library/Tool | Version | Purpose | When to Use |
|--------------|---------|---------|-------------|
| `shfmt` | `3.12.0` is installed. [VERIFIED: `shfmt --version`] | Check shell script formatting in changed Bash files. [VERIFIED: standards/core/verification.md] | Use `shfmt -l -d` for new/changed shell scripts if the plan includes formatter checks. [VERIFIED: standards/core/verification.md] |
| `mdformat` | `1.0.0` is installed. [VERIFIED: `mdformat --version`] | Check Markdown docs when appropriate. [VERIFIED: standards/core/verification.md] | Use on non-summary docs only; do not run it over phase `*-SUMMARY.md` files. [VERIFIED: AGENTS.md] |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| New `prusa_wall_seam_summary` Rust binary [RECOMMENDED] | Extend `prusa_gcode_output_summary` or `prusa_arc_fitting_summary`. [VERIFIED: packages/slic3r-rust/crates/slic3r_flavors/src/bin/prusa_arc_fitting_summary.rs; VERIFIED: packages/slic3r-rust/crates/slic3r_flavors/src/bin/prusa_gcode_output_summary.rs] | Locked decision D-01 requires a wall-seam binary equivalent to the arc-fitting summary binary, and D-04 forbids generic comparator consolidation in this phase. [VERIFIED: .planning/phases/65-executable-wall-seam-evidence/65-CONTEXT.md] |
| Rust-backed fact validation [RECOMMENDED] | Validate all TSV facts directly in Bash. [VERIFIED: packages/parity-fixtures/verify_prusa_wall_seam_fixture.sh] | The public command must validate through `slic3r_flavors::prusa_wall_seam_summary_lines`; Bash should orchestrate, diff, and report. [VERIFIED: .planning/phases/65-executable-wall-seam-evidence/65-CONTEXT.md; VERIFIED: packages/slic3r-rust/crates/slic3r_flavors/src/prusa_wall_seam.rs] |
| One narrow status row [RECOMMENDED] | Widen `generated-outputs`, `fork.prusaslicer.gcode-output`, or `fork.prusaslicer.arc-fitting`. [VERIFIED: packages/parity/status.tsv] | Locked decisions D-09 and D-10 require a separate `fork.prusaslicer.wall-seam` row and preserving sibling row meanings. [VERIFIED: .planning/phases/65-executable-wall-seam-evidence/65-CONTEXT.md] |

**Installation:** No new dependency installation is recommended for Phase 65; use the existing Bazel, Rust, Bash, text-tool, fixture, and docs surfaces. [VERIFIED: environment availability audit; VERIFIED: codebase inspection]

**Version verification:** `npm view` is not applicable because Phase 65 should add no npm packages or external libraries. [VERIFIED: package inspection; VERIFIED: .planning/phases/65-executable-wall-seam-evidence/65-CONTEXT.md]

## Architecture Patterns

### Recommended Project Structure

```text
packages/
├── parity/
│   ├── compare_prusaslicer_wall_seam.sh        # new public wall-seam comparator
│   ├── compare_prusaslicer_wall_seam_test.sh   # new public mutation guard suite
│   ├── BUILD.bazel                             # new sh_binary and sh_test wiring
│   ├── README.md                               # public command/status docs
│   └── status.tsv                              # exactly one new wall-seam row
├── parity-fixtures/
│   ├── README.md                               # fixture package docs move from planned to published wording
│   ├── verify_prusa_wall_seam_fixture.sh       # exact status/docs guard update
│   └── forks/prusaslicer/prusaslicer.wall-seam/
│       ├── README.md                           # fixture namespace docs move from planned to published wording
│       └── expected-wall-seam-summary.tsv      # existing checked-in artifact
├── prusa-wall-seam-scope/
│   ├── README.md
│   ├── wall-seam-scope.md                      # scope docs move from planned to published wording
│   └── verify_prusa_wall_seam_scope.sh         # exact status/docs guard update
└── slic3r-rust/crates/slic3r_flavors/
    ├── src/bin/prusa_wall_seam_summary.rs      # new tiny Rust adapter
    ├── src/prusa_wall_seam.rs                  # existing pure parser and summary helper
    └── BUILD.bazel                             # rust_binary plus clippy/rustfmt wiring
docs/port/
├── README.md
├── package-map.md
├── parity-matrix.md
└── migration-guidance.md
```

This structure follows existing arc-fitting ownership and the Phase 65 six-plan roadmap breakdown. [VERIFIED: .planning/ROADMAP.md; VERIFIED: .planning/milestones/v1.15-phases/60-executable-arc-fitting-evidence/60-01-PLAN.md; VERIFIED: .planning/milestones/v1.15-phases/60-executable-arc-fitting-evidence/60-06-PLAN.md]

### Pattern 1: Rust Functional Core, Thin Public Adapters

**What:** Keep wall-seam parsing and fact construction in `slic3r_flavors::prusa_wall_seam_summary_lines`, add a tiny Rust binary that reads one explicit local path, and keep Bash limited to runfiles, diffs, assertions, temp files, and output. [VERIFIED: packages/slic3r-rust/crates/slic3r_flavors/src/prusa_wall_seam.rs; VERIFIED: packages/slic3r-rust/crates/slic3r_flavors/src/bin/prusa_arc_fitting_summary.rs; VERIFIED: standards/core/architecture.md]

**When to use:** Use for SEAMEV-01 because public evidence must validate the checked-in wall-seam summary through the Rust boundary. [VERIFIED: .planning/REQUIREMENTS.md]

**Example:**

```rust
#![forbid(unsafe_code)]

use std::{env, fs, path::Path, process::ExitCode};

use slic3r_flavors::prusa_wall_seam_summary_lines;

fn main() -> ExitCode {
    let args: Vec<_> = env::args().collect();
    let result = match args.as_slice() {
        [_, expected_wall_seam_summary] => run_summary(Path::new(expected_wall_seam_summary)),
        _ => Err("expected expected-wall-seam-summary.tsv".to_owned()),
    };

    match result {
        Ok(()) => ExitCode::SUCCESS,
        Err(error) => {
            eprintln!("error: {error}");
            ExitCode::FAILURE
        }
    }
}

fn run_summary(path: &Path) -> Result<(), String> {
    let input = fs::read_to_string(path)
        .map_err(|error| format!("failed to read {}: {error}", path.display()))?;
    let lines = prusa_wall_seam_summary_lines(&input).map_err(|error| {
        format!("failed to summarize wall-seam {}: {error:?}", path.display())
    })?;

    for line in lines {
        println!("{line}");
    }

    Ok(())
}
```

This example is adapted from the existing arc-fitting summary binary and swaps in the existing wall-seam summary helper. [VERIFIED: packages/slic3r-rust/crates/slic3r_flavors/src/bin/prusa_arc_fitting_summary.rs; VERIFIED: packages/slic3r-rust/crates/slic3r_flavors/src/prusa_wall_seam.rs]

### Pattern 2: Public Comparator Diffs Rust Summary Lines

**What:** Run the Rust summary binary against the trusted checked-in summary and the expected artifact, diff the generated summary lines, then assert exact wall-seam facts. [VERIFIED: packages/parity/compare_prusaslicer_arc_fitting.sh]

**When to use:** Use for the public `//packages/parity:prusaslicer_wall_seam_parity` target and for the mutation suite's failure authority. [VERIFIED: .planning/phases/65-executable-wall-seam-evidence/65-CONTEXT.md]

**Exact public facts to assert:** `wall_seam_summary_path`, `wall_seam_row_count=12`, `source_ref`, `inventory_source_paths`, `source_anchor`, `fixture_id`, `fixture_path`, `seam_transition_observations`, `layer_context_observations`, `travel_context_observations`, `coordinate_bounds`, `extrusion_observations`, `retraction_observations`, and `evidence_boundary=checked-in-wall-seam-summary-only`. [VERIFIED: packages/slic3r-rust/crates/slic3r_flavors/tests/prusa_wall_seam.rs]

### Pattern 3: Publication Verifiers Flip From Absence To Exact Presence

**What:** Existing wall-seam fixture and scope verifiers currently reject any `fork.prusaslicer.wall-seam` status row; Phase 65 must update them to require exactly one verified row with evidence `//packages/parity:prusaslicer_wall_seam_parity`. [VERIFIED: packages/parity-fixtures/verify_prusa_wall_seam_fixture.sh; VERIFIED: packages/prusa-wall-seam-scope/verify_prusa_wall_seam_scope.sh; VERIFIED: packages/parity/status.tsv]

**When to use:** Use after the public command and mutation suite pass, so status/docs publication is gated by executable evidence. [VERIFIED: .planning/phases/65-executable-wall-seam-evidence/65-CONTEXT.md; VERIFIED: .planning/milestones/v1.15-phases/60-executable-arc-fitting-evidence/60-03-PLAN.md]

### Anti-Patterns to Avoid

- **Generic comparator refactor:** Do not consolidate G-code, arc-fitting, and wall-seam public comparators in Phase 65. [VERIFIED: .planning/phases/65-executable-wall-seam-evidence/65-CONTEXT.md]
- **Bash as fact authority:** Do not reimplement wall-seam parser validity in Bash; use Rust as the parse/fail authority. [VERIFIED: packages/slic3r-rust/crates/slic3r_flavors/src/prusa_wall_seam.rs; VERIFIED: .planning/phases/65-executable-wall-seam-evidence/65-CONTEXT.md]
- **Status widening:** Do not add wall-seam claims to `generated-outputs`, `fork.prusaslicer.gcode-output`, or `fork.prusaslicer.arc-fitting`. [VERIFIED: .planning/phases/65-executable-wall-seam-evidence/65-CONTEXT.md; VERIFIED: packages/parity/status.tsv]
- **Live generator/runtime proof:** Do not run PrusaSlicer generation, import upstream source, touch network/device behavior, or claim printability/runtime/GUI behavior. [VERIFIED: .planning/REQUIREMENTS.md; VERIFIED: packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/README.md]

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Wall-seam TSV parse/fact validation | Bash parser for header, row order, exact values, and unsupported claims. [VERIFIED: packages/parity-fixtures/verify_prusa_wall_seam_fixture.sh] | `slic3r_flavors::parse_prusa_wall_seam_summary` and `prusa_wall_seam_summary_lines`. [VERIFIED: packages/slic3r-rust/crates/slic3r_flavors/src/prusa_wall_seam.rs] | Rust already encodes the 12-row closed contract and fail-closed parse errors. [VERIFIED: packages/slic3r-rust/crates/slic3r_flavors/tests/prusa_wall_seam.rs] |
| Public mutation failure authority | Independent Bash-only checks that pass/fail without invoking the public comparator. [VERIFIED: packages/parity/compare_prusaslicer_arc_fitting_test.sh] | Temp-copy mutations that call `compare_prusaslicer_wall_seam.sh`. [VERIFIED: packages/parity/compare_prusaslicer_arc_fitting_test.sh] | The public command path is what maintainers will run, so mutation tests must prove that path fails closed. [VERIFIED: .planning/REQUIREMENTS.md] |
| Generated-output graduation | A broad `generated-outputs` verifier or status promotion. [VERIFIED: packages/parity/status.tsv] | One narrow `fork.prusaslicer.wall-seam` row plus existing generated-output `in progress` row. [VERIFIED: .planning/phases/65-executable-wall-seam-evidence/65-CONTEXT.md] | The milestone explicitly defers broad generated-output verification and byte-for-byte parity. [VERIFIED: .planning/REQUIREMENTS.md] |
| External source/runtime proof | Git clone, upstream fetch, slicer runtime execution, host upload, or printer behavior checks. [VERIFIED: packages/parity-fixtures/verify_prusa_wall_seam_fixture.sh] | Checked-in fixture, expected summary, Rust parser, and public comparator. [VERIFIED: packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/README.md; VERIFIED: packages/slic3r-rust/crates/slic3r_flavors/src/prusa_wall_seam.rs] | Phase 65 proves a checked-in summary evidence slice only. [VERIFIED: .planning/ROADMAP.md] |

**Key insight:** The hard part is not parsing text; it is preserving the exact public evidence boundary while flipping earlier "not yet published" guards to exact published-state guards. [VERIFIED: packages/parity-fixtures/verify_prusa_wall_seam_fixture.sh; VERIFIED: packages/prusa-wall-seam-scope/verify_prusa_wall_seam_scope.sh; VERIFIED: .planning/milestones/v1.15-phases/60-executable-arc-fitting-evidence/60-03-PLAN.md]

## Common Pitfalls

### Pitfall 1: Publishing Status Before Executable Proof

**What goes wrong:** A `fork.prusaslicer.wall-seam` row appears before the public command and mutation test pass. [VERIFIED: packages/parity-fixtures/verify_prusa_wall_seam_fixture_test.sh; VERIFIED: packages/prusa-wall-seam-scope/verify_prusa_wall_seam_scope_test.sh]

**Why it happens:** Phase 62 and Phase 63 verifiers intentionally treated wall-seam public status as premature. [VERIFIED: packages/parity-fixtures/verify_prusa_wall_seam_fixture.sh; VERIFIED: packages/prusa-wall-seam-scope/verify_prusa_wall_seam_scope.sh]

**How to avoid:** Sequence plans as command, mutation test, status/verifier update, package/fixture docs, scope docs, port docs. [VERIFIED: .planning/ROADMAP.md; VERIFIED: .planning/milestones/v1.15-phases/60-executable-arc-fitting-evidence/60-01-PLAN.md]

**Warning signs:** `fork.prusaslicer.wall-seam` exists in `status.tsv` while `bazel query //packages/parity:prusaslicer_wall_seam_parity` still fails. [VERIFIED: current Bazel query audit; VERIFIED: packages/parity/status.tsv]

### Pitfall 2: Missing A Wall-Seam-Specific Mutation Class

**What goes wrong:** The public mutation test covers command wiring but misses one of D-06: seam transition, layer context, travel context, coordinate bounds, extrusion, retraction, source identity, fixture identity/path, row order, or unsupported claim text. [VERIFIED: .planning/phases/65-executable-wall-seam-evidence/65-CONTEXT.md]

**Why it happens:** Arc-fitting has different fields, and a direct copy needs wall-seam-specific replacements. [VERIFIED: packages/parity/compare_prusaslicer_arc_fitting_test.sh; VERIFIED: packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/expected-wall-seam-summary.tsv]

**How to avoid:** Build the mutation list from the 12 wall-seam summary fields and the D-06 drift classes. [VERIFIED: packages/slic3r-rust/crates/slic3r_flavors/tests/prusa_wall_seam.rs; VERIFIED: .planning/phases/65-executable-wall-seam-evidence/65-CONTEXT.md]

**Warning signs:** `rg` does not find `retraction_observations`, `travel_context_observations`, or `row-order` mutation logic in the new public test. [VERIFIED: packages/parity-fixtures/verify_prusa_wall_seam_fixture_test.sh]

### Pitfall 3: Stale "Planned" Wording After Publication

**What goes wrong:** Package, fixture, scope, or port docs still say Phase 65 "owns" or "plans" the command/status row after publication. [VERIFIED: packages/prusa-wall-seam-scope/wall-seam-scope.md; VERIFIED: packages/parity-fixtures/README.md; VERIFIED: docs/port/README.md]

**Why it happens:** Earlier phases intentionally documented the command/status as future work. [VERIFIED: .planning/phases/64-rust-wall-seam-evidence-boundary/64-VERIFICATION.md]

**How to avoid:** Update exact verifier checks to require published wording and add stale-wording mutation cases, following Phase 60 plans 04 and 05. [VERIFIED: .planning/milestones/v1.15-phases/60-executable-arc-fitting-evidence/60-04-PLAN.md; VERIFIED: .planning/milestones/v1.15-phases/60-executable-arc-fitting-evidence/60-05-PLAN.md]

**Warning signs:** Touched docs still contain `planned public evidence command`, `planned status token`, or `Phase 65 owns` in a current-state sentence. [VERIFIED: packages/prusa-wall-seam-scope/wall-seam-scope.md; VERIFIED: packages/parity-fixtures/README.md]

### Pitfall 4: Overclaiming The Evidence

**What goes wrong:** Public output/docs describe wall-seam parity, algorithm equivalence, geometry equivalence, seam visibility, printability, firmware behavior, printer-runtime behavior, GUI behavior, release behavior, sync behavior, or non-Prusa behavior. [VERIFIED: .planning/REQUIREMENTS.md]

**Why it happens:** The command name uses the existing `*_parity` target convention, but the evidence slice is checked-in summary evidence only. [VERIFIED: packages/parity/BUILD.bazel; VERIFIED: .planning/phases/65-executable-wall-seam-evidence/65-CONTEXT.md]

**How to avoid:** Use "checked-in wall-seam summary evidence slice" wording and keep the full deferral list near every public status/docs update. [VERIFIED: packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/README.md; VERIFIED: docs/port/parity-matrix.md]

**Warning signs:** New public text contains "wall-seam behavior verified" or "geometry/printability/runtime" without "deferred" or "does not prove". [VERIFIED: packages/parity-fixtures/verify_prusa_wall_seam_fixture.sh; VERIFIED: packages/prusa-wall-seam-scope/verify_prusa_wall_seam_scope.sh]

## Code Examples

### Bazel Wiring For The New Rust Binary

```python
rust_binary(
    name = "prusa_wall_seam_summary",
    srcs = ["src/bin/prusa_wall_seam_summary.rs"],
    crate_root = "src/bin/prusa_wall_seam_summary.rs",
    deps = [":slic3r_flavors"],
    edition = "2024",
)
```

Add `:prusa_wall_seam_summary` to the crate `rust_clippy` deps and `rustfmt_test` targets, mirroring the existing `prusa_arc_fitting_summary` wiring. [VERIFIED: packages/slic3r-rust/crates/slic3r_flavors/BUILD.bazel]

### Public Comparator Fact Assertions

```bash
assert_field "wall_seam_summary_path" \
	"packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/expected-wall-seam-summary.tsv" \
	"${actual_summary}"
assert_field "wall_seam_row_count" "12" "${actual_summary}"
assert_field "seam_transition_observations" \
	"seam_markers:seam_start,seam_resume;transition_count:2" \
	"${actual_summary}"
assert_field "evidence_boundary" \
	"checked-in-wall-seam-summary-only" \
	"${actual_summary}"
```

This shell pattern is adapted from the existing arc-fitting comparator, with wall-seam keys and values coming from the Rust summary helper tests. [VERIFIED: packages/parity/compare_prusaslicer_arc_fitting.sh; VERIFIED: packages/slic3r-rust/crates/slic3r_flavors/tests/prusa_wall_seam.rs]

### Public Mutation Test Shape

```bash
assert_wall_seam_value_mutation_fails \
	"travel_context_observations" \
	"travel_moves:2;travel_from:12.500,8.000;travel_to:14.000,8.750"
assert_wall_seam_value_mutation_fails \
	"retraction_observations" \
	"e_marker_values:0.28000,0.20000;retraction_marker_observed:true"
assert_wall_seam_row_order_mutation_fails \
	"retraction_observations" \
	"extrusion_observations"
```

The mutation test should copy `expected-wall-seam-summary.tsv` to temp paths, preserve the basename for diagnostics, and invoke the public comparator for each case. [VERIFIED: packages/parity/compare_prusaslicer_arc_fitting_test.sh; VERIFIED: packages/parity-fixtures/verify_prusa_wall_seam_fixture_test.sh]

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Phase 62/63/64 treat wall-seam public command/status/docs as planned or absent. [VERIFIED: packages/prusa-wall-seam-scope/wall-seam-scope.md; VERIFIED: packages/parity-fixtures/verify_prusa_wall_seam_fixture.sh; VERIFIED: .planning/phases/64-rust-wall-seam-evidence-boundary/64-VERIFICATION.md] | Phase 65 publishes the command, mutation guards, exact status row, and public docs. [VERIFIED: .planning/ROADMAP.md] | Phase 65. [VERIFIED: .planning/ROADMAP.md] | Verifier contracts must move from absence checks to exact-published checks. [VERIFIED: packages/parity-fixtures/verify_prusa_wall_seam_fixture.sh; VERIFIED: packages/prusa-wall-seam-scope/verify_prusa_wall_seam_scope.sh] |
| G-code output and arc-fitting are the only public Prusa generated-output evidence slices in docs/status. [VERIFIED: packages/parity/status.tsv; VERIFIED: docs/port/parity-matrix.md] | Wall-seam becomes a third separate narrow Prusa generated-output evidence slice. [VERIFIED: .planning/REQUIREMENTS.md; VERIFIED: .planning/phases/65-executable-wall-seam-evidence/65-CONTEXT.md] | Phase 65. [VERIFIED: .planning/ROADMAP.md] | Docs must list wall-seam beside arc-fitting without graduating broad `generated-outputs`. [VERIFIED: docs/port/README.md; VERIFIED: docs/port/parity-matrix.md] |

**Deprecated/outdated:** Treating `fork.prusaslicer.wall-seam` as forbidden in `packages/parity/status.tsv` becomes outdated once the Phase 65 command and mutation guards pass. [VERIFIED: packages/parity-fixtures/verify_prusa_wall_seam_fixture.sh; VERIFIED: packages/prusa-wall-seam-scope/verify_prusa_wall_seam_scope.sh; VERIFIED: .planning/ROADMAP.md]

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | The research freshness window is valid until 2026-08-01 for local codebase patterns, or earlier if Phase 65 code changes before planning. [ASSUMED] | Metadata | If wrong, rerun the target-absence, status/docs, and environment checks before planning. |

## Open Questions

1. **None for planning.** The phase has locked implementation decisions, the public targets are absent, required lower-layer helpers exist, and the docs/status boundaries are identifiable. [VERIFIED: .planning/phases/65-executable-wall-seam-evidence/65-CONTEXT.md; VERIFIED: current Bazel query audit; VERIFIED: codebase inspection]

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|-------------|-----------|---------|----------|
| Bazel/Bazelisk | Bazel target wiring and verification. [VERIFIED: packages/parity/BUILD.bazel] | yes [VERIFIED: `bazel --version`; VERIFIED: `bazelisk --version`] | 8.6.0 [VERIFIED: .bazelversion] | None needed. [VERIFIED: environment availability audit] |
| rustup + Rust/Cargo 1.94.1 | Required Cargo suite when Rust binary or crate wiring changes. [VERIFIED: .planning/phases/65-executable-wall-seam-evidence/65-CONTEXT.md] | yes [VERIFIED: `rustup run 1.94.1 cargo --version`; VERIFIED: `rustup run 1.94.1 rustc --version`] | cargo 1.94.1, rustc 1.94.1 [VERIFIED: environment availability audit] | None needed. [VERIFIED: environment availability audit] |
| Bash | New comparator and mutation scripts. [VERIFIED: packages/parity/compare_prusaslicer_arc_fitting.sh] | yes [VERIFIED: `bash --version`] | 3.2.57 [VERIFIED: `bash --version`] | None needed. [VERIFIED: environment availability audit] |
| `awk`, `diff`, `shasum` | TSV diagnostics, diffs, checksum/verifier patterns. [VERIFIED: packages/parity-fixtures/verify_prusa_wall_seam_fixture.sh] | yes [VERIFIED: `command -v awk`; VERIFIED: `command -v diff`; VERIFIED: `command -v shasum`] | awk version unavailable via `-W`; Apple diff; shasum 6.02. [VERIFIED: environment availability audit] | None needed. [VERIFIED: environment availability audit] |
| `shfmt` | Optional shell format check. [VERIFIED: standards/core/verification.md] | yes [VERIFIED: `shfmt --version`] | 3.12.0 [VERIFIED: `shfmt --version`] | Use `bash -n` and Bazel tests if formatter is skipped. [VERIFIED: standards/core/verification.md] |
| `mdformat` | Optional docs format check for non-summary docs. [VERIFIED: standards/core/verification.md] | yes [VERIFIED: `mdformat --version`] | 1.0.0 [VERIFIED: `mdformat --version`] | Use `git diff --check` if formatter is intentionally skipped. [VERIFIED: standards/core/verification.md; VERIFIED: AGENTS.md] |

**Missing dependencies with no fallback:** None found. [VERIFIED: environment availability audit]

**Missing dependencies with fallback:** None found. [VERIFIED: environment availability audit]

## Focused Verification Strategy

Run narrow checks in this order because the phase decisions require command evidence before publication and aggregate Rust verification after wiring changes. [VERIFIED: .planning/phases/65-executable-wall-seam-evidence/65-CONTEXT.md]

1. `bazel query //packages/slic3r-rust/crates/slic3r_flavors:prusa_wall_seam_summary` and `bazel build //packages/slic3r-rust/crates/slic3r_flavors:prusa_wall_seam_summary` after adding the Rust binary. [VERIFIED: current target absence audit; VERIFIED: packages/slic3r-rust/crates/slic3r_flavors/BUILD.bazel]
2. `bazel run //packages/parity:prusaslicer_wall_seam_parity` after adding the public comparator. [VERIFIED: current target absence audit; VERIFIED: .planning/phases/65-executable-wall-seam-evidence/65-CONTEXT.md]
3. `bazel test --cache_test_results=no //packages/parity:prusaslicer_wall_seam_parity_failure_test --test_output=errors` after adding public mutations. [VERIFIED: packages/parity/compare_prusaslicer_arc_fitting_test.sh]
4. `bazel run //packages/parity-fixtures:verify_prusa_wall_seam_fixture` and `bazel test //packages/parity-fixtures:verify_prusa_wall_seam_fixture_test --test_output=errors` after fixture/docs/status guard updates. [VERIFIED: packages/parity-fixtures/BUILD.bazel]
5. `bazel run //packages/prusa-wall-seam-scope:verify` and `bazel test //packages/prusa-wall-seam-scope:verify_prusa_wall_seam_scope_test --test_output=errors` after scope docs/status guard updates. [VERIFIED: packages/prusa-wall-seam-scope/BUILD.bazel]
6. `rustup run 1.94.1 cargo test --manifest-path packages/slic3r-rust/Cargo.toml --all-features` when adding the summary binary or changing crate wiring. [VERIFIED: .planning/phases/65-executable-wall-seam-evidence/65-CONTEXT.md; VERIFIED: environment availability audit]
7. `bazel test //packages/slic3r-rust:verify --test_output=errors` when Rust/Bazel wiring changes. [VERIFIED: packages/slic3r-rust/BUILD.bazel]
8. Regression commands `bazel run //packages/parity:prusaslicer_gcode_output_parity` and `bazel run //packages/parity:prusaslicer_arc_fitting_parity` should pass after status/docs publication because their public contracts must be preserved. [VERIFIED: .planning/phases/65-executable-wall-seam-evidence/65-CONTEXT.md; VERIFIED: packages/parity/BUILD.bazel]
9. Use `git diff --check -- <changed files>` for final whitespace verification. [VERIFIED: standards/core/verification.md]

## Security Domain

Security enforcement is enabled because `.planning/config.json` does not set `security_enforcement` to `false`. [VERIFIED: .planning/config.json]

OWASP ASVS is currently published as version 5.0.0 dated May 2025, and the GSD ASVS table below uses the workflow's V2/V3/V4/V5/V6 labels as a planning taxonomy rather than claiming those are the latest ASVS 5 chapter names. [CITED: https://github.com/OWASP/ASVS]

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no [VERIFIED: .planning/phases/65-executable-wall-seam-evidence/65-CONTEXT.md] | No auth/session/identity feature is introduced; keep command local-only. [VERIFIED: packages/parity/compare_prusaslicer_arc_fitting.sh] |
| V3 Session Management | no [VERIFIED: .planning/phases/65-executable-wall-seam-evidence/65-CONTEXT.md] | No browser or session state exists in this phase. [VERIFIED: codebase inspection] |
| V4 Access Control | no [VERIFIED: .planning/phases/65-executable-wall-seam-evidence/65-CONTEXT.md] | No multi-user access-control surface is introduced; restrict inputs to explicit local runfile paths. [VERIFIED: packages/parity/compare_prusaslicer_arc_fitting.sh] |
| V5 Input Validation / File Handling | yes [VERIFIED: packages/slic3r-rust/crates/slic3r_flavors/src/prusa_wall_seam.rs] | Parse checked-in TSV through Rust typed validation; Bash should assert files/executability and never trust mutated files without invoking Rust. [VERIFIED: packages/slic3r-rust/crates/slic3r_flavors/src/prusa_wall_seam.rs; VERIFIED: packages/parity/compare_prusaslicer_arc_fitting.sh] |
| V6 Cryptography | limited [VERIFIED: packages/parity-fixtures/verify_prusa_wall_seam_fixture.sh] | Do not add crypto; existing fixture checksum verification uses `shasum -a 256` only for integrity of checked-in bytes. [VERIFIED: packages/parity-fixtures/verify_prusa_wall_seam_fixture.sh] |

### Known Threat Patterns for Phase 65 Stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Mutated wall-seam TSV passes public evidence. [VERIFIED: .planning/REQUIREMENTS.md] | Tampering | Public mutation suite must mutate temp copies and assert the public comparator/Rust path fails. [VERIFIED: packages/parity/compare_prusaslicer_arc_fitting_test.sh] |
| Public status row overclaims broad generated-output or runtime behavior. [VERIFIED: .planning/phases/65-executable-wall-seam-evidence/65-CONTEXT.md] | Spoofing / Repudiation | Exact status-row verifier checks and stale/overclaim text rejection in fixture/scope/doc guards. [VERIFIED: packages/parity-fixtures/verify_prusa_wall_seam_fixture.sh; VERIFIED: packages/prusa-wall-seam-scope/verify_prusa_wall_seam_scope.sh] |
| Shell command accidentally performs external behavior. [VERIFIED: packages/parity-fixtures/verify_prusa_wall_seam_fixture.sh] | Information Disclosure / Elevation of Privilege | Keep scripts local-file-only, avoid Git/network/runtime discovery, and preserve forbidden-behavior self-scan patterns where verifiers already use them. [VERIFIED: packages/parity-fixtures/verify_prusa_wall_seam_fixture.sh] |

## Sources

### Primary (HIGH confidence)

- `.planning/phases/65-executable-wall-seam-evidence/65-CONTEXT.md` - locked Phase 65 decisions, discretion, deferrals, command/status/doc scope. [VERIFIED: local file read]
- `.planning/REQUIREMENTS.md` - SEAMEV-01, SEAMEV-02, SEAMEV-03 and out-of-scope generated-output/runtime behavior. [VERIFIED: local file read]
- `.planning/ROADMAP.md` - Phase 65 goal, six planned plans, success criteria, sequencing. [VERIFIED: local file read]
- `.planning/STATE.md` and `.planning/PROJECT.md` - current milestone state and prior wall-seam/arc-fitting history. [VERIFIED: local file read]
- `packages/parity/compare_prusaslicer_arc_fitting.sh`, `compare_prusaslicer_arc_fitting_test.sh`, `BUILD.bazel`, `status.tsv`, `README.md` - public command precedent and current status/docs. [VERIFIED: local file read]
- `packages/slic3r-rust/crates/slic3r_flavors/src/prusa_wall_seam.rs`, `tests/prusa_wall_seam.rs`, `BUILD.bazel`, `src/lib.rs`, `src/registry.rs` - wall-seam Rust boundary and missing binary wiring point. [VERIFIED: local file read]
- `packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/*`, `verify_prusa_wall_seam_fixture.sh`, `verify_prusa_wall_seam_fixture_test.sh`, `BUILD.bazel` - checked-in fixture corpus and current fixture verifier behavior. [VERIFIED: local file read]
- `packages/prusa-wall-seam-scope/*` - scope docs/verifier current planned-publication behavior. [VERIFIED: local file read]
- `docs/port/README.md`, `package-map.md`, `parity-matrix.md`, `migration-guidance.md` - public port docs publication boundaries. [VERIFIED: local file read]
- `.planning/milestones/v1.15-phases/60-executable-arc-fitting-evidence/*-PLAN.md` - closest six-plan publication precedent. [VERIFIED: local file read]
- `AGENTS.md`, `AGENTS.bright-builds.md`, `standards/index.md`, `standards/core/architecture.md`, `standards/core/code-shape.md`, `standards/core/testing.md`, `standards/core/verification.md`, `standards/languages/rust.md`, `standards-overrides.md` - repo and Bright Builds guidance. [VERIFIED: local file read]

### Secondary (MEDIUM confidence)

- OWASP ASVS GitHub repository - confirms current ASVS stable version context and source of ASVS taxonomy. [CITED: https://github.com/OWASP/ASVS]

### Tertiary (LOW confidence)

- None. [VERIFIED: source review]

## Metadata

**Confidence breakdown:**

- Standard stack: HIGH - versions and targets were verified locally. [VERIFIED: environment availability audit; VERIFIED: Bazel query audit]
- Architecture: HIGH - Phase 60 precedent and Phase 65 locked decisions align directly. [VERIFIED: .planning/milestones/v1.15-phases/60-executable-arc-fitting-evidence/60-01-PLAN.md; VERIFIED: .planning/phases/65-executable-wall-seam-evidence/65-CONTEXT.md]
- Pitfalls: HIGH - current verifiers and docs expose the exact planned-to-published boundary changes. [VERIFIED: packages/parity-fixtures/verify_prusa_wall_seam_fixture.sh; VERIFIED: packages/prusa-wall-seam-scope/verify_prusa_wall_seam_scope.sh; VERIFIED: docs/port/README.md]

**Research date:** 2026-07-02 [VERIFIED: system date]
**Valid until:** 2026-08-01 for local codebase patterns, or earlier if Phase 65 code changes before planning. [ASSUMED]
