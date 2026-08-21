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
| DC-2 | [Differential detail design](#differential-detail-design) | **P1** | J4/J5 wrist | — | `[Specified]` ✔ closed |
| DC-3 | [Wrist reduction ratio](#wrist-reduction-ratio) | P2 | J4/J5 resolution | Tooth-count decomposition | `[Provisional]` |
| DC-4 | [Base plate](#base-plate) | P2 | Base mounting | Robot-side hole transfer from CAD | `[Provisional]` |
| DC-5 | [Link member lengths (L2/L3)](#link-member-lengths) | P2 | Arm Body, End Arm Hub | Socket-seat depth check | `[Provisional]` |
| DC-6 | [Link-length discrepancy (L4)](#link-length-discrepancy-l4) | P2 | Kinematic accuracy | Caliper measurement | `[TBD]` |
| DC-7 | [Motor Control PCB](#motor-control-pcb) | P2 | Electronics | Physical power-on test | `[Provisional]` |
| DC-8 | [Power supply rating](#power-supply) | P2 | Power | — | `[Specified]` ✔ closed |
| DC-9 | [Performance characterization](#performance-characterization) | P3 | REQ-PRE/WS confirmation | Instrumented build | `[TBD]` |
| DC-10 | [From-scratch calibration files](#from-scratch-calibration-files) | P2 | First bring-up | Two job wrappers | `[Provisional]` |
| DC-11 | [Procurement data](#procurement-data) | P2 | Ordering, printing | Five unpinned part identities | `[Provisional]` |

**Completion progress.** DC-1, DC-2, and DC-8 are closed. Every other item has been narrowed to the
single remaining gap named in the table above, and each of those gaps is one of three kinds of work:
**procurement** (DC-11), **design or reconstruction authored here** (DC-3, DC-6, DC-10), or **a check on
a physical build** (DC-4, DC-5, DC-7, DC-9). DC-2 — the largest single piece of work in the set — is
authored as parametric OpenSCAD source; all seven recreated parts now render as one clean solid from
measured geometry. Its physical-build checks remain with DC-9.

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
**DC-2 · P1 · Requirement: REQ-DOF-1, REQ-STR-3 · Specified in [004](004-Mechanical-Architecture.md#wrist-and-differential-j4j5)** — ✔ **closed**

**Reopened 2026-08-06, closed 2026-08-09.** This item was originally closed on a verification that could
not detect the defect it was meant to catch, and five of the seven recreated parts were the wrong shape.
All five are now rebuilt and measure against their references under the revised contract below —
faithfully for four of them, and for the fifth (720-001) against an explicit, decided exception rather
than the ordinary tolerance. The parametric source, the parameter sets, and the assembly assertions below
all still stand; what failed the first time was the evidence that the parts match their references.

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
| 720-002 Diff Gear Axle | 0.094 | −0.02 % | **rebuilt, faithful** (p95 0.028; was 1.31) |
| 720-003 Diff End Pulley | 0.030 | −0.02 % | **rebuilt, faithful** (was 1.98 / −4 %) |
| 710-002 Split Gear Bottom | 0.150 | +0.02 % | **rebuilt, faithful** (p95 0.050; was 2.25 / −11 %) |
| 710-001 Split Gear Top | 0.045 | −0.1 % | **rebuilt, faithful** (p95 0.010; was 3.57 / −11 %) |
| 720-001 Diff Gear Shaft | 1.282 / 2.851 | −0.83 % | **rebuilt, cut to the shared crown** — fails ±0.15 mm by design, see CR-3A13 |

All seven parts now render as one clean solid from measured geometry. **720-001** is the one part that
does not meet the ordinary ±0.15 mm gate — not because it is the wrong shape, but because it was
deliberately cut to a tooth form other than its own reference's (below and [CR-3A13](../CHANGES.md)). Its
"worst deviation" cell is candidate→reference and reference→candidate respectively, since neither alone
tells the whole story here: the first is dominated by one localized modelling approximation (below), the
second by the reference mesh's own pre-existing artifact (next section). Tooth count (20) and tooth
clocking (within 0.3° of the reference at every position) are unaffected by the tooth-form swap and are
verified separately, on the render itself rather than against the reference.

**Four of the five are rebuilt and measure faithful.** Each was built the same way — revolve the measured
meridional profile for the body, build the toothed or belted feature separately, cut the through-work
last — and each renders as a single clean solid. Two findings generalise beyond the parts themselves:

- **The bevels are recoverable as cones.** Every crown surface on 710-001, 710-002 and 720-002 is a cone,
  and fitting measured radius against height recovers each one exactly — the four fitted on 720-002 leave
  a maximum residual of 0.0003 mm over six heights. Each crown's cone intersections then define its every
  edge outright, so no corner coordinate is measured twice.
- **The Split Gear and the Diff Gear Axle are one gear.** They do not merely mesh; they are the same
  20-tooth crown placed twice, and 710-001 and 710-002 are that crown sawn in half along a 45° cone.
  Sections of 710-001 and of 720-002 taken 15.4484 mm apart return outlines **0.0001 mm apart over 4088
  points**, already clocked alike, and 710-002 supplies exactly the material inside the parting cone that
  710-001 lacks — its area agreeing with 720-002's whole tooth ring to 0.007 mm² in 858. The gear is
  therefore defined once, in `diff_bevel.scad`, and each part intersects it with its own envelope; a part
  contributes only where its apex sits on its axis. They cannot now drift out of mesh in edit.
- **The third bevel is the previous revision of the same gear** `[Specified]`. 720-001 Diff Gear Shaft is
  20T — angular periodicity 1.4198 at n = 20 against ≤0.006 at every other count tried — and at a matched
  height its root radius agrees with the shared gear's to 0.03 mm, which is what makes the difference easy
  to miss. It is nonetheless a different tooth form, and the v1 STEP says which one.

  The **tip cone** decides it. 720-001's top land runs `r = 1.18343 (y − 0.5068)`, fitted over five
  sections a millimetre apart and constant to 1 × 10⁻⁵ in slope. The v1 STEP files state that cone
  analytically — one `CONICAL_SURFACE`, semi-angle 49.80181717642289°, slope 1.1834163, apex 0.5064895 —
  and state **the same one in all four gears**: KP0086 Outter Front, KP0087 and KP0092 Side, KP0088 Inner
  Front. 720-001's mesh reproduces it to 1.4 × 10⁻⁵ in slope and 0.0004 mm in apex. The shared gear's face
  cone is 1.14792, a 48.94° half-angle that appears in no v1 file, and 710-002 and 720-002 measure 1.1478
  independently of one another. The root cones part the same way: 720-001 runs `r = 0.84175 y` with its
  apex on the origin, constant to 1 × 10⁻⁴ over y 15..19, against `0.84952` with the apex 0.131 mm beyond
  the face apex.

  So v1 ran one gear in all four places; the revision that produced these meshes re-cut three of them and
  left the Diff Gear Shaft on the old form. Sections of 720-001 and 720-002 anywhere in the tooth zone,
  best-fitted for scale, clocking and hand, leave **0.64 mm max and 0.16 mm rms** — against **0.0000 mm**
  for 710-001 against 720-002. On the flanks alone it is 0.171 max, 0.083 rms; the root land carries the
  rest, 720-001's being the narrower. The pair therefore still meshes, on a tooth form one revision behind.

  **Decided: cut 720-001 from `diff_bevel.scad` like the other three**, for a matched set of four rather
  than reproducing the old form faithfully — see [CR-3A13](../CHANGES.md) for the rebuild and its actual
  measured cost, which came in higher than the ~0.17 mm/0.64 mm estimated above (those numbers compared
  720-001's *old* form against the *shared gear's reference*; the rebuilt part's own `dist` against *its
  own* reference is reported in the measured-state table). 004's "20T straight bevels at 1:1:1" is now
  `[Specified]` for all three positions.
- **Straight bevel teeth are ruled through the gear apex**, so *one* section reproduces the whole tooth:
  scaling it about the axis by the ratio of heights **is** the surface between them, which
  `linear_extrude(scale=)` draws exactly and without facets across the flank. Nothing needs a loft through
  stacked sections. An earlier revision used thirteen on 710-001 because it read the tooth's tip surface
  off the sections, and that surface changes direction at the crown ring; letting the revolved envelope
  supply the tip, root and end faces leaves the section responsible for the flanks alone, and those are
  ruled everywhere. The apex was measured rather than assumed — scaling a section at one height onto a
  measured section at another and minimising the mismatch locates it to ±0.02 mm on two independent pairs
  of heights, each agreeing to 0.002 mm, and it lands on the face cone's apex.
- **The flank is a cubic.** Fitted to 253 measured points — the median over 9 heights × 20 teeth, which
  agree among themselves to 0.002 mm — a single cubic Bézier holds them to **0.006 mm max, 0.003 RMS**.
  A bevel tooth flank has no closed form in this plane, so it stays measurement; but four control points
  carry it, where the polyline it replaced needed several hundred coordinates per part and still rendered
  as visible facets.

Rebuilding the three crowns this way took 710-001 from 0.225 mm to **0.045 mm** with nothing over
tolerance, made its bounding box exact, and cut its triangle count by 56 %. It also removed the previous
revision's one acknowledged limitation: the residual then was the tooth's concave **root fillet**, which a
loft through convex hulls cuts the corner across. A single `polygon()` has no such restriction, so the
fillet is now carried as measured.

**710-002's 0.150 mm is a defect in the reference, not in the model.** An earlier revision of this section
attributed it to chord error on the Ø8.5 bore; measurement does not support that. Circle fits at z 6.3,
6.5, 6.6, 6.7 and 6.9 all centre that bore and its funnel on (−0.039, 0.138) — **0.143 mm off the axis** —
while every turned surface around them fits the axis to 0.001 mm. It is a clearance hole for wire, so the
model keeps it concentric, and that eccentricity is the whole of the part's excursion past tolerance
(0.011 % of samples).

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
- **A shared face is not a join.** Where a feature is trimmed to the surface of the blank it stands on,
  CGAL returns the two as separate solids, the blank's face survives the union underneath the feature, and
  the export carries interior surface — which `dist` then measures against nothing, reading over a
  millimetre out on geometry that is dimensionally correct. This was hit on 710-002, whose crown envelope
  was bounded on the root cone: 21 solids, and 8.3 % of samples over tolerance. Trim such a feature to a
  surface **offset into** the blank (`BEVEL_ROOT_UNDER` offsets 0.35 mm) and let the overlap be buried.
  The `Volumes:` line of the render log is the cheap check: a part modelled as one solid must report 2.
- `compare` is retained, but only to name *which* dimension moved once `dist` has failed a part. It no
  longer gates anything.
- Three documented exception classes apply, and must be enumerated explicitly rather than absorbed into
  a widened tolerance:
  - **Gear zones — withdrawn for the bevels.** This exception was written when the teeth were generated
    by BOSL2 and could not match a reference vertex-for-vertex. They are no longer generated: the bevel
    crown is measured (`diff_bevel.scad`) and meets the ordinary ±0.15 mm surface check with room to
    spare, so 710-001, 710-002, and 720-002 are gated on `dist` like any other geometry, with no
    tooth-band exemption. The exception still stands for the **GT2 pulley** teeth, which are cut with a
    modelled groove profile. The bevels' 45° pitch cones remain a consequence of the 20T-on-20T,
    90°-shaft configuration rather than a measurement — but the face cone's apex, measured independently,
    lands on the pitch apex.
  - **720-001's tooth form — a decided exception, not a measurement gap.** [CR-3A13](../CHANGES.md) cut
    this part's crown to the shared gear rather than its own reference's superseded form, so its `dist`
    against its own reference fails ±0.15 mm in the tooth zone — expected and accepted. [CR-3A14](../CHANGES.md)
    then cut the crown's *envelope* to this part's own measured surfaces, which is not the same claim as
    its tooth form and is held to the usual standard: candidate→reference fell 1.282 → **0.568 mm** and
    reference→candidate 2.851 → **0.456 mm**. What remains sits on the two known consequences of the
    shared crown: its root cone runs 0.40 mm below this part's, and its shallower face cone forced a
    choice between the reference's Ø43.500 tip cut and the 0.5990 mm land that cut leaves. **The land is
    kept**: the blunting is the feature and its diameter is not, and the diameter that opened that land
    belongs to the superseded tooth form, so on the shared crown it would leave a 0.031 mm land — sharp
    tips with a matching number. This part's OD is therefore Ø42.715, **the one dimension outside the
    tooth zone that the file knowingly does not match**, with the argument and the measured cost of both
    choices stated in
    [`720-001_DiffGearShaft.scad`](../Hardware/Models/700-Differential/720-001_DiffGearShaft.scad).
    It is gated at its stated value rather than merely recorded: `render-all.rs` holds both transverse
    bounding-box dims to that 0.768 mm departure within 0.02 mm, so re-typing the reference's Ø43.500
    fails the check as surely as losing the land would. What *is* also
    gated on this part: tooth count (20, exact) and tooth clocking (within 0.3° of the reference), both
    measured on the render directly rather than by surface distance, plus every dimension outside the
    tooth zone.
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
    720-001's reference carries a feature that was read as a similar artifact and is not one. What was
    recorded as a degenerate Ø15.5 internal shell is **twelve Ø0.2 through-holes** on a Ø15.5 circle,
    30° apart with one on +x, running the full 60.6 mm of the part. They are voids and the mesh is sound:
    every triangle around a hole has its normal on that hole's own axis, `segment` returns one closed
    body, and the lateral area over any span is π·0.2·span to three decimals. They were most of the
    2.851 mm reference→candidate number because the model did not have them; [CR-3A14](../CHANGES.md)
    reproduces them, behind a `wall_holes` flag. **They are not buildable** — Ø0.2 × 60.6 mm is 303:1,
    past drilling and far past printing — and no other part in the reference set carries anything like
    them, so whether the built shaft should have them is open under DC-11.
- The two housings (Diff Body A/B) were carried as **authored functional redesigns** rather than
  recreations — every bearing seat, journal, bore, axis position, and span taken from measurement, the
  sculpted shells replaced with clean parametric bodies, and verified by interface slice checks rather
  than shape comparison on the grounds that there was no reference shape they were meant to match.
  **That exception is withdrawn** ([CR-3A16](../CHANGES.md)). Preserving every interface did not preserve
  the part: the authored Diff Body A rendered 2.43× the reference's material in the same bounding box,
  which is mass and inertia at the worst point on the arm, and interface checks are what it passed.
  Both housings are to be faithful recreations gated on `scadmesh dist` at ±0.15 mm, with cover-envelope
  fit carried as a minimal delta in the `revised` configuration.
  **Diff Body A is rebuilt and passing** at 0.016 mm Hausdorff, 0.000% of samples over tolerance.
  **Diff Body B is rebuilt from measurement but does not yet meet the contract** ([CR-3A17](../CHANGES.md)):
  0.414 mm Hausdorff against 18.891 for the authored redesign, with p95 0.136 mm inside tolerance both
  ways and 1.2% of samples over it. It is therefore absent from `DIST_GATES`, and closing that gap is the
  one item keeping this bullet open. Its measured geometry is recorded in the part file
  [`730-002_DiffBodyB.scad`](../Hardware/Models/700-Differential/730-002_DiffBodyB.scad) — the profiles
  are the dimension tables — together with the three residuals still outstanding. Two premises of the
  authored Body B are disproved there: the `TUNNEL_Y` span is the J4 mating rim's diameter rather than a
  tunnel, and there is no bore on the Y axis at all. The shaft tunnel runs along **X**, on the J4 axis,
  and the part is a body of revolution about it rather than the fork an earlier reading took it for.
- Tooth counts verified on the renders: three 20T bevels (1:1:1), two 40T GT2 pulleys, 100 encoder slots.
  These passed and are unaffected — a tooth count is not a shape claim.
- The assembly is evaluated in both configurations, which fires its assertions: the J4/J5 axes intersect,
  the L4 split resolves to the firmware's 59.50 mm, and the revised body fits the cover envelope. These
  also passed and are unaffected, being parameter assertions rather than geometry comparisons.

**Resolved in favor of faithful recreation.** This item was carried open while parts remained unrebuilt:
the faithful-recreation stage was premised on the reference STLs being trustworthy part geometry, and
they are artifact-laden assembly exports, so recreating them exactly might have been the wrong goal —
authoring directly to the revised interface and dropping the clone target was the alternative. All seven
parts are now rebuilt, each documenting its own reference's artifacts explicitly (above) rather than
being thrown off by them, so the artifacts turned out not to make faithful recreation the wrong goal —
they made it a goal that needed `dist` and `segment` rather than `compare` to verify correctly.

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

### What assembling the set showed

The nine parts were verified individually against their references long before they were ever placed
together. Assembling them is a different check and it found things the per-part gate cannot see, because
a part can match its own reference to a hundredth of a millimetre and still not fit its neighbours.
`diff_assembly.scad` now places every part by a feature it carries rather than by a typed offset, and
records each of the following at the point in the file that exposes it.

**Confirmed.** The three bevels mesh. All three are one crown ([`diff_bevel.scad`](../Hardware/Models/700-Differential/diff_bevel.scad)), a bevel set
meshes exactly when its apexes coincide, and each part states where that apex sits on its own axis, so
placing the parts by those three numbers is the whole of the gear train. Checked rather than asserted: the
CGAL intersection of the Split Gear against the Diff Gear Axle, and against the Diff Gear Shaft, is **empty
in both cases** — as is the intersection of whole 20T crowns substituted for both side bevels, whose tips
are longer than the shaft's cut ones and so is the stronger result.

**Confirmed: the Split Gear's halves need no relative transform.** `#710-001` and `#710-002` are authored
in the same frame — the same apex, `#710-002`'s Ø27 wall inside `#710-001`'s Ø28 cavity, its bottom face on
`#710-001`'s Ø23 seat floor at z 4.000 — and their intersection is a set of open shells enclosing
**exactly 0.000 mm³ apiece** (`scadmesh segment`), bounded by the seating face at z = 4.000 and by
`BEVEL_SPLIT_ROOT` at (14.903, 21.903), both construction points rather than accidents. They meet face to
face with no interference at all. A previous revision of the assembly mirrored one half against the other,
which cannot be right: mirrored about the shared apex the two crowns do not overlap anywhere.

**The brad holes disagreed by 0.5 mm; the revised config drills them on one axis.**
[008.6](008-Assembly.md#0086-differential) steps 7–9 lock the two halves together by driving `#680-001`
brads through four radial holes, and the two references do not put those holes in the same place. Measured
on the rendered meshes (`scadmesh planes --axis z`), `#710-001`'s hole runs z 11.534–12.943 and
`#710-002`'s z 12.089–13.456, centres 12.24 against 12.77. That leaves about 1.0 mm of common opening for a
Ø1.5 hole taking a Ø1.8 interference-fit brad. **Neither half can move to fix it** — the coincident faces
above fix their relative position exactly, and the gear geometry fixes it again — so this is a disagreement
between the two references, not a placement error, and the only thing free to move is the hole.

It moves in `config="revised"`, where both halves drill at **z = 12.750**; `config="previous"` keeps each
reference's own value, since that is what the reference comparison measures. The axis is stated once, as
`BRAD_Z` in `diff_params.scad`, because it belongs to neither half — a brad has to pass through `#710-001`'s
cage and land in `#710-002`'s blind hole, so one line serves both. **12.750 is the height kept** for two
reasons: it is the one both parts have material for (it leaves a full millimetre of `#710-002`'s Ø27 wall
below the hole, where 12.250 would leave 0.500 mm, while `#710-001`'s cage tube spans z 9.990–16.010 and
takes either), and it is the blind, glued half — the one whose hole actually holds the brad, so not the one
that should move. Verified by intersecting a Ø1.45 probe on that axis, from `#710-002`'s drilled floor at
r 12.000 outward, with both halves as they sit in the assembly: **empty in `revised`, and not empty in
`previous`**, which is the same check reporting the fault it was written to catch. `diff_assembly.scad`
draws the four brads — r 12.000 to 17.500, a 5.5 mm bite against 008.6 step 9's "~6 mm deep" — when and only
when both halves drill to one line, so the previous config's assembly still shows the disagreement by
leaving them out.

**Open: three bought parts have no seat.** The needle thrust stack, the MR85, and the fifth 6703 — see
[DC-11(e)](#procurement-data), where they are recorded with what each one's absence would cost.

**Recorded: three stack-ups.** The Diff Gear Axle's Ø9 boss reaches 1.34 mm into the shaft's front MR128
seat; Diff Body B's -X end flank sits 0.276 mm inside the axle bevel's toe cone, and its chimney cone
0.296 mm inside the Split Gear's, both being the same 45-degree relief on perpendicular axes. The two
0.28 mm figures cannot both be removed by moving Body B, since the differential centre has to lie on both
of its axes, and all three are the size of the residuals these parts already carry — `#730-002`'s own gate
is 0.414 mm. They are kept as measurements rather than designed out.

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

**While measuring the End Arm Hub, measure both ends of the L3 span, not just the socket.** The hub's own
axial offset is now measured — its tube socket axis lies at z = −25.000 and its top face at z = +4.000 on
`420-001_EndArmHub.stl`, **29.000 mm** apart — so what is missing is the *other* end: **where the L3 tube
meets Diff Body A**. Nothing in the 700 set shows it. Body A presents a 20 × 20 R4 arm with a flat tip,
two M3 screws at (−25, ±8.7) and two Ø4 pins at (−32.6, ±4), and the tube it is supposed to meet is
catalogued above as **0.75″ square** — those do not obviously fit one another, and until they are
reconciled the L3 cut length and L4's lower datum are both resting on the same unchecked joint. This
paragraph previously asked instead for a "J4 standoff" the hub must provide against Diff Body A's mating
face; there is no such face, since the two parts are a whole L3 apart — see
[DC-6](#link-length-discrepancy-l4).

## Link-length discrepancy (L4)
**DC-6 · P2 · Requirement: REQ-WS-6 · Specified in [003](003-Kinematics.md#link-lengths)**

Link-length records disagree on L4, and no unit exists to arbitrate them:

| Source | L4 | L5 |
|---|---|---|
| `Firmware/Defaults.make_ins` — **authoritative** | 59.50 mm | 82.44 mm |
| Wiki | 50.95 mm | 82.55 mm |
| CAD frame separation, per [004 § Differential interface](004-Mechanical-Architecture.md#differential-interface) | 39.50 mm along the arm axis (44.27 mm in 3D) | — |

**State — the authored design now supplies a fourth figure, and it does not land on the firmware's.** With
no serialized unit available to measure (see **Sources of record** above), L4 became a **design output**:
whatever the differential authored under [DC-2](#differential-detail-design) places between the J4 and J5
axes. It has now been computed from that design rather than assumed. The wrist axes intersect at the
differential centre (consistent with the DH set's `a ≈ 0`), so L4 is an offset **along the J4 axis**, from
where L3 lands on it up to that centre:

| L4 reading | Value | Kind |
|---|---|---|
| **DC-2 design, as built** | **37.53 mm** | derived geometry (`diff_assembly.scad`) |
| CAD kinematic frames | 39.50 mm | measured on the GLTF |
| Measured DH set, J4 row `d` | 39.30 mm | measured on HDI-007010 |
| Wiki | 50.95 mm | record |
| Firmware — authoritative | 59.50 mm | record |

**The three geometric readings agree to within 2.0 mm; the firmware's is 22 mm from all of them.** That
reframes this item. It is no longer a design gap to close by adding standoff somewhere until 59.50 is
reached — the wrist DC-2 authored, built from measured parts, is a ~37.5 mm wrist, and two independent
kinematic sources say the real robot's is too. `diff_assembly.scad` echoes all of these and asserts the
built figure stays beside the geometric cluster, so a later frame edit cannot quietly drift it toward the
firmware value.

**One assumption carries the built figure, and it is the thing to check first.** The upper datum is solid:
`C = 48.5335 mm` above Diff Body A's base plane, derived from the Diff Gear Shaft's bevel apex, whose height
three separate seats in Body A fix in agreement (the rear 6703 face on the Ø20 waist shoulder, the Ø27
collar 4 mm above the Ø26 step, and the 40T pulley band centred on the belt slot). The lower datum is **Body
A's arm centreline at z = 11.000** — where its 20 × 20 R4 section, its 6 × 6 belt slot and its
mirror-symmetric shell all centre. Taking that as the plane where L3 meets the J4 axis gives
48.5335 − 11.000 = 37.53 mm. **Nothing in the 700 set shows the L3 tube landing on it**, and per
[DC-5](#link-member-lengths) that tube is catalogued as 0.75″ square against Body A's 20 × 20 arm, which do
not obviously fit one another. Settle that joint and this figure either firms up or moves.

**Two superseded splits, recorded so they are not re-derived.** This item previously read 31.0 + 28.5 mm and
then, on 2026-08-19, 48.53 + 10.97 mm — in both cases a differential contribution plus a standoff the **End
Arm Hub** was said to owe against Diff Body A's mating face. Two separate errors sat in that. The
differential's half was a typed constant in a hand-placed assembly (the Diff Gear Shaft laid along the wrong
axis, the Split Gear halves mirrored apart), which is what the 2026-08-19 rework fixed. The decomposition
itself was wrong in both versions: **the End Arm Hub is at the elbow, a whole L3 away from the
differential**, as [004 § End Arm Hub](004-Mechanical-Architecture.md#end-arm-hub-j3j4-region) describes it
and as its own tooling shows — `GlueRig_EndArmHubToDiff_A`+`_B` span 362 mm and
`GlueRig_ArmBodyToEndArmHub_A`+`_B` span 405 mm, both long jigs holding parts at opposite ends of a tube.
The two parts share no mating face, so there was never a split to make there and no standoff for the hub to
owe. The 28.5 mm once credited to it is a real feature — the hub's tube socket axis at z = −25.000 and its
top face at z = +4.000, **29.000 mm** apart on `420-001_EndArmHub.stl` — but it is an offset at the **L3
end**.

Neither measured source is decisive alone. The DH model of HDI-007010
([003](003-Kinematics.md#denavithartenberg-model)) carries the wrist in frame `d` offsets (J4 `d` = 39.3 mm,
J5 `d` = 55.6 mm) because the axes intersect, and those do not map 1:1 onto a link length; a GLTF
kinematic-assembly node origin need not sit exactly on the joint axis either. What makes them worth more
than either is that they are independent of each other and now of a third, and all three land together.

**Definition of done:** settle where L3 meets the J4 axis in Diff Body A — the one open datum above, shared
with [DC-5](#link-member-lengths) — then confirm the wrist by caliper on the first build and reconcile the
records to it, updating [003](003-Kinematics.md#link-lengths) and the firmware file if the built value
differs. The geometric evidence now points at that reconciliation going **against** the firmware's 59.50 mm
rather than at a design that must reach it; until a physical measurement says so, the firmware file still
stands as the record. `[TBD]`.

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
bore and survives J5's full travel, and both code disks read cleanly through their shrouds — J5's off
`#710-004` and J4's off the track on Diff Body B's rim
([DC-11(e)](#the-j4-code-disk-is-missing)). Print-fit parameters
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
| e | **CAD-vs-BOM mismatches** ([007.2](007.2-Printed-Parts.md#model-vs-bom-discrepancies)) | `HDI-311-006C_J2StatorHolderCap_ConeDrive` is in the CAD model but has no BOM row; `HDI-610-006_MotorShaftCoupler` is instanced 4× where the BOM calls for 3. **Plus two found while authoring [DC-2](#differential-detail-design):** (i) [007.6](007-Bill-of-Materials.md#0076-differential) lists **5 × `#720-005` 60 × 4.4 × 1.5 mm CF strakes** in the differential, but no step in [008.6](008-Assembly.md#0086-differential) places them and no 4.4 × 1.5 mm slot appears anywhere in the differential's measured geometry (only the three 25 mm `#710-005` strakes, in the Split Gear Bottom, are both slotted and placed); (ii) **resolved — the J4 code disk is not a part at all**, its 115-slot track being cut into `#730-002`'s mating rim, so the BOM is not short a row — see [the note below](#the-j4-code-disk-is-missing). **Plus three found while placing `diff_assembly.scad`,** where every bought part was drawn into the seat it occupies and three had no seat to go to: (iii) the **needle thrust stack** (`#710-006` AXK0819 + 2 × AS0819, Ø19 OD) that [008.6](008-Assembly.md#0086-differential) step 5 puts on Diff Body B's Ø8 tube — nothing along that tube has a bore wide enough, the only Ø ≥ 19 bore in the Split Gear being `#710-001`'s Ø23 pocket, which `#710-002`'s Ø17 stub already fills; (iv) `#620-001` **MR85** (5 × 8 × 2.5), catalogued "Diff Gear Axle back" — `#720-002`'s only bore is the Ø8 the CF rod occupies, and no Ø5 feature exists anywhere in the differential for its inner race; (v) the **fifth 6703**, which by elimination is that Ø23 pocket (an r 8.5–11.5 × 4.25 mm annulus, floored exactly where `#710-002` bottoms on `#710-001` — a 6703 section to a hundredth), except that both of its races belong to parts the brads lock together, so nothing there turns relative to anything | Five fabricated parts with no home; three bought parts ordered with nowhere to fit |
| f | **Defective model file** (`#710-002`, [007.2](007.2-Printed-Parts.md#differential--0076)) — ✔ **closed** | The file was **~1000× oversize** (exporter unit slip; its header read `STLB ASM 217.00.00.5800` vs neighbours' `220.00.00.0000`). The factor was detected as **exactly 1/1000** (`scadmesh scale --ref-dim 23.0`, zero residual against the 6703 seat), applied in place, and the corrected part verified against its mates: Ø23.000 6703 seat, Ø12.000 MR128 seat, Ø28.06 press bore receiving the Split Gear Top's Ø28.00, brad circle matching the Top's windows. Old SHA-256 `c20e30d1…a853af`, corrected `e746f42f…9cb3662`. The part now also has parametric source (`710-002_SplitGearBottom.scad`, [DC-2](#differential-detail-design)) | — |

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
envelope; (b) fan size, voltage, and part number specified against the Fan Bracket; (c) the Belt Director
type settled and the affected rows corrected in [007](007-Bill-of-Materials.md)/[007.2](007.2-Printed-Parts.md);
(d) a published print profile validated on a bearing bore and a strake slot; (e) both CAD-vs-BOM mismatches
adjudicated against the model set; (f) **done** — the rescaled, mate-verified STL and its parametric source
are committed (see row f); and [007.2](007.2-Printed-Parts.md) carrying per-part model links now that the
model set is mirrored in [`Hardware/Models/`](../Hardware/Models/README.md). None of these blocks starting
the long-lead items in [DC-1](#strain-wave-component-set). `[Provisional]`.
