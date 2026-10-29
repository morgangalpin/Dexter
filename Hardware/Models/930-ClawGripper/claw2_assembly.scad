// 930-ClawGripper 2-finger assembly — placement model.
// Places the 2-finger claw on the tool interface: the Claw Body on the Span Mount, a Claw Gear on each
// pivot with its Pinion Bearing EXT in the body's two MR128s and the M3 x 16 that holds them, the Span
// Driver on the drive pivot, and a Claw Finger on each pivot over the driver's head or the gear's nose,
// each with its set screw. claw4_assembly.scad draws the 4-finger claw through this file's modules. The
// tool interface itself, with the span XL-320 the Span Driver stands on, is
// ../900-ToolInterface/tool_assembly.scad's, drawn through its modules.
//
// FRAME. The tool interface's: the Roll Body's, the roll axis on +Z. Every part of this group stands in
// the grip frame (tool_assembly.scad's grip_frame()); claw_params.scad gives the claw's layout along its y.
//
// PLACEMENT, each part by a feature it carries (specs/008.11, the claw gripper):
//
//   - The Claw Body's S1 over the Span Mount's column, its socket's ceiling on the column's top: it is
//     drawn in the grip frame.
//   - Each gear on its pivot, the drive's on the span axis and the follower's on its mirror; both drawn
//     the same way up (claw_params.scad, THE FLIP).
//   - Each EXT's keyed nose in its gear's K1, its spacer on the gear's +Y face, so that its shoulder is
//     the inner MR128's face (claw_journal_y()); the MR128s in M1 against the shoulder between the seats.
//   - The Span Driver on the span XL-320's spline, as steps 36-37 set it (span_driver_y()).
//   - Each finger's socket over its pivot's nose, its mid-plane at claw_finger_mid(): the drive finger as
//     drawn, the follower's turned 180 deg about Z.
//   - Each M3 bolt's head on its EXT's end face, its shank through the EXT into the gear's T1.
//   - Each set screw in its finger's outer M1, its outer end flush with the hub, its tip in the nose's X1.
//
// MOTION. OPEN, deg: the drive train turns +OPEN about +Y, the follower's -OPEN, and the span XL-320's
// output turns with the drive train. 0 is closed, the tips' faces meeting on the roll axis.
//
// NOT DRAWN. The M2.6 x 10 bolt that holds the Span Driver on the servo's spline (step 37).
//
// GEOMETRY. The printed parts are the binary mesh caches `render.rs 900-ToolInterface --meshes`,
// `render.rs 920-ParallelGripper --meshes` and `render.rs 930-ClawGripper --meshes` build in each group's
// out/asm/ (revised), so run all three first. Bearings are drawn at catalogue size as three parts each
// (outer and inner race, shield): `part` draws one race alone, and the part lists name only the whole
// bearing.

use <../900-ToolInterface/tool_assembly.scad>
use <../900-ToolInterface/span_socket.scad>
use <claw_params.scad>

part = "all";   // "all", or one name from claw_parts(2) or claw_race_parts() for per-part export
OPEN = 0;       // deg, 0 closed .. claw_open_max()

$fn = 96;

// --- Bought parts and fasteners ---------------------------------------------------------------------
MR128       = [8, 12, 3.5];              // C-405: bore, OD, width
MR128_RACES = [9.2, 10.8];               // inner race OD, outer race ID
M3_BOLT     = [3, 5.5, 3];               // ISO 4762: d, head d, head h
M3_LEN      = [16, 25];                  // C-620 with the EXT (2 fingers), with the Claw Axle (4 fingers)
UNDER_HEAD  = [8.5, 18.5];               // under its head, y from the EXT's or the Axle's shoulder
EXT_NOSE    = -2.000;                    // #920-006 N1's end, from its shoulder: the gear's K1 floor
SET_SCREW   = [3, 6];                    // C-606 DIN 913: d, length
// A screw's length in a tapped hole is drawn at the pilot it cuts its thread in, as print_fit.scad draws
// the pilot (fit_pin(d, FIT_TAP)), so that it meets the pilot line to line.
function tapped(d) = fit_pin(d, fit_clearances("revised")[3]);

// --- Frames -----------------------------------------------------------------------------------------
// A pivot's train: s = 1 the drive (+X, +OPEN), s = -1 the follower; a part's y is the grip frame's.
module train(s, open) grip_frame() translate([s * claw_pivot().x, 0, claw_pivot().y]) rotate([0, s * open, 0]) children();
// A finger on its pivot: the follower's turned 180 deg about Z.
module finger_on(s, outer, open) train(s, open) translate([0, claw_finger_mid(outer), 0]) rotate(s > 0 ? 0 : 180) children();

// --- Parts ------------------------------------------------------------------------------------------
module printed(id)        import(str("out/asm/", id, ".stl"), convexity = 10);
module ext_printed()      import("../920-ParallelGripper/out/asm/920-006.stl", convexity = 10);
module driver_printed()   import("../900-ToolInterface/out/asm/912-002.stl", convexity = 10);

SIDES = [["drive", 1], ["follow", -1]];

// An M3 bolt in three parts: its head on the EXT's or the Axle's end, its shank through the bore, and
// its thread in the gear's T1 from the K1 floor on.
module bolt(n, s, open, piece) let(j = claw_journal_y(), u = j + UNDER_HEAD[n == 2 ? 0 : 1],
                                   e = u - M3_LEN[n == 2 ? 0 : 1], k = j + EXT_NOSE)
    color("#8a8f94") train(s, open) rotate([-90, 0, 0])
        if (piece == "head") translate([0, 0, u]) cylinder(d = M3_BOLT[1], h = M3_BOLT[2], $fn = 72);
        else if (piece == "shank") translate([0, 0, k]) cylinder(d = M3_BOLT[0], h = u - k, $fn = 72);
        else translate([0, 0, e]) cylinder(d = tapped(M3_BOLT[0]), h = k - e, $fn = 48);   // T1's facets

// A set screw in its finger's outer hole, along the hub's radius away from the roll axis, wholly in
// the tapped hole or in the nose's X1 beyond it, so drawn at its pilot. An inner finger's stands flush
// with the hub; an outer finger's stops on the M3 bolt's shank in the Claw Axle's bore (#930-004 X1).
module set_screw(s, outer, open)
    let(y = claw_finger_mid(outer) + claw_screw()[1],
        tip = outer ? M3_BOLT[0] / 2 : claw_hub_r() - SET_SCREW[1])
    color("#8a8f94") train(s, open) translate([s > 0 ? tip : -tip - SET_SCREW[1], y, 0]) rotate([0, 90, 0])
        cylinder(d = tapped(SET_SCREW[0]), h = SET_SCREW[1], $fn = 48);

RACES = ["outer", "inner", "shield"];
module mr128(s, k, r, $fn = 360) let(y = claw_seats_y()[k][0])   // at 96 a race's chords stand inside its seat
    grip_frame() translate([s * claw_pivot().x, y, claw_pivot().y]) rotate([-90, 0, 0]) race(MR128, MR128_RACES, r);

// The part names: per side, its train's parts; the 4-finger claw takes the Axle and the outer fingers.
function train_parts(n) = concat(["finger", "gear", "bolt_head", "bolt_shank", "bolt_thread", "screw", "inner", "outer"],
                                 n == 2 ? ["ext"] : ["axle", "outer_finger", "outer_screw"]);
function claw_parts(n) = concat(tool_parts(), ["claw_body", "span_driver"],
                                [for (sd = SIDES, t = train_parts(n)) str(sd[0], "_", t)]);
function claw_race_parts() = concat(tool_race_parts(),
                                    [for (sd = SIDES, b = ["inner", "outer"], r = RACES) str(sd[0], "_", b, "_", r)]);

module claw_draw(p, n, open) {
  tool_draw(p, open);   // the span servo's output turns with the drive train
  if (p == "claw_body")   color("#c98a3a") grip_frame() printed("930-003");
  if (p == "span_driver") color("#7a7a3a") train(1, open) translate([0, span_driver_y(), 0]) driver_printed();
  for (sd = SIDES) let(s = sd[1], q = function(t) str(sd[0], "_", t)) {
    if (p == q("finger"))       color("#3a6b8f") finger_on(s, false, open) printed("930-001");
    if (p == q("outer_finger")) color("#3a6b8f") finger_on(s, true, open) printed("930-001");
    if (p == q("gear"))         color("#6b8f3a") train(s, open) printed("930-002");
    if (p == q("ext"))          color("#8f3a6b") train(s, open) translate([0, claw_journal_y(), 0]) ext_printed();
    if (p == q("axle"))         color("#8f3a6b") train(s, open) translate([0, claw_journal_y(), 0]) printed("930-004");
    if (p == q("bolt_head"))    bolt(n, s, open, "head");
    if (p == q("bolt_shank"))   bolt(n, s, open, "shank");
    if (p == q("bolt_thread"))  bolt(n, s, open, "thread");
    if (p == q("screw"))        set_screw(s, false, open);
    if (p == q("outer_screw"))  set_screw(s, true, open);
    for (k = [0, 1]) let(b = ["inner", "outer"][k]) {
      if (p == q(b)) color("#dcdcdc") for (r = RACES) mr128(s, k, r);
      for (r = RACES) if (p == q(str(b, "_", r))) color("#dcdcdc") mr128(s, k, r);
    }
  }
}

module claw_assembly(n, part, open) {
  for (p = claw_parts(n)) if (part == "all" || part == p) claw_draw(p, n, open);
  for (p = claw_race_parts()) if (part == p) claw_draw(p, n, open);
}

// How the claw stands at OPEN, and its margins.
module claw_echoes(n, open) {
  echo(tip_gap = claw_tip_gap(open));
  echo(tip_gap_open = claw_tip_gap(claw_open_max()));
  echo(gear_over_base_plate = claw_disc_margin());
  echo(column_wall = claw_column_wall("revised"));
  echo(bolt_in_tap = claw_teeth_y()[1] - (claw_journal_y() + UNDER_HEAD[n == 2 ? 0 : 1] - M3_LEN[n == 2 ? 0 : 1]));
}

claw_echoes(2, OPEN);
claw_assembly(2, part, OPEN);
