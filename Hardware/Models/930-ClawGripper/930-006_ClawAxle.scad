// #930-006 Claw Axle — parametric source.
// The axle of both pivots, one part: a hex seat between two Ø8 journals. The seat carries a Claw Finger (#930-001
// or #930-007), and on the drive pivot the Claw Gear (#930-002), each pinned by a set screw through a cross hole.
// The rear journal runs in an MR128 (C-405) in the Claw Body's rear wall (#930-003), the front one in an
// MR128 in the Claw Cap (#930-005), and the collars between bear on their inner races, which locate the
// axle along its axis. On the follower pivot it stands turned 60 deg on its hex, which puts its cross holes on
// the follower finger's screw line (claw_params.scad, THE MIRROR), and its gear's cross hole stays empty.
// #930-011 is this file with four fingers. claw_params.scad owns its dimensions and gives the claw's mechanism.
//
// Designed, "revised" only: there is no reference mesh.
//
// FRAME. Its own: the pivot's axis along +Y through the origin, y the grip frame's, and (x, z) the grip
// frame's about the drive pivot with the claw closed. It prints standing on J1's end.
//
//     ID  feature        value                                                     y span
//     J1  rear journal   Ø8                                                        -8.0 .. -4.5
//     C1  rear collar    Ø8.6                                                      -4.5 .. -4.0
//     A1  seat           hex 10 across flats, a vertex on +Z                       -4.0 .. 15.069
//     H1  finger's cross Ø3.3 through A1's flats along polar 120 deg, on the       0
//         hole           blade's mid-plane
//     H2  gear's cross   Ø3.3 through A1's flats along polar 120 deg, on the       11.069
//         hole           gear's mid-plane
//     C2  front collar   Ø8.6                                                      15.069 .. 15.569
//     J2  front journal  Ø8                                                        15.569 .. 19.069
//
// FITS (revised). J1 and J2 are pressed into the MR128s' bores (C-405, 8 x 12 x 3.5):
// fit_pin(8, FIT_PRESS) = Ø7.900. C1 and C2 bear on the inner races alone, halfway across the inner
// ring. A1 goes into the finger's and the gear's hex bores, which are grown by FIT_SLIP, so it is drawn at
// size. H1 and H2 pass the M3 set screws: fit_bore(3, FIT_SLIP) = Ø3.3.

include <claw_gears.scad>

/* [Configuration] */
// Parameter set: designed in revised only
config = "revised"; // [revised]
// What to draw: the part, or one layer's 2D section
layer = "part"; // [part, J1, C1, A1]

/* [Hidden] */
$fn = 144;
LAP = 0.005;

assert(config == "revised", "#930-006 exists only in the revised configuration: it has no reference");

// The layers along y, rear to front, each [y span, section index].
function layers() = [[claw_journal_y(), 0], [claw_collar_y(), 1], [claw_seat_y(), 2], [claw_collar_y(true), 1], [claw_journal_y(true), 0]];

module layer_2d(i, cfg = config)
    if (i == 0) circle(d = claw_journal_d(cfg));
    else if (i == 1) circle(d = claw_collar_d());
    else claw_hex_2d();

// A layer laps LAP into a neighbour only where that neighbour is wider (a higher section index), so that
// the layers fuse and no collar reaches into its MR128's span.
function lap(k, n) = let(l = layers()) n >= 0 && n < len(l) && l[n][1] > l[k][1] ? LAP : 0;

// H1 and H2, through the seat along the set screws' line, at each pair of fingers and at the gear.
module cross_holes(cfg) let(c = fit_clearances(cfg)) for (y = concat(claw_pair_y(), [claw_gear_y()]))
    translate([0, y, 0]) rotate([0, -claw_screw_dir(), 0]) rotate([0, 90, 0])
        cylinder(d = fit_bore(claw_screw()[0], c[0]), h = 2 * claw_hex_af(), center = true, $fn = 48);

module claw_axle(cfg = config) difference() {
    multmatrix(AXIS_Y) for (k = [0 : len(layers()) - 1])
        let(y = layers()[k][0], lo = lap(k, k - 1), hi = lap(k, k + 1))
            translate([0, 0, y[0] - lo]) linear_extrude(y[1] - y[0] + lo + hi) layer_2d(layers()[k][1], cfg);
    cross_holes(cfg);
}

if (layer == "part") claw_axle();
else layer_2d(search([layer], ["J1", "C1", "A1"])[0]);
