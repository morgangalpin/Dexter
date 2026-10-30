// #930-001 Claw Finger — parametric source.
// The claw's finger, one model for every finger of both claws: the 2-finger claw takes two, the 4-finger
// claw four. A curved blade on a closed hub, whose hex bore slides over a Claw Gear's hex seat (#930-002)
// like a box-end wrench and is held there by one M3 x 4 set screw (C-618) on a flat. claw_params.scad
// owns its dimensions and gives the claw's mechanism.
//
// Designed, "revised" only: there is no reference mesh.
//
// FRAME. Its own: the pivot's axis along +Y through the origin, the mid-plane y = 0, and (x, z) the grip
// frame's about the drive pivot with the claw closed, the tip toward -X. The follower's finger is this
// part turned 180 deg about Z; claw_params.scad's THE FLIP.
//
//     ID  feature        value
//     H1  hub            R9, 10 thick (y ±5)
//     B1  blade          7 thick (y ±3.5), 7 wide: the legacy claw finger's curve (claw_params.scad), a
//                        shank off H1 tangent into an arc whose grip face is R20.277 over 66.4 deg, leaned
//                        claw_lean() toward the roll axis, its root filleted R2 onto H1
//     T1  tip            the blade's end, a full round R3.5 centred 77.3 from the pivot, which touches the
//                        other finger's T1 on the roll axis when the claw is closed
//     X1  hex bore       10 across flats, a vertex on +Z, through H1
//     M1  set-screw hole Ø2.6 tapped M3 along +X from X1's flat through H1, on the mid-plane
//
// FITS (revised). X1 takes the gear's hex seat, a printed part: every face grown by FIT_SLIP. M1 is tapped
// by the set screw: fit_pin(3, FIT_TAP) = Ø2.6; the M3 x 4 on the seat's flat stands flush with H1. T1
// meets the other finger's T1 line to line when the claw is closed.

include <claw_params.scad>

/* [Configuration] */
// Parameter set: designed in revised only
config = "revised"; // [revised]
// What to draw: the part, or its 2D outline
layer = "part"; // [part, outline]

/* [Hidden] */
$fn = 144;
LAP = 0.005;

assert(config == "revised", "#930-001 exists only in the revised configuration: it has no reference");

module screw_hole(cfg) let(c = fit_clearances(cfg))
    rotate([0, 90, 0]) cylinder(d = fit_pin(claw_screw()[0], c[3]), h = claw_hub_r() + 1, $fn = 48);

module slab(t) multmatrix(AXIS_Y) translate([0, 0, -t / 2]) linear_extrude(t) children();

module claw_finger(cfg = config) let(c = fit_clearances(cfg)) difference() {
    union() {
        slab(claw_blade_t()) claw_finger_solid_2d();
        slab(FINGER_T) circle(r = claw_hub_r());
    }
    slab(FINGER_T + 2) claw_hex_2d(c[0]);
    screw_hole(cfg);
}

if (layer == "part") claw_finger();
else difference() { claw_finger_solid_2d(); claw_hex_2d(fit_clearances(config)[0]); }
