# Dexter — Specification

This directory is the **specification of the Dexter robot arm**: the authoritative design of
record from which all hardware, firmware, gateware, documentation, and build artifacts are derived.
It describes the robot — what it is, what it must do, and how it is built — not the process by which
this information was recovered. Where a design decision has been made, the specification states it as
the design; where a decision is still required to complete the robot, the specification records it as
work remaining (see [Design status](#design-status) and
[009-Design-Completion.md](009-Design-Completion.md)).

## Design identity and versioning

**No document in this set states its own version and revision.** Which design a document belongs to is
determined by the git branch or tag it is read at: `main` carries the latest development design, a released
revision is frozen at a tag such as `version-3-rev-a`, and a revision under development lives on a branch
such as `version-3/rev-b`. A new revision is authored on its own branch, taken from the previous revision's
tag, recording the intended changes as deltas against it and re-deriving the affected artifacts — the spec
set is never copied.

The version line, the branch and tag scheme, and the procedure for deriving the next revision are defined in
[010-Versioning.md](010-Versioning.md); the forward roadmap is [011-Roadmap.md](011-Roadmap.md); the
recorded history of each revision, and the only place a version and revision are written down, is
[CHANGES.md](../CHANGES.md) in the repository root.

## Specification map

Read top to bottom for a full picture; each document is self-contained and cross-links the others.

| # | Document | Scope |
|---|---|---|
| — | [README.md](README.md) | This map, the design-status scheme, and the specs workflow |
| 001 | [Overview](001-Overview.md) | What Dexter is; system decomposition; how the specification is organized |
| 002 | [Requirements](002-Requirements.md) | Capabilities the robot must deliver: degrees of freedom, workspace, precision, motion limits, environment, interfaces |
| 003 | [Kinematics](003-Kinematics.md) | Coordinate frames, joint conventions, link lengths, the Denavit–Hartenberg model, and motion commands |
| 004 | [Mechanical Architecture](004-Mechanical-Architecture.md) | Joint-by-joint mechanical design: drivetrains, structure, and the design intent behind each subassembly |
| 005 | [Electronics and Control](005-Electronics-and-Control.md) | Sensing, actuation, the FPGA joint-servo loop, boards, power, and the control-command interface |
| 006 | [Firmware and Calibration](006-Firmware-and-Calibration.md) | Firmware parameters, the calibration model, and the factory calibration and bring-up procedure |
| 007 | [Bill of Materials](007-Bill-of-Materials.md) | The parts that realize the design in 004–006, organized by subassembly |
| 008 | [Assembly](008-Assembly.md) | The procedure that builds the parts in 007 into the robot in 004 |
| 009 | [Design Completion](009-Design-Completion.md) | The open design decisions (`[TBD]` items) that must be closed to make the current design fully buildable |
| 010 | [Versioning](010-Versioning.md) | Version lineage, design identity, the git branch and tag model for versions and revisions, and the procedure for deriving the next one |
| 011 | [Roadmap](011-Roadmap.md) | Improvements anticipated beyond the current revision |
| — | [CHANGES.md](../CHANGES.md) | The design history: what changed in each revision and why (repository root) |

Documents 002–005 specify the robot (requirements → kinematics → mechanics → electronics/control).
Documents 006–008 are **derived artifacts**: firmware configuration, the parts list, and the build
procedure all follow from the design in 002–005 and must be regenerated when it changes. Document 009
is the live list of decisions still owed on the current revision; document 010 governs how the whole set evolves,
and 011 is what is intended beyond the current revision.

## Design status

Every requirement, design decision, and procedure carries one of three status markers. The marker
describes the **maturity of the design**, not the confidence of an observer.

- **`[Specified]`** — The design is defined and traceable to validated evidence: a physical unit, factory
  calibration data, released firmware, or a CAD model. It is safe to build to.
- **`[Provisional]`** — The design is defined by this specification and is the current design of record,
  but has not yet been validated on a physical build. It may change once verified. Treat it as a
  first-issue engineering design: buildable, but confirm before committing irreversible work
  (cutting carbon fiber, ordering long-lead parts).
- **`[TBD]`** — A design decision required to complete the current design has not yet been made. `[TBD]` items
  block a complete build and are collected in [009-Design-Completion.md](009-Design-Completion.md) with
  the requirement each must satisfy.

Each `[Specified]` and `[Provisional]` item cites its **source of record** (a file, CAD assembly, factory
document, or measurement) so the design remains traceable. Provenance is traceability metadata, not the
organizing narrative of the specification.

---

# Specs Directory (workflow)

Specification files are the source of truth. All code, documentation, and artifacts are derived from specs.
Project specification files are contained in the `specs/` directory in the project root.
Finer-grained feature spec files are contained in a `specs/` directory in a feature's subdirectory.

## File Naming
- `<number>-<descriptive-name>.md` where number is a 3-digit prefix (001, 002) and name is kebab-case.
- Use decimal notation for related specs (001-Overview.md, 001.1-Architecture.md, 001.2-Stack.md).

## Workflow
1. Update/create spec files with requirements, behavior, edge cases, and interfaces.
2. Generate/update code, tests, documentation, and build artifacts from the spec.
3. Verify the artifacts match the spec and that tests validate the requirements.

For this hardware project the "artifacts" derived from the spec are the firmware configuration
([006](006-Firmware-and-Calibration.md)), the bill of materials ([007](007-Bill-of-Materials.md)), the
assembly procedure ([008](008-Assembly.md)), and the CAD/build files they reference — not application code.
When the design in 002–005 changes, regenerate those derived documents to match.

## Diagrams
- Use Mermaid for all diagrams.
- May be inlined as mermaid code blocks.

## Documentation Standards
- Update spec files during design and build with details, clarifications, and behavioral requirements discovered.
- Record architectural decisions in `specs/*.md` for consistency across revisions.
- Correct grammar and punctuation are required in all documentation and comments.
- Use neutral statements describing the robot ("The base is bolted to a rigid surface"), not the author's process.
