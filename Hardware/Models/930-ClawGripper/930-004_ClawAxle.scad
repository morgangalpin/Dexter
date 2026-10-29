// #930-004 Claw Axle — parametric source.
// The 4-finger claw's journal: the Pinion Bearing EXT (#920-006, revised) with a nose beyond its collar
// that carries the outer finger. Its keyed nose sits in the Claw Gear's key recess, its Ø8 journal in the
// Claw Body's two MR128s, and its nose, of the Span Driver's head's outline, in the outer Claw Finger's
// socket, held by that finger's set screw in its cross-hole. An M3 x 25 through its bore into the gear's
// tapped hole holds it. The 2-finger claw takes the EXT itself. claw_params.scad gives the mechanism.
//
// Designed, "revised" only: there is no reference mesh.
//
// FRAME. The EXT's: the axis on +Y through the origin, the journal's shoulder at y 0; (x, z) the grip
// frame's about the pivot with the claw closed. The assembly stands it at claw_journal_y().
//
//     ID  feature        value                                                     y span
//     E1  EXT            #920-006 revised: N1, S1, J1, C1 and H1, as that file      -2.000 .. 9.000
//                        draws them
//     N2  nose           the Span Driver's head's outline (#912-002 D1), arc        8.500 .. 18.500
//                        over +Z
//     X1  cross-hole     Ø3.3 along X on the axis, for the outer finger's set screw  at 16.000
//     B1  bolt bore      Ø3.3 on the axis, through                                   -2.000 .. 18.500
//
// FITS (revised). E1 is the EXT's, which owns its fits: J1 at FIT_PRESS in the MR128s, N1 into the gear's
// K1 at FIT_SLIP. N2 goes into the Claw Finger's socket, which is grown by FIT_SLIP, so N2 is drawn as the
// head is. X1 takes the set screw's tip and B1 the M3 bolt: fit_bore(3, FIT_SLIP). X1 opens into B1, so the
// set screw stops on the bolt's shank and locks the bolt with the finger; the M3 x 6 then stands 0.5 out
// of the finger's hub.

include <claw_params.scad>
use <../920-ParallelGripper/920-006_PinionBearingExt.scad>

/* [Configuration] */
// Parameter set: designed in revised only
config = "revised"; // [revised]

/* [Hidden] */
$fn = 144;
LAP = 0.005;

assert(config == "revised", "#930-004 exists only in the revised configuration: it has no reference");

function y_n2() = claw_outer_finger_y() - [claw_journal_y(), claw_journal_y()];
function y_x1() = claw_finger_mid(true) + claw_screw()[1] - claw_journal_y();

module claw_axle(cfg = config) let(c = fit_clearances(cfg), n = y_n2()) difference() {
    union() {
        pinion_bearing_ext(cfg);
        multmatrix(AXIS_Y) translate([0, 0, n[0] - LAP]) linear_extrude(n[1] - n[0] + LAP) claw_nose_2d();
    }
    multmatrix(AXIS_Y) translate([0, 0, -3]) linear_extrude(n[1] + 4) circle(d = fit_bore(3, c[0]), $fn = 72);
    translate([-claw_hub_r(), y_x1(), 0]) rotate([0, 90, 0])
        cylinder(d = fit_bore(claw_screw()[0], c[0]), h = 2 * claw_hub_r(), $fn = 48);
}

claw_axle();
