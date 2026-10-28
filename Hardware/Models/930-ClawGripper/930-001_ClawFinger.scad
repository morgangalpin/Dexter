// #930-001 Claw Finger — parametric source.
// The claw gripper's moving finger: a curved blade on a hub, whose Ø8 shaft turns in two MR128s, held
// by an M2 x 16 bolt and washer through the Finger Cap (#930-002) into its end. The claw's fixed finger,
// which carries those MR128s, is not in the model set (specs/009 § Gripper design).
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/930-ClawGripper/930-001_ClawFinger.stl), in that mesh's
//                         frame.
//   config = "revised"  — the same part with the shaft at the MR128's press fit.
//
// SOURCE. The STL, a curved claw, published as the legacy `920-002_DynamicFinger.stl`. The STEP and f3d
// filed under that number hold the parallel gripper's rack finger, now #920-002 in 920-ParallelGripper.
//
// FRAME. The reference's own: the hub's axis along +Y through (x 14.139, z 17.5), the shaft's end at
// y = 14.007. The part is drawn as sections in the reference's (x, z) plane stacked along y, by AXIS_Y
// below (a reflection that sends a 2D section's y to z and the extrusion's z to y).
//
// A stack of constant sections (mesh-to-scad rung 1, profile per layer). `layer = "L1"` .. `"L6"`
// draws one layer's 2D section for the outline gates. Measured with scadmesh slice/arcs/planes; the
// feature IDs are those of 930-001_ClawFinger.view.json, and (x, z) are about the hub's axis
// unless given absolute:
//
//     ID  feature   value
//     K1  socket    the Span Driver's drive head's: between flats at x ±3.5, open through D1's top
//                   (its arc is D1's own), a floor at z -4.569 and 45 deg chamfers from (±3.5, -2.513)
//                   to (±1.444, -4.569); from the hub's open end to y 1.507
//     A1  blade     4 wide: a straight arm at -38.49 deg, tangent at 51.51 deg to arcs R20.277 and
//                   R24.277 about (-14.045, 10.990) absolute, which run on to 121.6 deg and end in an
//                   R2 round
//     D1  hub disc  Ø12
//     S1  stub      2.5 wide on the arm's centre line, from the hub to an R1.25 end at (5.380, 24.003)
//                   absolute
//     F1  flange    Ø11
//     S2  shaft     Ø8
//     B1  bolt hole Ø2 at (14.064, 17.557) absolute (0.094 off the hub's axis), from the flange's face
//
//     layer  y span            section
//     L1     -3.243 .. -2.500  D1 less K1
//     L2     -2.500 .. 1.507   D1 ∪ A1, less K1
//     L3     1.507 .. 2.500    D1 ∪ A1
//     L4     2.500 .. 3.507    D1 ∪ S1
//     L5     3.507 .. 4.007    F1
//     L6     4.007 .. 14.007   S2 less B1
//
// FITS (revised). S2 turns in the MR128s (C-405, 8 x 12 x 3.5), pressed into their bores:
// fit_pin(8, FIT_PRESS) = Ø7.9. K1 takes the Span Driver's head, a printed part: its flats, drawn line to
// line with the head's, open by FIT_SLIP each side (the whole socket grown by 0.15). B1 is tapped by the
// M2 bolt.

include <../print_fit.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or one layer's 2D section
layer = "part"; // [part, L1, L2, L3, L4, L5, L6]

/* [Hidden] */
$fn = 144;
LAP = 0.005;               // layers overlap so Manifold joins them (no shared faces)

Y   = [-3.243, -2.500, 1.507, 2.500, 3.507, 4.007, 14.007];   // the layers' faces, L1 .. L6
HUB = [14.139, 17.500];    // the hub's axis in (x, z)

KEY     = [3.500, -4.569, 6.013];           // K1: flat half-width, floor z, chamfer line |x| - z <= 6.013
BLADE   = [[-14.045, 10.990], 20.277, 24.277, -38.49, 121.6, 2.000];   // A1: arcs' centre, inner and
                                            // outer radii, arm angle, tip angle, tip radius
DISC_D  = 12.000;          // D1
STUB    = [1.250, [5.380, 24.003]];         // S1: half-width, end centre
FLANGE_D = 11.000;         // F1
SHAFT_D = 8.000;           // S2
BOLT    = [2.000, [14.064, 17.557]];        // B1: diameter, centre

// Sections are drawn in the reference's (x, z); this sends 2D y to z and extrusion z to y.
AXIS_Y = [[1, 0, 0, 0], [0, 0, 1, 0], [0, 1, 0, 0], [0, 0, 0, 1]];

function dir(a) = [cos(a), sin(a)];

// K1, run out past D1's top, grown by the slip clearance in revised.
module key_2d(cfg = config) let(c = fit_clearances(cfg)) translate(HUB) offset(delta = c[0]) intersection() {
    translate([-KEY[0], KEY[1]]) square([2 * KEY[0], DISC_D]);
    polygon([[0, -KEY[2]], [20, 20 - KEY[2]], [-20, 20 - KEY[2]]]);
}

// A1: the arm, from inside the hub to the arcs' tangent, the arc, and the tip.
module blade_2d() let(c = BLADE[0], ri = BLADE[1], ro = BLADE[2], arm = BLADE[3], t0 = arm + 90,
                      t1 = BLADE[4], rm = (ri + ro) / 2, u = dir(arm),
                      len = (HUB - (c + rm * dir(t0))) * u) union() {   // the arm runs on to the hub's axis
    polygon([c + ri * dir(t0), c + ro * dir(t0), c + ro * dir(t0) + len * u, c + ri * dir(t0) + len * u]);
    polygon(concat([for (i = [0 : 64]) c + ro * dir(t0 + (t1 - t0) * i / 64)],
                   [for (i = [64 : -1 : 0]) c + ri * dir(t0 + (t1 - t0) * i / 64)]));
    translate(c + rm * dir(t1)) circle(r = BLADE[5], $fn = 72);
}

module stub_2d() let(u = dir(BLADE[3]), n = [-u.y, u.x], e = STUB[1], w = STUB[0]) union() {
    polygon([e + w * n, e - w * n, e - w * n + 10 * u, e + w * n + 10 * u]);
    translate(e) circle(r = w, $fn = 72);
}

module layer_2d(i, cfg = config)
    if (i == 0) difference() { translate(HUB) circle(d = DISC_D); key_2d(cfg); }
    else if (i == 1) difference() { union() { translate(HUB) circle(d = DISC_D); blade_2d(); } key_2d(cfg); }
    else if (i == 2) union() { translate(HUB) circle(d = DISC_D); blade_2d(); }
    else if (i == 3) union() { translate(HUB) circle(d = DISC_D); intersection() { stub_2d(); translate(HUB) circle(d = DISC_D + 20); } }
    else if (i == 4) translate(HUB) circle(d = FLANGE_D);
    else let(c = fit_clearances(cfg)) difference() {
        translate(HUB) circle(d = fit_pin(SHAFT_D, c[1]));
        translate(BOLT[1]) circle(d = BOLT[0], $fn = 48);
    }

module dynamic_finger(cfg = config)
    multmatrix(AXIS_Y) for (i = [0 : 5])
        translate([0, 0, Y[i] - (i > 0 ? LAP : 0)])
            linear_extrude(Y[i + 1] - Y[i] + (i > 0 ? LAP : 0)) layer_2d(i, cfg);

if (layer == "part") dynamic_finger();
else layer_2d(search([layer], ["L1", "L2", "L3", "L4", "L5", "L6"])[0]);
