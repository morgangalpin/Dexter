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
unit is available to measure. Every item below is therefore closed by one of three routes only: a
**third-party procurement action**, a **decision authored into this specification**, or a **measurement on
a unit built from it**. Where an item previously named recovery from the originator, that route is gone and
the item is an authoring task — most consequentially [DC-2](#differential-detail-design), which became a
full detail design, authored as OpenSCAD source that is committed but does not yet reproduce its
reference geometry.

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
| DC-9 | [Performance characterization](#performance-characterization) | P3 | REQ-PRE/WS confirmation | Instrumented build | `[TBD]` |
| DC-10 | [From-scratch calibration files](#from-scratch-calibration-files) | P2 | First bring-up | Two job wrappers | `[Provisional]` |
| DC-11 | [Procurement data](#procurement-data) | P2 | Ordering, printing | Five unpinned part identities | `[Provisional]` |
| DC-12 | [Wrist pulley rework](#wrist-pulley-rework) | P2 | J4/J5 drive parts | Re-cutting five parts to the specified counts | `[Provisional]` |
| DC-13 | [Base height and L1](#base-height-and-l1) | P2 | Kinematic accuracy | Mounting face to J2 on a build | `[TBD]` |
| DC-14 | [Power inlet mounting](#power-inlet-mounting) | P2 | Harness assembly | A mounting home for the panel receptacle | `[Provisional]` |

**Completion progress.** DC-1, DC-2, DC-3, DC-4, DC-5, DC-6, and DC-8 are closed. Every other item has been
narrowed to the single remaining gap named in the table above, and each of those gaps is one of three kinds
of work: **procurement** (DC-11), **design or reconstruction authored here** (DC-10, DC-12, DC-14), or **a
check on a physical build** (DC-7, DC-9, DC-13). DC-2 — the largest single piece of work in the set
— is authored as parametric OpenSCAD source; all seven recreated parts now render as one clean solid from
measured geometry. Its physical-build checks remain with DC-9.

**DC-4 closed by measurement, and it spawned DC-13.** The hole pattern is recovered exactly from the CAD
part; the model mirror held the previous version's un-bolted base and is corrected in place
([DC-11(i)](#procurement-data)). The measured base chain gives a J2 height the firmware's L1 does not
agree with, which is tracked separately rather than left implicit inside a closed item.

**DC-3 closed by decision, and it spawned DC-12.** Choosing the wrist's tooth-count split settled the
ratio but did not re-cut the parts that carry it, and measurement showed those parts still hold the
previous version's counts — so the authoring work that follows is tracked separately rather than left
implicit inside a closed item.

**DC-11(j) closed by decision, and it spawned DC-14.** Naming the inlet connector settled what plugs into
the robot but not what holds the receptacle: the part chosen is panel-mount and the design has no panel, so
the mounting home is tracked separately rather than left implicit inside a closed sub-item.

---

## Strain-wave component set
**DC-1 · P1 · Requirement: REQ-STR-2 · Specified in [004](004-Mechanical-Architecture.md#base-joints-j1j3-strain-wave-drive)** — ✔ **closed**

**Closed.** The part is identified, quoted, and dimensionally confirmed against the printed adapters it
mates to. Vendor, part number, price, lead time, the interface dimensions from the manufacturer drawing,
and the cross-check against the built STL geometry are all specified in
[C-201](007.1-Parts-Catalog.md#c-201--521-strain-wave-component-set). Start this order before anything
else; it carries the longest lead time in the build.

*Cone Drive (conedrive.com) remains a viable alternate source — same size-14, 52:1 spec, and the printed
adapters' `_ConeDrive`-suffixed CAD names and the maintenance schedule's Cone Drive lubricant
([006](006-Firmware-and-Calibration.md#maintenance)) reflect that this was the design's original target
vendor. HanZhen is the one actually quoted.*

**Definition of done — met:** a named, quotable part whose mating dimensions are confirmed against the
printed adapters. What remains is the order itself: the set is on 9–12 week lead time, and a physically
received unit is confirmed against the drawing before the final adapters are printed
([007.2](007.2-Printed-Parts.md)). `[Specified]`.

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
[DC-9](#performance-characterization). **Do not print the four driven pulleys from the HD model set as
they stand** — see DC-12.

## Wrist pulley rework
**DC-12 · P2 · Requirement: REQ-STR-3 · Specified in [004](004-Mechanical-Architecture.md#wrist-and-differential-j4j5)**

**Open:** the geometry that realizes the tooth-count decomposition specified in
[004 § Wrist and differential](004-Mechanical-Architecture.md#wrist-and-differential-j4j5). The counts are
decided; the parts still carry the previous version's, and two of them are load-bearing structure rather
than plain pulleys, so this is authoring work rather than a parameter edit.

⚠️ **The shortfall is measured, not inferred.** Counting teeth on the HD models themselves
(`scadmesh teeth`, on slices through each tooth band) returns **90T/90T** on the External pair (tip
Ø 56.2 mm), **40T/40T** on the Internal pair (24.4 / 24.8 mm) and **40T** on both differential inputs
(24.8 mm), against the bought 16T motor pulley. The train as modelled is therefore
16T → 90T ‖ 40T → 40T = **5.625:1**, the previous version's figure — matching the wiki's `Joints.md`
(`90 / 16`) and its `AxisCal` of 36000. **Printing this set and running it against `AxisCal` = 86400 would
scale every commanded J4/J5 angle by 2.4.**

| Part | From | To | What the change costs |
|---|---|---|---|
| `#430-001` External Outer Pulley | 90T | **108T** | Tip Ø 56.8 → 68.2. Free-standing printed pulley; re-cut the ring on the existing hub |
| `#430-002` External Inner Pulley | 90T | **108T** | Same, on the strake-tube hub |
| `#720-003` Diff End Pulley | 40T | **80T** | Tip Ø 25.0 → 50.4 on a part `dist`-gated under DC-2 |
| `#720-001` Diff Gear Shaft, integrated band | 40T | **80T** | Same, on the part that is *also* the J4 pivot axle |
| `#730-001` Diff Body A | — | pulley chamber | Its wall sits at r ≈ 15.5 mm and must open to about r 27, widening the body ≈ 4 mm |

`#421-001` and `#421-002` stay at **40T** — the Internal pair is what the decomposition holds fixed.

Three consequences follow from the DC-2 contract and should not be discovered late. The 700-series changes
belong in **`config="revised"` only**: `config="previous"` is what the `dist` gates in `render-all.rs`
measure against the reference meshes, and a re-toothed pulley would read as a miss there by design.
`PULLEY_TEETH` in [`diff_params.scad`](../Hardware/Models/700-Differential/diff_params.scad) is presently a
bare `40` consumed by `gt2_pulley_teeth_2d()` alongside a measured `GT2_TIP_D` and a hand-set
`GT2_GROOVE_C`; those three must become one config-dependent set derived from the tooth count before
either value can move. And Diff Body A is the part `check_revised()` asserts against the
**78 × 73.5 × 50.5 mm** cover envelope, so opening its chamber re-runs the one interface check the revised
config exists to satisfy — the ≈64.4 mm width predicted in [004](004-Mechanical-Architecture.md#wrist-and-differential-j4j5) is an estimate that this work replaces
with a rendered bounding box.

**Definition of done:** the five parts above re-cut in `config="revised"`, every part still rendering as
one clean solid and previewing without warnings, Diff Body A asserting inside the cover envelope, the
`previous` config and its `dist` gates untouched, and `diff_assembly.scad` placing the enlarged pulleys
without interference. `[Provisional]`.

## Base plate
**DC-4 · P2 · Requirement: REQ-STR-4, REQ-ENV-5 · Specified in [004](004-Mechanical-Architecture.md#base-j1)** — ✔ **closed**

**Closed.** The robot-side hole pattern, the bolt, and the doubled clamp's stacking are specified in
[004 § Base mounting plate](004-Mechanical-Architecture.md#base-mounting-plate); the hardware quantities
are in [007.2](007-Bill-of-Materials.md#0072-base). The plate is `#110-004`, with parametric source and a
render-and-check script at
[`Hardware/Models/100-Base/`](../Hardware/Models/100-Base/110-004_BaseMountingPlate.scad); `check.rs`
gates its eight tapped centres against `110-001_BaseMountBottom.stl`.

The doubled clamp raises the J2 axis, and the height that produces does not agree with L1, which is
[DC-13](#base-height-and-l1).

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
`#410-001`, L3 from the End Arm Hub's spigot against the J3–J4 separation. The absent part at L3's far end
stays with [DC-11(h)](#procurement-data) and [DC-6](#link-length-discrepancy-l4); no cut length depends on
it. Confirmation on a built arm belongs to [DC-9](#performance-characterization). `[Specified]`.

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
does not depend on the bracket that carries the differential off the L3 tube; that part is absent from the
model set and stays with [DC-11(h)](#procurement-data). What remains is confirmation on a built arm —
measured with [DC-9](#performance-characterization)'s first-build checks — and the one firmware field that
follows from it ([006](006-Firmware-and-Calibration.md#firmware-defaults-defaultsmake_ins)).
`[Specified]`.

## Base height and L1
**DC-13 · P2 · Requirement: REQ-WS-6 · Specified in [003](003-Kinematics.md#link-lengths)**

**Open:** which clamp count the authoritative L1 belongs to. The base stack is specified in
[004 § Base mounting plate](004-Mechanical-Architecture.md#base-mounting-plate) — a clamp seating shoulder
at 97.000 mm above the mounting face and two 15.000 mm clamps stacked on it — and L1 is
[003 § Link lengths](003-Kinematics.md#link-lengths). Measured against those, the J2 axis lands at:

| Reading | J2 axis above the mounting face | Source |
|---|---|---|
| As modelled — one clamp | 231.200 mm | `HDI-210-001_MainPivot` node origin |
| As designed — two clamps | 246.200 mm | the above plus one clamp |
| **L1 — authoritative** | **235.200 mm** | `Firmware/Defaults.make_ins` |

Neither configuration reproduces the firmware value: the single-clamp model is 4.000 mm short of it, and
the doubled clamp the design calls for overshoots it by 11.000 mm. The CAD model carries one clamp, so it
does not model the design, and nothing in the model set says which clamp count the 235.200 mm belongs to.
The 231.200 mm is the along-arm figure that
[003 § Link lengths](003-Kinematics.md#link-lengths)'s convention takes a link length from, so this is a
disagreement over the stack rather than over the convention, which is what
[DC-6](#link-length-discrepancy-l4) turned out to be.

**Definition of done:** measure mounting face to J2 axis on the first build, recording the clamp count
with it, and reconcile [003 § Link lengths](003-Kinematics.md#link-lengths) and the firmware file to the
built stack. The clamp count moves the answer by 15.000 mm, more than the disagreement itself, so a
measurement without it settles nothing. `[TBD]`.

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
3. **Measure the rail at `J23`** while the board runs; that reading is what
   [DC-11(b)](#procurement-data) needs to choose the fan.

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

**Differential first-build checklist (moved here from [DC-2](#differential-detail-design)):** J4 and J5
move without binding through their full travel (J4 ±108.3°, J5 ±190°), the 6-conductor bundle passes the
bore and survives J5's full travel, and both code disks read cleanly through their shrouds — J5's off
`#710-004` and J4's off the track on Diff Body B's rim
([DC-11(e)](#the-j4-code-disk-is-missing)). Print-fit parameters
(press interference, bevel backlash) tune in
[`diff_params.scad`](../Hardware/Models/700-Differential/diff_params.scad) if a check fails.

**Wrist station (moved here from [DC-6](#link-length-discrepancy-l4)):** measure the **J4 → J5 along-arm
station separation** on the built arm. [003 § Link lengths](003-Kinematics.md#link-lengths) specifies L4
from the CAD kinematic chain, and the build is the first independent check of it; reconcile 003 and the
`LinkLengths` line in [006](006-Firmware-and-Calibration.md#firmware-defaults-defaultsmake_ins) to what is
measured. The wrist is only apart once, so take it with the travel checks above.

**Base first-build checklist (moved here from [DC-4](#base-plate)):** the mounted plate reacts full
dynamic load without walking or tipping (REQ-ENV-5), bolted to the work surface as
[004](004-Mechanical-Architecture.md#base-mounting-plate) requires — the plate is sized against a
calculated ≈45 N·m overturning moment that an unbolted plate cannot resist, so this check tests the
bolting, not the plate. Record the **mounting face to J2 axis height and the clamp count** at the same
time; that is [DC-13](#base-height-and-l1)'s measurement and the base is only apart once.

**Definition of done:** measured repeatability, payload, speed envelope, and reachable workspace on a
physical build, replacing derived values and advancing the requirements to `[Specified]`; plus the
differential and base checklists above. This is the main content of roadmap item 1
([011](011-Roadmap.md)). `[TBD]`.

## From-scratch calibration files
**DC-10 · P2 · Requirement: REQ-ENV-2, REQ-CTL-6 · Specified in [006](006-Firmware-and-Calibration.md#factory-calibration-procedure)**

**Open:** two job files. The [factory calibration procedure](006-Firmware-and-Calibration.md#factory-calibration-procedure)
a from-scratch build must run references calibration jobs that shipped in a factory bundle. Most of that
bundle is recoverable from public repos; two wrappers are not.

| File | Role | Availability |
|---|---|---|
| `PHUI2RCP.js` | Default PhUI startup job | **Present** — `Firmware/dde_apps/PHUI2RCP.js` (and `DDE/examples/PHUI2RCP.dde`) |
| Calibration engine | Optical-encoder calibration routines the job files call | **Present** — `dde/low_level_dexter/` (`Calibrate_Encoders_Function.dde`, `calibrate_optical.js`, `calibrate_build_tables.js`, `calibrate_ui.js`, `ViewEyeRealTime.js`, `ViewEye_Support_Functions.js`) |
| `Setup_Find_Index_Home_HDI*.dde` | Step 2 eye-calibration job wrapper | **Missing** from the public repo (referenced only) |
| `Find_Index_Pulses_HDI.dde` | Boot home-finding job wrapper | **Missing** — named in `Firmware/RunDexRun` (commented boot line) but not shipped |

Because the calibration **engine** is public, the two missing `.dde` wrappers are thin jobs over it and must
be **reconstructed** against `Calibrate_Encoders_Function.dde` / `calibrate_optical.js`. Requesting them
from the originator is not an option (see **Sources of record** above), so reconstruction is the only route.

**Definition of done:** reconstruct the two missing job wrappers, verify they drive the engine
through [006](006-Firmware-and-Calibration.md#factory-calibration-procedure) end-to-end on a new unit, and
confirm the resulting `post_cal_info.JSON` gives correct home-finding. `[Provisional]`.

## Procurement data
**DC-11 · P2 · Requirement: buildability · Specified in [007.1](007.1-Parts-Catalog.md), [007.2](007.2-Printed-Parts.md)**

**Open:** five part identities that the parts catalog could not pin from the design record, plus two parts
that the model set does not contain at all (row h). (Four further sub-items are closed: the defective, the
misfiled, and the superseded model file — rows f, g, and i — and the power supply with its inlet
connector, row j.) Everything else in [007.1](007.1-Parts-Catalog.md) resolves to an orderable product
with a supplier link; these five do not, and each is `[Provisional]` there.

| # | Item | What is open | Consequence if wrong |
|---|---|---|---|
| a | **Stepper motor identity** ([C-101](007.1-Parts-Catalog.md#c-101--nema-17-stepper-09step)) | The legacy list gives only *"25 mm shaft, 0.9°, 0.52 N·m"* — no manufacturer part number, and the recommended qualifying part is not a proven identity match. The requirements it must meet, and how the candidate measures against them, are in [C-101](007.1-Parts-Catalog.md#c-101--nema-17-stepper-09step) | Body or shaft length mismatch against the printed Motor End Cap; five motors ordered wrong |
| b | **Cooling fan** ([C-716](007.1-Parts-Catalog.md#7-electronics-and-wiring)) | Size and part number. The board side — the connector, its fusing, and the voltage the schematic annotates — is specified in [005 § Boards](005-Electronics-and-Control.md#boards); no fan dimension or part number is anywhere in the design record, only a printed Fan Bracket (`#800-005`) and a CAD body (`HDI-730-005_Fan`). The rail is read on [DC-7](#motor-control-pcb)'s power-on | Fan does not fit the bracket, or fouls the MicroZed USB connector |
| c | **Belt Director type** ([#210-004/005](007.2-Printed-Parts.md#arm-body-and-belt-directors--0075)) | [007.5](007-Bill-of-Materials.md#0075-arm-body) types them "Fabricate"; [008.5](008-Assembly.md) treats them as printed bodies that accept pressed MR128 bearings and printed caps | Three parts either printed that should be machined, or absent from the print list |
| d | **Print parameters** ([007.2 § Material](007.2-Printed-Parts.md#material)) | Layer height, wall count, infill, and orientation were never published — the originals were produced on Markforged equipment | Bearing bores and CF strake slots out of tolerance; press and bond fits fail |
| e | **CAD-vs-BOM mismatches** ([007.2](007.2-Printed-Parts.md#model-vs-bom-discrepancies)) | `HDI-311-006C_J2StatorHolderCap_ConeDrive` is in the CAD model but has no BOM row; `HDI-610-006_MotorShaftCoupler` is instanced 4× where the BOM calls for 3. **Plus two found while authoring [DC-2](#differential-detail-design):** (i) [007.6](007-Bill-of-Materials.md#0076-differential) lists **5 × `#720-005` 60 × 4.4 × 1.5 mm CF strakes** in the differential, but no step in [008.6](008-Assembly.md#0086-differential) places them and no 4.4 × 1.5 mm slot appears anywhere in the differential's measured geometry (only the three 25 mm `#710-005` strakes, in the Split Gear Bottom, are both slotted and placed); (ii) **resolved — the J4 code disk is not a part at all**, its 115-slot track being cut into `#730-002`'s mating rim, so the BOM is not short a row — see [the note below](#the-j4-code-disk-is-missing). **Plus three found while placing `diff_assembly.scad`,** where every bought part was drawn into the seat it occupies and three had no seat to go to: (iii) the **needle thrust stack** (`#710-006` AXK0819 + 2 × AS0819, Ø19 OD) that [008.6](008-Assembly.md#0086-differential) step 5 puts on Diff Body B's Ø8 tube — nothing along that tube has a bore wide enough, the only Ø ≥ 19 bore in the Split Gear being `#710-001`'s Ø23 pocket, which `#710-002`'s Ø17 stub already fills; (iv) `#620-001` **MR85** (5 × 8 × 2.5), catalogued "Diff Gear Axle back" — `#720-002`'s only bore is the Ø8 the CF rod occupies, and no Ø5 feature exists anywhere in the differential for its inner race; (v) the **fifth 6703**, which by elimination is that Ø23 pocket (an r 8.5–11.5 × 4.25 mm annulus, floored exactly where `#710-002` bottoms on `#710-001` — a 6703 section to a hundredth), except that both of its races belong to parts the brads lock together, so nothing there turns relative to anything | Five fabricated parts with no home; three bought parts ordered with nowhere to fit |
| f | **Defective model file** (`#710-002`, [007.2](007.2-Printed-Parts.md#differential--0076)) — ✔ **closed** | The file was **~1000× oversize** (exporter unit slip; its header read `STLB ASM 217.00.00.5800` vs neighbours' `220.00.00.0000`). The factor was detected as **exactly 1/1000** (`scadmesh scale --ref-dim 23.0`, zero residual against the 6703 seat), applied in place, and the corrected part verified against its mates: Ø23.000 6703 seat, Ø12.000 MR128 seat, Ø28.06 press bore receiving the Split Gear Top's Ø28.00, brad circle matching the Top's windows. Old SHA-256 `c20e30d1…a853af`, corrected `e746f42f…9cb3662`. The part now also has parametric source (`710-002_SplitGearBottom.scad`, [DC-2](#differential-detail-design)) | — |
| g | **Misfiled model file** (`#200-001` Arm Body) — ✔ **closed** | `200-ArmBody/200-001_ArmBody.stl` held `ArmBodyFrontStrakeMED.stl` byte for byte (SHA-256 `c991b4e5…dcee1b`, 20 triangles, 4.9 × 9.9 × 32 mm) — the mirror had matched the archive's `ArmBody*` name prefix rather than the part. Replaced with `ArmBodyWEncode.stl` from [thing:3781990](https://www.thingiverse.com/thing:3781990) (SHA-256 `ad4e940d…1d86b4`, 11,946 triangles, 99.6 × 108.1 × 98.0 mm), confirmed to be the part by its 29 × 29 mm L2 tube socket agreeing with `HDI-310-001_ArmBody`'s to 0.011 mm ([DC-5](#link-member-lengths)). Unlike row f this was invisible to every check the manifest makes — the file was well-formed and the right size for *a* part. [Models § Known defects](../Hardware/Models/README.md#known-defects) records what that implies for the rest of the mirror | The largest printed part in the robot unprintable, and L2's seat depth uncheckable |
| h | **L3's far-end part is absent from the model set** | [C-505](007.1-Parts-Catalog.md#c-505--braided-carbon-fibre-square-tube-075) puts the L3 tube's far face 36.000 mm short of the J4 axis, and no file here presents the face it butts. The tube axis is (x = 0, z = 36.000) in world, `HDI-940-001_DiffCover` stops at z = 18.000, and neither differential body carries a 0.75″ joint; the CAD model represents the whole wrist as covers | No modelled path from the L3 tube's far face to the differential. Neither the L3 cut length nor [DC-6](#link-length-discrepancy-l4)'s L4 depends on it |
| i | **Superseded model file** (`#110-001` Base Mount Bottom) — ✔ **closed** | `100-Base/110-001_BaseMountBottom.stl` held the **previous version's un-bolted base**: 85.000 × 85.000 × 98.000 mm against the CAD part's 150 × 150 × 98, with **no fastener features at all**. Its six 60°-spaced features decompose under `scadmesh arcs` into six straight lines — 12.94 × 3.82 mm bonding pockets for the `#110-003` CF strakes — identifying it as exactly the *"6 legged aluminum strake base"* the wiki says the bolted base replaced ([010](010-Versioning.md#1-version-lineage)). Replaced from the CAD model's `BaseMountBottom_Bolted v9` (SHA-256 `ab267f07…c00d2bde`, 25,952 triangles, 150.000 × 150.000 × 98.000 mm), which carries the 8-hole robot-side pattern [DC-4](#base-plate) was opened to recover. Like row g this passed every check the manifest makes — the file was well-formed and plausible for *a* base | [DC-4](#base-plate) unclosable, and a base printed without the mounting holes the design bolts through |
| j | **Power supply and its mating connector** ([C-103](007.1-Parts-Catalog.md#c-103--power-supply-36-v-dc), [C-715](007.1-Parts-Catalog.md#7-electronics-and-wiring)) — ✔ **closed** | The design record named no supply model — the wiki gives only *"standard laptop power bricks ... rated at 36 volts, 4 amps"* — so [DC-8](#power-supply) closed on a rating and left the part open. C-103 then specified the supply as carrying a **DC barrel plug** while recommending MEAN WELL `GST160A36-R7B`, whose standard `-R7B` plug is a **KYCON `KPPX-4P` equivalent 4-pin DIN**: the two cannot mate, and C-715 was unorderable in consequence. **Closed by decision.** `GST160A36-R7B` is the supply of record and the inlet is its snap-and-lock mate, KYCON **`KPJX-PM-4S`** (48 V DC, 7.5 A per pin), specified in [005 § Power](005-Electronics-and-Control.md#power). A barrel inlet is rejected: the arm moves under power and a barrel plug has no retention. Two consequences follow — the inlet wire goes to **18 AWG** ([C-714](007.1-Parts-Catalog.md#7-electronics-and-wiring)), C-715's datasheet specifying #18 for its power pins where the previous version's 24 AWG is undersized for a 4 A rail; and an **IEC C13 line cord** ([C-718](007.1-Parts-Catalog.md#7-electronics-and-wiring)) joins the bill, the adapter having a C14 inlet and shipping without one | — |

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

**Largely closed: the model archives are now mirrored** in
[`Hardware/Models/`](../Hardware/Models/README.md), so the upstream archives are no longer a single point of
failure ([007.2 § Model file sources](007.2-Printed-Parts.md#model-file-sources)). Two gaps remain:
[007.2](007.2-Printed-Parts.md) still gives per-*archive* links rather than per-*part* ones, and — more
seriously — **most of the robot is mesh-only**, so changing an HD part today means re-deriving it from a
mesh ([`Hardware/Models/README.md` § Formats](../Hardware/Models/README.md#formats-and-what-can-actually-be-edited)).
The OpenSCAD conversion has now started where it mattered most: the differential set has full parametric
source ([DC-2](#differential-detail-design)), and the `openscad-tools` measurement utilities built for it
apply to every remaining mesh-only part.

**Definition of done:** (a) a confirmed stepper part number verified against the printed Motor End Cap
envelope; (b) fan size and part number specified against the Fan Bracket, on the rail DC-7 reads at `J23`;
(c) the Belt Director type settled and the affected rows corrected in
[007](007-Bill-of-Materials.md)/[007.2](007.2-Printed-Parts.md);
(d) a published print profile validated on a bearing bore and a strake slot; (e) both CAD-vs-BOM mismatches
adjudicated against the model set; (f) **done** — the rescaled, mate-verified STL and its parametric source
are committed (see row f); and [007.2](007.2-Printed-Parts.md) carrying per-part model links now that the
model set is mirrored in [`Hardware/Models/`](../Hardware/Models/README.md). None of these blocks starting
the long-lead items in [DC-1](#strain-wave-component-set). `[Provisional]`.
