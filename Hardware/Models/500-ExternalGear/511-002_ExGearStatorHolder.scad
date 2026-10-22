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
//                         (../600-StrainWave/c201_spline_seat.scad). The rim
//                         is lowered by FLOOR_DROP toward the spigot. The
//                         floor stands DRIVE_RISE beyond where that would put
//                         it, on a boss inside the Mount Top's 6810, so it
//                         carries no recess: the pilot alone centres the
//                         spline. The spigot's end is counterbored over the
//                         Flex Spline Attach's land. What sets all three is
//                         recorded in exgear_assembly.scad.
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
// 4.0 keys to 34.1, both at 45 deg pitch). The z -8.333 and -3.667 planes a
// histogram reports are tessellation rows on the peg bores, not faces.
//
// FITS (../print_fit.scad), revised only:
//
//     core and keys, in the gear's socket   slip, both being printed: the
//                                           core, the keys' sides and their
//                                           flat tops each stand in by it.
//                                           The keys carry J3's output
//                                           torque, so their play is the
//                                           joint's backlash
//     pilot, on the spline's step           press, and the seat's nut
//                                           pockets slip:
//                                           c201_spline_seat.scad
//     boss, inside the 6810's bore          running, though both turn
//     end counterbore, over the Attach's    running: the Attach is fixed
//       land                                and the holder turns
//
// The keys' end chamfers keep their plane, r + z = 44.5, because their
// bottoming in the slots' chamfers is the seat. The key's flat simply ends
// higher on it, so the seat, the floor and every stack value
// exgear_assembly.scad echoes are the same at any clearance.

include <../print_fit.scad>
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
FLOOR_DROP    = 1.000;     // revised: the rim this much toward the seat
DRIVE_RISE    = 4.000;     // revised: the floor this much further from the seat than the rim's drop puts it (DC-600-2)
ATTACH_LAND_D = 50.000;    // #630-005's land, under the spigot's end
END_CUT       = 2.000;     // revised: the counterbore over it, deep
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
function stator_floor(cfg = config) = cfg == "previous" ? FLOOR : FLOOR + FLOOR_DROP - DRIVE_RISE;
function stator_rim(cfg = config) = cfg == "previous" ? RIM : RIM + FLOOR_DROP;
function stator_end() = END;
// The face over the Attach: the spigot's end, or the revised counterbore's floor.
function stator_clear(cfg = config) = cfg == "previous" ? END : END - END_CUT;

// The keys' end chamfer, as the r + z its plane keeps.
CHAMFER_PLANE = KEY[1] + END - KEY_CHAMFER;

function slip(cfg) = fit_clearances(cfg)[0];
function press(cfg) = fit_clearances(cfg)[1];
function run(cfg) = fit_clearances(cfg)[2];

// --- Body -------------------------------------------------------------------
// The turned body: bore, recess (or the revised boss), cylinder, cone, core.
// The floor's edge: the recess wall, or the boss's side a running clearance
// inside the spline's flange, which is the 6810's bore.
function floor_r(cfg) = cfg == "previous" ? RECESS_D / 2 : spline_flange()[0] / 2 - run(cfg);
module body(cfg) {
    fl = stator_floor(cfg);
    rim = stator_rim(cfg);
    wall_r = floor_r(cfg);
    core = CORE_R - slip(cfg);
    rotate_extrude() polygon([
        [BORE_D / 2, END], [BORE_D / 2, fl], [wall_r, fl], [wall_r, rim],
        [BODY_R, rim], [BODY_R, CONE_TOP], [core, CONE_TOP + BODY_R - core], [core, END]]);
}

// Everything beyond the cone's surface carried on past the core: the keys
// stand on the core there and are cut off by the cone toward the recess.
// Carried epsilon inward, so the keys overlap the body rather than touch it.
module beyond_cone()
    rotate_extrude() polygon([
        [BODY_R + 1 - epsilon, CONE_TOP - 1], [BODY_R + 2, CONE_TOP - 1], [BODY_R + 2, END + 1],
        [BODY_R + CONE_TOP - END - 1 - epsilon, END + 1]]);

// One key on +X: the flat and its end chamfer, extruded across its width,
// each standing in from the slot by the clearance c.
module key(c)
    rotate([90, 0, 0]) linear_extrude(2 * (KEY[0] - c), center = true) polygon([
        [CORE_R - 1, CONE_TOP], [KEY[1] - c, CONE_TOP], [KEY[1] - c, CHAMFER_PLANE - KEY[1] + c],
        [CHAMFER_PLANE - END, END], [CORE_R - 1, END]]);

module keys(cfg) intersection() { for (a = [0 : 45 : 315]) rotate(a) key(slip(cfg)); beyond_cone(); }

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
        difference() { union() { body(cfg); keys(cfg); pegs(); } peg_cuts(); screw_cuts(); }
    else
        // The seat's frame has its floor facing +Z; this part's faces -Z.
        // The nut pockets open into the counterbore.
        difference() {
            union() { body(cfg); keys(cfg); }
            translate([0, 0, stator_floor(cfg)]) mirror([0, 0, 1])
                spline_seat_cuts(stator_clear(cfg) - stator_floor(cfg), press(cfg), slip(cfg));
            translate([0, 0, stator_clear(cfg)])
                cylinder(d = fit_bore(ATTACH_LAND_D, run(cfg)), h = END_CUT + 1);
        }
}

ex_gear_stator_holder();
echo(seat_floor = stator_floor());
