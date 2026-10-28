// #920-006 Pinion Bearing EXT — parametric source.
// The parallel gripper's pinion axle: its keyed nose sits in the Pinion Gear's recess, its Ø8 journal
// carries the Static Finger's two MR128s, and its collar bears on the outer MR128's inner race. An
// M3 x 16 bolt through its bore holds it to the Pinion Gear's nut (specs/008.11 steps 43-45). The
// hash mark on its collar is aligned with the Static Finger's long hash in step 45.
//
//   config = "previous" — a faithful recreation of 920-006_PinionBearingExt.step, gated against
//                         ../Reference/meshes/920-ParallelGripper/920-006_PinionBearingExt.stl, in that
//                         frame.
//   config = "revised"  — the same part with print fits on the journal, the nose and the bore.
//
// SOURCE. 920-006_PinionBearingExt.step (Reference/, published as `PinionGearExt.step`, 2020-03-12);
// the dimensions below are its surfaces' (scadmesh surfaces, 24 faces, all planes, cylinders and one
// cone). The reference mesh is that STEP tessellated by scadmesh tessellate.
//
// FRAME. The STEP's own: the axis on +Y through the origin, the nose's end at y = -2, the journal's
// shoulder (the nose's root) at y = 0, the hash mark's end at y = 9. The part is drawn as sections in
// the STEP's (x, z) plane stacked along y, by AXIS_Y below (a reflection that sends a 2D section's y to
// z and the extrusion's z to y).
//
// A stack of constant sections (mesh-to-scad rung 1, profile per layer), with the nose's end chamfer
// as the hull of its section and that section inset by the chamfer (rung 6), which is exact because
// the section is convex. `layer = "L1"` .. `"L4"` draws one layer's 2D section for the outline gates.
// The feature IDs are those of 920-006_PinionBearingExt.view.json:
//
//     ID  feature        value                                                 y span
//     N1  keyed nose     the Ø8 arc over +Z between flats at x ±3 (which meet   -2.000 .. 0.000
//                        it at z ±√7), and two faces from (±3, -√7) to a point
//                        at (0, -4); its end chamfered 0.5 x 45 deg
//     J1  journal        Ø8.000                                                0.000 .. 7.500
//     C1  collar         Ø8.800                                                7.500 .. 8.500
//     H1  hash mark      1 wide (x ±0.5) on +Z, from R3 out to R4.9 about the  7.500 .. 9.000
//                        axis
//     B1  bolt bore      Ø3.000 on the axis                                    -2.000 .. 8.500
//     S1  spacer         Ø8.800 about N1's root (revised only)                 -0.500 .. 0.000
//
//     layer  y span          section
//     L1     -2.0 .. 0.0     N1 less B1
//     S1     -0.5 .. 0.0     S1 less B1 (revised only, over L1)
//     L2     0.0 .. 7.5      J1 less B1
//     L3     7.5 .. 8.5      C1 ∪ H1, less B1
//     L4     8.5 .. 9.0      H1
//
// FITS (revised). J1 is pressed into the two MR128s' bores (C-405, 8 x 12 x 3.5):
// fit_pin(8, FIT_PRESS) = Ø7.900. B1 takes the M3 x 16 bolt: fit_bore(3, FIT_SLIP) = Ø3.300. N1 goes
// into the Pinion Gear's printed recess: every face moved in by FIT_SLIP, which leaves 1.20 of wall
// between B1 and each flat. C1 bears on the MR128's inner race face, and H1 meets nothing; both are as
// drawn.
//
// SPACER (revised). The Pinion Gear's reference carries a Ø8.8 x 0.5 collar between its teeth and the
// inner MR128's inner race, round the recess N1 sits in; at slip it leaves 0.25 of wall outside that
// recess. The revised gear drops it, and S1 takes its place here: N1's root is solid out to Ø8.8 from
// y -0.5, which then sits on the gear's face, so N1 engages 1.5 (y -2 .. -0.5) and J1 is unmoved. S1
// stays inside the MR128's inner race and clears its outer race's Ø10.8 bore by 1.0 radially.

include <../print_fit.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or one layer's 2D section
layer = "part"; // [part, L1, S1, L2, L3, L4]

/* [Hidden] */
$fn = 144;
LAP = 0.005;               // layers overlap so Manifold joins them (no shared faces)

Y = [-2.000, 0.000, 7.500, 8.500, 9.000];   // the layers' faces, L1 .. L4

NOSE_R    = 4.000;         // N1's arc, the journal's radius
FLAT_X    = 3.000;         // N1's flats
TIP_Z     = -4.000;        // N1's lower faces meet here
CHAMFER   = 0.500;         // N1's end chamfer, 45 deg
JOURNAL_D = 8.000;         // J1, the MR128's bore
COLLAR_D  = 8.800;         // C1
MARK      = [0.500, 3.000, 4.900];          // H1: half-width, inner and outer radius
BOLT_D    = 3.000;         // B1, M3
SPACER    = [8.800, -0.500];                // S1 (revised only): diameter, its face's y

// Sections are drawn in the STEP's (x, z); this sends 2D y to z and extrusion z to y.
AXIS_Y = [[1, 0, 0, 0], [0, 0, 1, 0], [0, 1, 0, 0], [0, 0, 0, 1]];

// N1: the arc from one flat over +Z to the other, then the two lower faces to the tip.
FLAT_Z = sqrt(NOSE_R ^ 2 - FLAT_X ^ 2);
ARC_A  = atan2(FLAT_Z, FLAT_X);
nose_pts = concat(
    [for (i = [0 : 64]) let(a = ARC_A + (180 - 2 * ARC_A) * i / 64) NOSE_R * [cos(a), sin(a)]],
    [[-FLAT_X, -FLAT_Z], [0, TIP_Z], [FLAT_X, -FLAT_Z]]);

// N1, every face moved in by the slip clearance in revised, and by `inset` more.
module nose_2d(cfg, inset = 0) offset(delta = -fit_clearances(cfg)[0] - inset) polygon(nose_pts);

module bore_2d(cfg) circle(d = fit_bore(BOLT_D, fit_clearances(cfg)[0]), $fn = 72);

// H1: the strip x ±0.5 over +Z, between its two radii.
module mark_2d() intersection() {
    difference() { circle(r = MARK[2]); circle(r = MARK[1]); }
    translate([-MARK[0], 0]) square([2 * MARK[0], MARK[2] + 1]);
}

// A layer's section without B1, which the part cuts once through every layer.
module solid_2d(i, cfg)
    if (i == 0) nose_2d(cfg);
    else if (i == 1) circle(d = fit_pin(JOURNAL_D, fit_clearances(cfg)[1]));
    else if (i == 2) union() { circle(d = COLLAR_D); mark_2d(); }
    else mark_2d();

module layer_2d(i, cfg = config) difference() { solid_2d(i, cfg); bore_2d(cfg); }

// N1's end chamfer: the hull of the section inset by the chamfer at the end face and the whole section
// from the chamfer's depth on, which L1 is intersected with.
module nose_chamfer(cfg) multmatrix(AXIS_Y) hull() {
    translate([0, 0, Y[0] - LAP]) linear_extrude(LAP) nose_2d(cfg, CHAMFER);
    translate([0, 0, Y[0] + CHAMFER]) linear_extrude(Y[1] - Y[0]) nose_2d(cfg);
}

// Each lap runs from the narrower section into the wider, so that no layer stands LAP proud of the
// faces the MR128s' inner races sit on: J1 laps into N1 (and S1) and into C1, and H1 into C1.
LAP_LO = [0, LAP, 0, LAP];
LAP_HI = [0, LAP, 0, 0];

module layer_3d(i, cfg) multmatrix(AXIS_Y) translate([0, 0, Y[i] - LAP_LO[i]])
    linear_extrude(Y[i + 1] - Y[i] + LAP_LO[i] + LAP_HI[i]) solid_2d(i, cfg);

module spacer_2d(cfg) difference() { circle(d = SPACER[0]); bore_2d(cfg); }

// S1 over N1's root, which J1's lap joins.
module spacer_3d(cfg) multmatrix(AXIS_Y) translate([0, 0, SPACER[1]])
    linear_extrude(Y[1] - SPACER[1]) circle(d = SPACER[0]);

// B1 through the whole part.
module bore_3d(cfg) multmatrix(AXIS_Y) translate([0, 0, Y[0] - 1]) linear_extrude(Y[4] - Y[0] + 2) bore_2d(cfg);

module pinion_bearing_ext(cfg = config) difference() {
    union() {
        intersection() { layer_3d(0, cfg); nose_chamfer(cfg); }
        if (cfg != "previous") spacer_3d(cfg);
        for (i = [1 : 3]) layer_3d(i, cfg);
    }
    bore_3d(cfg);
}

if (layer == "part") pinion_bearing_ext();
else if (layer == "S1") spacer_2d(config);
else layer_2d(search([layer], ["L1", "L2", "L3", "L4"])[0]);
