// 100-Base assembly — placement model.
// Places the base's seven parts, the strakes and all-threads that tie them,
// and J1's drive inside the Base Long — the Base Motor End Cap, the motor,
// the Flex Spline Attach and Cap, C-201 and the two 6810s — so the base can
// be reviewed for fit by looking at it.
//
// FRAME. The Base Mount Bottom's own: J1's axis on +Z through the origin, its
// mounting face on z = 0, the Base Mounting Plate below it. +Z is up.
//
// THE FIXED STACK is specs/004 § Base mounting plate's, each part on a face of
// the one below it:
//
//   - The Base Mounting Plate under the mounting face; its frame already
//     puts its top face on z = 0.
//   - The Base Clamp on the Mount's shoulder, MOUNT_SHOULDER.
//   - The Base Stator Holder (#110-002, revised) turned over, its flange's
//     face on the Mount's top face, MOUNT_TOP, and turned 30° like the Long.
//     Its flange is the Long's own outline, so it lies between the two.
//   - The Base Long's bottom face on the holder flange's back. Its strake
//     slots are on 0° + 60°k and the Mount's on 30° + 60°k, so it is turned
//     30° to put each strake in both.
//   - The Base Code Disc on the Long's top face, turned with it: its slots
//     take the Long's strakes where they stand STRAKE_PROUD above the face,
//     and its notches the all-threads.
//
// WHAT TURNS ON J1 hangs from the Main Pivot (#300-001, a context part from
// 300-Pivot), whose base rests on the upper 6810 flush with the Long's top
// face (004's stack). It is turned 180° about J1 from its own frame, which
// puts its outside inside the Pivot Skirt's frame. The skirt hangs from it by
// three M3 screws: its own axis is Y, a quarter turn about X carries it onto
// Z, and its screw holes (H1, y BOSS_Y) are on the pivot's lower side holes,
// PIVOT_HOLE_Z above the Long's top face. That puts the skirt's round part
// round the disc. Its round part is an arc, x -35.6 .. 55, its lug on +X.
//
// J1'S DRIVE closes from the top. 007.1 C-101 makes the End Cap the fixed
// datum, and the stack above fixes the Stator Holder, so the drive must close
// between them. Each part below is placed on the one above it:
//
//   - The Base Motor End Cap (#311-001) in the upper 6810: its land, z
//     CAP_LAND, is the bearing's width, so the bearing on the land's shoulder
//     is flush with the cap's top face, and both with the Long's top face.
//   - The motor's rear on the cap's seat, CAP_SEAT, its face MOTOR_LEN below.
//   - The Wave Gen Coupler (#630-004, revised) on the shaft, its bottom
//     face wgc_above_motor() below the motor face, where the 008.3 step 10
//     tool sets it; its M3 x 4 grub screw and nut where the coupler's source
//     draws them (wgc_grub_screw(), wgc_nut()).
//   - The Flex Spline Attach (#630-005, revised, no hub drop) on the motor
//     face, its land in the lower 6810 on the Long's shoulder; the
//     flexspline's hub on its hub face, its holes on the Attach's nubs, the
//     Flex Spline Cap inside the cup, and the six M2 hub screws from the
//     Attach's head seats up through them.
//   - The circular spline drive_span() below the hub face, the wave generator
//     inside it, on the coupler's stub.
//
// The spline's flange must then bear on the holder's recess floor. The
// revised holder's flange stands FLANGE_RISE along its body from the
// reference's for that, at the C-101 body length MOTOR_LEN, and the file
// asserts it: a different motor length leaves a gap or an interference at
// the floor, echoed as drive_gap. The coupler's spacing (DC-600-2) moved the
// motor 1.0 of it up and the drive the other 4.0 down.
//
// STRAKES. Six 133 mm CF strakes (C-501) in alternate slots, three
// epoxied in each part (008.2 step 2): the Mount's three bottomed in its
// slots, on 30°, 150° and 270°; the Long's three on 90°, 210° and 330°,
// standing STRAKE_PROUD above its top face (008.2 step 3, "~6 mm"). The
// all-threads (008.4 steps 12–16) are 105 mm M3, three in alternate holes,
// from the holder's flange face up through the Long.
//
// GEOMETRY. The 100-Base parts are the binary mesh cache `render.rs
// 100-Base --meshes` builds in out/asm/, so run it first. Building them here
// from source would take over an hour, and a `use`d file keeps its own
// `config`. The Main Pivot is `render.rs 300-Pivot --meshes`'s revised render
// in ../300-Pivot/out/asm/; its source includes BOSL2, whose transforms a
// `use` would bring here unset. The Base Motor End Cap is that cache too, since
// a `use`d file keeps its own `config`; the faces placed against it come from
// its source. The plate, the coupler, the
// Attach and the Cap are built from source; they are quick, and the last three
// take their config as an argument.
//
// CLASH. Set clash to two names from PARTS and the file renders their
// intersection instead; an empty top-level object means the pair is clear.
// The whole assembly is checked by assembly-clash.rs against
// base_assembly.clash.json. A bearing there is three parts, <bearing>_inner,
// _outer and _shield, which `part` draws one at a time and PARTS does not list.
//
// Vendor parts are envelopes: the 6810s at catalogue size, C-201 from the
// manufacturer drawing, the motor from C-101, the strakes and all-threads as
// plain prisms.

use <110-004_BaseMountingPlate.scad>
use <110-002_BaseStatorHolder.scad>
use <../print_fit.scad>
use <../600-StrainWave/630-004_WaveGenCoupler.scad>
use <../600-StrainWave/630-005_FlexSplineAttach.scad>
use <../600-StrainWave/630-006_FlexSplineCap.scad>
use <../600-StrainWave/c201_spline_seat.scad>
use <../c101_motor.scad>
use <../300-Pivot/311-001_MotorEndCapBase.scad>

part     = "all";   // "all", or one name from PARTS for per-part export
section  = false;   // true cuts the model on the XZ plane
clash    = [];      // two names from PARTS: render their intersection

$fn = 96;

// --- Features, each in its own part's frame --------------------------------
MOUNT_SHOULDER = 82.000;           // #110-001 shoulder under the spigot
MOUNT_TOP      = 98.000;           // #110-001 top face
MOUNT_SLOT_Z   = 4.000;            // #110-001 strake slots' bottom
LONG_BOTTOM    = -28.000;          // #120-001 bottom face
LONG_TOP       = 68.000;           // #120-001 top face
LONG_SHOULDER  = 7.000;            // #120-001 lower bore's shoulder
HOLDER_FLANGE  = holder_flange("revised");  // #110-002 flange: back, face
HOLDER_FLOOR   = holder_floor();            // #110-002 recess floor
DISC_D         = 94.300;           // #100-002 D1
SKIRT_R        = 48.000;           // #100-003 S1, inside
SKIRT_DROP     = 26.000;           // #100-003 S1, below y = 0
SKIRT_RISE     = 20.000;           // #100-003 frame, above y = 0
BOSS_Y         = 12.000;           // #100-003 H1, the screw holes' y
PIVOT_HOLE_Z   = 15.000;           // #300-001 side screw holes at 180° and ±45°, above its base
CAP_LAND       = cap_land();       // #311-001 Ø50 land, the 6810's journal; its top is the top face, on the Main Pivot
CAP_TOP        = CAP_LAND[1];
CAP_SEAT       = cap_seat("revised");  // #311-001 the motor's rear; the revised seat stands the press clearance above it
M2_SCREW       = [2.000, 3.800, 2.000, 16.000];  // the hub screws: shank Ø, head Ø, head height, length under the head
PIVOT_TURN     = 180;              // #300-001 about J1, onto the skirt
SLOT_TURN      = 30;               // #120-001, #110-002 and #100-002 slots on 0°, the Mount's on 30°
STRAKE         = [12.700, 3.175, 133.000];  // C-501, tangential, radial, length
STRAKE_R       = 35.651;           // the slots' centre radius, shared
STRAKE_PROUD   = 6.000;            // above the Long's top face, 008.2 step 3
THREAD         = [3.000, 105.000]; // M3 all-thread
THREAD_R       = 35.540;           // the all-thread holes' radius, shared
MOTOR_LEN      = c101_len();       // C-101 body length; replace with the measured one
B6810          = [50, 65, 7];
B6810_FN       = 360;              // facets: at 96 the Ø50 bore's chords stand 0.013 inside the
                                   // circle, more than the clash check's facet slack

// --- Placement --------------------------------------------------------------
HOLDER_FACE = MOUNT_TOP;
HOLDER_Z   = HOLDER_FACE + HOLDER_FLANGE[1];  // holder flipped: world = HOLDER_Z - z
HOLDER_BACK = HOLDER_Z - HOLDER_FLANGE[0];
LONG_Z     = HOLDER_BACK - LONG_BOTTOM;  // world = Long z + LONG_Z
LONG_TOP_Z = LONG_TOP + LONG_Z;
BRG_LOW    = LONG_SHOULDER - B6810[2] + LONG_Z;
BRG_UP     = LONG_TOP_Z - B6810[2];
SKIRT_Z    = LONG_TOP_Z + PIVOT_HOLE_Z - BOSS_Y;  // world = skirt y + SKIRT_Z
CAP_Z      = LONG_TOP_Z - CAP_TOP;       // world = cap z + CAP_Z
MOTOR_REAR = CAP_SEAT + CAP_Z;
MOTOR_F    = MOTOR_REAR - MOTOR_LEN;     // motor face, looking down
ATTACH_Z   = MOTOR_F + attach_motor_face();  // Attach flipped: world = ATTACH_Z - z
HUB_F      = ATTACH_Z - attach_hub_face("revised", 0);  // flexspline hub face
CS_FACE    = HUB_F - drive_span();       // circular spline outer face, looking down
DRIVE_GAP  = HOLDER_Z - HOLDER_FLOOR - spline_flange()[1] - CS_FACE;  // holder floor above the spline's flange
COUPLER_Z  = MOTOR_F - wgc_above_motor();   // coupler flipped: world = COUPLER_Z - z
SHAFT_TIP  = MOTOR_F - 24;                   // C-101's Ø5 x 24 shaft
WG_INNER   = CS_FACE + wg_hub_inner();       // the wave generator hub's inner end
WG_SCREWS  = CS_FACE + wg_set_screws();      // its set screws' axis
MOUNT_STRAKE_Z = MOUNT_SLOT_Z;
LONG_STRAKE_Z  = LONG_TOP_Z + STRAKE_PROUD - STRAKE[2];

assert(abs(CAP_LAND[1] - CAP_LAND[0] - B6810[2]) < 1e-9, "the End Cap's land is not the 6810's width");
assert(MOTOR_F > BRG_LOW + B6810[2], "the motor face passes into the lower 6810");
assert(HUB_F < BRG_LOW, "the lower 6810 runs off the Attach's land, which spans the hub face to the motor face");
assert(abs(DRIVE_GAP) < 1e-6, "J1's drive does not close on the Stator Holder's floor; see drive_gap");
assert(COUPLER_Z - wgc_cone_top("revised") - WG_INNER >= fit_clearances("revised")[2] - 1e-9,
       "the coupler's shoulder comes within the running clearance of the wave generator");
assert(WG_SCREWS - (COUPLER_Z - wgc_top("revised")) >= 1.5, "the coupler's stub does not pass the wave generator's set screws");

// Named, so scripts and the section viewer (base_assembly.view.json) read
// them; every length is mm.
echo(long_bottom_z = HOLDER_BACK);
echo(holder_flange_z = str(HOLDER_FACE, " .. ", HOLDER_BACK));
echo(long_top_z = LONG_TOP_Z);
echo(motor_len = MOTOR_LEN);
echo(motor_face_z = MOTOR_F);
echo(motor_above_6810 = MOTOR_F - BRG_LOW - B6810[2]);   // motor face over the lower 6810
echo(land_below_6810 = BRG_LOW - HUB_F);                 // the Attach's land, hub face to motor face, beyond the 6810 below
echo(spline_face_z = CS_FACE);
echo(drive_gap = round(DRIVE_GAP * 1000) / 1000 + 0);   // holder floor above the spline's flange; 0 closes (+ 0 clears -0)
echo(wg_inner_above_motor = MOTOR_F - WG_INNER);          // the wave generator hub's inner end, from the motor face
echo(coupler_under_wg = COUPLER_Z - wgc_cone_top("revised") - WG_INNER);  // coupler shoulder's top to the wave generator
echo(shaft_under_bore_end = SHAFT_TIP - (COUPLER_Z - wgc_bore_top("revised")));  // shaft tip to the coupler bore's end
echo(stub_past_set_screws = WG_SCREWS - (COUPLER_Z - wgc_top("revised")));        // stub end beyond the set screws' axis
echo(grip_under_hub = COUPLER_Z - wgc_grip("revised")[1] - HUB_F);              // coupler grip's top to the hub face
echo(thread_above_long = HOLDER_FACE + THREAD[1] - LONG_TOP_Z);  // all-thread, for the washer and nut
echo(disc_skirt_radial = SKIRT_R - DISC_D / 2);          // disc edge inside the skirt
echo(skirt_span = str(SKIRT_Z - SKIRT_DROP, " .. ", SKIRT_Z + SKIRT_RISE));
echo(skirt_above_long = SKIRT_Z - LONG_TOP_Z);          // round part's top over the Long's top face
echo(long_strake_below_long = HOLDER_BACK - LONG_STRAKE_Z);  // Long's strakes, down through the holder into the Mount
echo(mount_strake_above_mount = MOUNT_STRAKE_Z + STRAKE[2] - MOUNT_TOP);  // Mount's strakes, up into the Long
echo(strake_proud = STRAKE_PROUD);
// Where the viewer's cut, in its 0.5 steps, shows a clash that y = 0 misses.
echo(cut_lugs = 10);                                            // a lug of the Attach and of the End Cap

// --- Parts ------------------------------------------------------------------
module printed(id) import(str("out/asm/", id, ".stl"), convexity = 10);

module plate()   color("#7d8794") base_mounting_plate();
module mount()   color("#9aa7b4") printed("110-001");
module clamp()   color("#d99a45") translate([0, 0, MOUNT_SHOULDER]) printed("100-001");
module long()    color("#b8c4cf") translate([0, 0, LONG_Z]) rotate(SLOT_TURN) printed("120-001");
module disc()    color("#2f6db5") translate([0, 0, LONG_TOP_Z]) rotate(SLOT_TURN) printed("100-002");
module skirt()   color("#5b9be0") translate([0, 0, SKIRT_Z]) rotate([90, 0, 0]) printed("100-003");
module pivot()   color("#d4ad6b") translate([0, 0, LONG_TOP_Z]) rotate(PIVOT_TURN)
                   import("../300-Pivot/out/asm/300-001.stl", convexity = 10);
module end_cap() color("#e0a458") translate([0, 0, CAP_Z])
                   import("../300-Pivot/out/asm/311-001.stl", convexity = 8);
module motor()   color("#50565c") translate([0, 0, MOTOR_REAR]) rotate([180, 0, 0]) c101_motor_envelope(MOTOR_LEN);
module attach()  color("#e3b060") translate([0, 0, ATTACH_Z]) rotate([180, 0, 0]) flex_spline_attach("revised", 0);
module fs_cap()  color("#c98a3a") translate([0, 0, HUB_F - fs_hub()[1] - cap_face()]) flex_spline_cap("revised");
module coupler() color("#e8c547") translate([0, 0, COUPLER_Z]) rotate([180, 0, 0]) wave_gen_coupler("revised");
// The coupler's M3 x 4 grub screw and its nut, in the coupler's frame.
module grub_screw()  color("#6f7782") translate([0, 0, COUPLER_Z]) rotate([180, 0, 0]) wgc_grub_screw();
module coupler_nut() color("#8a929b") translate([0, 0, COUPLER_Z]) rotate([180, 0, 0]) wgc_nut();
// The six M2 hub screws, in the Attach's frame: each head under its seat,
// the shank up through the hub into the Cap's nut.
module hub_screws() color("#6f7782") translate([0, 0, ATTACH_Z]) rotate([180, 0, 0]) fs_hub_holes()
  translate([0, 0, attach_head_seat("revised")]) {
    translate([0, 0, -M2_SCREW[2]]) cylinder(d = M2_SCREW[1], h = M2_SCREW[2], $fn = 48);
    cylinder(d = M2_SCREW[0], h = M2_SCREW[3], $fn = 24);
  }
module holder()  color("#c65f4f") translate([0, 0, HOLDER_Z]) rotate(SLOT_TURN) rotate([180, 0, 0]) printed("110-002");

module tube(od, id, h) difference() { cylinder(d = od, h = h); translate([0, 0, -1]) cylinder(d = id, h = h + 2); }

BEARINGS = [["bearing_lower", BRG_LOW], ["bearing_upper", BRG_UP]];
RACES    = ["outer", "inner", "shield"];
RACE_PARTS = [for (b = BEARINGS, r = RACES) str(b[0], "_", r)];   // `part` only, not in PARTS

module bearing_race(z0, race, $fn = B6810_FN) translate([0, 0, z0]) {
  if (race == "outer")  tube(B6810[1], 60.5, B6810[2]);
  if (race == "inner")  tube(54.5, B6810[0], B6810[2]);
  if (race == "shield") translate([0, 0, 0.6]) tube(60.5, 54.5, B6810[2] - 1.2);
}

module bearing(z0) color("#dcdcdc") for (r = RACES) bearing_race(z0, r);

// C-201 is drawn in the circular spline's frame turned over, outer face down.
// The spline's holes follow the holder's slots; the wave generator keeps the
// flexspline's phase, whose oval it holds.
module drive_frame(turn = SLOT_TURN) translate([0, 0, CS_FACE]) rotate(turn) rotate([180, 0, 0]) children();
module circular_spline() color("#2a9d8f") drive_frame() circular_spline_envelope();
module wave_gen()        color("#b58ac9") drive_frame(0) wave_generator_envelope();
module flexspline()      color("#8f969c") translate([0, 0, HUB_F]) rotate([180, 0, 0]) flexspline_envelope();

module strake(a, z0) rotate(a) translate([STRAKE_R - STRAKE[1] / 2, -STRAKE[0] / 2, z0]) cube([STRAKE[1], STRAKE[0], STRAKE[2]]);
module strakes_mount() color("#29292e") for (a = [30 : 120 : 270]) strake(a, MOUNT_STRAKE_Z);
module strakes_long()  color("#3d3d44") for (a = [90 : 120 : 330]) strake(a, LONG_STRAKE_Z);
module threads() color("#6f7782") for (a = [0 : 120 : 240])
  rotate(a) translate([THREAD_R, 0, HOLDER_FACE]) cylinder(d = THREAD[0], h = THREAD[1], $fn = 24);

PARTS = ["plate", "mount", "clamp", "long", "strakes_mount", "strakes_long", "threads", "disc",
         "pivot", "skirt", "end_cap", "motor", "coupler", "grub_screw", "coupler_nut", "attach", "hub_screws", "fs_cap", "flexspline", "wave_gen",
         "circular_spline", "holder", "bearing_lower", "bearing_upper"];

module draw(p) {
  if (p == "plate")           plate();
  if (p == "mount")           mount();
  if (p == "clamp")           clamp();
  if (p == "long")            long();
  if (p == "strakes_mount")   strakes_mount();
  if (p == "strakes_long")    strakes_long();
  if (p == "threads")         threads();
  if (p == "disc")            disc();
  if (p == "pivot")           pivot();
  if (p == "skirt")           skirt();
  if (p == "end_cap")         end_cap();
  if (p == "motor")           motor();
  if (p == "attach")          attach();
  if (p == "fs_cap")          fs_cap();
  if (p == "coupler")         coupler();
  if (p == "grub_screw")      grub_screw();
  if (p == "coupler_nut")     coupler_nut();
  if (p == "hub_screws")      hub_screws();
  if (p == "flexspline")      flexspline();
  if (p == "wave_gen")        wave_gen();
  if (p == "circular_spline") circular_spline();
  if (p == "holder")          holder();
  if (p == "bearing_lower")   bearing(BRG_LOW);
  if (p == "bearing_upper")   bearing(BRG_UP);
  for (b = BEARINGS, r = RACES) if (p == str(b[0], "_", r)) color("#dcdcdc") bearing_race(b[1], r);
}

module assembly() {
  for (p = PARTS)      if (part == "all" || part == p) draw(p);
  for (p = RACE_PARTS) if (part == p) draw(p);
}

if (len(clash) == 2)
  intersection() { draw(clash[0]); draw(clash[1]); }
else if (section)
  difference() { assembly(); translate([-200, 0, -50]) cube([400, 200, 400]); }
else
  assembly();
