// #930-002 Claw Gear — parametric source.
// The drive pivot's toothed sector, a part of its own so that it prints flat, and the same part in both
// builds. Its hex bore slides over the Claw Axle's seat (#930-006, #930-011), and one M3 x 16 set screw
// pins it there, in from the web's far side through the seat's cross hole to the blind hole in the sector, so
// that the screw carries the torque in shear on both sides of the seat, as a finger's does. Its teeth meet
// the Claw Pinion's (#930-004, #930-012). claw_params.scad owns its dimensions and gives the claw's mechanism.
//
// Designed, "revised" only: there is no reference mesh.
//
// FRAME. Its own: the pivot's axis along +Y through the origin, y the grip frame's, and (x, z) the grip
// frame's about its pivot with the claw closed. It prints lying on either face.
//
//     ID  feature        value                                                     y span
//     G1  sector         34-tooth pitch, module 1.25, 20 deg, thinned for          7.069 .. 15.069
//                        backlash, its teeth from 251.471 to 325.588 deg polar,
//                        a tooth on 2.647 + 10.588k deg, cut to their wedge, on
//                        a web R9
//     X1  hex bore       10 across flats, a vertex on +Z, through G1               7.069 .. 15.069
//     M1  set-screw hole Ø2.6 tapped M3 on both sides of X1, on the mid-plane,     11.069
//                        along polar 120 / 300 deg, through two of X1's flats, in
//                        line with the seat's cross hole: open through the web on
//                        120 deg, where the screw goes in and comes out, on the
//                        bench, and stopped 8.5 from the pivot on 300 deg, in the
//                        sector
//
// FITS (revised). X1 takes the seat, a printed part: every face grown by FIT_SLIP. G1 meshes with the pinion,
// a printed part: each gear's teeth are thinned by FIT_SLIP / cos 20 along the pitch circle, so that, centred
// in the mesh, each pair of flanks stands FIT_SLIP apart. M1 is tapped by the set screw on both sides:
// fit_pin(3, FIT_TAP) = Ø2.6; the M3 x 16, centred on the pivot, stands 1 under the web at the far side and
// 0.5 short of M1's stop.

include <claw_gears.scad>

/* [Configuration] */
// Parameter set: designed in revised only
config = "revised"; // [revised]

/* [Hidden] */
$fn = 144;

assert(config == "revised", "#930-002 exists only in the revised configuration: it has no reference");

module slab(y, lo = 0, hi = 0) multmatrix(AXIS_Y) translate([0, 0, y[0] - lo]) linear_extrude(y[1] - y[0] + lo + hi) children();

// M1, along the set screw's line: stopped in the sector, and out through the web's far side.
module screw_hole(cfg) let(c = fit_clearances(cfg), s = claw_screw_stop())
    translate([0, claw_gear_y(), 0]) rotate([0, -claw_screw_dir(), 0]) rotate([0, 90, 0]) translate([0, 0, -s])
        cylinder(d = fit_pin(claw_screw()[0], c[3]), h = s + claw_hub_r() + 1, $fn = 48);

module claw_gear(cfg = config) let(c = fit_clearances(cfg), y = claw_teeth_y()) difference() {
    slab(y) claw_sector_2d(cfg);
    slab(y, 1, 1) claw_hex_2d(c[0]);
    screw_hole(cfg);
}

claw_gear();
