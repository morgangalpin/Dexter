// #200-003 Stator Balancer — parametric source.
// One of four keys that stand in the Arm Body's K1 slots and the Pivot Stator Holder's ear slots, and
// hold the stator against the drive's torque. They are tapped in with light mallet taps
// (specs/008.5 step 6).
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/200-ArmBody/), in that mesh's frame.
//   config = "revised"  — the same part. Its mates' fits are the Arm Body's K1 and the holder's ear slot, which carry them.
//
// FRAME. The reference's own, which is the Arm Body's assembly frame: the shank's inner face on
// x = 0, the part from y 0 to 9.900 and from z 86 to 98.
//
// Measured from the reference with scadmesh planes/slice/solid (it is 20 triangles). The feature IDs
// are those of 200-003_StatorBalancer.view.json:
//
//     ID  feature   section (x by z)            y span
//     S1  shank     0 .. 3.900  by 86 .. 96     0 .. 9.900
//     L1  lip       0 .. 4.900  by 96 .. 98     0 .. 9.900
//
// FITS: none drawn here. S1 stands in the Arm Body's K1 slot, 0.05 per side, the press clearance, and in
// the holder's ear slot (whose revised slip is the holder's); each carries its own gap.

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]

/* [Hidden] */
SHANK = [3.900, 86.000, 96.000];   // radial depth, z bottom, z top
LIP   = [4.900, 98.000];           // radial depth, z top
WIDTH = 9.900;

// The L section in (x, z), extruded along +Y.
module stator_balancer(cfg = config)
    translate([0, WIDTH, 0]) rotate([90, 0, 0]) linear_extrude(WIDTH)
        polygon([[0, SHANK[1]], [SHANK[0], SHANK[1]], [SHANK[0], SHANK[2]],
                 [LIP[0], SHANK[2]], [LIP[0], LIP[1]], [0, LIP[1]]]);

stator_balancer();
