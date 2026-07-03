---
phase: 65
slug: executable-wall-seam-evidence
status: secured
threats_open: 0
threats_total: 22
threats_closed: 22
asvs_level: 1
created: 2026-07-03T00:43:04Z
updated: 2026-07-03T00:43:04Z
generated_by: gsd-security-auditor
---

# Phase 65 - Security

Per-phase security contract for Phase 65, executable wall-seam evidence.

Material guidance loaded for this audit: `AGENTS.md`, `AGENTS.bright-builds.md`,
`standards-overrides.md`, `standards/index.md`,
`standards/core/verification.md`, `standards/core/testing.md`,
`standards/languages/rust.md`, and the `gsd-secure-phase` workflow. Repo-local
guidance was applied by creating only this `65-SECURITY.md` report, leaving
implementation files, `.planning/config.json`, and existing SUMMARY files
untouched.

## Scope

This audit verifies only threats declared in the six Phase 65 PLAN threat models.
It does not scan for unrelated new vulnerabilities. All declared dispositions are
`mitigate`; there are no accepted or transferred threats.

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| checked-in TSV -> Rust parser | `expected-wall-seam-summary.tsv` is parsed as local evidence input before public output is produced. | Local TSV evidence into `prusa_wall_seam_summary_lines`. |
| Bazel runfiles -> shell comparator | Shell receives explicit Bazel runfile paths and must not discover runtime files or external sources. | Bazel runfile paths into Bash comparator. |
| command output -> maintainer interpretation | Public wording must not overclaim wall-seam behavior, byte parity, geometry equivalence, printability, runtime, GUI, release, sync, or fork support. | Maintainer-facing command output and docs. |
| checked-in fixture -> temp mutation | Tests copy source evidence into temp files before mutation. | Checked-in TSV into temp mutation files. |
| temp mutated TSV -> public comparator | Mutated files cross into the same public Rust-backed validation path maintainers run. | Temp TSV into public comparator. |
| stderr diagnostics -> maintainer evidence | Failure messages must identify the changed artifact and field or boundary. | Comparator/test diagnostics. |
| status.tsv -> public parity status | Checked-in public status text becomes maintainer-facing evidence. | Status row text into docs and status command. |
| status.tsv -> verifier scripts | Verifiers enforce exact publication state. | Status TSV into fixture and scope verifiers. |
| test temp status fixtures -> verifier diagnostics | Mutation tests prove false or widened status claims fail closed. | Temp status TSV into verifiers. |
| package docs -> maintainer interpretation | Docs become public evidence guidance. | Package README content. |
| fixture README -> fixture verifier | Exact verifier checks decide whether package docs are stale or overclaiming. | README text into verifier checks. |
| status row -> docs | Package docs must describe the exact checked-in status row without widening it. | Status semantics into docs. |
| scope docs -> maintainer interpretation | Scope docs explain what the public wall-seam evidence proves and does not prove. | Scope markdown into maintainer decisions. |
| scope docs -> scope verifier | Exact checks decide whether scope docs are stale or overclaiming. | Scope markdown into verifier checks. |
| status row -> scope docs | Scope docs must describe the checked-in `fork.prusaslicer.wall-seam` row without promoting broad generated-output status or widening sibling rows. | Status row semantics into scope docs. |
| public port docs -> maintainer decisions | Port docs communicate what evidence is verified and what remains deferred. | Public docs into maintainer decisions. |
| status TSV -> port docs | Port docs must match `packages/parity/status.tsv` without promoting broad generated-output status. | Status semantics into public port docs. |
| package ownership docs -> future executors | Package map guides future changes to the correct local checked-in packages. | Ownership documentation into future work. |

## Threat Register

| Threat ID | Category | Component | Disposition | Status | Evidence |
|-----------|----------|-----------|-------------|--------|----------|
| T-65-01-01 | Tampering | `prusa_wall_seam_summary.rs` and comparator | mitigate | closed | Rust CLI delegates to `prusa_wall_seam_summary_lines` and reads an explicit path in `packages/slic3r-rust/crates/slic3r_flavors/src/bin/prusa_wall_seam_summary.rs:5` and `:23`; comparator generates, validates, diffs, and asserts exact summary fields in `packages/parity/compare_prusaslicer_wall_seam.sh:148` and `:165`; `bazel run //packages/parity:prusaslicer_wall_seam_parity` and mutation tests passed. |
| T-65-01-02 | Elevation of Privilege / Information Disclosure | shell comparator path handling | mitigate | closed | Comparator requires exactly four explicit arguments and local files in `packages/parity/compare_prusaslicer_wall_seam.sh:4` and `:24`; Bazel passes explicit runfiles in `packages/parity/BUILD.bazel:180`; forbidden runtime/source/network command scan returned no matches. |
| T-65-01-03 | Spoofing / Repudiation | public command wording | mitigate | closed | Public output is limited to checked-in wall-seam facts and `checked-in-wall-seam-summary-only` in `packages/parity/compare_prusaslicer_wall_seam.sh:189`; public command/docs overclaim scan returned no matches. |
| T-65-02-01 | Tampering | mutation tests | mitigate | closed | Mutation suite uses `mktemp`, temp cleanup, and copied `expected-wall-seam-summary.tsv` files in `packages/parity/compare_prusaslicer_wall_seam_test.sh:20`, `:21`, and `:174`; original checked-in rows are asserted in `:268`; uncached Bazel mutation test passed. |
| T-65-02-02 | Repudiation | diagnostics | mitigate | closed | Mutation helpers assert stderr contains `expected-wall-seam-summary.tsv` and the changed field or phrase in `packages/parity/compare_prusaslicer_wall_seam_test.sh:182`, `:203`, and `:224`; comparator diagnostics name the mismatch field and artifact in `packages/parity/compare_prusaslicer_wall_seam.sh:154` and `:165`. |
| T-65-02-03 | Elevation of Privilege / Information Disclosure | test harness temp paths | mitigate | closed | Test harness resolves local workspace/runfile paths and calls only the public comparator in `packages/parity/compare_prusaslicer_wall_seam_test.sh:4` and `:149`; forbidden runtime/source/network command scan returned no matches. |
| T-65-03-01 | Spoofing | `fork.prusaslicer.wall-seam` row | mitigate | closed | Exact verified wall-seam status row exists in `packages/parity/status.tsv:20`; status `awk` count check returned `wall=1 generated_in_progress=1 gcode=1 arc=1`. |
| T-65-03-02 | Repudiation | `generated-outputs` row | mitigate | closed | `generated-outputs` remains one `in progress` row in `packages/parity/status.tsv:14`; fixture and scope verifiers enforce this at `packages/parity-fixtures/verify_prusa_wall_seam_fixture.sh:485` and `packages/prusa-wall-seam-scope/verify_prusa_wall_seam_scope.sh:322`. |
| T-65-03-03 | Tampering | sibling Prusa rows | mitigate | closed | Sibling rows remain exact in `packages/parity/status.tsv:18` and `:19`; verifiers require exact G-code, arc-fitting, and wall-seam rows in `packages/parity-fixtures/verify_prusa_wall_seam_fixture.sh:491` and `packages/prusa-wall-seam-scope/verify_prusa_wall_seam_scope.sh:328`; mutation tests reject sibling widening. |
| T-65-03-04 | Information Disclosure | status publication | mitigate | closed | Wall-seam row is limited to checked-in summary evidence and explicit deferrals in `packages/parity/status.tsv:20`; hardcoded secret assignment scan returned no matches. |
| T-65-04-01 | Spoofing | package docs | mitigate | closed | Package docs name only the wall-seam command/status and checked-in summary evidence in `packages/parity/README.md:134` and `packages/parity-fixtures/README.md:100`; docs grep confirmed command, row, and Phase 62-65 chain. |
| T-65-04-02 | Repudiation | fixture docs | mitigate | closed | Fixture verifier requires the exact Phase 65 publication sentence in `packages/parity-fixtures/verify_prusa_wall_seam_fixture.sh:458` and `:474`; fixture mutation tests reject stale owned/future wording in `packages/parity-fixtures/verify_prusa_wall_seam_fixture_test.sh:527`; verifier and mutation test passed. |
| T-65-04-03 | Tampering | docs/status drift | mitigate | closed | Docs keep generated outputs in progress and sibling rows separate in `packages/parity/README.md:141` and `packages/parity-fixtures/README.md:100`; fixture verifier enforces status and docs checks in `packages/parity-fixtures/verify_prusa_wall_seam_fixture.sh:477`. |
| T-65-04-04 | Information Disclosure | docs | mitigate | closed | Package/fixture docs contain explicit deferrals and no executable exposure in `packages/parity/README.md:150` and `packages/parity-fixtures/README.md:103`; hardcoded secret assignment scan returned no matches. |
| T-65-05-01 | Spoofing | scope docs | mitigate | closed | Scope README and contract publish the exact command/status wording in `packages/prusa-wall-seam-scope/README.md:14` and `packages/prusa-wall-seam-scope/wall-seam-scope.md:78`; `bazel run //packages/prusa-wall-seam-scope:verify` passed. |
| T-65-05-02 | Tampering | scope verifier | mitigate | closed | Scope verifier exact-text checks require published rows/section and reject stale planned wording in `packages/prusa-wall-seam-scope/verify_prusa_wall_seam_scope.sh:206`, `:288`, `:298`, and `:395`; mutation tests cover stale label/section changes at `packages/prusa-wall-seam-scope/verify_prusa_wall_seam_scope_test.sh:341` and `:357`. |
| T-65-05-03 | Repudiation | published evidence boundary | mitigate | closed | Scope docs preserve Phase 62-65 chain and deferrals in `packages/prusa-wall-seam-scope/wall-seam-scope.md:25`, `:79`, and `:103`; scope verifier checks deferred terms in `packages/prusa-wall-seam-scope/verify_prusa_wall_seam_scope.sh:404`. |
| T-65-05-04 | Information Disclosure | scope docs | mitigate | closed | Scope security note says no secrets/private data/runtime discovery/network/device/host upload/release/sync/upstream import/printer-runtime behavior in `packages/prusa-wall-seam-scope/wall-seam-scope.md:25`; forbidden-claim checks remain active in `packages/prusa-wall-seam-scope/verify_prusa_wall_seam_scope.sh:341`. |
| T-65-06-01 | Spoofing | public port evidence wording | mitigate | closed | Public port docs include exact status token, command, artifact, Rust helper, and Phase 62-65 chain in `docs/port/README.md:404`, `docs/port/package-map.md:249`, `docs/port/parity-matrix.md:129`, and `docs/port/migration-guidance.md:225`. |
| T-65-06-02 | Tampering | broad generated-output status | mitigate | closed | Parity matrix and public docs keep `Generated outputs` in progress and sibling rows separate in `docs/port/parity-matrix.md:15`, `:136`, `docs/port/README.md:421`, and `docs/port/package-map.md:250`; `bazel run //packages/parity:status` and status `awk` check passed. |
| T-65-06-03 | Repudiation | stale planned/future wording | mitigate | closed | Stale planned/future wording scan across touched port and scope docs returned no matches. |
| T-65-06-04 | Information Disclosure | docs-only publication | mitigate | closed | Public docs keep network/device/upstream import/host upload/runtime/sync/release/printer-runtime terms as explicit deferrals in `docs/port/README.md:423`, `docs/port/migration-guidance.md:236`, and `docs/port/parity-matrix.md:140`; hardcoded secret assignment scan returned no matches. |

## Accepted Risks Log

No accepted risks.

## Transferred Risks

No transferred risks.

## Unregistered Flags

None. All six SUMMARY files contain `## Threat Flags` sections with no new
unregistered attack surface:

| Summary | Threat Flags |
|---------|--------------|
| `65-01-SUMMARY.md` | None - explicit local-file Rust adapter and explicit-runfile comparator only. |
| `65-02-SUMMARY.md` | None - local temp-file mutation tests and Bazel wiring only. |
| `65-03-SUMMARY.md` | None - exact status row covered by the plan threat model. |
| `65-04-SUMMARY.md` | None - package/fixture docs and exact-text checks only. |
| `65-05-SUMMARY.md` | None - scope docs and verifier exact-text checks only. |
| `65-06-SUMMARY.md` | None - documentation-only deferrals, not executable surfaces. |

## Verification Commands

| Command | Result |
|---------|--------|
| `bash -n packages/parity/compare_prusaslicer_wall_seam.sh packages/parity/compare_prusaslicer_wall_seam_test.sh packages/parity-fixtures/verify_prusa_wall_seam_fixture.sh packages/parity-fixtures/verify_prusa_wall_seam_fixture_test.sh packages/prusa-wall-seam-scope/verify_prusa_wall_seam_scope.sh packages/prusa-wall-seam-scope/verify_prusa_wall_seam_scope_test.sh` | Passed, no output. |
| `shfmt -l -d packages/parity/compare_prusaslicer_wall_seam.sh packages/parity/compare_prusaslicer_wall_seam_test.sh packages/parity-fixtures/verify_prusa_wall_seam_fixture.sh packages/parity-fixtures/verify_prusa_wall_seam_fixture_test.sh packages/prusa-wall-seam-scope/verify_prusa_wall_seam_scope.sh packages/prusa-wall-seam-scope/verify_prusa_wall_seam_scope_test.sh` | Passed, no diff. |
| `mdformat --check packages/parity/README.md packages/parity-fixtures/README.md packages/parity-fixtures/forks/prusaslicer/prusaslicer.wall-seam/README.md packages/prusa-wall-seam-scope/README.md packages/prusa-wall-seam-scope/wall-seam-scope.md docs/port/README.md docs/port/package-map.md docs/port/parity-matrix.md docs/port/migration-guidance.md` | Passed. |
| `awk -F '\t' ... packages/parity/status.tsv` | Passed: `wall=1 generated_in_progress=1 gcode=1 arc=1`. |
| `rg -n 'curl \|git \|clone\|fetch\|host upload\|send-gcode\|PrusaSlicer --\|slic3r --' packages/parity/compare_prusaslicer_wall_seam.sh packages/parity/compare_prusaslicer_wall_seam_test.sh` | Passed: no forbidden runtime/source/network command matches. |
| `rg -n 'future fork\.prusaslicer\.wall-seam\|Phase 65 planned ...\|planned public evidence command' ...` | Passed: no stale planned/future wall-seam wording matches. |
| `git diff --check -- <Phase 65 touched files>` | Passed. |
| `bazel test --cache_test_results=no --test_output=errors //packages/parity:prusaslicer_wall_seam_parity_failure_test //packages/parity-fixtures:verify_prusa_wall_seam_fixture_test //packages/prusa-wall-seam-scope:verify_prusa_wall_seam_scope_test` | Passed: 3 of 3 tests passed. |
| `bazel run //packages/parity:prusaslicer_wall_seam_parity` | Passed: printed `ok: fork.prusaslicer.wall-seam checked-in summary evidence passed`, `wall_seam_rows: 12`, and `evidence_boundary: checked-in-wall-seam-summary-only`. |
| `bazel run //packages/parity:status` | Passed: displayed `generated-outputs in progress`, exact sibling rows, and `fork.prusaslicer.wall-seam verified`. |
| `bazel run //packages/parity-fixtures:verify_prusa_wall_seam_fixture` | Passed: `ok: Prusa wall-seam fixture verification passed`. |
| `bazel run //packages/prusa-wall-seam-scope:verify` | Passed: `ok: Prusa wall-seam scope verification passed`. |
| `bazel run //packages/parity:prusaslicer_gcode_output_parity` | Passed: `ok: fork.prusaslicer.gcode-output semantic evidence passed`. |
| `bazel run //packages/parity:prusaslicer_arc_fitting_parity` | Passed: `ok: fork.prusaslicer.arc-fitting checked-in summary evidence passed`. |
| Secret assignment and eval/exec sink scans over Phase 65 touched files | Passed: no hardcoded secret assignment patterns and no eval/exec/HTML sink matches. |
| Public command/docs verified-overclaim scan | Passed: no unsupported verified-overclaim wording matches. |

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-07-03T00:43:04Z | 22 | 22 | 0 | gsd-security-auditor |

## Sign-Off

- [x] All threats have a disposition.
- [x] Accepted risks documented in Accepted Risks Log.
- [x] `threats_open: 0` confirmed.
- [x] `status: secured` set in frontmatter.

**Approval:** secured 2026-07-03T00:43:04Z
