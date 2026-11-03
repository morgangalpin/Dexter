// GlueRig_ArmBodyToEndArmHub_C — the L2 glue rig's key — parametric source.
// The L2 rig is three printed parts: B holds the Arm Body, A holds the Axis Intersection Half, and
// this key drops into the pocket their butted ends make and locks them in line while the L2 tube's
// epoxy cures (specs/007.2 § Tooling — glue rigs).
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/950-Tooling/), in that mesh's frame.
//   config = "revised"  — the key with the slip fit drawn on every face it meets A and B with.
//
// FRAME. The rig's common frame, the reference's own: the key lies over the joint at z 10 .. 20, a
// plate's thickness above the pocket (z 0 .. 10) it drops into.
//
// CONSTRUCTION. One layer: the joint's outline (l2_rig_joint.scad), extruded. `layer = "key"` draws
// it in 2D for verification against the mesh's section.
//
// Measured from the reference with scadmesh planes/slice/arcs (it is 76 triangles):
//
//     ID  feature        value
//     K1  key            the joint, 50 x 50 with a 10 x 10 notch mid-side, z 10 .. 20
//
// FITS (../print_fit.scad), revised only:
//
//     K1, every side, in A's and B's pocket and round their tabs and lips    slip
//
// The key carries the whole clearance, so A's and B's pockets are drawn as the reference has them.

include <../print_fit.scad>
include <l2_rig_joint.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or its 2D profile
layer = "part"; // [part, key]

/* [Hidden] */
KEY_Z = [10.000, 20.000];   // K1

SLIP = fit_clearances(config)[0];

module key_2d() offset(delta = -SLIP) l2_joint_2d();

if (layer == "key") key_2d();
else translate([0, 0, KEY_Z[0]]) linear_extrude(KEY_Z[1] - KEY_Z[0]) key_2d();
