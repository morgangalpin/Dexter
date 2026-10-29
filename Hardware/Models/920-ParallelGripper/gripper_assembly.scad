// 920-ParallelGripper assembly — placement model.
// Places the parallel gripper on the tool interface: the Static Finger on the Span Mount, the Pinion Gear
// and the Pinion Bearing EXT on their two MR128s in the Static Finger's hub, the Span Driver in the
// Pinion Gear's drive slot, the M3 bolt and nut that join the pinion and the EXT, and the Dynamic Finger
// in the Static Finger's T-slot, meshed with the pinion. The tool interface itself, with the span
// XL-320 the Span Driver stands on, is ../900-ToolInterface/tool_assembly.scad's, drawn through its
// modules.
//
// FRAME. The tool interface's: the Roll Body's, the roll axis on +Z. Every part of this group stands in
// the Static Finger's frame, which is the grip frame (tool_assembly.scad's grip_frame()); the hub's axis
// runs along its +Y through HUB, the span axis.
//
// PLACEMENT, each part by a feature it carries (specs/008.11 steps 36-47):
//
//   - The Static Finger's socket over the Span Mount's column, its ceiling on the column's top and its
//     slot on the upright plate (step 46): the socket is the column's section turned -90 deg about Z,
//     so its frame is the Span Mount's turned +90 deg and 1.5 lower. Its hub then stands on the Span
//     Mount's eye axis, and its plate slot stands over the span XL-320's case and pads.
//   - The MR128s on the EXT's journal and in the Static Finger's seats (step 41): the journal (#920-006
//     J1) is 7.5 long, the two bearings' widths and the 0.5 shoulder between the seats, so each bearing
//     stands against the shoulder.
//   - The Pinion Gear on the hub's axis, its top face (z 6.0) on the EXT's spacer collar, whose far face
//     is the inner MR128's: the pinion's z runs along +Y, 3.507 on, and its drive slot opens toward -Z
//     of this frame, the side the Span Driver's head is flat on (steps 42 and 44).
//   - The EXT's keyed nose in the pinion's key recess, point to point (step 43): its y runs along +Y,
//     10.007 on, its hash mark on +Z.
//   - The Span Driver's head in the pinion's drive slot, its end on the slot's ceiling (z -2 of the
//     pinion): its y runs along +Y, 11.493 back (step 36-37 set it on the servo's spline). The span
//     XL-320, which tool_assembly.scad draws, does not agree. Its spline's axis is the driver's, and
//     its teeth and key stand in B1's and K2's, but B1's mouth stands inside the servo's case, so only
//     the spline's root is in B1 and the rest of it stands in the driver's collar beyond B1, as the
//     file echoes. Seated with B1's mouth on the case's face, the driver would stand that depth further
//     along +Y and its head would end as far past the slot's ceiling, so the driver, the pinion's slot
//     and the servo cannot all stand as drawn. The servo's output turns with the driver (OPEN).
//   - The M3 nut against its trap's ceiling (step 40), and the M3 x 16 bolt's head on the EXT's end
//     face, its shank through the EXT and the pinion into the nut (step 43).
//   - The Dynamic Finger in the T-slot, its rack's pitch line on the pinion's pitch circle: its own frame
//     is not this one, and the move between them with the gripper closed (the two gripping faces meeting,
//     without pads) is its header's FRAME paragraph's. OPEN moves it along +X from there. Closed, one of
//     the pinion's teeth points along +Z into a gap of the rack, 0.010 off the gap's centre.
//
// NOT DRAWN. The satin pins of steps 38-39: the 2020-03-12 STEP of the Pinion Gear has no holes for
// them. The M2.6 x 10 bolt that holds the Span Driver on the servo's spline (step 37); the grip pads
// (step 48).
//
// GEOMETRY. The printed parts are the binary mesh caches `render.rs 900-ToolInterface --meshes` and
// `render.rs 920-ParallelGripper --meshes` build in each group's out/asm/ (revised), so run both first.
// Bearings are drawn at catalogue size as three parts each (outer and inner race, shield): `part` draws
// one race alone, and PARTS lists only the whole bearing.

use <../900-ToolInterface/tool_assembly.scad>
use <../900-ToolInterface/span_socket.scad>
use <../c102_servo.scad>

part = "all";   // "all", or one name from PARTS or RACE_PARTS for per-part export
OPEN = 0;       // the Dynamic Finger's travel from its drawn position, mm along the T-slot

$fn = 96;

// --- Features, each in its own part's frame ---------------------------------
HUB         = span_axis();               // #920-001 hub axis (x, z), along +Y
MR128       = [8, 12, 3.5, [10.007, 14.007]];  // bore, OD, width, y of each in #920-001
MR128_RACES = [9.2, 10.8];
PINION_Y    = 3.507;                     // #920-005 z 0 along +Y: its top (z 6.0) on the EXT's spacer at y 9.507
EXT_Y       = 10.007;                    // #920-006 y 0 (its shoulder, the inner MR128's face)
DRIVER_Y    = span_driver_y();           // #912-002 y 0: its head's end (y 13) on #920-005 D1's ceiling (z -2)
DRIVER_B1   = [2.175, 5.325];            // #912-002 B1's y span, its mouth first
M3_BOLT     = [3, 16, 5.5, 3, 8.5];      // M3 x 16 socket head (ISO 4762): d, length, head d, head h; under its head y in #920-006
M3_NUT      = [5.5, 2.4, 1.3];           // M3 nut (DIN 934): across flats, height; its top z in #920-005 (N1's ceiling)
RACK        = [18.272, 3.257, 28];       // #920-002's frame in #920-001's, closed: its pitch line z 0 on z 28
PITCH_R     = 10.500;                    // #920-005's pitch circle, the rack's pitch line above HUB

// --- Frames -----------------------------------------------------------------
module sf_frame()     grip_frame() children();
module hub_frame(y)   sf_frame() translate([HUB.x, y, HUB.y]) children();   // a part's axis on the hub's, +Y
// A turning part on the hub's axis: turned with OPEN, so that its pitch circle rolls along the rack's
// pitch line (+X at the top for +OPEN). The MR128s, which are round, are drawn unturned.
module span_frame(y)  hub_frame(y) rotate([0, OPEN / PITCH_R * 180 / PI, 0]) children();
// The pinion's z along +Y, its +Y (the drive slot's mouth) toward +Z of the hub.
module pinion_frame() span_frame(PINION_Y) rotate([0, 180, 0]) rotate([-90, 0, 0]) children();

// --- Parts ------------------------------------------------------------------
module gripper_printed(id) import(str("out/asm/", id, ".stl"), convexity = 10);
module driver_printed()    import("../900-ToolInterface/out/asm/912-002.stl", convexity = 10);

module static_finger()  color("#c98a3a") sf_frame() gripper_printed("920-001");
module dynamic_finger() color("#6b8f3a") sf_frame() translate(RACK + [OPEN, 0, 0]) gripper_printed("920-002");
module pinion_gear()    color("#3a6b8f") pinion_frame() gripper_printed("920-005");
module pinion_ext()     color("#8f3a6b") span_frame(EXT_Y) gripper_printed("920-006");
module span_driver()    color("#7a7a3a") span_frame(DRIVER_Y) driver_printed();

// The M3 bolt is two parts, head and shank, so that the shank's thread in the nut can be engaged while
// the head is still held to its clearance on the EXT.
module m3_bolt_head()  color("#8a8f94") hub_frame(EXT_Y + M3_BOLT[4]) rotate([-90, 0, 0])
  cylinder(d = M3_BOLT[2], h = M3_BOLT[3], $fn = 72);
module m3_bolt_shank() color("#8a8f94") hub_frame(EXT_Y + M3_BOLT[4] - M3_BOLT[1]) rotate([-90, 0, 0])
  cylinder(d = M3_BOLT[0], h = M3_BOLT[1], $fn = 72);
module m3_nut() color("#8a8f94") pinion_frame() translate([0, 0, M3_NUT[2] - M3_NUT[1]])
  difference() {
    rotate(90) cylinder(d = M3_NUT[0] / cos(30), h = M3_NUT[1], $fn = 6);   // corners on ±Y, as N1's
    translate([0, 0, -1]) cylinder(d = M3_BOLT[0], h = M3_NUT[1] + 2, $fn = 72);
  }

GRIP_BEARINGS = ["span_inner", "span_outer"];
GRIP_RACES = ["outer", "inner", "shield"];
GRIP_RACE_PARTS = [for (b = GRIP_BEARINGS, r = GRIP_RACES) str(b, "_", r)];   // `part` only, not in PARTS

module grip_bearing_in(b, r, $fn = 360) {   // at 96 a race's chords stand inside its seat's circle
  if (b == "span_inner") hub_frame(MR128[3][0]) rotate([-90, 0, 0]) race(MR128, MR128_RACES, r);
  if (b == "span_outer") hub_frame(MR128[3][1]) rotate([-90, 0, 0]) race(MR128, MR128_RACES, r);
}

OWN_PARTS = ["static_finger", "dynamic_finger", "pinion_gear", "pinion_ext", "span_driver",
             "span_inner", "span_outer", "m3_bolt_head", "m3_bolt_shank", "m3_nut"];
PARTS = concat(tool_parts(), OWN_PARTS);
RACE_PARTS = concat(tool_race_parts(), GRIP_RACE_PARTS);

module draw(p) {
  tool_draw(p, OPEN / PITCH_R * 180 / PI);   // the span servo's output turns with the Span Driver
  if (p == "static_finger")  static_finger();
  if (p == "dynamic_finger") dynamic_finger();
  if (p == "pinion_gear")    pinion_gear();
  if (p == "pinion_ext")     pinion_ext();
  if (p == "span_driver")    span_driver();
  if (p == "m3_bolt_head")   m3_bolt_head();
  if (p == "m3_bolt_shank")  m3_bolt_shank();
  if (p == "m3_nut")         m3_nut();
  for (b = GRIP_BEARINGS) if (p == b) color("#dcdcdc") for (r = GRIP_RACES) grip_bearing_in(b, r);
  for (b = GRIP_BEARINGS, r = GRIP_RACES) if (p == str(b, "_", r)) color("#dcdcdc") grip_bearing_in(b, r);
}

// The Span Driver against the span XL-320, along the Span Mount's X: the hub's +Y is its -X (SF_TURN).
B1_X = [-(DRIVER_Y + DRIVER_B1[0]), -(DRIVER_Y + DRIVER_B1[1])];   // B1's mouth and end, x in #912-001
SPLINE_IN_B1 = span_servo_face() - max(span_servo_face() - c102_spline()[3], B1_X[1]);
echo(b1_mouth_in_servo = B1_X[0] - span_servo_face());   // past the case's front face, into the case
echo(spline_in_b1 = SPLINE_IN_B1);
echo(spline_past_b1 = c102_spline()[3] - SPLINE_IN_B1);    // beyond B1's end, in the driver's collar

echo(m3_end_below_nut_top = (PINION_Y + M3_NUT[2]) - (EXT_Y + M3_BOLT[4] - M3_BOLT[1]));   // of the nut's M3_NUT[1]

for (p = PARTS) if (part == "all" || part == p) draw(p);
for (p = RACE_PARTS) if (part == p) draw(p);
