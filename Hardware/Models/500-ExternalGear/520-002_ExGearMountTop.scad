// #520-002 Ex Gear Mount Top — parametric source.
// The cap over the External Gear. Its 6810 is the output's third support: the
// bearing is pressed into the plate's seat from below until it stops on the
// shoulder (008.8 step 13), and the circular spline turns in its bore. The block
// under the plate stands on the Ex Gear Mount's back, and the two M3 x 46
// all-threads tie it down through the block into the Nut Holders.
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/500-ExternalGear/), in that
//                         mesh's frame.
//   config = "revised"  — the same part with its print fits on the 6810 and
//                         the all-threads.
//
// FRAME. The Ex Gear Mount's, which the reference already uses: the drive axis
// on +Z through the origin, the plate's top face at z 101.
//
// CONSTRUCTION. A stack of constant sections along z (profile per layer), each
// drawn whole in 2D and extruded once:
//
//     rebate   z 77.5 .. 81.5    block from x -53.901, less the all-thread holes
//     block    z 81.5 .. 85.5    block from x -57.901, less the holes
//     pockets  z 85.5 .. 89.5    block less the holes and the two P1 pockets
//     block    z 89.5 .. 93.0    as above the rebate
//     seat     z 93.0 .. 100.0   plate less B1, the 6810's seat, and the holes
//     shoulder z 100.0 .. 100.5  plate less B2 and the holes
//     top      z 100.5 .. 101.0  plate less B3 and the holes
//
// The block lies under the plate's tab, which covers it. `layer` names one
// profile to draw in 2D, for verification against the mesh's section
// (scadmesh outline; render.rs --verify does this).
//
// Measured from the reference with scadmesh planes/slice/arcs. The feature IDs
// are those of 520-002_ExGearMountTop.view.json:
//
//     ID  feature                  value
//     T1  plate                    z 93.0 .. 101.0
//     O1  plate outline            the tab x -57.901 .. -43.904, y +-20.0, then a
//                                  line from each of the tab's corners at x -43.904
//                                  to the R38.654 disc about the axis: tangent on -y,
//                                  at (-18.595, -33.888); on +y it meets the circle
//                                  at (-20.926, 32.500), 4 deg short of tangent
//     B1  6810 seat                Ø65.000, z 93.0 .. 100.0, open below
//     B2  shoulder                 Ø55.000, z 100.0 .. 100.5
//     B3  top bore                 Ø51.000, z 100.5 .. 101.0
//     K1  block                    z 77.5 .. 93.0, x -57.901 to the Mount bore's
//                                  R38.000 about (-0.655, 0), y +-20.0; R3 rounds
//                                  where the bore's arc meets the sides
//     K2  rebate                   x -57.901 .. -53.901 absent below z 81.5
//     P1  pockets                  2, x -57.901 .. -56.524, y +-6.0 .. +-14.0,
//                                  z 85.5 .. 89.5
//     H1  all-thread holes         2, Ø3.000 about (-46.278, +-10.0), z 77.5 .. 101.0
//
// FITS (../print_fit.scad), revised only:
//
//     B1, on the 6810's outer race (Ø65)      press
//     H1, on the M3 all-thread (Ø3.0)          slip
//
// B3 already stands the running clearance off the circular spline's Ø50 (0.5
// per side), and B1's depth is a shoulder contact, so neither changes.

include <../print_fit.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or one layer's 2D profile
layer = "part"; // [part, rebate, block, pockets, seat, shoulder, top]

/* [Hidden] */
$fn = 360;
epsilon = 0.01;

PLATE_Z   = [93.000, 101.000];         // T1
DISC_R    = 38.654;                    // O1
TAB       = [-57.901, -43.904, 20.000];  // O1: x min, x of the corners the lines leave, half-width
TANGENT_N = [-18.595, -33.888];        // O1, where the -y line meets the disc
MEET_P    = [-20.926, 32.500];         // O1, where the +y line meets the disc
SEAT      = [65.000, 100.000];         // B1: diameter, top
SHOULDER  = [55.000, 100.500];         // B2: diameter, top
TOP_D     = 51.000;                    // B3
BLOCK_Z   = 77.500;                    // K1, its bottom
BORE_R    = 38.000;                    // K1, the Mount bore's radius ...
BORE_C    = [-0.655, 0];               // ... and centre
BLOCK_RND = 3.000;                     // K1
REBATE    = [-53.901, 81.500];         // K2: x of the face below it, top
POCKET    = [-56.524, 6.000, 14.000, 85.500, 89.500];  // P1: inner x, y from, y to, z from, z to
HOLE      = [-46.278, 10.000, 3.000];  // H1: x, +-y, diameter
OUTER_D   = 65.000;                    // the 6810's outer race
ROD_D     = 3.000;                     // the M3 all-thread

function seat_d(cfg) = cfg == "previous" ? SEAT[0] : fit_bore(OUTER_D, fit_clearances(cfg)[1]);
function hole_d(cfg) = cfg == "previous" ? HOLE[2] : fit_bore(ROD_D, fit_clearances(cfg)[0]);

// For the assembly: the part's lowest and highest faces, B1's open face and
// shoulder, and H1's axes.
function mount_top_z() = [BLOCK_Z, PLATE_Z[1]];
function mount_top_seat() = [PLATE_Z[0], SEAT[1]];
function mount_top_holes() = [for (s = [-1, 1]) [HOLE[0], s * HOLE[1]]];

module holes_2d(cfg) for (s = [-1, 1]) translate([HOLE[0], s * HOLE[1]]) circle(d = hole_d(cfg), $fn = 96);

module plate_outline_2d() {
    a0 = atan2(TANGENT_N.y, TANGENT_N.x);
    a1 = atan2(MEET_P.y, MEET_P.x);
    polygon(concat(
        [[TAB[0], -TAB[2]], [TAB[1], -TAB[2]], TANGENT_N],
        [for (a = [ceil(a0) : 1 : a1 - 0.5]) DISC_R * [cos(a), sin(a)]],
        [MEET_P, [TAB[1], TAB[2]], [TAB[0], TAB[2]]]));
}

// The block's section from x0: out to the Mount bore's arc, its corners there
// rounded by an opening, those at x0 left sharp.
module block_2d(x0) {
    intersection() {
        offset(r = BLOCK_RND) offset(delta = -BLOCK_RND) difference() {
            translate([TAB[0] - 10, -TAB[2]]) square([45, 2 * TAB[2]]);
            translate(BORE_C) circle(r = BORE_R);
        }
        translate([x0, -TAB[2] - 1]) square([45, 2 * TAB[2] + 2]);
    }
}

module pockets_2d() for (s = [-1, 1]) translate([TAB[0] - 1, s > 0 ? POCKET[1] : -POCKET[2]])
    square([POCKET[0] - TAB[0] + 1, POCKET[2] - POCKET[1]]);

module layer_2d(l, cfg) {
    if (l == "rebate")        difference() { block_2d(REBATE[0]); holes_2d(cfg); }
    else if (l == "block")    difference() { block_2d(TAB[0]); holes_2d(cfg); }
    else if (l == "pockets")  difference() { block_2d(TAB[0]); holes_2d(cfg); pockets_2d(); }
    else if (l == "seat")     difference() { plate_outline_2d(); circle(d = seat_d(cfg)); holes_2d(cfg); }
    else if (l == "shoulder") difference() { plate_outline_2d(); circle(d = SHOULDER[0]); holes_2d(cfg); }
    else if (l == "top")      difference() { plate_outline_2d(); circle(d = TOP_D); holes_2d(cfg); }
}

// [layer, bottom, top], bottom up.
LAYERS = [
    ["rebate",   BLOCK_Z,    REBATE[1]],
    ["block",    REBATE[1],  POCKET[3]],
    ["pockets",  POCKET[3],  POCKET[4]],
    ["block",    POCKET[4],  PLATE_Z[0]],
    ["seat",     PLATE_Z[0], SEAT[1]],
    ["shoulder", SEAT[1],    SHOULDER[1]],
    ["top",      SHOULDER[1], PLATE_Z[1]]
];

module ex_gear_mount_top(cfg = config) {
    for (i = [0 : len(LAYERS) - 1]) {
        l = LAYERS[i];
        // Each layer but the last laps the next by epsilon, so no two share a face.
        translate([0, 0, l[1]]) linear_extrude(l[2] - l[1] + (i < len(LAYERS) - 1 ? epsilon : 0)) layer_2d(l[0], cfg);
    }
}

if (layer == "part") ex_gear_mount_top(config);
else layer_2d(layer, config);
