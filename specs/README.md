# Specs Directory

Specification files are the source of truth. All code, documentation, and artifacts are derived from specs.
Project specification files are contained in the `specs/` directory in the project root.
Finer-grained feature spec files are contained in a `specs/` directory a feature's subdirectory.
Copy the contents of this file into the `specs/README.md` file.

## File Naming
- `<number>-<descriptive-name>.md` where number is 3-digit prefix (001, 002) and name is kebab-case.
- Use decimal notation for related specs (001-Overview.md, 001.1-Architecture.md, 001.2-Stack.md).

## Workflow
1. Update/create spec files with requirements, behavior, edge cases, interfaces.
2. Generate/update code, tests, documentation from spec.
3. Verify code matches spec and tests validate requirements.

## Code Examples
Use pseudocode (not language-specific syntax) to keep specs implementation-agnostic.

## Diagrams
- Use Mermaid for all diagrams.
- Can be inlined as mermaid code blocks.

# Development Rules

## Documentation Standards

- Update spec files during implementation with details, clarifications, and behavioral requirements discovered.
- Record refactoring/architectural change instructions in `/specs/*.md` for consistency across iterations.
- Correct grammar and punctuation required in all documentation and code comments.
- Use neutral statements: "Ensure the home directory is the current working directory" (not "Ensure we're running from...").

## Testing Requirements

- >90% code coverage per file
- Unit tests for all functions/methods
- Integration tests for API endpoints and critical paths
- Test actual code (don't copy code into tests)
- Individual tests complete in seconds
- Test termination functions using injected function parameters
- Test long-running loops/IO with parameters for iteration control, mock IO, or reduced sleep times

## Bug Fixing

1. Create failing unit test with buggy code.
2. Fix application code.
3. Run unmodified test to verify fix.

## Code Quality

- DRY: Extract common functionality into reusable functions/modules.
- Function Size: <25 lines; break larger functions into smaller ones.
- SOLID Principles: Follow clean architecture and dependency inversion.
- Testability: Use dependency injection and mocks; design for isolation.

## Notes for This Project

Dexter is primarily a hardware project (mechanical assembly, electronics, firmware, gateware) rather than an
application codebase, so the general-purpose Rust/API/Makefile rules in the parent CLAUDE.md apply only where
relevant (e.g., any tooling scripts added to this fork). The specs in this directory currently focus on:

- Consolidating the Bill of Materials (previously split across multiple spreadsheets of unclear currency).
- Consolidating assembly instructions (previously split across a wiki page, a YouTube series, and tribal knowledge).
- Documenting firmware defaults and the factory calibration procedure (previously buried in a `.make_ins` config
  file and un-cross-referenced onboarding PDFs).

**Target generation: Dexter HDI**, not Dexter HD. This was a deliberate change from an earlier draft of this spec
set — see [001-Overview.md](001-Overview.md#generation-decision-this-spec-set-targets-dexter-hdi) for why. Because
no structured HDI BOM, assembly video series, or PBS spreadsheet exists upstream, this spec set marks every section
as one of three things: **VERIFIED** (transcribed from a named upstream source), **FORK PROPOSAL** (this fork's own
design/procedure, written to close a gap upstream never published — not verified against a physical build), or
**OPEN QUESTION** (a gap this fork judged too risky to guess at, e.g. the harmonic drive components, left as a
call-to-action instead). Consult [001-Overview.md](001-Overview.md#verification-status) before treating any
FORK PROPOSAL content as more authoritative than a first draft.

All specs are derived from the original Haddington Dynamics wiki, BOM spreadsheets, upstream git branches
(including the `Stable_Conedrive` "Dexter HDI" development branch), factory calibration PDFs shipped in this
repo's tree, the `cfry/dde` sibling repo, and community reports, cross-checked against each other. None has been
verified against a physical build by this fork's maintainer yet — see the "Verification status" note at the top
of each spec.
