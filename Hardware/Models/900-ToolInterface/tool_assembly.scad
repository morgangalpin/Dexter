// 900-ToolInterface assembly — placement model.
// Places the roll stack (Roll Body, Roll Driver on its two 6703s, Span Mount with its strake) and the
// Static Finger on the Span Mount with its two MR128s, so the tool interface can be reviewed for fit by
// looking at it.
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
//   - The Static Finger's socket over the Span Mount's column, its ceiling on the column's top and its
//     slot on the upright plate (step 46): the socket is the column's section turned -90 deg about Z,
//     so its frame is the Span Mount's turned +90 deg and 1.5 lower. Its hub then stands on the Span
//     Mount's eye axis.
//   - The MR128s in their seats, against the shoulder (step 41).
//   - The four M2 x 20 roll bolts threaded up through the Roll Driver (step 7), each head in C1 against
//     its floor, through the Span Mount's H1, with an M2 washer and nut in its K1 pocket on the pocket's
//     floor (steps 17-18). The file echoes how far each bolt ends above its nut.
//   - The four satin pins in the Roll Driver's P1, flush with its end and ~6 mm proud below N1 (steps
//     5-6).
//
// NOT DRAWN. The two XL-320s, and the Tool Interface Body (#900-001), which holds them and meets the roll
// stack only through the roll XL-320 (steps 10 and 20-23), so no printed feature places it; the
// Dynamic Finger and the Finger Cap, which do not stand in this Static Finger (specs/009 § Gripper
// design); the Span Driver, whose place along the eye's axis the span servo's horn sets; and the
// fasteners into those: the Roll Body's M2 x 12 and M2 x 16 bolts, the span servo's M2 x 12 bolts and
// the Span Driver's M2.6 x 10.
//
// GEOMETRY. The printed parts are the binary mesh cache `render.rs 900-ToolInterface --meshes` builds
// in out/asm/ (revised), so run it first. Bearings are drawn at catalogue size as three parts each
// (outer and inner race, shield): `part` draws one race alone, and PARTS lists only the whole bearing.

part = "all";   // "all", or one name from PARTS or RACE_PARTS for per-part export
ROLL = 0;       // roll angle, deg

$fn = 96;

// --- Features, each in its own part's frame ---------------------------------
RD_DROP     = 4.500;                     // #911-002 shaft z 8 on the #911-001 bearing span's z 3.5
SM_RISE     = 19.000;                    // #912-001 ring foot z -2.5 on #911-002's end z 21
SF_DROP     = 1.500;                     // #920-001 socket ceiling z 24.2 on #912-001's column top z 22.7
SF_TURN     = 90;                        // #920-001 socket = #912-001 column turned -90 deg
HUB         = [14.139, 17.500];          // #920-001 hub axis (x, z), along +Y
STRAKE      = [2.337, 5.588, 1.200, 26.200];   // C-502 across x and y in #912-001's frame, z span
B6703       = [17, 23, 4, [3.5, 12.5]];  // bore, OD, width, z of each in #911-001
B6703_RACES = [18.8, 21.2];              // inner race OD, outer race ID
MR128       = [8, 12, 3.5, [10.007, 14.007]];  // bore, OD, width, y of each in #920-001
MR128_RACES = [9.2, 10.8];
ROLL_BOLT   = [2, 20, 3.8, 2, 7.995];    // M2 x 20 socket head (ISO 4762): d, length, head d, head h; under its head z in
                                         // #911-002 (revised): C1's floor, z 8.0 less the 0.005 its L3 laps down
ROLL_WASHER = [2.2, 5, 0.3, 2];          // M2 washer (DIN 125): bore, OD, thickness; on #912-001's K1 floor z 2
ROLL_NUT    = [4, 1.6];                  // M2 nut (DIN 934): across flats, height; on the washer
PIN         = [1, -1.5, 21];             // satin pin #19: d, z span in #911-002 (~6 mm proud below N1, flush at the top)
PCD_R       = 6;                         // #911-002 B1 and P1, #912-001 H1 and K1

// --- Frames -----------------------------------------------------------------
module roll_frame() rotate(ROLL) children();
module rd_frame()   roll_frame() translate([0, 0, -RD_DROP]) children();
module sm_frame()   roll_frame() translate([0, 0, SM_RISE]) children();
module sf_frame()   sm_frame() translate([0, 0, -SF_DROP]) rotate(SF_TURN) children();

// --- Parts ------------------------------------------------------------------
module printed(id) import(str("out/asm/", id, ".stl"), convexity = 10);

module roll_body()      color("#d4ad6b") printed("911-001");
module roll_driver()    color("#2f6db5") rd_frame() printed("911-002");
module span_mount()     color("#e0a458") sm_frame() printed("912-001");
module static_finger()  color("#c98a3a") sf_frame() printed("920-001");
module strake()         color("#303030") sm_frame()
    translate([-STRAKE[0] / 2, -STRAKE[1] / 2, STRAKE[2]]) cube([STRAKE[0], STRAKE[1], STRAKE[3] - STRAKE[2]]);

module tube(od, id, h) difference() { cylinder(d = od, h = h); translate([0, 0, -1]) cylinder(d = id, h = h + 2); }

// Fasteners on the roll bolt circle (steps 5-7 and 17-18): drawn at the facet counts and phase of the
// holes they stand in, so a pin or a thread in its own hole meets it line to line.
module at_pcd(start) for (a = [start : 90 : start + 270]) rotate(a) translate([PCD_R, 0, 0]) children();

// A bolt is two parts, its head and its shank, so that the shank's thread in B1 can be engaged while
// the head is still held to its clearance in C1.
module roll_bolt_heads() color("#8a8f94") rd_frame() at_pcd(45)
  translate([0, 0, ROLL_BOLT[4] - ROLL_BOLT[3]]) cylinder(d = ROLL_BOLT[2], h = ROLL_BOLT[3], $fn = 72);
module roll_bolt_shanks() color("#8a8f94") rd_frame() at_pcd(45)
  translate([0, 0, ROLL_BOLT[4]]) cylinder(d = ROLL_BOLT[0], h = ROLL_BOLT[1], $fn = 72);
module roll_washers() color("#b0b4b8") sm_frame() at_pcd(45) translate([0, 0, ROLL_WASHER[3]])
  difference() {
    cylinder(d = ROLL_WASHER[1], h = ROLL_WASHER[2], $fn = 96);
    translate([0, 0, -1]) cylinder(d = ROLL_WASHER[0], h = ROLL_WASHER[2] + 2, $fn = 72);
  }
module roll_nuts() color("#8a8f94") sm_frame() at_pcd(45) translate([0, 0, ROLL_WASHER[3] + ROLL_WASHER[2]])
  difference() {
    cylinder(d = ROLL_NUT[0] / cos(30), h = ROLL_NUT[1], $fn = 6);
    translate([0, 0, -1]) cylinder(d = ROLL_BOLT[0], h = ROLL_NUT[1] + 2, $fn = 72);
  }
module roll_pins() color("#c0c0c0") rd_frame() at_pcd(0) translate([0, 0, PIN[1]]) cylinder(d = PIN[0], h = PIN[2] - PIN[1], $fn = 48);

RACES = ["outer", "inner", "shield"];

module race(b, races, race) {
  if (race == "outer")  tube(b[1], races[1], b[2]);
  if (race == "inner")  tube(races[0], b[0], b[2]);
  if (race == "shield") translate([0, 0, 0.5]) tube(races[1], races[0], b[2] - 1);
}

BEARINGS = ["roll_lower", "roll_upper", "span_inner", "span_outer"];
RACE_PARTS = [for (b = BEARINGS, r = RACES) str(b, "_", r)];   // `part` only, not in PARTS

module bearing_in(b, r, $fn = 360) {   // at 96 a race's chords stand inside its seat's circle
  if (b == "roll_lower") translate([0, 0, B6703[3][0]]) race(B6703, B6703_RACES, r);
  if (b == "roll_upper") translate([0, 0, B6703[3][1]]) race(B6703, B6703_RACES, r);
  if (b == "span_inner") sf_frame() translate([HUB.x, MR128[3][0], HUB.y]) rotate([-90, 0, 0]) race(MR128, MR128_RACES, r);
  if (b == "span_outer") sf_frame() translate([HUB.x, MR128[3][1], HUB.y]) rotate([-90, 0, 0]) race(MR128, MR128_RACES, r);
}
module bearing(b) color("#dcdcdc") for (r = RACES) bearing_in(b, r);

PARTS = ["roll_body", "roll_driver", "span_mount", "strake", "static_finger",
         "roll_lower", "roll_upper", "span_inner", "span_outer",
         "roll_bolt_heads", "roll_bolt_shanks", "roll_washers", "roll_nuts", "roll_pins"];

module draw(p) {
  if (p == "roll_bolt_heads")  roll_bolt_heads();
  if (p == "roll_bolt_shanks") roll_bolt_shanks();
  if (p == "roll_washers")   roll_washers();
  if (p == "roll_nuts")      roll_nuts();
  if (p == "roll_pins")      roll_pins();
  if (p == "roll_body")      roll_body();
  if (p == "roll_driver")    roll_driver();
  if (p == "span_mount")     span_mount();
  if (p == "strake")         strake();
  if (p == "static_finger")  static_finger();
  for (b = BEARINGS) if (p == b) bearing(b);
  for (b = BEARINGS, r = RACES) if (p == str(b, "_", r)) color("#dcdcdc") bearing_in(b, r);
}

echo(str("roll bolt end above its nut: ",
          (ROLL_BOLT[4] + ROLL_BOLT[1] - RD_DROP) - (SM_RISE + ROLL_WASHER[3] + ROLL_WASHER[2] + ROLL_NUT[1]), " mm"));

for (p = PARTS) if (part == "all" || part == p) draw(p);
for (p = RACE_PARTS) if (part == p) draw(p);
