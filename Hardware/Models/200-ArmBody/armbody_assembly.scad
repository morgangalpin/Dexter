// 200-ArmBody assembly — placement model.
// Places the Arm Body's parts, the 6810 under it, the four Stator Balancers, the three
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
//   - The 6810 in the bore under the L1 ledge, z -7 .. 0 (200-001's L1).
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

part = "all";   // "all", or one name from PARTS for per-part export

$fn = 96;

// --- Features, each in its own part's frame ---------------------------------
ARM_TOP        = 91.000;           // #200-001 top face
ARM_BOTTOM     = -7.000;           // #200-001 bottom face
BRG_SEAT       = [-7.000, 0.000];  // #200-001 L1: the 6810's seat below the ledge
HOLDER_FLANGE  = [0.000, 2.000];   // #200-002 flange, z in its own frame
HOLDER_END     = 12.000;          // #200-002 revised back face (pivot_back("revised")), z in its own frame
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

// Each Belt Director: its name, its column, the z of its head's top (its lower MR128's face), its shank's length,
// part and the z of the upper MR128's face.
DIRECTORS = [["A", COL_A, A_BRG_LOWER, LARGE, "210-005", A_UPPER_FLOOR + MR128[2]],
             ["B", COL_B, B_LOWER,     SMALL, "210-004", A_UPPER_FLOOR + MR128[2]],
             ["C", COL_C, C_LOWER,     SMALL, "210-004", C_UPPER_FLOOR + MR128[2]]];
function short_of_cap(d) = d[5] - (d[2] + d[3]);   // the shank's end under the bearing's face

for (d = DIRECTORS) assert(abs(short_of_cap(d)) < 1e-6, str("the shank of director ", d[0], " does not end at its bearing"));

module directors() color("#2f6db5") for (d = DIRECTORS) translate([d[1][0], d[1][1], d[2]]) printed(d[4]);
module caps() color("#5b9be0") for (d = DIRECTORS) translate([d[1][0], d[1][1], d[5]]) printed("210-001");
module bearings_6810() color("#dcdcdc") bearing(B6810, BRG_SEAT[0]);
module bearings_mr128() color("#dcdcdc") {
  for (p = [[COL_A, A_BRG_LOWER], [COL_A, A_UPPER_FLOOR], [COL_B, B_LOWER], [COL_B, A_UPPER_FLOOR],
            [COL_C, C_LOWER], [COL_C, C_UPPER_FLOOR]])
    translate([p[0][0], p[0][1], 0]) bearing(MR128, p[1]);
}
module idler_plug() color("#5b9be0") translate([COL_D[0], COL_D[1], PLUG_TIP_Z]) printed("210-003");
module idler_bearing() color("#dcdcdc") translate([COL_D[0], COL_D[1], 0]) bearing(MR85, PULLEY_LOW);
module pulley() color("#4f86c6") translate([COL_D[0], COL_D[1], PULLEY_Z]) printed("210-002");

PARTS = ["arm_body", "holder", "balancers", "bearing_6810", "directors", "caps", "bearings_mr128",
         "idler_plug", "idler_bearing", "pulley"];

module draw(p) {
  if (p == "arm_body")       arm_body();
  if (p == "holder")         holder();
  if (p == "balancers")      balancers();
  if (p == "bearing_6810")   bearings_6810();
  if (p == "directors")      directors();
  if (p == "caps")           caps();
  if (p == "bearings_mr128") bearings_mr128();
  if (p == "idler_plug")     idler_plug();
  if (p == "idler_bearing")  idler_bearing();
  if (p == "pulley")         pulley();
}

for (p = PARTS) if (part == "all" || part == p) draw(p);
