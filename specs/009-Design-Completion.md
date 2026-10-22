# 009 — Design Completion

This document is the live list of **open design decisions** that must be closed to make Dexter
fully buildable and to advance its `[Provisional]`/`[TBD]` items to `[Specified]`. **It owns design
status.** No other document in the set carries status markers: each states its design as the design of
record and links here where something is still open, so anything not named below is `[Specified]`
([README.md](README.md#design-status)). Each item states the
requirement it must satisfy, its current state, what closing it requires (definition of done), and what it
blocks. These are design tasks owned by this project — not gaps in knowledge about the robot.

Each item covers only the part of a design that is still **open**. The settled design around it is
specified in the document named in the item's header, and is not repeated here.

Priority reflects lead time and build-blocking impact. Close **P1** items before ordering; **P2** before
cutting/committing structure; **P3** are refinements or characterizations.

**Sources of record.** Haddington Dynamics, the originator of this design, is **out of business**. No
further design files, part identities, or physical units can be obtained from them, and no serialized HDI
unit is available to measure. Every item below is therefore closed by one of four routes only: **recovery
from material already in this repository**, a **third-party procurement action**, a **decision authored into
this specification**, or a **measurement on a unit built from it**. The first route is narrow but real: it
closed [DC-10](#from-scratch-calibration-files), whose job files were committed with the design, deleted in
2020, and are restored from this repository's history. Where an item previously named recovery from the
originator, that route is gone and the item is an authoring task — most consequentially
[DC-2](#differential-detail-design), which became a full detail design, authored as OpenSCAD source that is
committed but does not yet reproduce its reference geometry.

| ID | Item | Priority | Blocks | What is still open | Status |
|---|---|---|---|---|---|
| DC-1 | [Strain-wave component set](#strain-wave-component-set) | **P1** | J1–J3 drives | — | `[Specified]` ✔ closed |
| DC-2 | [Differential detail design](#differential-detail-design) | **P1** | J4/J5 wrist | — | `[Specified]` ✔ closed |
| DC-3 | [Wrist reduction ratio](#wrist-reduction-ratio) | P2 | J4/J5 resolution | — | `[Specified]` ✔ closed |
| DC-4 | [Base plate](#base-plate) | P2 | Base mounting | — | `[Specified]` ✔ closed |
| DC-5 | [Link member lengths (L2/L3)](#link-member-lengths) | P2 | Arm Body, End Arm Hub | — | `[Specified]` ✔ closed |
| DC-6 | [Link-length discrepancy (L4)](#link-length-discrepancy-l4) | P2 | Kinematic accuracy | — | `[Specified]` ✔ closed |
| DC-7 | [Motor Control PCB](#motor-control-pcb) | P2 | Electronics | Physical power-on test | `[Provisional]` |
| DC-8 | [Power supply rating](#power-supply) | P2 | Power | — | `[Specified]` ✔ closed |
| DC-9 | [Performance characterization](#performance-characterization) | P3 | REQ-PRE/WS confirmation | The build [009.2](009.2-Test-Build-Manifest.md) specifies | `[TBD]` |
| DC-10 | [From-scratch calibration files](#from-scratch-calibration-files) | P2 | First bring-up | Running the calibration on a build | `[Provisional]` |
| DC-11 | [Procurement data](#procurement-data) | P2 | Ordering, printing | A coupon print | `[Provisional]` |
| DC-12 | [Wrist pulley rework](#wrist-pulley-rework) | P2 | J4/J5 drive parts | — | `[Specified]` ✔ closed |
| DC-13 | [Base height and L1](#base-height-and-l1) | P2 | Kinematic accuracy | — | `[Specified]` ✔ closed |
| DC-14 | [Power inlet mounting](#power-inlet-mounting) | P2 | Harness assembly | A mounting home for the panel receptacle | `[Provisional]` |
| DC-15 | [Arm Body placement](#arm-body-placement) | P2 | Arm Body fits, assembly review | Every part's placement in the Arm Body | `[Provisional]` |
| DC-16 | [Main Pivot placement](#main-pivot-placement) | P2 | Main Pivot fits, assembly review | The code disk's turn and the Pivot cap's, and what the disk's pegs engage | `[Provisional]` |
| DC-400-1 | [End Arm bearing order](#end-arm-bearing-order) | P2 | End Arm Hub assembly | 008.7's step for two MR128s | `[Provisional]` |
| DC-600-1 | [Wave Gen Coupler stub](#wave-gen-coupler-stub) | P2 | J1–J3 drives | — | superseded by [DC-600-2](#strain-wave-drive-spacing) |
| DC-600-2 | [Strain-wave drive spacing](#strain-wave-drive-spacing) | P2 | J1–J3 drives | — | `[Specified]` ✔ closed |

**Completion progress.** DC-1, DC-2, DC-3, DC-4, DC-5, DC-6, DC-8, DC-12, DC-13 and DC-600-2 are closed, and
DC-600-1 is superseded by DC-600-2. Every
other item has been narrowed to the gap named in the table above, and each of those gaps is one of two kinds
of work: **design authored here** (DC-14, DC-15, DC-16, DC-400-1), or **a check on a physical build** (DC-7, DC-9, DC-10, DC-11).
DC-11 owes the model set neither a part nor a link, and all that is left of it is a coupon printed on the
machine that will print the robot. DC-2 — the largest single piece of work in
the set — is authored as parametric OpenSCAD source; all seven recreated parts now render as one clean
solid from measured geometry. Its physical-build checks remain with DC-9.

**DC-4 closed by measurement, and DC-13 closed the height it left.** The hole pattern is recovered exactly
from the CAD part; the model mirror held the previous version's un-bolted base and is corrected in place
([DC-11(i)](#procurement-data)). The J2 height the base stack sets is L1, specified from that stack under
[DC-13](#base-height-and-l1).

**DC-3 closed by decision, and DC-12 realized it.** The tooth-count split is carried by the parts that
`config="revised"` builds; `config="previous"` still builds the previous version's counts.

**DC-11(j) closed by decision, and it spawned DC-14.** Naming the inlet connector settled what plugs into
the robot but not what holds the receptacle: the part chosen is panel-mount and the design has no panel, so
the mounting home is tracked separately rather than left implicit inside a closed sub-item.

---

## Strain-wave component set
**DC-1 · P1 · Requirement: REQ-STR-2 · Specified in [004](004-Mechanical-Architecture.md#base-joints-j1j3-strain-wave-drive)** — ✔ **closed**

**Closed.** The part is identified and quoted. Vendor, part number, price, lead time, the interface
dimensions from the manufacturer drawing, and the cross-check against the printed adapters are specified in
[C-201](007.1-Parts-Catalog.md#c-201--521-strain-wave-component-set). Start this order before anything
else; it carries the longest lead time in the build.

Both halves of the drive are seated, from the shared
[`c201_spline_seat.scad`](../Hardware/Models/600-StrainWave/c201_spline_seat.scad): the circular spline by
the three Stator Holders' `config="revised"`, and the flexspline hub by the Flex Spline Attach's and Flex
Spline Cap's (`#630-005`, `#630-006`).

*Cone Drive (conedrive.com) remains a viable alternate source — same size-14, 52:1 spec, and the printed
adapters' `_ConeDrive`-suffixed CAD names and the maintenance schedule's Cone Drive lubricant
([006](006-Firmware-and-Calibration.md#maintenance)) reflect that this was the design's original target
vendor. HanZhen is the one actually quoted.*

**Definition of done — met:** a named, quotable part whose mating dimensions the printed adapters meet.
The adapters' `config="revised"` is checked by `render.rs --verify` for each group, and
[008.3](008-Assembly.md#0083-harmonic-drive-motors) steps 4–7 and 12 fasten the drive through it. What
remains is the order itself: the set is on 9–12 week lead time, and a physically received unit is confirmed
against the drawing before the final adapters are printed ([007.2](007.2-Printed-Parts.md)). `[Specified]`.

## Differential detail design
**DC-2 · P1 · Requirement: REQ-DOF-1, REQ-STR-3 · Specified in [004](004-Mechanical-Architecture.md#wrist-and-differential-j4j5)** — ✔ **closed**

**Closed by authoring.** There was no source to recover this design from, which is what made it an
authoring task rather than a retrieval one. The in-repo CAD model (`dde/HDIMeterModel.gltf`) carries the
differential *covers* and the kinematic frames but **not** the mechanism internals — which is why the
envelope and axis frames are specified in
[004 § Differential interface](004-Mechanical-Architecture.md#differential-interface) and nothing else is.
The OnShape document exported to
[`Hardware/Models/Reference/onshape-v1/`](../Hardware/Models/Reference/onshape-v1/README.md) is the **v1**
design and holds a single `Import 1` feature pointing at foreign CAD that returns `404`: measurable
reference geometry, not a parametric source. And no physical unit is obtainable — see **Sources of
record** above.

The design that closed it is specified in
[004 § Wrist and differential](004-Mechanical-Architecture.md#wrist-and-differential-j4j5), and its
geometry is owned by the parametric source in
[`Hardware/Models/700-Differential/`](../Hardware/Models/700-Differential/), organized as 004 describes.
The rules that verification is held to, the per-part measured state, and
the reference-export traps that make a naive comparison misleading are in
[`Hardware/Models/README.md`](../Hardware/Models/README.md#verifying-a-recreated-part-against-its-reference).

**Still outstanding under the contract:** `#730-002` Diff Body B is rebuilt from measurement but is not
yet in `DIST_GATES`. Its p95 is inside tolerance in both directions and only the maxima fail, both on the
same unmodelled feature — the chimney base's junction with the chimney cone, filleted on the reference and
sharp in the model. Filleting those four junctions is the remaining work.

**Definition of done — met:** a differential design authored to
[004 § Differential interface](004-Mechanical-Architecture.md#differential-interface), with its **source
geometry committed to this repository** (`.scad`, per the convention in
[`Hardware/Models/README.md`](../Hardware/Models/README.md#moving-to-openscad)) rather than as a mesh
alone, and geometrically verified against its references. The physical checks — J4 and J5 moving without
binding through full travel, the 6-conductor bundle surviving J5's travel, and both code disks reading
cleanly — are [DC-9](#performance-characterization)'s first-build checklist. Until a build passes those,
treat printed fit (press interference, bevel backlash) as tunable via `diff_params.scad`. Status
`[Specified]`.

## Wrist reduction ratio
**DC-3 · P2 · Requirement: REQ-STR-3, REQ-PRE (J4/J5) · Specified in [004](004-Mechanical-Architecture.md#wrist-and-differential-j4j5), [006](006-Firmware-and-Calibration.md#drive-constants-axiscal)** — ✔ **closed**

**Closed by decision.** No surviving record states how the net wrist ratio is decomposed into belt stages,
and none can be obtained (see **Sources of record** above), so the decomposition was authored here. The
two-stage tooth-count split, the measured constraint that forced the differential input pulley to grow,
and the options weighed against it are specified in
[004 § Wrist and differential](004-Mechanical-Architecture.md#wrist-and-differential-j4j5); the belt
lengths that follow from it are in [007.1 § 3](007.1-Parts-Catalog.md#3-belts-and-pulleys). The **net**
ratio was never the open part — it is fixed by the J4/J5 `AxisCal`
([006](006-Firmware-and-Calibration.md#drive-constants-axiscal)).

**Definition of done — met:** the tooth-count decomposition chosen, together with the belt lengths that
follow from it. `[Specified]` for the ratio and the tooth counts. The two belt lengths stay
`[Provisional]`: they stand on a routing no file in this repository places, and are confirmed against the
measured centre distance on the first build before ordering. The parts that must be re-cut to realize the
decomposition are [DC-12](#wrist-pulley-rework); resolution, range and backlash on a physical build are
[DC-9](#performance-characterization). Print the wrist pulleys from `config="revised"` only — see DC-12.

## Wrist pulley rework
**DC-12 · P2 · Requirement: REQ-STR-3 · Specified in [004](004-Mechanical-Architecture.md#wrist-and-differential-j4j5)** — ✔ **closed**

**Closed by authoring.** `config="revised"` builds the tooth counts that
[004 § Wrist and differential](004-Mechanical-Architecture.md#wrist-and-differential-j4j5) specifies.
`config="previous"` builds the previous version's 16T → 90T ‖ 40T → 40T = 5.625:1 train, which does not
match `AxisCal` = 86400 ([006](006-Firmware-and-Calibration.md#drive-constants-axiscal)); it is kept as the
reference the `dist` gates measure against and is not printed. Every printed GT2 tooth ring takes its form
from one shared definition, [`gt2_pulley.scad`](../Hardware/Models/gt2_pulley.scad), which derives tip and
root diameters from the tooth count.

| Part | `previous` | `revised` | Source |
|---|---|---|---|
| `#430-001` External Outer Pulley | 90T | **108T** | [`430-001_ExternalOuterPulley.scad`](../Hardware/Models/400-EndArm/430-001_ExternalOuterPulley.scad) |
| `#430-002` External Inner Pulley | 90T | **108T** | [`430-002_ExternalInnerPulley.scad`](../Hardware/Models/400-EndArm/430-002_ExternalInnerPulley.scad) |
| `#720-003` Diff End Pulley | 40T | **80T** | [`720-003_DiffEndPulley.scad`](../Hardware/Models/700-Differential/720-003_DiffEndPulley.scad) |
| `#720-004` Diff Shaft Pulley | — | **80T** | [`720-004_DiffShaftPulley.scad`](../Hardware/Models/700-Differential/720-004_DiffShaftPulley.scad) |
| `#720-001` Diff Gear Shaft | 40T input band | 40T spline band carrying `#720-004` | [`720-001_DiffGearShaft.scad`](../Hardware/Models/700-Differential/720-001_DiffGearShaft.scad) |
| `#730-001` Diff Body A | measured chamber | opened pulley chamber | [`730-001_DiffBodyA.scad`](../Hardware/Models/700-Differential/730-001_DiffBodyA.scad) |

`#421-001` and `#421-002` stay at **40T** — the Internal pair is what the decomposition holds fixed.

The Diff Gear Shaft's 80T input is the separate ring `#720-004`: the shaft enters Diff Body A through the
6705's Ø25 bore, which an 80T ring cannot pass. The ring keys on the shaft's 40T band as a spline and is
set into the chamber before the shaft ([008.6](008-Assembly.md#0086-differential)). Diff Body A's M3
screws sit outboard of the ring. Each part's dimensions, clearances, and what it keeps from its reference
are stated in its `.scad` file.

[`render.rs --verify`](009.3-Render-Program.md) verifies the revised set: every
revised part renders as one clean solid, the tooth counts are counted on the rendered meshes, the extents
`diff_assembly.scad` places by agree with the renders, and Diff Body A's intersection with `#720-004` is
empty. [`robot_assembly.scad`](../Hardware/Models/robot_assembly.scad) asserts Diff Body A inside the
forearm skin in both configurations.

**Definition of done — met:** the five parts re-cut in `config="revised"`, every part rendering as one
clean solid and previewing without warnings, Diff Body A asserting inside the envelope, the `previous`
config and its `dist` gates untouched, and `diff_assembly.scad` placing the enlarged pulleys without
interference. No file in this repository places the External pulleys against the elbow, so their
clearance there is confirmed on the first build together with the belt lengths
([DC-3](#wrist-reduction-ratio)). `[Specified]`.

## Base plate
**DC-4 · P2 · Requirement: REQ-STR-4, REQ-ENV-5 · Specified in [004](004-Mechanical-Architecture.md#base-j1)** — ✔ **closed**

**Closed.** The robot-side hole pattern, the bolt, and the base stack are specified in
[004 § Base mounting plate](004-Mechanical-Architecture.md#base-mounting-plate); the hardware quantities
are in [007.2](007-Bill-of-Materials.md#0072-base). The plate is `#110-004`, with parametric source and a
render-and-check script at
[`Hardware/Models/100-Base/`](../Hardware/Models/100-Base/110-004_BaseMountingPlate.scad); `render.rs --verify`
gates its eight tapped centres against `110-001_BaseMountBottom.stl`.

**Definition of done — met:** a plate drawing carrying the robot-side hole coordinates, and the resulting
hardware quantities in [007.2](007-Bill-of-Materials.md#0072-base). The load check — that the mounted
plate reacts full dynamic load without walking or tipping — is a measurement on an instrumented unit and
is held by [DC-9](#performance-characterization). `[Specified]`.
## Link member lengths
**DC-5 · P2 · Requirement: REQ-WS-6 · Specified in [003](003-Kinematics.md#link-lengths), [004](004-Mechanical-Architecture.md)** — ✔ **closed**

**Closed.** L2 and L3 are each a carbon-fibre tube bonded between two printed parts. Both cut lengths are
specified in [C-504](007.1-Parts-Catalog.md#c-504--braided-carbon-fibre-square-tube-1) and
[C-505](007.1-Parts-Catalog.md#c-505--braided-carbon-fibre-square-tube-075), each stated against the two
stops it bridges, and listed against their subassemblies in
[007.5](007-Bill-of-Materials.md#0075-arm-body) and [007.7](007-Bill-of-Materials.md#0077-end-arm-hub).
The glue rigs that hold each span at its finished spacing while the epoxy cures are catalogued in
[007.2 § Tooling](007.2-Printed-Parts.md#tooling--glue-rigs).

**Definition of done — met:** both cut lengths closed on measured geometry — L2 stop to stop through
`#410-001`, L3 from the End Arm Hub's spigot against the J3–J4 separation. L3's far end wants neither a
part nor another cut: [DC-11(h)](#procurement-data) closed it on Diff Body A's spigot, which the specified
243.0 mm laps by 15.000 mm. Confirmation on a built arm belongs to
[DC-9](#performance-characterization). `[Specified]`.

## Link-length discrepancy (L4)
**DC-6 · P2 · Requirement: REQ-WS-6 · Specified in [003](003-Kinematics.md#link-lengths)** — ✔ **closed**

**Closed by analysis.** L4 is **39.50 mm**, the along-arm separation of the J4 and J5 stations, specified
together with the convention it follows from in [003 § Link lengths](003-Kinematics.md#link-lengths). Both
records this item was opened against are disposed of there: the firmware file's 59.50 mm is that span's
along-arm and across-arm components added together, and the wiki's pair is version 1's set rather than a
reading of this version. The readings withdrawn on the way, the DH `d` term among them, are recorded in
[CR-3A12](../CHANGES.md#cr-3a12-l4-specified-along-the-arm-the-dh-d-corroboration-withdrawn).

**Definition of done — met:** the datum this item turned on — where L3 lands on the J4 axis — is the J4
station, which the same kinematic chain places 307.500 mm along the arm from J3, reproducing L3 exactly. It
does not depend on what closes the span between the L3 tube and Diff Body A's spigot:
[DC-11(h)](#procurement-data) closed that span on the spigot itself, and put the differential's own J4 axis
on this same station, reaching 307.500 mm from the other direction. What remains is confirmation on a built
arm — measured with [DC-9](#performance-characterization)'s first-build checks — and the one firmware field
that follows from it ([006](006-Firmware-and-Calibration.md#firmware-defaults-defaultsmake_ins)).
`[Specified]`.

## Base height and L1
**DC-13 · P2 · Requirement: REQ-WS-6 · Specified in [003](003-Kinematics.md#link-lengths), [004](004-Mechanical-Architecture.md#base-mounting-plate)** — ✔ **closed**

**Closed by analysis.** L1 is **235.50 mm**, the height of the J2 axis above the mounting face, specified
in [003 § Link lengths](003-Kinematics.md#link-lengths). It is set by the base stack specified in
[004 § Base mounting plate](004-Mechanical-Architecture.md#base-mounting-plate), where every height rests
on a face the next part seats on, the Base Stator Holder's flange among them. The clamp is not in that
stack, so it does not move L1, and the spigot the clamp fits has room for one. The firmware file's
235.20 mm is the CAD chain's station with the flange added, on the CAD's shorter Base Long; it is
superseded, and [006](006-Firmware-and-Calibration.md#firmware-defaults-defaultsmake_ins) carries the line
to write. The evidence, and the doubled clamp withdrawn with it, are recorded in
[CR-3A19](../CHANGES.md#cr-3a19-l1-specified-from-the-base-stack-the-doubled-clamp-withdrawn-6810s-allocated-to-their-seats),
and the flange's place in the stack in
[CR-3A20](../CHANGES.md#cr-3a20-mesh-only-printed-parts-converted-to-openscad).

**Definition of done — met:** L1 specified against a stack of positive stops, and
[003 § Link lengths](003-Kinematics.md#link-lengths) and the `LinkLengths` line reconciled to it.
Confirmation on a built base, and of J3's drive stack, belongs to
[DC-9](#performance-characterization)'s base checklist.
`[Specified]`.

## Motor Control PCB
**DC-7 · P2 · Requirement: REQ-CTL-3, REQ-IF-4 · Specified in [005](005-Electronics-and-Control.md#boards)**

**Open:** a physical power-on test. No purpose-built Motor Control PCB exists, so the previous version's
"green" board is reused. Its devices, its full connector map, and the board landing of every tool conductor
are specified in [005 § Boards](005-Electronics-and-Control.md#boards) and
[005 § Tool interface wiring](005-Electronics-and-Control.md#tool-interface-wiring) from the schematic; that
review is what established the reuse as viable, since the board's connector set is generic and the only
known difference is the harness White-wire reassignment. What has *not* happened is running a unit on it.

**Definition of done:** confirm the inherited board drives a unit correctly with this wiring harness on a
physical power-on test:

1. **Before power.** White lands on `J24` pin 2 with nothing at the tool end driving it; exactly one
   opto-supply jumper is fitted; every motor and opto lead is on the header its joint *name* selects
   ([008.10](008-Assembly.md#00810-wire-harness)).
2. **Under power.** Each of the five joints steps in the commanded direction and its own encoder counts
   with it — the check that the channel map was followed rather than the connector numbering.
3. **Measure the rail at `J23`** while the board runs. The fan is already chosen and spans 4.5–13.8 V
   ([C-716](007.1-Parts-Catalog.md#7-electronics-and-wiring)), so this reading confirms the rail rather than
   selecting the part — but a reading outside that span is a board fault, not a fan question.

Full closure (a purpose-built board) is a roadmap item ([011](011-Roadmap.md)), not a blocker here. If a
unit shows power-related faults absent on earlier builds, revisit this reuse assumption first.
`[Provisional]`.

## Power supply
**DC-8 · P2 · Requirement: REQ-CTL-5 · Specified in [005](005-Electronics-and-Control.md#power)** — ✔ **closed**

**Closed.** The supply rating was open because the board's input ceiling had not been established. It has
been, so the rating, the reasoning behind it, and the under-voltage failure mode are specified in
[005 § Power](005-Electronics-and-Control.md#power), the part is listed in
[007.10](007-Bill-of-Materials.md#00710-wire-harness), and an orderable part meeting that rating is named
in [C-103](007.1-Parts-Catalog.md#c-103--power-supply-36-v-dc). REQ-CTL-5 is `[Specified]`.

*(The in-testing "blue" board would raise the ceiling to 75 V — out of scope for this design.)*

## Power inlet mounting
**DC-14 · P2 · Requirement: REQ-CTL-5 · Specified in [005 § Power](005-Electronics-and-Control.md#power)**

**Open:** where the inlet receptacle mounts. [C-715](007.1-Parts-Catalog.md#7-electronics-and-wiring) is a
**panel-mount** part and the build list has no panel. [008.10](008-Assembly.md#00810-wire-harness) brackets
the Motor Control Board straight to the 1" CF tube, and the only parts in the set presenting a face of that
kind are the 9xx outer skins, which are cosmetic and outside the build list
([007.2](007.2-Printed-Parts.md#not-in-the-build-list)). `#110-004` Base Mounting Plate is machined and
defined by the hole pattern it bolts through
([004 § Base mounting plate](004-Mechanical-Architecture.md#base-mounting-plate)), not a face to cut a
connector into.

⚠️ **The absence is measured, not inferred.** The only candidates by name are `#800-001/002` **Wire Entry
Left / Right** — a mirror pair meeting on a split plane, `#800-001` measuring
**18.000 × 29.730 × 43.713 mm**. Sectioning it along both the split-plane normal and the long axis returns
irregular saddle outlines under **225 mm²**, and no void larger than about **Ø6** — smaller than a 4-pin DIN
body whatever the datasheet cut-out figure proves to be.

**The Wire Entry pair is itself unplaced.** It is listed in
[007.10](007-Bill-of-Materials.md#00710-wire-harness) and in
[007.2](007.2-Printed-Parts.md#wire-harness--00710), and no step in [008](008-Assembly.md) installs either
part — so what the pair is for is as open as where the receptacle goes, and the two close together.

**Definition of done:** the part that carries the receptacle named; its cut-out specified from the
[KPJX-PM datasheet](https://www.kycon.com/Catalog_PDF/KPJX-PM.pdf) — hole size, flange screw pattern, and
the panel thickness the receptacle clamps; a step in [008.10](008-Assembly.md#00810-wire-harness) placing
that part ahead of the wiring step; and a [007.2](007.2-Printed-Parts.md) row if the part is new.
`[Provisional]`.

## Performance characterization
**DC-9 · P3 · Requirements: REQ-PRE-5/6/7, REQ-WS-6/8**

End-to-end repeatability, rated payload, maximum speed, and the reachable envelope are derived or unknown,
not measured. This is inherently a **physical, instrumented-build** item and cannot be closed from the design
record.

**The protocol is written and runnable.**
[009.1](009.1-Performance-Characterization-Protocol.md) specifies every measurement this item owns: the
instrument and the resolution it must reach, the procedure, the rule that decides each result, and the
document each result is written into once taken
([009.1 § 7](009.1-Performance-Characterization-Protocol.md#section-7-closing-out)). What remains is a
build to run it on: [009.2](009.2-Test-Build-Manifest.md) specifies what that build must contain, the
stages it is assembled in, and the three items that must close before it can be completed. Where a requirement is marked for characterization, that protocol states no acceptance
threshold: the measurement is the value.

**Differential first-build checklist (moved here from [DC-2](#differential-detail-design)):** J4 and J5
move without binding through their full travel, the 6-conductor bundle passes the bore and survives
J5's travel, and both code disks read cleanly through their shrouds — J5's off `#710-004` and J4's off
the track on Diff Body B's rim ([DC-11(e)](#the-j4-code-disk-is-missing)). Print-fit parameters (press
interference, bevel backlash) tune in
[`diff_params.scad`](../Hardware/Models/700-Differential/diff_params.scad) if a check fails. Procedure:
[009.1 § 1](009.1-Performance-Characterization-Protocol.md#section-1-differential-first-build-checklist).

**Wrist station (moved here from [DC-6](#link-length-discrepancy-l4)):** confirm L4 on the built arm.
[003 § Link lengths](003-Kinematics.md#link-lengths) specifies it from the CAD kinematic chain, and the
build is the first independent check of it; reconcile 003 and the `LinkLengths` line in
[006](006-Firmware-and-Calibration.md#firmware-defaults-defaultsmake_ins) to what is measured.
**The check is kinematic, not dimensional.** The J4 and J5 axes intersect
([004 § Differential interface](004-Mechanical-Architecture.md#differential-interface)), so no instrument
can be put across them; L4 is observable only as the value that minimizes Cartesian residual, which
requires a calibrated robot rather than an open wrist. Procedure:
[009.1 § 2](009.1-Performance-Characterization-Protocol.md#section-2-wrist-station--l4-measurement), which
also carries the belt centre distances [DC-3](#wrist-reduction-ratio) leaves provisional — those *are*
taken while the arm is apart.

**Base first-build checklist (moved here from [DC-4](#base-plate)):** the mounted plate reacts full
dynamic load without walking or tipping (REQ-ENV-5), bolted to the work surface as
[004](004-Mechanical-Architecture.md#base-mounting-plate) requires — the plate is sized against a
calculated ≈45 N·m overturning moment that an unbolted plate cannot resist, so this check tests the
bolting, not the plate. Measure the **mounting face to J2 axis height** at the same time; it confirms
the L1 that [DC-13](#base-height-and-l1) specified, and the base is only apart once. The same section confirms
J3's drive stack, closed in the model under
[CR-3A19](../CHANGES.md#cr-3a19-l1-specified-from-the-base-stack-the-doubled-clamp-withdrawn-6810s-allocated-to-their-seats),
while that drive is open. Procedure:
[009.1 § 3](009.1-Performance-Characterization-Protocol.md#section-3-base-first-build-checklist).

**Definition of done:** measured repeatability, payload, speed envelope, and reachable workspace on a
physical build, replacing derived values and advancing the requirements to `[Specified]`; plus the
differential and base checklists above, executed per [009.1](009.1-Performance-Characterization-Protocol.md)
and written back through its
[§ 7](009.1-Performance-Characterization-Protocol.md#section-7-closing-out).
This is the main content of roadmap item 1 ([011](011-Roadmap.md)). `[TBD]`.

## From-scratch calibration files
**DC-10 · P2 · Requirement: REQ-ENV-2, REQ-CTL-6 · Specified in [006](006-Firmware-and-Calibration.md#factory-calibration-procedure)**

**Open:** running the calibration on a build. The
[factory calibration procedure](006-Firmware-and-Calibration.md#factory-calibration-procedure) a
from-scratch build must run is driven from two job files. Both are **present**, restored from this
repository's own history, into which they were committed with the design and from which they were deleted
in October 2020 without replacement.

| File | Role | Provenance |
|---|---|---|
| `DDE/InitialCalibration/Setup_Find_Index_Home_HDIv2.dde` | The Step 2 and Step 3 job. Defines every routine those steps call | Added `91a9bbb`, deleted `1b121ce` (2020-10-29), restored |
| `Firmware/dde_apps/Find_Index_Pulses_HDI.dde` | The boot home-finding job Step 3.10 enables in `Firmware/RunDexRun`. Carries the index-eye search and the scan that writes `Firmware/Index_Eye_Data.JSON` | Added `bc42951`, revised `2efc8ee` (2020-10-16), deleted `e4a3a0d` (2020-10-27), restored at the revised content |
| `dde/low_level_dexter/` | The eye-plot and encoder-sweep engine `Jobs → Calibrate Dexter…` drives between those steps | Present |
| `Firmware/dde_apps/PHUI2RCP.js` | Default PhUI startup job, the second boot line Step 3.10 enables | Present |

`Setup_Find_Index_Home_HDIv2.dde` is the file of record: `HDI CAL INSTRUCTIONS- STEP 2.pdf` names it by
that name and sits beside it. Two earlier variants, `Setup_Find_Index_Home_HDI.dde` and
`Setup_Find_Index_Home_HDI_Stable.dde`, are superseded and are not restored. Neither job is a thin wrapper
over the engine: the index-eye search, the scan thresholds, and the home-offset arithmetic are in the job
files, and the engine supplies only the eye plots and the calibration sweep the steps are run between.

`Find_Index_Pulses_HDI.dde` is restored at its **2020-10-16** content. That revision takes the joint
boundaries by running `Defaults.make_ins`, which is what makes the job agree with
[003 § Joint travel limits](003-Kinematics.md#joint-travel-limits); the content it replaces set a narrower
boundary set of its own, inside the job. It also shapes the search move rather than taking the firmware
defaults for it.

**One correction is applied to both files.** Each declared `n_eyes = [200, 180, 157, 113, 100]`, the
per-joint slot counts the eye-to-angle conversion `deg_per_eye = 360 / n_eyes` is built from. J4's term is
**115**, the count [003 § Joint definitions](003-Kinematics.md#joint-definitions) specifies, counted on
`#730-002`'s rim ([the J4 code disk note](#the-j4-code-disk-is-missing)) and carried by `DexRun.c`'s
`joints_slots`. At 113 every J4 eye hop runs 1.8 % long. Recovered SHA-256 `e07b3602…e4e0b0` and
`8fed1af9…e9d6ff`; corrected `b0d9322c…8b88c02` and `34cededd…4b3ec1`.

**Definition of done:** run [006 Steps 2 and 3](006-Firmware-and-Calibration.md#factory-calibration-procedure)
end-to-end on a build from these two files, and confirm the resulting `post_cal_info.JSON` gives correct
home-finding. This is [009.2 stage 6](009.2-Test-Build-Manifest.md), which every measurement needing
trustworthy encoder counts sits behind. `[Provisional]`.

## Procurement data
**DC-11 · P2 · Requirement: buildability · Specified in [007.1](007.1-Parts-Catalog.md), [007.2](007.2-Printed-Parts.md)**

**All eleven sub-items are closed:** the stepper, the fan, the Belt Director type and the print
profile (rows a, b, c, d), the CAD-vs-BOM mismatches and the differential's homeless parts (row e), the
defective, misfiled and superseded model files (rows f, g, i), the L3 tube's far end (row h), the power
supply with its inlet connector (row j), and the Diff Gear Shaft's wall holes (row k). What keeps the item
`[Provisional]` is the print that validates row d's profile. Row e corrected two bearing counts on its way out. **Ordering from
[007.6](007-Bill-of-Materials.md#0076-differential) before those corrections lands two MR128 and one 6703
short at the bench.** **Row h closed by finding that the part it was opened on does not exist** — the span
it was to fill is Diff Body A's own spigot, and what had emptied the span was where the differential was
landed in the arm. **Every part in
[007.1](007.1-Parts-Catalog.md) now resolves to an orderable product with a supplier link.** Two of them —
[C-101](007.1-Parts-Catalog.md#c-101--nema-17-stepper-09step) and
[C-103](007.1-Parts-Catalog.md#c-103--power-supply-36-v-dc) — resolve by decision rather than by recovery,
the design record holding no part number for either; each carries the requirement table a substitute must
meet.

| # | Item | What is open | Consequence if wrong |
|---|---|---|---|
| a | **Stepper motor identity** ([C-101](007.1-Parts-Catalog.md#c-101--nema-17-stepper-09step)) — ✔ **closed by decision** | The legacy list gives only *"25 mm shaft, 0.9°, 0.52 N·m"*, and **no manufacturer part number exists to recover.** The design's own CAD carries the motor as `NEMA17-48H` in seven `Reference/onshape-v1/` assemblies, but as an imported solid — `isStandardContent: false`, a single `documentId`, bodies named `Part 87`…`Part 96` — with no vendor, no number and no geometry in the mirror. That was the last place an identity could have been held, so the item closes the way [row j](#procurement-data) did: **StepperOnline `17HM19-2004S` is adopted as the part of record.** All three interface rows now hold. *Frame:* the three printed Motor End Caps (`#311-001`, `#312-001`, `#511-001`) and the Flex Spline Attach (`#630-005`) independently carry the same face — 4 × Ø3.19 / Ø3.49 at (±15.500, ±15.500), a **31.000 mm square** M3 pattern, around a **Ø22.49** / **Ø23.000** pilot-boss clearance — which is NEMA 17's face pattern to three decimals. *Shaft:* the Wave Gen Coupler `#630-004` takes it in a **Ø5.000 bore 16.0 mm deep**, and the wave generator runs on the coupler's stub rather than the shaft ([DC-600-2](#strain-wave-drive-spacing)), with coupler depth set by a shop gauge ([008.3](008-Assembly.md#0083-harmonic-drive-motors) step 10), so the 1 mm the adopted part gives up against the legacy 25 mm is absorbed. *Body length:* **48 mm, and the earlier reading of this row was wrong.** It said no printed part bounds body length and that the figure was a ceiling checked once on a build. The End Cap does not in fact float on the motor: [008.4](008-Assembly.md#0084-main-pivot) fixes it to the Main Pivot before the motor is epoxied to it, making it a datum, and what body length then sets is the drive's axial station — a two-sided constraint, mechanism in [C-101](007.1-Parts-Catalog.md#c-101--nema-17-stepper-09step). The band on it is an assembly stack-up and is **not** recoverable from the manufacturer's drawing, which fixes the component set's internal geometry and says nothing about how far the mating parts may sit from nominal. *Torque:* **the 0.46 N·m against the legacy 0.52 turns out not to matter at all.** Both exceed what the strain-wave drive will accept: J2 reaches [C-201](007.1-Parts-Catalog.md#c-201--521-strain-wave-component-set)'s start/stop rating at 0.30 N·m of motor torque, so payload is capped by the gearbox well below either motor's stall ([003 § Static gravity torque](003-Kinematics.md#static-gravity-torque)). The delta is margin over a limit neither part is allowed to reach | — |
| b | **Cooling fan** ([C-716](007.1-Parts-Catalog.md#7-electronics-and-wiring)) — ✔ **closed** | The design record gave no fan dimension and no part number, only a printed Fan Bracket (`#800-005`) and a CAD body (`HDI-730-005_Fan`). **Both were measured and they agree on a 40 mm frame.** The CAD body is 40.000 × 40.000 × 10.800 with a Ø37.698 impeller bore and 4 × Ø3.394 holes on a 32.500 mm pitch — a representative envelope of the standard 40 × 40 × 10 fan, whose nominal pattern is 4 × Ø4.3 on 32.0 ± 0.3. The bracket's aperture is **40.000 mm square with R2.000 corners at its seating face, drafting to 38.0 mm** at the far face, which seats that frame and clears that bore. **The bracket carries no fan screw holes** — at a 32 mm pattern the fan's holes fall inside the aperture — so the fan is glued, not bolted. What the bracket *does* carry is two Ø2.99 holes 49.737 mm apart on integral 9 mm standoffs, and the Motor Control PCB carries eight Ø0.125″ holes in two columns **1.95″ = 49.53 mm** apart: the bracket is built for the stood-off position the wiki prescribes, over the PCB rather than on the drivers. Specified as Sunon `MF40101V1-1000U-A99` in [C-716](007.1-Parts-Catalog.md#7-electronics-and-wiring), 12 V per the schematic's `J23` annotation and tolerant of 4.5–13.8 V, so [DC-7](#motor-control-pcb)'s rail reading cannot invalidate the choice | — |
| c | **Belt Director type** ([#210-004/005](007.2-Printed-Parts.md#arm-body-and-belt-directors--0075)) — ✔ **closed** | [007.5](007-Bill-of-Materials.md#0075-arm-body) typed them "Fabricate" against [008.5](008-Assembly.md#0085-arm-body)'s treatment of them as printed bodies. **The model set decides it: they are printed**, and both are in the HD STL print archive ([007.2 § Model file sources](007.2-Printed-Parts.md#model-file-sources)). Each measures as a shouldered sleeve — Ø11.000 × 0.5 mm head, Ø8.000 shank (17.000 Small, 27.000 Large), Ø4.700 blind core. **The measurement also corrects the fit's direction and settles the bearing:** Ø8.000 is the MR128 *bore*, so the bearings go onto the shank and their Ø12 races carry the belt, and the legacy build notes' alternative reading of "MR 125" is excluded — MR125's 5 mm bore will not go on a Ø8.000 shank. Both rows retyped `3D print`; [008.5](008-Assembly.md#0085-arm-body) step 8a now reads *onto* | — |
| d | **Print parameters** ([007.2 § Print profile](007.2-Printed-Parts.md#print-profile)) — ✔ **published** | Layer height, wall count, infill, and orientation were never published — the originals were produced on Markforged equipment. **A profile is now derived from the features the parts have to hold**, each parameter stated with the geometry that sets it: the 0.539 mm land between `#730-002`'s encoder slots sets the nozzle, the Belt Director's 0.500 mm head sets the layer height, and the 2.5–7.0 mm bearing races set perimeter count and orientation. Machine qualification is a coupon, [`fit_coupon.scad`](../Hardware/Models/950-Tooling/fit_coupon.scad), carrying each print-fit class the parts draw; [007.2 § Print fits](007.2-Printed-Parts.md#print-fits) states which fits and why. The slot on it was re-specified under [row e](#procurement-data), the original having been drawn on a strip's section rather than on a slot. **Validating it needs a print**, which is [009.2](009.2-Test-Build-Manifest.md)'s, not this item's | — |
| e | **CAD-vs-BOM mismatches** ([007.2](007.2-Printed-Parts.md#model-vs-bom-discrepancies)) — ✔ **closed** | **The two original mismatches are adjudicated, and neither is a missing row.** (α) `HDI-311-006C_J2StatorHolderCap_ConeDrive` is a real body — 83.032 mm square × 8.100, spanning z 7.900–16.000 in its own frame, stacked on `HDI-311-006B`'s −2.500–7.900 — but the printed `#200-002` runs **z 0–16.000 as one body**, occupying the cap's whole span, with the same internal bore profile (Ø49.98 stator seat low, Ø38 bore high). The CAD's two-body split is a modelling division of one printed part, so the BOM is not short a row. *What the comparison does turn up is that the `_ConeDrive` CAD pair is a different **revision** of `#200-002` from the printed mesh — 4 × Ø3.395 on r 22.000 against the mesh's 4 × Ø3.490 on r 21.500, and a Ø71.5 outer against the mesh's Ø65.0. The mesh is the geometry of record: it is what [C-201](007.1-Parts-Catalog.md#c-201--521-strain-wave-component-set) was cross-checked against in [DC-1](#strain-wave-component-set).* (β) `HDI-610-006_MotorShaftCoupler`'s 4 instances are not a shortfall against `#630-004`'s 3: the CAD body is a 30 × 30 × 12 mm set-screw hub on a Ø5.1 bore and `#630-004` is a 16 × 18.5 × 23 mm wave generator on a Ø5.000 bore — **different parts**. The CAD name serves as a generic motor-shaft hub, and two of its four instances sit at the differential motors, which drive through GT2 pulleys and take no wave generator. The mapping is withdrawn from [007.2](007.2-Printed-Parts.md#model-vs-bom-discrepancies). **Four findings remained after that, all from [DC-2](#differential-detail-design) and all in the differential. All four are now closed, and each of the first three had been looking for the wrong kind of seat.** (ii) *The needle thrust stack — **closed**.* `#710-006` and its two AS0819 races are Ø19 over an Ø8 tube, and no bore in the Split Gear takes them — but a needle thrust bearing does not want a bore. It is a washer stack located by the shaft and carried by two **faces**, and both faces were already there: Diff Body B's Ø8 tube stands **10.423 mm proud** of `#710-001`'s base, whose annulus runs r 5.994–18.500, and the epoxied Diff Keeper closes the other side. The stack takes 4.0 mm of that protrusion and the keeper another 4.0. What hid it is that `diff_assembly.scad` butted the keeper straight onto the base, so the 4 mm the stack occupies read as no gap at all; the file now stands the keeper off and draws it. (iii) *The MR85 — **closed**.* Its **OD 8** is the race that seats, in the top 1.5 mm of `#720-002`'s Ø8 rod bore ([008.6](008-Assembly.md#0086-differential) step 19: 2.5 mm wide, ~1 mm proud). No Ø5 feature exists in the differential because the Ø5 race is the one that leaves it — the 700-series set ends at this part, at the top of the J4 axis. Placing it also **settled the one placement `diff_assembly.scad` had no measurement behind**: the CF rod cannot sit flush with that back face, it stops on the bearing, and the End Pulley moves with it ([008.6](008-Assembly.md#0086-differential) step 20). (iv) *The fifth 6703 — **closed**.* It is an **assembly bearing, not a running one**. `#710-001`'s Ø23 bore (z 4.000–8.750) and `#710-002`'s Ø17 stub (z 4.000–8.253) are that bearing's two race diameters exactly, and the void between them is its width plus 0.253 mm. [008.6](008-Assembly.md#0086-differential) presses it into the Top at step 5, **before** step 8 joins the halves and turns one against the other to clock the teeth; it carries that rotation, and thereafter stands as a ground Ø17/Ø23 concentricity bush. Its races turning together once the brads are driven is the finished state, not a defect. **(i) The five `#720-005` 60 × 4.4 × 1.5 mm CF strakes — closed. The row is withdrawn** from [007.6](007-Bill-of-Materials.md#0076-differential). Three independent records are silent on them: no step in [008.6](008-Assembly.md#0086-differential) places them, the upstream build notes [008](008-Assembly.md) descends from do not list them among the differential's parts, and **no slot in any of the nine printed parts will take one.** That last is the one that decides it, because each of those parts is a recreation gated against its reference mesh and each reproduces the slots it does have — `#710-001`'s three section at exactly 14.000 mm². `#720-001` Diff Gear Shaft is the part whose form invites them, a 60.600 mm printed tube carrying a pulley, which is the problem `#421-002` solves with three bonded strakes; sectioned along its axis it is Ø16.99 over a Ø9.99 bore with nothing cut into either wall. The search was widened before the row was dropped, and the forearm carries three slot families and no fourth: `#710-001`'s three at **5.600 × 2.500 mm**, `#421-002`'s three at **5.000 × 2.000 mm** running its full 72.500 mm, and the Axis Intersection Half's four at 14.546 mm² in section — all of them accounted for by a BOM row. **The cost of being wrong is five cuts, not a purchase** — [C-503](007.1-Parts-Catalog.md#c-503--carbon-fibre-strip-057--177) is cut from stock, and the withdrawal is what lets its stick drop from 48″ to 24″. *Adjacent to it, [008.6](008-Assembly.md#0086-differential) step 11 named the wrong half — the 25 mm strakes go in the **Top** — and is corrected.* *Reaching the slot dimensions also corrected the print-qualification coupon, which had been drawn on the C-503 strip's own section rather than on any slot the robot has ([007.2 § Print profile](007.2-Printed-Parts.md#print-profile)).* **(v) Placing the three closed items exposed a quantity error, and that is the finding with a cost at the bench.** The differential has **four** Ø12 MR128 seats — both ends of `#720-001`, one in each Split Gear half, all four pressed by [008.6](008-Assembly.md#0086-differential) steps 4–6 — against the **2** [007.6](007-Bill-of-Materials.md#0076-differential) listed. The row is corrected to 4 and [C-405](007.1-Parts-Catalog.md#4-bearings) to 14. An earlier pass had met this as a 15-vs-12 conflict and resolved it toward the short rows, re-deriving the aggregate **down** from the figure that was nearer right; [007.1's corrections table](007.1-Parts-Catalog.md#corrections-to-007) now records what actually happened. The 6703s are a separate, smaller case and it closes the same way: [007.6](007-Bill-of-Materials.md#0076-differential)'s five matched the five Ø23 seats in the differential's own parts, while step 2 presses a **sixth** into `#420-001` End Arm Hub that no subassembly counted — [007.7](007-Bill-of-Materials.md#0077-end-arm-hub)'s three are all consumed by the New Belt Pulley at [008.7](008-Assembly.md#0087-end-arm-hub) step 7. A subassembly's row is what its own steps consume, so the sixth belongs to the differential; [007.6](007-Bill-of-Materials.md#0076-differential) reads **6** and [C-404](007.1-Parts-Catalog.md#4-bearings) **11**. **Both counts are corroborated from outside the model set.** The same build notes list *4 MR128* and *6 6703* among the differential's parts — the pair of figures counting seats arrives at, reached independently, in the document [008.6](008-Assembly.md#0086-differential)'s steps descend from. The two BOM rows had been short against their own source all along | Two MR128 and one 6703 short at the bench |
| f | **Defective model file** (`#710-002`, [007.2](007.2-Printed-Parts.md#differential--0076)) — ✔ **closed** | The file was **~1000× oversize** (exporter unit slip; its header read `STLB ASM 217.00.00.5800` vs neighbours' `220.00.00.0000`). The factor was detected as **exactly 1/1000** (`scadmesh scale --ref-dim 23.0`, zero residual against the 6703 seat), applied in place, and the corrected part verified against its mates: Ø23.000 6703 seat, Ø12.000 MR128 seat, Ø28.06 press bore receiving the Split Gear Top's Ø28.00, brad circle matching the Top's windows. Old SHA-256 `c20e30d1…a853af`, corrected `e746f42f…9cb3662`. The part now also has parametric source (`710-002_SplitGearBottom.scad`, [DC-2](#differential-detail-design)) | — |
| g | **Misfiled model file** (`#200-001` Arm Body) — ✔ **closed** | `200-ArmBody/200-001_ArmBody.stl` held `ArmBodyFrontStrakeMED.stl` byte for byte (SHA-256 `c991b4e5…dcee1b`, 20 triangles, 4.9 × 9.9 × 32 mm) — the mirror had matched the archive's `ArmBody*` name prefix rather than the part. Replaced with `ArmBodyWEncode.stl` from [thing:3781990](https://www.thingiverse.com/thing:3781990) (SHA-256 `ad4e940d…1d86b4`, 11,946 triangles, 99.6 × 108.1 × 98.0 mm), confirmed to be the part by its 29 × 29 mm L2 tube socket agreeing with `HDI-310-001_ArmBody`'s to 0.011 mm ([DC-5](#link-member-lengths)). Unlike row f this was invisible to every check the manifest makes — the file was well-formed and the right size for *a* part. [Models § Known defects](../Hardware/Models/README.md#known-defects) records what that implies for the rest of the mirror | The largest printed part in the robot unprintable, and L2's seat depth uncheckable |
| h | **L3's far end** — ✔ **closed** | **The part this row was opened on does not exist, and neither does the span.** [C-505](007.1-Parts-Catalog.md#c-505--braided-carbon-fibre-square-tube-075) puts the L3 tube's far face 36.000 mm short of the J4 axis, and no file presented the face it butts. What presents it is **Diff Body A's own spigot** — a 20 × 20 R4 plug matching the End Arm Hub's in section and bore ([004 § Differential interface](004-Mechanical-Architecture.md#differential-interface)). The same plug stands at both ends of the one tube, so that end of Body A points back down the forearm; and the Diff End Pulley faces the elbow pulleys the belt reaches it from, which sends the J4 axis along world z. **That settles the question this row was blocked on, in [003 § DH model](003-Kinematics.md#denavithartenberg-model)'s favour** — J4 does run parallel to J3 — and it settles the quarter turn about that axis, which neither record addressed and which is what the spigot fixes. [004](004-Mechanical-Architecture.md#differential-interface)'s gripper-cover argument is withdrawn there, along with the four readings it produced. **What emptied the span was the landing, not a missing part.** `robot_assembly.scad` first put the differential's centre on the **J5** station, which stands the differential's own J4 axis **347.000 mm** from J3 against the **307.500 mm** [003 § Link lengths](003-Kinematics.md#link-lengths) specifies and the firmware carries to the micron. One axis crossing cannot sit at both wrist frames 39.500 mm apart, and the J5 frame is the one that is not on its axis. **Landed on the J4 axis at the J4 station, the specified 243.0 mm cut laps the spigot by 15.000 mm**, leaving 6.000 mm of its 21.000 mm standing proud of the tube's end, against the 16.0 mm of lap the same tube takes on the same plug at the hub. **Four readings fix that landing and not one of them is a bounding box.** (i) *The link length* — J3 → J4 measures 307.500 mm with the differential there and 347.000 mm without it. (ii) *The cut* — 243.0 mm laps 15.000 mm one way and falls 24.500 mm short the other, and it is fixed at the near end by the hub's counterbore, so it cannot absorb the difference. (iii) *The covers* — Body A falls inside `ENV_L3_SKIN` with 6.5335 mm to spare, where the other landing overruns that box by 30.500 mm and carries the differential into the gripper's. (iv) *The glue rig* — `950-Tooling/GlueRig_EndArmHubToDiff_A`/`_B` is catalogued at [007.2 § Tooling](007.2-Printed-Parts.md#tooling--glue-rigs) as holding the End Arm Hub to the differential over `#420-003`, and it carries one precision register at each end. At the hub: a **Ø22.971 boss** with four **Ø1.994** pins on r = 14.500, entering the hub's **Ø22.990** J3 bore and its four Ø4.995 holes at (±10.252, ±10.253). At the differential, **307.500 mm** away on a parallel axis: a **Ø16.971 boss**, which is a 6703's bore — the two bearings [007 § Aggregate](007-Bill-of-Materials.md#aggregate-hardware-quantities-whole-robot) carries as *(+2 glue rig)* — whose Ø23 outer race then seats in Diff Body A's Ø23 6703 bore on the J4 axis. **The rig measures J3 to J4 directly, and as first exported it read 309.500 mm**: that excludes the 347.000 mm landing, missing it by 37.500 mm, and sits 2.000 mm beyond the 307.500 mm the kinematic records hold — one twentieth of the difference this reading has to decide, and it changes nothing this reading settles. The kinematic records are the design of record, so the jig is what moves: [CR-3A17](../CHANGES.md#cr-3a17-dc-11-resolved-to-a-coupon-print) shortens `GlueRig_EndArmHubToDiff_B` by 2.000 mm across a prismatic stretch of its trough, clear of both registers and of the pair's lap, and the rig now holds the span [003 § Link lengths](003-Kinematics.md#link-lengths) specifies. The rig settles one thing on its own: **a jig that holds exactly two parts across this tube says the bonded span has exactly two ends**, which is what an intermediate part would contradict. **Withdrawn with the row:** the void `robot_assembly.scad` drew on the tube's section, [C-505](007.1-Parts-Catalog.md#c-505--braided-carbon-fibre-square-tube-075)'s 283.5 mm alternative cut, and [004](004-Mechanical-Architecture.md#differential-interface)'s reading that the differential centre lands on the J5 station | A forearm built 39.500 mm long, around a part that does not exist |
| i | **Superseded model file** (`#110-001` Base Mount Bottom) — ✔ **closed** | `100-Base/110-001_BaseMountBottom.stl` held the **previous version's un-bolted base**: 85.000 × 85.000 × 98.000 mm against the CAD part's 150 × 150 × 98, with **no fastener features at all**. Its six 60°-spaced features decompose under `scadmesh arcs` into six straight lines — 12.94 × 3.82 mm bonding pockets for the `#110-003` CF strakes — identifying it as exactly the *"6 legged aluminum strake base"* the wiki says the bolted base replaced ([010](010-Versioning.md#1-version-lineage)). Replaced from the CAD model's `BaseMountBottom_Bolted v9` (SHA-256 `ab267f07…c00d2bde`, 25,952 triangles, 150.000 × 150.000 × 98.000 mm), which carries the 8-hole robot-side pattern [DC-4](#base-plate) was opened to recover. Like row g this passed every check the manifest makes — the file was well-formed and plausible for *a* base | [DC-4](#base-plate) unclosable, and a base printed without the mounting holes the design bolts through |
| j | **Power supply and its mating connector** ([C-103](007.1-Parts-Catalog.md#c-103--power-supply-36-v-dc), [C-715](007.1-Parts-Catalog.md#7-electronics-and-wiring)) — ✔ **closed** | The design record named no supply model — the wiki gives only *"standard laptop power bricks ... rated at 36 volts, 4 amps"* — so [DC-8](#power-supply) closed on a rating and left the part open. C-103 then specified the supply as carrying a **DC barrel plug** while recommending MEAN WELL `GST160A36-R7B`, whose standard `-R7B` plug is a **KYCON `KPPX-4P` equivalent 4-pin DIN**: the two cannot mate, and C-715 was unorderable in consequence. **Closed by decision.** `GST160A36-R7B` is the supply of record and the inlet is its snap-and-lock mate, KYCON **`KPJX-PM-4S`** (48 V DC, 7.5 A per pin), specified in [005 § Power](005-Electronics-and-Control.md#power). A barrel inlet is rejected for the reason [005 § Power](005-Electronics-and-Control.md#power) gives. Two consequences follow — the inlet wire goes to **18 AWG** ([C-714](007.1-Parts-Catalog.md#7-electronics-and-wiring)), C-715's datasheet specifying #18 for its power pins where the previous version's 24 AWG is undersized for a 4 A rail; and an **IEC C13 line cord** ([C-718](007.1-Parts-Catalog.md#7-electronics-and-wiring)) joins the bill, the adapter having a C14 inlet and shipping without one | — |
| k | **The Diff Gear Shaft's wall holes** (`#720-001`) — ✔ **closed by decision** | The reference mesh carries twelve Ø0.2 × 60.6 mm through-holes in the shaft wall. They are real voids, not a mesh artifact, and they are unbuildable ([`Hardware/Models/README.md`](../Hardware/Models/README.md#verifying-a-recreated-part-against-its-reference) holds the measurement). No part in the differential uses them, and no [008.6](008-Assembly.md#0086-differential) step touches them. **The built shaft is solid.** [007.2](007.2-Printed-Parts.md#differential--0076) states it as the part's print instruction, and [`720-001_DiffGearShaft.scad`](../Hardware/Models/700-Differential/720-001_DiffGearShaft.scad)'s `wall_holes` flag defaults off to match. The harness gates the solid render against the reference as it stands: [`render.rs --verify`](009.3-Render-Program.md) masks the ring the holes occupy, and with the holes off no check moves beyond the part's two stated tip-blunt deviations | A shaft printed in whichever state the renderer was last left in, and a slicer deciding a design question |

### The J4 code disk is missing

**Closed — it was never missing.** J4 is read off a feature integrated into another part, which was one of
the two possibilities this item was opened to decide between. Every arm joint carries an output-side
optical code disk whose slot count is specified in
[003 § Joint definitions](003-Kinematics.md#joint-definitions), and each count was **counted on its model**
while closing [DC-2](#differential-detail-design):

| Joint | Slots specified | Part | Slots counted |
|---|---|---|---|
| J1 Base | 200 | `#100-002` Base Code Disc | **200** ✔ |
| J2 Pivot | 180 | `#300-002` Pivot Code Disk | **180** ✔ |
| J3 End | 157 | `#410-003` End Arm Code Disk | **157** ✔ |
| J4 Angle | **115** | `#730-002` Diff Body B — the track on its mating rim, not a disk | **115** ✔ |
| J5 Rotate | 100 | `#710-004` Rotate Code Disk | **100** ✔ |

Four of the five are separate printed disks; J4's is a ring of 115 radial slots cut clean through Diff Body
B's Ø58.985 mating rim, on an exact 360/115 pitch, r 24.500–28.800, 0.800 mm wide, first slot at 2.270°.
Body B pivots on the J4 axis inside Diff Body A, so a track on that rim reads J4 directly and needs no part
of its own. The earlier reading here — that no part carries 115 slots — was measured on the *disks*; the
track had been found on Body B's rim and recorded in
[`730-002_DiffBodyB.scad`](../Hardware/Models/700-Differential/730-002_DiffBodyB.scad) during DC-2, but
labelled there as J5's, which is `#710-004`'s 100.

**The candidate nominated here was the wrong part.** `KP0089-01_DiffA1CodeDiskFine` in
[`Reference/onshape-v1/parts-step/`](../Hardware/Models/Reference/onshape-v1/) measures **99 slots on a
3.600° pitch — a 100-count pattern**, so it is v1's ancestor of `#710-004`, J5's disk, not J4's. The v1
part that does carry the 115 pattern is `KP0079-01_DiffA2CodeDiskEndStopFilled`, a combined code disk and
end stop; it is superseded and has no HD equivalent as a part, its track having moved onto Body B's rim.
Its other revision is kept as
[`Reference/superseded/DiffA2CodeDiskEndStop.dwg`](../Hardware/Models/Reference/superseded/). The A1/A2
names in that set do not follow [003](003-Kinematics.md#joint-definitions)'s DiffA1 = J4, DiffA2 = J5: the
part named A2 carries J4's count and the part named A1 carries J5's. Trust the counts, not the v1 names.

**What this leaves open:** v1 gave J4 a hard end stop — `KP0079`'s slotted arc spans 287°, closed by two
tabs — and Body B's track runs the full 360° with no such feature, so **the HD design has no modelled
mechanical limit for J4**. Whether that limit moved to another part or was dropped is not settled here.
The "both code disks read cleanly" item in the
[DC-9 differential checklist](#performance-characterization) is now runnable.

### The model archives are a single point of failure

**Closed.** The archives are mirrored in [`Hardware/Models/`](../Hardware/Models/README.md), so no upstream
host is load-bearing, and [007.2 § Printed parts](007.2-Printed-Parts.md#printed-parts) links every row to
the file the mirror holds that part as, so reaching a part's geometry no longer means matching part numbers
by eye across two documents.
[`Hardware/Models/PART-INDEX.md`](../Hardware/Models/PART-INDEX.md) owns which file is which part and the
print list's `Model` column is generated from it.

### Most of the robot is mesh-only

**Open, and it does not gate this item.** Changing an HD part today means re-deriving it from a mesh, which
limits editing the design rather than ordering or printing it — this item's requirement is buildability,
and a mesh prints.
[`Hardware/Models/README.md` § Formats](../Hardware/Models/README.md#formats-and-what-can-actually-be-edited)
owns what each format allows. The OpenSCAD conversion has started where it mattered most: the differential
set has full parametric source ([DC-2](#differential-detail-design)), every part in `100-Base`,
`200-ArmBody`, `300-Pivot`, `400-EndArm`, `500-ExternalGear` and `600-StrainWave` has it ([CR-3A20](../CHANGES.md#cr-3a20-mesh-only-printed-parts-converted-to-openscad)), and the `openscad-tools`
measurement utilities built for them apply to every remaining mesh-only part.

**Definition of done:** (a) **done** — `17HM19-2004S` is the part of record in
[C-101](007.1-Parts-Catalog.md#c-101--nema-17-stepper-09step) (see row a), its 48 mm body read as the
drive's axial stack-up on a built joint by [009.2](009.2-Test-Build-Manifest.md); (b) **done** — the fan is
specified in [C-716](007.1-Parts-Catalog.md#7-electronics-and-wiring) (see row b); (c) **done** — both rows
retyped `3D print` (see row c); (d) the published [print profile](007.2-Printed-Parts.md#print-profile)
validated on its coupon, which is a print and therefore [009.2](009.2-Test-Build-Manifest.md)'s;
(e) **done** — all four differential findings adjudicated against the model set, two bearing counts
corrected with them (see row e); (f) **done** — the rescaled, mate-verified STL and its parametric source
are committed (see row f); (g) **done** — the Arm Body's own mesh is in the mirror and what the misfiling
implies for the rest of it is recorded (see row g); (h) **done** — the span is closed by geometry already
in the model set and no part or cut length is owed (see row h); (i) **done** — the bolted base is in the
mirror, which is what let [DC-4](#base-plate) close (see row i); (j) **done** — the supply and the inlet it
mates carry part numbers, the receptacle's mounting home tracked as [DC-14](#power-inlet-mounting) (see
row j); (k) **done** — `#720-001` prints solid, and the `wall_holes` default matches (see row k); and
**done** — the model mirror is complete and reachable per part from the print list (see
[the archives](#the-model-archives-are-a-single-point-of-failure)). **One item remains, and it is not a
design question**: the coupon print. It does not block starting the long-lead items in
[DC-1](#strain-wave-component-set). `[Provisional]`.

## Arm Body placement
**DC-15 · P2 · Requirement: REQ-STR-5 · Specified in [008.5](008-Assembly.md#0085-arm-body)**

**Open:** where each part of the Arm Body stands. [008.5](008-Assembly.md#0085-arm-body) orders the
operations and says what goes into what, and from which side ("front to back", "back to front"), but states no
position along an axis for any part and ties neither direction to the frame of a model. No document owns one. The model set has no assembly
for the arm body from CAD to confirm one against, so every part of
[`armbody_assembly.scad`](../Hardware/Models/200-ArmBody/armbody_assembly.scad) is placed by a feature it
carries, as an inference to be confirmed or replaced:

- the Pivot Stator Holder's height in the bore and the span its flange stands over the Arm Body's top face;
- the four Stator Balancers' position in the K1 slots, and the lip that bears on the holder;
- the 6810's seat: 008.5 step 1 presses it "~38 mm" into the Arm Body, and the Arm Body's L1 ledge seats it at
  z -7 .. 0;
- each Belt Director's end-for-end direction and its MR128s' seats, in columns A, B and C, and the Belt Director
  Caps on the upper bearings' inner races, the shanks ending flush with the bearings (B's lower plate is extended 0.7 so B and C stand as far apart);
- the idler column D: the Idler Plug through both plates with its head on the upper one, the MR85 on it and the
  Belt Director Pulley between the plates;
- the Calibration Arrows (`#200-006`), for which no document says where they stand.

**Definition of done:** each part's placement stated in [008.5](008-Assembly.md#0085-arm-body) or
[004](004-Mechanical-Architecture.md) by the feature it is located from; the model's inferences replaced by
those values; and the fits the part headers still defer (the Calibration Arrows' and the flap's holes) settled in the parts.
`[Provisional]`.

## Main Pivot placement
**DC-16 · P2 · Requirement: REQ-STR-5 · Specified in [008.4](008-Assembly.md#0084-main-pivot)**

**Open:** where three of the Main Pivot's parts stand about their axes. [008.4](008-Assembly.md#0084-main-pivot)
says what goes onto what but fixes no turn about J2 and no part's position along it, and the model set has no
assembly for the pivot from CAD to confirm one against. The seats along each axis follow from the parts'
own faces, so [`pivot_assembly.scad`](../Hardware/Models/300-Pivot/pivot_assembly.scad) places each part
by a feature it carries; these placements are inferences to be confirmed or replaced:

- the Pivot Code Disk's turn about J2, which also places its two pegs. Its hub's top seats on the Main
  Pivot's +X face, but 008.4 step 5 fixes no turn, so the model keeps the disk's own frame;
- what the disk's pegs and their Ø1 holes engage. No document names a mate for them, and the Main Pivot's
  +X face has no socket, so in the model the pegs' tops bear on that face in the hub's plane;
- the Pivot Motor End Cap's turn about J2. Step 6 orients the cap's notch "toward the motor-wire hole".
  The cap's four motor holes (Ø3.2, counterbored Ø6 on `#312-001`) line up with the Main Pivot's H5
  (Ø3.0, an M3 tapping size) only at 45° + k·90°, so the model takes 45°, the turn nearest H2. That leaves
  the wire channel's centre 6.2° short of H2's, still open into the Ø12 hole. 008.4 names no screws
  into H5, so whether they run there is still to be confirmed;
- the Base Motor End Cap's turn about J1. Step 6 leaves it free, so the model takes the turn that
  [`base_assembly.scad`](../Hardware/Models/100-Base/base_assembly.scad) gives the pivot, which keeps its
  motor holes on H4.

**Definition of done:** the disk's and the Pivot cap's turns stated in [008.4](008-Assembly.md#0084-main-pivot)
by the feature each is located from, and the pegs' mate named; the model's inferences replaced by those
values. `[Provisional]`.

## End Arm bearing order
**DC-400-1 · P2 · Requirement: buildability · Specified in [008.7](008-Assembly.md#0087-end-arm-hub)**

**Open:** 008.7 fits two MR128s at a step that can no longer reach their seats.
[`endarm_assembly.scad`](../Hardware/Models/400-EndArm/endarm_assembly.scad) places each part by a
feature it carries, and shows:

- step 20 presses an MR128 into the End Arm Hub Cap (`#420-002`) after step 19 has snapped the Cap on,
  but the Cap's MR128 pocket opens into the hub, so that bearing goes into the Cap before step 19;
- step 20 presses the other MR128 into "the Internal Outer Pulley end", but the Internal Outer Pulley
  (`#421-001`) has no Ø12 seat. The Internal Inner Pulley (`#421-002`) has one, and it faces `#421-001`
  across the first Pulley Spacer, so that bearing goes in before step 10 joins the two pulleys.

**Definition of done:** step 20 moved before step 10, naming the Internal Inner Pulley, or 008.7 otherwise
reordered so that each MR128 reaches its seat. `[Provisional]`.

## Wave Gen Coupler stub
**DC-600-1 · P2 · Requirement: buildability · Specified in [007.1 C-201](007.1-Parts-Catalog.md#c-201--521-strain-wave-component-set)** — **superseded by [DC-600-2](#strain-wave-drive-spacing)**,
which replaces the hex body and solid stub decided below. The finding stands.

**Found:** the Wave Gen Coupler's (`#630-004`) reference stub does not enter C-201's wave generator. It is
Ø10.0 with a key 3.0 wide whose flat top stands 6.0 from the axis: a Cone Drive wave generator's input.
C-201's takes a Ø6H7 bore with two set screws. Earlier readings took the key's 6.0 for a Ø6 stub; the
reference has no Ø6 feature. The motor's Ø5 shaft ran through the stub, and a Ø6 stub has no room for it.

**Decided:** `config="revised"` draws a solid Ø6 stub at the press fit, as long as the wave generator's
bore is deep, and the shaft bore stops in the hex body.
[`630-004_WaveGenCoupler.scad`](../Hardware/Models/600-StrainWave/630-004_WaveGenCoupler.scad) owns the
dimensions and where each is taken from. `config="previous"` keeps the reference's stub. Superseded.

## Strain-wave drive spacing
**DC-600-2 · P2 · Requirement: buildability · Specified in [007.1 C-201](007.1-Parts-Catalog.md#c-201--521-strain-wave-component-set)** — ✔ **closed by decision**

**Found:** with [DC-600-1](#wave-gen-coupler-stub)'s solid stub seated in the wave generator's hub, the
coupler's blind bore ended about 1.5 short of the tip of C-101's 24 mm shaft
([007.1 C-101](007.1-Parts-Catalog.md#c-101--nema-17-stepper-09step)), so either the shaft was cut or the
coupler stood off it. The wave generator's Ø6 bore runs through its whole hub.

**Decided (reviewer):** keep the standard shaft, uncut. The drive stands further from its motor, partly by
moving the motor away from the drive, its Motor End Cap's seat deeper (`#311-001`, `#312-001`, `#511-001`),
and partly by moving the drive away, the Flex Spline Attach (`#630-005`) thicker and the Stator Holder's
floor further along it (`#110-002`, `#511-002`; for J2's `#200-002`, see below), until the coupler's blind bore, 1.0 past the shaft's tip, and its floor
end the running clearance under the wave generator. The Wave Gen Coupler (`#630-004`) is one round piece
from over the motor's boss, through the Attach, the flexspline's hub and the Flex Spline Cap, to just under
the wave generator, with a Ø6 stub up the wave generator's bore past its two set screws. An M3 screw
through a nut captured in the coupler grips the shaft's flat, reached through an access hole in the
Attach, so the coupler can be taken off for maintenance. The Attach loses its spigot, since the nubs
centre the hub, and its shaft ridge; the Cap's bore opens to pass the coupler.

**Sized:** the spacing is **5.0 mm: 1.0 by moving the motor and 4.0 by moving the drive, in every joint**.
The bore rule alone needs 3.0 in J1 and J2 and 3.7 in J3, whose hub face stands 0.687 nearer its motor.
The grip sets the rest: its nut must sit on the shaft's flat, which starts 9.0 above the motor face, and
the coupler's grip, which holds the nut and is wider than the hub's Ø11 bore, must stand the running
clearance under the hub face in J3. J3 sets the split: its motor can move at most about 1.2 before the
motor's Ø50.8 corners reach the lower 6810's Ø50 bore, so its Stator Holder seats the spline's flange on
a boss inside the Mount Top's 6810 ([`exgear_assembly.scad`](../Hardware/Models/500-ExternalGear/exgear_assembly.scad)
owns J3's figures), and the reviewer chose the same split for J1 and J2. Three consequences follow:

- **The screw is an M3 × 4 grub screw.** A bolt's head on the grip would sweep through the six M2 hub
  screws on Ø17 as the shaft turns.
- **The coupler goes on the shaft before the Attach goes on the motor** ([008.3](008-Assembly.md#0083-harmonic-drive-motors)):
  its grip cannot pass the hub's bore. It passes inside the M2 screws' heads as the Attach goes on.
- **J2's holder floor does not move toward the opening.** With C-201 in place of the reference's drive,
  the reference's `#200-002` floor stood 4.3 short of where the spline's flange lands, before any
  spacing. The 4.0 takes up most of that, so the revised floor is 0.3 deeper than the reference's and
  the wave generator's hub stays 0.3 inside the recess.

[`630-004_WaveGenCoupler.scad`](../Hardware/Models/600-StrainWave/630-004_WaveGenCoupler.scad) owns the
coupler's dimensions. [`630-005_FlexSplineAttach.scad`](../Hardware/Models/600-StrainWave/630-005_FlexSplineAttach.scad)
owns the Attach's, and asserts the coupler's running clearances and the deepest `hub_drop` they allow.
[`base_assembly.scad`](../Hardware/Models/100-Base/base_assembly.scad) asserts J1's closure and the
coupler's clearances to the wave generator, and
[`armbody_assembly.scad`](../Hardware/Models/200-ArmBody/armbody_assembly.scad) asserts J2's.
`[Specified]`.
