// #930-001 Claw Finger — parametric source.
// The claw's finger, one model for every finger of both claws: the 2-finger claw takes two, the 4-finger
// claw four. A curved blade on a hub whose socket drops onto the Span Driver's head (#912-002 D1) on the
// drive pivot and onto a gear's or an axle's nose on both pivots, held by an M3 x 6 set screw (C-606)
// in the nose's cross-hole. claw_params.scad owns its dimensions and gives the claw's mechanism.
//
// Designed, "revised" only: there is no reference mesh.
//
// FRAME. Its own: the pivot's axis along +Y through the origin, the mid-plane y = 0, and (x, z) the grip
// frame's about the drive pivot with the claw closed, the tip toward -X. The follower's finger is this
// part turned 180 deg about Z; claw_params.scad's THE FLIP.
//
//     ID  feature        value
//     H1  hub            R7, 10 thick (y ±5)
//     B1  blade          6 thick (y ±3): the band BLADE_W wide outside the grip (claw_grip_2d()), from
//                        the pivot's height up to the tip, its convex edges rounded R1
//     T1  tip face       the blade's end on the roll axis (x = -14.139 here), which meets the other tip
//     S1  socket         the Span Driver's head's outline, open down through H1
//     M1  set-screw      Ø2.6 tapped M3 along +X from S1 through H1's outer side, at y ±2.5 and z 0
//         holes ×2
//
// FITS (revised). S1 takes the Span Driver's head and the gears' and axles' noses, printed parts: the
// head's outline grown by FIT_SLIP, its sides run on down at the flats' width. M1 is tapped by the set
// screw: fit_pin(3, FIT_TAP) = Ø2.6. T1 meets the other finger's T1 line to line when the claw is closed.

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

module screw_holes(cfg) let(c = fit_clearances(cfg)) for (s = [-1, 1])
    translate([0, s * claw_screw()[1], 0]) rotate([0, 90, 0])
        cylinder(d = fit_pin(claw_screw()[0], c[3]), h = claw_hub_r() + 1, $fn = 48);

module slab(t) multmatrix(AXIS_Y) translate([0, 0, -t / 2]) linear_extrude(t) children();

module claw_finger(cfg = config) difference() {
    union() {
        slab(claw_blade_t()) claw_finger_solid_2d();
        slab(FINGER_T) circle(r = claw_hub_r());
    }
    slab(FINGER_T + 2) claw_socket_2d(cfg);
    screw_holes(cfg);
}

if (layer == "part") claw_finger();
else difference() { claw_finger_solid_2d(); claw_socket_2d(config); }
