// #100-003 Pivot Skirt — parametric source.
// A skirt around J1's pivot that hangs from the base. Three M3 screws through its collar hold it, and
// a hollow lug on +X carries a duct up its side and out through a 45° hood.
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/100-Base/), in that mesh's frame.
//   config = "revised"  — the same part with print fits on the screw holes.
//
// FRAME. The skirt's axis is Y, through the origin. y = 0 is where the round skirt meets the
// octagonal frame, and the part spans y -26 .. 20. The lug is on +X, and the flange runs out along -X
// at the top (+Z). The reference mesh is already in this frame.
//
// CONSTRUCTION. A region split, joined on y = 0 and where the lug turns:
//
//     skirt   y -26 .. 0     one XZ section (S1, F1, L1 with its fillets, E1), extruded along Y
//     rim     y 0 .. 5.8     the S1 annulus carried up, with O2 cut on the 90° and ±45° faces and
//                            L2's foot and fillets over it on +X
//     frame   y 0 .. 20      one (d, y) profile swept along an open octagon path: linear_extrude
//                            along each face, rotate_extrude(45) about each core vertex. d is the
//                            offset from the core octagon's face. O6 is the same sweep with the
//                            collar slot filled.
//     lug     L1, L2         a 2D section extruded along each leg (L1 along Y, L2 at 45°). L2
//                            starts on the plane square to its leg through the outer bend line,
//                            and L1 runs up to that plane, under L2's outside. The pocket L3
//                            likewise, with the plug unioned into it before K1 cuts through plug
//                            and skirt
//     cutters K1, K2, H1     primitive slot and hole cutters
//     round   L4             a rolling-ball round lofted along the bend edge (bend_round)
//
// `layer = "skirt"`, `"frame"` or `"hood"` draws that 2D profile in the coordinates of the mesh
// section it is checked against (scadmesh outline). render.rs --verify checks the skirt and the frame.
// H1's hole crosses every section of the hood, so the hood is left to the 3D gate.
//
// Measured from the reference with scadmesh planes/slice/arcs/solid/transform. The feature IDs are
// those of 100-003_PivotSkirt.view.json, which labels each one on the mesh:
//
//     ID  feature                       value
//     S1  skirt                         R48.000 .. R50.000 about Y, y -26 .. 0
//     F1  flange                        z 45.438 .. 48.500, out to x -35.645
//     E1  bottom end                    plane x 12.355
//     K1  slot on +X                    8.400 wide (|z| < 4.2), y -26 .. -13, square end
//     K2  slots at ±39.92°              walls parallel to the ray, y -26 .. -13, end corners R2.000;
//                                       on +z 7.893 out and 7.250 in from it, on -z 7.800 and 7.343
//     O1  taper                         core octagon apothem 29.483; outer d 19.017 to y 5.71, then
//                                       d = 24.727 - y (45°) to y 20; the knee between them R1.000
//                                       from the middle of the +X face round to F1, sharp below
//     O2  rim chamfer                   S1's R50 cut by d = 20.467 - y on the 90° and ±45° faces;
//                                       on +X it runs up under L2's foot
//     O3  inner ridge and groove        base chamfer d = 15.955 - y; ridge R0.600 onto a step at
//                                       y 3.000; groove flank d = y + 11.547 out to the inner face
//     O4  collar                        d 3.017 .. 6.017 (apothem 32.500 .. 35.500), chamfer
//                                       d = 15.955 - y below; inner face d = 20.487 - y outside it
//     O5  collar slot                   between O4 and the inner face, open below
//     O6  end caps                      3.000 long at each end of the path, O5 filled
//     H1  screw bosses at 0°, ±45°      y 12: boss Ø11.900 filling O5; spacer Ø5.900 from O4's
//                                       inner face, its edge onto O4's chamfer chamfered 1.000
//                                       along each face; Ø3.000 through; from d 7.017 outward
//                                       Ø6.200 at 0° (through L3 and L1) and Ø5.900 at ±45°, every
//                                       edge where they cross a face rounded R1.000 (rolling ball),
//                                       on the lug over L4 as well
//     L1  lug                           corners R5.170 about (49.830, ±3.990), face x 55, R2 fillets
//     L2  hood                          square to its leg: face x' 47.526 for |z| <= 4.000, then
//                                       sides that are R5.164 semicircles about z ±4.000 stretched
//                                       √2 along x' (half ellipses, tangent to the face); a foot
//                                       ramping (dx'/dz 0.326) from the taper face's edges, and
//                                       R2 fillets to it
//     L3  pocket                        L1: R3.000 about L1's centres, out to x 52.840, inside to S1;
//                                       L2: face x' 44.471, sides as L2's at R3.000, inner arc
//                                       R35.500 (x' 40.455 at z 0); open at y 20. Plug
//                                       |z| < 4 below a ramp along L2's leg, arched R70.000 across
//                                       z, crest x' 31.906
//     L4  bend round                    R1.000 where L1's outside meets L2's: along the bend line,
//                                       over L1's corners and fillets, and on down onto S1 and
//                                       L2's foot, out to where S1 dips under O1's face. It rounds
//                                       S1, not O1: it dies away onto O1's face, and past it on +z
//                                       S1 stays inside O1's knee round
//
// x' is the distance along (1, 1, 0)/√2, square to the hood's leg. The onshape-v1 STEP
// (KP0016-01_PivotSkirtV2) is a different revision, with faces up to y 24, and is not the source.
//
// FITS (../print_fit.scad), revised only:
//
//     H1 Ø3, on the M3 screw    slip
//
// H1's Ø6.2 and Ø5.9 already clear an M3 head (Ø5.5) by 0.35 and 0.2 per side, and are not fits.
// What the collar, the slots and the pocket mate with is not recorded, so they take no clearance.

include <BOSL2/std.scad>
include <../print_fit.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or one 2D profile
layer = "part"; // [part, skirt, frame, hood]

/* [Hidden] */
$fn = 180;
epsilon = 0.01;

// The octagonal frame, O1–O6: offsets d from the core octagon's faces, at heights y.
CORE      = 29.483;                    // core octagon apothem
CORE_HALF = CORE * tan(22.5);          // half a core face (12.212)
OUTER_D   = 19.017;                    // O1 below the taper (apothem 48.500)
TAPER     = 24.727;                    // O1 taper: d + y
TOP_Y     = 20.000;
CHAMFER   = 15.955;                    // O3 base chamfer and O4 collar chamfer: d + y
INNER     = 20.487;                    // inner face: d + y
COLLAR    = [3.017, 6.017];            // O4: inner and outer d
RIDGE     = [[14.403, 2.400], 0.600];  // O3 ridge round: centre [d, y], radius
GROOVE    = 11.547;                    // O3 groove flank: d - y
CAP_L     = 3.000;                     // O6
KNEE_R    = 1.000;                     // O1's knee round, above the face on +X

// The round skirt, S1, F1, E1, and the rim, O2.
SKIRT_R   = [48.000, 50.000];          // S1
SKIRT_Y   = -26.000;
FLANGE_X  = -35.645;                   // F1's end, and the frame's
END_X     = 12.355;                    // E1
RIM_TOP   = 5.800;                     // above where O1's taper meets S1 on +X
RIM_CHAMF = 20.467;                    // O2: d + y

// The slots, K1 and K2.
SLOT_Y    = -13.000;                   // both slots' closed end
K1_HALF   = 4.200;
K2_ANGLE  = 39.920;
K2_WALLS  = [[-7.250, 7.893],          // walls' offsets from the ray, toward +angle, on +z
             [-7.343, 7.800]];         // and on -z, mirrored: the slots are not mirror images
K2_ROUND  = 2.000;                     // the closed end's corners

// The screw bosses, H1.
BOSS_ANGLES = [-45, 0, 45];
BOSS_Y    = 12.000;
BOSS_D    = 11.900;                    // in O5
SPACER_D  = 5.900;                     // inside O4, round the Ø3, from O4's inner face
SPACER_CHAMF = 1.000;                  // its edge onto O4's chamfer face: back along each face
HEAD_D    = [5.900, 6.200, 5.900];   // per BOSS_ANGLES: the one on +X, through L1, is larger
HEAD_FROM = 7.017;                     // d where the Ø6.2 starts
HOLE_ROUND = 1.000;                    // H1's edge round, at every face its holes cross
SCREW_D   = 3.000;

// For the Main Pivot (#300-001), which the collar's inner face (O4) stands on:
// the y span of that face, from where O4's chamfer reaches it to the top; and
// the screw bosses (H1) behind it, which the screws draw onto the pivot, and
// the spacers round the screws, flush with that face below it: y, the
// bosses' Ø, the spacers' Ø, angles.
function skirt_collar_y() = [CHAMFER - COLLAR[0], TOP_Y];
function skirt_boss() = [BOSS_Y, BOSS_D, SPACER_D, BOSS_ANGLES];

// The lug, L1 and L2, and its pocket, L3.
LUG_C     = [49.830, 3.990];           // L1 corner centres [x, ±z]
LUG_R     = 5.170;
LUG_FILLET = 2.000;
BEND      = [55.000, 12.210];          // the outer bend line [x, y]; L2's face is x + y = 67.21
LUG_INNER = 46.600;                    // L1 runs inward to x >= this, inside the wall
HOOD_FACE = 47.526;                    // L2, x'
HOOD_SIDE = [4.000, 5.164];            // L2's sides: a stadium [semicircles' ±z, radius], stretched in x'
STRETCH   = sqrt(2);                   // L2's and L3's sides, along x'
HOOD_BASE = 38.334;                    // O1's taper face on +X, x'
FOOT_SLOPE = 0.326;                    // L2's foot: dx'/dz of the ramp from O1's face edges onto the hood
BEND_R    = 1.000;                     // the round on the bend line from L1 to L2, and down onto S1
HOOD_INNER = 36.500;                   // L2 runs inward to x' >= this, inside the wall
HOOD_X    = CORE + COLLAR[0] + 0.500;  // and to x >= this, so it stays out of O4's bore at the top
POCKET_R  = 3.000;                     // L3 in L1
POCKET_X  = 52.840;                    // L3 in L1: outer face
P2_FACE   = 44.471;                    // L3 in L2: outer face, x'
P2_SIDE   = [4.000, 3.000];            // L3 in L2: sides, as L2's
P2_INNER  = [[4.955, 0], 35.500];      // inner arc: centre [x', z], radius
PLUG_HALF = 4.000;
PLUG_RAMP = [31.906, 70.000];          // its top: an arc across z along L2's leg, crest x' and radius

SLIP = fit_clearances(config)[0];
SCREW_HOLE = fit_bore(SCREW_D, SLIP);

U2 = [-1, 1, 0] / sqrt(2);             // L2's leg direction
N2 = [1, 1, 0] / sqrt(2);              // x'

// ---- Helpers

// Children (2D, in x and z) extruded along +Y from y0 to y1.
module along_y(y0, y1) {
    translate([0, y1, 0]) rotate([90, 0, 0]) linear_extrude(y1 - y0) children();
}

// Children (2D, in x' and z) extruded along L2's leg, s0 .. s1 along U2.
module along_hood(s0, s1) {
    translate(s1 * U2) multmatrix([[N2.x, 0, -U2.x, 0], [N2.y, 0, -U2.y, 0], [0, 1, 0, 0]])
        linear_extrude(s1 - s0) children();
}

// Children (2D, in x and y) extruded along Z, to bound a solid in plan.
module plan(h = 120) {
    down(h / 2) linear_extrude(h) children();
}

// A circle's points from angle a0 to a1, for profiles drawn as one polygon.
function arc(c, r, a0, a1, n = 24) = [for (i = [0 : n]) c + r * [cos(a0 + (a1 - a0) * i / n), sin(a0 + (a1 - a0) * i / n)]];

// Where L2 starts: the plane square to its leg through the outer bend line, which L1 runs up to.
// y on it at x. L3's two parts meet on the same plane.
function leg2_y(x) = x - (BEND.x - BEND.y);

// How far L1, and L3's part in it, run on past that plane into L2. Stopped on the plane, each meets
// its L2 counterpart face to face, and Manifold keeps the shared face as a wall across the lug, 1.754
// off the reference. Both seams need it.
SEAM_LAP = 0.005;

// ---- The frame profile, in [d, y]

STEP_Y = RIDGE[0].y + RIDGE[1];       // O3's step, which the ridge round is tangent to

// O1's knee, where its outer face turns onto the taper: sharp, or rounded by KNEE_R.
function knee(round) = round
    ? arc([OUTER_D - KNEE_R, TAPER - OUTER_D - KNEE_R * tan(22.5)], KNEE_R, 45, 0, 8)
    : [[OUTER_D, TAPER - OUTER_D]];

// What O1's knee round leaves outside the frame, from where the round leaves O1's outer face.
module knee_chip_2d() {
    y0 = knee(true)[len(knee(true)) - 1].y;
    difference() {
        translate([OUTER_D - 2, y0]) square([4, TOP_Y - y0]);
        polygon(concat([[0, -1], [OUTER_D, -1]], reverse(knee(true)), [[TAPER - TOP_Y, TOP_Y], [0, TOP_Y]]));
    }
}

function frame_points(round) = let (b = -epsilon) concat(
    [[CHAMFER - b, b]],
    arc(RIDGE[0], RIDGE[1], 225, 90, 12),                 // O3 ridge, onto the step
    [[STEP_Y + GROOVE, STEP_Y],                           // the step, out to the groove's flank
     [(INNER + GROOVE) / 2, (INNER - GROOVE) / 2],        // the flank, out to the inner face
     [COLLAR[1], INNER - COLLAR[1]],                      // the inner face up to O4
     [COLLAR[1], CHAMFER - COLLAR[1]],                    // O5's inner wall, down
     [COLLAR[0], CHAMFER - COLLAR[0]],                    // O4's chamfer
     [COLLAR[0], TOP_Y],
     [TAPER - TOP_Y, TOP_Y]],
    knee(round),                                          // O1
    [[OUTER_D, b]]);

module frame_2d(round = false) { polygon(frame_points(round)); }

// O6: the profile with O3, O5 and the inner face replaced by the chamfer line.
module cap_2d(round = false) {
    b = -epsilon;
    polygon(concat([[CHAMFER - b, b], [COLLAR[0], CHAMFER - COLLAR[0]], [COLLAR[0], TOP_Y],
                    [TAPER - TOP_Y, TOP_Y]], knee(round), [[OUTER_D, b]]));
}

// The band between the chamfer line and the inner face, which H1's boss fills.
module band_2d() {
    d = COLLAR[0];  // from O4's bore outward
    polygon([[d, CHAMFER - d], [d, INNER - d], [16, INNER - 16], [16, CHAMFER - 16]]);
}

// ---- The frame sweep

// A profile (2D, in d and y) swept along the face whose normal is at theta, t0 .. t1 along it.
module face_sweep(theta, t0, t1) {
    rotate([0, -theta, 0]) translate([0, 0, t0]) linear_extrude(t1 - t0) right(CORE) children();
}

// A profile swept 45° about the core vertex between the faces at theta and theta + 45.
module corner_sweep(theta) {
    v = CORE / cos(22.5) * [cos(theta + 22.5), 0, sin(theta + 22.5)];
    translate(v) rotate([0, -theta, 0]) rotate([90, 0, 0])
        rotate_extrude(angle = 45) mirror([0, 1]) children();
}

// O1's knee is sharp from E1 to the middle of the face on +X, and rounded from there on to F1.
// Beside the lug, where S1 stands outside O1, the edge is the lug's bend round instead.
module frame() {
    e = epsilon;
    // E1 trims the bottom corner. O6 fills the slot over its last CAP_L.
    intersection() {
        corner_sweep(-90) frame_2d();
        plan() translate([END_X + CAP_L - e, -10]) square([60, 40]);
    }
    intersection() {
        corner_sweep(-90) cap_2d();
        plan() translate([END_X, -10]) square([CAP_L, 40]);
    }
    for (theta = [-45, 45]) face_sweep(theta, -CORE_HALF - e, CORE_HALF + e) frame_2d(theta > 0);
    face_sweep(0, -CORE_HALF - e, e) frame_2d();
    face_sweep(0, 0, CORE_HALF + e) frame_2d(true);
    for (theta = [-45, 0, 45]) corner_sweep(theta) frame_2d(theta >= 0);
    face_sweep(90, -CORE_HALF - e, -FLANGE_X - CAP_L + e) frame_2d(true);
    face_sweep(90, -FLANGE_X - CAP_L, -FLANGE_X) cap_2d(true);
}

// H1's bosses: the band, filled within the boss's diameter, and the spacer round the Ø3
// inside the collar, below its chamfer, with its edge onto the chamfer face chamfered.
module bosses() {
    for (theta = BOSS_ANGLES) rotate([0, -theta, 0]) {
        intersection() {
            translate([CORE + 1, BOSS_Y, 0]) rotate([0, 90, 0]) cylinder(d = BOSS_D, h = 16);
            translate([0, 0, -BOSS_D]) linear_extrude(2 * BOSS_D) right(CORE) band_2d();
        }
        translate([CORE + COLLAR[0], BOSS_Y, 0]) rotate([0, 90, 0]) cylinder(d = SPACER_D, h = HEAD_FROM - COLLAR[0]);
        intersection() {
            right(CORE) spacer_chamfer(SPACER_D / 2, SPACER_CHAMF);
            translate([CORE + COLLAR[0], 0, -BOSS_D]) cube([16, 2 * BOSS_Y, 2 * BOSS_D]);
        }
    }
}

// The spacer meets O4's chamfer face on an edge, chamfered back by L along each face, square to the
// edge. Each section, at angle phi round the hole from -y toward +z, in [d, y, z]: the point on the
// spacer, the point on the face, and a point behind the edge, inside the material.
function spacer_chamfer_section(phi, R, L) = let (
    S = sin(phi), C = cos(phi),
    edge = [CHAMFER - BOSS_Y + R * C, BOSS_Y - R * C, R * S],
    q = phi - L * S / (sqrt(1 + S * S) * R) * 180 / PI,  // round the spacer, as it unrolls
    on_spacer = [edge.x - L / sqrt(1 + S * S), BOSS_Y - R * cos(q), R * sin(q)],
    on_face = edge + L * [C, -C, 2 * S] / sqrt(2 + 2 * S * S),
    inward = [0, C, -S] + [1, 1, 0] / sqrt(2)
) [edge + 0.3 * inward / norm(inward), on_spacer, on_face];

// The fill under the chamfer, all round the edge; bosses() trims it at O4's inner face.
module spacer_chamfer(R, L, step = 2.5) {
    sections = [for (phi = [-120 : step : 120]) spacer_chamfer_section(phi, R, L)];
    k = len(sections);
    polyhedron(
        points = [for (s = sections) each s],
        faces = concat(
            [for (i = [0 : k - 2], j = [0 : 2])
                let (a = i * 3, b = (i + 1) * 3, q = (j + 1) % 3)
                each [[a + j, b + j, b + q], [a + j, b + q, a + q]]],
            [[0, 1, 2], [3 * k - 1, 3 * k - 2, 3 * k - 3]]));
}

// ---- The skirt and rim, in x and z

module lug_2d() {
    hull() for (s = [-1, 1]) translate([LUG_C.x, s * LUG_C.y]) circle(r = LUG_R);
}

// S1 with L1, filleted together, less S1's bore.
module skirt_lug_2d() {
    difference() {
        offset(r = -LUG_FILLET) offset(r = LUG_FILLET) union() {
            difference() { circle(r = SKIRT_R[1]); circle(r = SKIRT_R[0]); }
            lug_2d();
        }
        circle(r = SKIRT_R[0]);
    }
}

// Where S1 is kept: from E1 round +X, and over the top as far as F1, which carries on from there.
module skirt_keep_2d() {
    translate([END_X, -60]) square([60, 120]);
    translate([-14, 0]) square([80, 60]);
}

module skirt_2d() {
    difference() {
        union() {
            intersection() { skirt_lug_2d(); skirt_keep_2d(); }
            translate([FLANGE_X, CORE + CHAMFER]) square([-10 - FLANGE_X, OUTER_D - CHAMFER]);  // F1
        }
        circle(r = SKIRT_R[0]);
    }
}

// O2, and the taper on +X: what is cut from the rim above each face, in that face's frame.
module rim_cut(theta, k) {
    rotate([0, -theta, 0]) translate([0, 0, -40]) linear_extrude(80)
        polygon([[CORE + k + 1, -1], [80, -1], [80, 10], [CORE + k - 10, 10]]);
}

// L1 with its fillets to S1, less S1: what L1 adds above y 0, where it rises past S1's top.
module lug_fillets_2d() {
    lug_2d();
    difference() { skirt_lug_2d(); circle(r = SKIRT_R[1]); }
}

module rim() {
    difference() {
        along_y(-epsilon, RIM_TOP) intersection() {
            difference() { circle(r = SKIRT_R[1]); circle(r = SKIRT_R[0]); }
            skirt_keep_2d();
        }
        for (theta = [-45, 45, 90]) rim_cut(theta, RIM_CHAMF);
        // On +X, beside L1, S1 runs up under L2's foot and fillets rather than to O1's taper.
        along_hood(-60, 10) above_hood_2d();
        // On +z, past L4's end, S1 runs into O1's rounded knee and stays inside it.
        face_sweep(0, BEND_END, CORE_HALF + epsilon) knee_chip_2d();
        corner_sweep(0) knee_chip_2d();
    }
}

// ---- The lug, L1 and L2

module lug() {
    // L1, with its fillets, up to where L2 starts, kept inside the frame's wall on its inner side.
    // Where L1's corners and fillets stand outside L2's section, L2's outside is L1's top: the two
    // meet on one edge, which bend_round rounds.
    intersection() {
        along_y(0, 20) lug_fillets_2d();
        plan() polygon([[LUG_INNER, 0], [70, 0], [70, leg2_y(70) + SEAM_LAP], [LUG_INNER, leg2_y(LUG_INNER) + SEAM_LAP]]);
        along_hood(-60, 10) difference() { translate([0, -20]) square([80, 40]); above_hood_2d(); }
    }
    // L2 from where it starts, and from where O1's taper begins, up to the top face, clear of O4's
    // bore where it meets the top.
    taper_y = TAPER - OUTER_D;
    intersection() {
        along_hood(-45, -5) hood_2d();
        plan() polygon([[HOOD_X, taper_y], [taper_y + BEND.x - BEND.y, taper_y],
                        [TOP_Y + BEND.x - BEND.y, TOP_Y], [HOOD_X, TOP_Y]]);
    }
    // L2's foot and its fillets also run below where L2 starts, along O1's face and down onto S1,
    // which they meet inside S1's outer surface, to meet L1's fillets.
    intersection() {
        along_hood(-45, -5) hood_2d();
        plan() translate([HOOD_X, 0]) square([40, TOP_Y]);
        along_y(0, TOP_Y) circle(r = SKIRT_R[1]);
    }
}

// Everything outside L2's section and O1's face, in x' and z.
module above_hood_2d() {
    difference() { translate([HOOD_BASE, -40]) square([40, 80]); hood_2d(); }
}

// L2's foot, in x' and z: O1's face across its width, ramping up from its edges toward the hood.
FOOT_PEAK = HOOD_BASE + CORE_HALF * FOOT_SLOPE;

module foot_2d() {
    polygon([[HOOD_INNER - 5, -CORE_HALF], [HOOD_BASE, -CORE_HALF], [FOOT_PEAK, 0],
             [HOOD_BASE, CORE_HALF], [HOOD_INNER - 5, CORE_HALF]]);
}

// L2's and L3's sections, in x' and z: a stadium, semicircles of radius side[1] about z ±side[0]
// joined by the face, stretched by STRETCH along x'. Each side is half an ellipse, tangent to the
// face where the face ends.
function stadium_x(side, face) = face - STRETCH * side[1];  // the semicircles' centres, in x'

// The point at angle t round the +z semicircle, from the face, and the outward normal there.
function stadium_point(side, face, t) = [stadium_x(side, face) + STRETCH * side[1] * cos(t), side[0] + side[1] * sin(t)];
function stadium_normal(t) = let (n = [cos(t), STRETCH * sin(t)]) n / norm(n);

module stadium_2d(side, face) {
    translate([stadium_x(side, face), 0]) scale([STRETCH, 1])
        hull() for (s = [-1, 1]) translate([0, s * side[0]]) circle(r = side[1]);
}

// L2's section, in x' and z, filleted to O1's taper face.
module hood_2d() {
    intersection() {
        offset(r = -LUG_FILLET) offset(r = LUG_FILLET) union() {
            stadium_2d(HOOD_SIDE, HOOD_FACE);
            // O1's face under the hood, as far as its edges, and the foot ramping up from them, so the
            // fillets have a face to meet.
            foot_2d();
        }
        translate([HOOD_INNER, -20]) square([20, 40]);
    }
}

// L3 in L1: inside L1's walls, bounded within by S1's outer surface.
module pocket_2d() {
    difference() {
        hull() for (s = [-1, 1]) translate([LUG_C.x, s * LUG_C.y]) circle(r = POCKET_R);
        circle(r = SKIRT_R[1]);
    }
}

// L3 in L2, in x' and z.
module hood_pocket_2d() {
    difference() {
        stadium_2d(P2_SIDE, P2_FACE);
        translate(P2_INNER[0]) circle(r = P2_INNER[1], $fn = 720);
    }
}

// L3 turns on the same plane as the lug: L1's pocket face meets L2's on it.
module pocket() {
    intersection() {
        along_y(SKIRT_Y - 1, 20) pocket_2d();
        plan() polygon([[40, -30], [80, -30], [80, leg2_y(80) + SEAM_LAP], [40, leg2_y(40) + SEAM_LAP]]);
    }
    intersection() {
        along_hood(-60, 5) hood_pocket_2d();
        plan() polygon([[30, leg2_y(30)], [80, leg2_y(80)], [80, 40], [30, 40]]);
    }
}

module plug() {
    intersection() {
        translate([49, SKIRT_Y - 1, -PLUG_HALF]) cube([5, 30, 2 * PLUG_HALF]);
        along_hood(-60, -30) translate([PLUG_RAMP[0] - PLUG_RAMP[1], 0]) circle(r = PLUG_RAMP[1], $fn = 720);
    }
}

// ---- The cutters

module k1_slot() {
    translate([45, SKIRT_Y - 1, -K1_HALF]) cube([20, SLOT_Y - SKIRT_Y + 1, 2 * K1_HALF]);
}

// Each K2 slot square to its ray, in -z' (across the slot) and y, its closed end's corners rounded,
// extruded outward along the ray.
module k2_slots() {
    for (m = [0, 1]) mirror([0, 0, m]) rotate([0, -K2_ANGLE, 0]) translate([40, 0, 0]) rotate([0, 90, 0])
        linear_extrude(20) offset(r = K2_ROUND) offset(r = -K2_ROUND)
            let (w = K2_WALLS[m])
                translate([-w[1], SKIRT_Y - 5]) square([w[1] - w[0], SLOT_Y - SKIRT_Y + 5]);
}

module screw_holes() {
    for (i = [0 : len(BOSS_ANGLES) - 1]) rotate([0, -BOSS_ANGLES[i], 0]) {
        translate([0, BOSS_Y, 0]) rotate([0, 90, 0]) {
            translate([0, 0, CORE - 1]) cylinder(d = SCREW_HOLE, h = HEAD_FROM + 2);
            translate([0, 0, CORE + HEAD_FROM]) cylinder(d = HEAD_D[i], h = 40);
        }
        // The ±45° holes leave through O1's taper. The one on +X crosses L3 and leaves through the
        // lug, rounded at each of the three faces.
        if (BOSS_ANGLES[i] != 0) hole_round(HEAD_D[i] / 2, HOLE_ROUND, TAPER_FACE);
        else {
            hole_round(HEAD_D[i] / 2, HOLE_ROUND, POCKET_INNER);
            crease_round(HEAD_D[i] / 2, HOLE_ROUND, POCKET_OUTER, side = 1);
            hole_round(HEAD_D[i] / 2, HOLE_ROUND, LUG_FACE, fine = lug_face_fine(HEAD_D[i] / 2 + HOLE_ROUND));
        }
    }
}

// An H1 hole's edge round where it passes through a face, as one lofted cutter: a rolling ball,
// as bend_round's. Points are [u, v, s] about the hole: u along +y, v along z, s the offset d along
// the axis. The hole's wall is u^2 + v^2 = R^2. The face is [a, m, k], meaning s = a - m u - k v^2:
// m = 0 is square to the hole, and m = 1 is a plane d + y = a + BOSS_Y, at 45°. k bends the face
// away from the hole as z grows, as L3's inner arc does. A face that is none of these is a function
// of [u, v] that returns what face_at does. `side` is -1 where the material is below the face (the
// hole leaves it) and +1 where it is above (the hole enters from a void).

// The face's offset s at [u, v], and its slopes [ds/du, ds/dv] there.
function face_at(face, p) = is_function(face) ? face(p) : let (k = len(face) > 2 ? face[2] : 0)
    [face[0] - face[1] * p.x - k * p.y ^ 2, -face[1], -2 * k * p.y];

function face_point(face, p) = [p.x, p.y, face_at(face, p)[0]];

// The face's normal at [u, v], toward the void.
function face_normal(face, side, p) = let (
    f = face_at(face, p), g = [-f[1], -f[2], 1]
) -side * g / norm(g);

// The ball's centre r inside the face, over the face point p.
function centre_over(face, side, r, p) = face_point(face, p) - r * face_normal(face, side, p);

// The face point under the ball whose centre is over [u, v] = target, found by Newton's method on
// how the centre moves with that point. Over a face curved nearly as tightly as the ball, the centre
// hardly moves, so a plain correction by the miss would not converge.
function ball_foot(face, side, r, target, p, i = 0) = let (
    c = centre_over(face, side, r, p)
) i == 10 ? p : let (
    h = 1e-4,
    cu = centre_over(face, side, r, p + [h, 0]),
    cv = centre_over(face, side, r, p + [0, h]),
    J = [[cu.x - c.x, cv.x - c.x], [cu.y - c.y, cv.y - c.y]] / h,
    D = J[0][0] * J[1][1] - J[0][1] * J[1][0],
    miss = target - [c.x, c.y]
) ball_foot(face, side, r, target,
              p + (abs(D) < 1e-9 ? miss : [[J[1][1], -J[0][1]], [-J[1][0], J[0][0]]] * miss / D), i + 1);

// Each section is the ball's arc between where it touches the wall and the face, at angle phi
// round the hole from +y, pushed a little into the void past both surfaces.
function round_section(R, r, phi, face, side, n = 10) = let (
    dir = [cos(phi), sin(phi)],
    target = (R + r) * dir,
    p = ball_foot(face, side, r, target, target),
    c = centre_over(face, side, r, p),
    n1 = [-dir.x, -dir.y, 0],
    n2 = face_normal(face, side, p),
    a = acos(n1 * n2),
    b = (n1 + n2) / norm(n1 + n2),
    e = 0.3,
    section = concat([c + (r + e) * n1, c + r * (n1 + n2) / (1 + n1 * n2) + 2 * e * b, c + (r + e) * n2],
                     [for (j = [0 : n]) let (f = j / n) c + r * (sin((1 - f) * a) * n2 + sin(f * a) * n1) / sin(a)])
) side < 0 ? section : [for (j = [len(section) - 1 : -1 : 0]) section[j]];

// `fine` adds angles, in [0, 360), where the section turns quickly.
module hole_round(R, r, face, side = -1, segments = 72, fine = []) {
    phis = sort(concat([for (i = [0 : segments - 1]) 360 * i / segments], fine));
    k = len(phis);
    sections = [for (phi = phis)
        [for (q = round_section(R, r, phi, face, side)) [CORE + q.z, BOSS_Y + q.x, q.y]]];
    m = len(sections[0]);
    polyhedron(
        points = [for (s = sections) each s],
        // Two triangles per quad: neighbouring sections are not coplanar, so a quad would not be.
        faces = [for (i = [0 : k - 1], j = [0 : m - 1])
            let (a = i * m, b = ((i + 1) % k) * m, q = (j + 1) % m)
            each [[a + j, b + j, b + q], [a + j, b + q, a + q]]]);
}

// A hole's round where it passes through two plane faces that meet in a crease, the material
// wrapping round the edge between them, as it does round L3's bend. Each face's round, lofted
// smoothly, stays out of the other face's material, and where both reach, only what both remove goes.
module crease_round(R, r, faces, side = -1) {
    difference() { hole_round(R, r, faces[0], side); face_side(faces[1], side); }
    difference() { hole_round(R, r, faces[1], side); face_side(faces[0], side); }
    intersection() { hole_round(R, r, faces[0], side); hole_round(R, r, faces[1], side); }
}

// The material's side of a plane face [a, m] about the 0° hole, within 20 of the face.
module face_side(face, side) {
    plan() polygon([for (u = [-20, 20]) [CORE + face[0] - face[1] * u, BOSS_Y + u],
                    for (u = [20, -20]) [CORE + face[0] - face[1] * u + 20 * side, BOSS_Y + u]]);
}

// The faces H1's holes pass through, as hole_round's faces, offsets from the core face. L3's inner
// face is an arc of radius P2_INNER[1] across z, so it falls away by z^2 / (2 radius) in x'.
TAPER_FACE   = [TAPER - BOSS_Y, 1];
POCKET_OUTER = [[POCKET_X - CORE, 0], [P2_FACE * sqrt(2) - CORE - BOSS_Y, 1]];
POCKET_INNER = [(P2_INNER[0].x + P2_INNER[1]) * sqrt(2) - CORE - BOSS_Y, 1, 1 / (sqrt(2) * P2_INNER[1])];

// The lug's outside, which the hole on +X leaves through: L1's face, L4's round over the bend line,
// and L2's face. The bend line runs along z, so the face varies with u alone. L4 is as tight as the
// ball, so the ball's centre would stop at one point while the ball rolled over L4. The face takes
// L4 at LUG_FACE_R instead, which keeps the centre moving and departs from L4 by 0.008 at most.
LUG_FACE_R = BEND_R + 0.100;
LUG_UE     = BEND.y - BOSS_Y;              // the bend line, in u
LUG_U1     = LUG_UE - LUG_FACE_R * tan(22.5);  // where L4 leaves L1's face, and its centre's u
LUG_FACE = let (
    s1 = BEND.x - CORE,                    // L1's face
    u2 = LUG_UE + LUG_FACE_R * tan(22.5) / sqrt(2)  // where L4 meets L2's face
) function (p) p.x <= LUG_U1 ? [s1, 0, 0]
    : p.x >= u2 ? [s1 - (p.x - LUG_UE), -1, 0]
    : let (w = p.x - LUG_U1, h = sqrt(LUG_FACE_R ^ 2 - w ^ 2)) [s1 - LUG_FACE_R + h, -w / h, 0];

// The angles round a hole of radius Rc to the ball's centre where that centre passes over L4, on
// each side of the hole, where the ball rolls over L4.
function lug_face_fine(Rc, n = 12) = let (
    a0 = acos((LUG_U1 + (LUG_FACE_R - HOLE_ROUND) * sin(45)) / Rc), a1 = acos(LUG_U1 / Rc)
) [for (i = [1 : n - 1]) let (a = a0 + (a1 - a0) * i / n) each [a, 360 - a]];

// ---- The bend round
//
// L1's outside meets L2's along the outer bend line, and on down each side, over L1's corners and
// fillets, onto S1 and L2's foot. That edge is rounded by BEND_R. L1 with S1 is a section extruded along Y, and L2 one extruded along
// its leg, so each solid shrunk by the round is its section offset inward, extruded the same way.
// The rolling ball's centre at height z is where the two offset surfaces cross, and the round
// runs between where the ball touches each surface. Each section of the cutter is that round,
// pushed a little into the void past both surfaces, as round_section's are.

// Where two circles meet: the crossing on the left of the line from c1 to c2.
function circle_meet(c1, r1, c2, r2) = let (
    d = norm(c2 - c1), u = (c2 - c1) / d,
    a = (r1 * r1 - r2 * r2 + d * d) / (2 * d)
) c1 + a * u + sqrt(r1 * r1 - a * a) * [-u.y, u.x];

// L1's fillet to S1, centre [x, z], above the lug.
LUG_FILLET_C = circle_meet([0, 0], SKIRT_R[1] + LUG_FILLET, [LUG_C.x, LUG_C.y], LUG_R + LUG_FILLET);

// The round runs while the ball rests on S1, out to where S1 dips under O1's face. Past it on +z,
// the edge is O1's knee, rounded by the frame sweep; on -z, the knee is sharp.
BEND_END = sqrt((SKIRT_R[1] - BEND_R) ^ 2 - (CORE + OUTER_D - BEND_R) ^ 2);

// L2's fillet to its foot: R2 from the side and from the ramp. Its centre [x', z], and the angle on
// the side's semicircle where it is tangent.
function hood_fillet_c(t) = stadium_point(HOOD_SIDE, HOOD_FACE, t) + LUG_FILLET * stadium_normal(t);
HOOD_FILLET_T = root_find(function (t) let (g = hood_fillet_c(t))
    (g.x + FOOT_SLOPE * g.y - FOOT_PEAK) / sqrt(1 + FOOT_SLOPE ^ 2) - LUG_FILLET, 0, 180);
HOOD_FILLET_C = hood_fillet_c(HOOD_FILLET_T);

// A point on an arc, and the outward normal there: about centre c, at height z, radius r. `far`
// takes the arc's side away from x' or x = 0, and `concave` turns the normal toward the centre.
function arc_wall(c, r, z, far = true, concave = false) = let (
    x = c.x + (far ? 1 : -1) * sqrt(max(0, r * r - (z - c.y) ^ 2)),
    n = ([x, z] - c) / r
) [x, concave ? -n : n];

// L1 and S1's outer wall at height z >= 0, shrunk by r: [x, outward normal [x, z]].
function bend_wall(z, r) = let (
    F = LUG_FILLET_C, Rf = LUG_FILLET + r, S = SKIRT_R[1] - r, L = LUG_R - r
) z >= F.y * S / (SKIRT_R[1] + LUG_FILLET) ? [sqrt(S * S - z * z), [sqrt(S * S - z * z), z] / S]
  : z >= F.y + (LUG_C.y - F.y) * Rf / (LUG_R + LUG_FILLET) ? arc_wall(F, Rf, z, false, true)
  : z >= LUG_C.y ? arc_wall(LUG_C, L, z)
  : [LUG_C.x + L, [1, 0]];

// L2's outside, in x', at height z >= 0, shrunk by r: [x', outward normal [x', z]]. The face is flat
// below its side's semicircle; on the side, the ball's angle round it is found from z.
function bend_top(z, r) = let (
    G = HOOD_FILLET_C, m = sqrt(1 + FOOT_SLOPE ^ 2),
    ball = function (t) stadium_point(HOOD_SIDE, HOOD_FACE, t) - r * stadium_normal(t)
) z <= HOOD_SIDE[0] ? [HOOD_FACE - r, [1, 0]]
  : z <= ball(HOOD_FILLET_T).y
    ? let (t = root_find(function (t) ball(t).y - z, 0, HOOD_FILLET_T)) [ball(t).x, stadium_normal(t)]
  : z <= G.y - (LUG_FILLET + r) * FOOT_SLOPE / m ? arc_wall(G, LUG_FILLET + r, z, false, true)
  : [FOOT_PEAK - FOOT_SLOPE * z - r * m, [1, FOOT_SLOPE] / m];

// One section of the cutter, with the ball's centre at height z.
function bend_section(z, r, n = 10) = let (
    s = z < 0 ? -1 : 1,
    w = bend_wall(abs(z), r), t = bend_top(abs(z), r),
    c = [w[0], sqrt(2) * t[0] - w[0], z],
    n1 = [w[1].x, 0, s * w[1].y],
    n2 = [t[1].x / sqrt(2), t[1].x / sqrt(2), s * t[1].y],
    cw = n1 * n2,
    a = acos(min(1, cw)),
    b = (n1 + n2) / norm(n1 + n2),
    e = 0.3
) concat([c + (r + e) * n1, c + r * (n1 + n2) / (1 + cw) + 2 * e * b, c + (r + e) * n2],
         [for (j = [0 : n]) let (f = j / n)
             c + r * (a < 0.01 ? n2 : (sin((1 - f) * a) * n2 + sin(f * a) * n1) / sin(a))]);

// The ball's heights: fine where L1's corner and L2's side meet nearly tangent, and the centre
// moves fast. Where both faces are flat, the sections are one section moved along z, and only
// the two at its ends are kept: CGAL fails on the vertices the others would leave collinear.
function bend_heights(z0, z1) = let (
    flat = HOOD_SIDE[0],
    fine = [for (z = [-10.5 : 0.05 : -5.5]) z, for (z = [5.5 : 0.05 : 10.5]) z],
    coarse = [for (z = [ceil(z0 / 0.25) * 0.25 : 0.25 : z1]) if (abs(z) < 5.5 || abs(z) > 10.5) z]
) [for (z = concat([z0, z1, -flat, flat], coarse, fine)) if (z >= z0 && z <= z1 && abs(z) >= flat) z];

module bend_round(r = BEND_R) {
    zs = unique(bend_heights(-BEND_END, BEND_END));
    sections = [for (z = zs) bend_section(z, r)];
    m = len(sections[0]);
    k = len(sections);
    polyhedron(
        points = [for (s = sections) each s],
        faces = concat(
            [for (i = [0 : k - 2], j = [0 : m - 1])
                let (a = i * m, b = (i + 1) * m, q = (j + 1) % m)
                each [[a + j, b + j, b + q], [a + j, b + q, a + q]]],
            // Each end, as a fan from the edge's corner, which sees the whole round: a section need not
            // be flat.
            [for (j = [2 : m - 1]) [1, j, (j + 1) % m]],
            [for (j = [2 : m - 1]) let (a = (k - 1) * m) [a + 1, a + (j + 1) % m, a + j]]));
}

// ---- The part

// L4 rounds the skirt, rim and lug only. Where S1 dips under O1's face, O1's face is left standing
// under it, so the round dies away onto that face rather than cutting into it.
module pivot_skirt() {
    difference() {
        union() {
            difference() {
                union() {
                    difference() {
                        union() {
                            along_y(SKIRT_Y, 0) skirt_2d();
                            rim();
                            lug();
                        }
                        bend_round();
                    }
                    frame();
                    bosses();
                }
                pocket();
            }
            plug();
        }
        k1_slot();
        k2_slots();
        screw_holes();
    }
}

// The sections, as the mesh is cut: the skirt across y just above the plug's crest, the frame and
// F1 across the top face (in y and z), and the hood square to its leg (in x' and z).
if (layer == "skirt") difference() { skirt_2d(); pocket_2d(); }
else if (layer == "frame") translate([0, CORE]) mirror([1, -1]) union() {
    frame_2d(true);
    translate([CHAMFER, SKIRT_Y]) square([OUTER_D - CHAMFER, -SKIRT_Y]);  // F1, below y 0
}
else if (layer == "hood") difference() { hood_2d(); hood_pocket_2d(); }
else pivot_skirt();
