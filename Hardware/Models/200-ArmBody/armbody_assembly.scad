// 200-ArmBody assembly — placement model.
// Places the Arm Body's parts, its two 6810s, J2's drive, the four Stator Balancers, the three
// Belt Directors with their MR128s and the idler column, so the arm body can be reviewed for
// fit by looking at it. The Calibration Arrows (#200-006) are not placed: no spec or part
// says where on the arm they stand.
//
// FRAME. The Arm Body's own (200-001_ArmBody.scad): J2 on +Z through the origin, the bottom
// face at z = -7, the top at 91, the L2 tube's socket on ±Y and the lug columns on the +Y half.
// The Stator Balancer's frame is this one already (200-003_StatorBalancer.scad).
//
// PLACEMENT, each part by a feature it carries:
//
//   - Two 6810s (008.5 steps 1-2): one in the bore under the L1 ledge, z -7 .. 0
//     (200-001's L1), the other pressed down the bore onto the L2 ledge, z 54 .. 61.
//   - J2's drive, closing from the pivot up. The Pivot Motor End Cap (#312-001)
//     turned over, its land in the L1 6810, its top face flush with the bearing's
//     lower face, as pivot_assembly.scad puts it on the Main Pivot's J2 end face.
//     The motor's rear on the cap's seat, its face MOTOR_LEN above; the Wave Gen
//     Coupler wgc_above_motor() over the face, with its grub screw and nut where
//     its source draws them; the Flex Spline Attach (no hub drop)
//     on the face, its land in the L2 6810; the flexspline's hub on its hub face,
//     the Flex Spline Cap inside the cup and the six M2 hub screws up through both;
//     C-201's circular spline drive_span() above the hub face, the wave generator
//     inside it on the coupler's stub. The spline's flange must then bear on the
//     Pivot Stator Holder's floor, echoed as j2_drive_gap and asserted: the
//     holder's revised floor is set for it (200-002_PivotStatorHolder.scad).
//   - The Pivot Stator Holder turned over, its body down the bore, its back face
//     on the Balancers' lips: their shanks are z 86 .. 96 and their
//     lips z 96 .. 98, so the holder's back face is the lips' underside, z 96. The flange then
//     stands above the Arm Body's top face, which is the span the all-thread nuts take up
//     (specs/008.5 step 5), echoed as holder_flange_gap.
//   - The four Balancers in the K1 slots on 0/90/180/270°, centred in the slot, the
//     shank's inner face on the slot's inner radius.
//   - Each Belt Director's head on the face of its lower MR128, its shank up through the plates: A the
//     Large, B and C the Small. The MR128s sit in the Ø12 pockets on each plate's outer face, seated
//     against the pocket's end. Its cap sits on the upper MR128's face, plug down the core: the shank is the
//     span between the two bearings' outer faces, so it ends flush with them (asserted).
//     the disc bears on the inner race and on the shank end
//   - The idler column D: the Idler Plug through both plates, its tube's end flush with the lower
//     plate's face and its head on the upper plate's; the MR85 on the tube at the pulley's lower face,
//     and the pulley centred in the gap between D's plates.
//
// GEOMETRY. The printed parts are the binary mesh cache `render.rs 200-ArmBody --meshes`
// builds in out/asm/, so run it first. Vendor parts are envelopes at catalogue size.

use <200-002_PivotStatorHolder.scad>
use <../print_fit.scad>
use <../c101_motor.scad>
use <../300-Pivot/311-001_MotorEndCapBase.scad>
use <../600-StrainWave/630-004_WaveGenCoupler.scad>
use <../600-StrainWave/630-005_FlexSplineAttach.scad>
use <../600-StrainWave/630-006_FlexSplineCap.scad>
use <../600-StrainWave/c201_spline_seat.scad>

part = "all";   // "all", or one name from PARTS for per-part export

$fn = 96;

// --- Features, each in its own part's frame ---------------------------------
ARM_TOP        = 91.000;           // #200-001 top face
ARM_BOTTOM     = -7.000;           // #200-001 bottom face
BRG_SEAT       = [-7.000, 0.000];  // #200-001 L1: the 6810's seat below the ledge
HOLDER_FLANGE  = [0.000, 2.000];   // #200-002 flange, z in its own frame
HOLDER_END     = pivot_back("revised");  // #200-002 revised back face, z in its own frame
HOLDER_BACK    = 96.000;           // #200-003 SHANK top, LIP underside
BAL_RADIAL     = 33.516 + 0.050;   // #200-001 K1 inner radius, the press clearance to the shank
BAL_WIDTH      = 9.900;            // #200-003 WIDTH
B6810          = [50, 65, 7];
MR128          = [8, 12, 3.5];
MR85           = [5, 8, 2.5];
COL_A          = [-40.638, 14.634];
COL_B          = [ 40.638, 14.634];
COL_C          = [-33.029, 38.547];
COL_D          = [ 34.968, 51.546];
A_BRG_LOWER = 55.750;  A_UPPER_FLOOR = 78.250;   // #200-001 PLATES: A's lower plate's face, its pocket 3.5 deep from the ceiling at 59.25 (revised opens it at C's 55.65)
B_LOWER = 65.050;                              // #200-001 B_OPEN_Z: revised extends B's lower plate 0.7 below PLATES' 65.75
C_LOWER = 55.650;  C_UPPER_FLOOR = 68.850;
D_LOWER = 55.650;                              // lower plate's outer face
D_GAP   = [60.250, 68.250];                   // the plates' inner faces
D_UPPER = 70.250;                             // D's upper plate, outer face
PULLEY  = [-8.136, -0.744];                   // #210-002 z span in its frame
PLUG    = [14.600, 16.600];                   // #210-003 tube length (D's depth), head top
LARGE   = 26.000;  SMALL = 16.700;             // #210-005, #210-004 revised shank length: the span between the outer bearings (A; B and C)

// --- Placement --------------------------------------------------------------
HOLDER_Z      = HOLDER_BACK + HOLDER_FLANGE[0];  // holder turned over: world = HOLDER_Z - z
PULLEY_Z      = (D_GAP[0] + D_GAP[1]) / 2 - (PULLEY[0] + PULLEY[1]) / 2;
PULLEY_LOW    = PULLEY[0] + PULLEY_Z;
PLUG_TIP_Z    = D_LOWER;                         // the tube's end flush with the lower plate's face

// J2's drive, from the Pivot Motor End Cap up. The cap's land is in the L1
// 6810, its top face flush with the bearing's lower face; the motor's rear on
// its seat; the Attach on the motor face, its land in the L2 6810.
CAP_LAND   = cap_land();                       // #312-001 (#311-001's source): the 6810's journal
CAP_SEAT   = cap_seat("revised");              // the motor's rear
MOTOR_LEN  = c101_len();                       // C-101 body length; replace with the measured one
M2_SCREW   = [2.000, 3.800, 2.000, 16.000];    // the hub screws: shank Ø, head Ø, head height, length under the head
BRG_UPPER  = 54.000;                           // #200-001 L2: the Attach's 6810 on the upper ledge
CAP_Z      = BRG_SEAT[1] + CAP_LAND[0];        // cap turned over: world = CAP_Z - z
MOTOR_REAR = CAP_Z - CAP_SEAT;
MOTOR_F    = MOTOR_REAR + MOTOR_LEN;           // motor face, looking up
ATTACH_Z   = MOTOR_F - attach_motor_face();    // world = ATTACH_Z + z
HUB_F      = ATTACH_Z + attach_hub_face("revised", 0);
CS_FACE    = HUB_F + drive_span();             // circular spline outer face, looking up
FLOOR_Z    = HOLDER_Z - pivot_floor("revised");  // #200-002's floor, facing up
J2_GAP     = CS_FACE - spline_flange()[1] - FLOOR_Z;  // the spline's flange over the floor; 0 closes
COUPLER_Z  = MOTOR_F + wgc_above_motor();      // world = COUPLER_Z + z
WG_INNER   = CS_FACE - wg_hub_inner();
WG_OUTER   = CS_FACE - wg_hub_outer();
WG_SCREWS  = CS_FACE - wg_set_screws();

assert(abs(CAP_LAND[1] - CAP_LAND[0] - B6810[2]) < 1e-9, "the End Cap's land is not the 6810's width");
assert(abs(J2_GAP) < 1e-6, "J2's drive does not close on the Pivot Stator Holder's floor; see j2_drive_gap");
assert(BRG_UPPER > MOTOR_F && BRG_UPPER + B6810[2] < HUB_F, "the L2 6810 is not on the Attach's land");
assert(WG_INNER - (COUPLER_Z + wgc_cone_top("revised")) >= fit_clearances("revised")[2] - 1e-9,
       "the coupler's shoulder comes within the running clearance of the wave generator");
assert(COUPLER_Z + wgc_top("revised") - WG_SCREWS >= 1.5, "the coupler's stub does not pass the wave generator's set screws");

echo(j2_motor_face_z = MOTOR_F);
echo(j2_upper_6810_above_motor = BRG_UPPER - MOTOR_F);
echo(j2_spline_face_z = CS_FACE);
echo(j2_drive_gap = round(J2_GAP * 1000) / 1000 + 0);
echo(j2_wg_outer_z = WG_OUTER);
echo(j2_wg_above_holder = WG_OUTER - HOLDER_Z);
echo(j2_coupler_under_wg = WG_INNER - (COUPLER_Z + wgc_cone_top("revised")));   // coupler shoulder's top to the wave generator
echo(j2_stub_past_set_screws = COUPLER_Z + wgc_top("revised") - WG_SCREWS);
echo(holder_flange_gap = HOLDER_Z - HOLDER_FLANGE[1] - ARM_TOP);   // flange's face over the arm's top
echo(holder_body_below_top = ARM_TOP - (HOLDER_Z - HOLDER_END));   // body's depth in the bore
echo(pulley_span = str(PULLEY_LOW, " .. ", PULLEY[1] + PULLEY_Z));
assert(abs(PLUG_TIP_Z + PLUG[0] - D_UPPER) < 1e-6, "the plug's tube does not span D");

// --- Parts ------------------------------------------------------------------
module printed(id) import(str("out/asm/", id, ".stl"), convexity = 10);

module arm_body() color("#9aa7b4") printed("200-001");
module holder()   color("#c65f4f") translate([0, 0, HOLDER_Z]) rotate([180, 0, 0]) printed("200-002");
module balancers() color("#d99a45") for (a = [0 : 90 : 270]) rotate(a)
  translate([BAL_RADIAL, -BAL_WIDTH / 2, 0]) printed("200-003");

module tube(od, id, h) difference() { cylinder(d = od, h = h); translate([0, 0, -1]) cylinder(d = id, h = h + 2); }
module bearing(b, z0) translate([0, 0, z0]) tube(b[1], b[0], b[2]);

// J2's drive, each part in its own frame carried onto the arm body.
module j2_cap()     color("#c98a3a") translate([0, 0, CAP_Z]) rotate([180, 0, 0])
                      import("../300-Pivot/out/asm/312-001.stl", convexity = 8);
module motor()      color("#50565c") translate([0, 0, MOTOR_REAR]) c101_motor_envelope(MOTOR_LEN);
module attach()     color("#e3b060") translate([0, 0, ATTACH_Z]) flex_spline_attach("revised", 0);
module coupler()    color("#e8c547") translate([0, 0, COUPLER_Z]) wave_gen_coupler("revised");
module grub_screw() color("#6f7782") translate([0, 0, COUPLER_Z]) wgc_grub_screw();   // the coupler's M3 x 4 grub screw
module coupler_nut() color("#8a929b") translate([0, 0, COUPLER_Z]) wgc_nut();        // and its nut
module fs_cap()     color("#c98a3a") translate([0, 0, HUB_F + fs_hub()[1] + cap_face()]) rotate([180, 0, 0])
                      flex_spline_cap("revised");
// The six M2 hub screws, in the Attach's frame: each head under its seat,
// the shank up through the hub into the Cap's nut.
module hub_screws() color("#6f7782") translate([0, 0, ATTACH_Z]) fs_hub_holes()
  translate([0, 0, attach_head_seat("revised")]) {
    translate([0, 0, -M2_SCREW[2]]) cylinder(d = M2_SCREW[1], h = M2_SCREW[2], $fn = 48);
    cylinder(d = M2_SCREW[0], h = M2_SCREW[3], $fn = 24);
  }
module flexspline() color("#8f969c") translate([0, 0, HUB_F]) flexspline_envelope();
// C-201's spline and wave generator in the spline's frame, outer face up.
module drive_frame() translate([0, 0, CS_FACE]) children();
module circular_spline() color("#2a9d8f") drive_frame() circular_spline_envelope();
module wave_gen()        color("#b58ac9") drive_frame() wave_generator_envelope();

// The two 6810s split into their races, for the clash check's bearing rule:
// "lower" under L1 on the End Cap's land, "upper" on L2 on the Attach's.
BEARINGS   = [["bearing_lower", BRG_SEAT[0]], ["bearing_upper", BRG_UPPER]];
RACES      = ["outer", "inner", "shield"];
RACE_PARTS = [for (b = BEARINGS, r = RACES) str(b[0], "_", r)];   // `part` only, not in PARTS
module bearing_race(z0, race, $fn = 360) translate([0, 0, z0]) {
  if (race == "outer")  tube(B6810[1], 60.5, B6810[2]);
  if (race == "inner")  tube(54.5, B6810[0], B6810[2]);
  if (race == "shield") translate([0, 0, 0.6]) tube(60.5, 54.5, B6810[2] - 1.2);
}

// Each Belt Director: its name, its column, the z of its head's top (its lower MR128's face), its shank's length,
// part and the z of the upper MR128's face.
DIRECTORS = [["A", COL_A, A_BRG_LOWER, LARGE, "210-005", A_UPPER_FLOOR + MR128[2]],
             ["B", COL_B, B_LOWER,     SMALL, "210-004", A_UPPER_FLOOR + MR128[2]],
             ["C", COL_C, C_LOWER,     SMALL, "210-004", C_UPPER_FLOOR + MR128[2]]];
function short_of_cap(d) = d[5] - (d[2] + d[3]);   // the shank's end under the bearing's face

for (d = DIRECTORS) assert(abs(short_of_cap(d)) < 1e-6, str("the shank of director ", d[0], " does not end at its bearing"));

module directors() color("#2f6db5") for (d = DIRECTORS) translate([d[1][0], d[1][1], d[2]]) printed(d[4]);
module caps() color("#5b9be0") for (d = DIRECTORS) translate([d[1][0], d[1][1], d[5]]) printed("210-001");
module bearing_6810(z0) color("#dcdcdc") for (r = RACES) bearing_race(z0, r);
module bearings_mr128() color("#dcdcdc") {
  for (p = [[COL_A, A_BRG_LOWER], [COL_A, A_UPPER_FLOOR], [COL_B, B_LOWER], [COL_B, A_UPPER_FLOOR],
            [COL_C, C_LOWER], [COL_C, C_UPPER_FLOOR]])
    translate([p[0][0], p[0][1], 0]) bearing(MR128, p[1]);
}
module idler_plug() color("#5b9be0") translate([COL_D[0], COL_D[1], PLUG_TIP_Z]) printed("210-003");
module idler_bearing() color("#dcdcdc") translate([COL_D[0], COL_D[1], 0]) bearing(MR85, PULLEY_LOW);
module pulley() color("#4f86c6") translate([COL_D[0], COL_D[1], PULLEY_Z]) printed("210-002");

PARTS = ["arm_body", "holder", "balancers", "bearing_lower", "bearing_upper", "directors", "caps",
         "bearings_mr128", "idler_plug", "idler_bearing", "pulley", "j2_cap", "motor", "coupler", "grub_screw", "coupler_nut", "attach",
         "hub_screws", "fs_cap", "flexspline", "wave_gen", "circular_spline"];

module draw(p) {
  if (p == "arm_body")       arm_body();
  if (p == "holder")         holder();
  if (p == "balancers")      balancers();
  if (p == "bearing_lower")  bearing_6810(BRG_SEAT[0]);
  if (p == "bearing_upper")  bearing_6810(BRG_UPPER);
  if (p == "j2_cap")         j2_cap();
  if (p == "motor")          motor();
  if (p == "coupler")        coupler();
  if (p == "grub_screw")     grub_screw();
  if (p == "coupler_nut")    coupler_nut();
  if (p == "attach")         attach();
  if (p == "hub_screws")     hub_screws();
  if (p == "fs_cap")         fs_cap();
  if (p == "flexspline")     flexspline();
  if (p == "wave_gen")       wave_gen();
  if (p == "circular_spline") circular_spline();
  for (b = BEARINGS, r = RACES) if (p == str(b[0], "_", r)) color("#dcdcdc") bearing_race(b[1], r);
  if (p == "directors")      directors();
  if (p == "caps")           caps();
  if (p == "bearings_mr128") bearings_mr128();
  if (p == "idler_plug")     idler_plug();
  if (p == "idler_bearing")  idler_bearing();
  if (p == "pulley")         pulley();
}

for (p = PARTS) if (part == "all" || part == p) draw(p);
for (p = RACE_PARTS) if (part == p) draw(p);
