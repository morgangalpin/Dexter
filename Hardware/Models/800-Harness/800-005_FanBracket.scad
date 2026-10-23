// #800-005 Fan Bracket — parametric source.
// Holds the C-716 Sunon 40 x 40 x 10 fan, glued (CA) in its aperture, and
// stands on two M3 standoffs on the Motor Control PCB (specs/007.1, C-716).
//
//   config = "previous" — faithful recreation of the reference mesh
//                         (../Reference/meshes/800-Harness/).
//   config = "revised"  — the print fit below drawn on the fan's seat.
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
//
// The fan's frame bears on the taper and the 38 lip, which keep their size.
// H1 is threaded by its M3 screw, not a clearance, and keeps its size.

include <../print_fit.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or one 2D profile
layer = "part"; // [part, plate, lip, boss]

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
HOLE_D    = 3.0;             // H1; threaded by the M3 screw

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

module fan_bracket(cfg = config)
    union() {
        difference() { plate_body(); aperture_cut(cfg); }
        bosses();
    }

if (layer == "plate") plate_2d(config, SEAT[0] + 2 * press(config), SEAT[1]);
else if (layer == "lip") plate_2d(config, LIP[0], LIP[1]);
else if (layer == "boss") bosses_2d();
else fan_bracket();
