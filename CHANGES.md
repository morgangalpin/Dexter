# Dexter — Change History

The design history of the Dexter specification, one section per revision, newest first. Each section
records what changed in that revision and why, so the file read top to bottom is the history of the design
and read bottom to top is how the current machine came to be. This file, together with
[specs/010-Versioning.md](specs/010-Versioning.md), is the only place a version and revision are written
down: every other document takes its identity from the branch or tag it is read at.

- **What a version and a revision are**, how each is branched and tagged, and the procedure for authoring
  the next one: [specs/010-Versioning.md](specs/010-Versioning.md).
- **What is planned but not yet opened as a revision**: [specs/011-Roadmap.md](specs/011-Roadmap.md).
- **What is still open on the current revision**: [specs/009-Design-Completion.md](specs/009-Design-Completion.md).

Each change is a `CR-<version><revision-letter><n>` entry in the format defined in
[010 §5](specs/010-Versioning.md#5-change-record-format). Change IDs are permanent: once published they are
not renumbered or reused, so a superseded change is amended by a later entry rather than edited away.
Statuses (`[Specified]`, `[Provisional]`, `[TBD]`) carry the meaning defined in
[specs/README.md](specs/README.md#design-status) and are recorded as of the revision's release.

---

## Version 3, revision A — baseline

**Status:** current design of record · **Tag:** `version-3-rev-a`, to be applied when this revision is
released ([010 §3](specs/010-Versioning.md#3-branch-model))

Revision A is the first issue of version 3's design of record and has no predecessor *revision* to delta
against — it establishes the baseline that later revisions delta against. It does have a predecessor
*version*: the changes below are the deliberate departures from version 2, recorded here because they are
the design decisions that define this revision and the reason version 2 is the inherited baseline for
anything version 3 does not independently specify
([010 §1](specs/010-Versioning.md#1-version-lineage)).

### CR-3A1: Belt-reduced wrist (J4/J5)

- **Affects:** [004 §Wrist](specs/004-Mechanical-Architecture.md), [006 §Drive constants](specs/006-Firmware-and-Calibration.md#drive-constants-axiscal)
- **Was:** Version 2 obtained wrist resolution by oscillating the motor across microsteps in firmware
  (`Interpolation` 16× on J4/J5), over a 5.625:1 (16T→90T) belt.
- **Now:** The wrist is resolved through a physical pulley reduction netting **13.5:1**, with
  `Interpolation` = 1 on all joints.
- **Driver:** Wrist resolution and repeatability without firmware microstep oscillation.
- **Status:** `[Specified]` for the net 13.5:1 ratio and the firmware constants;
  `[Provisional]` for the tooth-count realization, which remains open in
  [009](specs/009-Design-Completion.md).
- **Re-derive:** 006 (drive constants), 007 (pulley part numbers), 008 (wrist assembly).
- **Note:** Reusing version 2's driven pulley set unchanged against the new `AxisCal` produces a **2.4×
  wrist-scale error**. The driven side must be re-toothed to net 13.5:1.

### CR-3A2: Bolted base and doubled base clamp

- **Affects:** [004 §Base (J1)](specs/004-Mechanical-Architecture.md#base-j1)
- **Was:** Version 2 stood free on a 6-leg strake base with a single base clamp at the base-to-pivot joint.
- **Now:** The robot mounts to a rigid surface via a bolted metal base plate, and the base-to-pivot joint
  uses a doubled (stacked) base clamp.
- **Driver:** React the arm's full dynamic load through the mounting surface (REQ-ENV-5); stiffen the
  base-to-pivot joint.
- **Status:** `[Provisional]` — base plate design of record established, CAD hole transfer and the double
  clamp detail open in [009](specs/009-Design-Completion.md#base-plate).
- **Re-derive:** 007 (base plate, fasteners), 008 (base assembly and mounting).

### CR-3A3: Factory-recorded calibration

- **Affects:** [006 §Calibration model](specs/006-Firmware-and-Calibration.md#calibration-model)
- **Was:** Version 2 units were calibrated in the field.
- **Now:** Optical-encoder centers and index mapping are calibrated once and recorded onto the
  specific robot; a fielded unit is not re-calibrated. From-scratch builds run the full factory procedure
  once before first use.
- **Driver:** Remove field calibration as a routine operation and make each unit's kinematics traceable to
  a recorded factory measurement.
- **Status:** `[Specified]`.
- **Re-derive:** 008 (bring-up steps reference the recorded calibration rather than a field procedure).

### CR-3A4: Revised link geometry

- **Affects:** [003 §Link lengths](specs/003-Kinematics.md#link-lengths), [004](specs/004-Mechanical-Architecture.md), [007](specs/007-Bill-of-Materials.md)
- **Was:** Version 2 link lengths L1–L5 = 228.60 / 320.68 / 330.20 / 50.80 / 82.55 mm.
- **Now:** Link lengths L1–L5 = 235.20 / 339.09 / 307.50 / 59.50 / 82.44 mm (deltas +6.60, +18.42,
  −22.70, +8.70, −0.11 mm). L5 is unchanged within tolerance, consistent with the cross-version tool
  interface.
- **Driver:** Revised arm geometry; the L2/L3 deltas are far larger than build tolerance and change the
  carbon-fiber tube cut lengths.
- **Status:** `[Specified]` for the link lengths themselves (source: `Firmware/Defaults.make_ins`);
  `[Provisional]` for the derived cut lengths (Arm Body 282.4 mm, End Arm Hub 214.3 mm), pending a
  socket-seat check ([DC-5](specs/009-Design-Completion.md#link-member-lengths)).
- **Re-derive:** 007 (tube cut lengths), 008 (link assembly).

### CR-3A5: Specification restructured as the design of record

- **Affects:** the whole spec set, [specs/README.md](specs/README.md)
- **Was:** Build information was distributed across upstream wiki pages, spreadsheets, video build notes,
  and firmware files, describing what had been observed of the machine.
- **Now:** `specs/` is the authoritative design of record: requirements → kinematics → mechanics →
  electronics/control (002–005), with firmware configuration, bill of materials, and assembly (006–008) as
  derived artifacts. Every item carries a `[Specified]` / `[Provisional]` / `[TBD]` status and a source of
  record, and the decisions still owed on this revision are collected in
  [009](specs/009-Design-Completion.md).
- **Driver:** Make the design buildable from one traceable source, and make the open decisions explicit
  rather than implicit in what the sources did not cover.
- **Status:** `[Specified]`.
- **Re-derive:** n/a — this change defines the derivation order rather than following from it.
