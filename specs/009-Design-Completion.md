# 009 — Design Completion (Dexter HDI Rev A)

This document is the live list of **open design decisions** that must be closed to make Dexter HDI Revision A
fully buildable and to advance its `[Provisional]`/`[TBD]` items to `[Specified]`. Each item states the
requirement it must satisfy, its current state, what closing it requires (definition of done), and what it
blocks. These are design tasks owned by this project — not gaps in knowledge about the robot.

Priority reflects lead time and build-blocking impact. Close **P1** items before ordering; **P2** before
cutting/committing structure; **P3** are refinements or characterizations.

| ID | Item | Priority | Blocks | Status |
|---|---|---|---|---|
| DC-1 | [Strain-wave component set](#strain-wave-component-set) | **P1** | J1–J3 drives | `[TBD]` |
| DC-2 | [Differential detail design](#differential-detail-design) | **P1** | J4/J5 wrist | `[Provisional]` |
| DC-3 | [Wrist reduction ratio](#wrist-reduction-ratio) | P2 | J4/J5 resolution | `[TBD]` |
| DC-4 | [Base plate](#base-plate) | P2 | Base mounting | `[TBD]` |
| DC-5 | [Link member lengths (L2/L3)](#link-member-lengths) | P2 | Arm Body, End Arm Hub | `[Provisional]` |
| DC-6 | [Link-length discrepancy (L4)](#link-length-discrepancy-l4) | P2 | Kinematic accuracy | `[TBD]` |
| DC-7 | [Motor Control PCB](#motor-control-pcb) | P2 | Electronics | `[Provisional]` |
| DC-8 | [Power supply rating](#power-supply) | P2 | Power | `[TBD]` |
| DC-9 | [Performance characterization](#performance-characterization) | P3 | REQ-PRE/WS confirmation | `[TBD]` |
| DC-10 | [From-scratch calibration files](#from-scratch-calibration-files) | P2 | First bring-up | `[Provisional]` |

---

## Strain-wave component set
**DC-1 · P1 · Requirement: REQ-STR-2 · Specified in [004](004-Mechanical-Architecture.md#base-joints-j1-j3-strain-wave-drive)**

The 52:1 strain-wave drives on J1–J3 require a **flex spline, wave generator, and circular ("stator")
gear** — three sets total. These are not committed to an orderable part number. Historically sourced as a
special-order 52:1 "component gear set" (bare, not a housed unit), originally from HanZhen and later Cone
Drive, with long (9–12 week) lead time.

**Definition of done:** an orderable component set (or validated equivalent) at 52:1, with a bare
flex-spline / wave-generator / circular-gear geometry compatible with the printed Wave Gen Coupler and Flex
Spline Attach/Cap interfaces; confirmed price and lead time from the vendor. This is the highest-risk,
longest-lead item — resolve it first. If no compatible component set is procurable, this becomes a
drive-redesign task (e.g. cycloidal), which is a new revision, not a Rev A completion.

## Differential detail design
**DC-2 · P1 · Requirement: REQ-DOF-1, REQ-STR-3 · Specified in [004](004-Mechanical-Architecture.md#wrist-and-differential-j4-j5)**

The differential is described as significantly revised on HDI, and a distinct HDI differential CAD assembly
is referenced in `dde` (`HDI_DiffSkins`). Rev A specifies the differential *function* and provisionally
builds the HD differential geometry as a working substitute.

**Definition of done:** the HDI differential detail geometry (flex/pivot dimensions, pulley integration,
wiring bore) recovered from the HDI CAD/kinematic model or re-derived and validated, replacing the HD
substitute. Until then, build the HD differential; an incorrect flex/pivot geometry risks binding a joint
that also routes the tool wiring through its bore.

## Wrist reduction ratio
**DC-3 · P2 · Requirement: REQ-STR-3, REQ-PRE (J4/J5) · Specified in [004](004-Mechanical-Architecture.md#wrist-and-differential-j4-j5), [006](006-Firmware-and-Calibration.md#drive-constants-axiscal)**

HDI resolves J4/J5 by belt/pulley reduction (`Interpolation` = 1, J4/J5 `AxisCal` differs from HD). The
exact HDI pulley tooth counts are not derivable from the firmware constants alone (the `AxisCal` and
`Interpolation` changes do not algebraically pin a single tooth count).

**Definition of done:** the HDI J4/J5 pulley tooth counts and belt lengths, validated so that firmware
`AxisCal`/`Interpolation` produce correct joint resolution and range with acceptable backlash. Rev A builds
the wrist with the HD GT2 pulleys provisionally and verifies resolution empirically; adjust tooth counts if
the measured resolution/backlash is unacceptable.

## Base plate
**DC-4 · P2 · Requirement: REQ-STR-4, REQ-ENV-5 · Specified in [004](004-Mechanical-Architecture.md#base-j1)**

The bolted base replaces HD's legs with a plate bolted to the Base Mount Bottom and through to a work
surface. Material, thickness, and bolt pattern are undefined.

**Definition of done:** a base-plate design (material — metal recommended over printed Onyx for a
load-bearing bolted plate — thickness, and both bolt patterns: to the Base Mount Bottom and to the work
surface) that reacts the arm's full dynamic load, plus the corresponding mounting hardware in
[007](007-Bill-of-Materials.md). Also confirm whether the plate is intended to stay fixed to the work
surface with the base docking onto it, or to be removed as a unit.

## Link member lengths
**DC-5 · P2 · Requirement: REQ-WS-6 · Specified in [003](003-Kinematics.md#link-lengths), [004](004-Mechanical-Architecture.md)**

L2 (+18.4 mm) and L3 (−22.7 mm) differ from HD by more than build tolerance, so the Arm Body 1" CF tube and
End Arm Hub 0.75" CF tube (and possibly Main Pivot strakes) need HDI-specific cut lengths, not HD lengths.

**Definition of done:** exact HDI cut lengths for the L2 and L3 structural members, confirmed against the
HDI kinematic/CAD model before cutting carbon fiber. Rev A provisionally scales HD lengths by the deltas
(e.g. ~282 mm Arm Body tube, ~214 mm End Arm Hub tube) as a starting point only.

## Link-length discrepancy (L4)
**DC-6 · P2 · Requirement: REQ-WS-6 · Specified in [003](003-Kinematics.md#link-lengths)**

Two HDI link-length sets disagree: the firmware file (`Defaults.make_ins`) gives L4 = 59.50 mm and
L5 = 82.44 mm; the wiki gives L4 = 50.95 mm and L5 = 82.55 mm. Rev A treats the firmware file as
authoritative.

**Definition of done:** reconcile the two against a physical measurement of L4/L5 on a built or serialized
unit and set the authoritative values, updating [003](003-Kinematics.md#link-lengths) and firmware.

## Motor Control PCB
**DC-7 · P2 · Requirement: REQ-CTL-3, REQ-IF-4 · Specified in [005](005-Electronics-and-Control.md#boards)**

No HDI-native Motor Control PCB exists; Rev A reuses the HD board (D3/D4-corrected) with the White-wire
harness reassignment. The board reuse is provisional and untested on HDI.

**Definition of done (Rev A):** confirm the HD board drives an HDI unit correctly with the HDI wiring
harness. Full closure (an HDI-native board) is a roadmap item, not a Rev A blocker. If an HDI unit shows
power-related faults absent on HD builds, revisit this reuse assumption first.

## Power supply
**DC-8 · P2 · Requirement: REQ-CTL-5 · Specified in [005](005-Electronics-and-Control.md#power)**

The DC supply voltage/current is unspecified.

**Definition of done:** supply voltage and current sized to the stepper driver rail and total motor current,
read from the Motor Control PCB schematic (`Hardware/Motor PCB/`), plus the selected supply part in
[007](007-Bill-of-Materials.md).

## Performance characterization
**DC-9 · P3 · Requirements: REQ-PRE-5/6/7, REQ-WS-6/8**

End-to-end repeatability, rated payload, maximum speed, and the reachable envelope are derived or unknown,
not measured.

**Definition of done:** measured repeatability, payload, speed envelope, and reachable workspace on a
physical Rev A build, replacing derived values and advancing the requirements to `[Specified]`. This is the
main content of roadmap item 1 ([010](010-Versioning-and-Roadmap.md#roadmap)).

## From-scratch calibration files
**DC-10 · P2 · Requirement: REQ-ENV-2, REQ-CTL-6 · Specified in [006](006-Firmware-and-Calibration.md#factory-calibration-procedure)**

A from-scratch build has no factory calibration record (`AdcCenters.txt`, `HiMem.dta`,
`post_cal_info.JSON`) and must run the full factory calibration once. The procedure references calibration
job files (`Setup_Find_Index_Home_HDI*.dde`, `Find_Index_Pulses_HDI.dde`, `PHUI2RCP.js`) that ship in a
factory file bundle, not in the public repo.

**Definition of done:** obtain or reconstruct the calibration job files and the factory file bundle needed
to run [006](006-Firmware-and-Calibration.md#factory-calibration-procedure) end-to-end on a new unit; verify
the resulting `post_cal_info.JSON` gives correct home-finding.
