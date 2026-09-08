// #110-004 Base Mounting Plate — parametric source (DC-4).
//
// The plate that fixes the robot to the world: a flat metal square bolted to
// the Base Mount Bottom on one face and through to a bench on the other.
//
// Unlike the 700-Differential sources, this part is AUTHORED, not recreated.
// There is no reference mesh to compare against, because the design has never
// had this part — the previous version stood on six printed feet, and the
// bolted base replaced them with a plate that was specified but never drawn.
// So the checks here are not "does it match a reference"; they are "does it
// still mate with the part it bolts to", which is the only thing about it that
// is not a free choice.
//
// Material, thickness, footprint, and both hole patterns are specified in
// `specs/004-Mechanical-Architecture.md` § Base mounting plate. That document
// owns them; this file reads them off it and must be re-derived if they move.
//
// The robot-side pattern is not a free choice: it is measured off
// HDI-110-001_BaseMountBottom, whose flange presents eight Ø6.000 mm holes in
// pairs on its four edges. `check.rs` asserts the centres below against that
// part's own mesh, so an edit that moves a hole fails rather than quietly
// producing a plate that will not bolt on.
//
// Origin: the J1 axis, on the plate's TOP face (the face the robot sits on),
// so the plate occupies z -THICKNESS .. 0 and the hole coordinates below are
// stated in the same frame 004 states them in.

// ---------------------------------------------------------------- parameters

// Plate. 6061-T6 at 9.5 mm (3/8"); 004 gives ~6 mm as the steel equivalent.
FOOTPRINT = 200.0;   // square, per 004
THICKNESS = 9.5;     // 3/8" aluminium

// Robot-side pattern — 8 holes, tapped M5 through, measured off the CAD part.
// Each pair sits on one edge of the mount's 150 mm flange: two holes 25.000 mm
// apart, 62.500 mm out from the axis. The pattern is symmetric under a 90°
// rotation, so the robot can be indexed a quarter turn on its plate.
ROBOT_OUT   = 62.500;  // distance from the J1 axis to the pair's edge
ROBOT_HALF  = 12.500;  // half the spacing within a pair
ROBOT_TAP   = 4.200;   // M5 tap drill (0.8 mm pitch: 5.0 - 0.8)

// Work-surface pattern — 4 × M6 clearance near the corners. 004 requires them
// outboard of the robot-side pattern and near the corners; this file fixes
// them at 15.0 mm from each edge, which clears the 150 mm flange by 10.0 mm
// on the diagonal and leaves a socket wrench room outside the base.
BENCH_OUT   = FOOTPRINT / 2 - 15.0;  // 85.000
BENCH_CLEAR = 6.600;                 // M6 medium clearance, ISO 273

// Central clearance. The mount's Ø20.000 bore carries the J1 wiring through;
// the plate opens it out so the harness turns without chafing on a cut edge.
CENTRE_BORE = 26.0;

$fn = 96;

// ------------------------------------------------------------------ geometry

// The eight robot-side centres, generated rather than listed, so that the
// 90°-symmetry the pattern relies on cannot be broken by a typo in one row.
function robot_holes() = [
    for (q = [0 : 3], s = [-1, 1])
        let (a = q * 90)
        [ROBOT_OUT * cos(a) - s * ROBOT_HALF * sin(a),
         ROBOT_OUT * sin(a) + s * ROBOT_HALF * cos(a)]
];

function bench_holes() = [for (sx = [-1, 1], sy = [-1, 1])
                              [sx * BENCH_OUT, sy * BENCH_OUT]];

module plate_blank() {
    translate([0, 0, -THICKNESS])
        cube([FOOTPRINT, FOOTPRINT, THICKNESS], center = false);
}

// Every hole goes right through, so each cutter overhangs both faces. Nothing
// here is bounded on a surface the plate already has — a cutter that ends
// exactly on a face leaves coincident planes that preview as speckle.
module through_hole(d) {
    translate([0, 0, -THICKNESS - 1])
        cylinder(d = d, h = THICKNESS + 2);
}

module base_mounting_plate() {
    difference() {
        translate([-FOOTPRINT / 2, -FOOTPRINT / 2, 0]) plate_blank();
        for (p = robot_holes()) translate([p[0], p[1], 0]) through_hole(ROBOT_TAP);
        for (p = bench_holes()) translate([p[0], p[1], 0]) through_hole(BENCH_CLEAR);
        through_hole(CENTRE_BORE);
    }
}

// ---------------------------------------------------------------------- part

// `PROJECT=1` emits the machining drawing instead of the solid:
//   openscad -D PROJECT=1 -o 110-004_BaseMountingPlate.dxf <this file>
PROJECT = 0;

if (PROJECT) projection(cut = false) base_mounting_plate();
else base_mounting_plate();
