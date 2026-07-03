# Requirements: Slic3r Rust Port v1.16

**Defined:** 2026-06-26
**Milestone:** v1.16 PrusaSlicer Wall-Seam G-code Evidence Slice
**Core Value:** Deliver a trustworthy Rust successor to Slic3r that matches the
legacy behavior and interfaces closely enough that the old implementation can
eventually be retired without breaking the contracts users and integrators
depend on.

## v1.16 Requirements

Requirements for the current milestone. Each requirement maps to exactly one
roadmap phase and must be verified before milestone archive.

### Wall-Seam Scope Contract

- [x] **SEAMSCOPE-01**: Maintainer can inspect a reviewed Prusa wall-seam
  evidence scope contract that names the accepted source identity, inventory
  row, category-map row, source anchors, fixture namespace, expected wall-seam
  summary artifact, Rust boundary, public evidence command, planned status
  wording, docs touched, security note, deferred scope, and reviewer signoff.
- [x] **SEAMSCOPE-02**: Maintainer can run a fail-closed wall-seam scope
  verifier that rejects unsupported seam fields, duplicate or missing field
  rows, traceability drift, unsupported generated-output claims, unsupported
  runtime or printability claims, and missing deferred-scope language.
- [x] **SEAMSCOPE-03**: Maintainer can confirm the broad `generated-outputs`
  status row remains `in progress`, the existing
  `fork.prusaslicer.gcode-output` and `fork.prusaslicer.arc-fitting` status
  rows are not widened, and the planned `fork.prusaslicer.wall-seam` status row
  remains limited to the exact narrow evidence slice planned by this milestone.

### Wall-Seam Fixture Corpus

- [x] **SEAMFIX-01**: Maintainer can inspect a small reviewed Prusa wall-seam
  fixture corpus with source-pinned provenance, update rules, fixture identity,
  expected wall-seam summary paths, and explicit exclusion of generator,
  runtime, network, sync, host-upload, post-processing, thumbnail,
  printability, and GUI behavior.
- [x] **SEAMFIX-02**: Maintainer can inspect checked-in wall-seam expected
  summaries that cover only the Phase 62 approved fields, such as source
  identity, inventory source paths, source anchors, fixture identity,
  seam-transition observations, layer or travel context observations,
  coordinate bounds, extrusion or retraction observations, and
  evidence-boundary text.
- [x] **SEAMFIX-03**: Maintainer can run fail-closed fixture verification that
  rejects missing rows, duplicate rows, out-of-order rows, unsupported seam
  fields, unsupported claim text, wrong source refs, wrong fixture identities,
  checksum drift, and stale documentation references.

### Rust Wall-Seam Boundary

- [x] **SEAMRUST-01**: Developer can use a pure typed Rust wall-seam summary
  boundary that parses caller-supplied checked-in wall-seam summary artifacts
  into domain values without Git, network, filesystem discovery, process,
  generator, printer-runtime, release, or sync side effects.
- [x] **SEAMRUST-02**: Developer can inspect static readiness or registry
  metadata that traces the wall-seam boundary to the accepted Prusa source
  identity, fixture corpus, expected wall-seam summaries, planned command,
  planned status wording, and deferred generated-output surfaces.
- [x] **SEAMRUST-03**: Developer can run Cargo and Bazel coverage that proves
  the valid wall-seam fixture rows parse, invalid rows fail closed, optional or
  nullable Rust internals are named clearly, and no public helper names claim
  byte parity, seam geometry equivalence, printability, runtime, support, GUI,
  arc-fitting, or non-Prusa fork behavior.

### Executable Wall-Seam Evidence

- [x] **SEAMEV-01**: Maintainer can run public Prusa wall-seam parity evidence
  that validates the checked-in wall-seam summary artifact through the Rust
  boundary while preserving the existing public Prusa G-code output and
  arc-fitting command contracts.
- [x] **SEAMEV-02**: Maintainer can see fail-closed mutation guards for wall
  seam drift classes such as seam-transition observation changes, layer or
  travel context changes, coordinate-bound changes, extrusion or retraction
  observation changes, source identity drift, fixture identity drift,
  row-order drift, and unsupported deferred-behavior claims.
- [x] **SEAMEV-03**: Maintainer can inspect parity status, package docs, and
  port docs that describe the exact narrow `fork.prusaslicer.wall-seam`
  evidence slice while keeping broad `generated-outputs` in progress,
  preserving the existing `fork.prusaslicer.gcode-output` and
  `fork.prusaslicer.arc-fitting` meanings, and keeping all deferred
  generated-output, runtime, GUI, release, sync, and non-Prusa fork surfaces
  explicit.

## Future Requirements

### Generated Output Semantics

- **GOUT-01**: Maintainer can compare byte-for-byte Prusa G-code output for a
  larger reviewed fixture corpus.
- **GOUT-02**: Maintainer can compare richer semantic toolpath geometry,
  extrusion, timing, and printability evidence for reviewed generated-output
  fixtures.
- **GOUT-03**: Maintainer can graduate the broad `generated-outputs` status row
  only after multiple generated-output surfaces have executable evidence.

### Downstream Generated-Output Features

- **SUPP-01**: Maintainer can verify Prusa support-generation evidence through
  reviewed fixtures and executable parity.
- **SEAM-02**: Maintainer can verify richer wall-seam geometry, tolerance,
  algorithm-equivalence, seam-visibility, or printability evidence beyond the
  narrow v1.16 checked-in summary evidence slice.
- **ARC-02**: Maintainer can verify richer arc-fitting geometry, tolerance,
  algorithm-equivalence, or printability evidence beyond the narrow v1.15
  command-shape evidence slice.

### Input Format and Fork Expansion

- **STEP-01**: Maintainer can verify Prusa STEP import evidence through
  reviewed file-format fixtures and parser evidence.
- **FORK-01**: Maintainer can plan Bambu Studio or OrcaSlicer evidence only
  after an explicit planning decision moves a non-Prusa fork out of the
  parking lot.

## Out of Scope

Explicitly excluded from v1.16 to prevent scope creep.

| Feature | Reason |
|---------|--------|
| Byte-for-byte Prusa G-code parity | v1.16 proves narrow wall-seam evidence summaries, not exact generated text equality across a broad corpus. |
| Broad `generated-outputs` verification | One additional feature-specific generated-output milestone is still too narrow to mark the whole generated-output surface verified. |
| Full wall-seam algorithm equivalence, geometry, tolerance, seam visibility, or printability | The milestone validates checked-in evidence facts, not mathematical, geometric, visual, or printer-runtime equivalence. |
| Printability, firmware behavior, printer-runtime behavior, host upload, and timing guarantees | Wall-seam summaries are evidence inputs, not proof that a printer accepts or prints the output correctly. |
| Support generation, STEP import, and richer arc-fitting behavior | These remain separate feature slices that can use the evidence machinery after explicit future planning. |
| Full PrusaSlicer runtime or GUI behavior | v1.16 is an evidence-chain milestone, not a runtime fork port or desktop-app milestone. |
| Binary G-code, thumbnails, post-processing, and host upload | These surfaces require separate fixture, runtime, and integration scopes. |
| Network/device, cloud, credential, or profile auto-update execution | These remain deferred because they introduce external integration, credential, and runtime-support risk. |
| Fork release builds and release-channel publishing | v1.16 does not create distributable PrusaSlicer artifacts or release automation. |
| Bambu Studio and OrcaSlicer support | Active downstream-fork port planning remains limited to PrusaSlicer until a future planning decision says otherwise. |
| Upstream source imports or sync automation | Existing source pins remain planning inputs; automated import/sync needs a later review-gated policy. |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| SEAMSCOPE-01 | Phase 62 | Complete |
| SEAMSCOPE-02 | Phase 62 | Complete |
| SEAMSCOPE-03 | Phase 62 | Complete |
| SEAMFIX-01 | Phase 63 | Complete |
| SEAMFIX-02 | Phase 63 | Complete |
| SEAMFIX-03 | Phase 63 | Complete |
| SEAMRUST-01 | Phase 64 | Complete |
| SEAMRUST-02 | Phase 64 | Complete |
| SEAMRUST-03 | Phase 64 | Complete |
| SEAMEV-01 | Phase 65 | Complete |
| SEAMEV-02 | Phase 65 | Complete |
| SEAMEV-03 | Phase 65 | Complete |

**Coverage:**

- v1.16 requirements: 12 total
- Mapped to phases: 12
- Unmapped: 0

______________________________________________________________________

*Requirements defined: 2026-06-26*
*Last updated: 2026-06-26 during roadmap creation*
