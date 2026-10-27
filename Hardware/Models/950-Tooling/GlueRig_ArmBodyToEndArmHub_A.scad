// GlueRig_ArmBodyToEndArmHub_A — the L2 glue rig's Axis Intersection Half end — parametric source.
// The L2 rig holds the Arm Body (#200-001) and the Axis Intersection Half (#410-001) at their
// finished spacing while the L2 tube's epoxy cures (specs/007.2 § Tooling — glue rigs). This half
// carries the Axis Intersection Half: its boss enters the half's Ø42 bore, and its head block, with
// the two ears, follows the half's own outline. Its near end butts B's, and the key C locks the two.
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/950-Tooling/), in that mesh's frame.
//   config = "revised"  — the same part with the slip fit drawn on the boss.
//
// FRAME. The rig's common frame, the reference's own (B's J2 axis is the origin): the plate on
// z 0 .. 10, running along +Y from the joint at y 170.016 to the head about H = (-0.136, 340.032).
//
// CONSTRUCTION. Three layers on the bore, each drawn whole in 2D and extruded once, each lapping
// SEAM_LAP into the one above:
//
//     boss    z -19.75 .. -10.75   O1 - B1
//     block   z -10.75 .. 0        D1 (a hull of the head circle and the two flank ends) + E1 - B1 - E2
//     plate   z 0 .. 10            P1 + the head circle + E1 - B1 - W1 - E2 - the joint's +Y half
//                                  (l2_rig_joint.scad)
//
// `layer = "boss"`, `"block"` or `"plate"` draws that profile in 2D, for verification against the
// mesh's section (render.rs --verify does this).
//
// Measured from the reference with scadmesh planes/radial/slice/arcs/solid:
//
//     ID  feature       value
//     B1  bore          Ø24.000 about H, through
//     O1  boss          Ø42.000 about H, z -19.75 .. -10.75
//     D1  head block    R32.5 about H, its flanks tangent to it from (-21.424, 296.533) and
//                       (20.909, 296.533); z -10.75 .. 0
//     P1  plate         |x| <= 32.5 from the joint; its +X edge runs to y 340.032 and steps in
//                       0.136 to the head circle there, its -X edge runs to (-32.5, 337.065) and
//                       on to the head circle at (-32.634, 339.732); the head R32.5 about H;
//                       z 0 .. 10
//     W1  window        x -25.068 .. 24.932, y 205.016 .. 296.533
//     E1  ears          R3 stadiums on (-22.954, 366.688)-(-18.436, 369.971) and
//                       (22.682, 366.689)-(18.164, 369.971), each carried radially in to the head
//                       circle with straight sides; z -10.75 .. 10
//     E2  ear slots     2.540 x 5.588, one through each ear (corners below)
//
// The head's centre lies 0.136 off the plate's centre line, and the plate's edges meet it as above;
// both are the reference's, and both are kept.
//
// FITS (../print_fit.scad), revised only:
//
//     O1, in the Axis Intersection Half's Ø42 lip    slip
//
// The Axis Intersection Half's dimensions are those of ../400-EndArm/410-001_AxisIntersectionHalf.scad
// (R3, which `revised` keeps at size). The joint's slip is the key's
// (GlueRig_ArmBodyToEndArmHub_C.scad).

include <../print_fit.scad>
include <l2_rig_joint.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or one layer's 2D profile
layer = "part"; // [part, boss, block, plate]

/* [Hidden] */
$fn = 180;
SEAM_LAP = 0.005;   // each layer runs this far into the next, so no two faces coincide

H        = [-0.136, 340.032];           // the head's centre
HEAD_R   = 32.500;                      // D1, P1
BORE_D   = 24.000;                      // B1
BOSS     = [42.000, -19.750, -10.750];  // O1: diameter, z bottom, z top
BLOCK_Z  = [-10.750, 0.000];            // D1
FLANKS   = [[-21.424, 296.533], [20.909, 296.533]];   // D1's flank ends
PLATE_Z  = [0.000, 10.000];             // P1
PLATE_W  = 32.500;                      // P1's half-width
PLATE_EDGE = [[32.500, 340.032], [32.364, 340.032], [-32.634, 339.732], [-32.500, 337.065]];
WINDOW   = [[-25.068, 205.016], [24.932, 296.533]];   // W1: corners
EAR_R    = 3.000;                       // E1
EAR_IN   = 8.000;                       // how far each ear is carried in, past the head circle
EARS     = [[[-22.954, 366.688], [-18.436, 369.971]], [[22.682, 366.689], [18.164, 369.971]]];
EAR_SLOTS = [                           // E2: each slot's corners
    [[-23.286, 367.143], [-21.793, 365.088], [-17.272, 368.372], [-18.765, 370.427]],
    [[23.014, 367.143], [21.522, 365.088], [17.001, 368.372], [18.494, 370.427]]];

BORE_410 = 42.000;                      // the Axis Intersection Half's bore

SLIP = fit_clearances(config)[0];

function boss_d() = config == "previous" ? BOSS[0] : fit_pin(BORE_410, SLIP);

module bore_2d() translate(H) circle(d = BORE_D);

// Each ear: the stadium on its two centres, carried in toward H until it is inside the head circle.
module ears_2d()
    for (e = EARS) let(mid = (e[0] + e[1]) / 2, inward = (H - mid) / norm(H - mid))
        hull() for (c = e, s = [0, EAR_IN]) translate(c + s * inward) circle(r = EAR_R);

module ear_slots_2d() for (s = EAR_SLOTS) polygon(s);

module boss_2d() difference() { translate(H) circle(d = boss_d()); bore_2d(); }

module block_2d()
    difference() {
        union() {
            hull() { translate(H) circle(r = HEAD_R); polygon(concat(FLANKS, [H])); }
            ears_2d();
        }
        bore_2d();
        ear_slots_2d();
    }

module plate_2d()
    difference() {
        union() {
            polygon(concat([[-PLATE_W, L2_JOINT_Y], [PLATE_W, L2_JOINT_Y]], PLATE_EDGE));
            translate(H) circle(r = HEAD_R);
            ears_2d();
        }
        bore_2d();
        translate(WINDOW[0]) square(WINDOW[1] - WINDOW[0]);
        ear_slots_2d();
        l2_joint_half_2d(+1);
    }

module slab(z0, z1) translate([0, 0, z0]) linear_extrude(z1 - z0) children();

module rig_a() {
    slab(BOSS[1], BOSS[2] + SEAM_LAP) boss_2d();
    slab(BLOCK_Z[0], BLOCK_Z[1] + SEAM_LAP) block_2d();
    slab(PLATE_Z[0], PLATE_Z[1]) plate_2d();
}

if (layer == "boss") boss_2d();
else if (layer == "block") block_2d();
else if (layer == "plate") plate_2d();
else rig_a();
