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
//   scadmesh segment 730-002_DiffBodyB.stl --out out/730-002-ref.stl --keep 0
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
// WHERE THIS STANDS. Volume 16672.2 mm3 (-0.13%), bounding box 39.000 x
// 58.985 x 80.492, hausdorff 0.414 mm, rms 0.049 / 0.050, p95 0.136 both
// ways, 1.2% of points outside tolerance. That FAILS the 0.15 mm gate on
// max, so 730-002 is deliberately absent from render-all.rs's DIST_GATES;
// add it there when, and only when, it passes. (Quote the volume to one
// decimal: OpenSCAD's tessellation is not bit-stable run to run, and two
// renders of this file differed by 8 triangles and 0.004 mm3.) Four
// residuals are known, the first two undiagnosed:
//   1. The top corner of the -X end face, at (8.001, -22.554, 34.000) where
//      the z = 34 clip meets it — 0.414 mm, the worst candidate point.
//   2. Somewhere in the encoder track: the worst REFERENCE point is 0.399 mm
//      and lands at x = 46.875, r = 25.000 about the J4 axis, on two
//      independent renders that disagree about which of the 115 slots it
//      picks. The track itself measures right — 115 loops, pitch 3.130,
//      first angle 2.270, r 24.500..28.803, width 0.801, all matching the
//      reference — so it is not slot placement. Suspect the slot walls'
//      corner treatment rather than their position.
//   3. The junction where a chimney y flat meets the chimney cone is
//      filleted, radius about 1.5; modelled here as a sharp intersection,
//      which costs about 0.10 mm locally.
//   4. The wire bore's lead-in loft, about 0.10 mm.
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
J4_YZ  = [-21.0, 21.0];   // tunnel / pivot axis (y, z); runs along X
COL_XY = [21.0, -21.0];   // column axis (x, y); runs along Z

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

// J5 encoder track, cut clean through the rim. 115 radial slots on an exact
// 360/115 pitch; each is a true rectangle (its sides hold a constant
// perpendicular offset from the radius over the whole 4.3 mm length, so it is
// a cuboid cut, not a wedge). Same construction as 710-004's disk.
SLOTS      = 115;
SLOT_R     = [24.500, 28.800];
SLOT_W     = 0.800;
SLOT_PHASE = 2.270;       // angle of the first slot, from +y toward +z

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
WIRE_ROUND = [[0.000, -1.000], [4.000, -1.000],
              [4.000, 32.050], [0.000, 32.050]];

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
// at radius rc and the J4 axis at radius rx. Note that a faceted sphere is
// inscribed, not circumscribed: at $fn = 32 its facet planes sit at
// r * cos(5.625 deg), 0.01 mm shy of r. Here that errs toward removing less,
// which is the safe direction, but a sphere subtracted from a knife-edge
// cover needs r / cos(180/$fn) or the shortfall exposes a face.
module blend_tube(rc, rx, t0, n) {
    for (base = [0, 180], sz = [-1, 1])
        for (i = [0 : n - 1])
            hull() for (j = [i, i + 1]) {
                t = base + t0 + (180 - 2 * t0) * j / n;
                translate([COL_XY[0] + rc * cos(t), COL_XY[1] + rc * sin(t),
                           J4_YZ[1] + sz * sqrt(rx * rx - pow(rc * sin(t), 2))])
                    sphere(r = BLEND_R, $fn = 32);
            }
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
BLEND_ZONE_D = BLEND_CR * GROOVE_R / BLEND_XR;

function blend_rt(dx) = sqrt(WIRE_R * WIRE_R + BLEND_XR * BLEND_XR
                             - BLEND_CR * BLEND_CR + dx * dx);

BLEND_ZONE = concat(
    [for (i = [0 : 8])
        let (dx = GROOVE_X[0] - COL_XY[0]
                + (GROOVE_X[1] - GROOVE_X[0]) * i / 8)
        [blend_rt(dx), COL_XY[0] + dx]],
    [[GROOVE_R, GROOVE_X[1]], [GROOVE_R, GROOVE_X[0]]]
);

module bore_groove_blend() {
    half = (GROOVE_X[1] - GROOVE_X[0]) / 2;
    difference() {
        intersection() {
            // Annuli, not discs. The zone must also exclude the two voids it
            // blends: above z = 32 the wire bore is the lead-in and no longer
            // Ø8, so material stands inside r = WIRE_R there, and a zone that
            // reaches the axis carves it away.
            z_revolve([[WIRE_R, -10], [BLEND_ZONE_D, -10],
                       [BLEND_ZONE_D, 80], [WIRE_R, 80]]);
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
        blend_tube(BLEND_CR, BLEND_XR, acos(2 * half / BLEND_CR), 12);
    }
}

module rim_slots() {
    translate([0, J4_YZ[0], J4_YZ[1]])
        for (i = [0 : SLOTS - 1])
            xrot(SLOT_PHASE + i * 360 / SLOTS)
                translate([(RIM_X[0] + RIM_X[1]) / 2,
                           (SLOT_R[0] + SLOT_R[1]) / 2, 0])
                    cube([RIM_X[1] - RIM_X[0] + 2, SLOT_R[1] - SLOT_R[0],
                          SLOT_W], center = true);
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
        bore_groove_blend();
        rim_slots();
    }
}

diff_body_b();
