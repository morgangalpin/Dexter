# 009 — Design Completion

This document is the live list of **open design decisions** that must be closed to make Dexter
fully buildable and to advance its `[Provisional]`/`[TBD]` items to `[Specified]`. Each item states the
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
| DC-2 | [Differential detail design](#differential-detail-design) | **P1** | J4/J5 wrist | One part not yet rebuilt (720-001) | `[Provisional]` reopened |
| DC-3 | [Wrist reduction ratio](#wrist-reduction-ratio) | P2 | J4/J5 resolution | Tooth-count decomposition | `[Provisional]` |
| DC-4 | [Base plate](#base-plate) | P2 | Base mounting | Robot-side hole transfer from CAD | `[Provisional]` |
| DC-5 | [Link member lengths (L2/L3)](#link-member-lengths) | P2 | Arm Body, End Arm Hub | Socket-seat depth check | `[Provisional]` |
| DC-6 | [Link-length discrepancy (L4)](#link-length-discrepancy-l4) | P2 | Kinematic accuracy | Caliper measurement | `[TBD]` |
| DC-7 | [Motor Control PCB](#motor-control-pcb) | P2 | Electronics | Physical power-on test | `[Provisional]` |
| DC-8 | [Power supply rating](#power-supply) | P2 | Power | — | `[Specified]` ✔ closed |
| DC-9 | [Performance characterization](#performance-characterization) | P3 | REQ-PRE/WS confirmation | Instrumented build | `[TBD]` |
| DC-10 | [From-scratch calibration files](#from-scratch-calibration-files) | P2 | First bring-up | Two job wrappers | `[Provisional]` |
| DC-11 | [Procurement data](#procurement-data) | P2 | Ordering, printing | Five unpinned part identities | `[Provisional]` |

**Completion progress.** DC-1 and DC-8 are closed. Every other item has been narrowed to the single
remaining gap named in the table above, and each of those gaps is one of three kinds of work:
**procurement** (DC-11), **design or reconstruction authored here** (DC-2, DC-3, DC-6, DC-10), or **a
check on a physical build** (DC-4, DC-5, DC-7, DC-9). DC-2 — the largest single piece of work in the set
— is authored as parametric OpenSCAD source, but one of its seven recreated parts does not yet reproduce
their reference geometry, so it is **reopened**; its physical-build checks remain with DC-9.

---

## Strain-wave component set
**DC-1 · P1 · Requirement: REQ-STR-2 · Specified in [004](004-Mechanical-Architecture.md#base-joints-j1j3-strain-wave-drive)** — ✔ **closed**

**Closed.** The part is identified, quoted, and dimensionally confirmed against the printed adapters it
mates to.

**Vendor and part.** Identified, quoted, and dimensionally confirmed — see
[C-201](007.1-Parts-Catalog.md#c-201--521-strain-wave-component-set) for vendor, part number, price, and
lead time. Start this order before anything else; it carries the longest lead time in the build.

*Cone Drive (conedrive.com) remains a viable alternate source — same size-14, 52:1 spec, and the printed
adapters' `_ConeDrive`-suffixed CAD names and the maintenance schedule's Cone Drive lubricant
([006](006-Firmware-and-Calibration.md#maintenance)) reflect that this was the design's original target
vendor. HanZhen is the one actually quoted.*

**Interface dimensions, from the datasheet.** These are the mating dimensions the printed adapters are cut
to:

| Feature | Value | Mates with |
|---|---|---|
| Housing / circular-spline OD | **Ø50h6** | Bore in Pivot / Base / Ex Gear Stator Holder |
| Mounting bolt circle | **Ø44**, 6 × Ø4.5 clearance holes | Same three Stator Holders |
| Secondary hole circle | 6 × Ø3.5 | Flex Spline Attach |
| Wave-generator input bore | **Ø6H7**, retained by 2 × M3 set screws at 90° | Wave Gen Coupler output stub |
| Other stepped diameters (recorded, not yet tied to a specific printed feature) | Ø38h7, Ø22.5, Ø17, Ø14, Ø11H7 | — |
| Overall axial length | 28.5 mm | — |
| Backlash / input speed / mass (all ratios) | ≤0.3 arcmin / 3500 rpm max / 0.1 kg | — |

**Dimensional cross-check against the model set.** The datasheet's key mating diameters were checked
against the built STL geometry (binary-STL vertex radii, centred on each part's rotation axis) rather than
taken on faith:

- **Pivot Stator Holder** (`200-002_PivotStatorHolder.stl`), **Base Stator Holder**
  (`110-002_BaseStatorHolder.stl`), and **Ex Gear Stator Holder** (`511-002_ExGearStatorHolder.stl`) each
  show a sharp, dominant Ø50.0 mm radial band — matching the housing Ø50h6 exactly — plus a Ø44–45 mm
  band cluster matching the Ø44 bolt circle.
- **Wave Gen Coupler** (`630-004_WaveGenCoupler.stl`) is dominated by a Ø5.0 mm bore (the NEMA-17 motor
  shaft it is reamed onto) with a smaller Ø6.0 mm band consistent with the Ø6H7 wave-generator input stub
  on its other end.
- **Flex Spline Attach** (`630-005_FlexSplineAttach.stl`) shows the same Ø44 mm hole-circle cluster and a
  ~Ø50–51 mm band; **Flex Spline Cap** (`630-006_FlexSplineCap.stl`) is dominated by a Ø23.0 mm band, close
  to the datasheet's Ø22.5 mm.

No scale or gross dimensional mismatch was found (contrast [DC-11(f)](#procurement-data), where this same
kind of check caught a ~1000× oversized STL). The printed adapters already align with the actual component
set.

**Note on the ratio table.** The datasheet's torque table is tabulated at ratios 40/50/60/80/110/120 — 52 is
not a row (consistent with it being quoted off-catalog, per HanZhen's "not listed, contact directly"
behaviour). Start/stop torque (11 N·m) and peak torque (24 N·m) are identical at the neighbouring 50 and 60
rows, so both hold at 52 too; rated (continuous) torque interpolates to **≈4.1–4.2 N·m**. Backlash
(≤0.3 arcmin), input max speed (3500 rpm), and mass (0.1 kg) are constant across the table regardless of
ratio.

*Source: `Hardware/Reference/XB1-AS-C-32.pdf` (HanZhen manufacturer drawing); `Hardware/README.md`;
STL geometry in `Hardware/Models/`.*

## Differential detail design
**DC-2 · P1 · Requirement: REQ-DOF-1, REQ-STR-3 · Specified in [004](004-Mechanical-Architecture.md#wrist-and-differential-j4j5)** — `[Provisional]` — **reopened**

**Reopened 2026-08-06.** This item was closed on a verification that could not detect the defect it was
meant to catch, and five of the seven recreated parts were the wrong shape — four have since been rebuilt
and measure faithful, and 720-001 remains. The parametric source, the parameter sets, and the assembly
assertions below all still stand; what failed was the evidence that the parts match their references.

**Why the original verification was insufficient.** It rested on `scadmesh compare`, which asks whether
every reference **diameter and face position** reappears somewhere in the candidate. That is a set of
one-dimensional histograms, and a solid can satisfy every one of them while being the wrong body: a
missing boss, a square hole where the reference has a round one, and a dished flank where the reference
bulges all leave the histograms intact. The check reported ±0.006–0.131 mm agreement on parts deviating
by up to 3.8 mm. **A dimensional check is not a shape check**, and no amount of tightening its tolerance
would have made it one.

**Measured state** (`scadmesh dist`, two-sided sampled surface distance against each reference, mm):

| Part | Worst deviation | Volume vs reference | Status |
|---|---|---|---|
| 710-003 Diff Keeper | 0.023 | −0.8 % | faithful |
| 710-004 Rotate Code Disk | 0.350 | −1.4 % | faithful (p95 0.011; one localized edge) |
| 720-002 Diff Gear Axle | 0.100 | −0.02 % | **rebuilt, faithful** (was 1.31) |
| 720-003 Diff End Pulley | 0.030 | −0.02 % | **rebuilt, faithful** (was 1.98 / −4 %) |
| 710-002 Split Gear Bottom | 0.150 | +0.02 % | **rebuilt, faithful** (was 2.25 / −11 %) |
| 710-001 Split Gear Top | 0.225 | −0.1 % | **rebuilt**, p95 0.010, 0.13 % over tol (was 3.57 / −11 %) |
| 720-001 Diff Gear Shaft | 3.82 | −16 % | wrong, not yet rebuilt |

Known specific defect remaining: **720-001** is missing 16 % of its material, and is the one part not
yet rebuilt.

**Four of the five are rebuilt and measure faithful.** Each was built the same way — revolve the measured
meridional profile for the body, build the toothed or belted feature separately, cut the through-work
last — and each renders as a single clean solid. Two findings generalise beyond the parts themselves:

- **The bevels are recoverable as cones.** Every crown surface on 710-001, 710-002 and 720-002 is a cone,
  and fitting measured radius against height recovers each one to a few thousandths of a millimetre. The
  fits corroborate each other across parts, which is what makes them trustworthy rather than merely
  well-fitted: 720-002's tip cones are 710-001's translated by 15.448 mm, as a 1:1 pair must share; their
  root-cone slopes agree to 0.07 %; and 710-001's 45° inner cone is the identical equation 710-002 records
  for its outer cone, the surface the two parts actually mate on. Each crown's four cone intersections
  then define it outright, and every one was checked against an independent measurement — 710-001's
  computed apex at z = 24.4103 against a bounding box topping out at 24.410.
- **Straight bevel teeth are ruled through the gear apex**, so one measured section reproduces a whole
  tooth when lofted between two scaled copies: the hull between them *is* the ruled surface. 720-002 needs
  exactly one section. 710-001 needs thirteen, because its tip surface changes direction at the crown ring
  — below it the skirt cone rises with height while the root cone falls — so no single similarity can
  follow both.

The residual on 710-001 is a limit of the method rather than slack in the numbers: its worst point is the
tooth's **root fillet**, which is concave, and a loft through convex hulls cuts the corner across it.
Going from seven sections to thirteen moved p95 from 0.023 to 0.010 and left the maximum where it was.
Removing it means a skinned loft that preserves concavity.

**710-002 Split Gear Bottom is rebuilt and now meets the contract below.** Its bevel crown is no longer a
generated `bevel_gear()` — a 1:1 bevel's teeth stand outside the crown radius, so intersecting one against
this part cut no slots at all and left the hub solid. The teeth are instead lofted through convex hulls of
seventeen measured cross-sections, and the body is a revolved measured profile. Four cone surfaces govern
the crown, three of them 45°, and the tooth's inner face is cut by the same cone that forms the top edge of
the Ø23 bore, which is why they meet exactly at (r 11.500, z 24.846):

| Surface | Radius as a function of height |
|---|---|
| outer tip cone | `r = z − 7.000` |
| top face | `r = 45.452 − 1.14900 z` |
| root cone | `r = 33.5244 − 0.84876 z` |
| inner cone | `r = z − 13.350` |

Agreement: tooth tips within 0.009 mm and the root cone within 0.007 mm over nine heights; candidate-to-
reference max 0.150 mm, RMS 0.024, p95 0.043. The 0.150 mm worst point is on the Ø8.5 bore, which the
reference tessellates with only 12 facets — that is chord error between two meshes, not shape error.

**Revised verification contract — what closing DC-2 now requires:**

- Every recreated part agrees with its reference under `scadmesh dist` within ±0.15 mm **in both
  directions**. Both directions are required, not a formality: candidate-to-reference finds material the
  model invented, reference-to-candidate finds material it never reproduced, and a model that is a strict
  subset of its reference passes the first alone. The one exception is an unmerged reference, where the
  reverse direction is uninterpretable — see the artifact exception below, and account for it explicitly
  rather than by widening the tolerance.
- Each part's body is built from its **measured meridional profile** (`scadmesh profile`) rather than
  from inferred diameters and face heights, so flank curvature is reproduced instead of guessed.
- Every part previews (F5) as well as renders (F6), and a part modelled as one solid reports one solid.
  Previewing must be **checked**, not assumed: it fails independently of rendering, so exporting an STL
  and measuring it will pass a part that shows nothing in the GUI. Run
  `openscad --preview -o check.png <part>.scad` and require zero warnings. The failure mode is specific
  and was hit on 710-001: **no cutter may be a module that is internally boolean** — BOSL2's `pie_slice()`
  and anything taking `rounding=`/`chamfer=` are — because `A - (B - C)` normalizes to `(A - B) | (A & C)`
  and each one doubles the preview tree. Build cutters from single primitives, and cut each solid before
  unioning it into an array rather than after.
- `compare` is retained, but only to name *which* dimension moved once `dist` has failed a part. It no
  longer gates anything.
- The two documented exception classes still apply and still must be enumerated explicitly rather than
  absorbed into a widened tolerance:
  - **Gear zones.** Tooth flanks are BOSL2 involutes and will never match a hand-modelled mesh
    vertex-for-vertex, so within those bands the check is **tooth count plus outside diameter**. The pitch
    cones are not measured; they follow from the 20T-on-20T, 90°-shaft configuration.
  - **Reference-export artifacts.** The STLs are CAD *assembly* exports (`STLB ASM` headers) carrying
    zero-thickness internal shells — `profile` shows these as doubled-back slivers, one measuring 0.003 mm
    across in 710-002 — which a clean model must not reproduce. They also carry **unmerged solids**: run
    `scadmesh segment` on a reference before measuring it. 710-002 is two bodies, a turned body and a
    tooth crown, tessellated at 3.85 and 6.91 triangles/mm² and never merged. Two consequences follow.
    Its file volume **double-counts** the ≈352 mm³ where they interpenetrate, so a faithful model reads
    4.8 % light against the file and correct against the merged 7001 mm³ — the volume column above is
    computed against unmerged files and is a screening signal, not a verdict. And `dist` in the
    reference-to-candidate direction flags every **buried** surface, because a merged model has no
    counterpart for them; on this part that is 28 % of reference samples at up to 2.25 mm, none of it a
    defect. Only the candidate-to-reference direction gates a part whose reference is an assembly export.
- The two housings (Diff Body A/B) remain **authored functional redesigns** rather than recreations: every
  bearing seat, journal, bore, axis position, and span is taken from measurement, while the sculpted
  shells are replaced with clean parametric bodies. They are verified by interface slice checks, not by
  shape comparison, because there is no reference shape they are meant to match.
- Tooth counts verified on the renders: three 20T bevels (1:1:1), two 40T GT2 pulleys, 100 encoder slots.
  These passed and are unaffected — a tooth count is not a shape claim.
- The assembly is evaluated in both configurations, which fires its assertions: the J4/J5 axes intersect,
  the L4 split resolves to the firmware's 59.50 mm, and the revised body fits the cover envelope. These
  also passed and are unaffected, being parameter assertions rather than geometry comparisons.

**Open question carried with this item.** The faithful-recreation stage was premised on the reference
STLs being trustworthy part geometry. They are artifact-laden assembly exports, so recreating them
exactly may be the wrong goal; authoring directly to the revised interface and dropping the clone target
is the alternative. Resolve before rebuilding the remaining parts.

**Physical build validation moved to [DC-9](#performance-characterization):** J4 and J5 move without
binding through their full travel, the 6-conductor bundle passes the bore and survives J5's full travel,
and both code disks read cleanly. Until a build passes those checks, treat printed fit (press interference,
bevel backlash) as tunable via `diff_params.scad`.

**There was no source to recover this from.** All three candidate routes were closed, which made this an
authoring task rather than a retrieval task:

- **The in-repo CAD model is a kinematic-and-skin model.** `dde/HDIMeterModel.gltf` (and
  `dde/sim2/HDIMeterModel.gltf`) carries the differential *covers* (`HDI-940-001_DiffCover`,
  `HDI-940-002_DiffCoverCap`) and the `DexterHDI_Link4/5/6/7_KinematicAssembly` frames, but **not** the
  mechanism internals (the 700-series Split Gear, Diff Body A/B, Diff Gear Shaft/Axle, Diff End Pulley). It
  fixes the envelope and the axis frames — which is why those are now specified in
  [004 § Differential interface](004-Mechanical-Architecture.md#differential-interface) — and nothing else.
- **The OnShape document cannot yield it.** It is exported to
  [`Hardware/Models/Reference/onshape-v1/`](../Hardware/Models/Reference/onshape-v1/README.md) and is the
  **v1** design, not this one. Its Part Studio holds a single `Import 1` feature pointing at foreign CAD
  that returns `404`: 140 dead solids, no sketches, no editable dimensions, no feature history. It is
  measurable reference geometry, not a parametric source.
- **No physical unit is obtainable** — see **Sources of record** above.

**What survives as design input.** Enough to author the part against a closed constraint set:

| Input | Where | What it gives |
|---|---|---|
| Interface specification | [004 § Differential interface](004-Mechanical-Architecture.md#differential-interface) | Envelope, axis positions, travel, bevel ratio, encoders, bore |
| Previous version's mechanism | [`Hardware/Models/700-Differential/`](../Hardware/Models/700-Differential/) — 9 STLs | A complete, built, working precedent at mesh fidelity, with its build procedure in [008.6](008-Assembly.md#0086-differential) |
| v1 mechanism internals | `Hardware/Models/Reference/onshape-v1/parts-step/` — `SideDifferentialGear`, `SideDifferentialGear2`, `OutterFrontDifferentialGear`, `InnerFrontDifferentialGear`, `SmallDifferentialShaft`, `DiffBodySmallB` | Bevel-gear geometry as measurable B-rep solids |
| v1 assembly relationships | `…/assemblies/definition/KA0014-01_Differential.json`, `KA0015-01_DifferentialSet.json` | Occurrence transforms for how those solids sit together |

**Definition of done (met):** a differential design authored to
[004 § Differential interface](004-Mechanical-Architecture.md#differential-interface), with its **source
geometry committed to this repository** (`.scad`, per the convention in
[`Hardware/Models/README.md`](../Hardware/Models/README.md#moving-to-openscad)) rather than as a mesh
alone, geometrically verified per the contract above. The physical checks formerly listed here are DC-9's
first-build checklist. Status `[Specified]`.

## Wrist reduction ratio
**DC-3 · P2 · Requirement: REQ-STR-3, REQ-PRE (J4/J5) · Specified in [004](004-Mechanical-Architecture.md#wrist-and-differential-j4j5), [006](006-Firmware-and-Calibration.md#drive-constants-axiscal)**

**Open:** the tooth-count decomposition. The **net** wrist reduction is fixed and specified; which pulleys
realize it is not.

**The net ratio is derivable from the firmware.** Only the *individual tooth counts* are unpinned — the
net motor→joint reduction is fully determined by `AxisCal`:

- `AxisCal = gear_ratio × motor_steps × microstepping`. With a 400-step motor at 16× microstepping,
  one motor revolution = 6400 microsteps.
- **J4/J5 (this version):** `AxisCal` = 86400 ⇒ **net wrist reduction = 86400 / 6400 = 13.5:1.** Corroborated
  independently by this unit's `Firmware/AxisCal.txt` (J4/J5 line = 0.0666667 = 13.5 × 6400 / 1 296 000) and
  by its `ANGLE_END_RATIO` term (−4 529 848 = −round(13.5 / 50 × 2²⁴); the base-joint `50` there vs the
  authoritative `52` is a separate stale-file note in
  [006](006-Firmware-and-Calibration.md#drive-constants-axiscal)).
- **J4/J5 (previous version):** `AxisCal` = 36000 ⇒ net wrist reduction = 36000 / 6400 = **5.625:1**, which is exactly its
  belt stage **90T / 16T** documented in the wiki (`Joints.md`, `Firmware.md`: motor pulley 16T → joint-3
  pulley 90T).

⚠️ **Correctness fix.** The firmware expects **13.5:1**, but the previously documented 16T→90T pulleys give only
**5.625:1** — 2.4× short. **Building the wrist with that pulley set unchanged and running it against the
`AxisCal` specified here would produce a 2.4× wrist-scale error.** The wrist must therefore net **13.5:1** (revised
differential and/or re-toothed pulleys — 13.5 = 2.4 × the earlier 90/16 stage), *or* the firmware `AxisCal` must
be set to the as-built ratio. The 16T motor pulley in [007.9](007-Bill-of-Materials.md#0079-external-gear-mount--differential-motors)
is retained; the driven side is what changes. The differential bevels are ≈1:1 (the previous version's
net 5.625:1 equals its
belt stage alone), so the added 2.4× lives in the belt/pulley stages.

**Definition of done:** the J4/J5 tooth-count decomposition — which pulleys realize the 13.5:1 net —
**chosen here**, since no surviving record states the intended split and none can be obtained (see
**Sources of record** above); plus the belt lengths that follow from it, validated so firmware
`AxisCal`/`Interpolation` produce correct joint resolution and range with acceptable backlash. Status
`[Provisional]`: **the target net ratio (13.5:1) is fixed and specified**; only the tooth-count split is
open. Do **not** ship the previous version's 16T/90T driven set against this firmware without re-checking
the net ratio.

## Base plate
**DC-4 · P2 · Requirement: REQ-STR-4, REQ-ENV-5 · Specified in [004](004-Mechanical-Architecture.md#base-j1)**

**Open:** the plate's **robot-side hole pattern**. The plate's material, thickness, footprint, work-surface
pattern, and the stability analysis that requires it to be bolted down are all specified in
[004 § Base mounting plate](004-Mechanical-Architecture.md#base-mounting-plate).

The pattern itself is not unknown — it matches the existing mounting bosses on
`HDI-110-001_BaseMountBottom`, the same ones the previous version's feet bolted to. What remains is
transferring the exact hole coordinates out of the OnShape/GLTF part and onto a plate drawing, and
confirming the resulting bolt size and count (which the [007.2](007-Bill-of-Materials.md#0072-base) row
currently leaves open).

**Definition of done:** a plate drawing carrying the robot-side hole coordinates transferred from CAD, the
resulting hardware quantities added to [007.2](007-Bill-of-Materials.md#0072-base), and a build confirming
the mounted plate reacts full dynamic load without walking or tipping. `[Provisional]`.

## Link member lengths
**DC-5 · P2 · Requirement: REQ-WS-6 · Specified in [003](003-Kinematics.md#link-lengths), [004](004-Mechanical-Architecture.md)**

L2 (+18.4 mm) and L3 (−22.7 mm) differ from the previous version by more than build tolerance, so the Arm
Body 1″ CF tube and
End Arm Hub 0.75″ CF tube need new cut lengths.

**Resolution — cut lengths computed.** If the printed sockets that set the axis positions — the Arm
Body and End Arm Hub — keep the same tube seat depth as the previous version, then the entire
axis-to-axis link delta appears
in the tube: `tube_new = tube_previous + link_delta`, giving:

| Span | Previous tube | Link delta (from [003](003-Kinematics.md#link-lengths)) | **Computed cut length** |
|---|---|---|---|
| L2 — Arm Body, 1″ CF square tube | 264 mm | +18.41 mm | **282.4 mm** |
| L3 — End Arm Hub, 0.75″ CF square tube | 237 mm | −22.70 mm | **214.3 mm** |

Adopt these as the cut lengths of record. **Caveat:** the CAD model shows the printed bodies are *renumbered*
(`HDI-310-001_ArmBody`, `HDI-500-001_EndArmHub` in `dde/HDIMeterModel.gltf`), so the socket seat
depth is not guaranteed identical. **Confirm the socket seat depth against the CAD model (or measure
the printed socket bottoms) before committing the tubes.** Getting L2/L3 wrong shifts where the links land
relative to encoder zero and shows up as a Cartesian-accuracy error, not an assembly failure. `[Provisional]`
(computed value; one narrow CAD/measurement check remaining).

**While measuring the End Arm Hub, also check its J4 standoff.** The authored differential
([DC-2](#differential-detail-design)) contributes 31.0 mm of the 59.50 mm L4 offset, leaving **28.5 mm**
that the End Arm Hub must provide between its own frame origin and Diff Body A's mating face
([004 § L4 realization](004-Mechanical-Architecture.md#differential-interface)). That is a separate
dimension from the tube seat depth above, on the same part.

## Link-length discrepancy (L4)
**DC-6 · P2 · Requirement: REQ-WS-6 · Specified in [003](003-Kinematics.md#link-lengths)**

Link-length records disagree on L4, and no unit exists to arbitrate them:

| Source | L4 | L5 |
|---|---|---|
| `Firmware/Defaults.make_ins` — **authoritative** | 59.50 mm | 82.44 mm |
| Wiki | 50.95 mm | 82.55 mm |
| CAD frame separation, per [004 § Differential interface](004-Mechanical-Architecture.md#differential-interface) | 39.50 mm along the arm axis (44.27 mm in 3D) | — |

**State.** With no serialized unit available to measure (see **Sources of record** above), this stops being
an arbitration between records and becomes a **design output**: L4 is whatever the differential and End Arm
Hub authored under [DC-2](#differential-detail-design) place between the J4 and J5 axes. The firmware value
is the target that design must hit. The authored DC-2 design now embodies this: its J4/J5 axes intersect
(consistent with the DH set's `a ≈ 0`), so L4 is an offset **along the J4 axis**, split **31.0 mm inside
the differential + 28.5 mm in the End Arm Hub**
([004 § L4 realization](004-Mechanical-Architecture.md#differential-interface)); `diff_assembly.scad`
asserts it. **What remains is the caliper check on the first build** — and note that the 28.5 mm hub
standoff is now a requirement on the End Arm Hub, so verify it there as well as at the wrist.

The measured DH model of HDI-007010 ([003](003-Kinematics.md#denavithartenberg-model)) does not adjudicate:
the wrist axes intersect (`a`≈0 on J4/J5), so L4 is carried in frame `d` offsets (J4 `d` = 39.3 mm, J5
`d` = 55.6 mm) that do not map 1:1 to any candidate. The GLTF figure is **not** decisive either — a
kinematic-assembly node origin need not sit exactly on the joint axis — but it lands within 0.2 mm of the
J4 `d` term, and is recorded here so whoever closes this has all three figures rather than two.

**Definition of done:** design the wrist to the firmware L4 (59.50 mm), confirm it by caliper on the first
build, and update [003](003-Kinematics.md#link-lengths) and firmware if the built value differs. Until then
the firmware file stands. `[TBD]`.

## Motor Control PCB
**DC-7 · P2 · Requirement: REQ-CTL-3, REQ-IF-4 · Specified in [005](005-Electronics-and-Control.md#boards)**

**Open:** a physical power-on test. No purpose-built Motor Control PCB exists, so the previous version's
"green" board is reused. Its contents have been confirmed against the gerbers and BOM and are specified in
[005 § Boards](005-Electronics-and-Control.md#boards); that review is what established the reuse as viable,
since the board's connector set is generic and the only known difference is the harness White-wire
reassignment. What has *not* happened is running a unit on it.

**Definition of done:** confirm the inherited board drives a unit correctly with this wiring harness on a
physical power-on test. Full closure (a purpose-built board) is a roadmap item
([011](011-Roadmap.md)), not a blocker here. If a unit shows power-related faults absent on earlier builds,
revisit this reuse assumption first. `[Provisional]`.

## Power supply
**DC-8 · P2 · Requirement: REQ-CTL-5 · Specified in [005](005-Electronics-and-Control.md#power)** — ✔ **closed**

**Closed.** The supply rating was open because the board's input ceiling had not been established. It has
been: the `LTC3786` boost controller sets a 38 V limit, which places the supply at **36 V / 4 A** with
margin. The rating, the reasoning behind it, and the under-voltage failure mode are now specified in
[005 § Power](005-Electronics-and-Control.md#power), and the part is listed in
[007.10](007-Bill-of-Materials.md#00710-wire-harness). REQ-CTL-5 is `[Specified]`.

*(The in-testing "blue" board would raise the ceiling to 75 V — out of scope for this design.)*

## Performance characterization
**DC-9 · P3 · Requirements: REQ-PRE-5/6/7, REQ-WS-6/8**

End-to-end repeatability, rated payload, maximum speed, and the reachable envelope are derived or unknown,
not measured. This is inherently a **physical, instrumented-build** item and cannot be closed from the design
record.

**Differential first-build checklist (moved here from [DC-2](#differential-detail-design)):** J4 and J5
move without binding through their full travel (J4 ±108.3°, J5 ±190°), the 6-conductor bundle passes the
bore and survives J5's full travel, and both code disks read cleanly through their shrouds — the J5 disk
today, and the J4 disk once [DC-11(e)](#the-j4-code-disk-is-missing) supplies one. Print-fit parameters
(press interference, bevel backlash) tune in
[`diff_params.scad`](../Hardware/Models/700-Differential/diff_params.scad) if a check fails.

**Definition of done:** measured repeatability, payload, speed envelope, and reachable workspace on a
physical build, replacing derived values and advancing the requirements to `[Specified]`; plus the
differential checklist above. This is the main content of roadmap item 1 ([011](011-Roadmap.md)). `[TBD]`.

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

**Open:** five part identities that the parts catalog could not pin from the design record. (A sixth
sub-item, the defective model file, is closed — see row f.) Everything else in
[007.1](007.1-Parts-Catalog.md) resolves to an orderable product with a supplier link; these five do not,
and each is `[Provisional]` there.

| # | Item | What is open | Consequence if wrong |
|---|---|---|---|
| a | **Stepper motor identity** ([C-101](007.1-Parts-Catalog.md#c-101--nema-17-stepper-09step)) | The legacy list gives only *"25 mm shaft, 0.9°, 0.52 N·m"* — no manufacturer part number. The recommended `17HM19-2004S` is 0.46 N·m with a 24 mm shaft: it meets every stated requirement but is not a proven identity match | Body or shaft length mismatch against the printed Motor End Cap; five motors ordered wrong |
| b | **Cooling fan** ([C-716](007.1-Parts-Catalog.md#7-electronics-and-wiring)) | No size, voltage, or part number anywhere in the design record — only a printed Fan Bracket (`#800-005`) and a CAD body (`HDI-730-005_Fan`) | Fan does not fit the bracket, or fouls the MicroZed USB connector |
| c | **Belt Director type** ([#210-004/005](007.2-Printed-Parts.md#arm-body-and-belt-directors--0075)) | [007.5](007-Bill-of-Materials.md#0075-arm-body) types them "Fabricate"; [008.5](008-Assembly.md) treats them as printed bodies that accept pressed MR128 bearings and printed caps | Three parts either printed that should be machined, or absent from the print list |
| d | **Print parameters** ([007.2 § Material](007.2-Printed-Parts.md#material)) | Layer height, wall count, infill, and orientation were never published — the originals were produced on Markforged equipment | Bearing bores and CF strake slots out of tolerance; press and bond fits fail |
| e | **CAD-vs-BOM mismatches** ([007.2](007.2-Printed-Parts.md#model-vs-bom-discrepancies)) | `HDI-311-006C_J2StatorHolderCap_ConeDrive` is in the CAD model but has no BOM row; `HDI-610-006_MotorShaftCoupler` is instanced 4× where the BOM calls for 3. **Plus two found while authoring [DC-2](#differential-detail-design):** (i) [007.6](007-Bill-of-Materials.md#0076-differential) lists **5 × `#720-005` 60 × 4.4 × 1.5 mm CF strakes** in the differential, but no step in [008.6](008-Assembly.md#0086-differential) places them and no 4.4 × 1.5 mm slot appears anywhere in the differential's measured geometry (only the three 25 mm `#710-005` strakes, in the Split Gear Bottom, are both slotted and placed); (ii) **the J4 code disk does not exist as a part** — see [the note below](#the-j4-code-disk-is-missing) | Five fabricated parts with no home; a wrist joint with no encoder disk to print |
| f | **Defective model file** (`#710-002`, [007.2](007.2-Printed-Parts.md#differential--0076)) — ✔ **closed** | The file was **~1000× oversize** (exporter unit slip; its header read `STLB ASM 217.00.00.5800` vs neighbours' `220.00.00.0000`). The factor was detected as **exactly 1/1000** (`scadmesh scale --ref-dim 23.0`, zero residual against the 6703 seat), applied in place, and the corrected part verified against its mates: Ø23.000 6703 seat, Ø12.000 MR128 seat, Ø28.06 press bore receiving the Split Gear Top's Ø28.00, brad circle matching the Top's windows. Old SHA-256 `c20e30d1…a853af`, corrected `e746f42f…9cb3662`. The part now also has parametric source (`710-002_SplitGearBottom.scad`, [DC-2](#differential-detail-design)) | — |

### The J4 code disk is missing

Every arm joint carries an output-side optical code disk whose slot count is specified in
[003 § Joint definitions](003-Kinematics.md#joint-definitions). Four of the five exist as parts, and each
one's slot count was **counted on its model** while closing [DC-2](#differential-detail-design) and agrees
exactly with the specification:

| Joint | Slots specified | Part | Slots counted |
|---|---|---|---|
| J1 Base | 200 | `#100-002` Base Code Disc | **200** ✔ |
| J2 Pivot | 180 | `#300-002` Pivot Code Disk | **180** ✔ |
| J3 End | 157 | `#410-003` End Arm Code Disk | **157** ✔ |
| J4 Angle | **115** | **none — no BOM row, no model file** | — |
| J5 Rotate | 100 | `#710-004` Rotate Code Disk | **100** ✔ |

The four that exist match their joints one-for-one, which is what makes the fifth's absence a gap rather
than a naming confusion: **no part in [007](007-Bill-of-Materials.md) or
[`Hardware/Models/`](../Hardware/Models/README.md) carries 115 slots.** J4 nevertheless has a
photointerrupter shroud (`#824`) and a firmware slot count, so the disk is expected to exist physically.
The v1 reference set holds a candidate — `KP0089-01_DiffA1CodeDiskFine` in
[`Reference/onshape-v1/parts-step/`](../Hardware/Models/Reference/onshape-v1/) (DiffA1 is J4's differential
name in [003](003-Kinematics.md#joint-definitions)) — so this is recoverable by measurement rather than
from nothing.

**What closing it requires:** decide whether the J4 disk is a missing BOM row (add the part, with its
model), or whether J4 is read off a feature integrated into another part; then add the row, the model, and
the assembly step. Until it is closed, the "both code disks read cleanly" item in the
[DC-9 differential checklist](#performance-characterization) cannot be run.

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
envelope; (b) fan size, voltage, and part number specified against the Fan Bracket; (c) the Belt Director
type settled and the affected rows corrected in [007](007-Bill-of-Materials.md)/[007.2](007.2-Printed-Parts.md);
(d) a published print profile validated on a bearing bore and a strake slot; (e) both CAD-vs-BOM mismatches
adjudicated against the model set; (f) **done** — the rescaled, mate-verified STL and its parametric source
are committed (see row f); and [007.2](007.2-Printed-Parts.md) carrying per-part model links now that the
model set is mirrored in [`Hardware/Models/`](../Hardware/Models/README.md). None of these blocks starting
the long-lead items in [DC-1](#strain-wave-component-set). `[Provisional]`.
