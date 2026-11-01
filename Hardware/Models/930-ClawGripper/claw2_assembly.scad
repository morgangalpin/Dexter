// 930-ClawGripper 2-finger assembly — placement model.
// Places the 2-finger claw on the tool interface: the Claw Body on the Span Mount, the Claw Pinion on the
// span XL-320's spline, the Claw Gear and the Claw Follower Axle on their pivots in their MR128s, the
// drive and follower Claw Fingers on their seats, their hubs' teeth meshed, each pinned by its set screw
// through its seat, the Claw Finger Wall in the body's opening, and the Claw Cap on the rim they make with
// its four bolts. The tool interface itself, with the span XL-320, is
// ../900-ToolInterface/tool_assembly.scad's, drawn through its modules.
//
// FRAME. The tool interface's: the Roll Body's, the roll axis on +Z. Every part of this group stands in
// the grip frame (tool_assembly.scad's grip_frame()); claw_params.scad gives the claw's layout along its y.
//
// PLACEMENT, each part by a feature it carries (specs/008.11, the claw gripper):
//
//   - The Claw Body's S1 over the Span Mount's column, its socket's ceiling on the column's top; the Claw
//     Finger Wall's rear shoulder on the rear edge of the body's opening, its lips in the body's grooves;
//     and the Claw Cap's rear face on the two's shoulders, their rims in its groove: all three are drawn in
//     the grip frame.
//   - The Claw Pinion on the span XL-320's spline, as steps 36-37 set the Span Driver it stands in for
//     (span_driver_y()), its teeth in phase with the sector closed.
//   - Each axle on its pivot, its collars on its two MR128s' inner races: the drive's gear (#930-002) and
//     the follower's axle (#930-006), each as drawn.
//   - The MR128s in their seats, the rear wall's and the cap's.
//   - Each finger's hex over its axle's seat, its mid-plane on y = 0, each as drawn: the drive's
//     (#930-001) and the follower's (#930-007), their hubs' teeth in mesh (claw_params.scad, THE MIRROR).
//   - Each set screw in its finger's M1 and through its seat's H1, centred on the pivot: 1 under the face of
//     the hub's far side, and 0.5 short of M1's stop under the blade. M1 opens on the far side alone, so the
//     screw goes in and comes out there, with the finger off the housing, on the bench.
//   - Each cap bolt's head in its recess in the cap, its thread in the body's T1.
//
// MOTION. OPEN, deg: the drive pivot turns +OPEN about +Y, the follower -OPEN, and the pinion and the span
// XL-320's output -claw_ratio() * OPEN. 0 is closed, the tips' rounds touching on the roll axis.
//
// NOT DRAWN. The M2.6 x 10 bolt that holds the Claw Pinion on the servo's spline (step 37).
//
// GEOMETRY. The printed parts are the binary mesh caches `render.rs 900-ToolInterface --meshes` and
// `render.rs 930-ClawGripper --meshes` build in each group's out/asm/ (revised), so run both first.
// Bearings are drawn at catalogue size as three parts each (outer and inner race, shield): `part` draws
// one race alone, and the part lists name only the whole bearing.

use <../900-ToolInterface/tool_assembly.scad>
use <../900-ToolInterface/span_socket.scad>
use <claw_params.scad>

part = "all";   // "all", or one name from claw_parts() or claw_race_parts() for per-part export
OPEN = 0;       // deg, 0 closed .. claw_open_max()

$fn = 96;

// --- Bought parts and fasteners ---------------------------------------------------------------------
M3_BOLT   = claw_cap_bolt();             // C-609 ISO 4762: d, head d, head h, length
SET_SCREW = claw_screw();                // DIN 916: d, length
// A screw's length in a tapped hole is drawn at the pilot it cuts its thread in, as print_fit.scad draws
// the pilot (fit_pin(d, FIT_TAP)), so that it meets the pilot line to line.
function tapped(d) = fit_pin(d, fit_clearances("revised")[3]);

// --- Frames -----------------------------------------------------------------------------------------
// A pivot's frame: s = 1 the drive (+X, +OPEN), s = -1 the follower; a part's y is the grip frame's.
module on_pivot(s, open) grip_frame() translate([s * claw_pivot().x, 0, claw_pivot().y]) rotate([0, s * open, 0]) children();
// The pinion's frame, on the span axis.
function pinion_turn(open) = -claw_ratio() * open;
module on_pinion(open) grip_frame() translate([span_axis().x, 0, span_axis().y]) rotate([0, pinion_turn(open), 0]) children();

// --- Parts ------------------------------------------------------------------------------------------
module printed(id) import(str("out/asm/", id, ".stl"), convexity = 10);

SIDES = [["drive", 1], ["follow", -1]];

// A set screw in its finger's M1 and through its seat's H1, drawn at its pilot and centred on the pivot along
// its line, as claw_screw_stop() takes it: the same thread on each side of the seat, and clear of M1's stop.
module set_screw(s) rotate([0, -claw_screw_dir(s), 0]) rotate([0, 90, 0])
    cylinder(d = tapped(SET_SCREW[0]), h = SET_SCREW[1], center = true, $fn = 48);

// The cap's M3 x 10s in three parts: the head in its recess in the cap, the shank through the cap, and
// the thread in the body's T1.
module cap_bolts(piece) let(y = claw_cap_y()[0], s = claw_bolt_seat_y(), e = claw_bolt_end_y())
    color("#8a8f94") grip_frame() for (b = claw_cap_bolts()) translate([b.x, 0, b.y]) rotate([-90, 0, 0])
        if (piece == "head") translate([0, 0, s]) cylinder(d = M3_BOLT[1], h = M3_BOLT[2], $fn = 72);
        else if (piece == "shank") translate([0, 0, y]) cylinder(d = M3_BOLT[0], h = s - y, $fn = 72);
        else translate([0, 0, e]) cylinder(d = tapped(M3_BOLT[0]), h = y - e, $fn = 48);

RACES = ["outer", "inner", "shield"];
// An MR128 at (x, z) in the grip frame, its -Y face at y0. At 96 a race's chords stand inside its seat.
module mr128(xz, y0, r, $fn = 360)
    grip_frame() translate([xz.x, y0, xz.y]) rotate([-90, 0, 0]) race(claw_mr128(), claw_mr128_ring(), r);

// The bearings: per side its rear and front; the pinion's in the cap.
function bearings() = let(p = claw_pivot())
    [["drive_rear", [p.x, p.y], claw_rear_bearing_y()[0]], ["drive_front", [p.x, p.y], claw_front_bearing_y()[0]],
     ["follow_rear", [-p.x, p.y], claw_rear_bearing_y()[0]], ["follow_front", [-p.x, p.y], claw_front_bearing_y()[0]],
     ["pinion_bearing", span_axis(), claw_front_bearing_y()[0]]];

// The part names: the body, finger wall, cap, pinion and bolts; per side its gear, finger and screw; the
// bearings.
function claw_parts() = concat(tool_parts(), ["claw_body", "claw_wall", "claw_cap", "pinion", "cap_bolt_heads", "cap_bolt_shanks", "cap_bolt_threads"],
                               [for (sd = SIDES, t = ["gear", "finger", "screw"]) str(sd[0], "_", t)], [for (b = bearings()) b[0]]);
function claw_race_parts() = concat(tool_race_parts(), [for (b = bearings(), r = RACES) str(b[0], "_", r)]);

module claw_draw(p, open) {
  tool_draw(p, pinion_turn(open));   // the span servo's output turns with the pinion
  if (p == "claw_body")        color("#c98a3a") grip_frame() printed("930-003");
  if (p == "claw_wall")        color("#c9c23a") grip_frame() printed("930-008");
  if (p == "claw_cap")         color("#b07a32") grip_frame() printed("930-005");
  if (p == "pinion")           color("#7a7a3a") on_pinion(open) printed("930-004");
  if (p == "cap_bolt_heads")   cap_bolts("head");
  if (p == "cap_bolt_shanks")  cap_bolts("shank");
  if (p == "cap_bolt_threads") cap_bolts("thread");
  for (sd = SIDES) let(s = sd[1], q = function(t) str(sd[0], "_", t)) {
    if (p == q("gear"))   color("#6b8f3a") on_pivot(s, open) printed(s > 0 ? "930-002" : "930-006");
    if (p == q("finger")) color("#3a6b8f") on_pivot(s, open) printed(s > 0 ? "930-001" : "930-007");
    if (p == q("screw"))  color("#8a8f94") on_pivot(s, open) set_screw(s);
  }
  for (b = bearings()) {
    if (p == b[0]) color("#dcdcdc") for (r = RACES) mr128(b[1], b[2], r);
    for (r = RACES) if (p == str(b[0], "_", r)) color("#dcdcdc") mr128(b[1], b[2], r);
  }
}

module claw_assembly(part, open) {
  for (p = claw_parts()) if (part == "all" || part == p) claw_draw(p, open);
  for (p = claw_race_parts()) if (part == p) claw_draw(p, open);
}

// How the claw stands at OPEN, and its margins.
module claw_echoes(open) {
  echo(tip_gap = claw_tip_gap(open));
  echo(tip_gap_open = claw_tip_gap(claw_open_max()));
  echo(ratio = claw_ratio());
  echo(servo_turn_open = claw_ratio() * claw_open_max());
  echo(teeth_past_open = (claw_sector_arc()[1] - claw_pinion_dir() - claw_open_max()) / claw_sector_pitch());
  echo(pinion_journal_wall = claw_pinion_wall("revised"));
  echo(hubs_over_servo = claw_hub_over_servo());
}

claw_echoes(OPEN);
claw_assembly(part, OPEN);
