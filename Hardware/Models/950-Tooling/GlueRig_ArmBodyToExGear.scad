// GlueRig_ArmBodyToExGear — the Ex Gear Mount glue rig — parametric source.
// One plate that holds the Arm Body (#200-001) and the Ex Gear Mount (#520-001) at their finished
// spacing while the #520-006 span's epoxy cures (specs/007.2 § Tooling — glue rigs). Its ring end
// enters the Arm Body's lower end and carries the body's outline; its disc end keys into the Ex Gear
// Mount's four slots and takes four M3 screws.
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/950-Tooling/), in that mesh's frame.
//   config = "revised"  — the same part with its print fits on the ring, the keys and the screw holes.
//
// FRAME. The reference's own: the plate on z 0 .. 3, the disc about the origin O, the ring about
// R = (155.263, 0). The disc's holes and keys are about P = (-0.654, 0), not O; both are the
// reference's, and both are kept.
//
// CONSTRUCTION. Four layers, each drawn whole in 2D and extruded once, each lapping SEAM_LAP into the
// plate:
//
//     ring    z -13.505 .. -6.505   G1 - B1
//     pad     z -6.505 .. 0         A1 - B1 - K1
//     keys    z -5 .. 0             Y1
//     plate   z 0 .. 3              D1 + T1 + A1 - B1 - K1 - W1 - C1 - H1
//
// A1 is the Arm Body's outline with its ±Y ears only, drawn from ../200-ArmBody/arm_body_outline.scad
// (the circle, the ear and their R4 fillets) about R. `layer = "ring"`, `"pad"`, `"keys"` or
// `"plate"` draws the section from that layer's height in 2D (`"keys"` draws the pad with them), for
// verification against the mesh's section (render.rs --verify does this).
//
// Measured from the reference with scadmesh planes/radial/slice/arcs/solid:
//
//     ID  feature        value
//     G1  ring           Ø65.000 about R, z -13.505 .. -6.505
//     B1  bore           Ø55.000 about R, through
//     A1  pad            the Arm Body's outline about R, ears on ±Y only; z -6.505 .. 0, and in the plate
//     K1  slots          10.000 x 4.000 on ±Y at r 33.516 .. 37.516 about R: in line with the Arm
//                        Body's K1; through the pad and the plate
//     D1  disc           R38.000 about O, its flanks tangent to it from the bar's corners
//     T1  bar            |y| <= 20.663, x 42.007 .. 125.175, its ends tangent to D1 and to A1's circle
//     W1  window         x 45.029 .. 112.804, |y| <= 10.167
//     C1  centre hole    Ø22.000 about P
//     H1  screw holes    4 x Ø3.200 on P ± (15.5, ±15.5)
//     Y1  keys           4 x 3.300 radial x 12.800 about P, from r 21.0, on 0/90/180/270 deg;
//                        z -5 .. 0
//
// FITS (../print_fit.scad), revised only:
//
//     G1, in the Arm Body's 6810 seat (#200-001's revised Ø65 at the press clearance)      slip
//     Y1, in the Ex Gear Mount's 3.300 x 12.800 slots (#520-001's S1, r 22.65)            slip
//     H1, M3 screws                                                                       slip
//
// The mates' dimensions are those of ../500-ExternalGear/520-001_ExGearMount.scad (S1, which
// `revised` keeps at size) and ../200-ArmBody/200-001_ArmBody.scad.

include <../print_fit.scad>
include <../200-ArmBody/arm_body_outline.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or one layer's 2D profile
layer = "part"; // [part, ring, pad, keys, plate]

/* [Hidden] */
$fn = 180;
SEAM_LAP = 0.005;   // each layer runs this far into the plate, so no two faces coincide

R        = [155.263, 0];                 // the ring's centre
P        = [-0.654, 0];                  // the disc's holes and keys
RING     = [65.000, -13.505, -6.505];    // G1: diameter, z bottom, z top
BORE_D   = 55.000;                       // B1
PAD_Z    = [-6.505, 0.000];              // A1
PLATE_Z  = [0.000, 3.000];
DISC_R   = 38.000;                       // D1
BAR      = [42.007, 125.175, 20.663];    // T1: x start, x end, half-width
WINDOW   = [[45.029, -10.167], [112.804, 10.167]];   // W1: corners
CENTRE_D = 22.000;                       // C1
SCREW    = [3.200, 15.500];              // H1: diameter, offset on x and y
KEY      = [21.000, 3.300, 12.800];      // Y1: inner radius, radial depth, width
KEY_Z    = [-5.000, 0.000];

ARM_SEAT_D = fit_bore(65.000, FIT_PRESS);   // the Arm Body's revised 6810 seat
M3         = 3.000;

SLIP = fit_clearances(config)[0];

function ring_d()  = config == "previous" ? RING[0] : fit_pin(ARM_SEAT_D, SLIP);
function screw_d() = config == "previous" ? SCREW[0] : fit_bore(M3, SLIP);

// The Arm Body's outline with its ±Y ears, about the origin.
module arm_outline_2d()
    offset(r = -ARM_BODY_EAR[2]) offset(delta = ARM_BODY_EAR[2]) union() {
        circle(r = ARM_BODY_R);
        for (a = [90, 270]) rotate(a) arm_body_ear_2d();
    }

module ring_cuts_2d()
    translate(R) {
        circle(d = BORE_D);
        for (a = [90, 270]) rotate(a)
            translate([(ARM_BODY_SLOT[0] + ARM_BODY_SLOT[1]) / 2, 0])
                square([ARM_BODY_SLOT[1] - ARM_BODY_SLOT[0], 2 * ARM_BODY_SLOT[2]], center = true);
    }

module ring_2d() translate(R) difference() { circle(d = ring_d()); circle(d = BORE_D); }

module pad_2d() difference() { translate(R) arm_outline_2d(); ring_cuts_2d(); }

// One key on +X about P, at the slip off the slot's walls in revised.
module keys_2d()
    translate(P) for (a = [0 : 90 : 270]) rotate(a)
        translate([KEY[0] + KEY[1] / 2, 0]) square([KEY[1] - 2 * SLIP, KEY[2] - 2 * SLIP], center = true);

module plate_2d()
    difference() {
        union() {
            hull() { circle(r = DISC_R); for (s = [-1, 1]) translate([BAR[0], s * BAR[2]]) square(0.01, center = true); }
            translate([BAR[0], -BAR[2]]) square([BAR[1] - BAR[0], 2 * BAR[2]]);
            hull() { translate(R) circle(r = ARM_BODY_R); for (s = [-1, 1]) translate([BAR[1], s * BAR[2]]) square(0.01, center = true); }
            translate(R) arm_outline_2d();
        }
        ring_cuts_2d();
        translate(WINDOW[0]) square(WINDOW[1] - WINDOW[0]);
        translate(P) {
            circle(d = CENTRE_D);
            for (sx = [-1, 1], sy = [-1, 1]) translate(SCREW[1] * [sx, sy]) circle(d = screw_d());
        }
    }

module slab(z0, z1) translate([0, 0, z0]) linear_extrude(z1 - z0) children();

module rig_exgear() {
    slab(RING[1], RING[2] + SEAM_LAP) ring_2d();
    slab(PAD_Z[0], PAD_Z[1] + SEAM_LAP) pad_2d();
    slab(KEY_Z[0], KEY_Z[1] + SEAM_LAP) keys_2d();
    slab(PLATE_Z[0], PLATE_Z[1]) plate_2d();
}

if (layer == "ring") ring_2d();
else if (layer == "pad") pad_2d();
else if (layer == "keys") { pad_2d(); keys_2d(); }
else if (layer == "plate") plate_2d();
else rig_exgear();
