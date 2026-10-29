// #930-003 Claw Body — parametric source.
// The claw's base, one model for both claws. It is pushed onto the Span Mount's strake column and strake
// and over its upright plate and the span XL-320 (specs/008.11), as the Static Finger is, and carries the
// two Claw Gears in its pocket and their journals' four MR128s (C-405) in its bearing plate. The fingers
// turn in front of it, on the pivots' noses; the 4-finger claw's outer fingers turn beyond its bearing
// plate. claw_params.scad owns the claw's dimensions and gives its mechanism.
//
// Designed, "revised" only: there is no reference mesh.
//
// FRAME. The grip frame (../900-ToolInterface/span_socket.scad): the roll axis on +Z, the span axis along
// +Y through (14.139, 17.5), the keel's and saddle's floor at z 10. It prints standing on B1's +Y face.
//
//     ID  feature        value
//     K1  keel           in the inner fingers' plane, y -3.743 .. 7.257, from the floor to z 30: within
//                        the fingers' hubs' running clearance (x ±6.639) below the pivots, and FIT_RUN
//                        off the fingers' swept area (claw_sweep_2d()) above them
//     R1  saddle         behind V1, y -12.5 .. -3.743, x ±14.139, from the floor to z 33, over V1's top
//                        and the servo
//     H1  housing        y 7.257 .. 25.5: the hull of R18.053 about both pivots (the gears' tips, FIT_RUN
//                        and 2 of wall), above z 8.5; three slabs along y:
//     W1  front wall       y 7.257 .. 11, the gears' bosses through it in slots open downward
//     P1  pocket           y 11 .. 18, about the gears' tips, open downward
//     B1  bearing plate    y 18 .. 25.5, two MR128 seats about each pivot
//     S1  column socket  span_socket.scad's, from the floor
//     S2  strake slot    span_socket.scad's section, from the column's top to FIT_RUN over the strake's top
//     S3  plate slot     span_socket.scad's, from the floor
//     M1  MR128 seats    Ø12 at y 18 .. 21.5 and 22 .. 25.5, Ø11.2 between, on each pivot
//
// FITS (revised). M1 takes the MR128s (C-405, 12 OD), pressed: fit_bore(12, FIT_PRESS) = Ø12.1. S1, S2 and
// S3 are span_socket.scad's, which owns their fits. The gears turn FIT_RUN off W1's slots, P1 and W1's and
// B1's faces, and the fingers FIT_RUN off K1 and the Span Mount's V1.

include <claw_params.scad>

/* [Configuration] */
// Parameter set: designed in revised only
config = "revised"; // [revised]

/* [Hidden] */
$fn = 144;
LAP = 0.005;
BIG = 100;

assert(config == "revised", "#930-003 exists only in the revised configuration: it has no reference");

FLOOR      = 10.000;                     // the Static Finger's: S1 and S3 run from 1 below it
H_FLOOR    = 8.500;                      // H1's, clear of the column's foot (912-001 C2), 2.95 under M1
KEEL_TOP   = 30.000;
SADDLE     = [-12.500, 33.000];          // R1's -Y face and top
WALL       = 2.000;                      // H1 over P1
SEATS      = [12.000, 11.200];           // M1: MR128 OD, the shoulder between

function y_keel() = [span_plate_face(), claw_front_wall_y()[0]];
function y_pocket() = [claw_front_wall_y()[1], claw_plate_y()[0]];
function pocket_r() = claw_gear_tip_r() + FIT_RUN;

module at_pivots() for (s = [-1, 1]) translate([s * claw_pivot().x, claw_pivot().y]) children();
module mirrored() for (m = [0, 1]) mirror([m, 0]) children();
module slab(y, lo = 0, hi = 0) multmatrix(AXIS_Y) translate([0, 0, y[0] - lo]) linear_extrude(y[1] - y[0] + lo + hi) children();

// Below the pivots, K1 stays inside the hubs' running clearance, so that the body comes down past the
// Span Driver's head; above them it fills out to the fingers' swept area.
module keel_2d() let(p = claw_pivot(), w = p.x - claw_hub_r() - FIT_RUN) difference() {
    union() {
        translate([-w, FLOOR]) square([2 * w, KEEL_TOP - FLOOR]);
        translate([-p.x, p.y]) square([2 * p.x, KEEL_TOP - p.y]);
    }
    offset(r = FIT_RUN) mirrored() claw_sweep_2d();
}

module housing_2d() intersection() {
    hull() at_pivots() circle(r = pocket_r() + WALL);
    translate([-BIG, H_FLOOR]) square([2 * BIG, BIG]);
}

module down_from(r) union() { circle(r = r); translate([-r, -BIG]) square([2 * r, BIG]); }

module saddle() let(p = claw_pivot())
    translate([-p.x, SADDLE[0], FLOOR]) cube([2 * p.x, span_plate_face() - SADDLE[0] + LAP, SADDLE[1] - FLOOR]);

module strake_slot(cfg) let(w = span_strake_w(cfg))
    translate([-w.x / 2, -w.y / 2, span_column_top() - LAP]) cube([w.x, w.y, span_strake_top() + FIT_RUN - span_column_top() + LAP]);

module seats(cfg) let(d = fit_bore(SEATS[0], fit_clearances(cfg)[1]), s = claw_seats_y()) {
    slab(s[0], 1, 0) at_pivots() circle(d = d);
    slab([s[0][1], s[1][0]], LAP, LAP) at_pivots() circle(d = SEATS[1]);
    slab(s[1], 0, 1) at_pivots() circle(d = d);
}

module claw_body(cfg = config) difference() {
    union() {
        slab(y_keel(), 0, LAP) keel_2d();
        saddle();
        slab([claw_front_wall_y()[0], claw_plate_y()[1]]) housing_2d();
    }
    span_column_socket(cfg, FLOOR);
    strake_slot(cfg);
    span_plate_slot(cfg, FLOOR);
    slab(claw_front_wall_y(), 1, LAP) at_pivots() down_from(claw_boss_d() / 2 + FIT_RUN);
    slab(y_pocket()) at_pivots() down_from(pocket_r());
    seats(cfg);
}

claw_body();
