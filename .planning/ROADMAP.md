# Roadmap: Slic3r Rust Port

## Milestones

- Active: **v1.16 PrusaSlicer Wall-Seam G-code Evidence Slice** -
  Phases 62-65 (planning complete; ready for Phase 62)
- Shipped: **v1.15 PrusaSlicer Arc-Fitting G-code Evidence Slice** -
  Phases 57-61 (shipped 2026-06-25)
  Archive: [.planning/milestones/v1.15-ROADMAP.md](/Users/peterryszkiewicz/Repos/Slic3r/.planning/milestones/v1.15-ROADMAP.md)
  Requirements: [.planning/milestones/v1.15-REQUIREMENTS.md](/Users/peterryszkiewicz/Repos/Slic3r/.planning/milestones/v1.15-REQUIREMENTS.md)
  Audit: [.planning/milestones/v1.15-MILESTONE-AUDIT.md](/Users/peterryszkiewicz/Repos/Slic3r/.planning/milestones/v1.15-MILESTONE-AUDIT.md)
  Phases: [.planning/milestones/v1.15-phases/](/Users/peterryszkiewicz/Repos/Slic3r/.planning/milestones/v1.15-phases/)
- Shipped: **v1.14 PrusaSlicer G-code Semantic Evidence Foundation** -
  Phases 53-56 (shipped 2026-06-22)
  Archive: [.planning/milestones/v1.14-ROADMAP.md](/Users/peterryszkiewicz/Repos/Slic3r/.planning/milestones/v1.14-ROADMAP.md)
  Requirements: [.planning/milestones/v1.14-REQUIREMENTS.md](/Users/peterryszkiewicz/Repos/Slic3r/.planning/milestones/v1.14-REQUIREMENTS.md)
  Audit: [.planning/milestones/v1.14-MILESTONE-AUDIT.md](/Users/peterryszkiewicz/Repos/Slic3r/.planning/milestones/v1.14-MILESTONE-AUDIT.md)
  Phases: [.planning/milestones/v1.14-phases/](/Users/peterryszkiewicz/Repos/Slic3r/.planning/milestones/v1.14-phases/)
- Shipped: **v1.13 PrusaSlicer G-code Structural Evidence Expansion** -
  Phases 49-52 (shipped 2026-06-19)
  Archive: [.planning/milestones/v1.13-ROADMAP.md](/Users/peterryszkiewicz/Repos/Slic3r/.planning/milestones/v1.13-ROADMAP.md)
- Shipped: **v1.12 PrusaSlicer G-code Output Evidence Foundation** -
  Phases 45-48 (shipped 2026-06-15)
  Archive: [.planning/milestones/v1.12-ROADMAP.md](/Users/peterryszkiewicz/Repos/Slic3r/.planning/milestones/v1.12-ROADMAP.md)
- Shipped: **v1.11 PrusaSlicer Broader Parity Port** - Phases 41-44
  (shipped 2026-06-06)
  Archive: [.planning/milestones/v1.11-ROADMAP.md](/Users/peterryszkiewicz/Repos/Slic3r/.planning/milestones/v1.11-ROADMAP.md)
- Shipped: **v1.10 PrusaSlicer Parity Evidence Foundation** - Phases 37-40
  (shipped 2026-06-02)
  Archive: [.planning/milestones/v1.10-ROADMAP.md](/Users/peterryszkiewicz/Repos/Slic3r/.planning/milestones/v1.10-ROADMAP.md)
- Shipped: **v1.9 Fork Vendor Intake and Module Architecture** - Phases 32-36
  (shipped 2026-05-29)
  Archive: [.planning/milestones/v1.9-ROADMAP.md](/Users/peterryszkiewicz/Repos/Slic3r/.planning/milestones/v1.9-ROADMAP.md)
- Shipped: **v1.8 Cross-Platform Release Build Automation** - Phase 31
  (shipped 2026-05-24)
  Archive: [.planning/milestones/v1.8-ROADMAP.md](/Users/peterryszkiewicz/Repos/Slic3r/.planning/milestones/v1.8-ROADMAP.md)
- Shipped: **v1.7 Cross-Platform Packaging-Visible Parity** - Phases 27-30
  (shipped 2026-05-23)
  Archive: [.planning/milestones/v1.7-ROADMAP.md](/Users/peterryszkiewicz/Repos/Slic3r/.planning/milestones/v1.7-ROADMAP.md)
- Shipped: **v1.6 Windows Parity Foundation** - Phases 24-26 (shipped
  2026-05-21)
  Archive: [.planning/milestones/v1.6-ROADMAP.md](/Users/peterryszkiewicz/Repos/Slic3r/.planning/milestones/v1.6-ROADMAP.md)
- Shipped: **v1.4 Linux Parity Foundation** - Phases 21-23 (shipped
  2026-04-11)
  Archive: [.planning/milestones/v1.4-ROADMAP.md](/Users/peterryszkiewicz/Repos/Slic3r/.planning/milestones/v1.4-ROADMAP.md)
- Shipped: **v1.3 Packaging-Visible Parity** - Phases 18-20 (shipped
  2026-04-11)
  Archive: [.planning/milestones/v1.3-ROADMAP.md](/Users/peterryszkiewicz/Repos/Slic3r/.planning/milestones/v1.3-ROADMAP.md)
- Shipped: **v1.2 Export and Transform Parity** - Phases 12-17 (shipped
  2026-04-11)
  Archive: [.planning/milestones/v1.2-ROADMAP.md](/Users/peterryszkiewicz/Repos/Slic3r/.planning/milestones/v1.2-ROADMAP.md)
- Shipped: **v1.1 CLI Parity Expansion** - Phases 9-11 (shipped 2026-04-08)
  Archive: [.planning/milestones/v1.1-ROADMAP.md](/Users/peterryszkiewicz/Repos/Slic3r/.planning/milestones/v1.1-ROADMAP.md)
- Shipped: **v1.0 Rust Port Foundations** - Phases 1-8 (shipped 2026-04-08)
  Archive: [.planning/milestones/v1.0-ROADMAP.md](/Users/peterryszkiewicz/Repos/Slic3r/.planning/milestones/v1.0-ROADMAP.md)

## Current Status

v1.16 is the active milestone. It proves one narrow, source-pinned
PrusaSlicer wall-seam G-code evidence slice through a reviewed scope contract,
fixture corpus, pure Rust evidence boundary, public executable evidence,
fail-closed mutation guards, exact status wording, and non-overclaiming docs.

The milestone keeps broad `generated-outputs`, byte-for-byte G-code parity,
wall-seam algorithm or geometry equivalence, seam visibility, printability,
printer-runtime behavior, support generation, STEP import, GUI behavior,
release behavior, upstream imports, sync automation, and non-Prusa fork
behavior deferred.

**Granularity:** fine
**Coverage:** 12/12 v1.16 requirements mapped

## Phases

**Phase Numbering:**

- Integer phases (62, 63, 64, 65): Planned milestone work

- Decimal phases (62.1, 62.2): Urgent insertions after planning

- [x] **Phase 62: Wall-Seam Scope Contract** - Close the reviewed (completed 2026-06-26)
  `prusaslicer.wall-seam` scope and fail-closed verifier before any evidence
  artifacts are published.

- [x] **Phase 63: Wall-Seam Fixture Corpus** - Add the source-pinned fixture (completed 2026-06-27)
  namespace, expected wall-seam summaries, provenance, and fixture drift
  guards.

- [x] **Phase 64: Rust Wall-Seam Evidence Boundary** - Parse checked-in (completed 2026-06-30)
  wall-seam summaries through a pure typed Rust boundary with static readiness
  metadata.

- [ ] **Phase 65: Executable Wall-Seam Evidence** - Publish public wall-seam
  parity evidence, mutation guards, exact status, and docs for the narrow
  evidence slice.

## Phase Details

### Phase 62: Wall-Seam Scope Contract

**Goal**: Maintainers have a reviewed, fail-closed wall-seam scope contract
that authorizes fixture, Rust, parity, status, and docs work without widening
generated-output claims.
**Depends on**: Phase 61
**Requirements**: SEAMSCOPE-01, SEAMSCOPE-02, SEAMSCOPE-03
**Success Criteria** (what must be TRUE):

1. Maintainer can inspect the accepted `prusaslicer.wall-seam` source
   identity, inventory row, category-map row, source anchors, artifact paths,
   planned status wording, deferred scope, security note, and reviewer signoff
   in one scope contract.
1. Maintainer can run the wall-seam scope verifier and see unsupported seam
   fields, duplicate or missing rows, traceability drift, broad
   generated-output claims, runtime or printability claims, and missing
   deferred-scope wording fail closed.
1. Maintainer can confirm broad `generated-outputs` remains `in progress`, the
   existing `fork.prusaslicer.gcode-output` and
   `fork.prusaslicer.arc-fitting` wording is preserved, and the planned
   `fork.prusaslicer.wall-seam` wording stays limited to the narrow v1.16
   evidence slice.

**Plans**: 3 plans

Plans:

- [x] 62-01-PLAN.md - Create the package-local wall-seam scope contract and
  package boundary.
- [x] 62-02-PLAN.md - Implement the fail-closed verifier for the scope
  contract.
- [x] 62-03-PLAN.md - Add mutation coverage and final Bazel verification
  wiring.

### Phase 63: Wall-Seam Fixture Corpus

**Goal**: Maintainers have a source-pinned wall-seam fixture corpus and
checked-in expected summaries constrained to the Phase 62 approved fields.
**Depends on**: Phase 62
**Requirements**: SEAMFIX-01, SEAMFIX-02, SEAMFIX-03
**Success Criteria** (what must be TRUE):

1. Maintainer can inspect a `prusaslicer.wall-seam` fixture namespace with
   source-pinned provenance, update rules, fixture identity, expected wall-seam
   summary paths, and explicit exclusions for generator, runtime, network,
   sync, host-upload, post-processing, thumbnail, printability, and GUI
   behavior.
1. Maintainer can inspect checked-in expected wall-seam summaries that cover
   only the Phase 62 approved fields, such as source identity, source anchors,
   fixture identity, seam-transition observations, layer or travel context,
   coordinate bounds, extrusion or retraction observations, and
   evidence-boundary text.
1. Maintainer can run fixture verification that rejects missing rows, duplicate
   rows, out-of-order rows, unsupported seam fields, unsupported claim text,
   wrong source refs, wrong fixture identities, checksum drift, and stale
   documentation references.

**Plans**: 2 plans

Plans:

- [x] 63-01-PLAN.md - Create source-pinned wall-seam fixture namespace,
  expected summary, provenance, and Bazel bundle.
- [x] 63-02-PLAN.md - Add fail-closed wall-seam fixture verifier, mutation
  coverage, and package-level command docs.

### Phase 64: Rust Wall-Seam Evidence Boundary

**Goal**: Developers can parse checked-in wall-seam summaries through a pure
typed Rust boundary and inspect readiness metadata without public status
publication or side effects.
**Depends on**: Phase 63
**Requirements**: SEAMRUST-01, SEAMRUST-02, SEAMRUST-03
**Success Criteria** (what must be TRUE):

1. Developer can parse caller-supplied checked-in wall-seam summary artifacts
   into typed Rust domain values without Git, network, filesystem discovery,
   process, generator, printer-runtime, release, or sync side effects.
1. Developer can inspect static registry or readiness metadata tracing the
   wall-seam boundary to the accepted Prusa source identity, fixture corpus,
   expected wall-seam summaries, planned command, planned status wording, and
   deferred generated-output surfaces.
1. Developer can run Cargo and Bazel coverage proving valid wall-seam fixture
   rows parse and invalid rows fail closed.
1. Developer can confirm public helper names and Rust internals do not claim
   byte parity, seam geometry equivalence, printability, runtime, support, GUI,
   arc-fitting, or non-Prusa fork behavior, and optional or nullable internals
   are named clearly.

**Plans**: 2 plans

Plans:

- [x] 64-01-PLAN.md - Add the pure typed wall-seam summary parser,
  developer-facing summary-line helper, and focused Cargo/Bazel parser
  coverage.
- [x] 64-02-PLAN.md - Add readiness metadata, registry visibility, aggregate
  Rust verification wiring, and public-boundary guards.

### Phase 65: Executable Wall-Seam Evidence

**Goal**: Maintainers can run public executable wall-seam evidence and inspect
exact public status/docs for the narrow PrusaSlicer wall-seam slice.
**Depends on**: Phase 64
**Requirements**: SEAMEV-01, SEAMEV-02, SEAMEV-03
**Success Criteria** (what must be TRUE):

1. Maintainer can run public Prusa wall-seam parity evidence that validates the
   checked-in wall-seam summary artifact through the Rust boundary while
   preserving the existing public Prusa G-code output and arc-fitting command
   contracts.
1. Maintainer can see fail-closed mutation guards for seam-transition
   observation changes, layer or travel context changes, coordinate-bound
   changes, extrusion or retraction observation changes, source identity drift,
   fixture identity drift, row-order drift, and unsupported deferred-behavior
   claims.
1. Maintainer can inspect parity status, package docs, and port docs that
   describe only the exact narrow `fork.prusaslicer.wall-seam` evidence slice
   while broad `generated-outputs` remains `in progress` and all
   generated-output, runtime, GUI, release, sync, and non-Prusa fork deferrals
   remain explicit.
1. Maintainer can confirm the existing `fork.prusaslicer.gcode-output` and
   `fork.prusaslicer.arc-fitting` meanings are not widened by wall-seam
   evidence publication.

**Plans**: 6 plans

Plans:

- [x] 65-01-PLAN.md - Add Rust-backed public wall-seam evidence command.
- [ ] 65-02-PLAN.md - Add fail-closed public wall-seam mutation guards.
- [ ] 65-03-PLAN.md - Publish exact wall-seam status row and verifier guards.
- [ ] 65-04-PLAN.md - Publish package and fixture docs with fixture verifier checks.
- [ ] 65-05-PLAN.md - Publish wall-seam scope docs with scope verifier checks.
- [ ] 65-06-PLAN.md - Publish public port docs for the narrow wall-seam slice.

## Coverage

| Requirement | Phase |
|-------------|-------|
| SEAMSCOPE-01 | Phase 62 |
| SEAMSCOPE-02 | Phase 62 |
| SEAMSCOPE-03 | Phase 62 |
| SEAMFIX-01 | Phase 63 |
| SEAMFIX-02 | Phase 63 |
| SEAMFIX-03 | Phase 63 |
| SEAMRUST-01 | Phase 64 |
| SEAMRUST-02 | Phase 64 |
| SEAMRUST-03 | Phase 64 |
| SEAMEV-01 | Phase 65 |
| SEAMEV-02 | Phase 65 |
| SEAMEV-03 | Phase 65 |

Mapped: 12/12 v1.16 requirements
Orphans: 0
Duplicates: 0

## Progress

**Execution Order:**
Phases execute in numeric order: 62 -> 63 -> 64 -> 65

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 62. Wall-Seam Scope Contract | 3/3 | Complete   | 2026-06-26 |
| 63. Wall-Seam Fixture Corpus | 2/2 | Complete   | 2026-06-27 |
| 64. Rust Wall-Seam Evidence Boundary | 2/2 | Complete   | 2026-06-30 |
| 65. Executable Wall-Seam Evidence | 1/6 | In Progress|  |

## Planning Notes

- Phase 62 owns final allowed wall-seam fields, source anchors, fixture
  derivation route, status wording, and package-boundary confirmation.
- Phase 63 must prove selected fixture bytes and expected rows are
  source-pinned and seam-specific without live generation or broad runtime
  claims.
- Phase 64 should reuse the existing `slic3r_flavors` parser/readiness
  patterns while keeping the Rust boundary pure and closed.
- Phase 65 publishes status/docs only after scope, fixture, Rust boundary,
  public comparator, mutation guards, and existing Prusa G-code output plus
  arc-fitting command regression checks pass.
