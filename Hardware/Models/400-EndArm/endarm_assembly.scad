// 400-EndArm assembly — placement model.
// Places the End Arm group about J3: the two Axis Intersection Halves on the L2 side, holding the
// 6807s the New Belt Pulley turns in; the End Arm Hub pegged to that pulley, with its Cap; the code
// disk on the pulley's end; and the two belt channels on their shafts: the inner channel (Internal
// Inner Pulley, its strakes, the External Inner Pulley) on the strake tube's 6703s, and the outer
// channel (the stainless tube, the Internal and External Outer Pulleys, the spacers) on its MR128s.
// It is the group as 008.7 builds it, for review by looking at it and for the clash check.
//
// FRAME. The End Arm Hub's own (420-001_EndArmHub.scad): J3 on +Z through the origin, the hub's top
// plate at z 4, the L3 spigot along +X. The arm is drawn straight: the L2 channel of the Axis
// Intersection along -X.
//
// PLACEMENT, each part by a feature it carries. Each frame below states where the part's own z
// lands; a part turned end for end runs its own z down.
//
//   - The New Belt Pulley's four pegs in the hub's four back holes, its pegged face on the hub's
//     top face (z 4); so its journals stand at z 4 .. 14 and 44 .. 51.
//   - Each Axis Intersection Half's 6807 on a journal, its pocket's floor (its lip) under the
//     bearing's outer race and the journal's shoulder on the inner race: halves at z 5 .. 29 and
//     29 .. 53, bonded face to face at z 29 (008.7 steps 1-5). The 48 mm C-502 strakes span the
//     two exactly.
//   - The code disk's raised hub on the pulley's end face (z 51), its flat face out, so it turns
//     with the hub past the halves (008.7 step 14).
//   - The Cap in the hub's open end (z -38 .. -30), its flat to the opening's (008.7 step 20).
//   - The Internal Inner Pulley's band in the hub's cavity, its journal up through the hub's 6703
//     and the pulley's three 6703s; its boss's face on the hub 6703's inner race.
//   - The External Inner Pulley's counterbore floor on that journal's end: the 81 mm C-503
//     strakes, flush with the Internal Inner Pulley's band face, then end flush with its far face,
//     as 008.7 step 6 has them.
//   - The stainless tube's lower end in the Cap's MR128; the Internal Outer Pulley's hub end on
//     that bearing's inner race; a spacer between it and the Internal Inner Pulley; a second
//     spacer, then the External Outer Pulley, beyond the External Inner (008.7 steps 9-11, 21-22).
//     The tube's 113 mm then ends in the External Outer Pulley's bore. STACK below derives each z.
//   - Each bearing on the seat or shoulder named where its z is set.
//
// Provisional: the turns of the pulleys and of the code disk about J3 are their own frames';
// nothing fixes them. The spacers' faces, and which bearing face each shoulder meets, are read from
// 008.7 and the parts, not from a drawing.
//
// GEOMETRY. The printed parts are the binary mesh cache `render.rs 400-EndArm --meshes` builds in
// out/asm/ (revised), so run it first. Vendor parts are envelopes at catalogue size.
//
// CLASH. assembly-clash.rs against endarm_assembly.clash.json. A bearing is three parts,
// <bearing>_inner, _outer and _shield, which `part` draws one at a time and PARTS does not list.

part = "all";   // "all", or one name from PARTS for per-part export

$fn = 96;

// --- Bearings, at catalogue size (007.1): [d, D, B, the corner chamfer r_s min] ---------------
B6807       = [35, 47, 7, 0.3];     // C-402
B6703       = [17, 23, 4, 0.2];     // C-404
MR128       = [8, 12, 3.5, 0.1];    // C-405
RACE_FN     = 360;          // facets of the races' envelopes: their chords stand within the
                            // clash check's slack of the printed seats

// --- Placements: the hub-frame z of each part's own z = 0, and whether it turns end for end ------
AI_Z        = [5.000, 53.000];      // #410-001 halves; the second is turned end for end
PULLEY_Z    = 42.000;               // #410-002, end for end: its pegged face (38) on the hub's top (4)
DISK_Z      = 55.000;               // #410-003, end for end: raised hub (4) on the pulley's end (51)
CAP_Z       = -38.000;              // #420-002: its plain face on the opening's bottom

// STACK. Two chains run along J3. The Cap, fixed in the hub, seats an MR128 on its pocket's floor
// (own z 4); #421-001's hub end (own 17.5) sits on that bearing's inner race; the first spacer
// stands on #421-001's slotted face (33); #421-002's face (30) on the spacer's flange; and its boss
// (16.5) under the inner race of the hub's 6703, whose outer race is on #420-001's seat (S1's floor,
// z -0.150, where its 45 deg cone starts). With the reference's spacer (1.800) that chain is 0.450
// too long; the revised spacer's hub is that much shorter (421-006 STACK_TRIM), and the assert below
// holds the chain closed. The second chain is clamped on the stainless tube by #421-001's and
// #430-001's set screws: #430-002's counterbore floor (own 27.5) on #421-002's journal end (-42.5),
// the second spacer on #430-002's far face (19.0), and #430-001's top face (32) on that spacer. The
// tube's lower end is 3.1 below #421-001's hub end (008.7 step 9).
SEAT_FLOOR  = -0.150;                           // #420-001 S1's floor
SPACER_H    = 1.350;                            // #421-006 revised: 1.800 less STACK_TRIM
CAP_FLOOR   = CAP_Z + 4.000;                    // #420-002 B2's floor
INT_OUTER_Z = CAP_FLOOR + MR128[2] - 17.500;    // #421-001
SPACER_A_Z  = INT_OUTER_Z + 33.000 + SPACER_H;  // #421-006, the first, end for end
INT_INNER_Z = SPACER_A_Z + 30.000;              // #421-002, end for end
EXT_INNER_Z = INT_INNER_Z + 42.500 + 27.500;    // #430-002, end for end
SPACER_B_Z  = EXT_INNER_Z - 19.000;             // #421-006, the second
EXT_OUTER_Z = SPACER_B_Z + SPACER_H + 32.000;   // #430-001, end for end
SPACER_Z    = [SPACER_A_Z, SPACER_B_Z];
assert(abs(INT_INNER_Z - 16.500 - SEAT_FLOOR) < 1e-6, "the Cap-to-6703 chain does not close");

TUBE        = [8.000, 6.000, 113.000, INT_OUTER_Z + 17.500 - 3.100];   // C-507: OD, ID, length, lower end z
// Each bearing's lower face. 6807s: on the halves' pocket lips, under 410-002's shoulders (14, 44).
// 6703s: the hub's on S1's floor; two on 410-002's lower pocket floor (12.5) and one on its upper
// (45.5) (008.7 step 7). MR128s: the Cap's on its pocket floor; the other on #421-002's B2 floor
// (own 25.8).
B6807_Z     = [7.000, 44.000];
B6703_Z     = [SEAT_FLOOR, 12.500 - 2 * B6703[2], 12.500 - B6703[2], 45.500];
MR128_Z     = [CAP_FLOOR, INT_INNER_Z - 25.800 - MR128[2]];

C502        = [2.337, 5.588];       // the 48 mm strakes' section: radial, tangential
C502_AT     = [34.016, [54, 126, -54, -126], 48.000];   // #410-001 S1: r, angles in its frame, length
C503        = [1.450, 4.500, 81.000];   // the 81 mm strakes: radial, tangential, length
C503_AT     = [7.091, [90, 210, 330]];  // #421-002 S1: r, angles in its frame
ROD         = [3.000, 15.250, -30.000, 57.000];   // M3 all-thread: Ø, centre r, lower and upper z

L3_TUBE     = [22.000, 20.070, 28.500, -25.000, 40.000];   // C-505: OD, ID, butt x, axis z, stub length
L2_TUBE     = [28.750, 26.213, -37.500, 29.000, 40.000];   // C-504: OD, ID, butt x, axis z, stub length

// --- Frames -----------------------------------------------------------------------------------
module flip() rotate([180, 0, 0]) children();
module ai_frame(k) translate([0, 0, AI_Z[k]]) rotate(-90) if (k == 0) children(); else rotate([0, 180, 0]) children();
module pulley_frame()    translate([0, 0, PULLEY_Z]) flip() children();
module disk_frame()      translate([0, 0, DISK_Z]) flip() children();
module cap_frame()       translate([0, 0, CAP_Z]) rotate(180) children();
module int_outer_frame() translate([0, 0, INT_OUTER_Z]) children();
module spacer_frame(k)   translate([0, 0, SPACER_Z[k]]) if (k == 0) flip() children(); else children();
module int_inner_frame() translate([0, 0, INT_INNER_Z]) flip() children();
module ext_inner_frame() translate([0, 0, EXT_INNER_Z]) flip() children();
module ext_outer_frame() translate([0, 0, EXT_OUTER_Z]) flip() children();

// --- Parts ------------------------------------------------------------------------------------
module printed(id) import(str("out/asm/", id, ".stl"), convexity = 10);

module hub()        color("#d4ad6b") printed("420-001");
module cap()        color("#c98a3a") cap_frame() printed("420-002");
module ai_a()       color("#9aa7b4") ai_frame(0) printed("410-001");
module ai_b()       color("#8795a3") ai_frame(1) printed("410-001");
module belt_pulley() color("#2f6db5") pulley_frame() printed("410-002");
module code_disk()  color("#5c8fd6") disk_frame() printed("410-003");
module int_outer()  color("#e0a458") int_outer_frame() printed("421-001");
module int_inner()  color("#7fb069") int_inner_frame() printed("421-002");
module spacer_a()   color("#e8c87a") spacer_frame(0) printed("421-006");
module spacer_b()   color("#e8c87a") spacer_frame(1) printed("421-006");
module ext_inner()  color("#6a9d58") ext_inner_frame() printed("430-002");
module ext_outer()  color("#d08c3a") ext_outer_frame() printed("430-001");

module tube(od, id, h) difference() { cylinder(d = od, h = h); translate([0, 0, -1]) cylinder(d = id, h = h + 2); }

module shaft() color("#b8bcc0") translate([0, 0, TUBE[3]]) tube(TUBE[0], TUBE[1], TUBE[2]);

// The four 48 mm C-502 strakes, in the halves' slots, end to end with the bonded pair.
module strakes_ai() color("#303030") ai_frame(0) for (a = C502_AT[1]) rotate(a)
    translate([C502_AT[0] - C502[0] / 2, -C502[1] / 2, 0]) cube([C502[0], C502[1], C502_AT[2]]);

// The three 81 mm C-503 strakes, flush with the Internal Inner Pulley's band face.
module strakes_inner() color("#303030") int_inner_frame() for (a = C503_AT[1]) rotate(a)
    translate([C503_AT[0] - C503[0] / 2, -C503[1] / 2, 30.000 - C503[2]]) cube([C503[0], C503[1], C503[2]]);

// The four M3 all-thread rods, threaded into the hub and out through the code disk.
module rods() color("#707070") for (a = [0 : 90 : 270]) rotate(a)
    translate([ROD[1], 0, ROD[2]]) cylinder(d = ROD[0], h = ROD[3] - ROD[2], $fn = 24);

// Square CF tube stubs, square to Y and Z: C-505 on the spigot to the counterbore's floor, C-504
// in the halves' channel to its blind end.
module square_tube(od, id, len) difference() {
    linear_extrude(len) offset(r = 1) offset(delta = -1) square(od, center = true);
    translate([0, 0, -1]) linear_extrude(len + 2) offset(r = 0.5) offset(delta = -0.5) square(id, center = true);
}
module l3_tube() color("#202020") translate([L3_TUBE[2], 0, L3_TUBE[3]]) rotate([0, 90, 0]) square_tube(L3_TUBE[0], L3_TUBE[1], L3_TUBE[4]);
module l2_tube() color("#202020") translate([L2_TUBE[2], 0, L2_TUBE[3]]) rotate([0, -90, 0]) square_tube(L2_TUBE[0], L2_TUBE[1], L2_TUBE[4]);

// --- Bearings ---------------------------------------------------------------------------------
RACES = ["outer", "inner", "shield"];

// One race of a bearing [d, D, B, r_s] standing on z0: a third of the section each, so a race's
// land (the inner race's outside, the outer race's inside) is a third of the way across, where the
// parts that seat on one race keep their rebates (FITS in 410-002, 410-003, 420-002 and 421-001).
// The bore's and the outside's corners take the catalogue chamfer, so a race on a 45 deg seat
// cone's edge stands clear of the cone. The shield sits SHIELD below both faces.
SHIELD = 0.35;      // as 700-Differential's diff_hardware.scad draws it (HW_SHIELD)
module race(b, race, z0, $fn = RACE_FN) translate([0, 0, z0]) {
    w = (b[1] - b[0]) / 2;
    c = b[3];
    ri = b[0] / 2;
    ro = b[1] / 2;
    if (race == "inner")  rotate_extrude() polygon([[ri + c, 0], [ri + w / 3, 0], [ri + w / 3, b[2]],
                                                    [ri + c, b[2]], [ri, b[2] - c], [ri, c]]);
    if (race == "outer")  rotate_extrude() polygon([[ro - w / 3, 0], [ro - c, 0], [ro, c], [ro, b[2] - c],
                                                    [ro - c, b[2]], [ro - w / 3, b[2]]]);
    if (race == "shield") translate([0, 0, SHIELD]) tube(b[1] - 2 * w / 3, b[0] + 2 * w / 3, b[2] - 2 * SHIELD);
}

BEARINGS = ["b6807_a", "b6807_b", "b6703_hub", "b6703_lower_a", "b6703_lower_b", "b6703_upper",
            "mr128_cap", "mr128_inner"];
function bearing_of(b) =
    b == "b6807_a"       ? [B6807, B6807_Z[0]] :
    b == "b6807_b"       ? [B6807, B6807_Z[1]] :
    b == "b6703_hub"     ? [B6703, B6703_Z[0]] :
    b == "b6703_lower_a" ? [B6703, B6703_Z[1]] :
    b == "b6703_lower_b" ? [B6703, B6703_Z[2]] :
    b == "b6703_upper"   ? [B6703, B6703_Z[3]] :
    b == "mr128_cap"     ? [MR128, MR128_Z[0]] :
                           [MR128, MR128_Z[1]];
RACE_PARTS = [for (b = BEARINGS, r = RACES) str(b, "_", r)];   // `part` only, not in PARTS

module bearing_in(b, r) let (s = bearing_of(b)) race(s[0], r, s[1]);
module bearing(b) color("#dcdcdc") for (r = RACES) bearing_in(b, r);

PARTS = ["hub", "cap", "ai_a", "ai_b", "belt_pulley", "code_disk", "int_outer", "int_inner",
         "spacer_a", "spacer_b", "ext_inner", "ext_outer", "shaft", "strakes_ai", "strakes_inner",
         "rods", "l3_tube", "l2_tube", "b6807_a", "b6807_b", "b6703_hub", "b6703_lower_a",
         "b6703_lower_b", "b6703_upper", "mr128_cap", "mr128_inner"];

module draw(p) {
  if (p == "hub")           hub();
  if (p == "cap")           cap();
  if (p == "ai_a")          ai_a();
  if (p == "ai_b")          ai_b();
  if (p == "belt_pulley")   belt_pulley();
  if (p == "code_disk")     code_disk();
  if (p == "int_outer")     int_outer();
  if (p == "int_inner")     int_inner();
  if (p == "spacer_a")      spacer_a();
  if (p == "spacer_b")      spacer_b();
  if (p == "ext_inner")     ext_inner();
  if (p == "ext_outer")     ext_outer();
  if (p == "shaft")         shaft();
  if (p == "strakes_ai")    strakes_ai();
  if (p == "strakes_inner") strakes_inner();
  if (p == "rods")          rods();
  if (p == "l3_tube")       l3_tube();
  if (p == "l2_tube")       l2_tube();
  for (b = BEARINGS) if (p == b) bearing(b);
  for (b = BEARINGS, r = RACES) if (p == str(b, "_", r)) color("#dcdcdc") bearing_in(b, r);
}

for (p = PARTS) if (part == "all" || part == p) draw(p);
for (p = RACE_PARTS) if (part == p) draw(p);
