// 900-ToolInterface assembly — placement model.
// Places the roll stack (Roll Body, Roll Driver on its two 6703s, Span Mount with its strake) and the two
// XL-320s that turn it and the span, the interface every gripper mounts on, so it can be reviewed for fit
// by looking at it. A gripper's own assembly (920-ParallelGripper/gripper_assembly.scad) `use`s this file
// and places its parts on the Span Mount by sm_frame().
//
// FRAME. The Roll Body's own (911-001_RollBody.scad): the roll axis on +Z through the origin, its ring
// from z 3.5 to 16.5. ROLL turns the roll stack about it.
//
// PLACEMENT, each part by a feature it carries (specs/008.11):
//
//   - The Roll Driver's shaft in the two 6703s, its end flush with the far bearing (step 8): its shaft
//     z 8 .. 21 on the bearings' span z 3.5 .. 16.5, so its frame stands 4.5 lower.
//   - The 6703s in the Roll Body's seats, against the shoulder's faces (step 4).
//   - The Span Mount's ring foot (z -2.5) on the Roll Driver's end (its z 21), their M2 bolt circles at
//     r 6 on 45 deg in line (steps 7 and 17): its frame stands 19 higher.
//   - The strake in the Span Mount's slot, its top at the notch's top, z 26.2 (steps 1-2).
//   - The four M2 x 20 roll bolts threaded up through the Roll Driver (step 7), each head in C1 against
//     its floor, through the Span Mount's H1, with an M2 washer and nut in its K1 pocket on the pocket's
//     floor (steps 17-18). The file echoes how far each bolt ends above its nut.
//   - The four satin pins in the Roll Driver's P1, flush with its end and ~6 mm proud below N1 (steps
//     5-6).
//   - The roll XL-320 by its engagement with the Roll Driver (steps 20-21): its horn's four Ø4 holes on
//     N1's bosses put its axis on the roll axis and set the horn's turn, which rolls with the Roll
//     Driver; the case does not roll. Along the axis the Roll Body holds the case (step 22): its front
//     face on the three P1 bosses (z -0.5), its tab end inside F1's rim (line to line: the revised
//     Roll Body gives F1 no fit), its tab holes under H1. The file echoes how far the horn's face
//     stands under the Roll Driver's flange and the roll bolts' heads, and how far the satin pins
//     reach into the servo.
//   - The span XL-320's case on the Span Mount: its front face on V1's +X face, its side pads on F1
//     with N1's nubs in their rivet holes, its tab holes on H2, so that its axis is E1's (steps 25-26).
//     The nubs stand line to line in the holes and deeper than they are (../c102_servo.scad gives by
//     how much).
//     Its horn is off (step 24), and its spline is turned so that its teeth and key meet the Span
//     Driver's B1 and K2 as a gripper's assembly places the driver (step 36).
//   - The two M2 x 12 span bolts in H2 from V1's -X face, each head on its counterbore's floor, through
//     the servo's tab, with an M2 washer in the tab's back counterbore and a nut on it (step 26). The
//     file echoes how far each bolt ends beyond its nut, and how far each head stands proud of V1.
//
// NOT DRAWN. The Tool Interface Body (#900-001), which holds the roll XL-320's case (step 10). The case
// would now place it: S1, x -38.04 .. -14.04 in the body's frame, is the case's 24 depth, its floor
// (z -5) takes the case's near end and its 57 deg sides the end's chamfers, which puts the flange's
// axis (z 4, 9 above the floor) on the case's, the roll axis. F2's R16.5 bore then stands round the
// Roll Body's ring (Ø33) from its foot (z 3.5) to z 7.2 of this frame. The gripper and the Span
// Driver, which a gripper's assembly places. The fasteners into the parts not drawn: the Roll Body's
// M2 x 16 bolts (step 23). The Roll Body's two M2 x 12 bolts and nuts in H1 (step 22): under its head
// on H1's counterbore floor, an M2 x 12 ends short of the servo's tab, as the file echoes, so no
// placement draws it as the step lists it.
//
// GEOMETRY. The printed parts are the binary mesh cache `render.rs 900-ToolInterface --meshes` builds
// in out/asm/ (revised), so run it first. Bearings are drawn at catalogue size as three parts each
// (outer and inner race, shield): `part` draws one race alone, and PARTS lists only the whole bearing.
// The XL-320s are ../c102_servo.scad's placement model, each drawn as two parts: its case, and its
// output (the roll servo's horn, the span servo's bare spline), which turns on it.

use <../c102_servo.scad>

part = "all";   // "all", or one name from PARTS or RACE_PARTS for per-part export
ROLL = 0;       // roll angle, deg

$fn = 96;

// --- Features, each in its own part's frame ---------------------------------
RD_DROP     = 4.500;                     // #911-002 shaft z 8 on the #911-001 bearing span's z 3.5
RD_FLANGE   = 7.300;                     // #911-002 F1's underside
SM_RISE     = 19.000;                    // #912-001 ring foot z -2.5 on #911-002's end z 21
STRAKE      = [2.337, 5.588, 1.200, 26.200];   // C-502 across x and y in #912-001's frame, z span
B6703       = [17, 23, 4, [3.5, 12.5]];  // bore, OD, width, z of each in #911-001
B6703_RACES = [18.8, 21.2];              // inner race OD, outer race ID
ROLL_BOLT   = [2, 20, 3.8, 2, 9.295];    // M2 x 20 socket head (ISO 4762): d, length, head d, head h; under its head z in
                                         // #911-002: C1's floor, z 9.3 less the 0.005 its L4 laps down
M2_WASHER   = [2.2, 5, 0.3];             // M2 washer (DIN 125): bore, OD, thickness
M2_NUT      = [4, 1.6];                  // M2 nut (DIN 934): across flats, height
K1_FLOOR    = 2;                         // #912-001 K1's floor z, under each roll bolt's washer
PIN         = [1, -1.5, 21];             // satin pin #19: d, z span in #911-002 (~6 mm proud below N1, flush at the top)
PCD_R       = 6;                         // #911-002 B1 and P1, #912-001 H1 and K1
ROLL_SERVO  = -0.500;                    // C-102's front face on #911-001's P1 bosses (z -0.5 .. 0)
RB_CBORE    = 13.500;                    // #911-001 H1's counterbore floor, under an M2 x 12's head (step 22)
SPAN_SERVO  = [7.243, 14.139, 16.000];   // C-102's front face on #912-001 V1's +X face; its axis on E1's (y, z)
SPAN_TURN   = 235;                       // C-102's output turn: #912-002's K2 stands at 215 deg in its (x, z), which
                                         // is 90 - 215 = 235 deg in the servo's (x, y), and on one of B1's teeth
M2X12       = [2, 12, 3.8, 2];           // M2 x 12 socket head (ISO 4762): d, length, head d, head h
V1_T        = 3.500;                     // #912-001 V1's thickness, x 3.743 .. 7.243
H2_CBORE    = 1.750;                     // #912-001 H2's counterbore depth from V1's -X face
SPAN_HEAD_Z = V1_T - H2_CBORE;           // under a span bolt's head, z in the servo's frame

// --- Frames -----------------------------------------------------------------
module roll_frame() rotate(ROLL) children();
module rd_frame()   roll_frame() translate([0, 0, -RD_DROP]) children();
module sm_frame()   roll_frame() translate([0, 0, SM_RISE]) children();
// The C-102's frames: the roll servo's case is fixed, its horn rolls; the span servo rides the Span Mount,
// its output along -X of it.
module roll_servo_frame() translate([0, 0, ROLL_SERVO]) children();
module span_servo_frame() sm_frame() translate(SPAN_SERVO) rotate([0, -90, 0]) children();

// The span servo's case front face in #912-001's frame, for a gripper's assembly.
function span_servo_face() = SPAN_SERVO.x;

// --- Parts ------------------------------------------------------------------
module printed(id) import(str("out/asm/", id, ".stl"), convexity = 10);

module roll_body()      color("#d4ad6b") printed("911-001");
module roll_driver()    color("#2f6db5") rd_frame() printed("911-002");
module span_mount()     color("#e0a458") sm_frame() printed("912-001");
module strake()         color("#303030") sm_frame()
    translate([-STRAKE[0] / 2, -STRAKE[1] / 2, STRAKE[2]]) cube([STRAKE[0], STRAKE[1], STRAKE[3] - STRAKE[2]]);

module roll_servo()  color("#3c4250") roll_servo_frame() c102_case();
module roll_horn()   color("#9aa3ad") roll_frame() roll_servo_frame() c102_horn(0);
module span_servo()  color("#3c4250") span_servo_frame() c102_case();
module span_spline(span = 0) color("#9aa3ad") span_servo_frame() c102_spline(SPAN_TURN + span);

module tube(od, id, h) difference() { cylinder(d = od, h = h); translate([0, 0, -1]) cylinder(d = id, h = h + 2); }

module washer() difference() {
  cylinder(d = M2_WASHER[1], h = M2_WASHER[2], $fn = 96);
  translate([0, 0, -1]) cylinder(d = M2_WASHER[0], h = M2_WASHER[2] + 2, $fn = 72);
}
module nut() difference() {
  cylinder(d = M2_NUT[0] / cos(30), h = M2_NUT[1], $fn = 6);
  translate([0, 0, -1]) cylinder(d = ROLL_BOLT[0], h = M2_NUT[1] + 2, $fn = 72);
}

// Fasteners on the roll bolt circle (steps 5-7 and 17-18): drawn at the facet counts and phase of the
// holes they stand in, so a pin or a thread in its own hole meets it line to line.
module at_pcd(start) for (a = [start : 90 : start + 270]) rotate(a) translate([PCD_R, 0, 0]) children();

// A bolt is two parts, its head and its shank, so that the shank's thread in B1 can be engaged while
// the head is still held to its clearance in C1.
module roll_bolt_heads() color("#8a8f94") rd_frame() at_pcd(45)
  translate([0, 0, ROLL_BOLT[4] - ROLL_BOLT[3]]) cylinder(d = ROLL_BOLT[2], h = ROLL_BOLT[3], $fn = 72);
module roll_bolt_shanks() color("#8a8f94") rd_frame() at_pcd(45)
  translate([0, 0, ROLL_BOLT[4]]) cylinder(d = ROLL_BOLT[0], h = ROLL_BOLT[1], $fn = 72);
module roll_washers() color("#b0b4b8") sm_frame() at_pcd(45) translate([0, 0, K1_FLOOR]) washer();
module roll_nuts() color("#8a8f94") sm_frame() at_pcd(45) translate([0, 0, K1_FLOOR + M2_WASHER[2]]) nut();
module roll_pins() color("#c0c0c0") rd_frame() at_pcd(0) translate([0, 0, PIN[1]]) cylinder(d = PIN[0], h = PIN[2] - PIN[1], $fn = 48);

// The span bolts (step 26), in the span servo's frame, its +Z out through V1: in the tab's two outer
// holes, each washer on the floor of the tab's back counterbore.
SPAN_WASHER_Z = c102_plate()[2] - c102_plate()[0];   // the back counterbore's floor
module at_span_holes() for (h = [c102_tab_holes()[1], c102_tab_holes()[2]]) translate(h) children();
module span_bolt_heads() color("#8a8f94") span_servo_frame() at_span_holes()
  translate([0, 0, SPAN_HEAD_Z]) cylinder(d = M2X12[2], h = M2X12[3], $fn = 72);
module span_bolt_shanks() color("#8a8f94") span_servo_frame() at_span_holes()
  translate([0, 0, SPAN_HEAD_Z - M2X12[1]]) cylinder(d = M2X12[0], h = M2X12[1], $fn = 72);
module span_washers() color("#b0b4b8") span_servo_frame() at_span_holes()
  translate([0, 0, SPAN_WASHER_Z - M2_WASHER[2]]) washer();
module span_nuts() color("#8a8f94") span_servo_frame() at_span_holes()
  translate([0, 0, SPAN_WASHER_Z - M2_WASHER[2] - M2_NUT[1]]) nut();

RACES = ["outer", "inner", "shield"];

// One race of a bearing b = [bore, OD, width, ...] whose races are [inner race OD, outer race ID], with
// its axis on +Z from z 0. A gripper's assembly draws its own bearings with this.
module race(b, races, race) {
  if (race == "outer")  tube(b[1], races[1], b[2]);
  if (race == "inner")  tube(races[0], b[0], b[2]);
  if (race == "shield") translate([0, 0, 0.5]) tube(races[1], races[0], b[2] - 1);
}

BEARINGS = ["roll_lower", "roll_upper"];
RACE_PARTS = [for (b = BEARINGS, r = RACES) str(b, "_", r)];   // `part` only, not in PARTS

module bearing_in(b, r, $fn = 360) {   // at 96 a race's chords stand inside its seat's circle
  if (b == "roll_lower") translate([0, 0, B6703[3][0]]) race(B6703, B6703_RACES, r);
  if (b == "roll_upper") translate([0, 0, B6703[3][1]]) race(B6703, B6703_RACES, r);
}
module bearing(b) color("#dcdcdc") for (r = RACES) bearing_in(b, r);

PARTS = ["roll_body", "roll_driver", "span_mount", "strake", "roll_lower", "roll_upper",
         "roll_bolt_heads", "roll_bolt_shanks", "roll_washers", "roll_nuts", "roll_pins",
         "roll_servo", "roll_horn", "span_servo", "span_spline",
         "span_bolt_heads", "span_bolt_shanks", "span_washers", "span_nuts"];

// For a gripper's assembly, which sees this file's modules and functions but not its variables.
function tool_parts() = PARTS;
function tool_race_parts() = RACE_PARTS;

// One part; `span` turns the span servo's output on from SPAN_TURN, deg, as a gripper turns its driver.
module tool_draw(p, span = 0) {
  if (p == "roll_bolt_heads")  roll_bolt_heads();
  if (p == "roll_bolt_shanks") roll_bolt_shanks();
  if (p == "roll_washers")   roll_washers();
  if (p == "roll_nuts")      roll_nuts();
  if (p == "roll_pins")      roll_pins();
  if (p == "roll_body")      roll_body();
  if (p == "roll_driver")    roll_driver();
  if (p == "span_mount")     span_mount();
  if (p == "strake")         strake();
  if (p == "roll_servo")     roll_servo();
  if (p == "roll_horn")      roll_horn();
  if (p == "span_servo")     span_servo();
  if (p == "span_spline")    span_spline(span);
  if (p == "span_bolt_heads")  span_bolt_heads();
  if (p == "span_bolt_shanks") span_bolt_shanks();
  if (p == "span_washers")   span_washers();
  if (p == "span_nuts")      span_nuts();
  for (b = BEARINGS) if (p == b) bearing(b);
  for (b = BEARINGS, r = RACES) if (p == str(b, "_", r)) color("#dcdcdc") bearing_in(b, r);
}

HORN_TOP = ROLL_SERVO + c102_output_h();   // the roll servo's horn face, in this frame

echo(roll_bolt_past_nut = (ROLL_BOLT[4] + ROLL_BOLT[1] - RD_DROP) - (SM_RISE + K1_FLOOR + M2_WASHER[2] + M2_NUT[1]));
echo(horn_under_flange = RD_FLANGE - RD_DROP - HORN_TOP);                // the horn's face, under F1's underside
echo(horn_under_roll_heads = (ROLL_BOLT[4] - ROLL_BOLT[3] - RD_DROP) - HORN_TOP);
echo(pins_in_roll_servo = ROLL_SERVO - (PIN[1] - RD_DROP));              // past the case's front face
echo(rb_bolt_short_of_tab = (RB_CBORE - M2X12[1]) - (ROLL_SERVO - c102_plate()[0]));   // an M2 x 12 in H1
echo(span_bolt_past_nut = (SPAN_WASHER_Z - M2_WASHER[2] - M2_NUT[1]) - (SPAN_HEAD_Z - M2X12[1]));
echo(span_heads_proud = M2X12[3] - H2_CBORE);   // past V1's -X face, out of H2's counterbore

for (p = PARTS) if (part == "all" || part == p) tool_draw(p);
for (p = RACE_PARTS) if (part == p) tool_draw(p);
