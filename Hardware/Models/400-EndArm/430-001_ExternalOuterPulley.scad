// #430-001 External Outer Pulley — driven pulley of the outer channel's stage 1
// at the elbow: 90T in "previous", 108T in "revised" (DC-12). The shared
// definition, and what each configuration builds, is in external_pulley.scad.
//
// The reference (Reference/meshes/400-EndArm/) is a Ø8-bore hub with three
// radial M3 set screws and their nut slots at r 6.4, a web z 23.5..32.0 pierced
// by three windows at 60, 180 and 300 deg, and a rim r 24.0..29.5 over
// z 22.5..32.0 carrying the 90T band z 24.0..30.5. A Ø3 access hole runs
// radially through the rim at z 26.5 in line with each window, so a key can
// reach the set screw; the rim's teeth count 87 on the mesh because the three
// holes take three teeth.
//
// "revised" keeps everything inside R_CUT, which is the whole web and the
// inner 2 mm of the rim, and re-drills the access holes through the new rim at
// ACCESS_D, a shade over the reference's Ø3 so the new bore contains the old
// one rather than running along it.

include <external_pulley.scad>

/* [Hidden] */
R_CUT      = 26.0;
RIM_LOWER  = [[1.090, 22.5], [1.090, 23.0], [0.090, 24.0]];
RIM_UPPER  = [[0.103, 30.5], [1.103, 31.5], [1.103, 32.0]];
ACCESS_Z   = 26.5;
ACCESS_ANG = [60, 180, 300];
ACCESS_D   = 3.1;
ACCESS_R   = [23.0, EXT_TIP_R + 2.0];   // radial span the drill runs over

module external_outer_pulley() {
    if (config == "previous")
        external_pulley("430-001_ExternalOuterPulley.stl", R_CUT, RIM_LOWER, RIM_UPPER);
    else difference() {
        external_pulley("430-001_ExternalOuterPulley.stl", R_CUT, RIM_LOWER, RIM_UPPER);
        for (a = ACCESS_ANG)
            rotate([0, 0, a]) translate([ACCESS_R[0], 0, ACCESS_Z]) rotate([0, 90, 0])
                cylinder(d = ACCESS_D, h = ACCESS_R[1] - ACCESS_R[0], $fn = 48);
    }
}

external_outer_pulley();
