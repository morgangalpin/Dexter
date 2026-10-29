// #930-002 Claw Gear — parametric source.
// The claw's gear, one model for both pivots of both claws: a 20-tooth spur gear whose nose turns the
// finger on its pivot. The two gears mesh 1:1, so the fingers turn equal and opposite. Each turns on a
// Ø8 journal in two MR128s in the Claw Body: the Pinion Bearing EXT (#920-006) in the 2-finger claw, held
// by an M3 x 16 (C-620) into G1's tapped hole; the Claw Axle (#930-004) in the 4-finger claw, held by an
// M3 x 25. claw_params.scad owns its dimensions and gives the claw's mechanism.
//
// Designed, "revised" only: there is no reference mesh.
//
// FRAME. Its own: the pivot's axis along +Y through the origin, y the grip frame's, and (x, z) the grip
// frame's about the pivot with the claw closed. Both gears are drawn the same way up: a tooth stands
// claw_gear_spin() off +Z, and the nose's arc is over +Z.
//
//     ID  feature        value                                                     y span
//     N1  nose           the Span Driver's head's outline (#912-002 D1), arc        1.757 .. 6.757
//                        over +Z
//     X1  cross-hole     Ø3.3 along X on the axis, for the finger's set screw       at 4.257
//     B1  boss           Ø12                                                        6.757 .. 11.500
//     G1  teeth          20, module 1.4139 (the pivots' spacing over 20), 20 deg,    11.500 .. 17.500
//                        thinned for backlash; a tooth at claw_gear_spin() off +Z
//     K1  key recess     the Pinion Bearing EXT's keyed nose (#920-006 N1), point     16.000 .. 17.500
//                        toward -Z, 1.5 deep
//     T1  tapped hole    Ø2.6 for M3, on the axis                                   10.000 .. 17.500
//
// FITS (revised). N1 goes into the Claw Finger's socket, which is grown by FIT_SLIP, so N1 is drawn as
// the head is. X1 takes the C-606 set screw's tip: fit_bore(3, FIT_SLIP). K1 takes the EXT's or the
// Claw Axle's keyed nose, printed parts: the nose's outline grown by FIT_SLIP, as #920-005's K1. T1 is
// tapped by the M3 bolt: fit_pin(3, FIT_TAP). G1 meshes with the other gear, a printed part: each gear's
// teeth are thinned by FIT_SLIP / cos 20 along the pitch circle, so that, centred in the mesh, each pair
// of flanks stands FIT_SLIP apart.

include <BOSL2/std.scad>
include <BOSL2/gears.scad>
include <claw_params.scad>
use <../920-ParallelGripper/920-006_PinionBearingExt.scad>

/* [Configuration] */
// Parameter set: designed in revised only
config = "revised"; // [revised]
// What to draw: the part, or one layer's 2D section
layer = "part"; // [part, N1, B1, G1]

/* [Hidden] */
$fn = 144;
LAP = 0.005;

assert(config == "revised", "#930-002 exists only in the revised configuration: it has no reference");

KEY_DEPTH = 1.500;                       // K1, the EXT's nose engaged past its spacer
TAP_DEPTH = 7.500;                       // T1, from the +Y face: an M3 x 16 from the EXT ends 7 in

function y_n1() = claw_nose_y();
function y_b1() = [claw_nose_y()[1], claw_teeth_y()[0]];
function y_g1() = claw_teeth_y();

module teeth_2d(cfg) spur_gear2d(mod = claw_gear_mod(), teeth = claw_gear_teeth(), pressure_angle = claw_gear_pa(),
    profile_shift = 0, backlash = claw_gear_backlash(cfg), gear_spin = claw_gear_spin());

module layer_2d(i, cfg = config)
    if (i == 0) claw_nose_2d();
    else if (i == 1) circle(d = claw_boss_d());
    else teeth_2d(cfg);

module along(y, lo = 0, hi = 0) multmatrix(AXIS_Y) translate([0, 0, y[0] - lo]) linear_extrude(y[1] - y[0] + lo + hi) children();

module claw_gear(cfg = config) let(c = fit_clearances(cfg), g = y_g1()) difference() {
    union() {
        along(y_n1(), 0, LAP) layer_2d(0, cfg);
        along(y_b1()) layer_2d(1, cfg);
        along(g, LAP) layer_2d(2, cfg);
    }
    translate([-claw_hub_r(), claw_screw_y(), 0]) rotate([0, 90, 0])
        cylinder(d = fit_bore(claw_screw()[0], c[0]), h = 2 * claw_hub_r(), $fn = 48);
    along([g[1] - KEY_DEPTH, g[1]], 0, 1) nose_2d("previous", -c[0]);
    along([g[1] - TAP_DEPTH, g[1]], 0, 1) circle(d = fit_pin(3, c[3]), $fn = 48);
}

if (layer == "part") claw_gear();
else layer_2d(search([layer], ["N1", "B1", "G1"])[0]);
