// GlueRig_ArmBodyToEndArmHub_B — the L2 glue rig's Arm Body half — parametric source.
// The L2 rig holds the Arm Body (#200-001) and the Axis Intersection Half (#410-001) at their
// finished spacing while the L2 tube's epoxy cures (specs/007.2 § Tooling — glue rigs). This half
// carries the Arm Body: its collar and spigot enter the body's lower end, where the 6810 seat and the
// L1 ledge are. Its far end butts A's, and the key C locks the two.
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/950-Tooling/), in that mesh's frame.
//   config = "revised"  — the same part with the slip fit drawn on the collar in the Arm Body.
//
// FRAME. The rig's common frame, the reference's own: the J2 axis on +Z through the origin, the
// plate on z 0 .. 10 and running out along +Y to the joint at y 170.016.
//
// CONSTRUCTION. Three layers on the bore, each drawn whole in 2D and extruded once, each lapping
// SEAM_LAP into the one above:
//
//     spigot   z -17 .. -7    S1 - B1
//     collar   z -7 .. 0      C1 - B1
//     plate    z 0 .. 10      P1 - B1 - W1 - K1 - the joint's -Y half (l2_rig_joint.scad)
//
// `layer = "spigot"`, `"collar"` or `"plate"` draws that profile in 2D, for verification against the
// mesh's section (render.rs --verify does this).
//
// Measured from the reference with scadmesh planes/radial/slice/arcs/solid:
//
//     ID  feature       value
//     B1  bore          Ø40.000, through
//     S1  spigot        Ø54.000, z -17 .. -7
//     C1  collar        Ø65.000, z -7 .. 0
//     P1  plate         |x| <= 32.5 from y 0 to the joint, a R32.5 half-round on the axis; z 0 .. 10
//     W1  window        x -25.068 .. 24.932, y 48.016 .. 135.016
//     K1  slot          10.000 x 4.000 on +Y, r 33.516 .. 37.516: in line with the Arm Body's K1
//
// FITS (../print_fit.scad), revised only:
//
//     C1, in the Arm Body's 6810 seat (#200-001's revised Ø65 at the press clearance)    slip
//
// S1 stands 1.0 per side inside the Arm Body's Ø56 L1 ledge, wider than the slip fit, and keeps it.
// K1 is drawn as the reference has it; nothing of the rig's is drawn in it. The joint's slip is the
// key's (GlueRig_ArmBodyToEndArmHub_C.scad). The Arm Body's dimensions are those of
// ../200-ArmBody/200-001_ArmBody.scad (B1, L1 and its seat).

include <../print_fit.scad>
include <l2_rig_joint.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or one layer's 2D profile
layer = "part"; // [part, spigot, collar, plate]

/* [Hidden] */
$fn = 180;
SEAM_LAP = 0.005;   // each layer runs this far into the next, so no two faces coincide

BORE_D    = 40.000;                   // B1
SPIGOT    = [54.000, -17.000, -7.000]; // S1: diameter, z bottom, z top
COLLAR    = [65.000, -7.000, 0.000];  // C1
PLATE     = [32.500, 0.000, 10.000];  // P1: half-width and end radius, z bottom, z top
WINDOW    = [[-25.068, 48.016], [24.932, 135.016]];   // W1: corners
SLOT      = [33.516, 37.516, 5.000];  // K1: inner and outer radius, half-width

ARM_SEAT_D = fit_bore(65.000, FIT_PRESS);   // the Arm Body's revised 6810 seat

SLIP = fit_clearances(config)[0];

function collar_d() = config == "previous" ? COLLAR[0] : fit_pin(ARM_SEAT_D, SLIP);

module bore_2d() circle(d = BORE_D);

module spigot_2d() difference() { circle(d = SPIGOT[0]); bore_2d(); }

module collar_2d() difference() { circle(d = collar_d()); bore_2d(); }

module plate_2d()
    difference() {
        union() {
            circle(r = PLATE[0]);
            translate([-PLATE[0], 0]) square([2 * PLATE[0], L2_JOINT_Y]);
        }
        bore_2d();
        translate(WINDOW[0]) square(WINDOW[1] - WINDOW[0]);
        translate([-SLOT[2], SLOT[0]]) square([2 * SLOT[2], SLOT[1] - SLOT[0]]);
        l2_joint_half_2d(-1);
    }

module slab(z0, z1) translate([0, 0, z0]) linear_extrude(z1 - z0) children();

module rig_b() {
    slab(SPIGOT[1], SPIGOT[2] + SEAM_LAP) spigot_2d();
    slab(COLLAR[1], COLLAR[2] + SEAM_LAP) collar_2d();
    slab(PLATE[1], PLATE[2]) plate_2d();
}

if (layer == "spigot") spigot_2d();
else if (layer == "collar") collar_2d();
else if (layer == "plate") plate_2d();
else rig_b();
