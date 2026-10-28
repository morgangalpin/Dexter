// The joint of the L3 glue rig, shared by its two halves.
//
//     GlueRig_EndArmHubToDiff_A.scad   the tab, standing off its plate's end
//     GlueRig_EndArmHubToDiff_B.scad   the notch in its plate's end that the tab enters
//
// The halves' plates butt on x = L3_JOINT_X, z 18 .. 23, and A's tab runs into B's notch on the
// rig's centre line, keeping the two in line. Measured on both references (scadmesh arcs at z 20.5
// and 21), which agree to the third decimal. The two registers stand L3_SPAN apart along x, which is
// the span the rig holds; specs/009 DC-11(h) owns why it is 307.500.
//
// Included, not used, so that its constants reach the including file.

L3_JOINT_X = 128.287;           // where A's plate ends and B's begins
L3_A_AXIS  = -16.865;           // A's register axis (the J4 end), on x
L3_SPAN    = 307.500;           // A's register to B's: L3 (specs/003 § Link lengths)
L3_TAB     = [10.000, 6.000];   // the tab and the notch: length along +X, width

// The tab's (and notch's) outline, grown by `grow` on its two sides.
module l3_tab_2d(grow = 0)
    translate([L3_JOINT_X, -L3_TAB[1] / 2 - grow]) square([L3_TAB[0], L3_TAB[1] + 2 * grow]);
