# Models

Model files for the robot's printed parts, organized by **arm component**. This directory is the build
source: everything needed to print one complete robot is here, and nothing else is. Most parts are meshes
you can print directly; `700-Differential/` is parametric `.scad` and is rendered first, as is the base
mounting plate — see [Moving to OpenSCAD](#moving-to-openscad).

- **[robot_assembly.scad](robot_assembly.scad)** — the arm composed in the CAD kinematic frame, so the
  build can be reviewed by looking at it. Every placement in it is solved from a feature the part carries;
  a part whose position nothing fixes is listed in that file's `UNPLACED` rather than drawn somewhere
  plausible, which is what lets a missing part show as a hole. `700-Differential/diff_assembly.scad` is the
  same idea one level down, and this file composes it in by its `diff_centre()`. A mating feature outranks
  a bounding box there: the differential is oriented by the L3 spigot Diff Body A carries and by the side
  its End Pulley faces, and where the measured cover bodies disagree with that the file reports the
  disagreement rather than moving the part into them.
- **[print_fit.scad](print_fit.scad)** — the two print-fit clearances every part's `config="revised"`
  draws its fits with, press and slip, and the running gap kept between parts that turn past each
  other. Tune the two fits on
  [`950-Tooling/fit_coupon.scad`](950-Tooling/fit_coupon.scad); the policy is
  [007.2 § Print fits](../../specs/007.2-Printed-Parts.md#print-fits).
- **[PART-INDEX.md](PART-INDEX.md)** — every part in
  [007.2](../../specs/007.2-Printed-Parts.md#printed-parts) with its file, grouped as the directories are.
- **[MANIFEST.csv](MANIFEST.csv)** — every model and model-source file (meshes, CAD, `.scad`, and the
  script that renders and verifies them) with its size, SHA-256, and, for STLs, format and triangle count.
  Sizes and hashes are of the **repository** bytes, so text files are counted with LF line endings — on a
  Windows checkout (`core.autocrlf=true`) the working-tree file is larger than its row says. Compare a
  text file by normalizing CRLF to LF first; binary files compare directly. The text set is `.step`
  (ISO-10303-21 is ASCII), `.scad`, `.rs`, `.json` and `.md`; `.stl`, `.f3d`, `.ipt`, `.dwg`, `.skp`
  and `.skb` compare directly. The group column is the file's directory; a file that belongs to no one
  component group is grouped `(all)`.

## Layout

Directories follow the `PBS` component groups in [007.2](../../specs/007.2-Printed-Parts.md#printed-parts).
Files are named `<PBS>_<PartName>.<ext>`, so a part number alone locates its file, and the directory
listing sorts in build order.

`PBS #` is the **authoritative part number** — the only scheme that names every part, and the one
[007](../../specs/007-Bill-of-Materials.md), [007.1](../../specs/007.1-Parts-Catalog.md),
[007.2](../../specs/007.2-Printed-Parts.md) and [008](../../specs/008-Assembly.md) all key on. The `HDI-`
and `TI1-` CAD IDs name bodies in the CAD model and cover only 13 of 70 parts; the `KP`/`KA` numbers in
[`Reference/onshape-v1/`](Reference/onshape-v1/README.md) belong to the superseded v1 design. See
[007.2 § Part identifiers](../../specs/007.2-Printed-Parts.md#part-identifiers).

| Directory | Parts | Files | What |
|---|---|---|---|
| [`100-Base/`](100-Base/) | 7 | 9 | Base clamp, mount, mounting plate, stator holder, code disc; the Stator Holder is `.scad` |
| [`200-ArmBody/`](200-ArmBody/) | 9 | 9 | Arm body, stator holder and balancers, belt directors; the Stator Holder is `.scad` |
| [`300-Pivot/`](300-Pivot/) | 4 | 4 | Main pivot, code disk, motor end caps |
| [`400-EndArm/`](400-EndArm/) | 10 | 12 | Axis intersection, hub, internal and external pulleys; the External pulleys are `.scad` |
| [`500-ExternalGear/`](500-ExternalGear/) | 7 | 9 | External gear, stator holder, mount and nut holders; the Motor End Cap and Stator Holder are `.scad`; `exgear_assembly.scad` places the group with its motor and drive, and closes J3's stack |
| [`600-StrainWave/`](600-StrainWave/) | 3 | 5 | Wave gen coupler, flex spline attach and cap; the Attach and Cap are `.scad`, and `c201_spline_seat.scad` holds the drive's interface for them and the three Stator Holders |
| [`700-Differential/`](700-Differential/) | 10 | 17 | Split gears, diff gear shaft and axle, diff pulleys, diff bodies — **the OpenSCAD set**, `.scad` only; the meshes it is measured against are under `Reference/meshes/`; `diff_assembly.scad` places the set and has a section view |
| [`800-Harness/`](800-Harness/) | 14 | 17 | Wire entries, pivot plugs, PCB brackets, strain reliefs, photointerrupter shrouds |
| [`900-ToolInterface/`](900-ToolInterface/) | 8 | 27 | Tool interface body, roll, span, gripper — **the parametric set** |
| [`950-Tooling/`](950-Tooling/) | 2 | 12 | Solder jigs, glue-rig jig bodies, and the print-fit coupon |
| [`Reference/`](#reference) | — | 226 | Not printed for a build. See below |

### Shared parts

Sharing happens at **subassembly** level, not file level, so no part lives in two directories:

- **`600-StrainWave/`** is three parts at quantity 3 — one adapter set per strain-wave joint (base, pivot,
  end arm). It is a component in its own right rather than a member of any one joint.
- **`800-Harness/`** parts are distributed throughout the robot (strain reliefs at quantity 10, PCB spacers
  at 4).

Only two *files* serve more than one part number, and both stay inside one component. See
[PART-INDEX](PART-INDEX.md#one-geometry-two-part-numbers).

### Reference

Not part of a build. Kept because the geometry exists nowhere else.

| Directory | Files | What |
|---|---|---|
| `Reference/onshape-v1/` | 193 | **v1** B-rep solids as STEP, plus assembly definitions. Dimension recovery only — see [its README](Reference/onshape-v1/README.md) |
| `Reference/inventor/` | 8 | Inventor `.ipt` with feature history: arm, CF tube and tube mould, valve and ratchet, arm-body spacer. No part in the build list maps to these |
| `Reference/covers/` | 6 | Cosmetic ducts, **not in the [007](../../specs/007-Bill-of-Materials.md) build list**. Includes SketchUp source |
| [`Reference/meshes/`](Reference/meshes/) | 17 | The original meshes of parts that now have parametric source: `700-Differential/`, `400-EndArm/`'s two External pulleys, `500-ExternalGear/`'s Motor End Cap, `600-StrainWave/`'s Flex Spline Attach and Cap, and the three Stator Holders in `100-Base/`, `200-ArmBody/` and `500-ExternalGear/`. A part's mesh moves here when its `.scad` lands; each group's `render-all.rs` measures its renders against these meshes (see [Checking a group](#checking-a-group)), and each External pulley `.scad` builds on its own |
| [`Reference/superseded/`](Reference/superseded/) | 2 | Earlier revisions of parts the build no longer uses. `GlueRig_EndArmHubToDiff_B_span309500.stl` is the L3 rig as first exported ([PART-INDEX](PART-INDEX.md#glue-rig-jigs)). `DiffA2CodeDiskEndStop.dwg` is the v1 J4 code disk and end stop, whose 115-slot track is now cut into `#730-002`'s rim |

## Known defects

**A tangency, corrected in place.** `400-EndArm/420-001_EndArmHub.stl` was not a closed 2-manifold. The
part carries four Ø3.000 holes whose centres sit on a Ø30.500 circle, each tangent to the Ø27.500 bore
exactly — 15.250 − 1.500 = 13.750 — and the tessellator honoured the tangency by giving both surfaces a
vertex at the same coordinate. At three of the four, (0, 13.750), (0, −13.750) and (13.750, 0) in the
part's own frame, they then shared the whole line from z = −2.000 to z = −30.000: four faces on one edge
instead of two, and two cones of faces meeting at the single vertex at the z = −2.000 end, with no way to
say which faces bound the material. The fourth, at (−13.750, 0), is cut into different segments on each
surface, shares no edge, and is manifold — which is why there were three and not four. CGAL takes none of
it, so a render of anything holding this part stopped at `The given mesh is not closed`.

It was not a hole — the mesh has no boundary loop anywhere, which is why `scadmesh repair` reported it as
not closed and then found nothing to fill — so what it needed was each contact opened rather than patched:

```
scadmesh pinch 400-EndArm/420-001_EndArmHub.stl --out 400-EndArm/420-001_EndArmHub.stl
```

That gives one surface at each contact its own vertex 1 µm off the line, along its own normal, which grows
the material between the two surfaces by that much: 6 triangles added, no existing vertex moved, the
bounding box unchanged and the volume 0.028 mm³ — four parts in ten million — larger. The file also holds
a second closed shell that shares no edge with the body, the 18 × 20 × 20 mm block on the spigot axis at
x 26.500..44.500, y ±10.000, z −35.000..−15.000, so this is a multi-body export rather than one unioned
solid. That is not a defect: two shells convert as readily as one.

**A second tangency, corrected the same way.** `500-ExternalGear/510-001_ExternalGear.stl` failed the same
way. Two of its surfaces shared 91 edges on one ring in the part's frame, at x 21.215 and r ≈ 33.7, so
`scadmesh repair` found no boundary loop, CGAL refused the mesh, and every boolean on the gear stopped at
`The given mesh is not closed`. It is corrected in place:

```
scadmesh pinch 500-ExternalGear/510-001_ExternalGear.stl --out 500-ExternalGear/510-001_ExternalGear.stl
```

That added 182 triangles, left the bounding box unchanged, and added 0.708 mm³ to the volume (1 part in
10⁵). The gear now intersects with the Mount, the Mount Top and the lower 6810. Two pairs still fail
inside CGAL's boolean (`applyBinaryOperator` asserts) and stay unjudged. The Stator Holder's keys meet
the gear's slots line-to-line, which is why `500-ExternalGear/render-all.rs` checks that fit by sections.
The upper 6810's assertion persists with its envelope shrunk to Ø64.9, so it is not the seat's Ø65; its
cause is not isolated.

Three files have held the wrong geometry rather than the wrong topology, and all three are corrected in
place:

- `100-Base/110-001_BaseMountBottom.stl` was the **un-bolted predecessor**, an 85 × 85 × 98 mm part whose
  bottom face carried no fastener features whatever: sections through it return only an outer Ø ≈ 72.9
  profile and a Ø53.99 bore, and the six 60°-spaced features on its Ø71.302 circle decompose into six
  straight lines — 12.94 × 3.82 mm slots for the `#110-003` CF strakes, not a bolt pattern. The design of
  record is a **bolted** base ([004 § Base (J1)](../../specs/004-Mechanical-Architecture.md#base-j1)), and
  the CAD model holds it as `BaseMountBottom_Bolted v9`: 150 × 150 × 98 mm, with eight Ø6.000 mounting
  holes through a 10 mm flange. That is now the file, exported from `dde/HDIMeterModel.gltf` in the part's
  own frame. **This was found by re-checking a file the manifest was perfectly happy with** — the previous
  entry was a valid, closed, correctly named mesh of the wrong revision.
- `200-ArmBody/200-001_ArmBody.stl` was not the Arm Body. It held
  `ArmBodyFrontStrakeMED.stl` — a 20-triangle 4.9 × 9.9 × 32 mm block — byte for byte, so the mirror
  had matched the archive's `ArmBody*` prefix rather than the part. The Arm Body is
  `ArmBodyWEncode.stl` in [thing:3781990](https://www.thingiverse.com/thing:3781990) (11,946 triangles,
  99.6 × 108.1 × 98.0 mm), and that is now the file. It is the part: its 29 × 29 mm L2 tube socket sits
  where the CAD model's `HDI-310-001_ArmBody` puts it, to the seat depth
  [C-504](../../specs/007.1-Parts-Catalog.md#c-504--braided-carbon-fibre-square-tube-1) states. **Any prefix-matched file in
  this mirror is worth re-checking the same way** — a file that is the right size and the wrong part
  passes every check the manifest makes.
- `Reference/meshes/700-Differential/710-002_SplitGearBottom.stl` was 1000× out of scale; it is
  dimension-checked against its mates and now also has parametric source
  ([DC-11(f)](../../specs/009-Design-Completion.md#procurement-data)).

The Base Mount Bottom is the only file here taken from the GLTF, and it takes two steps rather than one:

```
scadmesh gltf dde/HDIMeterModel.gltf --node HDI-110-001_BaseMountBottom \
    --frame HDI-110-001_BaseMountBottom --scale 1000 --out raw.stl
scadmesh repair raw.stl --out 100-Base/110-001_BaseMountBottom.stl
```

`--scale 1000` is needed because `--frame` reports the node's own units — metres here — where the default
world export converts to millimetres. And the GLTF mesh arrives with three 11.5 µm holes at the central
bore's seam, so it is not a closed solid until `repair` triangulates them; every other mesh in this
directory is closed, and this one now is too. The repair adds 3 triangles and moves no existing vertex,
leaving surface area and enclosed volume unchanged.

`Reference/meshes/700-Differential/720-002_DiffGearAxle.stl` is the set's only ASCII STL. That is not a
defect — it prints normally — but it is why [MANIFEST.csv](MANIFEST.csv) records it as `ascii-or-nonstd`
with no triangle count.

## Formats, and what can actually be edited

| Format | Where | Editable? |
|---|---|---|
| `.scad` | `700-Differential/` | **Yes** — parametric OpenSCAD source, the intended format going forward (see below) |
| `.stl` | component directories, `Reference/meshes/` | **No.** Mesh only — printable, not meaningfully modifiable |
| `.f3d` | `900-ToolInterface/` | **Yes** — Fusion 360 native, with feature history |
| `.step` | `900-ToolInterface/`, `Reference/onshape-v1/` | **Partly** — B-rep solids. Dimensions can be measured and features cut, but there is no feature tree to drive |
| `.ipt` | `Reference/inventor/` | **Yes** — Inventor native, with feature history |
| `.dwg` | `400-EndArm/`, `900-ToolInterface/`, `Reference/superseded/` | **Partly** — B-rep solids, not 2D profiles as previously recorded here. Each of the three holds one ACIS `3DSOLID` (`421-002` adds six lines and an arc beside it). Reading one needs the [ODA File Converter](https://www.opendesign.com/guestfiles/oda_file_converter); FreeCAD drives it once its path is set, and `ODAFileConverter in/ out/ ACAD2000 DXF 0 1 "*.dwg"` writes the solid as ASCII-encoded SAT in the DXF's group 1 and 3 records |
| `.skp`/`.skb` | `Reference/covers/` | **Yes** — SketchUp source |

**Most of the robot is still mesh-only.** Editable source exists for the differential (`.scad`), the tool
interface (`.f3d`), and the Inventor reference parts. Everything else is a mesh or a dead solid, so
changing one of those parts today means re-deriving it from an STL — the workflow the differential
conversion established (see below). That remaining gap is tracked as
[DC-11](../../specs/009-Design-Completion.md#procurement-data).

## Moving to OpenSCAD

`.scad` is the intended parametric format going forward: it is text, so it diffs and merges in Git, and it
depends on no proprietary tool. Four conventions keep the transition legible:

- **Share the stem.** A rewritten part keeps its mesh's name — `100-001_BaseClamp.scad` for
  `100-001_BaseClamp.stl` — so the two stay findable from each other after they are separated.
- **Treat the STL as output, not source, once a `.scad` exists.** Until then the STL *is* the source of
  record, because for most parts it is the only geometry that exists.
- **Move the mesh to `Reference/meshes/<group>/` when the group is converted**, keeping its stem and
  group directory. It stops being the build source at that point and becomes only what the render is
  gated against, and leaving it in the component directory invites printing the mesh instead of the
  `.scad`. A **converted** part therefore has no `.stl` beside its `.scad`, and which groups have been
  converted is visible from a listing of `Reference/meshes/`. The rule is about a part, not a directory:
  `100-Base/` holds `110-004_BaseMountingPlate.scad` beside six meshes because that part was *authored*
  rather than converted, and the meshes belong to parts nothing has rewritten yet. What a directory must
  never hold is a `.scad` and an `.stl` of the **same** part.
- **Wrap a nested `difference()` in `render()`, not the cut that follows it.** OpenSCAD's *preview*
  normalizes the tree to disjunctive normal form, and `x - (A - B)` rewrites to `(x - A) | (x & B)` —
  one copy of the entire part per term of `A` and of `B`. A subtracted union does not multiply, so an
  array of cuts is rarely the cause even when it is what overflows: it is the nested difference upstream
  that multiplies, and the array merely lands on every copy. Two symptoms follow, and the second is the
  one that gets misread. Past the element cap the normalizer gives up and preview draws an empty tree,
  so a part can export a flawless STL and show nothing. Below the cap it draws, but every primitive is
  redrawn once per product per frame, and the viewport stops turning. `render()` on the nested
  difference collapses it to one mesh, removing the fan-out at its source and costing the export
  nothing. Take the deepest multiplier first: wrapping a downstream cut while a large factor survives
  upstream caps the element count without touching the product count, which cures the empty tree and
  leaves the model exactly as unusable to turn.
  [`730-002_DiffBodyB.scad`](700-Differential/730-002_DiffBodyB.scad) is the worked example — its Ø8
  bore fillet multiplies the whole part, its 115 encoder slots merely land on every copy — and the
  arithmetic and measurements are at that call site. Two things there carry elsewhere. The cheaper
  lever is often not `render()` at all: that fillet's factor is set by how its cutter is built, and
  rebuilding the cutter as a swept polyhedron rather than a chain of hulled spheres took it from 51 to
  7 for nothing. And **measure compile and frame separately** — render the same file at two image
  sizes, because compile does not scale with pixels and a frame does. On that part the variant that
  compiled fastest was the one that could not be orbited, and reading the two costs as a single number
  is what hid it.

**`700-Differential/` is fully converted** (DC-2,
[specs/009](../../specs/009-Design-Completion.md#differential-detail-design)): one `.scad` per part,
shared dimensions in `diff_params.scad`, placements in `diff_assembly.scad`, and `render-all.rs` to render
both configurations and dimensionally verify each render against its reference STL with `scadmesh`
(from the standalone `openscad-tools` project, checked out beside this repository's parent — bounding
boxes, diameter and face-position bands, cross-sections, tooth counts). Use that directory as the template
for converting the remaining groups.

**Printing the differential therefore takes one command first**: `rust-script render-all.rs` writes the
ten meshes to print into `700-Differential/out/revised/`. `out/` is deliberately untracked — a rendered mesh is a build
artifact, and tracking it would leave two copies of the same geometry to disagree. Everything the render
is checked against is under
[`Reference/meshes/700-Differential/`](Reference/meshes/700-Differential/).

`Reference/onshape-v1/parts-step/` is the most useful starting material: STEP solids can be measured for
real dimensions, which an STL cannot give you reliably.

### Verifying a recreated part against its reference

A recreated part is gated on **surface distance**, not on dimensions. `scadmesh compare` asks whether
every reference diameter and face position reappears somewhere in the candidate — a set of
one-dimensional histograms that a wrong body can satisfy in full: a missing boss, a square hole where the
reference has a round one, and a dished flank where the reference bulges all leave the histograms intact.
It once reported ±0.006–0.131 mm agreement on parts deviating by up to 3.8 mm. **A dimensional check is
not a shape check**, and no tightening of its tolerance makes it one. `compare` is retained only to name
*which* dimension moved once `dist` has failed a part; it gates nothing.

The contract every part in `700-Differential/` is held to:

- **`scadmesh dist` within ±0.15 mm in both directions.** Both are required, not a formality:
  candidate→reference finds material the model invented, reference→candidate finds material it never
  reproduced, and a model that is a strict subset of its reference passes the first alone.
- **Build the body from its measured meridional profile** (`scadmesh profile`) rather than from inferred
  diameters and face heights, so flank curvature is reproduced instead of guessed.
- **Preview (F5) as well as render (F6)**, checked rather than assumed — preview fails independently of
  rendering, so exporting an STL and measuring it will pass a part that shows nothing in the GUI. Run
  `openscad --preview -o check.png <part>.scad` and require zero warnings. The failure mode is specific:
  **no cutter may be a module that is internally boolean** — BOSL2's `pie_slice()` and anything taking
  `rounding=`/`chamfer=` are — because `A - (B - C)` normalizes to `(A - B) | (A & C)` and each one
  doubles the preview tree. Build cutters from single primitives, and cut each solid before unioning it
  into an array rather than after.
- **A shared face is not a join.** Where a feature is trimmed to the surface of the blank it stands on,
  CGAL returns the two as separate solids, the blank's face survives the union underneath the feature,
  and the export carries interior surface — which `dist` then measures against nothing, reading over a
  millimetre out on geometry that is dimensionally correct. Trim such a feature to a surface **offset
  into** the blank (`BEVEL_ROOT_UNDER` offsets 0.35 mm) and let the overlap be buried. The `Volumes:`
  line of the render log is the cheap check: a part modelled as one solid must report 2.

**The references are CAD assembly exports (`STLB ASM` headers) and they mislead in three ways.** Run
`scadmesh segment` on a reference before measuring it.

- *Zero-thickness internal shells.* `profile` shows these as doubled-back slivers, one measuring
  0.003 mm across in `710-002`. A clean model must not reproduce them.
- *Unmerged solids.* `710-002` is two bodies — a turned body and a tooth crown, tessellated at 3.85 and
  6.91 triangles/mm² and never merged. Its file volume **double-counts** the ≈352 mm³ where they
  interpenetrate, so a faithful model reads 4.8 % light against the file and correct against the merged
  7001 mm³; volume against an unmerged file is a screening signal, not a verdict. And reference→candidate
  `dist` flags every **buried** surface, because a merged model has no counterpart for them — on this
  part 28 % of reference samples at up to 2.25 mm, none of it a defect. Only candidate→reference gates a
  part whose reference is an assembly export.
- *Stray shells.* `730-002`'s export carries six 1.05 × 1.0 × 1.0 inverted shells (−0.815 mm³ apiece)
  beside the body, and `dist` against the whole file scores them at **0.991 mm**. Against the isolated
  body the same comparison reads **0.332 mm**. Every figure quoted for that part is against body 0, and a
  measurement that skips `segment` reads a part three times worse than it is.

Not every oddity in a reference is an artifact. `720-001`'s apparent degenerate Ø15.5 internal shell is
**twelve Ø0.2 through-holes** on a Ø15.5 circle, 30° apart with one on +x, running the full 60.6 mm of the
part: every triangle around a hole has its normal on that hole's own axis, `segment` returns one closed
body, and the lateral area over any span is π·0.2·span to three decimals. The model reproduces them behind
a `wall_holes` flag. They are **not buildable** — Ø0.2 × 60.6 mm is 303:1, past drilling and far past
printing — so the flag defaults off and the built shaft is solid
([007.2](../../specs/007.2-Printed-Parts.md#differential--0076)).

Two exceptions are enumerated explicitly rather than absorbed into a widened tolerance. The **GT2 pulley**
teeth are cut with a modelled groove profile rather than measured. The **Diff Gear Shaft's tooth form** is
deliberately cut to the shared crown rather than to its own superseded reference
([CR-3A7](../../CHANGES.md)), so its `dist` fails ±0.15 mm in the tooth zone by design; its tooth count
(20, exact), its clocking (within 0.3° of the reference) and every dimension outside the tooth zone are
gated as usual, measured on the render itself. There is **no tooth-band exemption for the bevels** — the
crown is measured (`diff_bevel.scad`) and meets the ordinary surface check with room to spare.

### Checking a group

Every group with `.scad` parts carries a `render-all.rs` (`rust-script render-all.rs`, run from the group
directory). It renders the group's parts into its untracked `out/`, gates each faithful render against
its mesh under `Reference/meshes/<group>/` by the contract above, checks the revised geometry by probing
material and void either side of the faces it moved, and ends in `ALL CHECKS PASSED` or a failure count.

The machinery is shared, not copied: the [`render-check/`](render-check/) crate, which each script takes
as a path dependency, finds OpenSCAD and `scadmesh` (`$OPENSCAD` and `$SCADMESH` first), runs a render and
fails it on any warning, a result CGAL reports as not simple, or an empty one, runs the `dist` gate, probes points, and reads
echoes. A script holds only its own gates and checks. Two rules keep the scripts from drifting apart:

- **A number a check needs comes from the part.** A `.scad` echoes it at top level as
  `echo(name = value)`, and the script reads that line; the value is never retyped into the script.
- **A group that uses another group's part runs that group's script** rather than repeating its gates.
  `500-ExternalGear/render-all.rs` runs `600-StrainWave/render-all.rs` first, because J3's stack
  depends on the Flex Spline Attach.

Two checks are shared across groups. `check_seat` probes a Stator Holder's revised seat against C-201's
hole pattern as [007.1](../../specs/007.1-Parts-Catalog.md#c-201--521-strain-wave-component-set) states
it, rather than as the seat library cuts it, so the probes test the library. `clash_free` renders an
assembly's `clash` pair. It passes when the intersection is empty or has no volume (a seat, where two
parts share a face), and fails when CGAL cannot intersect the pair at all, because a failed boolean
returns one of its operands.

### Measured state of the differential set

`scadmesh dist`, two-sided sampled surface distance against each reference, in mm. All nine parts render
as one clean solid from measured geometry.

| Part | Worst deviation | Volume vs reference | State |
|---|---|---|---|
| 710-001 Split Gear Top | 0.045 | −0.1 % | faithful (p95 0.010) |
| 710-002 Split Gear Bottom | 0.150 | +0.02 % | faithful (p95 0.050) |
| 710-003 Diff Keeper | 0.023 | −0.8 % | faithful |
| 710-004 Rotate Code Disk | 0.350 | −1.4 % | faithful (p95 0.011; one localized edge) |
| 720-001 Diff Gear Shaft | 0.568 / 0.456 | −2.05 % | cut to the shared crown — fails ±0.15 mm by design |
| 720-002 Diff Gear Axle | 0.094 | −0.02 % | faithful (p95 0.028) |
| 720-003 Diff End Pulley | 0.030 | −0.02 % | faithful |
| 730-001 Diff Body A | 0.016 | — | faithful, 0.000 % of samples over tolerance |
| 730-002 Diff Body B | 0.377 / 0.332 | −0.05 % | **not yet gated** — see below |

`710-002`'s 0.150 mm is a defect in the reference, not the model: circle fits at z 6.3–6.9 centre the
Ø8.5 bore and its funnel on (−0.039, 0.138), **0.143 mm off the axis**, while every turned surface around
them fits the axis to 0.001 mm. It is a clearance hole for wire, so the model keeps it concentric, and
that eccentricity is the whole of the part's excursion past tolerance (0.011 % of samples).

`730-002` is absent from `DIST_GATES`. p95 is inside tolerance in both directions (0.136); it is the
maxima that fail, and both are the same feature on opposite y flats — the chimney base's straight sides
meeting the chimney cone, filleted on the reference at radius ≈1.5 and modelled here as sharp
intersections, 0.377 mm at (32.686, −9.406, 31.057) and 0.332 mm at (32.346, −32.469, 30.915). Filleting
those four junctions is the remaining work, tracked as
[DC-2](../../specs/009-Design-Completion.md#differential-detail-design). Its measured geometry — the
profiles are the dimension tables — is recorded in
[`730-002_DiffBodyB.scad`](700-Differential/730-002_DiffBodyB.scad).

### What the rebuild established

Four findings generalise beyond the differential and are worth applying to the remaining groups.

- **Revolved bodies recover as cones.** Every crown surface on `710-001`, `710-002` and `720-002` is a
  cone, and fitting measured radius against height recovers each one exactly — the four fitted on
  `720-002` leave a maximum residual of 0.0003 mm over six heights. Cone intersections then define every
  edge outright, so no corner coordinate is measured twice.
- **Straight bevel teeth are ruled through the gear apex**, so *one* section reproduces the whole tooth:
  scaling it about the axis by the ratio of heights **is** the surface between them, which
  `linear_extrude(scale=)` draws exactly and without facets. Nothing needs a loft through stacked
  sections. Let the revolved envelope supply the tip, root and end faces, leaving the section responsible
  for the flanks alone. The apex is measured rather than assumed — scaling a section at one height onto a
  measured section at another and minimising the mismatch locates it to ±0.02 mm.
- **A bevel flank is a cubic.** Fitted to 253 measured points (the median over 9 heights × 20 teeth,
  which agree among themselves to 0.002 mm), a single cubic Bézier holds them to **0.006 mm max, 0.003
  RMS** — where the polyline it replaced needed several hundred coordinates per part and still rendered
  as visible facets. Rebuilding this way took `710-001` from 0.225 mm to 0.045 mm, made its bounding box
  exact, cut its triangle count by 56 %, and carried the tooth's concave root fillet as measured, which a
  loft through convex hulls cuts the corner across.
- **Author a shared feature once.** The Split Gear and the Diff Gear Axle are not two similar gears but
  one 20-tooth crown placed twice: sections taken 15.4484 mm apart return outlines **0.0001 mm apart over
  4088 points**, already clocked alike, and `710-002` supplies exactly the material inside the parting
  cone that `710-001` lacks — its area agreeing with `720-002`'s whole tooth ring to 0.007 mm² in 858.
  The gear is defined once in `diff_bevel.scad` and each part intersects it with its own envelope, so
  they cannot drift out of mesh in edit.

### What assembling the set showed

Per-part gating cannot see fit: a part can match its own reference to a hundredth of a millimetre and
still not fit its neighbours. `diff_assembly.scad` places every part by a feature it carries rather than
by a typed offset, and records each finding at the call site that exposes it.

- **The three bevels mesh**, checked rather than asserted: the CGAL intersection of the Split Gear
  against the Diff Gear Axle, and against the Diff Gear Shaft, is **empty in both cases** — as is the
  intersection of whole 20T crowns substituted for both side bevels, whose tips are longer than the
  shaft's cut ones and so is the stronger result. A bevel set meshes exactly when its apexes coincide,
  and each part states where its apex sits on its own axis, so placing the parts by those three numbers
  is the whole of the gear train.
- **The Split Gear's halves need no relative transform.** `710-001` and `710-002` are authored in the
  same frame, and their intersection is a set of open shells enclosing **exactly 0.000 mm³ apiece**
  (`scadmesh segment`), bounded by the seating face at z = 4.000 and by `BEVEL_SPLIT_ROOT` — both
  construction points rather than accidents. An earlier assembly mirrored one half against the other,
  which cannot be right: mirrored about the shared apex the two crowns do not overlap anywhere.
- **The brad holes disagreed by 0.5 mm.** `710-001`'s hole runs z 11.534–12.943 and `710-002`'s
  z 12.089–13.456 — about 1.0 mm of common opening for a Ø1.5 hole taking a Ø1.8 interference-fit brad.
  Neither half can move to fix it, so this is a disagreement between the two references. `config="previous"`
  keeps each reference's own value; `config="revised"` drills both at **z = 12.750**, stated once as
  `BRAD_Z` in `diff_params.scad`. That height is the one both parts have material for (it leaves a full
  millimetre of `710-002`'s Ø27 wall below the hole, where 12.250 would leave 0.500 mm) and it is the
  blind, glued half's own value — the hole that actually holds the brad. Verified by intersecting a
  Ø1.45 probe on that axis with both halves as they sit: **empty in `revised`, not empty in `previous`**.
  The assembly draws the four brads only when both halves drill to one line, so the previous config still
  shows the disagreement by leaving them out.
- **Four stack-ups are kept as measurements in `config="previous"`, and `config="revised"` designs them
  out.** The Diff Gear Axle's boss reaches into the shaft's front MR128 seat, and Diff Body B overlaps the
  toes of all three bevel crowns that turn in it. `revised` seats the boss on that bearing and keeps Body B
  the running clearance off each crown's swept teeth. The figures and constructions are in
  [`diff_assembly.scad`](700-Differential/diff_assembly.scad)'s header and `730-002`'s TOE CLEARANCE.

## Viewing an assembly

An assembly `.scad` can be turned into a section viewer page, an orthographic model cut on a movable
plane with its parts listed, grouped and labelled, by `scadmesh view` from `openscad-tools`. The
assembly must be **viewable**:

- A top-level `part` variable selects what it draws: `"all"`, or one part's id, drawn in its assembled
  position.
- Every value the page quotes is echoed at top level as `echo(name = value)`.

A sidecar `<assembly>.view.json` beside it names the parts, colours and groups, the labels and camera
presets, and the notes. It restates no dimension: part heights come from the exported meshes, and text
quotes echoes through `{name}` placeholders. The format is in `openscad-tools`'
`specs/003-CLI.md` § The view sidecar. Every `*.view.json` in this tree names a viewable assembly.

### Prerequisites

- **OpenSCAD**, found as `openscad-tools`' `specs/003-CLI.md` states for `view`.
- **`scadmesh`** on `PATH`, built from `openscad-tools` (its README § Build); `cargo install --path .`
  in that checkout installs it.
- **`miniserve`**: `cargo install miniserve`.

### Building, serving and opening a view

Run from the directory that holds the assembly — `500-ExternalGear/` for the External Gear stack:

```
scadmesh view exgear_assembly.view.json --out out/view
miniserve out/view
```

and `700-Differential/` for the wrist differential, whose assembly imports the mesh cache that
`render-meshes.rs` builds, so the cache is built first:

```
rust-script render-meshes.rs
scadmesh view diff_assembly.view.json --out out/view
miniserve out/view
```

Then open `http://localhost:8080/index.html`.

- `scadmesh view` writes `out/view/index.html` and one `out/view/parts/<id>.json` per part. OpenSCAD
  exports each part in its own run, one after another, so the build takes the sum of the parts'
  renders — about eight minutes for the External Gear stack. The page is output, like any render, and
  `out/` is untracked.
- The page loads its parts over HTTP, so it must be served; opened from disk (`file://`) it draws no
  parts.
- A rebuild while `miniserve` runs needs only a browser refresh. `Ctrl+C` stops the server, and
  `miniserve -p <port> out/view` serves on another port when 8080 is taken.

### Making an assembly viewable

1. **Write the assembly.** A group's assembly is `<group>/<short>_assembly.scad`; the arm's is
   [`robot_assembly.scad`](robot_assembly.scad). Place every part by a feature it carries, as the
   arm's assembly does. Copy the viewable shape from
   [`exgear_assembly.scad`](500-ExternalGear/exgear_assembly.scad): the `part` variable, a `PARTS` list
   of ids, one module per part, a `draw(p)` that dispatches on the id, and an `assembly()` that draws
   every id `part` selects. Echo every value the page will quote.
2. **Check one part exports alone** — `openscad -D 'part="<id>"' -o check.stl <assembly>.scad` — with
   no warnings.
3. **Write the sidecar**, `<assembly>.view.json` beside the assembly, to the format above;
   [`exgear_assembly.view.json`](500-ExternalGear/exgear_assembly.view.json) is the worked example.
   Every part `id` is an entry of `PARTS`, and every number the page shows is a `{name}` placeholder
   for an echo, never typed.
4. **Build and open it** as above. `scadmesh view` rejects an unknown field, a duplicate id, or a
   label, preset, overlap or focus that names no part or preset before it exports anything, so a
   sidecar mistake fails in seconds.

## What was removed

This directory previously mirrored 909 files (571 MB) organized by where they were downloaded from. That
was reduced to the parts a build needs. Removed:

| Removed | Files | MB | Why |
|---|---|---|---|
| Dropbox in-work variants | 281 | 202.8 | Experimental sweeps (`SplitGearRIN5ccw`, `ExternalGearBelt*`) of parts already covered. `PivotSkirt` was the only unique build part and was kept |
| `.x3g` toolpaths | 14 | 104.7 | Makerbot machine code — not geometry, and not for any current printer |
| v1 legacy STL set | 68 | 56.4 | Superseded by the HD sets |
| Parasolid `.x_t` | 140 | 54.3 | **Byte-for-byte the same solids as the STEP files**, in a proprietary kernel format |
| HD set superseded by HD update | 57 | 30.2 | Earlier revision of a part kept elsewhere here |
| OnShape glTF renders | 21 | 6.9 | Display meshes of solids already kept as STEP |
| HD update, not in the build list | 18 | 3.3 | `Foot`, `EndArmHandle`, `KevlarGuide`, skins — no BOM row |

Git history is the version record going forward, so superseded revisions are not kept as files. Everything
above is recoverable from the upstream archives using the method below; nothing removed was unique except
where noted.

## How this was retrieved

Recorded so the mirror can be refreshed or a discarded file recovered. Thingiverse serves no per-file
download URL and blocks plain HTTP clients at the CDN; the working route was:

1. The public web-app token is embedded in Thingiverse's own JS bundle
   (`cdn.thingiverse.com/site/js/app.bundle.js`, exported as `YK`).
2. `api.thingiverse.com` rejects that token from a non-browser client (Cloudflare). The **same-origin
   proxy** at `https://www.thingiverse.com/api/...` accepts it, so requests must run from a browser
   context on the Thingiverse origin.
3. `GET /api/things/{id}/files?per_page=300` lists files; `GET /api/v2/files/{fileId}/download`
   redirects to a plain, unsigned, non-expiring `cdn.thingiverse.com/assets/...` URL.
4. Those CDN URLs fetch fine outside the browser **provided a browser `User-Agent` is sent** — without
   one the CDN answers `429`.

Source archives: [HD set](https://www.thingiverse.com/thing:3206154),
[HD update](https://www.thingiverse.com/thing:3781990),
[tool interface](https://www.thingiverse.com/thing:3166448),
[covers](https://www.thingiverse.com/thing:2842496),
[v1 legacy](https://www.thingiverse.com/thing:2108244),
[Dropbox in-work](https://www.dropbox.com/sh/5bdyhcyyrf3x53k/AAAagpOvq-TxkVKE1Ax-uodEa/STLs?dl=0).
OnShape retrieval is documented [separately](Reference/onshape-v1/README.md#how-this-was-retrieved).

## Regenerating

`PART-INDEX.md` and `MANIFEST.csv` are derived artifacts. Regenerate them after adding or replacing model
files, and re-check them whenever
[007.2](../../specs/007.2-Printed-Parts.md#regenerating-this-list) is regenerated.

## Licence

The Thingiverse sets are published by Haddington Dynamics under **GNU GPL**. They keep that licence here;
mirroring does not change it. The OnShape document is owned by a different account and states no licence —
see [its README](Reference/onshape-v1/README.md#licence) before redistributing those files.
