// #930-003 Claw Body — parametric source.
// The claw's housing, a hollow container that the Claw Cap (#930-005) closes as its lid: flat plates at the
// rear and a wall of even thickness round the perimeter, which encloses every moving part. It is pushed
// down onto the Span Mount's strake column and strake and over its upright plate and the span XL-320
// (specs/008.11), as the Static Finger is; the Claw Pinion (#930-004) then goes in from the front through
// its tunnel onto the servo's spline. Its upper plate, over the servo, carries the rear MR128 (C-405) of the
// Claw Gear (#930-002) and of the Claw Follower Axle (#930-006), each in a blind seat under a thin cover.
// Each finger, already pinned on its axle, slides in from the open front, through an opening in the wall
// over the top. The Claw Finger Wall (#930-008) then slides in along that opening, its lips in the grooves
// at the opening's ends and behind it, and closes the wall round the blades. The two's tapered rim goes into
// a groove in the cap, and four M3 x 10 (C-609) hold the cap to pillars that blend into the wall.
// claw_params.scad owns the claw's dimensions and gives its mechanism.
//
// Designed, "revised" only: there is no reference mesh.
//
// FRAME. The grip frame (../900-ToolInterface/span_socket.scad): the roll axis on +Z, the span axis along
// +Y through (14.139, 17.5), the pivots along +Y through (±10, 45.180). It prints standing on the upper
// plate's rear face, y -11, open upward, with supports under the lower plate and the shelf only.
//
//     ID  feature        value
//     W1  wall           the outline claw_shell_path() (claw_gears.scad) to the seam, y 15.569, 2.5 thick
//                        round the perimeter, its inside claw_cavity_2d()
//     O1  opening        W1 from upper pillar to upper pillar, y -4 to the seam, each end tangent to its
//                        pillar and normal to the wall, its width FIT_SLIP over #930-008's; the pillars'
//                        blends stop at its ends, behind it too, as far as U1
//     G1  end grooves ×2 1.65 deep into each pillar's blend from O1's end, y -4 forward, open forward: the
//                        cap's groove's faces, 1 of wall outside and the pillar behind
//     G2  rear groove    behind O1, y -4 .. -6.65, on the cap's groove's faces, out to G1; open to the inside
//                        as far as U1; broken at the blades
//     R1  rim            the wall's end, y 15.569 .. 18.069, inset 1.15 from the outline, each face tapered
//                        0.15, 1.35 wide at the seam and 1.05 at its end; it stops FIT_SLIP short of the
//                        lips' ends of #930-008; the wall's shoulder outside it
//     K1  lower plate    y -3.593 .. -1.093, below the shelf, S3's face its rear face
//     U1  upper plate    y -11 .. -6, over S3's ceiling (z 28.05), its bottom corners R5; its rear edge's
//                        round grows from R1.5 at the top to R4 at the bottom, over the pads
//     L1  shelf          2.5 thick over S3's ceiling, joining U1 to K1, the corners inside it rounded R1.5;
//                        the tongue under it, which S3 leaves in V1's groove
//     C1  column sleeve  2.5 round S1, its front cut flat at y 6.569, 1 in front of S1, blended R2 into K1,
//                        up to the shelf's top, z 30.55, over S2
//     M1  MR128 seats   Ø12 at y -9.5 .. -6 on each pivot, open forward; a relief Ø10.2, 0.5 deep, behind
//                        them; a cover of 1 over that, unbroken
//     P1  pinion tunnel  R6 about the span axis, through K1
//     S1  column socket  span_socket.scad's, from the floor z 10, its mouth flared at 45 deg round the
//                        column's foot C2 where W1 reaches below the floor
//     S2  strake slot    span_socket.scad's section, from the column's top to FIT_RUN over the strake's top
//     S3  plate slot     span_socket.scad's, from the floor
//     D1  pillars ×4     R2.5 at claw_cap_bolts(), full depth, blended R3 into W1 as rounded triangles
//     T1  tapped holes   Ø2.6 for the cap's four M3 x 10 (C-609), from the seam to 1 past the bolts' ends,
//         ×4             y 6.369
//     —   fillets        R1.5 on the rear edges; the seam stays square
//
// FITS (revised). M1 takes the MR128s (C-405, 12 OD), pressed: fit_bore(12, FIT_PRESS) = Ø12.1, the relief
// standing FIT_RUN off their inner rings. S1, S2 and S3 are span_socket.scad's, which owns their fits; U1's
// flat bottom is S3's ceiling, K1's rear face S3's +Y face, and U1's rear round clears S3's step. T1 is
// tapped by the M3 bolts: fit_pin(3, FIT_TAP). The fingers, the gear and the pinion turn at least FIT_RUN
// off W1, D1 and P1. R1 stands FIT_SLIP off the cap's groove, and G1 and G2 off #930-008's lips.

include <claw_gears.scad>
use <../900-ToolInterface/span_socket.scad>

/* [Configuration] */
// Parameter set: designed in revised only
config = "revised"; // [revised]

/* [Hidden] */
$fn = 144;
LAP = 0.005;
BIG = 100;

assert(config == "revised", "#930-003 exists only in the revised configuration: it has no reference");

FLOOR    = claw_floor();                 // S1 and S3 run from 1 below it
CORNER_R = 5.000;                        // U1's bottom corners
SHIELD_R = 4.000;                        // U1's rear edge's round at the bottom, which clears S3's step
STRIP    = 10.000;                       // how far up U1 that round reaches
TONGUE   = [6.000, -7.500, 24.000];      // a block S3 cuts the tongue from: half-width, -Y face, bottom
SHELF_R  = 1.500;                        // the corners inside L1
SLEEVE_R = 2.000;                        // C1's blend into K1
R = claw_edge_r();
T = claw_shell_wall();

function shield_bottom() = span_plate_slot_at("revised")[1];               // S3's ceiling, on the servo
function rear_face() = span_plate_slot_at("revised")[0];                   // S3's +Y face, K1's rear face
function seam() = claw_cap_y()[0];
function shelf_top() = shield_bottom() + T;
// How far U1's rear round stands off the corner of S3's step, over the pads.
function shield_off_step() = let(q = span_plate_step_at("revised"), y = claw_cheek_y()[0])
    norm([y + SHIELD_R - q[0], shield_bottom() + SHIELD_R - q[1]]) - SHIELD_R;

assert(shield_off_step() >= 0, str("U1's rear round reaches ", -shield_off_step(), " into S3's step"));
assert(shelf_top() + SHELF_R <= claw_pivot().y - claw_hub_tip_r() - FIT_RUN, "L1's corner reaches the hubs");

module at_pivots() for (s = [-1, 1]) translate([s * claw_pivot().x, claw_pivot().y]) children();
module slab(y, lo = 0, hi = 0) multmatrix(AXIS_Y) translate([0, 0, y[0] - lo]) linear_extrude(y[1] - y[0] + lo + hi) children();
// A (y, z) section run along x.
module along_x() rotate([90, 0, 90]) translate([0, 0, -BIG]) linear_extrude(2 * BIG) children();

// U1's outline: the housing's above S3's ceiling, its bottom corners rounded.
function rear_path() = let(c = intersection(claw_shell_path(), [[-BIG, shield_bottom()], [BIG, shield_bottom()], [BIG, BIG], [-BIG, BIG]])[0])
    offset(offset(c, delta = -CORNER_R), r = CORNER_R, $fn = 48);
// That outline's z over or under a line.
function rear_part(lo, hi) = intersection(rear_path(), [[-BIG, lo], [BIG, lo], [BIG, hi], [-BIG, hi]])[0];

// A band of U1, its rear edge rounded r, run on past K1's rear round so that U1's sides are K1's.
module rear_band(path, r) let(y = [claw_cheek_y()[0], rear_face() + R + 1])
    multmatrix(AXIS_Y) translate([0, 0, y[0]]) offset_sweep(ccw_polygon(path), height = y[1] - y[0], bottom = os_circle(r = r));

// U1: their hull carries the rear edge's round from the top's to the bottom's.
module rear_plate() let(z = shield_bottom() + STRIP) hull() {
    rear_band(rear_part(z - LAP, BIG), R);
    rear_band(rear_part(shield_bottom() - 1, z), SHIELD_R);
}

module lower_block() let(y = [rear_face(), seam()])
    multmatrix(AXIS_Y) translate([0, 0, y[0]]) offset_sweep(claw_shell_path(), height = y[1] - y[0], bottom = os_circle(r = R));

// The inside's (y, z) section: forward of U1 over the shelf, forward of K1 under it, the step rounded.
module inside_section_2d() let(u = claw_cheek_y()[1], k = rear_face() + T)
    offset(r = SHELF_R) offset(r = -2 * SHELF_R) offset(r = SHELF_R)
        polygon([[k, -BIG], [BIG, -BIG], [BIG, BIG], [u, BIG], [u, shelf_top()], [k, shelf_top()]]);

module inside() intersection() {
    slab([claw_cheek_y()[1], seam()], 0, 1) claw_cavity_2d();
    along_x() inside_section_2d();
}

module housing() difference() {
    union() {
        rear_plate();
        lower_block();
    }
    inside();
}

// R1, stopped short of the Claw Finger Wall's.
module rim() let(s = seam(), f = claw_rim_fit()) difference() {
    claw_tapered_ring([s - LAP, s + claw_rim_l()], [claw_rim_outer(0), claw_rim_outer(1)], [claw_rim_inner(0), claw_rim_inner(1)]);
    slab([s, s + claw_rim_l()], 0, 1) claw_wall_zone_2d(-claw_wall_lip_l() - f);
}

// The opening that the Claw Finger Wall (#930-008) fills, with the grooves of its end lips, open forward.
module wall_opening(cfg) let(y = claw_wall_y(), f = claw_rim_fit()) {
    slab(y, 0, 1) claw_wall_zone_2d();
    slab(y, 0, 1) for (s = [-1, 1]) claw_wall_lip_2d(s, f);
}

// The groove behind the opening, the cap's own, out to the end lips' grooves, its inner face open to the
// inside where the wall stands alone; broken at the blades. The pillars' blends stop at the opening's ends
// there too, rather than thin out to nothing along the groove.
module wall_groove(cfg) let(y = claw_wall_y()[0], f = claw_rim_fit(), l = claw_rim_l() + f, k = l / claw_rim_l()) {
    difference() {
        intersection() {
            claw_tapered_ring([y + LAP, y - l], [claw_groove_outer(0), claw_groove_outer(k)], [claw_groove_inner(0), claw_groove_inner(k)]);
            slab([y - l, y], 1, 1) claw_wall_zone_2d(-claw_wall_lip_l() - f);
        }
        slab([y - l, y], 1, 1) offset(delta = -f) claw_finger_clear_2d();
    }
    slab([claw_cheek_y()[1], y], 0, LAP) intersection() {
        claw_wall_zone_2d();
        offset(delta = -claw_groove_inner(k)) polygon(claw_shell_path());
    }
}

// C1's (x, y) section: S1 grown by the wall, flat in front, blended into K1, in front of K1's rear round.
module sleeve_2d() let(y = rear_face() + R) offset(r = -SLEEVE_R) offset(r = SLEEVE_R) union() {
    intersection() {
        offset(r = T) span_socket_2d(0);
        translate([-BIG, y]) square([2 * BIG, claw_keel_front() - y]);
    }
    translate([-BIG, y]) square([2 * BIG, T - R]);
}

module sleeve() intersection() {
    linear_extrude(shelf_top()) sleeve_2d();
    slab([rear_face(), seam()]) polygon(claw_shell_path());
}

// The block S3 cuts the tongue from, into V1's groove.
module tongue() let(t = TONGUE)
    translate([-t[0], t[1], t[2]]) cube([2 * t[0], rear_face() - t[1] + LAP, shield_bottom() + LAP - t[2]]);

module strake_slot(cfg) let(w = span_strake_w(cfg))
    translate([-w.x / 2, -w.y / 2, span_column_top() - LAP]) cube([w.x, w.y, span_strake_top() + FIT_RUN - span_column_top() + LAP]);

module seats(cfg) let(b = claw_rear_bearing_y(), c = claw_cheek_y()[0]) {
    slab(b, 0, 1) at_pivots() circle(d = claw_seat_d(cfg));
    slab([c + claw_cover_t(), b[0]], 0, LAP) at_pivots() circle(d = claw_floor_bore());
}

// P1: closed all round, so that the pinion goes in from the front once the body is on.
module pinion_tunnel() let(s = span_axis())
    slab([span_plate_face(), rear_face() + T], 1, 1) translate(s) circle(r = claw_shank_tunnel_r());

module bolt_holes(cfg) let(d = fit_pin(claw_cap_bolt()[0], fit_clearances(cfg)[3]))
    slab([claw_bolt_end_y() - 1, seam()], 0, 1) for (b = claw_cap_bolts()) translate(b) circle(d = d, $fn = 48);

module claw_body(cfg = config) difference() {
    union() {
        housing();
        rim();
        sleeve();
        tongue();
    }
    span_column_socket(cfg, FLOOR);
    span_column_foot(cfg);
    strake_slot(cfg);
    span_plate_slot(cfg, FLOOR);
    seats(cfg);
    wall_opening(cfg);
    wall_groove(cfg);
    pinion_tunnel();
    bolt_holes(cfg);
}

claw_body();
