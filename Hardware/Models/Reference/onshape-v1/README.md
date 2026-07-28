# OnShape export — v1 design

Export of the public OnShape document that [007.2](../../../../specs/007.2-Printed-Parts.md#model-file-sources)
names as the CAD source. Retrieved 2026-07-26 with a signed-in (free-tier) OnShape account — the export
endpoints reject anonymous requests, which is why this could not be mirrored alongside the
[Thingiverse sets](../../README.md).

**This is reference material, not build material.** It is the superseded v1 robot, and it is not a
parametric model. Both claims are evidenced below.

| | |
|---|---|
| Document | **"Dexi"** — [2af8ed0e…](https://cad.onshape.com/documents/2af8ed0e61a34ebf69284c68/w/72caf65e51bde98e456925d2/e/6843c182cbf9181dbb307455) |
| Owner | Todd Enerson |
| Created | 2017-02-11 |
| Workspace | `72caf65e51bde98e456925d2` |
| Contents | 1 Part Studio (140 solids), 48 assemblies, 3 drawings |

## This is not a parametric model

⚠️ **The Part Studio contains exactly one feature — `Import 1`** — a `BTMParameterForeignId` pointing at
foreign CAD (`589eb21afb258f0f71a59f68`). All 140 solids arrived through that single import. There are no
sketches, no extrudes, no editable dimensions, and no feature history to recover.

Two consequences:

- **The STEP files here are the full fidelity OnShape holds.** Nothing is lost by working from them rather
  than from the OnShape document; there is no richer source behind them.
- **007.2's original description of OnShape as "the parametric source of record" was wrong.** It is a
  container for imported dead solids. The genuinely parametric source is whatever CAD system produced that
  import, and it is not in this document.

The original imported file is **not retrievable** — the foreign element ID returns `404` from every
blob-element and document endpoint tried. It was deleted, or it lives in a document that is not public.

`partstudio-features.json` holds the raw feature response, so this is checkable rather than taken on trust.

## This is the v1 design, not the HD build list

⚠️ Parts are numbered `KP00xx`/`KA00xx` — a scheme belonging to this document alone, unrelated to the
authoritative `PBS #` part numbering or to the `HDI-` CAD IDs
([007.2 § Part identifiers](../../../../specs/007.2-Printed-Parts.md#part-identifiers)). Matching the 87
`KP`-numbered parts against the STL sets by name, at the time those sets were still mirrored:

| Matches by name | Count |
|---|---|
| v1 legacy set | 40 |
| HD set | 8 |
| HD update | 7 |
| No name match in any STL set | 46 |

Only **11** distinct parts match the HD sets — the union, not the sum, since some match both. So this
document corresponds to the **superseded v1 robot**. Treat any part here as v1 geometry unless it is
confirmed against the current parts in [`Hardware/Models/`](../../README.md). Name matching is exact-stem,
so a part could exist under a different name — the counts bound the overlap, they do not prove identity.

## What this recovers that exists nowhere else

Of the 46 `KP` parts with no STL counterpart, about 40 are fabricated rather than bought. Two groups matter:

- **The differential mechanism internals** — `SideDifferentialGear`, `SideDifferentialGear2`,
  `OutterFrontDifferentialGear`, `InnerFrontDifferentialGear`, `SmallDifferentialShaft`,
  `DiffA1CodeDiskFine`. [007.2](../../../../specs/007.2-Printed-Parts.md) records the differential group as
  `[Provisional]` precisely because the in-repo GLTF contains only the differential **covers**, not the
  mechanism internals ([DC-2](../../../../specs/009-Design-Completion.md#differential-detail-design)). Those
  internals are here as solids. Since 007.2 also states the current differential group *realizes the
  previous version's differential as a working substitute*, this v1 geometry is directly applicable.
- **Strain-wave drive geometry** — `GearCSF-14-XXX-2A-R`, `CamLeverCSF-14-XXX-2A-R`,
  `KP0008-01_GearCupCSF-14-XXX-2A-R`, plus `CSF-14-2A-R FLEXSPLINE` and `14 WG BEARING` solids. Relevant to
  [DC-1](../../../../specs/009-Design-Completion.md#strain-wave-component-set), which turns on which
  vendor's component set the adapters are cut to.

Also unique here: slip-ring parts (`SlipRing`, `SlipRingBrushA`/`B`, `SlipRingBracketV2`), the wrist and
elbow shafts, and `ForarmBeam`.

## Layout

| Path | Files | What |
|---|---|---|
| `parts-step/` | 140 | Per-part **STEP** (ISO-10303-21). B-rep solids, readable by FreeCAD, Fusion, SolidWorks, anything |
| `assemblies/definition/` | 48 | Assembly JSON with occurrences, transforms, mate features and mate connectors |
| `assemblies/KA0006-01_Main_flattened.step` | 1 | The **whole robot**, flattened, in assembled positions |
| `parts-index.json` | — | `file` → part name, `partId`, `elementId`, `bodyType` |
| `elements.json` | — | All 52 document elements with type |
| `partstudio-features.json` | — | The raw feature list; evidence for the "single Import feature" claim above |

All 140 STEP files were verified to open with `ISO-10303-21` and close with `END-ISO-10303-21`, and all JSON
verified to parse.

**Two exported formats were dropped** when this directory was reorganized:

- **Parasolid `.x_t` (140 files, 54.3 MB)** — the same solids as `parts-step/`, in a proprietary kernel
  format. STEP is the ISO standard and opens in open-source tools, so nothing is lost.
- **glTF (21 files, 6.9 MB)** — display meshes of solids already held here as STEP.

Both are re-exportable from OnShape with the method below.

## How this was retrieved

OnShape's export endpoints (`/parasolid`, `/stl`, and the translation API) redirect cross-origin, so a
browser `fetch` on `cad.onshape.com` fails CORS. The route that worked, using the signed-in session:

1. Drive Playwright's **`page.request`** API context — it shares the browser cookie jar but is Node-side,
   so it follows redirects and is not subject to CORS. Session cookies never touch disk.
2. `GET /api/v6/parts/d/{did}/w/{wid}/e/{eid}/partid/{pid}/parasolid` returns Parasolid directly.
3. STEP needs the async translation API: `POST …/translations` with `formatName: STEP` (**requires the
   `X-XSRF-TOKEN` header** taken from the `XSRF-TOKEN` cookie, or it answers `401`), then poll
   `GET /api/v6/translations/{id}` until `requestState` leaves `ACTIVE`, then
   `GET /api/v6/documents/d/{did}/externaldata/{id}`.
4. Bytes were streamed to a loopback-only receiver that wrote them here.

## Licence

The OnShape document is public but carries no explicit licence grant. The Thingiverse sets by Haddington
Dynamics are GPL; **this document is owned by a different account and its terms are not stated.** Confirm
before redistributing these exports.
