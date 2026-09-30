// 500-ExternalGear assembly — placement model.
// Places the External Gear group, the J3 motor and strain-wave drive inside it,
// and the three 6810 bearings, so the stack can be reviewed by looking at it
// and so the question "what turns inside the Mount Top's bearing" is answered
// from the built geometry rather than argued. It is also where J3's stack is
// closed: the two printed parts that close it take their revised values from
// here.
//
// FRAME. The Ex Gear Mount's own frame, unchanged: floor on z = 0, the drive
// axis on +Z through the origin. The Mount Top (#520-002) is authored in the
// same frame — its all-thread holes at (-46.278, +/-10) run on from the
// Mount's, and its bearing seat is centred on the same axis — so it takes no
// transform either. Where this group sits on the arm is still open; see
// UNPLACED in ../robot_assembly.scad.
//
// WHAT PLACES WHAT. Every position below is solved from a feature a part
// carries. There are two chains, both starting from the Mount's floor, and
// they close on each other:
//
//   1. The motor stack (fixed). The Ex Gear Motor End Cap stands on the
//      floor's four bosses (top z 6.000, on the 31.000 mm NEMA 17 pattern its
//      own four holes share), lugs up: the lugs' inner faces sit 21.146 mm off
//      the axis, which is the motor body's half-width, so they are what grips
//      the motor. Motor on the End Cap's seat, MOTOR_LEN long. The Flex Spline
//      Attach on the motor face, its lugs down over the body the same way. The
//      drive's flex spline hub on the Attach's hub face, and the manufacturer
//      drawing (XB1-AS-C-32) puts the circular spline's outer face 23.500 mm
//      beyond that.
//
//   2. The output (turns). The End Cap and the Attach each carry a Ø50.000
//      land, the journals for the External Gear's two 6810s: the lower one
//      stands on the floor bosses around the End Cap's land, and the gear's
//      lower seat shoulder sits on it; the gear's upper seat shoulder carries
//      the upper one, on the Attach's land. The Stator Holder's keyed spigot
//      goes into the gear's notched end; its recess, facing up, takes the
//      circular spline, whose Ø38h7 step stands on the recess floor and whose
//      six Ø4.5 holes on Ø44 ride the holder's pegs.
//
// THE CLOSURE. Two revisions close the chains on each other, and the asserts
// below hold them:
//
//   - The End Cap's seat is raised seat_raise into the cap (#511-001,
//     revised), which lowers the motor, the Attach and the drive with it.
//     Without it the upper 6810's inner race passes below the motor face,
//     where the motor's corners reach past the Attach's R25 land.
//   - The Attach's flare is removed and its hub face lowered by
//     ATTACH_HUB_DROP (#630-005, revised), the amount the drive stands higher
//     on its motor than on its holder, so the drive fits both at once.
//     ATTACH_HUB_DROP follows MOTOR_LEN: set MOTOR_LEN to the measured body
//     length (008.3) and print J3's Attach with hub_drop set to the
//     j3_hub_drop echoed below.
//
// Above the drive the Mount Top's 6810 sits in a seat exactly 7.000 mm deep
// (z 93.000..100.000), and its Ø50 bore takes the circular spline's Ø50h6
// outside diameter. That is the answer: the circular spline — the
// "strain-wave top" of 008.8 step 7 — turns in the Mount Top's bearing, and
// the bearing is the output's third support, between the rotating spline and
// the fixed Mount. Every clearance the placement produces is echoed, not
// chosen.
//
// NOT DRAWN. Nut Holders A/B (#520-003/-004) and the two all-threads — the
// slots the holders take in the Mount are unmeasured. The Wave Gen Coupler
// (#630-004), whose depth is set by a tool, not by a face. The angle and
// rotate motors, which bolt to the Mount's two front pockets.
//
// Vendor parts are envelopes: the drive from the manufacturer drawing, the
// motor from C-101, the bearings from their catalogue size.

use <511-001_ExGearMotorEndCap.scad>
use <../600-StrainWave/630-005_FlexSplineAttach.scad>

part    = "all";    // "all", or one name from PARTS for per-part export
section = false;    // true cuts the model on the XZ plane to show the stack

$fn = 96;

// --- Features, each in its own part's frame --------------------------------
BOSS_TOP         = 6.000;    // #520-001 floor bosses, top face
MOUNT_FLOOR      = 4.000;    // #520-001 floor plate, top face
// #520-001 bore: R 38.000 about (-0.655, 0), behind the drive axis, so it is
// nearest the axis at its two edges, (-24.55, +/-29.54) over z 57..62.
MOUNT_NEAR_R     = 38.410;
TOP_SEAT         = [93.000, 100.000];  // #520-002 Ø65 seat, open face and shoulder
ENDCAP_TOP       = end_cap_top();                // #511-001 face on the bosses
ENDCAP_SEAT      = end_cap_seat("revised");      // #511-001 face the motor stands on
ATTACH_SEAT      = attach_motor_face();          // #630-005 face on the motor
ATTACH_HUB       = attach_hub_face("previous");  // #630-005 hub face before the drop
GEAR_LOWER_SHLDR = -24.763;  // #510-001 lower seat shoulder, along its x
GEAR_UPPER_SHLDR = 25.243;   // #510-001 upper seat shoulder
GEAR_KEYED_END   = 44.250;   // #510-001 notched end face
GEAR_BOTTOM      = -32.263;  // #510-001 end face over the floor
ROTOR_R          = 36.977;   // #510-001 and #511-002, largest radius
STATOR_SEAT      = 1.000;    // #511-002 flange face on the gear's end
STATOR_RECESS    = -4.000;   // #511-002 Ø50 recess floor
MOTOR_LEN        = 48.000;   // C-101 body length; replace with the measured one
DRIVE_SPAN       = 23.500;   // XB1-AS-C-32 mounting face to mounting face
B6810            = [50, 65, 7];

// --- Placement --------------------------------------------------------------
ENDCAP_Z = BOSS_TOP + ENDCAP_TOP;              // End Cap flipped: world = ENDCAP_Z - z
MOTOR_Z0 = ENDCAP_Z - ENDCAP_SEAT;
MOTOR_F  = MOTOR_Z0 + MOTOR_LEN;               // motor face
ATTACH_Z = MOTOR_F - ATTACH_SEAT;              // Attach frame origin
BRG_LOW  = BOSS_TOP;                           // lower 6810, on the bosses
GEAR_C   = BRG_LOW + B6810[2] - GEAR_LOWER_SHLDR;  // world z = gear x + GEAR_C
BRG_UP   = GEAR_UPPER_SHLDR + GEAR_C;
STATOR_Z = GEAR_KEYED_END + GEAR_C + STATOR_SEAT;  // Stator flipped: world = STATOR_Z - z
CS_FACE  = STATOR_Z - STATOR_RECESS + 8;       // circular spline outer face, on its holder
ATTACH_HUB_DROP = ATTACH_Z + ATTACH_HUB + DRIVE_SPAN - CS_FACE;
HUB_F    = ATTACH_Z + attach_hub_face("revised", ATTACH_HUB_DROP);  // flex spline hub face
CS_NOM   = HUB_F + DRIVE_SPAN;                 // the circular spline face, on its motor
BRG_TOP  = TOP_SEAT[0];

assert(abs(CS_NOM - CS_FACE) < 1e-9, "the drive does not close between its motor and its holder");
assert(BRG_UP > MOTOR_F, "upper 6810 inner race passes below the motor face");
assert(BRG_UP + B6810[2] < HUB_F, "upper 6810 inner race runs off the Attach's land");
assert(ATTACH_HUB_DROP >= 0, "the drive stands lower on its motor than on its holder; the Attach cannot rise");
assert(GEAR_BOTTOM + GEAR_C > MOUNT_FLOOR, "the External Gear reaches the floor plate");
assert(MOUNT_NEAR_R > ROTOR_R, "the External Gear or the Stator Holder reaches the Mount's bore");

// Named, so scripts and the section viewer (exgear_assembly.view.json) read
// them; every length is mm.
echo(motor_len = MOTOR_LEN);
echo(seat_raise = ENDCAP_SEAT - end_cap_seat("previous"));
echo(j3_hub_drop = ATTACH_HUB_DROP);                     // print J3's Attach: -D config="revised" -D hub_drop=
echo(upper_6810_above_motor = BRG_UP - MOTOR_F);         // inner race bottom over the motor face
echo(upper_6810_below_hub = HUB_F - BRG_UP - B6810[2]);  // inner race top under the hub face
echo(top_6810_on_spline = CS_FACE - BRG_TOP);            // the circular spline's Ø50h6 within the Mount Top's bore
echo(stator_below_top = BRG_TOP - (STATOR_Z + 7));       // Stator Holder flange under the Mount Top
echo(gear_above_floor = GEAR_BOTTOM + GEAR_C - MOUNT_FLOOR);  // External Gear's bottom face over the floor plate
echo(rotor_inside_bore = MOUNT_NEAR_R - ROTOR_R);        // gear and Stator Holder inside the Mount's bore, radial, at least

// --- Parts ------------------------------------------------------------------
module mount()     color("#9aa7b4") import("520-001_ExGearMount.stl");
module mount_top() color("#b8c4cf") import("520-002_ExGearMountTop.stl");
module end_cap()   color("#e0a458") translate([0, 0, ENDCAP_Z]) rotate([180, 0, 0])
                     ex_gear_motor_end_cap("revised");
module attach()    color("#e0a458") translate([0, 0, ATTACH_Z])
                     flex_spline_attach("revised", ATTACH_HUB_DROP);
module fs_cap()    color("#e0a458") translate([0, 0, HUB_F + 2.4])
                     import("../600-StrainWave/630-006_FlexSplineCap.stl");
module gear()      color("#4f86c6") multmatrix([[0, 1, 0, 0], [0, 0, 1, 0], [1, 0, 0, GEAR_C]])
                     import("510-001_ExternalGear.stl");
module stator()    color("#c65f4f") translate([0, 0, STATOR_Z]) rotate([180, 0, 0])
                     import("511-002_ExGearStatorHolder.stl");

module tube(od, id, h) difference() { cylinder(d = od, h = h); translate([0, 0, -1]) cylinder(d = id, h = h + 2); }

module bearing(z0) color("#d9d9d9") translate([0, 0, z0]) {
  tube(B6810[1], 60.5, B6810[2]);        // outer race
  tube(54.5, B6810[0], B6810[2]);        // inner race
  translate([0, 0, 0.6]) tube(60.5, 54.5, B6810[2] - 1.2);  // shields
}

module motor() color("#5a5a5a") translate([0, 0, MOTOR_Z0]) {
  intersection() {
    translate([-21.15, -21.15, 0]) cube([42.3, 42.3, MOTOR_LEN]);
    cylinder(d = 50.8, h = MOTOR_LEN);
  }
  translate([0, 0, MOTOR_LEN]) cylinder(d = 22, h = 2);
  translate([0, 0, MOTOR_LEN]) cylinder(d = 5, h = 24);
}

module flexspline() color("#8c8c8c") translate([0, 0, HUB_F]) {
  tube(22.5, 11, 2.4);                                 // hub
  translate([0, 0, 2.4]) tube(35.5, 22.5, 0.6);        // diaphragm
  translate([0, 0, 2.4]) tube(34.4, 33.9, DRIVE_SPAN - 8.4);
  translate([0, 0, DRIVE_SPAN - 6]) tube(35.5, 33.9, 6);  // teeth band, inside the circular spline
}

module circular_spline() color("#6f6f6f") translate([0, 0, CS_FACE - 8]) {
  tube(38, 35.5, 2);                     // Ø38h7 step, on the holder's floor
  translate([0, 0, 2]) difference() {
    tube(50, 35.5, 6);
    for (a = [0 : 60 : 300]) rotate(a + 30) translate([22, 0, -1]) cylinder(d = 4.5, h = 8);
  }
}

module wave_gen() color("#a0a0a0") translate([0, 0, CS_FACE - 6]) {
  tube(33.9, 14, 6);                     // plug and bearing, inside the teeth band
  translate([0, 0, 11 - 15]) tube(14, 6, 15);  // hub, 5.0 beyond the drive face
}

PARTS = ["mount", "mount_top", "end_cap", "motor", "attach", "fs_cap", "flexspline",
         "circular_spline", "wave_gen", "bearing_lower", "bearing_upper", "bearing_top",
         "gear", "stator"];

module draw(p) {
  if (p == "mount")           mount();
  if (p == "mount_top")       mount_top();
  if (p == "end_cap")         end_cap();
  if (p == "motor")           motor();
  if (p == "attach")          attach();
  if (p == "fs_cap")          fs_cap();
  if (p == "flexspline")      flexspline();
  if (p == "circular_spline") circular_spline();
  if (p == "wave_gen")        wave_gen();
  if (p == "bearing_lower")   bearing(BRG_LOW);
  if (p == "bearing_upper")   bearing(BRG_UP);
  if (p == "bearing_top")     bearing(BRG_TOP);
  if (p == "gear")            gear();
  if (p == "stator")          stator();
}

module assembly() for (p = PARTS) if (part == "all" || part == p) draw(p);

if (section)
  difference() { assembly(); translate([-200, 0, -50]) cube([400, 200, 300]); }
else
  assembly();
