# 730-002 Diff Body B — reference geometry

Measurements recovered from `730-002_DiffBodyB.stl` with `scadmesh`, recorded so the rebuild
([CR-3A16](../../../../CHANGES.md) withdrew the authored-redesign exception) starts from measurement
rather than from the bounding box. Status keys follow [specs/README.md](../../../../specs/README.md).

Everything here is stated once and referenced elsewhere; the part file consumes these numbers.

## Preparing the reference

The published mesh is a CAD **assembly** export and carries six degenerate shells beside the part —
92 triangles each, enclosing **−0.815 mm³** (inverted normals). Strip them before measuring anything:

```
scadmesh segment 730-002_DiffBodyB.stl --out out/730-002-ref.stl --keep 0
```

| | whole file | main body only |
|---|---|---|
| triangles | 20032 | **19480** |
| volume | 16689.421 mm³ | **16694.312 mm³** |

`16694.312 − 6 × 0.815 = 16689.42`, which is the arithmetic that confirms the split. **The recreation
target is 16694.312 mm³**, not the file's 16689.421.

Bounding box (main body): `39.000 × 58.994 × 80.500`, min `(8.000, −50.496, −8.500)`,
max `(47.000, 8.498, 72.000)`.

## Frame and symmetry

Three mutually perpendicular axes meet at the differential centre:

| axis | direction | position | carries |
|---|---|---|---|
| tunnel | Y | (x, z) = (21, ~21) | Diff Gear Shaft — but see the caution below |
| column | Z | (x, y) = (21, −21) | Split Gear stub and thrust tube |
| **J4** | **X** | **(y, z) = (−21, 21)** | mating rim to Diff Body A's Ø60 plate |

`[Specified]` — **one mirror plane, y = −21.0**. A section-area sweep along Y is symmetric about it to
better than 0.3% at every station (e.g. y = −30 → 592.34 mm² against y = −12 → 592.59 mm²).

## Two premises of the authored redesign that measurement disproves

- `TUNNEL_Y = [-50.5, 8.5]` **is not a tunnel span.** It is the diameter of the J4 mating rim, whose
  radius is **29.4925** about (y, z) = (−21, 21) and which therefore reaches y = −50.4925 … 8.4925 —
  the measured bounding box to 0.004 mm. The body proper stops at **y ≈ −45**; outside that there is
  only thin rim. The span was read off the bounding box and attributed to the wrong feature.
- **There is no through-bore on the tunnel axis.** Probing (21, y, 20.5) returns *solid* at y = −36 and
  −32, and again at −10 and −6, with void between. Body B is a fork: two solid side walls with the gear
  cavity between them. The authored `TUNNEL_ID` bore running the full span does not exist.

## Column along Z at (x, y) = (21, −21)

`[Specified]` — recovered from the meridian on the y = −21 section; every point fits its surface to
better than **0.004 mm**.

| z range | feature |
|---|---|
| 29.750 → 30.750 | concave fillet **R1.000**, centre (z 30.750, r 6.000), r 6.000 → 7.000 |
| 36.000 → 40.500 | cylinder **Ø17.000** |
| 40.500 → 42.000 | convex round **R1.500**, centre (z 40.500, r 7.000), r 8.500 → 7.000 |
| 42.000 | flat annular shoulder, r 4.500 → 7.000 |
| 42.000 → 42.500 | **45° chamfer**, 0.500 leg, r 4.500 → 4.000 |
| 42.500 → 72.000 | tube **Ø8.000** |

Between z 34.0 and 36.0 the section flares from r 10.5 to r 8.5; that blend is `[TBD]`.

## Wire bore — an octagon, not a round hole

`[Specified]` — constant from z ≈ 32 to the top of the tube at z = 72, centred on the column axis.

A **3.500 (x) × 6.000 (y) rectangle with 45° chamfers of leg 1.300** across all four corners:

```
(1.750, 1.700) (0.450, 3.000) (−0.450, 3.000) (−1.750, 1.700)
(−1.750, −1.700) (−0.450, −3.000) (0.450, −3.000) (1.750, −1.700)
```

Shoelace on those vertices gives **17.620 mm²** against a measured **17.493 mm²**. The 0.127 mm²
difference is exactly four single facets where each chamfer meets the top edge, so the corner carries a
small rounding that the tessellation renders as one chord per corner. Fitting a circle to this loop
returns Ø5.43–5.55 at rms 0.25–0.36 while the area implies Ø4.72 — the area/fit disagreement is what
identifies it as non-circular.

## J4 mating rim

`[Provisional]` — outer radius **29.4925**, inner radius **22.000**, about the X axis at (y, z) =
(−21, 21). Present from x ≈ 45.7 to x = 47.000. It is **not axisymmetric**: at r = 24 the material runs
x 45.7 → 47, while at r = 27.1, y = +6 the same x range is void, so the rim is scalloped or partial.
Its true outline is `[TBD]`.

## Gear cavity about the J4 axis

`[Provisional]` — a bore about the X axis opening toward the mating face: radius **11.500** at x = 30,
**22.000** at x = 46.6. Whether it is a cone, a step, or a blend is `[TBD]`.

## Reading the mesh — two traps in this reference

- **Near-tangent slivers.** Where a curved surface runs nearly parallel to a section plane, its
  tessellation breaks into many congruent slivers that read as a regular feature array. At x = 46.6 this
  produces **115 loops of identical area (3.445 mm²), identical fit (Ø3.828, rms 0.299), on a flawless
  3.130° pitch at r = 27.107** — convincingly an encoder ring. Dumping one outline shows a
  4.3 × 0.86 mm splinter. Always dump an outline before believing a pattern; `slice` sorts loops by
  area descending, so `head`, not `tail`, shows the real geometry.
- **`fit` assumes a turned part.** Run about z on this body it reports bosses of Ø94, because it is
  fitting cylinders about an axis the part is not turned on. It is not applicable to Body B as a whole.

## Open before the rebuild can be gated

1. The sculpted outer shell. A circle fit to the y = −36 outline leaves a 2.7 mm residual, so it is not
   a simple revolve; it needs its own decomposition.
2. The bearing seats — diameter, depth and axis. The existing `render-all.rs` `DIAMS` entries for
   730-002 check an axis and stations taken from the authored model and are therefore unverified.
3. The rim outline and the cavity blend, per the `[TBD]`s above.
4. The wire entry channels: position, diameter, and where they break into the cavity.
