// #930-004 Claw Pinion — parametric source.
// The claw's drive, in one piece: the Span Driver's spline end (#912-002 L1 .. L4), pushed onto the span
// XL-320's spline and held by its M2.6 x 10 bolt (specs/008.11 steps 36-37), a shank, a 10-tooth pinion
// that drives the drive Claw Gear's sector (#930-002), and a Ø8 journal in an MR128 (C-405) in the Claw
// Cap (#930-005), so that the servo's spline and the cap carry it at its two ends. It goes in from the
// front through the Claw Body's tunnel, once the body is on the Span Mount, and the bolt is driven
// through the access bore from the front. claw_params.scad owns its dimensions and gives the mechanism.
//
// Designed, "revised" only: there is no reference mesh.
//
// FRAME. Its own: the span axis along +Y through the origin, y the grip frame's, and (x, z) the grip
// frame's about the span axis with the claw closed. #912-002's layers stand at their own y plus
// span_driver_y(). It prints standing on S1's end.
//
//     ID  feature        value                                                     y span
//     E1  spline end     #912-002 revised L1 .. L4: the spline sleeve and its      -9.318 .. -3.493
//                        bore, collar, flange, bolt hole and key slot, as that
//                        file draws them
//     K1  bolt hole      #912-002's K1 and K2, run on through the shank            -3.493 .. -1.493
//     S1  shank          Ø11                                                       -3.493 .. 7.069
//     G1  pinion         10 teeth, module 1.25, 20 deg, profile-shifted 0.415 and   7.069 .. 15.069
//                        its tips shortened for it, thinned for backlash, in
//                        phase with the drive sector closed (claw_pinion_tooth0())
//     C1  collar         Ø8.6                                                      15.069 .. 15.569
//     J1  journal        Ø8                                                        15.569 .. 19.069
//     A1  access bore    Ø5.8 from the bolt head's seat out through J1             -1.493 .. 19.069
//
// FITS (revised). E1 and K1 are #912-002's, which owns their fits on the servo's spline and key and on
// the bolt. A1 takes the M2.6 bolt's head as #912-002's C1 does: fit_bore(5.5, FIT_SLIP) = Ø5.800, which
// leaves J1 a wall of 1.05. J1 is pressed into the MR128's bore: fit_pin(8, FIT_PRESS) = Ø7.900, and C1
// bears on its inner race alone. G1 meshes with the gear's sector, a printed part, thinned by
// FIT_SLIP / cos 20 along the pitch circle as the sector is.

include <claw_gears.scad>
use <../900-ToolInterface/912-002_SpanDriver.scad>

/* [Configuration] */
// Parameter set: designed in revised only
config = "revised"; // [revised]
// What to draw: the part, or one layer's 2D section
layer = "part"; // [part, S1, G1, C1, J1]

/* [Hidden] */
$fn = 144;
LAP = 0.005;

assert(config == "revised", "#930-004 exists only in the revised configuration: it has no reference");

function ys() = [for (y = layer_y()) y + span_driver_y()];
function seat_y() = ys()[5];             // the bolt head's seat, #912-002's C1 floor
function front_y() = claw_journal_y(true)[1];

// The layers from the bolt head's seat on, each [y span, section index].
function layers() = [[[ys()[4], claw_teeth_y()[0]], 0], [claw_teeth_y(), 1], [claw_collar_y(true), 2],
                     [claw_journal_y(true), 3]];

module pinion_layer_2d(i, cfg = config)
    if (i == 0) circle(d = claw_shank_d());
    else if (i == 1) claw_pinion_2d(cfg);
    else if (i == 2) circle(d = claw_collar_d());
    else circle(d = claw_journal_d(cfg));

// Each section's rank by width, narrowest first: the journal, the collar, the teeth, the shank, which
// stands wider than the teeth's root and so takes their lap rather than reaching into the sector's face. A
// layer laps LAP into a neighbour only where that neighbour is wider, so that no collar reaches into its
// MR128's span; the first laps into E1.
function rank(i) = [3, 2, 1, 0][i];
function lap(k, n) = let(l = layers()) n < 0 ? LAP : n < len(l) && rank(l[n][1]) > rank(l[k][1]) ? LAP : 0;

module along(y, lo = 0, hi = 0) multmatrix(AXIS_Y) translate([0, 0, y[0] - lo]) linear_extrude(y[1] - y[0] + lo + hi) children();

// E1: #912-002's L1 .. L4 (its layer_2d()), at their y.
module spline_end(cfg) let(y = ys()) for (i = [0 : 3]) along([y[i], y[i + 1]], i > 0 ? LAP : 0) layer_2d(i, cfg);

module claw_pinion(cfg = config) let(c = fit_clearances(cfg)) difference() {
    union() {
        spline_end(cfg);
        for (k = [0 : len(layers()) - 1]) along(layers()[k][0], lap(k, k - 1), lap(k, k + 1))
            pinion_layer_2d(layers()[k][1], cfg);
    }
    translate([0, span_driver_y(), 0]) rotate([-90, 0, 0]) end_round();   // #912-002's, its axis onto +y
    along([ys()[4], seat_y()], 1, 0) key_2d(cfg);
    along([seat_y(), front_y()], 0, 1) circle(d = fit_bore(5.5, c[0]), $fn = 96);
}

if (layer == "part") claw_pinion();
else pinion_layer_2d(search([layer], ["S1", "G1", "C1", "J1"])[0]);
