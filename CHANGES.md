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
  bevel's toe cone, which is on a different surface and still needs its own answer. Whether the built
  shaft should carry the Ø0.2 wall holes at all is open under DC-11.

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
