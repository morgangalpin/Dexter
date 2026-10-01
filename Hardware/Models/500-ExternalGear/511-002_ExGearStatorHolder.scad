// #511-002 Ex Gear Stator Holder — parametric source.
// Carries J3's circular spline on the External Gear. Its keyed spigot goes
// into the gear's notched end and turns it; its recess, facing away from the
// gear, takes the spline, which turns with it inside the Mount Top's 6810.
//
//   config = "previous" — faithful recreation of the reference mesh
//                         (../Reference/meshes/500-ExternalGear/).
//   config = "revised"  — seats the C-201 circular spline: the pegs and the
//                         two screw holes, laid out for a different drive,
//                         give way to the shared spline seat
//                         (../600-StrainWave/c201_spline_seat.scad), and the
//                         floor and rim are lowered by FLOOR_DROP toward the
//                         spigot. What sets FLOOR_DROP is recorded in
//                         exgear_assembly.scad.
//
// FRAME. The reference's own: the axis on +Z, the recess opening toward -Z.
// The seat is z = 4.000: there the 45 deg cone between the keys meets the
// R32.5 core, which is the gear's end face when every key's end chamfer
// bottoms in its slot's. The recess floor is at z = -4.000, the rim at
// -7.000, the spigot's end at 12.000.
//
// Measured from the reference (scadmesh slice/arcs/profile, meridians by
// transform --rz). Everything is fourfold about the axis except the screw
// holes, which are twofold:
//
//     feature                      value                  z span
//     body                         R36.977                -7 .. -0.477
//     cone                         45 deg, R36.977 to R32.5   -0.477 .. 4
//     core                         R32.5                  4 .. 12
//     keys, 8 on 45 deg            4.0 wide, flat tops 34.1 off the axis;
//                                  ends chamfered 45 deg to R32.5 at z 12;
//                                  cut off above by the cone, which is
//                                  where the z 2.341 edge comes from
//                                  (the flat's corners, 34.159 out)
//                                                         2.341 .. 12
//     recess                       Ø50.0                  -7 .. -4
//     bore                         Ø36.0                  -4 .. 12
//     pegs, 4 on 90 deg, Ø43       Ø3.5, Ø2.0 through     -13 .. -4
//     their counterbores           Ø4.0                   1 .. 12
//     screw holes, 45 / 225 deg,   Ø3.0                   -4 .. 5
//       Ø43
//     their counterbores           Ø5.6                   5 .. 12
//
// The keys' section is the gear's socket to the micrometre (R32.5 core, eight
// 4.0 keys to 34.1, both at 45 deg pitch), so both configs keep it. The z
// -8.333 and -3.667 planes a histogram reports are tessellation rows on the
// peg bores, not faces.

use <../600-StrainWave/c201_spline_seat.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]

/* [Hidden] */
$fn = 144;
epsilon = 0.01;

SEAT          = 4.000;     // on the gear's end face
FLOOR         = -4.000;    // previous recess floor
RIM           = -7.000;    // previous rim
END           = 12.000;    // spigot's end
FLOOR_DROP    = 1.000;     // revised: floor and rim this much toward the seat
BODY_R        = 36.977;
CONE_TOP      = -0.477;    // where the cone leaves R36.977
CORE_R        = 32.500;
KEY           = [2.000, 34.100];   // half-width, flat's distance from the axis
KEY_CHAMFER   = 1.600;     // 45 deg, at the key's end
RECESS_D      = 50.000;
BORE_D        = 36.000;
PEG_CIRCLE_R  = 21.500;
PEG           = [3.500, 2.000, -13.000];   // OD, bore, top
PEG_CBORE     = [4.000, 1.000];    // Ø, floor
SCREW         = [3.000, 5.600, 5.000];     // hole Ø, counterbore Ø, counterbore floor

function stator_seat() = SEAT;
function stator_floor(cfg = config) = cfg == "previous" ? FLOOR : FLOOR + FLOOR_DROP;
function stator_rim(cfg = config) = cfg == "previous" ? RIM : RIM + FLOOR_DROP;
function stator_end() = END;

// --- Body -------------------------------------------------------------------
// The turned body: bore, recess, cylinder, cone, core.
module body(cfg) {
    fl = stator_floor(cfg);
    rim = stator_rim(cfg);
    rotate_extrude() polygon([
        [BORE_D / 2, END], [BORE_D / 2, fl], [RECESS_D / 2, fl], [RECESS_D / 2, rim],
        [BODY_R, rim], [BODY_R, CONE_TOP], [CORE_R, CONE_TOP + BODY_R - CORE_R], [CORE_R, END]]);
}

// Everything beyond the cone's surface carried on past the core: the keys
// stand on the core there and are cut off by the cone toward the recess.
// Carried epsilon inward, so the keys overlap the body rather than touch it.
module beyond_cone()
    rotate_extrude() polygon([
        [BODY_R + 1 - epsilon, CONE_TOP - 1], [BODY_R + 2, CONE_TOP - 1], [BODY_R + 2, END + 1],
        [BODY_R + CONE_TOP - END - 1 - epsilon, END + 1]]);

// One key on +X: the flat and its end chamfer, extruded across its width.
module key()
    rotate([90, 0, 0]) linear_extrude(2 * KEY[0], center = true) polygon([
        [CORE_R - 1, CONE_TOP], [KEY[1], CONE_TOP], [KEY[1], END - KEY_CHAMFER],
        [KEY[1] - KEY_CHAMFER, END], [CORE_R - 1, END]]);

module keys() intersection() { for (a = [0 : 45 : 315]) rotate(a) key(); beyond_cone(); }

// --- Previous-only features ---------------------------------------------------
module pegs() for (a = [0 : 90 : 270]) rotate(a) translate([PEG_CIRCLE_R, 0, PEG[2]])
    cylinder(d = PEG[0], h = FLOOR - PEG[2] + epsilon, $fn = 48);

module peg_cuts() for (a = [0 : 90 : 270]) rotate(a) translate([PEG_CIRCLE_R, 0, 0]) {
    translate([0, 0, PEG[2] - epsilon]) cylinder(d = PEG[1], h = PEG_CBORE[1] - PEG[2] + 2 * epsilon, $fn = 48);
    translate([0, 0, PEG_CBORE[1]]) cylinder(d = PEG_CBORE[0], h = END - PEG_CBORE[1] + epsilon, $fn = 48);
}

module screw_cuts() for (a = [45, 225]) rotate(a) translate([PEG_CIRCLE_R, 0, 0]) {
    translate([0, 0, FLOOR - epsilon]) cylinder(d = SCREW[0], h = SCREW[2] - FLOOR + 2 * epsilon, $fn = 48);
    translate([0, 0, SCREW[2]]) cylinder(d = SCREW[1], h = END - SCREW[2] + epsilon, $fn = 48);
}

// --- Part ---------------------------------------------------------------------
module ex_gear_stator_holder(cfg = config) {
    if (cfg == "previous")
        difference() { union() { body(cfg); keys(); pegs(); } peg_cuts(); screw_cuts(); }
    else
        // The seat's frame has its recess on +Z; this part's opens toward -Z.
        difference() {
            union() { body(cfg); keys(); }
            translate([0, 0, stator_floor(cfg)]) mirror([0, 0, 1])
                spline_seat_cuts(END - stator_floor(cfg));
        }
}

ex_gear_stator_holder();
echo(seat_floor = stator_floor());
