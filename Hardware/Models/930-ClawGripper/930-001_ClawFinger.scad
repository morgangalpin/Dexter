// #930-001 Claw Finger — parametric source.
// The claw's drive finger: a curved blade on a closed hub, whose hex bore slides over the Claw Gear's hex
// seat (#930-002) like a box-end wrench, pinned there by one M3 x 16 set screw, in from the hub's far side
// through the seat's cross hole to the hub's blind hole under the blade, so that the screw carries the
// torque in shear on both sides of the seat. The hub is toothed where it meets the follower finger's
// (#930-007, this file with SIDE "follow"), which it turns 1:1. claw_params.scad owns its dimensions and
// gives the claw's mechanism.
//
// Designed, "revised" only: there is no reference mesh.
//
// FRAME. Its own: the pivot's axis along +Y through the origin, the mid-plane y = 0, and (x, z) the grip
// frame's about its pivot with the claw closed, the tip toward the roll axis. The follower's is the
// drive's mirrored about x = 0 but for its teeth (claw_params.scad, THE MIRROR); the values below are the
// drive's, the follower's polar angles being 180 less theirs but for G1's.
//
//     ID  feature        value
//     H1  hub            R9, 10 thick (y ±5)
//     G1  hub teeth      16-tooth pitch (R10), module 1.25, 20 deg, thinned for backlash, through H1's
//                        thickness, from 151.875 to 241.875 deg polar, a tooth on 5.625 + 22.5k deg (the
//                        follower's from -50.625 to 39.375, a tooth on 5.625 + 22.5k); the hub round
//                        elsewhere
//     B1  blade          7 thick (y ±3.5), 7 wide: the legacy claw finger's curve (claw_params.scad), a
//                        53.33 shank off H1 tangent into an arc whose grip face is R20.277 over 66.4 deg,
//                        the shank's centreline 3.97 off the pivot toward the other finger and leaned
//                        8.82 deg outward so that the tip meets the roll axis, its root filleted R2 onto
//                        H1, the fillet ending at 140.625 deg, where the follower's teeth end, and
//                        its edges on both faces R1, where it is handled
//     T1  tip            the blade's end, a full round R3.5 centred 77.3 from the pivot, which touches the
//                        other finger's T1 on the roll axis when the claw is closed
//     X1  hex bore       10 across flats, a vertex on +Z, through H1
//     M1  set-screw hole Ø2.6 tapped M3 on both sides of X1, on the mid-plane, along polar 120 / 300 deg
//                        (the follower's 60 / 240), through two of X1's flats, in line with the seat's
//                        cross hole: blind on the blade's side, stopped 8.5 from the pivot along 120 deg
//                        under B1, and open only through H1's far side on 300 deg, where the screw goes
//                        in and comes out, on the bench
//
// FITS (revised). X1 takes the seat, a printed part: every face grown by FIT_SLIP. G1 meshes with the
// other finger's G1, a printed part: each gear's teeth are thinned by FIT_SLIP / cos 20 along the pitch
// circle. M1 is tapped by the set screw on both sides: fit_pin(3, FIT_TAP) = Ø2.6; the M3 x 16, centred on
// the pivot, stands 1 under H1 at the far side and 0.5 short of M1's stop. T1 meets the other finger's T1
// line to line when the claw is closed.

include <claw_gears.scad>

/* [Configuration] */
// Parameter set: designed in revised only
config = "revised"; // [revised]
// What to draw: the part, or its 2D outline
layer = "part"; // [part, outline]

/* [Hidden] */
$fn = 144;
// Which finger this file draws; #930-007 includes it and names its own.
SIDE = "drive";

assert(config == "revised", "#930-001 exists only in the revised configuration: it has no reference");

function side() = SIDE == "drive" ? 1 : -1;

// M1, along the set screw's line: out through the hub's far side, and stopped under the blade.
module screw_hole(cfg) let(c = fit_clearances(cfg), r = claw_hub_r() + 1)
    rotate([0, -claw_screw_dir(side()), 0]) rotate([0, 90, 0]) translate([0, 0, -r])
        cylinder(d = fit_pin(claw_screw()[0], c[3]), h = r + claw_screw_stop(), $fn = 48);

module slab(t) multmatrix(AXIS_Y) translate([0, 0, -t / 2]) linear_extrude(t) children();

// The outline at the blade's thickness, its edges filleted and the teeth's zone cut from its round hub,
// and the hub, round and toothed, at the hub's. Every radius of the outline is over the R1 fillet, so its
// insets cannot collapse, and BOSL2's check of them, four fifths of this part's render, is left off.
module claw_finger(cfg = config) let(c = fit_clearances(cfg), t = claw_blade_t(), f = os_circle(r = claw_blade_fillet(), check_valid = false)) difference() {
    union() {
        difference() {
            multmatrix(AXIS_Y) translate([0, 0, -t / 2]) offset_sweep(claw_finger_path(side()), height = t, bottom = f, top = f);
            slab(t + 2) claw_teeth_zone_2d(side());
        }
        slab(FINGER_T) claw_hub_2d(cfg, side());
    }
    slab(FINGER_T + 2) claw_hex_2d(c[0]);
    screw_hole(cfg);
}

if (layer == "part") claw_finger();
else difference() { claw_finger_2d(config, side()); claw_hex_2d(fit_clearances(config)[0]); }
