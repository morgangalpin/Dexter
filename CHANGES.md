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
  [DC-3](specs/009-Design-Completion.md#wrist-reduction-ratio) before reusing wrist pulleys.

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
