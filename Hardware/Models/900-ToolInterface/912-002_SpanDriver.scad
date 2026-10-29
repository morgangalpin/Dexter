// #912-002 Span Driver — parametric source.
// The span (grip) axis's output: a sleeve pushed onto the span XL-320's output spline and held by an
// M2.6 x 10 bolt (specs/008.11 steps 36-37). Its flat-sided head drives the gripper: the parallel
// gripper's Pinion Gear (#920-005), or the claw's drive Claw Finger (#930-001), whose socket and the Claw
// Gear's nose take D1's outline, head_2d().
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/900-ToolInterface/912-002_SpanDriver.stl), in that mesh's
//                         frame.
//   config = "revised"  — the same part with print fits on the spline bore, the key slot and the
//                         bolt's hole and counterbore.
//
// SOURCE. The STL. 912-002_SpanDriver.step (Reference/, 2020-03-12) is a different revision and is not a
// source: its head is 9.5 deep across the flat where the STL's is 9.82, its key slot stands 30 deg off
// the flat's normal where the STL's stands 55 deg, it has a Ø6.5 counterbore the STL lacks, and it has
// no R0.5 round on the spline end. The spline's 20 points (r 2.683 / 2.356) are the same in both.
//
// FRAME. The reference's own: the axis on +Y through the origin, the spline end at y = 2.175 and the
// head's end at y = 13. The part is drawn as sections in the reference's (x, z) plane stacked along y,
// by AXIS_Y below (a reflection that sends a 2D section's y to z and the extrusion's z to y).
//
// A stack of constant sections (mesh-to-scad rung 1, profile per layer), with the spline end's round as
// one revolved cutter (rung 4). `layer = "L1"` .. `"L6"` draws one layer's 2D section for the outline
// gates. Measured with scadmesh slice/arcs/planes/solid; the feature IDs are those of
// 912-002_SpanDriver.view.json:
//
//     ID  feature        value                                               y span
//     S1  spline sleeve  Ø7.750, end edge round R0.5                         2.175 .. 5.175
//     S2  collar         Ø8.000                                              5.175 .. 7.500
//     F1  flange         Ø11.000                                             7.500 .. 8.000
//     D1  drive head     Ø11 arc (z > 0) between flats at x ±3.5, a flat     8.000 .. 13.000
//                        at z -4.319, and 45 deg chamfers from (±3.5,
//                        -2.513) to (±1.695, -4.319)
//     B1  spline bore    20-point star, points r 2.683 at -1 + 18k deg in    2.175 .. 5.325
//                        (x, z), roots r 2.356 between them
//     K1  bolt hole      Ø2.600 on the axis                                  5.325 .. 10.000
//     K2  key slot       1.0 wide from the axis to an R0.5 end centred 2.0   5.325 .. 10.000
//                        out at 215 deg in (x, z)
//     C1  counterbore    Ø5.500                                              10.000 .. 13.000
//
//     layer  y span           section
//     L1     2.175 .. 5.175   S1 less B1
//     L2     5.175 .. 5.325   S2 less B1
//     L3     5.325 .. 7.500   S2 less K1, K2
//     L4     7.500 .. 8.000   F1 less K1, K2
//     L5     8.000 .. 10.000  D1 less K1, K2
//     L6     10.000 .. 13.000 D1 less C1
//
// FITS (revised). B1 on the XL-320's output spline and K2 on its key, bought parts: ../c102_servo.scad's
// spline star grown by FIT_PRESS, and its key's width grown by it about the same end centre. K1 takes
// the M2.6 bolt and C1 its head: fit_bore(2.6, FIT_SLIP) = Ø2.900 and fit_bore(5.5, FIT_SLIP) =
// Ø5.800. D1 (in the gripper's drive slot) and S2/F1 (against the Span Mount) are left as drawn until
// the assembly stage shows their mates.

include <../print_fit.scad>
use <../c102_servo.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or one layer's 2D section
layer = "part"; // [part, L1, L2, L3, L4, L5, L6]

/* [Hidden] */
$fn = 144;
LAP = 0.005;               // layers overlap so Manifold joins them (no shared faces)

Y = [2.175, 5.175, 5.325, 7.500, 8.000, 10.000, 13.000];   // the layers' faces, L1 .. L6

// D1's y span, for the parts it drives.
function head_y_span() = [Y[4], Y[6]];

SLEEVE_D = 7.750;          // S1
END_R    = 0.500;          // S1's end edge round
COLLAR_D = 8.000;          // S2
FLANGE_D = 11.000;         // F1
HEAD     = [11.000, 3.500, -4.319, 6.013];   // D1: arc diameter, flat half-width, bottom flat z,
                                             // chamfer line |x| - z <= 6.013 (3.5 + 2.513)
STAR     = [20, 2.683, 2.356, -1];           // B1: points, tip r, root r, first tip's angle
BOLT_D   = 2.600;          // K1, M2.6
KEY      = [1.000, 2.000, 215];              // K2: width, end centre's distance, angle
CBORE_D  = 5.500;          // C1

// Sections are drawn in the reference's (x, z); this sends 2D y to z and extrusion z to y.
AXIS_Y = [[1, 0, 0, 0], [0, 0, 1, 0], [0, 1, 0, 0], [0, 0, 0, 1]];

// B1's star: the reference's, or revised the servo's spline (../c102_servo.scad), at B1's phase.
function star(cfg) = cfg == "revised" ? let(s = c102_spline()) [s[0], s[1], s[2], STAR[3]] : STAR;
function star_pts(cfg) = let(s = star(cfg)) [for (i = [0 : 2 * s[0] - 1])
    let(a = s[3] + i * 180 / s[0], r = i % 2 == 0 ? s[1] : s[2]) r * [cos(a), sin(a)]];

// B1, every flank moved out by the press clearance in revised.
module spline_2d(cfg) let(c = fit_clearances(cfg)) offset(delta = c[1]) polygon(star_pts(cfg));

// K2: width and end centre's distance, the reference's, or revised the servo's key at the press fit.
function key(cfg) = cfg == "revised" ? let(k = c102_key()) [fit_bore(k[0], fit_clearances(cfg)[1]), k[2]]
                                     : [KEY[0], KEY[1]];

module key_2d(cfg) let(c = fit_clearances(cfg), k = key(cfg)) union() {
    circle(d = fit_bore(BOLT_D, c[0]), $fn = 72);
    rotate(KEY[2]) {
        translate([0, -k[0] / 2]) square([k[1], k[0]]);
        translate([k[1], 0]) circle(d = k[0], $fn = 48);
    }
}

// D1: the Ø11 circle, cut to the flats, the bottom flat and the chamfers (z >= |x| - 6.013).
module head_2d() intersection() {
    circle(d = HEAD[0]);
    translate([-HEAD[1], HEAD[2]]) square([2 * HEAD[1], HEAD[0]]);
    polygon([[0, -HEAD[3]], [20, 20 - HEAD[3]], [-20, 20 - HEAD[3]]]);
}

module layer_2d(i, cfg = config) let(c = fit_clearances(cfg))
    if (i == 0) difference() { circle(d = SLEEVE_D); spline_2d(cfg); }
    else if (i == 1) difference() { circle(d = COLLAR_D); spline_2d(cfg); }
    else if (i == 2) difference() { circle(d = COLLAR_D); key_2d(cfg); }
    else if (i == 3) difference() { circle(d = FLANGE_D); key_2d(cfg); }
    else if (i == 4) difference() { head_2d(); key_2d(cfg); }
    else difference() { head_2d(); circle(d = fit_bore(CBORE_D, c[0]), $fn = 96); }

// S1's end round: the ring outside a quarter circle of END_R at the spline end, revolved about the axis.
module end_round()
    rotate_extrude() polygon(concat(
        [[SLEEVE_D / 2 + 1, Y[0] - 1], [SLEEVE_D / 2 + 1, Y[0] + END_R]],
        [for (i = [0 : 16]) let(a = 90 * i / 16)
            [SLEEVE_D / 2 - END_R + END_R * cos(a), Y[0] + END_R - END_R * sin(a)]],
        [[SLEEVE_D / 2 - END_R, Y[0] - 1]]));

module span_driver(cfg = config)
    difference() {
        multmatrix(AXIS_Y) for (i = [0 : 5])
            translate([0, 0, Y[i] - (i > 0 ? LAP : 0)])
                linear_extrude(Y[i + 1] - Y[i] + (i > 0 ? LAP : 0)) layer_2d(i, cfg);
        rotate([-90, 0, 0]) end_round();   // the revolve's axis (z) onto +y
    }

if (layer == "part") span_driver();
else layer_2d(search([layer], ["L1", "L2", "L3", "L4", "L5", "L6"])[0]);
