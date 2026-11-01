// #930-002 Claw Gear — parametric source.
// The drive pivot's gear and axle in one piece: a toothed sector in front of a hex seat, between two Ø8
// journals. Its sector meets the Claw Pinion (#930-004). The seat carries the drive Claw Finger
// (#930-001), and the finger's set screw passes in from the hub's far side, through the seat's cross hole.
// The rear journal runs in an MR128 (C-405) in the Claw Body's rear wall (#930-003), the front one in an
// MR128 in the Claw Cap (#930-005), and the collars between bear on their inner races, which locate the
// gear along its axis. The follower pivot's axle (#930-006) is this file with SIDE "follow": the seat
// runs on to collar C2 in place of the sector, and the cross hole lies on the follower finger's screw
// line. claw_params.scad owns its dimensions and gives the claw's mechanism.
//
// Designed, "revised" only: there is no reference mesh.
//
// FRAME. Its own: the pivot's axis along +Y through the origin, y the grip frame's, and (x, z) the grip
// frame's about its pivot with the claw closed. It prints standing on J1's end.
//
//     ID  feature        value                                                     y span
//     J1  rear journal   Ø8                                                        -9.5 .. -6.0
//     C1  rear collar    Ø8.6                                                      -6.0 .. -5.5
//     A1  seat           hex 10 across flats, a vertex on +Z                       -5.5 .. 7.069
//                        (the follower's: -5.5 .. 15.069)
//     H1  cross hole     Ø3.3 through A1's flats along polar 120 deg (the          0
//                        follower's 60), on the finger's mid-plane
//     G1  sector         34-tooth pitch, module 1.25, 20 deg, thinned for          7.069 .. 15.069
//                        backlash, its teeth from 251.471 to 325.588 deg polar,
//                        a tooth on 2.647 + 10.588k deg, cut to their wedge, on
//                        a web R9; the drive's only
//     C2  front collar   Ø8.6                                                      15.069 .. 15.569
//     J2  front journal  Ø8                                                        15.569 .. 19.069
//
// FITS (revised). J1 and J2 are pressed into the MR128s' bores (C-405, 8 x 12 x 3.5):
// fit_pin(8, FIT_PRESS) = Ø7.900. C1 and C2 bear on the inner races alone, halfway across the inner
// ring. A1 goes into the Claw Finger's hex bore, which is grown by FIT_SLIP, so it is drawn at size. H1
// passes the M3 set screw: fit_bore(3, FIT_SLIP) = Ø3.3. G1 meshes with the pinion, a printed part: each
// gear's teeth are thinned by FIT_SLIP / cos 20 along the pitch circle, so that, centred in the mesh, each
// pair of flanks stands FIT_SLIP apart.

include <claw_gears.scad>

/* [Configuration] */
// Parameter set: designed in revised only
config = "revised"; // [revised]
// What to draw: the part, or one layer's 2D section
layer = "part"; // [part, J1, C1, A1, G1]

/* [Hidden] */
$fn = 144;
LAP = 0.005;
// Which axle this file draws; #930-006 includes it and names its own.
SIDE = "drive";

assert(config == "revised", "#930-002 exists only in the revised configuration: it has no reference");

function side() = SIDE == "drive" ? 1 : -1;

// The layers along y, rear to front, each [y span, section index]: the follower's seat runs on over the
// sector's span.
function layers() = let(j = claw_journal_y(), c = claw_collar_y(), a = claw_seat_y(), g = claw_teeth_y())
    concat([[j, 0], [c, 1]], side() > 0 ? [[a, 2], [g, 3]] : [[[a[0], g[1]], 2]],
           [[claw_collar_y(true), 1], [claw_journal_y(true), 0]]);

module layer_2d(i, cfg = config)
    if (i == 0) circle(d = claw_journal_d(cfg));
    else if (i == 1) circle(d = claw_collar_d());
    else if (i == 2) claw_hex_2d();
    else claw_sector_2d(cfg);

// A layer laps LAP into a neighbour only where that neighbour is wider (a higher section index), so that
// the layers fuse and no collar reaches into its MR128's span.
function lap(k, n) = let(l = layers()) n >= 0 && n < len(l) && l[n][1] > l[k][1] ? LAP : 0;

// H1, through the seat along the set screw's line.
module cross_hole(cfg) let(c = fit_clearances(cfg))
    rotate([0, -claw_screw_dir(side()), 0]) rotate([0, 90, 0])
        cylinder(d = fit_bore(claw_screw()[0], c[0]), h = 2 * claw_hex_af(), center = true, $fn = 48);

module claw_gear(cfg = config) difference() {
    multmatrix(AXIS_Y) for (k = [0 : len(layers()) - 1])
        let(y = layers()[k][0], lo = lap(k, k - 1), hi = lap(k, k + 1))
            translate([0, 0, y[0] - lo]) linear_extrude(y[1] - y[0] + lo + hi) layer_2d(layers()[k][1], cfg);
    cross_hole(cfg);
}

if (layer == "part") claw_gear();
else layer_2d(search([layer], ["J1", "C1", "A1", "G1"])[0]);
