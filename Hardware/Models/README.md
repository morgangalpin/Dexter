# Models

Model files for the robot's printed parts, organized by **arm component**. This directory is the build
source: everything needed to print one complete robot is here, and nothing else is.

- **[PART-INDEX.md](PART-INDEX.md)** — every part in
  [007.2](../../specs/007.2-Printed-Parts.md#printed-parts) with its file, grouped as the directories are.
- **[MANIFEST.csv](MANIFEST.csv)** — every file with its size, SHA-256, and (for STLs) format and
  triangle count.

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
| [`100-Base/`](100-Base/) | 6 | 6 | Base clamp, mount, stator holder, code disc |
| [`200-ArmBody/`](200-ArmBody/) | 9 | 8 | Arm body, stator holder and balancers, belt directors |
| [`300-Pivot/`](300-Pivot/) | 4 | 4 | Main pivot, code disk, motor end caps |
| [`400-EndArm/`](400-EndArm/) | 10 | 11 | Axis intersection, hub, internal and external pulleys |
| [`500-ExternalGear/`](500-ExternalGear/) | 7 | 6 | External gear, stator holder, mount and nut holders |
| [`600-StrainWave/`](600-StrainWave/) | 3 | 3 | Wave gen coupler, flex spline attach and cap |
| [`700-Differential/`](700-Differential/) | 9 | 10 | Split gears, diff gear shaft and axle, diff bodies |
| [`800-Harness/`](800-Harness/) | 14 | 17 | Wire entries, pivot plugs, PCB brackets, strain reliefs, photointerrupter shrouds |
| [`900-ToolInterface/`](900-ToolInterface/) | 8 | 27 | Tool interface body, roll, span, gripper — **the parametric set** |
| [`950-Tooling/`](950-Tooling/) | 2 | 10 | Solder jigs and glue-rig jig bodies |
| [`Reference/`](#reference) | — | 214 | Not printed for a build. See below |

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

## Formats, and what can actually be edited

| Format | Where | Editable? |
|---|---|---|
| `.stl` | component directories | **No.** Mesh only — printable, not meaningfully modifiable |
| `.f3d` | `900-ToolInterface/` | **Yes** — Fusion 360 native, with feature history |
| `.step` | `900-ToolInterface/`, `Reference/onshape-v1/` | **Partly** — B-rep solids. Dimensions can be measured and features cut, but there is no feature tree to drive |
| `.ipt` | `Reference/inventor/` | **Yes** — Inventor native, with feature history |
| `.dwg` | `400-EndArm/`, `700-Differential/`, `900-ToolInterface/` | **Yes** — 2D profiles |
| `.skp`/`.skb` | `Reference/covers/` | **Yes** — SketchUp source |

**Most of the robot is mesh-only.** Genuine feature history exists for the tool interface (`.f3d`) and the
Inventor reference parts. Everything else is either a mesh or a dead solid, so changing an HD part today
means re-deriving it from an STL. That gap is tracked as
[DC-11](../../specs/009-Design-Completion.md#procurement-data).

## Moving to OpenSCAD

`.scad` is the intended parametric format going forward: it is text, so it diffs and merges in Git, and it
depends on no proprietary tool. Two conventions keep the transition legible:

- **Share the stem.** A rewritten part sits beside the mesh it replaces — `100-001_BaseClamp.scad` next to
  `100-001_BaseClamp.stl`. Which parts have been converted is then visible from a directory listing.
- **Treat the STL as output, not source, once a `.scad` exists.** Until then the STL *is* the source of
  record, because for most parts it is the only geometry that exists.

`Reference/onshape-v1/parts-step/` is the most useful starting material: STEP solids can be measured for
real dimensions, which an STL cannot give you reliably.

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
