// 300-Pivot assembly — placement model.
// Places the Main Pivot, the Pivot Code Disk on its J2 drum, the Base Motor End Cap on its J1 end
// and the Pivot Motor End Cap on its J2 end, each cap with the 6810 on its land and the C-101 on
// its seat, so the pivot can be reviewed for fit by looking at it.
//
// FRAME. The Main Pivot's own (300-001_MainPivot.scad): J1 on +Z through the origin, its base face
// at z = 0, J2 parallel to +X at z J2_Z, the J2 end face at x J2_END_X.
//
// PLACEMENT, each part by a feature it carries:
//
//   - The Base Motor End Cap's top face on the Main Pivot's base face, z 0, its body below: its
//     land, z 3.5 .. 10.5 in its own frame, is the 6810's width, so the bearing stands on the
//     pivot's land, as base_assembly.scad has it. The cap is turned 180° about J1 from that
//     file's frame, which turns the pivot 180° to put it in the Pivot Skirt. 008.4 step 6 leaves
//     this cap's turn free, since its wire hole is centred.
//   - The Pivot Motor End Cap's top face on the J2 end face, its body beyond it along +X. Its
//     wire channel, on +X in its own frame, is turned about J2 toward the cable hole (H2) that
//     opens in the end face (008.4 step 6), as near as its motor holes allow: their M3 screws
//     run on into the pivot's H5, so the turn is 45° + k·90°, 6.2° short of H2's direction.
//     The channel still opens into the Ø12 hole.
//   - The Pivot Code Disk on the J2 drum, its hub's top on the pivot's X_FACE and its flat face
//     away from the body (008.4 step 5). Nothing fixes its turn about J2, so it keeps its own
//     frame's, its first slit toward the world's +Z.
//   - Each 6810 on its cap's land, flush with the cap's top face; each C-101's rear on its cap's
//     seat, its body beyond it.
//
// GEOMETRY. The printed parts are the binary mesh cache `render.rs 300-Pivot --meshes` builds in
// out/asm/, so run it first. A `use`d file keeps its own `config`. Vendor parts are envelopes at
// catalogue size.
//
// CLASH. The whole assembly is checked by assembly-clash.rs against pivot_assembly.clash.json. A
// bearing there is three parts, <bearing>_inner, _outer and _shield, which `part` draws one at a
// time and PARTS does not list. The outer races stand in the housings that hold them: J1's in the
// Base Long, which does not turn with the pivot, and J2's in the Arm Body, which does turn about
// J2.

use <../c101_motor.scad>
use <311-001_MotorEndCapBase.scad>

part = "all";   // "all", or one name from PARTS for per-part export

$fn = 96;

// --- Features, each in its own part's frame ---------------------------------
J2_Z         = 37.500;                   // #300-001 J2 axis above the base face
X_FACE       = 35.500;                   // #300-001 the J2 end's +X body face, which the disk's hub meets
J2_END_X     = 55.000;                   // #300-001 the J2 drum's end face
CABLE_YZ     = [-9.350, 45.016];         // #300-001 H2, where it opens in the end face
CAP_LAND     = cap_land();               // #311-001 and #312-001: the 6810's journal, up to the top face
CAP_TOP      = CAP_LAND[1];
CAP_SEAT     = cap_seat();               // the motor's rear; the revised seat stands the press clearance above it
HUB_HEIGHT   = 6.200;                    // #300-002 H1: the hub's top above the flat face
B6810        = [50, 65, 7];
B6810_FN     = 360;                      // facets: at 96 the Ø50 bore's chords stand inside the circle,
                                         // more than the clash check's facet slack
BASE_TURN    = 180;                      // #311-001 about J1, as base_assembly.scad turns the pivot
H2_TURN      = atan2(-CABLE_YZ[0], CABLE_YZ[1] - J2_Z);   // about J2, up at 0: H2's direction
CABLE_TURN   = 45 + 90 * round((H2_TURN - 45) / 90);      // the channel nearest H2 with the motor holes on H5

// --- Frames -----------------------------------------------------------------
// Each cap's own frame carried onto the pivot: the top face on the pivot's face, the cap beyond it.
module j1_cap_frame() translate([0, 0, -CAP_TOP]) rotate(BASE_TURN) children();
module j2_cap_frame() translate([J2_END_X + CAP_TOP, 0, J2_Z]) rotate([CABLE_TURN, 0, 0]) rotate([0, -90, 0]) children();
module disk_frame()   translate([X_FACE + HUB_HEIGHT, 0, J2_Z]) rotate([0, -90, 0]) children();

echo(cable_turn = CABLE_TURN, h2_turn = round(H2_TURN * 10) / 10);
echo(j2_motor_rear_x = J2_END_X + CAP_TOP - CAP_SEAT);

// --- Parts ------------------------------------------------------------------
module printed(id) import(str("out/asm/", id, ".stl"), convexity = 10);

module pivot()      color("#d4ad6b") printed("300-001");
module code_disk()  color("#2f6db5") disk_frame() printed("300-002");
module j1_cap()     color("#e0a458") j1_cap_frame() printed("311-001");
module j2_cap()     color("#c98a3a") j2_cap_frame() printed("312-001");

module motor() translate([0, 0, CAP_SEAT]) rotate([180, 0, 0]) c101_motor_envelope(c101_len());
module j1_motor() color("#50565c") j1_cap_frame() motor();
module j2_motor() color("#50565c") j2_cap_frame() motor();

module tube(od, id, h) difference() { cylinder(d = od, h = h); translate([0, 0, -1]) cylinder(d = id, h = h + 2); }

RACES = ["outer", "inner", "shield"];

// One 6810's race, in its cap's frame, on the cap's land.
module bearing_race(race, $fn = B6810_FN) translate([0, 0, CAP_LAND[0]]) {
  if (race == "outer")  tube(B6810[1], 60.5, B6810[2]);
  if (race == "inner")  tube(54.5, B6810[0], B6810[2]);
  if (race == "shield") translate([0, 0, 0.6]) tube(60.5, 54.5, B6810[2] - 1.2);
}

BEARINGS = ["bearing_j1", "bearing_j2"];
RACE_PARTS = [for (b = BEARINGS, r = RACES) str(b, "_", r)];   // `part` only, not in PARTS

module bearing_in(b, race) {
  if (b == "bearing_j1") j1_cap_frame() bearing_race(race);
  if (b == "bearing_j2") j2_cap_frame() bearing_race(race);
}
module bearing(b) color("#dcdcdc") for (r = RACES) bearing_in(b, r);

PARTS = ["pivot", "code_disk", "j1_cap", "j2_cap", "j1_motor", "j2_motor", "bearing_j1", "bearing_j2"];

module draw(p) {
  if (p == "pivot")      pivot();
  if (p == "code_disk")  code_disk();
  if (p == "j1_cap")     j1_cap();
  if (p == "j2_cap")     j2_cap();
  if (p == "j1_motor")   j1_motor();
  if (p == "j2_motor")   j2_motor();
  if (p == "bearing_j1") bearing("bearing_j1");
  if (p == "bearing_j2") bearing("bearing_j2");
  for (b = BEARINGS, r = RACES) if (p == str(b, "_", r)) color("#dcdcdc") bearing_in(b, r);
}

for (p = PARTS) if (part == "all" || part == p) draw(p);
for (p = RACE_PARTS) if (part == p) draw(p);
