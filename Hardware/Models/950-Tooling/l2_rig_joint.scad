// The joint of the L2 glue rig, shared by its three parts.
//
//     GlueRig_ArmBodyToEndArmHub_A.scad   cuts the joint's +Y half from its plate's end
//     GlueRig_ArmBodyToEndArmHub_B.scad   cuts the joint's -Y half from its plate's end
//     GlueRig_ArmBodyToEndArmHub_C.scad   is the key: the whole joint, extruded
//
// A and B butt end to end on y = L2_JOINT_Y, and the key C drops into the pocket their two ends make,
// locking them in line. In plan the pocket is a 50 x 50 square with a 10 x 10 notch in the middle of
// each side: the notches on ±Y are tabs that stand in from A's and B's end walls, and the notches on
// ±X are the lips either side of the slot the two plates leave between their side rails. The joint is
// symmetric about y = L2_JOINT_Y and about x = L2_JOINT_X.
//
// Measured on all three references (scadmesh arcs, z 5 on A and B, z 15 on C), which agree to the
// third decimal. The reference is in the rigs' common frame, whose x = 0 is 0.068 off the joint's
// centre line.
//
// Included, not used, so that its constants reach the including file.

L2_JOINT_X    = -0.068;    // the joint's centre line
L2_JOINT_Y    = 170.016;   // where A's and B's ends meet
L2_JOINT_SIDE = 50.000;    // the square
L2_JOINT_TAB  = 10.000;    // each notch, square

// The joint's whole outline: the key's section, and the pocket A and B leave between them.
module l2_joint_2d()
    translate([L2_JOINT_X, L2_JOINT_Y]) difference() {
        square(L2_JOINT_SIDE, center = true);
        for (a = [0 : 90 : 270]) rotate(a)
            translate([L2_JOINT_SIDE / 2 - L2_JOINT_TAB / 2 + 0.5, 0])
                square([L2_JOINT_TAB + 1, L2_JOINT_TAB], center = true);
    }

// The half of the joint on one side of the butt line: side = +1 for A (y > L2_JOINT_Y), -1 for B.
module l2_joint_half_2d(side)
    intersection() {
        l2_joint_2d();
        translate([L2_JOINT_X - L2_JOINT_SIDE, side > 0 ? L2_JOINT_Y : L2_JOINT_Y - L2_JOINT_SIDE])
            square([2 * L2_JOINT_SIDE, L2_JOINT_SIDE]);
    }
