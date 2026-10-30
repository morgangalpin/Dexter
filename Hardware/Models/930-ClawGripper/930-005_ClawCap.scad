// #930-005 Claw Cap — parametric source.
// The claw's front plate, one model for both claws: it carries the front MR128 (C-405) of each Claw Gear
// (#930-002) and the Claw Pinion's (#930-004), so that every axis of the claw runs in bearings at both
// ends, and is held on the Claw Body's front face (#930-003) by three M3 x 10 (C-609). It goes on last,
// over the gears' and the pinion's front journals, and its seats' faces stop the gears' collars.
// claw_params.scad owns its dimensions and gives the claw's mechanism.
//
// Designed, "revised" only: there is no reference mesh.
//
// FRAME. The grip frame (../900-ToolInterface/span_socket.scad), as the Claw Body's. It prints standing on
// its rear face, y 25.
//
//     ID  feature        value
//     P1  plate          y 25 .. 30: the hull of R8.55 about both pivots and the span axis, and the body's
//                        front face (x ±29, z 10 .. 22.065)
//     M1  MR128 seats ×3 Ø12 at y 25 .. 28.5 on both pivots and the span axis, open rearward; a floor bored
//                        Ø10.2 in front of them
//     H1  bolt holes ×3  Ø3.3 through, on the body's T1
//
// FITS (revised). M1 takes the MR128s (C-405, 12 OD), pressed: fit_bore(12, FIT_PRESS) = Ø12.1, their floor
// bored to stand FIT_RUN off the inner rings. H1 takes the M3 bolts: fit_bore(3, FIT_SLIP) = Ø3.3. P1's rear
// face seats on the body's front face.

include <claw_params.scad>

/* [Configuration] */
// Parameter set: designed in revised only
config = "revised"; // [revised]

/* [Hidden] */
$fn = 144;
LAP = 0.005;

assert(config == "revised", "#930-005 exists only in the revised configuration: it has no reference");

function axes() = let(p = claw_pivot()) [[p.x, p.y], [-p.x, p.y], span_axis()];

module slab(y, lo = 0, hi = 0) multmatrix(AXIS_Y) translate([0, 0, y[0] - lo]) linear_extrude(y[1] - y[0] + lo + hi) children();

module plate_2d() hull() {
    for (a = axes()) translate(a) circle(r = claw_seat_d("revised") / 2 + claw_cap_wall());
    translate([-claw_block_x(), claw_floor()]) square([2 * claw_block_x(), claw_front_top() - claw_floor()]);
}

module claw_cap(cfg = config) let(c = fit_clearances(cfg), y = claw_cap_y(), b = claw_front_bearing_y()) difference() {
    slab(y) plate_2d();
    slab(b, 1, 0) for (a = axes()) translate(a) circle(d = claw_seat_d(cfg));
    slab([b[1], y[1]], LAP, 1) for (a = axes()) translate(a) circle(d = claw_floor_bore());
    slab(y, 1, 1) for (h = claw_cap_bolts()) translate(h) circle(d = fit_bore(3, c[0]), $fn = 48);
}

claw_cap();
