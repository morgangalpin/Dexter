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
//      drive's flex spline hub on the Attach's hub face, over its spigot and
//      six nubs, with the Flex Spline Cap (#630-006, revised) bearing on the
//      hub from inside the cup, and the manufacturer
//      drawing (XB1-AS-C-32) puts the circular spline's outer face 23.500 mm
//      beyond that.
//
//   2. The output (turns). The End Cap and the Attach each carry a Ø50.000
//      land, the journals for the External Gear's two 6810s: the lower one
//      stands on the floor bosses around the End Cap's land, and the gear's
//      lower seat shoulder sits on it; the gear's upper seat shoulder carries
//      the upper one, on the Attach's land. The Stator Holder's eight keys go
//      into the gear's notched end until their end chamfers bottom in the
//      slots'; its recess, facing up, takes the circular spline, whose flange
//      stands on the recess floor with its Ø38h7 step in the holder's pilot,
//      screwed down through its six holes on Ø44.
//
// THE CLOSURE. Three revisions close the chains on each other, and the asserts
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
//   - The Stator Holder (#511-002, revised) seats the spline's flange on a
//     floor lowered FLOOR_DROP toward the gear, which keeps the drive where
//     the two revisions above put it, stands the holder's end clear of the
//     Attach's hub face, and leaves the spline reaching into the Mount Top's
//     6810.
//
// Above the drive the Mount Top's 6810 sits in a seat exactly 7.000 mm deep
// (z 93.000..100.000), and its Ø50 bore takes the circular spline's Ø50h6
// outside diameter. That is the answer: the circular spline — the
// "strain-wave top" of 008.8 step 7 — turns in the Mount Top's bearing, and
// the bearing is the output's third support, between the rotating spline and
// the fixed Mount. Every clearance the placement produces is echoed, not
// chosen.
//
// THE TIE-DOWN. Nut Holders A and B (#520-003/-004) lie in the Mount's two
// slots, each on its slot's floor with its curved face on the Mount's bore
// (008.8 step 9), an M3 nut in each trap. An M3 x 46 all-thread runs from each
// holder's underside up through the Mount and the Mount Top, two M3 nuts
// locked on it on the Mount Top's face (steps 12, 13). Four M3 x 12 screws
// come up through the Mount's floor (M1) and its bosses into the End Cap's
// nuts, each nut drawn on its trap's floor, where tightening pulls it (steps
// 4, 11). endcap_screw_head_proud is how far each head stands below the
// floor's underside: a DIN 912 head is 3.0 tall, the M1 counterbore 2.0 deep.
//
// THE COUPLER. The Wave Gen Coupler (#630-004) is drawn from its mesh in
// ../600-StrainWave, in 600's frame, until 600-StrainWave's source merges:
// its stub seated full length in the wave generator's hub, which is where a
// tool sets it (008.3 step 10). The mesh is the reference's: a Ø10 keyed stub
// the wave generator's Ø6 bore cannot take, on a Ø5 through bore, so the clash
// manifest holds both contacts as exceptions until the revised part replaces
// it. coupler_shaft_overrun below is how far the C-101's 24 mm shaft runs past
// the revised part's blind bore (wgc_bore_top("revised") = 9.0) at that seat:
// 2.187. But the coupler cannot reach that seat. Its hex, 10.0 long below the
// stub's shoulder, must lie between the Flex Spline Cap's top face and the
// wave generator hub's inner end, and coupler_hex_room shows 7.1 there, so
// the hex runs 2.9 into the cap, which is solid across it but for its Ø5.5
// shaft hole. The clash manifest holds that as an exception, pending the
// reviewer; the figures follow the drive, not J3, so J1 and J2 share them.
//
// NOT DRAWN. The angle and rotate motors, which bolt to the Mount's two
// motor boxes. The six M3 screws and nuts that hold the spline in the Stator
// Holder, and the six M2 screws and nuts that clamp the flex spline hub.
//
// CLASH. assembly-clash.rs checks the whole assembly against
// exgear_assembly.clash.json. A bearing there is three parts, <bearing>_inner,
// _outer and _shield, which `part` draws one at a time and PARTS does not
// list. Set clash to two names from PARTS and the file renders their
// intersection instead; an empty top-level object means the pair is clear.
//
// Vendor parts are envelopes: the drive from the manufacturer drawing, the
// motor from C-101, the bearings from their catalogue size.

use <510-001_ExternalGear.scad>
use <520-001_ExGearMount.scad>
use <511-001_ExGearMotorEndCap.scad>
use <511-002_ExGearStatorHolder.scad>
use <520-002_ExGearMountTop.scad>
use <520-003_ExGearNutHold.scad>
use <../600-StrainWave/630-005_FlexSplineAttach.scad>
use <../600-StrainWave/630-006_FlexSplineCap.scad>
use <../600-StrainWave/c201_spline_seat.scad>
use <../c101_motor.scad>

part    = "all";    // "all", or one name from PARTS for per-part export
section = false;    // true cuts the model on the XZ plane to show the stack
clash   = [];       // two names from PARTS: render their intersection

// The parts' own resolution: a coarser one here reaches every `use`d part
// and turns their 0.05 fits into facet-deep false contacts.
$fn = 360;

// --- Features, each in its own part's frame --------------------------------
BOSS_TOP         = mount_boss_top();   // #520-001 floor bosses, top face
MOUNT_FLOOR      = mount_floor_top();  // #520-001 floor plate, top face
// #520-001 bore: R 38.000 about (-0.655, 0), behind the drive axis, so it is
// nearest the axis at its two edges, (-24.55, +/-29.54) over z 57..62.
MOUNT_NEAR_R     = 38.410;
TOP_SEAT         = mount_top_seat();    // #520-002 Ø65 seat, open face and shoulder
ENDCAP_TOP       = end_cap_top();                // #511-001 face on the bosses
ENDCAP_SEAT      = end_cap_seat("revised");      // #511-001 face the motor stands on
ATTACH_SEAT      = attach_motor_face();          // #630-005 face on the motor
ATTACH_HUB       = attach_hub_face("previous");  // #630-005 hub face before the drop
GEAR_LOWER_SHLDR = gear_lower_shoulder();  // #510-001 lower seat shoulder, along its axis
GEAR_UPPER_SHLDR = gear_upper_shoulder();  // #510-001 upper seat shoulder
GEAR_KEYED_END   = gear_keyed_end();       // #510-001 notched end face
GEAR_BOTTOM      = gear_bottom();          // #510-001 end face over the floor
ROTOR_R          = gear_rotor_r();         // #510-001 and #511-002, largest radius
STATOR_SEAT      = stator_seat();             // #511-002 face on the gear's end
STATOR_FLOOR     = stator_floor("revised");   // #511-002 floor the spline's flange stands on
STATOR_RIM       = stator_rim("revised");     // #511-002 rim, toward the Mount Top
STATOR_END       = stator_end();              // #511-002 spigot's end, toward the Attach
MOTOR_LEN        = c101_len();   // C-101 body length; replace with the measured one
DRIVE_SPAN       = drive_span();              // C-201 mounting face to mounting face
B6810            = [50, 65, 7];
NUT_Z            = mount_nut_slot_z();         // #520-001 Nut Holder slots' floor
NUT_HOLDER_H     = nut_holder_height();        // #520-003/-004 thickness
TRAP_FLOOR       = 1.200;                      // #520-003/-004 nut trap's floor, its frame
ROD              = [3.000, 46.000];            // #520-005 M3 all-thread: Ø, length
M3_NUT           = [5.500, 2.400];             // C-612 M3 nut: across flats, thickness
SCREW            = [3.000, 12.000, 5.500, 3.000];  // C-610 M3 x 12 DIN 912: Ø, length under the head, head Ø, head height
SCREW_AXES       = mount_screw_axes();         // #520-001 M1, on the End Cap's 31.0 square
CBORE_FLOOR      = mount_cbore_floor();        // #520-001 M1 counterbores' floor, the heads' seat
SHAFT_LEN        = 24.000;                     // C-101 shaft beyond the mounting face (007.1)
COUPLER_SHOULDER = 10.000;                     // #630-004 stub's shoulder: wgc_shoulder() once 600 merges
COUPLER_BORE_TOP = 9.000;                      // #630-004 revised bore's blind end: wgc_bore_top("revised")

// --- Placement --------------------------------------------------------------
ENDCAP_Z = BOSS_TOP + ENDCAP_TOP;              // End Cap flipped: world = ENDCAP_Z - z
MOTOR_Z0 = ENDCAP_Z - ENDCAP_SEAT;
MOTOR_F  = MOTOR_Z0 + MOTOR_LEN;               // motor face
ATTACH_Z = MOTOR_F - ATTACH_SEAT;              // Attach frame origin
BRG_LOW  = BOSS_TOP;                           // lower 6810, on the bosses
GEAR_C   = BRG_LOW + B6810[2] - GEAR_LOWER_SHLDR;  // world z = gear z + GEAR_C
BRG_UP   = GEAR_UPPER_SHLDR + GEAR_C;
STATOR_Z = GEAR_KEYED_END + GEAR_C + STATOR_SEAT;  // Stator flipped: world = STATOR_Z - z
CS_FACE  = STATOR_Z - STATOR_FLOOR + spline_flange()[1];  // circular spline outer face, on its holder
HOLDER_END = STATOR_Z - STATOR_END;            // the holder's end, over the Attach
HOLDER_RIM = STATOR_Z - STATOR_RIM;            // the holder's rim, under the Mount Top
ATTACH_HUB_DROP = ATTACH_Z + ATTACH_HUB + DRIVE_SPAN - CS_FACE;
HUB_F    = ATTACH_Z + attach_hub_face("revised", ATTACH_HUB_DROP);  // flex spline hub face
CS_NOM   = HUB_F + DRIVE_SPAN;                 // the circular spline face, on its motor
BRG_TOP  = TOP_SEAT[0];
CAP_Z    = HUB_F + fs_hub()[1] + cap_face();   // Flex Spline Cap flipped: world = CAP_Z - z; its top face
COUPLER_Z = CS_FACE + -wg_hub_inner() - COUPLER_SHOULDER;   // coupler frame origin: its stub seated full length
// Each all-thread stands on its slot's floor: under it the Mount's hole runs
// only 0.5 deeper, so its 46 mm puts its top above the locknuts.
ROD_FOOT = NUT_Z;
ROD_TOP  = ROD_FOOT + ROD[1];
LOCKNUT_Z = mount_top_z()[1];                  // the locknuts' underside, on the Mount Top's face
ENDCAP_NUT_Z = ENDCAP_Z - end_cap_trap_floor("revised");  // the End Cap's nuts' underside, on their traps' floor

assert(abs(CS_NOM - CS_FACE) < 1e-9, "the drive does not close between its motor and its holder");
assert(BRG_UP > MOTOR_F, "upper 6810 inner race passes below the motor face");
assert(BRG_UP + B6810[2] < HUB_F, "upper 6810 inner race runs off the Attach's land");
assert(ATTACH_HUB_DROP >= 0, "the drive stands lower on its motor than on its holder; the Attach cannot rise");
assert(GEAR_BOTTOM + GEAR_C > MOUNT_FLOOR, "the External Gear reaches the floor plate");
assert(MOUNT_NEAR_R > ROTOR_R, "the External Gear or the Stator Holder reaches the Mount's bore");
assert(HOLDER_END > HUB_F, "the Stator Holder reaches the Attach's hub face");
assert(HOLDER_RIM < BRG_TOP, "the Stator Holder's rim reaches the Mount Top's 6810");
assert(CS_FACE > BRG_TOP, "the circular spline does not reach the Mount Top's 6810");

// Named, so scripts and the section viewer (exgear_assembly.view.json) read
// them; every length is mm.
echo(motor_len = MOTOR_LEN);
echo(seat_raise = ENDCAP_SEAT - end_cap_seat("previous"));
echo(j3_hub_drop = ATTACH_HUB_DROP);                     // print J3's Attach: -D config="revised" -D hub_drop=
echo(upper_6810_above_motor = BRG_UP - MOTOR_F);         // inner race bottom over the motor face
echo(upper_6810_below_hub = HUB_F - BRG_UP - B6810[2]);  // inner race top under the hub face
echo(top_6810_on_spline = CS_FACE - BRG_TOP);            // the circular spline's Ø50h6 within the Mount Top's bore
echo(stator_below_top = BRG_TOP - HOLDER_RIM);           // Stator Holder rim under the Mount Top's 6810
echo(stator_above_hub = HOLDER_END - HUB_F);             // Stator Holder end over the Attach's hub face
echo(stator_on_gear = GEAR_KEYED_END + STATOR_SEAT);     // gear z (its mesh's x) = this - holder z, where the two share a plane
echo(gear_above_floor = GEAR_BOTTOM + GEAR_C - MOUNT_FLOOR);  // External Gear's bottom face over the floor plate
echo(rotor_inside_bore = MOUNT_NEAR_R - ROTOR_R);        // gear and Stator Holder inside the Mount's bore, radial, at least
echo(coupler_shaft_overrun = MOTOR_F + SHAFT_LEN - (COUPLER_Z + COUPLER_BORE_TOP));  // > 0: the shaft runs past the revised coupler's blind bore
echo(coupler_hex_room = CS_FACE + -wg_hub_inner() - CAP_Z);  // Flex Spline Cap's top to the hub's inner end; the hex is COUPLER_SHOULDER long
echo(rod_above_locknuts = ROD_TOP - LOCKNUT_Z - 2 * M3_NUT[1]);  // all-thread proud of its outer locknut; < 0 leaves it short
echo(endcap_screw_past_nut = CBORE_FLOOR + SCREW[1] - ENDCAP_NUT_Z - M3_NUT[1]);  // < 0: the screw stops inside its nut
echo(endcap_screw_below_motor = MOTOR_Z0 - CBORE_FLOOR - SCREW[1]);  // the screw's tip under the motor's rear face
echo(endcap_screw_head_proud = SCREW[3] - CBORE_FLOOR);  // the head below the Mount floor's underside

// --- Parts ------------------------------------------------------------------
module mount()     color("#9aa7b4") ex_gear_mount("revised");
module mount_top() color("#b8c4cf") ex_gear_mount_top("revised");
module end_cap()   color("#e0a458") translate([0, 0, ENDCAP_Z]) rotate([180, 0, 0])
                     ex_gear_motor_end_cap("revised");
module attach()    color("#e0a458") translate([0, 0, ATTACH_Z])
                     flex_spline_attach("revised", ATTACH_HUB_DROP);
module fs_cap()    color("#e0a458") translate([0, 0, CAP_Z]) rotate([180, 0, 0])
                     flex_spline_cap("revised");
module gear()      color("#4f86c6") translate([0, 0, GEAR_C]) external_gear("revised");
module stator()    color("#c65f4f") translate([0, 0, STATOR_Z]) rotate([180, 0, 0])
                     ex_gear_stator_holder("revised");

module nut_holder_in(which) color("#d99a45") mount_place(NUT_Z) nut_holder(which, "revised");
// corners on +-x, as the holders' traps have theirs; the bore is the
// all-thread's, which the clash manifest lists as engaged
module hex_nut(h) difference() {
  cylinder(d = M3_NUT[0] / cos(30), h = h, $fn = 6);
  translate([0, 0, -1]) cylinder(d = ROD[0], h = h + 2, $fn = 48);
}
// the M3 nuts in the holders' traps, on the traps' floors
module trap_nuts() color("#7d7d7d") for (a = mount_rod_axes())
  translate([a.x, a.y, NUT_Z + TRAP_FLOOR]) hex_nut(M3_NUT[1]);
module rods() color("#7d7d7d") for (a = mount_rod_axes())
  translate([a.x, a.y, ROD_FOOT]) cylinder(d = ROD[0], h = ROD[1], $fn = 48);
module locknuts() color("#7d7d7d") for (a = mount_rod_axes())
  translate([a.x, a.y, LOCKNUT_Z]) hex_nut(2 * M3_NUT[1]);
// heads down in M1's counterbores; the shank laps the head by 0.005
module endcap_screws() color("#7d7d7d") for (a = SCREW_AXES) translate([a.x, a.y, CBORE_FLOOR]) {
  translate([0, 0, -SCREW[3]]) cylinder(d = SCREW[2], h = SCREW[3], $fn = 48);
  translate([0, 0, -0.005]) cylinder(d = SCREW[0], h = SCREW[1] + 0.005, $fn = 48);
}
// a flat facing the axis, as the End Cap's traps have theirs
module endcap_nuts() color("#7d7d7d") for (a = SCREW_AXES)
  translate([a.x, a.y, ENDCAP_NUT_Z]) rotate(atan2(a.y, a.x) + 30) hex_nut(M3_NUT[1]);

module coupler() color("#e3b060") translate([0, 0, COUPLER_Z]) import("../600-StrainWave/630-004_WaveGenCoupler.stl");

module tube(od, id, h) difference() { cylinder(d = od, h = h); translate([0, 0, -1]) cylinder(d = id, h = h + 2); }

RACES = ["outer", "inner", "shield"];
BEARINGS = ["bearing_lower", "bearing_upper", "bearing_top"];
function bearing_z(b) = b == "bearing_lower" ? BRG_LOW : b == "bearing_upper" ? BRG_UP : BRG_TOP;

module bearing_race(b, race) color("#d9d9d9") translate([0, 0, bearing_z(b)]) {
  if (race == "outer")  tube(B6810[1], 60.5, B6810[2]);
  if (race == "inner")  tube(54.5, B6810[0], B6810[2]);
  if (race == "shield") translate([0, 0, 0.6]) tube(60.5, 54.5, B6810[2] - 1.2);
}
module bearing(b) for (r = RACES) bearing_race(b, r);

module motor() color("#5a5a5a") translate([0, 0, MOTOR_Z0]) c101_motor_envelope(MOTOR_LEN);

module flexspline() color("#8c8c8c") translate([0, 0, HUB_F]) flexspline_envelope();

module circular_spline() color("#6f6f6f") translate([0, 0, CS_FACE]) circular_spline_envelope();

module wave_gen() color("#a0a0a0") translate([0, 0, CS_FACE]) wave_generator_envelope();

PARTS = ["mount", "mount_top", "end_cap", "motor", "attach", "fs_cap", "flexspline",
         "circular_spline", "wave_gen", "coupler", "bearing_lower", "bearing_upper", "bearing_top",
         "gear", "stator", "nut_holder_a", "nut_holder_b", "trap_nuts", "rods", "locknuts",
         "endcap_screws", "endcap_nuts"];
RACE_PARTS = [for (b = BEARINGS, r = RACES) str(b, "_", r)];   // `part` only, not in PARTS

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
  if (p == "coupler")         coupler();
  for (b = BEARINGS) if (p == b) bearing(b);
  for (b = BEARINGS, r = RACES) if (p == str(b, "_", r)) bearing_race(b, r);
  if (p == "gear")            gear();
  if (p == "stator")          stator();
  if (p == "nut_holder_a")    nut_holder_in("A");
  if (p == "nut_holder_b")    nut_holder_in("B");
  if (p == "trap_nuts")       trap_nuts();
  if (p == "rods")            rods();
  if (p == "locknuts")        locknuts();
  if (p == "endcap_screws")   endcap_screws();
  if (p == "endcap_nuts")     endcap_nuts();
}

module assembly() {
  for (p = PARTS) if (part == "all" || part == p) draw(p);
  for (p = RACE_PARTS) if (part == p) draw(p);
}

if (len(clash) == 2)
  intersection() { draw(clash[0]); draw(clash[1]); }
else if (section)
  difference() { assembly(); translate([-200, 0, -50]) cube([400, 200, 300]); }
else
  assembly();
