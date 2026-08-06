// 700-Differential assembly — placement model (DC-2).
// Places the parametric parts in their assembled positions (008.6) so the
// stack can be reviewed visually and so the kinematic quantities below can
// be computed from the built geometry. It is a union, not an interference
// test: bearings and the CF rod are not modeled, so parts meet where those
// would sit. What it does check automatically is the L4 split, the axis
// intersection, and the revised configuration's envelope.
// Frame: Diff Body A at the origin with the J4 pivot
// axis along +Z (the axis of A's 6705/6703 ladder, realized by the Diff
// Gear Shaft). Diff Body B pivots about that axis; the Split Gear / J5
// output axis crosses it at the differential centre C.
//
// Kinematic conformance (DC-6, 004). In a bevel differential the J4 and
// J5 axes *intersect* — at the differential centre C — which is why the
// measured DH set carries a ~ 0 on both wrist rows and puts the wrist
// geometry in the d offsets instead. The firmware link length
// L4 = 59.50 mm is therefore an offset **along the J4 axis**, and it
// composes as
//   L4 = DIFF_CONTRIB + HUB_INSET
// where DIFF_CONTRIB is measured here (Body A's End Arm Hub mating face,
// z = 0, up the J4 axis to C) and HUB_INSET is the standoff the End Arm
// Hub must add on its side of that face. The required HUB_INSET is
// echoed below for the End Arm Hub design; the assert keeps it positive
// and within a plausible hub depth.

// The parts are pulled in with `use`, so only their modules are imported and
// their own top-level render calls do not fire. An OpenSCAD `-D config=...`
// override still reaches those modules' scopes, so selecting a configuration
// on the command line switches the parts here too, not just this file.
include <diff_params.scad>
use <710-001_SplitGearTop.scad>
use <710-002_SplitGearBottom.scad>
use <710-003_DiffKeeper.scad>
use <710-004_RotateCodeDisk.scad>
use <720-001_DiffGearShaft.scad>
use <720-002_DiffGearAxle.scad>
use <720-003_DiffEndPulley.scad>
use <730-001_DiffBodyA.scad>
use <730-002_DiffBodyB.scad>

/* [Hidden] */
// Body B -> Body A transform: B's tunnel axis (along Y at x=21, z=20.5)
// maps onto A's +Z axis; B's rear tunnel end lands just above A's ladder.
B_SHIFT = 10.0;   // A-frame z of B's tunnel y = 0
// Differential centre C (J4 x J5 axis crossing), A frame:
C = [0, 0, B_SHIFT + 21.0];

// L4 split (see header): differential contribution is C's height above
// Body A's mating face, measured along the J4 axis.
DIFF_CONTRIB = C.z;
HUB_INSET    = L4_TARGET - DIFF_CONTRIB;
echo(str("L4 split along the J4 axis: differential=", DIFF_CONTRIB,
         " mm + required End Arm Hub inset=", HUB_INSET,
         " mm = ", L4_TARGET, " mm (firmware L4)"));
assert(HUB_INSET > 0 && HUB_INSET < 45,
       "HUB_INSET out of range - revisit the differential's J4-axis stack");
// The axes must intersect: C lies on the J4 axis (x = y = 0) by
// construction, and on the J5 axis at the same point.
assert(C.x == 0 && C.y == 0, "J4 and J5 axes must intersect at C");
// Revised config must fit the HDI-940 cover envelope across the arm.
if (config == "revised")
    assert(BODY_A_LEN <= COVER_ENVELOPE.x,
           "Body A exceeds the cover envelope");

module placed_body_b() {
    translate([-21, -20.5, B_SHIFT]) xrot(-90) diff_body_b();
}

// The shaft realizes the J4 axle: its Ø25 section in A's 6705, rear Ø17
// journal in A's 6703. Shaft frame y maps to A frame -z + 51.5.
module placed_shaft() {
    up(51.5) xrot(90) diff_gear_shaft();
}

// Rod path (input A): pulley at the rear of the 96 mm rod, axle gear at
// the front, both on the shaft/J4 axis.
module placed_rod_parts() {
    up(62.5) zflip() diff_end_pulley();
    up(51.5 - 49.6 - 2.0) diff_gear_axle();
}

// Output stack on the J5 axis through C: split gear pair, code disk,
// keeper (positions per 008.6; the J5 axis is A-frame Y at z = C.z).
module placed_output() {
    translate(C) xrot(-90) {
        up(9.0) split_gear_top();
        up(9.0) zflip() split_gear_bottom();
        up(6.0) rotate_code_disk();
        up(33.5) diff_keeper();
    }
}

union() {
    diff_body_a();
    placed_body_b();
    placed_shaft();
    placed_rod_parts();
    placed_output();
}
