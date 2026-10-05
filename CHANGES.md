# Dexter — Change History

The design history of the Dexter specification, one section per revision, newest first. Each section
records what changed in that revision and why, so the file read top to bottom is the history of the design
and read bottom to top is how the current machine came to be.

- **What a version and a revision are**, how each is branched and tagged, and the procedure for authoring
  the next one: [specs/010-Versioning.md](specs/010-Versioning.md).
- **What is planned but not yet opened as a revision**: [specs/011-Roadmap.md](specs/011-Roadmap.md).
- **What is still open on the current revision**: [specs/009-Design-Completion.md](specs/009-Design-Completion.md).

Each change is a `CR-<version><revision-letter><n>` entry in the format defined in
[010 §5](specs/010-Versioning.md#5-change-record-format). Change IDs are permanent: once published they are
not renumbered or reused, so a superseded change is amended by a later entry rather than edited away.
Statuses carry the meaning defined in [specs/README.md](specs/README.md#design-status) and are recorded as
of the revision's release.

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
- **Note:** Version 2's driven pulley set is not compatible with the new `AxisCal`; see
  [DC-12](specs/009-Design-Completion.md#wrist-pulley-rework) before reusing wrist pulleys.

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
- **Was:** Link lengths L1–L5 = 228.60 / 320.68 / 330.20 / 50.80 / 82.55 mm. *(This entry originally
  attributed them to version 2; they are **version 1**'s — see
  [CR-3A10](#cr-3a10-l2l3-cut-lengths-corrected-the-comparison-link-set-identified-as-version-1).)*
- **Now:** Link lengths L1–L5 = 235.20 / 339.09 / 307.50 / 59.50 / 82.44 mm (deltas +6.60, +18.42,
  −22.70, +8.70, −0.11 mm). L5 is unchanged within tolerance, consistent with the cross-version tool
  interface.
- **Driver:** Revised arm geometry.
- **Status:** `[Specified]` for the link lengths themselves (source: `Firmware/Defaults.make_ins`). The
  tube cut lengths this entry derived from the deltas above are superseded by
  [CR-3A10](#cr-3a10-l2l3-cut-lengths-corrected-the-comparison-link-set-identified-as-version-1).
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

### CR-3A6: Parts catalog and printed-parts list added; BOM made orderable

- **Affects:** [007](specs/007-Bill-of-Materials.md), new [007.1](specs/007.1-Parts-Catalog.md) and
  [007.2](specs/007.2-Printed-Parts.md), [009](specs/009-Design-Completion.md),
  [specs/README.md](specs/README.md)
- **Was:** [007](specs/007-Bill-of-Materials.md) listed parts by subassembly with generic descriptions
  ("NEMA-17 stepper", "6810 bearing") and no supplier links. Carbon fiber referenced dead DragonPlate
  `pID=###` identifiers that could not be resolved to any current product. Parts recurring across
  subassemblies had to be summed by hand, and the aggregate table's totals disagreed with the sum of its own
  rows in eight places.
- **Now:** Two derived documents make the design orderable.
  [007.1](specs/007.1-Parts-Catalog.md) is the de-duplicated purchase list for one robot — every bought or
  fabricated item once, with the full specification needed to order correctly and at least one supplier link
  (Canadian first, then US, then elsewhere). [007.2](specs/007.2-Printed-Parts.md) is the de-duplicated
  print list — 109 pieces across 70 distinct parts — with model-file sources. Both carry a regeneration
  procedure. The three carbon fiber cross-sections are resolved to current DragonPlate stock
  (**.125″ × .500″**, **.092″ × .220″**, **.057″ × .177″**), and the metric dimensions in
  [007](specs/007-Bill-of-Materials.md) are recorded as nominal descriptions of imperial pultrusions rather
  than independent specifications. The MicroZed is pinned to `AES-Z7MB-7Z020-SOM-G`, and the AXK0819 thrust
  bearing's conflicting "1/4″" descriptor is corrected to its true 8 mm bore.
- **Driver:** A bill of materials that cannot be ordered from is not a buildable design. Generic part
  descriptions admit wrong parts — "NEMA 17" alone matches over a hundred motors, most of them 1.8°, which
  would silently halve every joint's resolution.
- **Status:** `[Specified]` for the catalog structure and the resolved carbon fiber, MicroZed, and bearing
  identities; `[Provisional]` for five part identities that could not be pinned from the design record,
  collected as [DC-11](specs/009-Design-Completion.md#procurement-data).
- **Re-derive:** 007.1 and 007.2 whenever 007 changes; both documents state the procedure.
- **Note:** Eight aggregate quantities in [007](specs/007-Bill-of-Materials.md) were corrected against the
  sum of its own subassembly rows — most caused by
  [007.3](specs/007-Bill-of-Materials.md#0073-harmonic-drive-motors) being quoted per motor and built twice.
  Anyone who ordered against the previous aggregate table should re-check
  [Corrections to 007](specs/007.1-Parts-Catalog.md#corrections-to-007).

### CR-3A7: Differential detail design authored as parametric OpenSCAD

- **Affects:** [004 §Wrist and differential](specs/004-Mechanical-Architecture.md#wrist-and-differential-j4j5),
  [003 §Link lengths](specs/003-Kinematics.md#link-lengths),
  [007.2 §Differential](specs/007.2-Printed-Parts.md#differential--0076),
  [008.6](specs/008-Assembly.md#0086-differential),
  [009 DC-2/DC-5/DC-6/DC-9/DC-11](specs/009-Design-Completion.md),
  new source in [`Hardware/Models/700-Differential/`](Hardware/Models/700-Differential/)
- **Was:** The differential's internal geometry existed only as the previous version's nine mesh STLs — one
  of them ~1000× oversize, all of them CAD *assembly* exports — with no editable source. DC-2 was the
  largest open item in [009](specs/009-Design-Completion.md); 004 carried the differential detail as
  `[Provisional]`, to be authored rather than recovered; L4 was a 59.50 mm firmware figure the wrist had yet
  to realize; and J4 was credited with a 115-slot code disk.
- **Now:** Every differential part has parametric OpenSCAD source beside its mesh (BOSL2). One `.scad` per
  part, shared dimensions in `diff_params.scad`, the bevel crown in `diff_bevel.scad`, the bought items in
  `diff_hardware.scad`, and `diff_assembly.scad` standing all nine parts and their hardware up as a machine.
  Two parameter sets: `config="previous"` reproduces the built differential; `config="revised"` meets
  [004 §Differential interface](specs/004-Mechanical-Architecture.md#differential-interface) — Diff Body A
  trimmed 80.98 → 77.8 mm for the HDI-940 cover envelope, and the Split Gear's two halves drilled on one
  brad axis. `render-all.rs` renders and checks every part in both configurations; `render-meshes.rs` caches
  the nine as binary STL for the assembly to import, ~54× faster to load than ASCII and carrying more digits
  than the ASCII writer emits. The oversize `710-002` STL is corrected in place (exact 1/1000,
  mate-verified — DC-11(f) closed).
  - **All nine parts are recreations of their references, measured rather than inferred.** Each body is a
    revolve of its **measured meridional profile** (`scadmesh profile`) rather than a stack of inferred
    diameters and face heights, each renders as one closed solid, and each is held to its reference by the
    harness — the two housings included, where an authored functional redesign verified by interface checks
    alone was the earlier plan and is withdrawn. Diff Body A meets the **±0.15 mm** surface gate at
    **0.016 mm** Hausdorff with no sample out of tolerance; Diff Body B is rebuilt from measurement to
    **0.377 mm** candidate→reference and **0.332 mm** reference→candidate, p95 0.136 mm inside tolerance
    both ways, and is not yet gated — what holds it is the chimney base's four unfilleted junctions, which
    are now the worst point in both directions. The
    per-part measurements, the verification contract, and its three exception classes are in
    [DC-2](specs/009-Design-Completion.md#differential-detail-design); the recovered dimensions for each
    part are in the part's own `.scad` header and profile comments, which *are* the dimension tables.
  - **The three bevels are one gear, authored once.** Sections of Split Gear Top and Diff Gear Axle taken
    15.4484 mm apart agree to **0.0001 mm over 4088 points**, already clocked alike, and Split Gear Bottom
    supplies exactly the material inside the 45° parting cone that the Top lacks. The crown is therefore
    defined once in `diff_bevel.scad` — four measured cones and a cubic-Bézier flank, stated about the
    gear's own apex — and each part intersects it with its own envelope, contributing only where that apex
    sits on its axis. Straight bevel teeth are **ruled through the apex**, so one section drawn with
    `linear_extrude(scale=)` is the exact surface and no loft is needed. Diff Gear Shaft's reference carries
    the **previous revision of that gear** (the v1 STEP states one `CONICAL_SURFACE`, slope 1.1834163, in
    all four of its bevels; the shared gear's face cone is 1.14792, in none of them). It is cut to the
    shared crown for a matched set of four, at the cost of the one decided tooth-form exception in DC-2.
  - **The assembly places each part by a feature it already carries**, never by an offset typed a second
    time, so meshing follows from placement: three 20T crowns at 90° mesh when their pitch apexes coincide.
    Checked rather than asserted — the CGAL intersection of the Split Gear against each side bevel is
    **empty**, as it is for whole 20T crowns substituted for both, and the Split Gear's own halves enclose
    **0.000 mm³** between them, meeting face to face on the Ø23 seat floor and the parting cone.
  - **The verification contract is surface-based.** `scadmesh compare` — every reference diameter and face
    position reappearing in the candidate — is a set of one-dimensional histograms, and a solid can satisfy
    all of them and still be the wrong body: it reported 0.006–0.131 mm agreement on parts deviating by up
    to 3.8 mm, and it reported nothing at all on a housing rendering **2.43× the reference's material in an
    identical bounding box**. Parts are gated on two-sided `scadmesh dist`, on `scadmesh segment` for one
    closed solid, and on previewing as well as rendering; `compare` is retained only to name which dimension
    moved once `dist` has failed a part, with each comparison's tolerance set from its own reference's noise
    floor. **A part with no shape contract is not a part that needs less verification; it is a part whose
    verification silently does nothing.**
- **Driver:** DC-2's definition of done — an authored design with source geometry committed, replacing
  mesh-only geometry that could not be edited or checked. An incorrect flex/pivot geometry risks binding the
  joint that also carries the tool wiring through its bore.
- **Status:** `[Specified]` for the authored design and its geometric verification; the physical-build
  checks (binding, wiring survival, code-disk reads) are
  [DC-9](specs/009-Design-Completion.md#performance-characterization)'s first-build checklist.
- **Re-derive:** run `Hardware/Models/700-Differential/render-all.rs` after any `.scad` change and
  `render-meshes.rs` before opening the assembly; regenerate `PART-INDEX.md`/`MANIFEST.csv` after renders
  change committed meshes.
- **Note — five findings the authoring and the assembly produced, the first two of them requirements on
  something outside the differential:**
  1. **L4 as built is 37.53 mm**, not the firmware's 59.50. The wrist axes intersect at the differential
     centre, so L4 is an offset **along the J4 axis** — from where L3 lands on it (Diff Body A's arm
     centreline, z = 11.000) up to the centre (48.5335, fixed by three seats in Body A that agree exactly).
     That sits within 2.0 mm of the CAD frames (39.50) and of HDI-007010's DH `d` term (39.30), while the
     firmware's figure is 22 mm from all three. An earlier split of L4 into a differential contribution plus
     an End Arm Hub standoff is withdrawn: the End Arm Hub is at the **elbow**, a whole L3 from the
     differential, as its own glue rigs show. `diff_assembly.scad` asserts the geometric cluster rather than
     a decomposition; [DC-6](specs/009-Design-Completion.md#link-length-discrepancy-l4) carries the state.
  2. **J4 has no code disk.** Counting slots on every code-disk model gives J1 = 200, J2 = 180, J3 = 157 and
     J5 = 100, each matching [003](specs/003-Kinematics.md#joint-definitions) exactly, and no *disk*
     anywhere carries J4's 115. The track exists: 115 radial slots cut clean through Diff Body B's Ø58.985
     mating rim, on an exact 360/115 pitch, r 24.500–28.800, 0.800 mm wide, read across the pivot from Diff
     Body A. The BOM is not short a row
     ([DC-11(e)](specs/009-Design-Completion.md#the-j4-code-disk-is-missing)).
  3. **The two references put the Split Gear's brad holes 0.5 mm apart** on a Ø1.5 hole, and neither half
     can move to absorb it — the halves are located twice over, by their coincident faces and by the gear.
     `config="revised"` drills both at **z = 12.750**, stated once as `BRAD_Z`: the height both parts have
     material for, and the blind, glued half's own value. Proved by sweeping a Ø1.45 probe along the axis
     and intersecting it with both halves — empty under `revised`, not empty under `previous`.
  4. **Three bought parts have no seat** — the needle thrust stack, the MR85, and the fifth 6703 — found by
     drawing every bought item into the seat it occupies. And the five `#720-005` 60 mm CF strakes listed in
     [007.6](specs/007-Bill-of-Materials.md#0076-differential) are placed by no assembly step and fit no
     slot in the measured geometry. All recorded under
     [DC-11(e)](specs/009-Design-Completion.md#procurement-data).
  5. **The reference meshes are assembly exports and carry features a clean model must not copy** —
     zero-thickness internal shells, and unmerged solids whose file volume double-counts where they
     interpenetrate and whose buried surfaces have no counterpart to measure against. Run `scadmesh segment`
     on a reference before measuring it. One feature read as an artifact is not one: the Diff Gear Shaft's
     twelve Ø0.2 × 60.6 mm through-holes are real voids and the mesh is sound, but at 303:1 they are past
     drilling and far past printing, so they sit behind a `wall_holes` flag.
- **Open:** Diff Body B does not yet meet the ±0.15 mm contract and is absent from `DIST_GATES`. What
  holds it is measured and located: the chimney base's four unfilleted junctions, now the worst point in
  both directions. Two unmodelled R1 edge breaks on the z = 34 clip have been cut along the way, taking
  the candidate side 0.414 → 0.397 → 0.377 mm; neither touches the 0.276 mm interference with the axle
  bevel's toe cone, which is on a different surface and is answered under
  [CR-3A19](#cr-3a19-l1-specified-from-the-base-stack-the-doubled-clamp-withdrawn-6810s-allocated-to-their-seats). Whether the built
  shaft should carry the Ø0.2 wall holes at all is open under DC-11(k).

### CR-3A8: Wrist tooth-count decomposition; design status consolidated into 009

- **Affects:** [004 §Wrist](specs/004-Mechanical-Architecture.md#wrist-and-differential-j4j5),
  [006 §Drive constants](specs/006-Firmware-and-Calibration.md#drive-constants-axiscal),
  [007.1 §3](specs/007.1-Parts-Catalog.md#3-belts-and-pulleys),
  [007.7](specs/007-Bill-of-Materials.md#0077-end-arm-hub),
  [007.2](specs/007.2-Printed-Parts.md#end-arm-hub-and-pulleys--0077);
  [specs/README.md](specs/README.md#document-ownership) and every document in the set.
- **Amends:** [CR-3A1](#cr-3a1-belt-reduced-wrist-j4j5) (closes
  [DC-3](specs/009-Design-Completion.md#wrist-reduction-ratio)).
- **Was:** The 13.5:1 wrist ratio was undecomposed, with no surviving record of the intended tooth split.
  Design status was also duplicated across 201 markers in 002-009, some stale — e.g. 002 still called the
  wrist reduction `[Provisional]` after this same change closed DC-3.
- **Now:**
  - Decomposed to **16T motor → 108T External** (6.75:1) → elbow 1:1 → **40T Internal → 80T differential
    input** (2.0:1) = **13.5:1** net, chosen over 90/96 and 120/72 for margin on both elbow torque and the
    differential's envelope against its cover. Belts: 1176 mm (588T) and 896 mm (448T) × 6 mm GT2 (was
    1120/900 mm) — both superseded by
    [CR-3A10](#cr-3a10-l2l3-cut-lengths-corrected-the-comparison-link-set-identified-as-version-1), which
    re-solves them at unchanged centre distances. Corrects an earlier 004 reading of the differential as
    driven directly off the motor pulley.
  - The HD model set still carries version 2's counts (90T/40T/40T) — five parts need re-cutting, tracked
    as [DC-12](specs/009-Design-Completion.md#wrist-pulley-rework).
  - Design status now owned solely by **009** ([README §Document
    ownership](specs/README.md#document-ownership)): status markers removed from 002-008, 010 and 011;
    004's and 005's status tables became open-item indexes; other stale duplicated prose (L4 splits, BOM
    mismatches, supply substitution limits, the strain-wave component list, stepper requirements, the stale
    `AxisCal.txt` note, version identity, derived-document scopes) corrected to match 009.
- **Driver:** DC-3 required the tooth split be chosen (originator out of business); a value written down
  twice eventually disagrees with itself, with nothing left to say which copy is the design.
- **Re-derive:** 007.1/007.2/007.7 done; 008.5/008.7 pending DC-12's re-cuts. No design value changed by
  the status consolidation.
- **Status:** `[Specified]` for the ratio and tooth counts; belt lengths `[Provisional]` — confirm against
  the measured centre distance before ordering. `[Specified]`/`[Provisional]`/`[TBD]` remain defined in
  [README](specs/README.md#design-status) and are applied in 009 only going forward; prior CR entries keep
  the markers they were written with.

### CR-3A9: Base mounting plate specified; two link datums withdrawn; two model mirrors replaced

- **Affects:** [004 §Base (J1)](specs/004-Mechanical-Architecture.md#base-j1),
  [007.2](specs/007-Bill-of-Materials.md#0072-base),
  [007.1 §C-509](specs/007.1-Parts-Catalog.md#c-509--base-mounting-plate-stock) and
  [§6](specs/007.1-Parts-Catalog.md#6-fasteners),
  [008.2](specs/008-Assembly.md#0082-base), [008.4](specs/008-Assembly.md#0084-main-pivot),
  [009](specs/009-Design-Completion.md); `Hardware/Models/100-Base/`, `Hardware/Models/700-Differential/`.
- **Amends:** [CR-3A2](#cr-3a2-bolted-base-and-doubled-base-clamp) (closes
  [DC-4](specs/009-Design-Completion.md#base-plate)),
  [CR-3A4](#cr-3a4-revised-link-geometry) (DC-5 seat depths, DC-6's L4 reading),
  [CR-3A7](#cr-3a7-differential-detail-design-authored-as-parametric-openscad) (reverts the Diff Body A
  trim recorded there).
- **Was:** The base plate's robot-side pattern was owed as a transfer out of CAD, with bolt size and count
  open and the doubled clamp's stacking "to be confirmed on build"; the doubled clamp was credited with
  L1's +6.6 mm growth over version 2. The adopted L2/L3 cut lengths rested on an unverified assumption
  that socket seat depth was unchanged. L4 was read as 37.53 mm off Diff Body A, and `config="revised"`
  trimmed that body 80.98 → 77.8 mm to clear the HDI-940 cover. Two mirror files held the wrong part.
- **Now:**
  - **Base plate specified and drawn.** The robot-side pattern is **8 × Ø6.000 mm** through the mount's
    150 × 150 × 10 mm flange, in pairs on its four edges at (±12.500, ±62.500) and (±62.500, ±12.500) —
    not a bolt circle, and unchanged by a 90° rotation of the robot on its plate. Each opens into a
    Ø10.000 counterbore driven from inside the base. The bolt is **M6 × 18 mm, 8 off**; as printed the
    flange is under size for it on both diameters, so the eight holes are opened on assembly to **Ø6.6
    through with a Ø11.0 counterbore**. The work-surface side is **4 × Ø6.6 mm at (±85.000, ±85.000)**,
    taking M6 bolt, washer, and nut with length set by the work surface, or a T-slot clamp on the same
    four corners; the Base Clamps carry no part of this load path. The plate is
    **`#110-004`**, authored as parametric OpenSCAD (the first part outside the differential to have
    source), emitting its own machining DXF; `check.rs` asserts its eight tapped centres against the
    mount's mesh rather than against this document, and fails on a 0.1 mm move.
  - **Doubled clamp resolved from geometry, not deferred to a build.** The clamps stack face to face on
    the mount's 97.000 mm shoulder, and because the Base Long bottoms on nothing the second clamp raises
    J2 by its full **15.000 mm**. The +6.6 mm attribution is therefore **withdrawn**: 15.000 mm is
    neither that, nor the 4.000 mm by which the CAD model falls short of firmware L1. That disagreement
    is raised as [DC-13](specs/009-Design-Completion.md#base-height-and-l1) and belongs to L1.
  - **L2/L3 seat depths validated.** Seat depth is unchanged across versions (L3 exactly, L2 by 0.011 mm).
    L3 is a **spigot, not a socket** — the hub plugs into the tube — and the 0.75″ tube's OD is **22.0 mm,
    wall ≈.038″**, not the .050″ previously assumed. The cut lengths this entry read off those seats
    (282.4 / 214.3 mm) are superseded by
    [CR-3A10](#cr-3a10-l2l3-cut-lengths-corrected-the-comparison-link-set-identified-as-version-1).
  - **L4 = 37.53 mm withdrawn.** Diff Body A's 81 mm arm is the **tool** arm, perpendicular to the L3 tube
    and in the other half of the wrist, so it cannot be where L3 lands. L4 now rests on two geometric
    readings that agree (glTF 39.5 mm, measured DH 39.3 mm) and disagree with firmware's 59.50 mm.
    **`BODY_A_LEN` reverts to 81.0 mm** in both configurations, since the envelope conflict that motivated
    the trim does not exist; `COVER_ENVELOPE` is dropped with the asserts that read it.
  - **Two model mirrors replaced.** `#200-001` Arm Body held `ArmBodyFrontStrakeMED.stl` byte for byte
    (name-prefix match), and `#110-001` Base Mount Bottom held version 2's un-bolted 6-leg strake base —
    150 × 150 × 98 mm bolted part now installed, which is what made DC-4's pattern recoverable at all.
    Both were well-formed, correctly named meshes of the wrong part, which is precisely what
    `MANIFEST.csv` cannot detect.
- **Driver:** Close DC-4 and DC-5's checks against measurement rather than assumption; stop a reading
  that two parts cannot share from propagating into L4 and into the differential's geometry.
- **Re-derive:** 007.1/007.2 done (plate stock, M6 line, M3 nut and clamp-screw counts recomputed to 45
  and 2); 008.2/008.4 unblocked; 003's L1 pending DC-13's measurement, which is queued with
  [DC-9](specs/009-Design-Completion.md#performance-characterization)'s base load check because the base
  is only apart once.
- **Status:** `[Specified]` for the base plate, its pattern, its hardware, and the clamp stack (DC-4
  closed). `[Provisional]` for L2/L3 as recorded here, superseded by
  [CR-3A10](#cr-3a10-l2l3-cut-lengths-corrected-the-comparison-link-set-identified-as-version-1). `[TBD]` for
  [L4](specs/009-Design-Completion.md#link-length-discrepancy-l4) and
  [L1](specs/009-Design-Completion.md#base-height-and-l1); the firmware file stands as the record for both
  until a unit is measured.

### CR-3A10: L2/L3 cut lengths corrected; the comparison link set identified as version 1

- **Affects:** [003 §Link lengths](specs/003-Kinematics.md#link-lengths),
  [007 §007.1](specs/007-Bill-of-Materials.md#0071-glue-rig-assembly),
  [007.5](specs/007-Bill-of-Materials.md#0075-arm-body),
  [007.7](specs/007-Bill-of-Materials.md#0077-end-arm-hub),
  [007.1 §3](specs/007.1-Parts-Catalog.md#3-belts-and-pulleys) and
  [§5](specs/007.1-Parts-Catalog.md#5-structural-composites-and-metal-stock),
  [007.2 §Tooling](specs/007.2-Printed-Parts.md#tooling--glue-rigs),
  [009](specs/009-Design-Completion.md); `Hardware/Models/PART-INDEX.md`.
- **Amends:** [CR-3A4](#cr-3a4-revised-link-geometry) (the comparison link set and the derived cut
  lengths), [CR-3A8](#cr-3a8-wrist-tooth-count-decomposition-design-status-consolidated-into-009) (both
  belt lengths), [CR-3A9](#cr-3a9-base-mounting-plate-specified-two-link-datums-withdrawn-two-model-mirrors-replaced)
  (the L2/L3 status recorded there).
- **Was:** The link-length comparison column in 003 was labelled "previous version", and the L2/L3 tube
  cut lengths were derived from it as `tube_previous + link_delta`, giving 282.4 mm and 214.3 mm. The two
  wrist belts were re-solved at centre distances carrying the same deltas. The glue rigs were recorded as
  tooling that consumes extra copies of the robot's own parts, and the eight jig bodies in `950-Tooling/`
  as possible orphans of a superseded rig design.
- **Now:**
  - **The comparison set is version 1, not version 2.** `dde/core/robot.js` carries both link sets on one
    line per link and labels them `HDI` and `ORIG DEX`. [010](specs/010-Versioning.md#1-version-lineage)
    records no link change between versions 2 and 3, so there is **no version 2 → 3 delta to apply to a
    version 2 part**, and the deltas in 003's table span two version steps.
  - **L2 = 264.0 mm and L3 = 243.0 mm** — the previous version's tubes, carried across unchanged. Both are
    re-derived against the current kinematics rather than by delta: L2 closes stop to stop at
    37.513 + 264.000 + 37.500 = **339.013 mm** against the firmware's 339.092, and L3's far face sits
    28.500 + 243.000 = 271.500 mm from J3, putting its stop 36.000 mm short of a J4 axis that both the
    firmware and the CAD model place at 307.500 mm. The superseded figures would have left L2 18.4 mm long
    and L3 22.7 mm short.
  - **L2's far end is `#410-001` Axis Intersection Half**, whose Ø42.000 mm J3 bore and blind 29.000 mm
    channel end at −37.500 mm are measured on the part. It was previously believed to be
    `HDI-330-002_ArmBodyHubB`, a clamp half with no file; that part is the clamp at the same joint, with
    its node origin on the J3 axis.
  - **Belts re-solved at unchanged centre distances: 1140 mm (570T) and 940 mm (470T)** × 6 mm GT2,
    replacing 1176 mm and 896 mm. Only the tooth counts move the length.
  - **The glue rigs resolved as tooling.** Each of the eight jig bodies is a trough holding both ends of
    one bonded span at its finished spacing, with the negative of the part it seats at each end — which is
    how L2's far end was identified. They consume **no** extra copies of robot parts; 007's 007.1
    subassembly, 007.1 §8 and 007.2's tooling total are corrected accordingly, and
    [C-404](specs/007.1-Parts-Catalog.md#4-bearings)'s *(+2 tooling)* 6703s drop — the catalog quantity is
    **10**, unchanged.
- **Driver:** A cut length is unrecoverable if it is short, and the derivation that set both rested on a
  column whose provenance had never been traced to a source file.
- **Re-derive:** 007/007.1/007.2 done (cut lengths, belt lengths, CF stock figures, tooling totals);
  008's belt-fitting step updated to the new lengths.
- **Status:** `[Specified]` for both cut lengths and for the glue rigs
  ([DC-5](specs/009-Design-Completion.md#link-member-lengths) closed). `[Provisional]` for the two belt
  lengths, which still stand on a routing no file places
  ([DC-3](specs/009-Design-Completion.md#wrist-reduction-ratio)). The part at L3's far end remains absent
  from the model set ([DC-11(h)](specs/009-Design-Completion.md#procurement-data)); no cut length depends
  on it.

### CR-3A11: Work-surface fastener specified

- **Affects:** [004 §Base mounting plate](specs/004-Mechanical-Architecture.md#base-mounting-plate),
  [007 §007.2](specs/007-Bill-of-Materials.md#0072-base),
  [007.1 §6](specs/007.1-Parts-Catalog.md#6-fasteners),
  [008 §008.2](specs/008-Assembly.md#0082-base).
- **Amends:** [CR-3A9](#cr-3a9-base-mounting-plate-specified-two-link-datums-withdrawn-two-model-mirrors-replaced)
  (the plate-to-bench fastener).
- **Was:** "M6 bolt, washer, and nut, 4 sets", with length "to suit the work surface" and no property
  class — not orderable as written.
- **Now:** **M6, property class 8.8 or better, one plain washer under the head and one under the nut,
  4 sets.** Length is **9.5 mm plate + work-surface thickness + 12 mm**, rounded up to a stock length. The
  work surface must give access to its underside for the nuts; where it does not, the T-slot clamp
  alternative already recorded in 004 applies.
- **Driver:** The four corner fasteners are the plate's only tie to the bench and carry ≈300 N at the far
  bolt; the entry did not state a class, a length rule, or what to do on a bench with no underside access.
- **Re-derive:** 007/007.1 fastener rows done.
- **Status:** `[Specified]`.

### CR-3A12: L4 specified along the arm; the DH `d` corroboration withdrawn

- **Affects:** [003 §Link lengths](specs/003-Kinematics.md#link-lengths),
  [§DH model](specs/003-Kinematics.md#denavithartenberg-model) and
  [§Workspace envelope](specs/003-Kinematics.md#workspace-envelope),
  [002 §2](specs/002-Requirements.md#2-kinematic-and-workspace-requirements),
  [004 §Differential interface](specs/004-Mechanical-Architecture.md#differential-interface),
  [006 §Firmware defaults](specs/006-Firmware-and-Calibration.md#firmware-defaults-defaultsmake_ins),
  [009](specs/009-Design-Completion.md).
- **Amends:** [CR-3A4](#cr-3a4-revised-link-geometry) (L4's value),
  [CR-3A8](#cr-3a8-wrist-tooth-count-decomposition-design-status-consolidated-into-009) (note 1's
  corroboration of the 37.53 mm reading),
  [CR-3A9](#cr-3a9-base-mounting-plate-specified-two-link-datums-withdrawn-two-model-mirrors-replaced)
  (L4's `[TBD]` status, the two readings recorded there as agreeing, and the firmware file standing as its
  record).
- **Was:** L4 = 59.50 mm on the authority of `Firmware/Defaults.make_ins`, with three competing readings
  open against it — the wiki's 50.95 mm, the CAD kinematic frames' 39.50 mm, and HDI-007010's DH `d` term
  at 39.30 mm — the last two held to be independent geometric readings agreeing to within 0.2 mm. Closing
  the item was owed a caliper measurement on a first build, and a datum that the model set could not reach.
- **Now:**
  - **L4 = 39.50 mm, and link lengths are along-arm components.** The `DexterHDI_Link*_KinematicAssembly`
    origins in `dde/HDIMeterModel.gltf` place each joint station on the arm axis with an offset across it.
    Taking the along-arm component alone reproduces the firmware's L3 to the micron (307.5000 against
    307.500) and its L2 to 3 µm (339.0945 against 339.092). Under that convention the J4 → J5 span reads
    **39.500 mm along the arm, −20.000 mm across it**, so L4 = 39.50 mm.
  - **The firmware's 59.50 mm is the two components added together** — 39.500 + 20.000 — and is neither
    the along-arm component nor the 44.275 mm distance between the two stations. `Defaults.make_ins` needs
    `39500` in that field; every other field stands.
  - **The DH `d` corroboration is withdrawn.** J2, J3 and J4 are parallel pitch axes (α = 180.43° and
    0.81° on the J2 and J3 rows), and between parallel axes the common normal has no determined position,
    so `d` on the rows that follow them is a fit parameter, not a measured offset. The J4 row's
    `d` = 39.300 mm is not a reading of L4 and its closeness to 39.50 mm is coincidence; that row's
    `a` = −0.000049 m is what it does say, which is that the wrist axes intersect. The DH set's **`a`**
    terms remain the cross-check on L2, L3 and L5.
  - **The wiki's pair is version 1's set** — L5 identical to 0.001 mm, L4 within 0.15 mm of version 1's
    2.000 in — not an alternate reading of this version, so it competes with nothing.
  - **The open datum is settled.** Where L3 lands on the J4 axis is the J4 station, which the same chain
    places 307.500 mm along the arm from J3. It never depended on the bracket that carries the
    differential off the L3 tube, which remains absent from the model set
    ([DC-11(h)](specs/009-Design-Completion.md#procurement-data)).
- **Driver:** The item could not be closed while its two supporting readings were believed to measure the
  same quantity, and the firmware field it disagrees with silently displaces every commanded Cartesian
  position by the error.
- **Re-derive:** 004's differential-interface prose done (the frame separation now reads as L4; the
  withdrawn 37.53 mm decomposition and its narrative are gone); 006's `LinkLengths` block carries `39500`
  with the deviation from the shipped file called out; the derived maximum reach falls 20.00 mm to
  **≈ 0.77 m** in 003 § Workspace envelope and REQ-WS-6; 009's DC-6 closed and its measurement moved to
  [DC-9](specs/009-Design-Completion.md#performance-characterization). No cut length, belt length, or
  printed part derives from L4.
- **Status:** `[Specified]` for L4 and for the along-arm convention
  ([DC-6](specs/009-Design-Completion.md#link-length-discrepancy-l4) closed). The built J4 → J5 station
  separation is measured with DC-9's first-build checks; L1 remains `[TBD]` under
  [DC-13](specs/009-Design-Completion.md#base-height-and-l1), where the same convention makes the 4.000 mm
  a disagreement over the base stack.

### CR-3A13: Motor Control PCB connector map recovered from the schematic

- **Affects:** [005 §Boards](specs/005-Electronics-and-Control.md#boards),
  [005 §Power](specs/005-Electronics-and-Control.md#power),
  [005 §Tool interface wiring](specs/005-Electronics-and-Control.md#tool-interface-wiring),
  [007.1 §7](specs/007.1-Parts-Catalog.md#7-electronics-and-wiring),
  [008 §008.10](specs/008-Assembly.md#00810-wire-harness),
  [009](specs/009-Design-Completion.md).
- **Was:** The board's connectors were given as four groups — `J1`–`J6`/`J24` motor screw terminals,
  `J7`–`J13` opto headers, `J14`–`J17` tool headers, `J19`–`J21` power — with no map from a connector to
  the joint it serves, and a tool conductor's landing named only for White, as "the 2nd-from-top '−' screw
  terminal". The logic rails were said to derive from the motor rail, and `D3`/`D4` to be the input
  rectification.
- **Now:** Every connector on the board is mapped in [005 §Boards](specs/005-Electronics-and-Control.md#boards)
  from the schematic (`Hardware/09011-00135-A.PDF`), and each of the six tool conductors carries its board
  landing in [005 §Tool interface wiring](specs/005-Electronics-and-Control.md#tool-interface-wiring).
  Four of the earlier groupings were wrong: `J24` is the main power input (`VIN1`/`GND1`/`VIN2`/`GND2`),
  not a seventh motor terminal; `J9` is the MicroZed `JX2` carrier connector, not an opto header;
  `J14`–`J17` are the differential analog inputs `ANA_1`–`ANA_4`, not tool headers; and `J19`–`J21` are the
  debug port and the two FPGA `AUX` pairs, not power. **The board's channel order is the firmware's axis
  order — Base, End, Pivot, Angle, Rotate — so the Pivot and End channels cross over relative to joint
  number**, and the opto headers run in a third order again. `U1`/`U2` buck the logic rails from the input
  rail ahead of the boost; `D3`/`D4` are those bucks' catch diodes, which is what the "D3/D4 fix" naming
  this board revision corrects, and `D6` is the input series Schottky.
- **Driver:** [DC-7](specs/009-Design-Completion.md#motor-control-pcb) closes on a physical power-on test,
  and the specification did not say where a single wire goes. Wiring by connector number rather than by
  joint name drives two joints from each other's channels, and the White conductor's landing — the one
  cross-version hazard on this board — could not be checked before power without the schematic.
- **Re-derive:** [008.10](specs/008-Assembly.md#00810-wire-harness) gains the opto-jumper, motor, and opto
  landing steps it did not have; DC-7's definition of done is now the power-on procedure itself;
  [DC-11(b)](specs/009-Design-Completion.md#procurement-data) and
  [C-716](specs/007.1-Parts-Catalog.md#7-electronics-and-wiring) narrow to fan size and part number, the
  board side being settled, with the rail at `J23` read during DC-7's test.
- **Status:** `[Specified]` for the connector map, the harness landings, and the rail derivation.
  [DC-7](specs/009-Design-Completion.md#motor-control-pcb) stays `[Provisional]`: nothing here substitutes
  for running a unit on the board.

### CR-3A14: Power supply, its inlet connector, and the supply wiring specified

- **Affects:** [002 §REQ-CTL-5](specs/002-Requirements.md),
  [005 §Power](specs/005-Electronics-and-Control.md#power),
  [007 §007.10](specs/007-Bill-of-Materials.md#00710-wire-harness),
  [007.1 §C-103](specs/007.1-Parts-Catalog.md#c-103--power-supply-36-v-dc) and §7 (C-714, C-715, C-718),
  [008 §008.10](specs/008-Assembly.md#00810-wire-harness),
  [009 §DC-11](specs/009-Design-Completion.md#procurement-data) and
  [§DC-14](specs/009-Design-Completion.md#power-inlet-mounting),
  [011 item 3](specs/011-Roadmap.md).
- **Was:** The rating read **36 V / 4 A** as a fixed figure in the requirement, in 005, and in the bill of
  materials, while the catalog read **≥ 4 A** and recommended a 4.44 A part — so the recommended supply did
  not meet the rating as the other three documents stated it. C-103 specified the supply as carrying "a DC
  barrel plug" and sent the builder to [C-712](specs/007.1-Parts-Catalog.md#7-electronics-and-wiring) for
  the mating part and to C-711/C-712 to fit the connector; those are the tool 3-pin connector and square
  pin header stock. No supply model was named, [C-715](specs/007.1-Parts-Catalog.md#7-electronics-and-wiring)
  was "match to the PSU plug you order" and unorderable, [008.10](specs/008-Assembly.md#00810-wire-harness)
  step 9 landed power wires on `J24` without ever terminating their other end, and no mains cord appeared
  in any list. [DC-8](specs/009-Design-Completion.md#power-supply) was closed and the connector was booked
  nowhere.
- **Now:** The rating is **36 V DC, ≥ 4 A (≈144 W)** in all four documents, the current being a floor the
  supply must meet rather than a figure it must equal. The supply of record is **MEAN WELL
  `GST160A36-R7B`**, whose `-R7B` order suffix *is* its plug code: a **KYCON `KPPX-4P` equivalent 4-pin
  DIN**, pins 1/4 `+Vo` and 2/3 `−Vo`. **The barrel-plug premise is withdrawn** — C-103 had asserted a
  connector its own candidate does not have. The inlet is that plug's snap-and-lock mate, KYCON
  **`KPJX-PM-4S`** (48 V DC, 7.5 A per pin), and 008.10 step 9 now lands both pins of each polarity and
  mounts the receptacle before wiring `J24`. Two dependent corrections follow: the inlet wire goes to
  **18 AWG**, C-715's datasheet specifying #18 for its power pins where the inherited 24 AWG is undersized
  for a 4 A rail; and an **IEC C13 line cord** ([C-718](specs/007.1-Parts-Catalog.md#7-electronics-and-wiring))
  joins the bill, the adapter having a C14 inlet and shipping without one. 005 records that under-voltage
  does not damage the board — it degrades motion — so only the 38 V ceiling is a damage limit, and carries
  the converse hazard the source warns of: this supply into a laptop expecting 12 V or 24 V can destroy
  the laptop.
- **Driver:** A builder pricing the supply could not tell whether a 4.44 A brick was over-rated or out of
  spec, and following C-103's connector references ordered the wrong two parts — for a plug the supply
  does not carry. Retention drove the connector choice over a barrel jack: the arm moves under power.
- **Re-derive:** [007.10](specs/007-Bill-of-Materials.md#00710-wire-harness) gains a mains-cord row and
  carries the new gauge on `#840-001`; [008.10](specs/008-Assembly.md#00810-wire-harness) step 9 is
  rewritten; [DC-11(j)](specs/009-Design-Completion.md#procurement-data) closes, and closing it opens
  [DC-14](specs/009-Design-Completion.md#power-inlet-mounting) — the receptacle is panel-mount and nothing
  in the build list carries a panel.
- **Status:** `[Specified]`. [DC-8](specs/009-Design-Completion.md#power-supply) never covered the
  connector — it closed on the rating, and stays closed on it.
- **Note:** USB-C PD 3.1 EPR supplies 36 V natively and was evaluated as the inlet. It does not fit this
  board — EPR's expected maximum at 36 V nominal is 38.3 V against the `LTC3786`'s 38 V, an unclamped
  disconnect transient reaches 44.3 V, and EPR drops the rail after one second of silence from the sink.
  It is recorded against the purpose-built board in [011 item 3](specs/011-Roadmap.md) instead.

### CR-3A15: DC-9 made executable — the measurement protocol, the build that runs it, and the motion shaping parameters it commands

- **Affects:** [009.1](specs/009.1-Performance-Characterization-Protocol.md) (new),
  [009.2](specs/009.2-Test-Build-Manifest.md) (new),
  [006 §Motion shaping parameters](specs/006-Firmware-and-Calibration.md#motion-shaping-parameters),
  [009 §DC-9](specs/009-Design-Completion.md#performance-characterization),
  [009 §DC-11](specs/009-Design-Completion.md#procurement-data),
  [README](specs/README.md#document-ownership).
- **Was:** [DC-9](specs/009-Design-Completion.md#performance-characterization) named four measurements and
  three inherited checklists but specified no procedure for any of them, and nothing anywhere said what
  build to run them on. 007 lists parts by subassembly and 008 gives an assembly order, but neither says
  which subset a characterization build needs, what can be deferred, or what must be settled before
  ordering. So the one item that can only be closed on a physical build had nothing a builder could
  execute and no build to execute it against. `MaxSpeed` and `Acceleration` were referred to by name in
  002 and 003 and defined nowhere; neither is in `Defaults.make_ins`.
- **Now:** [009.1](specs/009.1-Performance-Characterization-Protocol.md) specifies each measurement: the
  instrument and the resolution it must reach, the procedure, the rule that decides the result, and — in
  its [§ 7](specs/009.1-Performance-Characterization-Protocol.md#section-7-closing-out) — the document each
  result is written into. Where 002 marks a requirement for characterization, no acceptance threshold is
  stated: the measurement is the value, and a threshold invented in advance would become the answer the
  build was run to find. [009.2](specs/009.2-Test-Build-Manifest.md) specifies the build that protocol runs
  on, as seven stages, each drawing named 007 subassemblies, assembled by named 008 procedures, and each
  closing specific open items before the next is committed; it carries a table mapping every open item in
  009 to the stage that answers it. 006 now specifies the motion shaping parameters, including that the
  `S, MaxSpeed` argument is scaled by `arcsec_per_nbits` = 0.46423 rather than taken as arcsec/s — a value
  read as arcsec/s overstates the commanded speed by ≈ 2.15×.
- **Driver:** Four requirements (REQ-PRE-5/6/7, REQ-WS-6/8) and three design-completion items wait on
  measurements that no document described how to take. Sequencing the build is worth specifying for its
  own reasons: ordering the strain-wave sets last would add months, and belts or a fan bought before the
  measurements that size them would be bought twice.
- **Status:** `[TBD]` for DC-9 itself, which still requires a build. The protocol that closes it, and the
  build it is run on, are specified; the build does not exist.
- **Re-derive:** Nothing downstream. 009.1 produces values and consumes none that are not linked to their
  owner; 009.2 selects from 007 and 008 and states no quantity of its own.
- **Open:** Three items are **gates, not outputs** — the build cannot be completed without them.
  [DC-10](specs/009-Design-Completion.md#from-scratch-calibration-files)'s two job wrappers are what
  [006 §Steps 2–3](specs/006-Firmware-and-Calibration.md#factory-calibration-procedure) run, so without
  them there is no calibration and most of 009.1 cannot be executed at all.
  [DC-12](specs/009-Design-Completion.md#wrist-pulley-rework) must be closed before the wrist parts are
  printed, or every commanded J4 and J5 angle is scaled by 2.4 against the specified `AxisCal`.
  [DC-11(h)](specs/009-Design-Completion.md#procurement-data) is the hard one: no part in the set bridges
  the elbow tube to the wrist, so there is no complete arm to characterize until one is designed.
  [DC-14](specs/009-Design-Completion.md#power-inlet-mounting) alone is deferrable — the test build takes
  bench leads to `J24` and does not close it.
- **Note:** Four corrections were forced while authoring the protocol, each a procedure that could not have
  been run as written. **J4 cannot be rotated 360°** — it is bounded at ±108.3°, and the checklist item
  that commanded a full turn to count its 115-slot track is not executable; the track is read across its
  bounded travel. **J5 does not rotate continuously** — its cycle is a 380° sweep and return, not a
  revolution. **L4 cannot be measured dimensionally**: the J4 and J5 axes intersect
  ([004 §Differential interface](specs/004-Mechanical-Architecture.md#differential-interface)), so no
  instrument can be put across them and the check is kinematic, on a calibrated robot, rather than taken
  while the wrist is open as DC-9 previously directed. **`J23` is the fan connector**, not the motor rail
  — [DC-7](specs/009-Design-Completion.md#motor-control-pcb) criterion 3 reads it precisely because the
  rail feeding it is unknown, so the protocol states no expected voltage.

### CR-3A16: Calibration job files restored from repository history; J4 slot count corrected in both

- **Affects:** `DDE/InitialCalibration/Setup_Find_Index_Home_HDIv2.dde` (restored),
  `Firmware/dde_apps/Find_Index_Pulses_HDI.dde` (restored),
  [006 §Calibration model](specs/006-Firmware-and-Calibration.md#calibration-model),
  [006 §Factory calibration procedure](specs/006-Firmware-and-Calibration.md#factory-calibration-procedure),
  [006 §Encoder velocity monitor](specs/006-Firmware-and-Calibration.md#encoder-velocity-monitor) (new),
  [009 §DC-10](specs/009-Design-Completion.md#from-scratch-calibration-files),
  [009.2 §Gate items](specs/009.2-Test-Build-Manifest.md#gate-items--close-these-before-cutting-anything)
  and §Stage 6.
- **Was:** [DC-10](specs/009-Design-Completion.md#from-scratch-calibration-files) held that the two job
  files driving [006 Steps 2–3](specs/006-Firmware-and-Calibration.md#factory-calibration-procedure) were
  missing from the public repository, that they were thin wrappers over the calibration engine in
  `dde/low_level_dexter/`, and that reconstructing them against that engine was the only route. It was a
  gate on the whole test build, and 006 named the Step 2 file only by a glob.
- **Now:** Both files are in the repository. They were committed with the design and deleted from it in
  October 2020 — `Find_Index_Pulses_HDI.dde` at `e4a3a0d` (2020-10-27),
  `Setup_Find_Index_Home_HDIv2.dde` at `1b121ce` (2020-10-29) — in a run of six pure deletions that added
  nothing in their place, and they are restored from that history. Neither is a wrapper: the index-eye
  search, the scan thresholds, and the home-offset arithmetic are in the job files, and every routine
  [006 Step 3](specs/006-Firmware-and-Calibration.md#factory-calibration-procedure) names is a job defined
  in the Step 2 file — none of them exists anywhere else in either repository. `Find_Index_Pulses_HDI.dde`
  is restored at its **2020-10-16** content, which reads the joint boundaries from `Defaults.make_ins`
  rather than setting a narrower set inside the job, so the job agrees with
  [003 §Joint travel limits](specs/003-Kinematics.md#joint-travel-limits). 006 now names both files by
  path, and 009.2 drops DC-10 as a gate: nothing is owed before cutting, and the item closes when the
  files run.
- **Driver:** DC-10 gated every measurement in [009.1](specs/009.1-Performance-Characterization-Protocol.md)
  that needs trustworthy encoder counts, and it was scoped as reconstruction of two wrappers — work that
  would in fact have meant re-authoring the entire index-eye algorithm, against an engine that does not
  contain it.
- **Status:** `[Provisional]` — DC-10 stays open on the one thing left: running
  [006 Steps 2 and 3](specs/006-Firmware-and-Calibration.md#factory-calibration-procedure) end to end on a
  build. The files have not been run since they were restored.
- **Re-derive:** Nothing downstream. 006 gains file paths it referred to by glob; 009.2's gate table and
  stage 6 follow DC-10's change of kind.
- **Note:** **One correction is applied to both files.** Each declared
  `n_eyes = [200, 180, 157, 113, 100]`, the per-joint slot counts the eye-to-angle conversion
  `deg_per_eye = 360 / n_eyes` is built from; J4's term is **115**
  ([003 §Joint definitions](specs/003-Kinematics.md#joint-definitions), counted on `#730-002`'s rim, and
  carried by `DexRun.c`), so at 113 every J4 eye hop ran 1.8 % long. Recovered SHA-256 `e07b3602…e4e0b0`
  and `8fed1af9…e9d6ff`; corrected `b0d9322c…8b88c02` and `34cededd…4b3ec1`. **A second slot-count
  disagreement is left alone and specified instead.** `DexRun.c`'s `monitorTorque` reads J2 as 184 slots
  against the disk's 180, but its `joints_slots` and `joints_corr` arrays are an empirically fitted pair
  and correcting one term alone de-tunes the other — see
  [006 §Encoder velocity monitor](specs/006-Firmware-and-Calibration.md#encoder-velocity-monitor). Two
  superseded Step 2 variants, `Setup_Find_Index_Home_HDI.dde` and `Setup_Find_Index_Home_HDI_Stable.dde`,
  remain in history and are not restored; `HDI CAL INSTRUCTIONS- STEP 2.pdf` names `HDIv2`.

### CR-3A17: DC-11 resolved to a coupon print

- **Affects:** [003 §Static gravity torque](specs/003-Kinematics.md#static-gravity-torque),
  [003 §Link lengths](specs/003-Kinematics.md#link-lengths),
  [004 §Differential interface](specs/004-Mechanical-Architecture.md#differential-interface),
  [005 §Open items](specs/005-Electronics-and-Control.md#open-items),
  [007 §7.5](specs/007-Bill-of-Materials.md#0075-arm-body),
  [007 §7.6](specs/007-Bill-of-Materials.md#0076-differential),
  [007 §Aggregate](specs/007-Bill-of-Materials.md#aggregate-hardware-quantities-whole-robot),
  [007.1 §4](specs/007.1-Parts-Catalog.md#4-bearings),
  [007.1 §5](specs/007.1-Parts-Catalog.md#5-structural-composites-and-metal-stock),
  [007.1 §7](specs/007.1-Parts-Catalog.md#7-electronics-and-wiring),
  [007.1 §C-101](specs/007.1-Parts-Catalog.md#c-101--nema-17-stepper-09step),
  [007.1 §C-201](specs/007.1-Parts-Catalog.md#c-201--521-strain-wave-component-set),
  [007.1 §C-503](specs/007.1-Parts-Catalog.md#c-503--carbon-fibre-strip-057--177),
  [007.1 §C-505](specs/007.1-Parts-Catalog.md#c-505--braided-carbon-fibre-square-tube-075),
  [007.1 §Corrections](specs/007.1-Parts-Catalog.md#corrections-to-007),
  [007.2](specs/007.2-Printed-Parts.md#printed-parts) throughout,
  [008 §8.5](specs/008-Assembly.md#0085-arm-body),
  [008 §8.6](specs/008-Assembly.md#0086-differential),
  [DC-5](specs/009-Design-Completion.md#link-member-lengths),
  [DC-6](specs/009-Design-Completion.md#link-length-discrepancy-l4),
  [DC-9](specs/009-Design-Completion.md#performance-characterization),
  [DC-11](specs/009-Design-Completion.md#procurement-data),
  [009.1](specs/009.1-Performance-Characterization-Protocol.md),
  [009.2](specs/009.2-Test-Build-Manifest.md),
  `Hardware/Models/robot_assembly.scad` (new), `Hardware/Models/README.md`,
  `Hardware/Models/PART-INDEX.md`, `Hardware/Models/MANIFEST.csv`,
  `Hardware/Models/700-Differential/` (`diff_assembly.scad`, `diff_params.scad`, `diff_hardware.scad`,
  `720-001_DiffGearShaft.scad`, `render-meshes.rs`, `render-all.rs`),
  `Hardware/Models/400-EndArm/420-001_EndArmHub.stl`,
  `Hardware/Models/950-Tooling/GlueRig_EndArmHubToDiff_B.scad` (new) and its mesh,
  `Hardware/Models/Reference/superseded/GlueRig_EndArmHubToDiff_B_span309500.stl` (new).
- **Was:** [DC-11](specs/009-Design-Completion.md#procurement-data) gated ordering and printing, and it was
  open on five part identities the catalog could not pin, four differential findings with no seat to go to,
  and L3's far end, where [C-505](specs/007.1-Parts-Catalog.md#c-505--braided-carbon-fibre-square-tube-075)
  leaves the tube's far face 36.000 mm short of the J4 axis and no file presented the face it butts. The
  fan had no size and no part number; the Belt Directors were typed "Fabricate" in
  [007.5](specs/007-Bill-of-Materials.md#0075-arm-body) and printed everywhere else; layer height, wall
  count, infill and orientation were unpublished;
  [C-101](specs/007.1-Parts-Catalog.md#c-101--nema-17-stepper-09step) named a *recommended qualifying* part
  rather than a part of record and justified its holding torque as "legacy build record specifies
  0.52 N·m"; and two CAD bodies were recorded as BOM shortfalls. Motor stall was treated as the payload
  ceiling throughout, because [C-201](specs/007.1-Parts-Catalog.md#c-201--521-strain-wave-component-set)
  had transcribed everything from [`XB1-AS-C-32.pdf`](Hardware/Reference/XB1-AS-C-32.pdf) except its torque
  table. The model set held one assembly covering nine parts of seventy, so where parts sit relative to one
  another was recorded in prose or not at all, and [007.2](specs/007.2-Printed-Parts.md) pointed each part
  at the upstream archive its family came from rather than at a file.
- **Now:** **Every part in [007.1](specs/007.1-Parts-Catalog.md) resolves to an orderable product with a
  supplier link**, and all eleven of DC-11's sub-items are closed.
  *Identities.* The **fan is a 40 mm frame** — the CAD body `HDI-730-005_Fan` and the printed Fan Bracket
  agree on it independently — specified as Sunon `MF40101V1-1000U-A99` in
  [C-716](specs/007.1-Parts-Catalog.md#7-electronics-and-wiring), whose 4.5–13.8 V span makes it immune to
  whatever rail `J23` carries. The **Belt Directors are printed**, and the same measurement corrects the
  fit's direction: the Ø8.000 shank is the MR128 bore, so the bearings go *onto* it. **A print profile is
  published**, derived parameter by parameter from the features the parts must hold. **StepperOnline
  `17HM19-2004S` is the stepper of record**, adopted by decision because no manufacturer part number is
  recoverable — the design's own CAD carries the motor as an imported solid with no vendor identity, which
  was the last place one could have been held — with body length **48 mm exactly** and a two-sided
  constraint, the End Cap being epoxied to the Main Pivot before the motor is epoxied to it. **Neither
  CAD-vs-BOM mismatch is a missing row:** `HDI-311-006C_J2StatorHolderCap_ConeDrive` is a modelling
  division of the single printed `#200-002`, and `HDI-610-006_MotorShaftCoupler` is a different part from
  `#630-004` used as a generic hub.
  *Loads.* **The drives, not the motors, limit joint load.** At 52:1 the component set is rated **4–5 N·m
  continuous, 11 N·m start/stop, 24 N·m peak**; J2 reaches the continuous rating at ≈0.45 kg at the tool
  tip and start/stop at ≈1.45 kg, while the specified motor drives it to ≈16.7 N·m, so the motor can
  overload the drive without ever stalling. Holding torque is derived rather than inherited:
  [003](specs/003-Kinematics.md#static-gravity-torque) owns a worst-case static gravity table computed with
  the project's own `DH.torques_gravity`. The drawing also yields the axial interface, **23.5 mm between
  mounting faces**.
  *The differential's parts.* All four findings are adjudicated and none of them wanted a bore. The
  **thrust stack** is a washer stack between the Split Gear Top's base annulus and the Diff Keeper, on the
  10.423 mm of Diff Body B's Ø8 tube that stands proud of that base. The **MR85** seats by its OD 8 in the
  top 1.5 mm of `#720-002`'s Ø8 rod bore, which also fixes the CF rod: it stops on the bearing rather than
  flush with that face. The fifth **6703** is an assembly bearing that
  [008.6](specs/008-Assembly.md#0086-differential) step 8 turns one gear half against the other on. **The
  five `#720-005` 60 mm CF strakes are withdrawn** — no assembly step places them, the build record does
  not list them, and no slot in any of the nine printed parts will take one. **Two bearing counts were
  wrong and are corrected:** MR128 2 → **4** and 6703 5 → **6**, both corroborated by the build record
  [008.6](specs/008-Assembly.md#0086-differential) descends from.
  *The arm.* `robot_assembly.scad` composes the arm in the CAD kinematic frame, solving **every placement
  from a feature the part itself carries** and listing in `UNPLACED` any part whose position nothing fixes.
  It settles L3's far end by finding that **the part that row was opened on does not exist**: Diff Body A's
  own −x spigot is the same 20 × 20 R4 plug the End Arm Hub presents — 386.245 mm² against 386.068 in
  section over one bore of 131.7156 mm² against 131.7158, two parts in a million — so it is the tube's far
  end and points back down the forearm, and the Diff End Pulley facing the elbow sends the J4 axis along
  world z. The J4 and J5 crossing lands on the **J4 axis at the J4 station**, where J3 to the
  differential's own J4 axis measures the specified **307.500 mm** and the specified **243.0 mm C-505 cut
  laps the spigot by 15.000 mm**. **No part is missing and no cut length moves.**
  *The jig.* `950-Tooling/GlueRig_EndArmHubToDiff_A`/`_B` registers a Ø22.971 boss in the End Arm Hub's
  Ø22.990 J3 bore at one end and a Ø16.971 boss — a 6703's bore, its Ø23 race seating in Diff Body A — at
  the other, so it states J3 to J4 directly. As exported it stated 309.500 mm. The kinematic records are
  the design of record and a jig is derived from them, so the jig is what moves: `_B` is shortened
  **2.000 mm** across a prismatic stretch of its trough, clear of both registers and of the pair's lap, and
  is now generated from `GlueRig_EndArmHubToDiff_B.scad`.
  *The mirror.* [007.2](specs/007.2-Printed-Parts.md#printed-parts) links every row to the file
  `Hardware/Models/` holds that part as; `Hardware/Models/PART-INDEX.md` owns which file is which part and
  the `Model` column is generated from it.
  *The wall holes.* **The Diff Gear Shaft prints solid.** The twelve Ø0.2 wall holes its reference mesh
  carries are unbuildable and unused, so [007.2](specs/007.2-Printed-Parts.md#differential--0076) states
  the part's print state and `720-001_DiffGearShaft.scad`'s `wall_holes` flag defaults off to match. The
  harness gate already masks the ring the holes occupy, so it passes on the solid render unchanged.
- **Driver:** DC-11 gated ordering and printing — it is the item standing between the specification and a
  parts order — and most of what it held was answerable from geometry already in the repository rather than
  from a decision or a build. Answering the last of it needed the parts composed: a part in its own print
  frame cannot show a hole, and a subassembly placed by a bounding box is placed by a coincidence.
- **Status:** `[Provisional]` — DC-11 is left with one item, and it needs no part authored: the coupon
  print that validates [row d](specs/009-Design-Completion.md#procurement-data)'s profile, which is
  [009.2](specs/009.2-Test-Build-Manifest.md)'s.
- **Re-derive:** **Order against the corrected rows.** Ordering from
  [007.6](specs/007-Bill-of-Materials.md#0076-differential) as it stood lands two MR128 and one 6703 short
  at the bench. [C-503](specs/007.1-Parts-Catalog.md#c-503--carbon-fibre-strip-057--177) drops from 8
  pieces and a 48″ stick to 3 pieces and a **24″** stick. Any payload figure quoted against motor stall is
  superseded: the ceiling is the gearbox and roughly a third of the motor-derived number, so
  [009.1 Test 4.3](specs/009.1-Performance-Characterization-Protocol.md#test-43-rated-payload) is bounded
  at **1.0 kg** with that bound added as a stop condition, and
  [009.2](specs/009.2-Test-Build-Manifest.md)'s Stage 2 gate reads the drive's axial stack-up rather than
  end-cap stand-off. **Nothing dimensional moves on the robot**: no cut length, part dimension, link length
  or L4 value changes, and the 0.4665 mm by which the spigot axis sits off the tube's is unchanged. What is
  withdrawn is the span — `robot_assembly.scad` draws no void,
  [C-505](specs/007.1-Parts-Catalog.md#c-505--braided-carbon-fibre-square-tube-075)'s 283.5 mm alternative
  cut and [004](specs/004-Mechanical-Architecture.md#differential-interface)'s reading that the
  differential centre lands on the J5 station both go with it, and
  [009.2](specs/009.2-Test-Build-Manifest.md) loses a gate:
  [DC-12](specs/009-Design-Completion.md#wrist-pulley-rework) is the only authoring work the build now
  waits on. **A glue rig printed before this change is 2.000 mm long** and is not the tool
  [008.6](specs/008-Assembly.md#0086-differential) calls for; the as-exported mesh is kept under
  `Reference/superseded/`. Two [008.6](specs/008-Assembly.md#0086-differential) steps are corrected — step
  11 sent the 25 mm strakes to the Split Gear Bottom, which carries no slot, and step 23 left the Diff
  Keeper butted on the Split Gear with no room for the stack it retains — and `ROD_TOP` in
  `diff_assembly.scad` moves 1.5 mm with the End Pulley on it.
  **A `720-001` mesh rendered before this change carries the Ø0.2 wall holes**, the flag having defaulted
  on; re-render it before slicing. This closes the wall-hole question
  [CR-3A7](#cr-3a7-differential-detail-design-authored-as-parametric-openscad) left open.
- **Note:** *What made the composition renderable.* Three unrelated defects stopped a full render and each
  was cleared on its own terms. Exported meshes are not always surfaces CGAL can walk, so
  `render-meshes.rs` now puts each one through `scadmesh` as it is written — `settle` writes the mesh as
  OpenSCAD's own importer will read it, `repair` fills the gaps that reveals, and `pinch` opens any edge or
  vertex the surface still touches itself at — and stops on a part that fails, so the cache is renderable
  or there is no cache. `420-001_EndArmHub.stl` was not a closed 2-manifold at all, three of its four
  Ø3.000 holes being tangent to its Ø27.500 bore, and is corrected in place by `pinch`: 6 triangles added,
  no existing vertex moved, volume four parts in ten million larger. And surfaces the design has touching
  were drawn touching, which CGAL cannot union, so `diff_params.scad` defines `DRAW_JOINT = 0.001` mm and
  owns what it is for; the stand-ins are illustrations rather than part models and no seat, bore or part
  dimension derives from it. *Why the arm was drawn before it was landed.* The differential was first left
  out of the composition, then drawn in every direction its J4 axis could take, rather than placed on a
  reading — [003 §DH model](specs/003-Kinematics.md#denavithartenberg-model) put that axis across the arm
  and [004](specs/004-Mechanical-Architecture.md#differential-interface) fitted Body A to the gripper
  covers by a radius that bounds two perpendicular directions at once. Drawing it either way would have
  adopted an answer silently. The mating bore is what decided it — a belt passage is not a feature a tool
  arm repeats — and 004's gripper-cover argument is withdrawn there along with the four readings it
  produced. *Sizing.* Link 2 carries 2.520 kg of the robot's 4.79 kg of moving mass and its centre of mass
  acts 62 mm *behind* the J2 axis, so the unloaded arm needs about a twentieth of the specified motor's
  holding torque: motor sizing on this robot is set by payload and dynamics, not by holding its own weight
  up. *The drawing's silence.* The body-length tolerance
  [`XB1-AS-C-32.pdf`](Hardware/Reference/XB1-AS-C-32.pdf) was consulted for is not on it — the drawing
  fixes the component set internally and says nothing about how far its mating parts may sit from nominal —
  so the band is an assembly stack-up taken up on the Stator Holder all-thread, which
  [009.2](specs/009.2-Test-Build-Manifest.md) Stage 2 records.

### CR-3A18: Wrist pulleys re-cut to the specified tooth counts

- **Affects:** [004 §Wrist and differential](specs/004-Mechanical-Architecture.md#wrist-and-differential-j4j5),
  [004 §Differential interface](specs/004-Mechanical-Architecture.md#differential-interface),
  [007 §7.6](specs/007-Bill-of-Materials.md#0076-differential),
  [007 §7.7](specs/007-Bill-of-Materials.md#0077-end-arm-hub),
  [007.1 §3](specs/007.1-Parts-Catalog.md#3-belts-and-pulleys),
  [007.2](specs/007.2-Printed-Parts.md#printed-parts),
  [008 §8.6](specs/008-Assembly.md#0086-differential), [008 §8.9](specs/008-Assembly.md#0089-belts),
  [DC-3](specs/009-Design-Completion.md#wrist-reduction-ratio),
  [DC-12](specs/009-Design-Completion.md#wrist-pulley-rework),
  [009.1](specs/009.1-Performance-Characterization-Protocol.md),
  [009.2](specs/009.2-Test-Build-Manifest.md),
  `Hardware/Models/gt2_pulley.scad` (new), `Hardware/Models/robot_assembly.scad`,
  `Hardware/Models/400-EndArm/` (`external_pulley.scad`, `430-001_ExternalOuterPulley.scad`,
  `430-002_ExternalInnerPulley.scad`, all new; both meshes moved to `Reference/meshes/400-EndArm/`),
  `Hardware/Models/700-Differential/` (`720-004_DiffShaftPulley.scad` new; `diff_params.scad`,
  `720-001_DiffGearShaft.scad`, `720-003_DiffEndPulley.scad`, `730-001_DiffBodyA.scad`,
  `diff_assembly.scad`, `render-meshes.rs`, `render-all.rs`), `Hardware/Models/README.md`,
  `Hardware/Models/PART-INDEX.md`, `Hardware/Models/MANIFEST.csv`.
- **Was:** The model set carried the previous version's counts — 90T External pulleys and 40T
  differential inputs, netting 5.625:1 against an `AxisCal` of 86400 — so a wrist printed from it scaled
  every commanded J4/J5 angle by 2.4. The External pulleys existed only as meshes, and `diff_params.scad`
  held one measured 40T tooth ring.
- **Now:** `config="revised"` builds 108T External pulleys, an 80T Diff End Pulley, and a new 80T ring,
  `#720-004` Diff Shaft Pulley, keyed on the Diff Gear Shaft's 40T band; Diff Body A's pulley chamber is
  opened to clear them, widening it from 60.0 to 63.0 mm, and its M3 screws move outboard of the ring.
  Every printed GT2 ring derives from `gt2_pulley.scad`. `render-all.rs` counts the revised teeth on the
  rendered meshes, checks the assembly's placing extents against the renders, and requires Diff Body A
  and `#720-004` not to intersect; `robot_assembly.scad` asserts Diff Body A inside the forearm skin.
  `config="previous"` and its `dist` gates are unchanged.
- **Driver:** Realize [CR-3A8](#cr-3a8-wrist-tooth-count-decomposition-design-status-consolidated-into-009)'s
  decomposition so the printed wrist matches `AxisCal`.
- **Status:** `[Specified]` — DC-12 is closed. The External pulleys' clearance at the elbow is not placed
  by any file in the repository and is confirmed on the first build with the belt lengths.
- **Re-derive:** Print every wrist pulley and Diff Body A from `config="revised"`; a `config="previous"`
  print does not match `AxisCal`. [008.6](specs/008-Assembly.md#0086-differential) step 13 now sets
  `#720-004` in Body A before the shaft enters it. [009.2](specs/009.2-Test-Build-Manifest.md) has no
  authoring gate left on the wrist.

### CR-3A19: L1 specified from the base stack; the doubled clamp withdrawn; 6810s allocated to their seats

- **Affects:** [001 §5](specs/001-Overview.md#5-design-lineage), REQ-STR-4 in
  [002](specs/002-Requirements.md), [003 §Link lengths](specs/003-Kinematics.md#link-lengths),
  [004 §Base mounting plate](specs/004-Mechanical-Architecture.md#base-mounting-plate),
  [004 §Wrist and differential](specs/004-Mechanical-Architecture.md#wrist-and-differential-j4j5),
  [006 §Firmware defaults](specs/006-Firmware-and-Calibration.md#firmware-defaults-defaultsmake_ins),
  007 [§7.2](specs/007-Bill-of-Materials.md#0072-base),
  [§7.3](specs/007-Bill-of-Materials.md#0073-harmonic-drive-motors),
  [§7.4](specs/007-Bill-of-Materials.md#0074-main-pivot),
  [§7.8](specs/007-Bill-of-Materials.md#0078-external-gear),
  [§7.9](specs/007-Bill-of-Materials.md#0079-external-gear-mount--differential-motors) and
  [aggregate](specs/007-Bill-of-Materials.md#aggregate-hardware-quantities-whole-robot),
  007.1 [C-101](specs/007.1-Parts-Catalog.md#c-101--nema-17-stepper-09step),
  [C-201](specs/007.1-Parts-Catalog.md#c-201--521-strain-wave-component-set),
  [§4](specs/007.1-Parts-Catalog.md#4-bearings), [§6](specs/007.1-Parts-Catalog.md#6-fasteners) and
  [§Corrections](specs/007.1-Parts-Catalog.md#corrections-to-007),
  007.2 [§Totals](specs/007.2-Printed-Parts.md#totals) and
  [§Print fits](specs/007.2-Printed-Parts.md#print-fits) (new),
  008 [.2](specs/008-Assembly.md#0082-base), [.3](specs/008-Assembly.md#0083-harmonic-drive-motors),
  [.4](specs/008-Assembly.md#0084-main-pivot), [.5](specs/008-Assembly.md#0085-arm-body),
  [.7](specs/008-Assembly.md#0087-end-arm-hub) and [.8](specs/008-Assembly.md#0088-external-gear),
  [009](specs/009-Design-Completion.md),
  009.1 [§3.1](specs/009.1-Performance-Characterization-Protocol.md#test-31-mounting-face-to-j2-axis) and
  [§3.3](specs/009.1-Performance-Characterization-Protocol.md#test-33-j3-drive-stack) (new),
  [009.2](specs/009.2-Test-Build-Manifest.md), [010](specs/010-Versioning.md).
  Under `Hardware/Models/`: `robot_assembly.scad`, `print_fit.scad` (new), `render-check/` (new),
  `README.md`, `PART-INDEX.md`, `MANIFEST.csv`; `100-Base/110-002_BaseStatorHolder.scad` (new);
  `200-ArmBody/200-002_PivotStatorHolder.scad` (new); `400-EndArm/`'s External pulleys; `500-ExternalGear/`
  (`exgear_assembly.scad`, `exgear_assembly.view.json`, `511-001_ExGearMotorEndCap.scad` and
  `511-002_ExGearStatorHolder.scad`, all new; `510-001_ExternalGear.stl`, pinched); `600-StrainWave/`
  (`630-005_FlexSplineAttach.scad`, `630-006_FlexSplineCap.scad` and `c201_spline_seat.scad`, all new);
  `700-Differential/` (every part file, `diff_params.scad`, `diff_assembly.scad`, `diff_bevel.scad` and
  `render-meshes.rs`; `parts.json` and `diff_assembly.view.json`, new); `render-all.rs` in `100-Base`,
  `200-ArmBody`, `500-ExternalGear` and `600-StrainWave` (new) and in `700-Differential`;
  `950-Tooling/fit_coupon.scad` (new); the six meshes the new sources replace, moved to `Reference/meshes/`.
- **Amends:** [CR-3A2](#cr-3a2-bolted-base-and-doubled-base-clamp) (the doubled clamp; the bolted base
  stands),
  [CR-3A9](#cr-3a9-base-mounting-plate-specified-two-link-datums-withdrawn-two-model-mirrors-replaced)
  ("doubled clamp resolved from geometry": the 97.000 mm shoulder, the Base Long bottoming on nothing, the
  15.000 mm rise, and the clamp-screw and M3 nut counts of 2 and 45),
  [CR-3A12](#cr-3a12-l4-specified-along-the-arm-the-dh-d-corroboration-withdrawn) (L1's `[TBD]` status),
  [CR-3A6](#cr-3a6-parts-catalog-and-printed-parts-list-added-bom-made-orderable) (its 6810 correction from
  7 to 8).
- **Was:**
  - **Base.** L1 = 235.20 mm on the authority of `Firmware/Defaults.make_ins`, against two 15.000 mm clamps
    on a 97.000 mm shoulder that was held to set the Base Long's height. The CAD's single-clamp chain put
    J2 at 231.200 mm and the doubled stack at 246.200 mm, neither of them L1, and DC-13 waited on a
    first-build measurement of height and clamp count together.
  - **6810s.** 7.2 listed two, "one per Base row", and C-401 totalled 8. 008.7 step 1 put a 6810 in each
    Axis Intersection half, against 7.7's two 6807s, and no step in 008 consumed 7.9's. J1's and J2's far
    6810 was pushed off its shoulder on assembly and tapped back (008.4 step 9c, 008.5 step 2), and J3's
    was pressed "~38 mm" with the same instruction (008.8 step 5).
  - **Strain-wave adapters.** #511-001, #630-005, #630-006 and the three Stator Holders (#110-002,
    #200-002, #511-002) were the HD set's meshes. C-201's table gave the circular spline 6 × Ø4.5 holes on
    Ø44 and the Attach 6 × Ø3.5, and [DC-1](specs/009-Design-Completion.md#strain-wave-component-set) was
    closed on the holders and the Attach matching the drawing. Each holder took 4 M2 × 16 mm bolts, and
    the spline 2 M3 × 12 mm bolts (008.4 steps 10–11, 008.5 steps 4–5).
  - **Fits.** Every printed part was drawn line to line against its mates, which a printed part, slightly
    oversize, does not go together on. The External Gear's mesh touched itself on one ring, so CGAL
    refused it in any boolean.
  - **Differential.** `diff_params.scad` defaulted to `config="previous"`, so a file opened or rendered
    without `-D` showed the reference parts. The Diff Gear Axle's Ø9 boss ran 1.84 mm into the Diff Gear
    Shaft's front MR128, and its rod bore was a slip fit that left 0.35 mm of wall. Diff Body B overlapped
    the toes of the three bevel crowns that turn in it, and `diff_assembly.scad` recorded those overlaps
    rather than designing them out. The shaft's Ø19 shoulder ran 0.17 mm into Body B's rear 6703, and the
    Split Gear Bottom's crown-bore shoulder 0.42 mm into the column 6703. Four shoulders that locate a
    bearing by its outer race bore on its inner race as well: Body A's Ø26 under the 6705, the Split Gear
    Bottom's Ø18 under the column 6703, and each Split Gear half's Ø8.5 under its MR128. The 6703 between
    the Split Gear's halves was drawn on the Top's pocket floor, across both races.
- **Now:** Each part's geometry is stated in its file's header; this entry records the decisions and the
  evidence for them.
  - **L1 = 231.500 mm, the printed stack**
    ([004 § Base mounting plate](specs/004-Mechanical-Architecture.md#base-mounting-plate)), **and the
    clamp is not in it.** Sectioning the CAD bodies shows the Base Long and the Base Mount Bottom sharing
    material over r 33–36 mm at 98.000 mm, so the Base Long bottoms on the mount. The clamp seats on its own
    shoulder below; its Ø74.500 bore equals the outer face radius of the strakes it squeezes. The CAD
    chain's 231.200 mm is 0.300 mm short because its Base Long body is the earlier, 95.700 mm revision.
  - **The spigot takes one clamp; the doubled clamp is withdrawn.** A second would ride on the first and
    lift the Base Long 14.000 mm off its seat, to no stop. The HD build notes list one clamp, one
    M3 × 20 mm bolt and one M3 nut. The wiki's `Dynamics.md` lists a "double base clamp" among the features
    "specific to the Dexter HDI that was measured": a deviation on that unit, not the design. The bolt
    runs across the clamp's split into a hex pocket for the nut (the build notes' "M3 Washer" there is a
    slip); the ±35.540 mm holes are six axial Ø3.5 mm holes in the Base Long, not clamp-bolt holes.
  - **The firmware's 235.20 mm is superseded.** No seated stack of these parts reproduces it, nor does the
    doubled-clamp unit, whose second clamp has no stop. HDI-007010's J1 `d` = 250.101 mm, 14.9 mm above
    it, fits that unit having carried a second clamp, but is not a reading of L1
    ([003](specs/003-Kinematics.md#denavithartenberg-model)).
  - **The robot takes seven 6810s** ([C-401](specs/007.1-Parts-Catalog.md#4-bearings)). That is the
    figure CR-3A6 corrected from, reached by a different sum: CR-3A6's count took 7.3 once and 7.2 twice.
    Each seat decides its bearing:
    - The Base Long's upper bore, Ø65 × 7 mm flush with its top face, takes the Base Motor End Cap's
      bearing, which is 7.3's. Only the bearing in its lower bore is 7.2's: Ø65 for 35.5 mm onto a Ø60
      shoulder, the build notes' "about 1½″ down" seat, which sets no height. The build notes list three
      6810s for the Main Pivot: two end caps and one Base Long.
    - `#410-001`'s Axis Intersection seat is Ø47.000 × 7 mm, a 6807; the build notes' "2 - 6810
      Bearings" under the End Arm Hub is a slip that 008.7 inherited.
    - The `#520-002` Ex Gear Mount Top's Ø65.0 × 7 mm seat, bored from its underside, is the third support
      of J3's output, around the circular spline that turns with the Stator Holder and the External Gear.
      The build notes do not install it; the seat decides it.
  - **J3's stack closes on two revised prints.** Placed from its seats, J3's upper 6810 ran into the Flex
    Spline Attach's flare, and the drive stood higher on its motor than on its Stator Holder. `#511-001`
    deepens the motor seat; `#630-005` removes the flare and lowers the hub face by `hub_drop`.
    `exgear_assembly.scad` (new) places the group from the parts' own seats, computes the drop from
    `MOTOR_LEN`, and asserts and echoes the closure and every clearance. J1 and J2 print the same Attach
    at no drop: their far 6810, which sat 0.2 mm into the flare and was tapped back, now runs free on the
    land, retained by the #6 washers, and their all-thread nuts take up the drive's span.
  - **C-201 is seated to its drawing**
    ([C-201](specs/007.1-Parts-Catalog.md#c-201--521-strain-wave-component-set) owns the values and the
    meshes' mismatches). The three Stator Holders and the Flex Spline Cap are now OpenSCAD source whose
    `config="previous"` reproduces the mesh within 0.026 mm and 0.005 mm. In `config="revised"`, one
    shared seat, `c201_spline_seat.scad`, gives each holder a pilot for the spline's step and six M3
    screws into captive nuts, and the Attach and the Cap clamp the flexspline hub on its bore and holes
    before the Attach goes on the motor. The Ex Gear Stator Holder seats on its keys' end chamfers, 3 mm
    higher than first placed, where it cut the gear's bore.
  - **Every printed part's `config="revised"` draws its fits with print clearance** from one library,
    `print_fit.scad`, by the classes in [007.2 § Print fits](specs/007.2-Printed-Parts.md#print-fits).
    `config="previous"` draws none, so no dist gate moves. The fit coupon is a model, and the slicer's
    dimensional compensation goes to zero, since the clearances carry the machine's fit.
  - **The differential defaults to `config="revised"`**
    ([004](specs/004-Mechanical-Architecture.md#wrist-and-differential-j4j5)), with `previous` selected by
    `-D`, and `parts.json` is its one part list. In `revised`:
    - Diff Body B stands the running clearance off the volume each of the three bevel crowns' teeth sweep,
      by moving each facing surface whole, so no cut leaves a ridge (`730-002_DiffBodyB.scad`, TOE
      CLEARANCE).
    - The Diff Gear Axle's boss, the spacer that 008.6 step 21's rod stops on, seats on the inner race of
      the Diff Gear Shaft's front MR128: the shaft's front journal is shorter by `front_drop()`, and Body
      B's front seat that much deeper. The boss body grows, and the rod bore becomes a press fit, so its wall goes
      from 0.35 to 1.15 mm (`720-002_DiffGearAxle.scad`).
    - Each bearing shoulder bears on one race: outer-race shoulders are bored to `shoulder_bore()`, and
      inner-race shoulders stop at the far faces `diff_params.scad` carries from Body B's seats.
  - **Every model group checks itself.** The shared `render-check` crate reads the clearances from
    `print_fit.scad` and probes each fit a part's header lists, in a `render-all.rs` per group. The 500
    script checks the Ex Gear Stator Holder by sections where its keys fit line to line; the 700 script
    requires Body B to render empty against its neighbours and against the three tooth zones grown to
    just under the running clearance. `510-001_ExternalGear.stl` is pinched so CGAL accepts it; the Models
    README records the pairs that still fail.
  - **The section view is reusable.** `scadmesh view` (openscad-tools) builds a section viewer for any
    viewable assembly from a sidecar whose numbers come from the assembly's echoes:
    `exgear_assembly.view.json` and `diff_assembly.view.json`, with label toggles (REQ-W-6 in
    openscad-tools).
- **Driver:** DC-13 could not be closed by a measurement whose outcome depended on how many clamps a
  builder fitted. A link length has to rest on positive stops that the parts define. A bearing row that no
  step consumes, or a step that consumes a bearing no row lists, is an order that arrives short or long at
  the bench. A bearing that is tapped back on every build, one that cannot reach its journal, a fit drawn
  with no room for a printed surface's error, and a gear that turns through the body around it are faults
  the printed parts must design out, not steps a builder repeats.
- **Status:** `[Specified]` — [DC-13](specs/009-Design-Completion.md#base-height-and-l1) is closed. The
  built height is confirmed under
  [DC-9](specs/009-Design-Completion.md#performance-characterization)'s base checklist. J3's stack closes
  in `exgear_assembly.scad`, whose asserts hold it for the measured motor length; the fit is confirmed on
  the first built J3 by
  [009.1 § 3.3](specs/009.1-Performance-Characterization-Protocol.md#test-33-j3-drive-stack). Both
  halves of C-201 are seated: the circular spline in all three holders, and the flexspline hub between
  the Attach and the Cap. [DC-1](specs/009-Design-Completion.md#strain-wave-component-set) stays closed.
- **Re-derive:**
  - **003, 004, 006** carry L1 = 231.50 mm. 004 takes the single clamp and the stack table and drops the
    Base open item; 006's `LinkLengths` block calls out the second deviation from the shipped file, which
    is not edited, per CR-3A12. The derived maximum reach does not include L1 and is unchanged.
  - **007, 007.1.** #100-001 goes to qty 1; M3 × 20 mm to 5, M3 × 12 mm to 34 and M3 nuts to 62, the last
    two with the spline's 6 screws and 6 nuts per joint in 7.3 and 7.8. C-401 carries 7 with its
    breakdown, and the corrections table loses its 6810 row and C-401 note. C-201's table takes the
    drawing's hole sets and ties each mating feature to its printed part, and its model-set check states
    both mismatches; C-101's body-length row says how each joint closes the drive. C-502 draws
    `#710-001`'s slots at the press clearance and points to the coupon.
  - **007.2, `PART-INDEX.md`** point the six new sources at their `.scad` files. 007.2 prints them from
    `config="revised"` and the differential from the default, counts 108 printed pieces (119 with
    tooling), adds § Print fits, and zeroes the slicer's compensation in the print profile.
  - **008.** 008.2 step 6 places the clamp's nut. 008.3 measures J3's motor before its Attach is printed,
    seats and clamps the hub before the Attach goes on the motor (steps 4–7), sets the wave generator's
    depth from the flex spline's mounting face (step 10), and mounts each spline in its holder (step 12).
    008.4, 008.5 and 008.8 link that step instead of repeating it, so 008.4's later steps renumber to
    12–16 and 17, and 007.1's C-101 row, 008.2 and 009.1 cite them. 008.4 steps 4 and 9 name the end caps
    and seat both Base Long bearings, and step 17 installs one clamp. The tap-back steps go, and the
    washers of 008.4 step 9d and 008.5 step 3 retain the free-running inner race. 008.6 step 11 points to
    the coupon, 008.7 step 1 inserts 6807s, 008.8 step 8 seats the keys, and 008.8 step 13 presses the 7.9
    bearing into the Ex Gear Mount Top.
  - **009, 009.1, 009.2.** 009.1 § 3.1 measures from the plate's top face (the Base Mount Bottom's mounting
    face) and becomes a pass/fail confirmation of L1; § 3.3 confirms J3's closure on the built joint, and
    008.8, 009 and 009.2's Stage 4 point to it. 009's DC-11(d) row and 009.2's Stage 0 point to the coupon
    rather than state slot sizes. 009.2's Stage 2 gate loses J3 to Stage 4, whose draw list loses a
    repeated 007.9 line. Two restatements become links: 007.2's L3 rig paragraph to DC-11(h), and
    DC-11(h)'s spigot section to 004.
  - **Models.** `robot_assembly.scad` seats the Main Pivot on the printed Base Long and asserts that the
    stack sums to L1. `exgear_assembly.scad` draws the revised holder, the spline and the Cap from their
    sources. `diff_assembly.scad` takes the viewable shape and a `part` id per export, reads Body B's
    front seat from 720-001's `front_drop()` and `front_seat_floor()`, and asserts that the boss's tip is
    the front MR128's face; `diff_bevel.scad`'s `BEVEL_ZONE` and 720-001's `crown_zone()` state the tooth
    zones the gates grow. Each part's header lists its fits and classes, and `render-meshes.rs` builds in
    `config="revised"` unless told otherwise. The Models README recounts its parts and files and points to
    the `render-all.rs` files for the gates' figures.
