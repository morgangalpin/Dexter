// #730-002 Diff Body B — parametric source (DC-2), faithful recreation.
// The pivoting differential carrier. The Diff Gear Shaft spins in the two
// 6703s pressed into the ends of the X bore (008.6 steps 3, 12); that bore
// IS the J4 pivot axis, and the shaft continues outward into Diff Body A's
// 6705 / 6703. Perpendicular to it, the Ø17 column carries the Split Gear on
// its 6703, and the Ø8 tube above carries the Split Gear's MR128, the thrust
// stack (2x AS0819 + AXK0819), and the epoxied Diff Keeper (steps 5, 23).
// The tool conductors run up the tube's bore (step 14), which is not round —
// see WIRE_POLY below.
//
// This file is a recreation of 730-002_DiffBodyB.stl, not an authored
// redesign: it is gated on `scadmesh dist` +/-0.15 mm in both directions,
// the same contract as the other six 700-series parts. See specs/009
// § Differential detail design. The reference measurements live here
// rather than in a document of their own — the profiles below ARE the
// dimension tables, and each comment records where its numbers came from.
//
// PREPARING THE REFERENCE. The published mesh is a CAD assembly export and
// carries six degenerate shells beside the part — 92 triangles each,
// enclosing -0.815 mm3 apiece on inverted normals. Strip them before
// measuring anything:
//
//   scadmesh segment ../Reference/meshes/700-Differential/730-002_DiffBodyB.stl \
//       --out out/730-002-ref.stl --keep 0
//
// which takes 20032 triangles and 16689.421 mm3 to 19480 and 16694.312.
// That 16694.312 - 6 x 0.815 = 16689.42 is the arithmetic confirming the
// split, and 16694.312 mm3 — not the file's 16689.421 — is the target.
// Bounding box of the main body alone: 39.000 x 58.994 x 80.500, from
// (8.000, -50.496, -8.500) to (47.000, 8.498, 72.000).
//
// The part as measured:
//   - It has TWO axes, not three. The X axis at (y, z) = (-21, 21) is both
//     the J4 pivot and the shaft tunnel; the Z axis at (x, y) = (21, -21) is
//     the column. They meet at (21, -21, 21). The authored redesign put the
//     tunnel along Y, having read TUNNEL_Y off the bounding box — that span
//     is the mating rim's diameter, not a tunnel. There is no Y bore at all.
//   - Everything below the chimney is a SURFACE OF REVOLUTION about the X
//     axis: outer shell, both 6703 seats, the shaft clearance, the bevel
//     relief, the conical wall and the mating rim. Per-x-section circle fits
//     return the axis to within 0.003 mm with residuals of 0.001-0.011 mm.
//   - The chimney base is a 45-degree cone of revolution about the COLUMN
//     axis, rho = 47.520 - z, capped by an R1 round onto the z = 34 face. It
//     is trimmed by four straight sides — the two y flats at |dy| = 12.460
//     and the two x walls at |dx| = 10.988 — leaving the cone's own arcs at
//     the corners. That single surface replaces what an earlier reading took
//     for a rounded rectangular boss with a growing corner radius.
//   - The single mirror plane is y = -21, verified to 0.3% on a section-area
//     sweep. The bore system is symmetric about x = 21 as well.
//
// WHERE THIS STANDS. Volume 16689.5 mm3 (-0.03%), bounding box 39.000 x
// 58.985 x 80.492, hausdorff 0.414 mm, rms 0.049 / 0.045, p95 0.136 both
// ways, 1.2% of candidate points and 0.5% of reference points outside
// tolerance. That FAILS the 0.15 mm gate on max, so 730-002 is deliberately
// absent from render-all.rs's DIST_GATES; add it there when, and only when,
// it passes. (Quote the volume to one decimal: OpenSCAD's tessellation is
// not bit-stable run to run, and two renders of this file differed by 8
// triangles and 0.004 mm3.) Three residuals are known, the first
// undiagnosed:
//   1. The top corner of the -X end face, at (8.001, -22.554, 34.000) where
//      the z = 34 clip meets it — 0.414 mm, the worst candidate point, and
//      the only thing now holding the gate.
//   2. The chimney base's straight sides meeting the chimney cone. Both
//      junctions are filleted on the reference, radius about 1.5, and are
//      modelled here as sharp intersections. This is now the worst REFERENCE
//      point, 0.332 mm at (32.346, -32.469, 30.915) — the top of the
//      z 30.22..30.91 band over which an x wall shows before the cone
//      becomes the tighter bound. An earlier note here put the cost of this
//      simplification at about 0.10 mm; that was measured on a y flat and
//      understates the x wall by 3x.
//   3. The wire bore's lead-in loft, about 0.10 mm.
//
// The encoder track used to be listed here as a fourth, undiagnosed residual
// — the worst reference point at x = 46.875, r = 25.000 about the J4 axis.
// It was the tie rings: the track had been modelled as a plain through
// cuboid, so the slots ran 24.500..28.800 the whole depth of the rim instead
// of closing to the 25.000..28.574 read slit over the last 0.250 mm. Adding
// them took that side from 0.399 to 0.332 mm, its p99 from 0.190 to 0.139,
// its share of out-of-tolerance points from 1.16% to 0.53%, and the volume
// from -0.13% to -0.03%. See the track's own comment below. The lesson is
// the general one for this file: a section taken at one depth is not the
// feature. Sweep the depth before believing a cut is prismatic.
//
// READING THE MESH — two traps particular to this reference. Where a curved
// surface runs nearly parallel to a section plane its tessellation breaks
// into many congruent slivers that read as a regular feature array, so dump
// an outline before believing a pattern; `slice` sorts loops by area
// descending, so head, not tail, shows the real geometry. The converse trap
// is worse, and cost a full pass here: the 115 congruent loops in the rim
// were dismissed as exactly that artefact and are in fact the encoder
// slots. Separately, `fit` assumes a turned part — run about z on this body
// it reports bosses of Ø94, because it is fitting cylinders about an axis
// the part is not turned on, so it does not apply to Body B as a whole.
// (Both of this part's axes sit at -21, and `slice` wants `--at=-21.0`; the
// spaced form is parsed as a flag and exits 2.)
//
// House style is followed except for edge breaks: no chamfer or roundover is
// added for printability, because every edge here has to match a measurement.

include <diff_params.scad>

/* [Hidden] */
// The two axes, from diff_params.scad -- the assembly places this part by
// putting their crossing on the differential centre, and reads them from there.
J4_YZ  = BODY_B_J4_YZ;    // tunnel / pivot axis (y, z); runs along X
COL_XY = BODY_B_COL_XY;   // column axis (x, y); runs along Z

CLIP_Z    = 34.0;         // the flat face the chimney base rounds onto
FLAT_Y    = 12.460;       // vertical side flats, +/- this about the mirror plane
FLAT_Z0   = 30.2195;      // where they start: 21 + sqrt(15.5^2 - FLAT_Y^2)
TOP_R     = 1.414;        // round from those flats onto the z = 34 face
BOSS_X    = 10.988;       // the chimney base's x walls, +/- this about the column
CHIM_C    = 47.520;       // chimney base cone: rho = CHIM_C - z (45 degrees)
CHIM_R    = 1.000;        // round from that cone onto the z = 34 face

CONE_X    = 32.700;       // where the shell turns conical
CYL_X     = 34.000;       // beyond here the top is cut by planes through the
CONE_ANG  = 35.0;         // axis at this angle, rather than by the chimney

RIM_OD    = 29.4925;      // mating rim, against Diff Body A's Ø60 plate
RIM_X     = [45.700, 47.000];

// J4 encoder track. 115 radial slots on an exact 360/115 pitch; each is a true
// rectangle (its sides hold a constant perpendicular offset from the radius
// over the whole 4.3 mm length, so it is a cuboid cut, not a wedge). Same
// construction as 710-004's disk, which carries J5's 100.
SLOTS      = 115;
SLOT_R     = [24.500, 28.800];
SLOT_W     = 0.800;
SLOT_PHASE = 2.270;       // angle of the first slot, from +y toward +z

// The track is NOT cut clean through. Over the last 0.250 mm to the mating
// face the slots are bridged at both ends by thin rings that tie the 115 teeth
// together, leaving a read slit of r 25.000..28.574 where the body of the slot
// is 24.500..28.800. Section the reference either side of the step and the
// slots measure differently — r 24.500..28.800 over a length of 4.300 at
// x = 45.75, 46.00, 46.35 and 46.70, and r 25.000..28.574 over 3.574 at 46.80,
// 46.85, 46.90 and 46.99, on all 115 slots at every position. `planes --axis x`
// puts the step at 46.750 exactly. The ends of the slit are cylindrical, not
// flat: across one slit the radial reading falls 28.5740 -> 28.5712 from the
// centre to the side wall, which is r*cos(v/r) for r = 28.574 and not a chord,
// so the ties are stated here as revolves and cut back out of the slot.
//
// Only the slit edges — 25.000 and 28.574 — are geometry. Each ring is run a
// millimetre past the slot on its other side rather than stopped on SLOT_R:
// ended flush it shares a face with the cuboid it is cut out of, and the
// difference sheds a sliver per slot instead of closing (231 loops of
// 0.007 mm2 where there should be 115 of 2.86).
TIE_X      = 46.750;      // where the ties start; they overrun the RIM_X[1] face
TIE_R      = [[SLOT_R[0] - 1, 25.000], [28.574, SLOT_R[1] + 1]];

// Wire bore blends.
WIRE_R    = 4.000;        // Ø8 conductor bore below the tube
GROOVE_R  = 11.000;       // Ø22 bevel relief — the bore breaks through here
GROOVE_X  = [19.000, 23.000];
BLEND_R   = 2.000;        // round between that relief and the wire bore
LEAD_R    = 0.900;        // round from Ø8 into the octagon, y direction only
POLY_HY    = 3.000;

function arcpts(cx, cy, r, a0, a1, n = 24) =
    [for (i = [0:n]) [cx + r * cos(a0 + (a1 - a0) * i / n),
                      cy + r * sin(a0 + (a1 - a0) * i / n)]];

// ---------------------------------------------------------------------------
// Profiles revolved about the X axis. Each point is [radius, x], so the
// polygon is the part's own meridian and can be read against the reference's
// y = -21 section directly.
// ---------------------------------------------------------------------------

// The outer shell is two nested revolves that take different top cuts, and
// separating them is what makes the top of the part come out right. The
// BARREL, r = 15.500, runs the whole length to x = 32.700 and is capped by
// the chimney; the COLLAR outside it — the r = 18 band, the 45-degree cone
// and the rim — is cut instead by the two 35-degree planes through the axis.
// An x-section at 30 shows both: a 250-degree arc at r = 18 with the chords
// running in to r = 15.500, and above them the chimney's tower standing on
// the barrel. Treating the whole shell as one solid under one clip removes
// the collar's wings and costs 2500 mm3. That the arc really is 250 degrees
// is confirmed downstream by area: at x = 43, 250/360 x 289.03 = 200.6 mm2
// against 200.450 measured.
//
// The -X end is a narrow radial face at x = 8.000, only 0.586 mm tall,
// reached by an R1 round from the 45-degree flank; the matching R1 round on
// the bore side is in BORE below.
BARREL = concat(
    [[ 0.000,   8.000],
     [12.500,   8.000],   // inner round's tangent on the end face
     [13.086,   8.000]],  // outer round's tangent on the end face
    arcpts(13.086, 9.000, 1.000, 270, 315, 8),   // R1 -> (13.793, 8.293)
    [[15.000,   9.452],   // 45-degree flank, r = x + 5.5
     [15.483,   9.586],   // small shoulder onto the cylinder
     [15.500,   9.700],
     [15.500,  CONE_X],
     // Past CONE_X the barrel carries only the 6703 seat's end wall — the
     // "lip" that an x = 33 section shows as a near-full ring, r 11.5 to
     // 14.484, capped by the chimney rather than by the 35-degree planes.
     [15.483,  CONE_X],
     [15.483,  CYL_X],
     [ 0.000,  CYL_X]]
);

COLLAR = [
    [ 0.000,  28.700],
    // A sharp radial step out from the barrel, deliberately unblended: the
    // y = -33 section shows it as a vertical face, r 15.50 to 18.00.
    [18.000,  28.700],
    [18.000,  CONE_X],
    [24.000,  38.700],   // 45-degree cone
    [24.000,  RIM_X[0]],
    [RIM_OD,  RIM_X[0]], // mating rim
    [RIM_OD,  RIM_X[1]],
    [ 0.000,  RIM_X[1]],
];

// Everything cut away on the axis: both 6703 seats, the two Ø17.5 shaft
// lands, the Ø22 bevel relief between them, and the conical inner wall. The
// profile doubles back at x 32.7..34.0 — that is a real annular groove
// between the seat's end wall and the conical wall, not a measurement error.
BORE = concat(
    [[ 0.000,   7.000],
     [12.500,   7.000]],
    arcpts(12.500, 9.000, 1.000, 270, 180, 12),   // R1 off the -X end face
    [[11.500,  13.800],   // Ø23.000 6703 seat
     [10.500,  13.800],
     [10.500,  14.000],
     [ 9.750,  14.000]],
    arcpts(9.750, 15.000, 1.000, 270, 180, 12),   // R1 into the shaft land
    [[ 8.750,  GROOVE_X[0]],                      // Ø17.500 shaft land
     [GROOVE_R, GROOVE_X[0]],                     // Ø22.000 bevel relief
     [GROOVE_R, GROOVE_X[1]],
     [ 8.750,  GROOVE_X[1]],
     [ 8.750,  27.000]],
    arcpts(9.750, 27.000, 1.000, 180, 90, 12),    // R1 out of the shaft land
    [[10.500,  28.000],
     [10.500,  28.200],
     [11.500,  28.200],   // Ø23.000 6703 seat
     [11.500,  33.000]],
    arcpts(12.500, 33.000, 1.000, 180, 90, 12),   // R1 at the seat's mouth
    [[13.070,  CYL_X]],                           // the seat's end wall
    arcpts(13.070, 33.000, 1.000, 0, 45, 8),      // R1 -> (13.777, 33.707)
    [[14.784,  CONE_X],   // 45-degree groove flank
     [15.483,  CONE_X],
     [22.000,  39.200],   // conical inner wall, 2.5 mm thick
     [22.000,  48.000],
     [ 0.000,  48.000]]
);

// ---------------------------------------------------------------------------
// Column, revolved about Z. Every point on this meridian fits its surface to
// better than 0.004 mm, so the ladder below is measured, not inferred from
// the bearing catalogue.
// ---------------------------------------------------------------------------
COLUMN = concat(
    [[0.000, 29.750],
     [6.000, 29.750]],
    arcpts(6.000, 30.750, 1.000, 270, 360, 12),   // R1 cove off the shell
    [[7.000, 31.500],
     [7.200, 31.500],
     [7.200, CLIP_Z],
     [10.500, CLIP_Z]],
    arcpts(10.500, 36.000, 2.000, 270, 180, 16),  // R2 into the Ø17 journal
    [[8.500, 40.500]],
    arcpts(7.000, 40.500, 1.500, 0, 90, 16),      // R1.5 off it
    [[4.500, 42.000],                             // flat annular shoulder
     [4.000, 42.500],                             // 45-degree chamfer, 0.5 leg
     [4.000, 72.000],                             // Ø8.000 thrust tube
     [0.000, 72.000]]
);

// The conductor path, in three parts. Below the tube it is a plain Ø8.000
// hole, running clear through the shell — it exits the bottom at z = 5.5 and
// there is no material below that on this axis. Inside the tube it is not
// round at all but the 12-gon below, 3.500 across x by 6.000 across y.
// Between the two the lead-in is not a revolve — R2 in x, R0.9 in y — so it
// takes a profile of its own.
//
// What identifies the section as non-circular is that its area and its
// circle fit disagree: fitting a circle returns Ø5.43-5.55 at rms 0.25-0.36
// while the area implies Ø4.72. Area, not the fit, is the trustworthy
// measurement of a polygonal hole.
// The Ø8 ends at 32.000 EXACTLY, and the exactness is the point: the lead-in
// starts there, BLEND_ZTOP clips the fillet there, and the reference shows all
// three meeting in one flat. Its x = 21 section reads that flat as dy 3.900 ->
// 4.067, which is the lead-in's y half-width at z = 32 (lead_hy(32) = 3.900),
// then the bore wall at 4.000, then the fillet's truncation. Carried to 32.050
// — an overlap this file did not need, since a union of cutters meeting on a
// plane is exact — the bore outlived the lead-in by 0.050 mm, and because the
// lead-in is turning fastest there that 0.050 mm of height came back as a
// 0.360 mm ledge: the same section read dy 3.640 -> 4.000 at z = 32.050, a
// step ring standing inside the bore where the reference has none. A cutter
// that overshoots into a taper does not err by its overshoot; it errs by the
// overshoot divided by the taper's slope.
WIRE_ROUND = [[0.000, -1.000], [4.000, -1.000],
              [4.000, 32.000], [0.000, 32.000]];

// Each corner carries two chamfers, not one — 45 degrees off the x face and
// then 22.5 degrees onto the y face — so the section is a 12-gon. Shoelace on
// these vertices gives 17.4919 mm2 against 17.4927 measured; the single-
// chamfer octagon that fits the same x and y flats is 0.13 mm wide of the
// real corner over the whole 38 mm of tube.
WIRE_POLY = [
    [ 1.750,  1.700], [ 0.662,  2.788], [ 0.150,  3.000],
    [-0.150,  3.000], [-0.662,  2.788], [-1.750,  1.700],
    [-1.750, -1.700], [-0.662, -2.788], [-0.150, -3.000],
    [ 0.150, -3.000], [ 0.662, -2.788], [ 1.750, -1.700],
];
WIRE_POLY_Z = [33.900, 73.000];
POLY_HX     = 1.750;

// The lead-in from the Ø8 hole into the 12-gon is a genuine loft and is not a
// revolve: R2.000 in x (centre 3.750, z = 34.000) but R0.900 in y (centre
// 3.900, z = 32.900), with a 0.25 mm step in x where the Ø8 ends. The
// anisotropy is the whole point — over this span the y face does not move at
// all while the x face moves 0.28 mm, which is why isotropic offset, uniform
// scale, and the convex hull of the two end sections all fail:
//
//        z      x half-width   y flat half-width
//      33.0        2.030            0.296
//      33.4        1.854            0.205
//      33.7        1.785            0.166
//      33.9        1.762            0.155
//     >=34.2       1.750            0.150
//
// Scaling the 12-gon anisotropically — x by a(z)/1.750, y by hy(z)/3.000 —
// reproduces those to about 0.05 mm. Extruding a y-only profile along x does
// not: it leaves the corners square and over-cuts them by 1 mm. Step the
// hull chain by ARC ANGLE, not by z; the R2 arc starts vertical at z = 32,
// so uniform z steps put almost no sections where it changes fastest.
LEAD_N = 20;
function lead_a(t)  = 3.750 + 2.000 * cos(t);
function lead_z(t)  = CLIP_Z + 2.000 * sin(t);
function lead_hy(z) = z >= 32.900 ? POLY_HY
                    : POLY_HY + LEAD_R - sqrt(max(0, LEAD_R * LEAD_R
                                                    - pow(32.900 - z, 2)));

// ---------------------------------------------------------------------------
// Top cuts. Below x = 34 the shell is pinched to the flange width and capped
// by the chimney base; past x = 34 it is cut by two planes through the axis
// instead, which is why an x-section there reads as a 250-degree arc.
// ---------------------------------------------------------------------------
// The y flats start exactly where the barrel reaches them and not below, so
// the profile stays full width up to FLAT_Z0.
KEEP_CYL = concat(
    [[-45.000, -15.000], [3.000, -15.000], [3.000, FLAT_Z0],
     [J4_YZ[0] + FLAT_Y, FLAT_Z0]],
    arcpts(J4_YZ[0] + FLAT_Y - TOP_R, CLIP_Z - TOP_R, TOP_R, 0, 90, 12),
    arcpts(J4_YZ[0] - FLAT_Y + TOP_R, CLIP_Z - TOP_R, TOP_R, 90, 180, 12),
    [[J4_YZ[0] - FLAT_Y, FLAT_Z0], [-45.000, FLAT_Z0]]
);

// The chimney base, as a solid of revolution about the column axis. Below the
// shell it is far larger than the part, so it only bites near the top.
CHIM = concat(
    [[0.000, -12.000],
     [CHIM_C + 12.000, -12.000]],
    arcpts(CHIM_C - CLIP_Z - CHIM_R * (sqrt(2) - 1), CLIP_Z - CHIM_R,
           CHIM_R, 45, 90, 8),
    [[0.000, CLIP_Z]]
);

KEEP_CONE = [
    [-65.000, -15.000], [23.000, -15.000],
    [23.000, J4_YZ[1] + 44 * tan(CONE_ANG)],
    [J4_YZ[0], J4_YZ[1]],
    [-65.000, J4_YZ[1] + 44 * tan(CONE_ANG)],
];

// The rim itself is not cut at all: its face section is a clean full annulus,
// r 22.000 to 29.4925 about the axis, so it carries no clip of its own.
KEEP_ALL = [[-65.000, -15.000], [23.000, -15.000], [23.000, 60.000],
            [-65.000, 60.000]];

// ---------------------------------------------------------------------------
// Placement. A profile written as [radius, x] is revolved about Z and then
// turned onto the X axis; a (y, z) profile is extruded along X, which the
// same rotation reaches by writing the 2D point as [-z, y].
// ---------------------------------------------------------------------------

module j4_revolve(profile) {
    translate([0, J4_YZ[0], J4_YZ[1]]) yrot(90) rotate_extrude() polygon(profile);
}

module z_revolve(profile) {
    translate([COL_XY[0], COL_XY[1], 0]) rotate_extrude() polygon(profile);
}

module extrude_x(x0, len, profile) {
    translate([x0, 0, 0]) yrot(90)
        linear_extrude(len) polygon([for (p = profile) [-p[1], p[0]]]);
}

// ---------------------------------------------------------------------------
// Features that are not revolves.
// ---------------------------------------------------------------------------

// The chimney base carries material outboard of the shell — at z = 31 its y
// face sits 0.5 mm proud of the r = 15.5 cylinder — so it has to be added,
// then trimmed by CHIM in the keep below. Its x walls only show over
// z 30.22..30.91; above that the cone is the tighter bound.
module chimney_base() {
    translate([COL_XY[0], COL_XY[1], (21 + 40) / 2])
        cube([2 * BOSS_X, 2 * FLAT_Y, 19], center = true);
}

// One section of the lead-in loft: the 12-gon scaled anisotropically to the
// x half-width and y flat half-width that hold at this height.
module wire_section(t) {
    translate([COL_XY[0], COL_XY[1], lead_z(t)])
        linear_extrude(0.01)
            scale([lead_a(t) / POLY_HX, lead_hy(lead_z(t)) / POLY_HY])
                polygon(WIRE_POLY);
}

module wire_lead() {
    for (i = [0 : LEAD_N - 1])                   // step the R2 arc by angle,
        hull() {                                 // not by z, or the near-
            wire_section(270 - 90 * i / LEAD_N); // vertical start is coarse
            wire_section(270 - 90 * (i + 1) / LEAD_N);
        }
}

// ---------------------------------------------------------------------------
// Where the Ø8 wire bore breaks through the Ø22 bevel relief, top and bottom,
// the rim of the hole is rounded R2. The radius is recovered from the x = 21
// section: the blend leaves the bore wall at dy = 4.000, dz = -+11.533 and
// meets the relief floor at dy = 5.077, dz = -+9.758, and the radius tangent
// to both solves to f = 2.001. The balls it rolls on have centres 6.000 from
// the column axis and 13.000 from the J4 axis.
// ---------------------------------------------------------------------------

// A tube of radius BLEND_R swept along a curve that circles the column axis
// at radius rc and the J4 axis at radius rx. Its centre curve is
//
//   p(t) = [COL_XY[0] + rc cos t, COL_XY[1] + rc sin t,
//           J4_YZ[1] + sz sqrt(rx^2 - (rc sin t)^2)]
//
// and it is built as one polyhedron per arc, four in all.
//
// This was 48 hulled sphere pairs until the cost was measured. Hulling a
// chain of balls is the obvious way to sweep one, and it is expensive twice
// over: the result is a UNION of 48 solids, which multiplies the whole body
// when preview normalises the tree (see diff_body_b), and CGAL charges 7:49
// to evaluate the cutter alone against 6.4 s for the sweep — 13424 triangles
// against 3312.
//
// The sweep needs no parallel transport, because the radial direction about
// the column axis is perpendicular to the tangent everywhere already: the
// radial component of p is the constant rc, so e_r . p'(t) = 0 identically.
// Ring point k of station i is therefore just
// p + BLEND_R (cos a * e_r + sin a * (T x e_r)), with no drift to correct
// and no seam where the arcs meet. T is taken as a central difference; the
// frame only needs its direction, and 0.01 deg leaves that right to 1e-8.
//
// The ring is CIRCUMSCRIBED, BLEND_R / cos(180/m), and that is not a detail.
// The zone's outer bounds are placed at the ball's TANGENCY with the wall
// behind them — BLEND_ZONE_D is by construction the distance from the column
// axis to the point where the ball touches the relief floor — so zone and
// tube meet in a cusp there, and only a tube that CONTAINS the true ball
// closes it. Inscribed at m = 32 the facet planes sat BLEND_R * (1 -
// cos(5.625 deg)) = 0.0096 mm shy, and the x = 21 section of the export
// showed what that costs: a 0.0134 mm vertical face standing at dy = 5.0769,
// which is BLEND_ZONE_D itself — the zone's own bound, left uncovered and cut
// as a face, on both fillets alike. The reference goes from the fillet arc onto
// the relief floor in one step at (5.076, 9.759) with nothing between.
// Circumscribed, zone - tube is contained in the exact cutter and closes at
// both cusps, and that face falls to 0.0025 mm; the error also changes sign,
// becoming a ridge of at most 0.0096 mm left un-filleted under the facet
// vertices, which removes nothing that should have stayed. What is left is the
// relief floor's own faceting: it is an inscribed 128-gon, so it sits up to
// 11 * (1 - cos(180/128)) = 0.0033 mm inside r = 11, and the tube is tangent to
// the true cylinder rather than to that polygon.
//
// The general rule, and the one this file got wrong twice: an inscribed cutter
// is the safe direction only when it is subtracted from the PART. Subtracted
// from a cover, as here, inscribing is what exposes the cover's boundary.
//
// One reading trap, met while measuring the above. A section taken at x = 21
// reports a degenerate zero-area loop near the fillet, and it is not a defect
// in the mesh: n = 12 over a span of 180 - 2 t0 puts station 6 at exactly
// t = 90 deg, which is exactly x = 21, so the cut plane grazes a whole ring of
// the polyhedron edge-on. It appears at 21.0 and at no other station, before
// the change and after it. Section a swept solid off its stations.
//
// Sides and caps are both triangulated. A quad ring of a curved sweep is not
// planar and a 32-gon cap is planar only to rounding; left as polygons,
// OpenSCAD prints "PolySet has nonplanar faces. Attempting alternate
// construction" once per arc and repairs them on its own terms.
//
// WINDING. Check it by volume, always. A polyhedron wound inside out exports
// with no diagnostic whatever, and as a difference() cutter an inverted solid
// silently ADDS material instead of removing it. Wound correctly this sweep
// reads +446.725 mm3, one arc of the four +111.681; wound inside out it reads
// the same magnitudes negative. (Those are the circumscribed figures. The
// inscribed ring read 442.435 and 110.609, and 446.725 / 442.435 = 1.0097 is
// 1 / cos^2(5.625 deg) to five places, which is the check that the radius
// change did what it was meant to and nothing else.)
//
// The sweep has flat ends where the hull chain had hemispheres. That is the
// entire difference between the two cutters, 132 mm3 of it against the
// 8 x 2/3 pi 2^3 = 134 the caps would hold, and it falls outside the zone at
// both ends: t0 = acos(4/6) = 48.19 deg puts the end stations at x = 21 +/- 4
// with unit tangent (-0.724, 0.648, -0.237), so the cap normal's x component
// is 0.724 and the absent half-ball reaches no closer than
// 25 - 2 sqrt(1 - 0.724^2) = 23.62, against a zone bounded at GROOVE_X[1] =
// 23. Symmetrically, 18.38 against 19. Measured rather than argued: when the
// sweep replaced the hull chain the part exported 16688.936 mm3 against the
// chain's 16688.927, the same bounding box, and `dist` between the two meshes
// was 0.014 mm max, 0.000 rms. (Two later corrections have moved the volume
// since — see the header — but they are the fillet's radius convention and
// the Ø8 bore's top, not the caps.)
function blend_pt(rc, rx, sz, t) =
    [COL_XY[0] + rc * cos(t),
     COL_XY[1] + rc * sin(t),
     J4_YZ[1] + sz * sqrt(rx * rx - pow(rc * sin(t), 2))];

function blend_frame(rc, rx, sz, t, d = 0.01) =
    let (n = [cos(t), sin(t), 0],
         tg = unit(blend_pt(rc, rx, sz, t + d) - blend_pt(rc, rx, sz, t - d)))
    [n, unit(cross(tg, n))];

// Triangle fan over a ring of point indices, wound in the order given.
function blend_fan(idx) =
    [for (j = [1 : len(idx) - 2]) [idx[0], idx[j], idx[j + 1]]];

module blend_arc(base, rc, rx, sz, t0, n, m) {
    step = (180 - 2 * t0) / n;
    rr   = BLEND_R / cos(180 / m);            // circumscribed; see above
    pts = [for (i = [0 : n], k = [0 : m - 1])
             let (t = base + t0 + step * i,
                  f = blend_frame(rc, rx, sz, t),
                  a = 360 * k / m)
             blend_pt(rc, rx, sz, t)
                 + rr * (cos(a) * f[0] + sin(a) * f[1])];
    polyhedron(points = pts,
        faces = concat(
            [for (i = [0 : n - 1], k = [0 : m - 1], half = [0, 1])
                let (k1 = (k + 1) % m,
                     a = i * m + k,        b = (i + 1) * m + k,
                     c = (i + 1) * m + k1, d = i * m + k1)
                half == 0 ? [a, b, c] : [a, c, d]],
            blend_fan([for (k = [0 : m - 1]) k]),
            blend_fan([for (k = [m - 1 : -1 : 0]) n * m + k])),
        convexity = 4);
}

module blend_tube(rc, rx, t0, n, m = 32) {
    for (base = [0, 180], sz = [-1, 1])
        blend_arc(base, rc, rx, sz, t0, n, m);
}

// The material a rolling ball takes out of the rim is the corner zone less
// the tube around the ball's centre curve, and the zone has to stop at the
// ball's TANGENCY, not at BLEND_R past each surface. When a fillet is built
// as zone-minus-balls an over-large zone does not merely waste geometry —
// it CUTS, and it cuts a face on the zone's own boundary, because a
// difference against an incomplete cover exposes the bound itself. Three
// looser bounds were tried and each left a false face inside solid material:
//
//   r <= GROOVE_R + BLEND_R and dist-to-column <= WIRE_R + BLEND_R,
//     which runs 2 mm up the bore wall past the tangency        1.42 mm
//   a tube of radius BLEND_R around the sharp edge, which runs
//     2 mm straight up in z, into the shell                     1.38 mm
//   the two tangency radii, but as discs rather than annuli,
//     which reaches the axis and so carves the lead-in          0.96 mm
//
// Each of those put the worst `dist` point exactly on whichever bound was
// loosest, which is also how to recognise the mistake: a worst point sitting
// at a suspiciously round radius is a construction artefact, not geometry.
// The tangency radii vary only over 12.21..12.57 and 5.08..5.32 across the
// sweep, so their midpoints bound it to about 0.05 mm.
// The tangency bound up the relief floor is not a constant radius but
// sqrt(149 + dx^2) — a hyperboloid about the J4 axis, so a revolve states it
// exactly. Rounding it up to a constant leaves a 0.03 mm cavity at the
// relief's side wall, and `dist` charges 0.9 mm for that, because a shallow
// void in the middle of solid material has no reference surface anywhere near
// its floor. Out from the bore axis the bound varies only 5.077…5.188, so the
// minimum is taken; erring small merely leaves a 0.11 mm ridge un-filleted,
// which is the safe direction.
BLEND_CR = WIRE_R + BLEND_R;
BLEND_XR = GROOVE_R + BLEND_R;
BLEND_ZTOP = 32.000;      // where the Ø8 bore ends and the lead-in starts
// THE ZONE MUST NOT STATE A BOUND AS THE SURFACE IT BLENDS INTO. Two of them
// did: the annulus's inner wall was WIRE_R, which is the Ø8 bore's own
// cylinder, and the zone polygon's floor was GROOVE_R, which is the relief's
// own. Same radius, same axis, same $fn, so each pair tessellates to identical
// facets, and the difference then carries two coincident faces. CGAL orders
// them exactly and F6 is clean; OpenCSG cannot order two fragments at one
// depth, so PREVIEW drew both, and the fillet came out ringed by a speckled,
// ragged band that reads as random chunks of material around the two bore
// holes. It is worst looking along the bore, where the coincident cylinders
// run edge-on and every pixel is a near-tie.
//
// Both bounds are now set BLEND_CLEAR clear of the surface they duplicated,
// into the void behind it. This removes nothing extra: inside WIRE_R is the
// wire bore and inside GROOVE_R is the relief, and BORE and WIRE_ROUND have
// already cut both away, so the added reach reaches only where there is no
// material to take. Half a millimetre is far above the 0.0033 mm ripple of a
// 128-gon revolve and far below the 8.75 mm shaft land that walls the void, so
// the value needs no more precision than that. Exported geometry is unchanged,
// and exactly so: with the clearance in place the part still exports 43374
// triangles at 16689.530 mm3, the same two figures recorded below for the
// render that preceded it, and `dist` against the reference is unmoved at
// 0.414 / 0.332 with both worst points where they were.
//
// Recorded because the band LOOKS like faceting and is not: the sweep's
// section count (12 vs 48) and its ring radius (inscribed vs circumscribed)
// were both tried first, and neither moved it by a pixel.
BLEND_CLEAR = 0.500;

// Sections along the sweep. The tube joins its rings by chords, so its surface
// runs about 0.011 mm inside the true radius at n = 12, falling as 1/n^2. That
// error is real, but it is the fillet's RADIUS and not its edge: 12 is kept
// because 0.011 mm is a fourteenth of the 0.15 mm gate, and 48 costs 17 s per
// F6 and 9.7 s per F5 to buy back geometry no measurement here can see.
// Section step, not z step -- see the lead-in's note above for why this curve
// must be walked by angle.
BLEND_N = 12;

BLEND_ZONE_D = BLEND_CR * GROOVE_R / BLEND_XR;

function blend_rt(dx) = sqrt(WIRE_R * WIRE_R + BLEND_XR * BLEND_XR
                             - BLEND_CR * BLEND_CR + dx * dx);

BLEND_ZONE = concat(
    [for (i = [0 : 8])
        let (dx = GROOVE_X[0] - COL_XY[0]
                + (GROOVE_X[1] - GROOVE_X[0]) * i / 8)
        [blend_rt(dx), COL_XY[0] + dx]],
    // The floor is set clear of GROOVE_R, not on it — see BLEND_CLEAR.
    [[GROOVE_R - BLEND_CLEAR, GROOVE_X[1]],
     [GROOVE_R - BLEND_CLEAR, GROOVE_X[0]]]
);

module bore_groove_blend() {
    half = (GROOVE_X[1] - GROOVE_X[0]) / 2;
    difference() {
        intersection() {
            // Annuli, not discs. The zone must also exclude the two voids it
            // blends: above z = 32 the wire bore is the lead-in and no longer
            // Ø8, so material stands inside r = WIRE_R there, and a zone that
            // reaches the axis carves it away. The inner wall stays a wall; it
            // is only set clear of WIRE_R rather than on it — see BLEND_CLEAR.
            z_revolve([[WIRE_R - BLEND_CLEAR, -10], [BLEND_ZONE_D, -10],
                       [BLEND_ZONE_D, 80], [WIRE_R - BLEND_CLEAR, 80]]);
            j4_revolve(BLEND_ZONE);
            // The blend is tangent to the Ø8 wall, so it cannot outlive it.
            // Its own tangency would carry it to z = 32.67, but the bore stops
            // being Ø8 at 32.000 and the reference shows the fillet ending
            // there in a flat. The lower blend needs no such cut — the bore
            // runs Ø8 all the way down.
            translate([-60, -90, -30]) cube([160, 130, BLEND_ZTOP + 30]);
        }
        // The centre curve is swept wider than the relief so that its tube
        // still covers the zone where the relief's side walls cut in.
        blend_tube(BLEND_CR, BLEND_XR, acos(2 * half / BLEND_CR), BLEND_N);
    }
}

module rim_slots() {
    difference() {
        translate([0, J4_YZ[0], J4_YZ[1]])
            for (i = [0 : SLOTS - 1])
                xrot(SLOT_PHASE + i * 360 / SLOTS)
                    translate([(RIM_X[0] + RIM_X[1]) / 2,
                               (SLOT_R[0] + SLOT_R[1]) / 2, 0])
                        cube([RIM_X[1] - RIM_X[0] + 2, SLOT_R[1] - SLOT_R[0],
                              SLOT_W], center = true);
        // The ties are put back at $fn 512, not the file's 128. A revolve is
        // inscribed, so at 128 the slit edge ripples 25 x (1 - cos(180/128)) =
        // 0.007 mm inside its radius and the slit measures that much long —
        // small against the 0.15 gate, but this feature exists to be measured.
        //
        // Preview takes the 128, because preview cannot measure anything. The
        // render() wrapped round this module makes CGAL evaluate these two
        // revolves on every F5, and at 512 that alone costs 18 s of the
        // compile — for a 0.007 mm ripple that is a fifth of a pixel on screen.
        // $preview is false for F6 and for -o, so every exported mesh, and
        // therefore every measurement the harness takes, is still the 512.
        for (r = TIE_R)
            j4_revolve([[r[0], TIE_X], [r[1], TIE_X],
                        [r[1], RIM_X[1] + 2], [r[0], RIM_X[1] + 2]],
                       $fn = $preview ? 128 : 512);
    }
}

// ---------------------------------------------------------------------------
// The part.
// ---------------------------------------------------------------------------

module diff_body_b() {
    difference() {
        union() {
            intersection() {                         // barrel and chimney base
                union() {
                    j4_revolve(BARREL);
                    chimney_base();
                }
                extrude_x(7.0, CYL_X - 7.0, KEEP_CYL);
                z_revolve(CHIM);
            }
            intersection() {                         // collar, cone and rim
                j4_revolve(COLLAR);
                union() {
                    extrude_x(28.0, RIM_X[0] - 28.0, KEEP_CONE);
                    extrude_x(RIM_X[0], 48.0 - RIM_X[0], KEEP_ALL);
                }
            }
            z_revolve(COLUMN);
        }
        j4_revolve(BORE);
        z_revolve(WIRE_ROUND);
        translate([COL_XY[0], COL_XY[1], WIRE_POLY_Z[0]])
            linear_extrude(WIRE_POLY_Z[1] - WIRE_POLY_Z[0]) polygon(WIRE_POLY);
        wire_lead();
        // These two render() calls are not cosmetic, and between them they are
        // the whole reason this part is usable to look at. Preview normalises
        // the tree to disjunctive normal form, and both calls are differences
        // nested inside the body's: x - (A - B) rewrites to (x - A) | (x & B),
        // so each multiplies the whole body by one product per term of A plus
        // one per term of B. The fillet's zone is an intersection of 3 and its
        // cutter is 4 swept arcs, so 7; the slots subtract a union — one
        // product, with 115 cuts appended to it — less 2 tie revolves, so 3.
        // Against the body's own 5-product union that is 5 x 7 x 3 = 105
        // products, and every primitive in the tree is redrawn once per
        // product per frame. Evaluating each cutter to a single mesh takes its
        // factor to 1 and the whole tree to 5.
        //
        // It was once far worse, which is why the first of these lines exists
        // at all. With blend_tube built as 48 hulled spheres the fillet's
        // factor was 51 rather than 7 — 255 copies of the body before the
        // slots applied theirs — and appending 115 slot cuts to all of them
        // overran the normaliser's element cap outright: preview drew NOTHING
        // ("Normalized tree is growing past ... Aborting normalization", then
        // "CSG normalization resulted in an empty tree").
        //
        // What the second line buys, measured on one camera at two image sizes
        // so that compile and frame separate — 64x64 is compile, and whatever
        // 2400x2400 costs over it is one frame:
        //
        //   rendered                 elements   compile   2400x2400 frame
        //   fillet only                   323    18.4 s           1 - 3 s
        //   fillet and slots               87    54.5 s   none measurable
        //   the same, ties at $fn 128      87    36.3 s   none measurable
        //
        // The first row is the trap. It compiles fastest and it is the one
        // that cannot be orbited: 1 - 3 s a frame is two frames a second at
        // best, and a model can be quick to build and still unusable to turn.
        // Wrapping the slots pays 18 s once per F5 and buys back every frame
        // after it, which is the right way round for a part that is orbited
        // far more often than it is edited. The third row is the same result
        // for less — see rim_slots on why preview does not need the 512.
        //
        // Neither render() makes preview CORRECT, only cheap. Collapsing a
        // cutter to one mesh does not change where its faces lie, so a bound
        // stated on a surface the part already has stays coincident and stays
        // unorderable — that defect is fixed at the bound, in BLEND_CLEAR, and
        // could not have been fixed here.
        //
        // F6 and STL export never normalise, so neither line changes what
        // comes out: exported with and without the slots' render() the part
        // gives 43374 triangles and 16689.530 mm3 both times, the same
        // bounding box, and `dist` between the two meshes is 0.000 mm in both
        // directions. The two files are not byte-identical — ASCII facet order
        // is not stable run to run, and they differ in sha256 at the same byte
        // count — so check this by measurement and never by hash.
        // Of the nine parts here only this one fans out; 710-004
        // cuts 100 slots by the same construction and previews clean, because
        // it has no nested difference ahead of them to multiply against.
        render() bore_groove_blend();
        render() rim_slots();
    }
}

diff_body_b();
