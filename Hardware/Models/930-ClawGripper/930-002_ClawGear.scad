// #930-002 Claw Gear — parametric source.
// The claw's gear and axle in one piece, one model for both pivots of both claws: a toothed sector
// between two hex seats and two Ø8 journals. The drive's sector meets the Claw Pinion (#930-004) and the
// follower's; the two mesh 1:1, so the fingers turn equal and opposite. Seat A carries every claw's
// finger (#930-001) and seat B the 4-finger claw's second; each finger's set screw bears on a flat. The
// rear journal runs in an MR128 (C-405) in the Claw Body's rear cheek (#930-003), the front one in an
// MR128 in the Claw Cap (#930-005), and the collars between bear on their inner races, which locate the
// gear along its axis. claw_params.scad owns its dimensions and gives the claw's mechanism.
//
// Designed, "revised" only: there is no reference mesh.
//
// FRAME. Its own: the pivot's axis along +Y through the origin, y the grip frame's, and (x, z) the grip
// frame's about the drive pivot with the claw closed. The follower's is this part turned
// claw_gear_turn() about its axis (claw_params.scad, THE FLIP). It prints standing on J1's end.
//
//     ID  feature        value                                                     y span
//     J1  rear journal   Ø8                                                        -9.5 .. -6.0
//     C1  rear collar    Ø8.6                                                      -6.0 .. -5.5
//     A1  seat A         hex 10 across flats, a vertex on +Z                       -5.5 .. 5.5
//     G1  sector         30-tooth pitch, module 1.25, 20 deg, thinned for          5.5 .. 13.5
//                        backlash; teeth from 165 to 297 deg polar, a tooth on
//                        3 + 12k deg, on a disc of R14.69
//     A2  seat B         as A1                                                     13.5 .. 24.5
//     C2  front collar   Ø8.6                                                      24.5 .. 25.0
//     J2  front journal  Ø8                                                        25.0 .. 28.5
//
// FITS (revised). J1 and J2 are pressed into the MR128s' bores (C-405, 8 x 12 x 3.5):
// fit_pin(8, FIT_PRESS) = Ø7.900. C1 and C2 bear on the inner races alone, halfway across the inner
// ring. A1 and A2 go into the Claw Finger's hex bore, which is grown by FIT_SLIP, so they are drawn at
// size. G1 meshes with the other gear and the pinion, printed parts: each gear's teeth are thinned by
// FIT_SLIP / cos 20 along the pitch circle, so that, centred in the mesh, each pair of flanks stands
// FIT_SLIP apart.

include <claw_gears.scad>

/* [Configuration] */
// Parameter set: designed in revised only
config = "revised"; // [revised]
// What to draw: the part, or one layer's 2D section
layer = "part"; // [part, J1, C1, A1, G1]

/* [Hidden] */
$fn = 144;
LAP = 0.005;

assert(config == "revised", "#930-002 exists only in the revised configuration: it has no reference");

// The layers along y, rear to front, each [y span, section index].
function layers() = [[claw_journal_y(), 0], [claw_collar_y(), 1], [claw_seat_y(), 2], [claw_teeth_y(), 3],
                     [claw_seat_y(true), 2], [claw_collar_y(true), 1], [claw_journal_y(true), 0]];

module layer_2d(i, cfg = config)
    if (i == 0) circle(d = claw_journal_d(cfg));
    else if (i == 1) circle(d = claw_collar_d());
    else if (i == 2) claw_hex_2d();
    else claw_sector_2d(cfg);

// A layer laps LAP into a neighbour only where that neighbour is wider (a higher section index), so that
// the layers fuse and no collar reaches into its MR128's span.
function lap(k, n) = let(l = layers()) n >= 0 && n < len(l) && l[n][1] > l[k][1] ? LAP : 0;

module claw_gear(cfg = config) multmatrix(AXIS_Y) for (k = [0 : len(layers()) - 1])
    let(y = layers()[k][0], lo = lap(k, k - 1), hi = lap(k, k + 1))
        translate([0, 0, y[0] - lo]) linear_extrude(y[1] - y[0] + lo + hi) layer_2d(layers()[k][1], cfg);

if (layer == "part") claw_gear();
else layer_2d(search([layer], ["J1", "C1", "A1", "G1"])[0]);
