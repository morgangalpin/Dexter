// #930-003 Claw Body — parametric source.
// The claw's base, one model for both claws. It is pushed down onto the Span Mount's strake column and
// strake and over its upright plate and the span XL-320 (specs/008.11), as the Static Finger is, past the
// Claw Pinion (#930-004) already on the servo's spline. Its rear cheek, over the servo, carries one MR128
// (C-405) for each Claw Gear (#930-002); the Claw Cap (#930-005), bolted to its front face, carries the
// gears' other MR128s and the pinion's. The fingers turn over it, the sectors in front of finger A.
// claw_params.scad owns the claw's dimensions and gives its mechanism.
//
// Designed, "revised" only: there is no reference mesh.
//
// FRAME. The grip frame (../900-ToolInterface/span_socket.scad): the roll axis on +Z, the span axis along
// +Y through (14.139, 17.5), the pivots along +Y through (±18.75, 42.565), the floor at z 10. It prints
// standing on its front face, y 25.
//
//     ID  feature        value
//     R1  saddle         behind V1, y -12.5 .. -3.743, x ±14.139, from the floor to z 33, over V1's top
//                        and the servo
//     E1  rear cheek     y -11 .. -6, over the saddle: the hull of R8.55 about both pivots and the
//                        saddle's top, x ±14.139 from z 30
//     M1  MR128 seats    Ø12 at y -9.5 .. -6 on each pivot, open forward; a floor bored Ø10.2 behind them
//     K1  keel           in finger A's plane, y -3.743 .. 5, x ±29, from the floor to z 33.065,
//                        FIT_RUN under the fingers' hubs
//     F1  front block    y 5 .. 25, x ±29, from the floor to z 22.065, FIT_RUN under the sectors' tips, so that each gear
//                        passes over it into its MR128 from the front
//     P1  pinion slot    about the span axis, open downward: R6 round the pinion's shank and collar,
//                        R8.485 round its teeth (y 5 .. 14)
//     S1  column socket  span_socket.scad's, from the floor
//     S2  strake slot    span_socket.scad's section, from the column's top to FIT_RUN over the strake's top
//     S3  plate slot     span_socket.scad's, from the floor
//     T1  tapped holes   Ø2.6 for the cap's three M3 x 10 (C-609), 7 deep from the front face, at z 16 and
//         ×3             x -22, 0 and 25.5
//
// FITS (revised). M1 takes the MR128s (C-405, 12 OD), pressed: fit_bore(12, FIT_PRESS) = Ø12.1, their floor
// bored to stand FIT_RUN off the inner rings. S1, S2 and S3 are span_socket.scad's, which owns their fits.
// T1 is tapped by the M3 bolts: fit_pin(3, FIT_TAP). The fingers and the gears turn FIT_RUN off K1, F1
// and E1's face, and the pinion FIT_RUN off P1.

include <claw_gears.scad>

/* [Configuration] */
// Parameter set: designed in revised only
config = "revised"; // [revised]

/* [Hidden] */
$fn = 144;
LAP = 0.005;
BIG = 100;

assert(config == "revised", "#930-003 exists only in the revised configuration: it has no reference");

FLOOR   = claw_floor();                  // S1 and S3 run from 1 below it
SADDLE  = [-12.500, 33.000];             // R1's -Y face and top
CHEEK_Z = 30.000;                        // E1: the bottom of its join to R1
BOLT_DEPTH = 7.000;                      // T1

function keel_top() = claw_pivot().y - claw_hub_r() - FIT_RUN;            // under the hubs
function y_keel() = [span_plate_face(), claw_finger_y()[1]];
function y_front() = [claw_finger_y()[1], claw_cap_y()[0]];

module at_pivots() for (s = [-1, 1]) translate([s * claw_pivot().x, claw_pivot().y]) children();
module slab(y, lo = 0, hi = 0) multmatrix(AXIS_Y) translate([0, 0, y[0] - lo]) linear_extrude(y[1] - y[0] + lo + hi) children();
module down_from(r) union() { circle(r = r); translate([-r, -BIG]) square([2 * r, BIG]); }
module mirrored() for (m = [0, 1]) mirror([m, 0]) children();

module block_2d(top) translate([-claw_block_x(), FLOOR]) square([2 * claw_block_x(), top - FLOOR]);

module cheek_2d() hull() {
    at_pivots() circle(r = claw_seat_d("revised") / 2 + claw_cap_wall());
    translate([-span_axis().x, CHEEK_Z]) square([2 * span_axis().x, SADDLE[1] - CHEEK_Z]);
}

module saddle() let(x = span_axis().x)
    translate([-x, SADDLE[0], FLOOR]) cube([2 * x, span_plate_face() - SADDLE[0] + LAP, SADDLE[1] - FLOOR]);

module strake_slot(cfg) let(w = span_strake_w(cfg))
    translate([-w.x / 2, -w.y / 2, span_column_top() - LAP]) cube([w.x, w.y, span_strake_top() + FIT_RUN - span_column_top() + LAP]);

module seats(cfg) let(b = claw_rear_bearing_y()) {
    slab(b, 0, 1) at_pivots() circle(d = claw_seat_d(cfg));
    slab([claw_cheek_y()[0], b[0]], 1, LAP) at_pivots() circle(d = claw_floor_bore());
}

// P1: round the pinion's shank and collar, and wider round its teeth.
module pinion_slot() let(s = span_axis(), t = claw_teeth_y()) {
    slab([span_plate_face(), claw_cap_y()[0]], 1, 1) translate(s) down_from(claw_shank_d() / 2 + FIT_RUN);
    slab([t[0] - FIT_RUN, t[1] + FIT_RUN]) translate(s) down_from(claw_pinion_tip_r() + FIT_RUN);
}

// The parts that turn over the body, each grown by FIT_RUN: the fingers in their two planes, the sectors
// in theirs.
module sweeps() let(t = claw_teeth_y()) {
    for (b = [false, true]) slab(claw_finger_y(b), FIT_RUN, FIT_RUN) offset(r = FIT_RUN) mirrored() claw_sweep_2d();
    slab(t, FIT_RUN, FIT_RUN) offset(r = FIT_RUN) for (s = [-1, 1]) claw_gear_sweep_2d(s);
}

module bolt_holes(cfg) let(d = fit_pin(3, fit_clearances(cfg)[3]), y = claw_cap_y()[0])
    slab([y - BOLT_DEPTH, y], 0, 1) for (b = claw_cap_bolts()) translate(b) circle(d = d, $fn = 48);

module claw_body(cfg = config) difference() {
    union() {
        saddle();
        slab(claw_cheek_y()) cheek_2d();
        slab(y_keel(), LAP, LAP) block_2d(keel_top());
        slab(y_front()) block_2d(claw_front_top());
    }
    span_column_socket(cfg, FLOOR);
    strake_slot(cfg);
    span_plate_slot(cfg, FLOOR);
    seats(cfg);
    pinion_slot();
    sweeps();
    bolt_holes(cfg);
}

claw_body();
