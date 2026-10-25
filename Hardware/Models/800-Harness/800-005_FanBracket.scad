// #800-005 Fan Bracket — parametric source.
// Holds the C-716 Sunon 40 x 40 x 10 fan in its aperture, and stands on two
// M3 standoffs on the Motor Control PCB (specs/007.1, C-716).
//
//   config = "previous" — faithful recreation of the reference mesh
//                         (../Reference/meshes/800-Harness/), in which the
//                         fan is glued.
//   config = "revised"  — the print fits below drawn on the fan's seat and
//                         the M3 pilots, and the fan screwed on at its
//                         corners (FAN SCREWS).
//
// FRAME. The reference's own: the plate's underside at z = 3.75, its top face
// at z = 7.0, the bosses rising to z = 16.0; the plate's corner at x 0, y -8.
//
// Measured from the reference (scadmesh planes/slice/arcs). The feature IDs
// are those of 800-005_FanBracket.view.json, which labels each one on the mesh:
//
//     ID  feature                    value                          z span
//     P1  plate                      x 0 .. 57.4, y -8 .. 39.922,
//                                    R2 corners                     3.75 .. 7.0
//     A1  fan aperture, centre       40.0 x 40.0 R2                 3.75 .. 5.5
//         (28.925, 15.991)           45 deg taper, 1.0 per side     5.5 .. 6.5
//                                    38.0 x 38.0 R1 lip             6.5 .. 7.0
//     B1  boss, centre (3.981, 7.850) R3.980, material y <= 10.331  7.0 .. 16.0
//     B2  boss, centre (53.719, 7.850) R3.680, material y <= 10.531 7.0 .. 16.0
//     H1  holes, at each boss centre Ø3.0                           3.75 .. 16.0
//
// The plane the survey found at z 9.875 is not a feature: the sections on both
// sides of it have the same outline and an area that grows smoothly, so it is
// the tessellation of the bosses' flanks.
//
// CONSTRUCTION. The plate's profile, less the holes, extruded; the aperture
// cut in three runs (the 40 section, the taper as the hull of two thin slabs,
// the lip); the bosses (circle cut by the flat's half-plane, less the hole)
// extruded from a lap below the top face. `layer` draws one 2D profile, for
// verification against the mesh's section (scadmesh outline).
//
// FITS (../print_fit.scad), revised only, per side:
//
//     A1 40 section, the fan's seat       press (40.1 square)
//     H1 holes, the M3 screws' pilots     tap (Ø2.6)
//     F1 holes, the fan screws'           slip (Ø5.3)
//
// The fan's frame bears on the taper and the 38 lip, which keep their size,
// and in revised on the pads.
//
// FAN SCREWS, revised only. The fan's four Ø4.3 holes lie on a 32 mm square
// (Sunon's specification, p. 6), inside the 38 lip, so the reference has no
// material over them. Revised fills each corner of the aperture with a
// triangular pad, from the fan's face (the seat's top) up to PAD_TOP, its
// inner edge square to the diagonal and tangent to the Ø38 circle, which
// clears the fan's impeller bore. A standard fan screw (Ø5 x 10 self-tapping,
// the one Sunon names) goes down through each pad's F1 hole and cuts its
// thread in the fan's hole: 3 mm of pad leaves it 7 of the fan's 10.

include <../print_fit.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or one 2D profile
layer = "part"; // [part, plate, lip, boss, pad]

/* [Hidden] */
$fn = 96;
LAP = 0.005;                 // overlap that joins solids on Manifold

PLATE_X   = [0, 57.4];       // P1
PLATE_Y   = [-8, 39.922];
PLATE_R   = 2.0;
PLATE_Z   = [3.75, 7.0];
CENTRE    = [28.925, 15.991];   // A1
SEAT      = [40.0, 2.0];     // 40 section: side, corner radius
LIP       = [38.0, 1.0];     // lip: side, corner radius
SEAT_TOP  = 5.5;
LIP_FOOT  = 6.5;
BOSSES    = [                // [centre x, radius, flat y]
    [3.981, 3.980, 10.331],  // B1
    [53.719, 3.680, 10.531]  // B2
];
BOSS_Y    = 7.850;
BOSS_TOP  = 16.0;
HOLE_D    = fit_pin(3.0, fit_clearances(config)[3]);  // H1, the M3 screw's pilot
FAN_PITCH = 32.0;            // the fan's holes, on a square about CENTRE
FAN_SCREW = 5.0;             // F1, the fan screw's diameter
PAD_EDGE  = 19.0;            // pads' inner edge, off CENTRE along each diagonal
PAD_TOP   = 8.5;

function press(cfg) = fit_clearances(cfg)[1];

// --- 2D profiles -----------------------------------------------------------
module rounded(size, r) offset(r = r) offset(delta = -r) square(size, center = true);

module plate_outline()
    translate([PLATE_X[0], PLATE_Y[0]])
        offset(r = PLATE_R) offset(delta = -PLATE_R)
            square([PLATE_X[1] - PLATE_X[0], PLATE_Y[1] - PLATE_Y[0]]);

module hole_at(c) translate([c, BOSS_Y]) circle(d = HOLE_D, $fn = 48);

module holes() for (b = BOSSES) hole_at(b[0]);

module aperture(side, r) translate(CENTRE) rounded([side, side], r);

// The plate's section under the aperture's 40 run or its lip.
module plate_2d(cfg, side, r) difference() {
    plate_outline();
    aperture(side, r);
    holes();
}

module boss_2d(b) difference() {
    intersection() {
        translate([b[0], BOSS_Y]) circle(r = b[1]);
        translate([b[0] - b[1] - 1, BOSS_Y - b[1] - 1]) square([2 * b[1] + 2, b[2] - BOSS_Y + b[1] + 1]);
    }
    hole_at(b[0]);
}

module bosses_2d() for (b = BOSSES) boss_2d(b);

module fan_holes(cfg)
    for (i = [-1, 1], j = [-1, 1])
        translate(CENTRE + [i, j] * FAN_PITCH / 2)
            circle(d = fit_bore(FAN_SCREW, fit_clearances(cfg)[0]), $fn = 48);

// The four corner pads: the seat's square less the diamond inside PAD_EDGE.
module pads_2d(cfg) difference() {
    aperture(SEAT[0] + 2 * press(cfg), SEAT[1]);
    translate(CENTRE) rotate(45) square(2 * PAD_EDGE, center = true);
    fan_holes(cfg);
}

// --- Solids ----------------------------------------------------------------
module slab(z, h) translate([0, 0, z]) linear_extrude(h) children();

// The aperture's cutters: the seat run, the taper, and the lip, each pushed
// past the faces it opens.
module aperture_cut(cfg) {
    seat = SEAT[0] + 2 * press(cfg);
    slab(PLATE_Z[0] - 1, SEAT_TOP - PLATE_Z[0] + 1) aperture(seat, SEAT[1]);
    hull() {
        slab(SEAT_TOP - LAP, LAP) aperture(SEAT[0], SEAT[1]);
        slab(LIP_FOOT, LAP) aperture(LIP[0], LIP[1]);
    }
    slab(LIP_FOOT - LAP, PLATE_Z[1] - LIP_FOOT + 1) aperture(LIP[0], LIP[1]);
}

module plate_body() slab(PLATE_Z[0], PLATE_Z[1] - PLATE_Z[0]) difference() { plate_outline(); holes(); }

module bosses() slab(PLATE_Z[1] - LAP, BOSS_TOP - PLATE_Z[1] + LAP) bosses_2d();

module pads(cfg) slab(SEAT_TOP, PAD_TOP - SEAT_TOP) pads_2d(cfg);

module fan_bracket(cfg = config)
    union() {
        difference() { plate_body(); aperture_cut(cfg); }
        bosses();
        if (cfg == "revised") pads(cfg);
    }

if (layer == "plate") plate_2d(config, SEAT[0] + 2 * press(config), SEAT[1]);
else if (layer == "lip") plate_2d(config, LIP[0], LIP[1]);
else if (layer == "boss") bosses_2d();
else if (layer == "pad") pads_2d(config);
else fan_bracket();
