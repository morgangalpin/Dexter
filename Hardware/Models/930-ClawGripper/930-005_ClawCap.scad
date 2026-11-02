// #930-005 Claw Cap — parametric source.
// The lid of the Claw Body (#930-003): a flat plate on the body's outline, so that the two read as one
// piece. It carries the front MR128 (C-405) of each Claw Axle (#930-006) and of the Claw Pinion
// (#930-004), each in a blind seat under a thin cover, so that every
// axis of the claw runs in bearings at both ends. A groove takes the tapered rim of the body and the Claw
// Finger Wall (#930-008), which locates it across the seam and traps the wall. Nothing stands off its rear
// face, so that it is one part in the 2-finger and 4-finger builds. It goes on last, its MR128s pressed in from
// the inside, over the axles' and the pinion's journals, and four M3 x 10 (C-609) hold it to the body's pillars.
// claw_params.scad owns its dimensions and gives the claw's mechanism.
//
// Designed, "revised" only: there is no reference mesh.
//
// FRAME. The grip frame (../900-ToolInterface/span_socket.scad), as the Claw Body's. It prints standing on
// its front face, y 20.569, open upward, with no supports.
//
//     ID  feature        value
//     P1  plate          y 15.569 .. 20.569, on claw_shell_path() (claw_gears.scad), its front face's edge
//                        filleted R1.5, its rear face square on the seam
//     G1  rim groove     round the outline, 1 in from it at the seam, 1.65 wide there and 1.35 at its end,
//                        each face tapered 0.15, 2.65 deep; filled at the blades' cutouts, FIT_SLIP in from
//                        the cut in the wall's lip
//     M1  MR128 seats ×3 Ø12 at y 15.569 .. 19.069 on both pivots and the span axis, open rearward; a
//                        relief Ø10.2, 0.5 deep, in front of them; a cover of 1 over that, unbroken
//     H1  bolt holes ×4 Ø3.3 through, on the body's T1, in Ø5.8 recesses 3.2 deep from the front face
//
// FITS (revised). M1 takes the MR128s (C-405, 12 OD), pressed: fit_bore(12, FIT_PRESS) = Ø12.1, the relief
// standing FIT_RUN off their inner rings. H1 takes the M3 bolts and their heads: fit_bore(3, FIT_SLIP) =
// Ø3.3 and fit_bore(5.5, FIT_SLIP) = Ø5.8, the heads 0.2 under the front face. G1 stands FIT_SLIP off the
// rim's faces and its end. P1's rear face seats on the wall's shoulders and on the pillars, and the sector,
// the teeth and the collars turn FIT_RUN off it.

include <claw_gears.scad>

/* [Configuration] */
// Parameter set: designed in revised only
config = "revised"; // [revised]

/* [Hidden] */
$fn = 144;
LAP = 0.005;

assert(config == "revised", "#930-005 exists only in the revised configuration: it has no reference");

function axes() = let(p = claw_pivot()) [[p.x, p.y], [-p.x, p.y], span_axis()];
function seam() = claw_cap_y()[0];

module slab(y, lo = 0, hi = 0) multmatrix(AXIS_Y) translate([0, 0, y[0] - lo]) linear_extrude(y[1] - y[0] + lo + hi) children();

module plate() let(y = claw_cap_y())
    multmatrix(AXIS_Y) translate([0, 0, y[0]]) offset_sweep(claw_shell_path(), height = y[1] - y[0], top = os_circle(r = claw_edge_r()));

// G1, filled at the blades' cutouts, where the 4-finger build's front pair opens through the wall's lip and
// the 2-finger's lip stops to match. The rim's end stands the fit off its end.
module groove(cfg) let(s = seam(), f = claw_rim_fit(), l = claw_rim_l() + f, k = l / claw_rim_l()) difference() {
    claw_tapered_ring([s - LAP, s + l], [claw_groove_outer(0), claw_groove_outer(k)], [claw_groove_inner(0), claw_groove_inner(k)]);
    slab([s, s + l], 1, 1) claw_groove_land_2d();
}

module seats(cfg) let(b = claw_front_bearing_y()) {
    slab(b, LAP, 0) for (a = axes()) translate(a) circle(d = claw_seat_d(cfg));
    slab([b[1], claw_cap_y()[1] - claw_cover_t()], LAP, 0) for (a = axes()) translate(a) circle(d = claw_floor_bore());
}

module bolt_holes(cfg) let(c = fit_clearances(cfg), y = claw_cap_y(), s = claw_bolt_seat_y()) {
    slab([y[0], s], 1, LAP) for (h = claw_cap_bolts()) translate(h) circle(d = fit_bore(claw_cap_bolt()[0], c[0]), $fn = 48);
    slab([s, y[1]], 0, 1) for (h = claw_cap_bolts()) translate(h) circle(d = claw_bolt_recess_d(), $fn = 72);
}

module claw_cap(cfg = config) difference() {
    plate();
    groove(cfg);
    seats(cfg);
    bolt_holes(cfg);
}

claw_cap();
