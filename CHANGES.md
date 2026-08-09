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

### CR-3A7: Differential detail design authored as parametric OpenSCAD (superseded by CR-3A8)

- **Affects:** [004 §Wrist and differential](specs/004-Mechanical-Architecture.md#wrist-and-differential-j4j5),
  [007.2 §Differential](specs/007.2-Printed-Parts.md#differential--0076),
  [008.6](specs/008-Assembly.md#0086-differential), [009 DC-2/DC-6/DC-9/DC-11(f)](specs/009-Design-Completion.md),
  new source in [`Hardware/Models/700-Differential/`](Hardware/Models/700-Differential/)
- **Was:** The differential's internal geometry existed only as the previous version's nine mesh STLs (one
  of them ~1000× oversize) with no editable source; DC-2 was the largest open item in
  [009](specs/009-Design-Completion.md).
- **Now:** Every differential part has parametric OpenSCAD source beside its mesh (BOSL2), with shared
  dimensions in `diff_params.scad`, assembly placements in `diff_assembly.scad`, and a `render-all.rs`
  script that renders each part in both configurations, dimensionally verifies each render against its reference
  mesh using the new sibling `openscad-tools` project (`scadmesh`: bounding boxes, diameter/face bands,
  cross-sections, tooth counts, scale detection). Measured mechanism facts are now specified: three 20T
  straight bevels at 1:1:1 (Ø44.055), two 40T GT2 input pulleys, the shaft doubling as the J4 pivot axle,
  and the axially split output gear. `config="previous"` reproduces the built differential;
  `config="revised"` narrows Diff Body A from 80.98 to 77.8 mm to fit the HDI-940 cover envelope. The
  oversize `710-002` STL is corrected in place (exact 1/1000, mate-verified — DC-11(f) closed).
- **Driver:** DC-2's definition of done: an authored design with source geometry committed, replacing
  mesh-only geometry that could not be edited or checked.
- **Status:** `[Specified]` for the authored design and its geometric verification; the physical-build
  checks (binding, wiring survival, code-disk reads) are DC-9's first-build checklist.
- **Re-derive:** run `Hardware/Models/700-Differential/render-all.rs` after any `.scad` change; regenerate
  `PART-INDEX.md`/`MANIFEST.csv` after renders change committed meshes.
- **Note — three findings the authoring produced, each a requirement on something outside the
  differential:**
  (1) the wrist axes intersect, so the firmware L4 = 59.50 mm is an offset **along the J4 axis** that
  splits **31.0 mm inside the differential + 28.5 mm in the End Arm Hub**
  ([004](specs/004-Mechanical-Architecture.md#differential-interface)) — the hub standoff is now a
  dimension the End Arm Hub must hit, checked with [DC-6](specs/009-Design-Completion.md#link-length-discrepancy-l4);
  (2) **J4 has no code disk.** Counting slots on every code-disk model confirmed J1 = 200, J2 = 180,
  J3 = 157 and J5 = 100, each matching [003](specs/003-Kinematics.md#joint-definitions) exactly — but no
  part anywhere carries J4's specified 115
  ([DC-11(e)](specs/009-Design-Completion.md#the-j4-code-disk-is-missing));
  (3) the five `#720-005` 60 mm CF strakes listed in [007.6](specs/007-Bill-of-Materials.md#0076-differential)
  are placed by no assembly step and fit no slot in the differential's geometry. (2) and (3) are recorded
  as model-vs-BOM discrepancies under [DC-11(e)](specs/009-Design-Completion.md#procurement-data).

### CR-3A8: DC-2 reopened — the recreated differential parts are the wrong shape

- **Affects:** [009 DC-2](specs/009-Design-Completion.md#differential-detail-design),
  [004 §Wrist and differential](specs/004-Mechanical-Architecture.md#wrist-and-differential-j4j5),
  [`Hardware/Models/700-Differential/`](Hardware/Models/700-Differential/)
- **Was:** CR-3A7 closed DC-2 on `scadmesh compare`, which checks that every reference **diameter and
  face position** reappears in the candidate. That is a set of one-dimensional histograms; a solid can
  satisfy all of them and still be the wrong body.
- **Now:** Measured with two-sided surface distance (`scadmesh dist`), five of the seven recreated parts
  deviate from their references by 1.3–3.8 mm and are down to 16 % short on volume — while the old check
  had reported 0.006–0.131 mm agreement. Only Diff Keeper (0.023 mm) and Rotate Code Disk (0.350 mm max,
  0.011 mm p95) are faithful. Split Gear Top additionally previews as an empty CSG tree, so it is
  invisible in the OpenSCAD GUI until a full render.
- **Driver:** A dimensional check is not a shape check. Closing DC-2 now requires agreement under `dist`
  in both directions, bodies built from measured meridional profiles rather than inferred dimensions, and
  parts that preview as well as render.
- **Consequence:** DC-2 returns to `[Provisional]`. The parametric source, parameter sets, tooth counts,
  and assembly assertions stand; the part shapes do not. Do not print the 700-series parts from this
  source.

### CR-3A9: Split Gear Bottom rebuilt from measured geometry

- **Affects:** [009 DC-2](specs/009-Design-Completion.md#differential-detail-design),
  [`710-002_SplitGearBottom.scad`](Hardware/Models/700-Differential/710-002_SplitGearBottom.scad)
- **Was:** The part deviated from its reference by up to 2.25 mm (CR-3A8): a generated `bevel_gear()` that
  cut no tooth slots and left the hub solid, a cylindrical rather than conical cut on the inner tooth
  faces, and a missing step inside the bottom bore.
- **Now:** The body is a revolved measured profile and the crown is lofted through convex hulls of
  seventeen measured cross-sections. Candidate-to-reference distance is 0.150 mm max, 0.024 RMS, 0.043
  p95; tooth tips agree within 0.009 mm and the root cone within 0.007 mm. The part renders as one solid.
- **Driver:** A 1:1 bevel's teeth stand outside this crown's radius, so no generated gear could ever cut
  its slots. The four cone surfaces that do govern it are now recorded in DC-2.
- **Consequence:** One of the five wrong parts is corrected; **DC-2 stays `[Provisional]`** on the other
  four. The reference STLs are also now known to be **unmerged assembly exports**, which invalidates
  whole-file volume comparison and the reference-to-candidate distance direction — both recorded in DC-2's
  artifact exception.

### CR-3A10: Four differential parts rebuilt from measured geometry

- **Affects:** [009 DC-2](specs/009-Design-Completion.md#differential-detail-design),
  [004 §Wrist and differential](specs/004-Mechanical-Architecture.md#wrist-and-differential-j4j5),
  [`Hardware/Models/700-Differential/`](Hardware/Models/700-Differential/)
- **Was:** CR-3A8 found five recreated parts deviating from their references by 1.3–3.8 mm; CR-3A9 fixed
  one of them.
- **Now:** 720-003 Diff End Pulley agrees to **0.030 mm**, 720-002 Diff Gear Axle to **0.100 mm**, and
  710-001 Split Gear Top to **0.225 mm** (RMS 0.012, p95 0.010). All three render as one clean solid, and
  710-001 now previews, which it previously did not. Only 720-001 Diff Gear Shaft is still wrong.
- **Driver:** Two things made the bevels tractable. Every crown surface is a **cone**, recoverable to a few
  thousandths of a millimetre by fitting measured radius against height, and the fits corroborate each
  other across parts — 720-002's tip cones are 710-001's translated by 15.448 mm, their root slopes agree
  to 0.07 %, and 710-001's inner cone is the equation 710-002 already recorded for the surface they mate
  on. And straight bevel teeth are **ruled through the gear apex**, so a hull between two scaled copies of
  one measured section *is* the tooth's surface exactly.
- **Consequence:** **DC-2 stays `[Provisional]`** on 720-001 alone. Two verification rules are added to its
  contract, both learned the hard way: previewing must be checked separately from rendering, because it
  fails independently and an STL-based check cannot see it; and no cutter may be a module that is
  internally boolean, since `A - (B - C)` normalizes to `(A - B) | (A & C)` and doubles the preview tree
  per instance. 710-001's residual 0.225 mm is the tooth root fillet, which is concave and cannot be
  represented by a loft through convex hulls.
