// 930-ClawGripper — the claw's design parameters, and the outlines its parts share.
// The single owner of the claw's dimensions: its parts include this file, and its assemblies use it.
//
// THE CLAW. Two curved fingers (#930-001) turn about two pivots along the span axis's direction, set
// symmetrically about the roll axis above the span XL-320, so that their tips meet on the roll axis. Each
// pivot carries a Claw Gear (#930-002): a toothed sector between two hex seats and two Ø8 journals, in one
// piece. The two sectors mesh 1:1, so the fingers turn equal and opposite. The Claw Pinion (#930-004), one
// piece with the sleeve on the servo's spline, drives the sector on +X at claw_ratio() : 1. Each gear runs
// in an MR128 in the Claw Body's rear cheek (#930-003) and another in the Claw Cap (#930-005); the
// pinion runs on the servo's spline and in a third MR128 in the cap. A finger's closed hub, a hex bore,
// slides over a seat and is held by one set screw: seat A carries the 2-finger claw's fingers, and the
// 4-finger claw adds a second finger on seat B, in front of the sectors.
//
// FRAME. The grip frame (../900-ToolInterface/span_socket.scad): the roll axis on +Z, every axis along +Y.
// A finger, a gear and the pinion are each drawn in their own frame, whose origin is on its axis, whose y
// is the grip frame's (a finger's is its mid-plane's offset), and whose (x, z) is the grip frame's about
// that axis with the claw closed; the drive pivot is the one on +X. Their 2D sections are drawn in that
// (x, z) and stacked along y by AXIS_Y. Angles in (x, z) are polar, from +X toward +Z.
//
// THE FLIP. One finger serves every place: it is symmetric about its own mid-plane and its hex is
// symmetric about its own x = 0, so the follower's is the drive's turned 180 deg about Z. One gear
// serves both pivots, the follower's turned GEAR_TURN about its own axis. Two gears of one tooth pattern
// mesh along the line between their pivots when a tooth stands a quarter of a pitch off that line
// (claw_sector_tooth0()): a tooth of the drive at 180 + e needs a gap of the follower at -e, which for an
// even tooth count is 2 t0 = p / 2 mod p. GEAR_TURN is a whole number of pitches, which keeps that
// pattern, and of the hex's 60 deg, which keeps the seats square to the fingers.
//
// MOTION. OPEN, deg: the drive pivot turns +OPEN about +Y, the follower -OPEN and the pinion
// -claw_ratio() * OPEN; 0 is closed, the tips meeting on x = 0, and claw_open_max() is fully open.

include <../print_fit.scad>
use <../900-ToolInterface/span_socket.scad>
use <../c102_servo.scad>

// Sections in (x, z) stacked along y: sends 2D y to z and extrusion z to y.
AXIS_Y = [[1, 0, 0, 0], [0, 0, 1, 0], [0, 1, 0, 0], [0, 0, 0, 1]];

// --- Gears ------------------------------------------------------------------------------------------
// A module-1.25 pinion of 10 teeth, profile-shifted against undercut, on the span axis, and two sectors
// cut from a 30-tooth gear that mesh on the roll axis's plane. The gears' geometry is computed here by
// the standard involute relations, so that the assemblies can use this file without BOSL2, whose core
// overrides a `use` would carry; claw_gears.scad draws the teeth with BOSL2 and asserts that it agrees.

MOD       = 1.250;
PA        = 20;
PINION_N  = 10;
SECTOR_N  = 30;
GEAR_TURN = 120;                                  // the follower's gear about its axis, polar deg

function claw_mod() = MOD;
function claw_pa() = PA;
function claw_pinion_n() = PINION_N;
function claw_sector_n() = SECTOR_N;
function claw_ratio() = SECTOR_N / PINION_N;
function claw_gear_turn() = GEAR_TURN;
function claw_open_max() = 25;                    // deg, at the fingers
// Each gear's teeth thinned so that a flank stands FIT_SLIP off its mate's, normal to it, at the pitch
// circle: half of each gear's circular backlash per flank, times cos of the pressure angle, twice.
function claw_gear_backlash(cfg) = fit_clearances(cfg)[0] / cos(PA);
// The pinion's profile shift: the least that clears undercut, 1 - z sin^2(a) / 2 (BOSL2's "auto").
function claw_pinion_shift() = 1 - PINION_N * sin(PA) ^ 2 / 2;
// The involute function, and its inverse by Newton's method, deg.
function inv(a) = tan(a) - a * PI / 180;
function inv_of(c, a = 20, i = 0) = i == 8 ? a : inv_of(c, a - (inv(a) - c) / tan(a) ^ 2 * 180 / PI, i + 1);
// The pinion's working centre distance to a sector: its shift opens the pressure angle at the mesh.
function claw_pinion_dist() = let(z = PINION_N + SECTOR_N,
                                  aw = inv_of(2 * tan(PA) * claw_pinion_shift() / z + inv(PA)))
    MOD * z / 2 * cos(PA) / cos(aw);
// The pinion's tips shortened by what the shift adds beyond the distance opened, so that they keep the
// root clearance in the sector.
function claw_pinion_shorten() = claw_pinion_shift() - (claw_pinion_dist() - MOD * (PINION_N + SECTOR_N) / 2) / MOD;

// The pivots: the sectors' centre distance apart about the roll axis, at the pinion's centre distance
// from the span axis. The drive pivot is (x, z); the follower is at -x.
function claw_pinion_axis() = span_axis();
function claw_pivot() = let(s = span_axis(), p = MOD * SECTOR_N / 2, d = claw_pinion_dist())
    [p, s.y + sqrt(d ^ 2 - (p - s.x) ^ 2)];
// From the drive pivot toward the pinion, and back, polar deg.
function claw_pinion_dir() = let(d = span_axis() - claw_pivot()) atan2(d.y, d.x) + 360;
function claw_pivot_dir() = claw_pinion_dir() - 180;

function claw_sector_pitch() = 360 / SECTOR_N;
function claw_sector_tooth0() = claw_sector_pitch() / 4;         // a tooth on it, polar
// The pinion's teeth against the drive sector's: where the sector has a tooth at the pinion's line + e,
// the pinion has a gap at its own line - ratio * e.
function claw_pinion_tooth0() = let(e = claw_sector_tooth0() - claw_pinion_dir())
    claw_pivot_dir() - claw_ratio() * e + 180 / PINION_N;
// BOSL2 draws a tooth on +Y, which AXIS_Y sends to +Z (polar 90).
function claw_sector_spin() = claw_sector_tooth0() - 90;
function claw_pinion_spin() = claw_pinion_tooth0() - 90;

// Tip radii: the pitch radius, one module, and the shift less the shortening.
function claw_sector_tip_r() = MOD * (SECTOR_N / 2 + 1);
function claw_pinion_tip_r() = MOD * (PINION_N / 2 + 1 + claw_pinion_shift() - claw_pinion_shorten());
// The sector's disc, inside its root circle (BOSL2's, with its 0.25 module clearance).
function claw_sector_disc_r() = MOD * (SECTOR_N / 2 - 1.25) - 2 * MOD;

// The sector's teeth, polar in the gear's own frame: what the drive meets the follower and the pinion
// through, over the travel, a pitch beyond at each end, ended in a gap's middle. The follower meets the
// drive through the same teeth turned GEAR_TURN (claw_sector_covers()).
function claw_sector_arc() = let(p = claw_sector_pitch(), g = claw_sector_tooth0() + p / 2,
                                 lo = 180 - p, hi = claw_pinion_dir() + claw_open_max() + p)
    [g + p * floor((lo - g) / p), g + p * ceil((hi - g) / p)];
// The follower's teeth that face the drive over the travel, in its gear's own frame.
function claw_follower_need() = [360 - GEAR_TURN - claw_open_max(), 360 - GEAR_TURN];
function claw_sector_covers() = let(a = claw_sector_arc(), n = claw_follower_need())
    n[0] >= a[0] + claw_sector_pitch() && n[1] <= a[1] - claw_sector_pitch();

// --- Along y (the grip frame's) ---------------------------------------------------------------------
// The rear cheek's MR128, finger A over seat A, the sectors and the pinion's teeth, finger B over seat B
// (4 fingers), and the cap's MR128s; each gear's collars bear on its MR128s' inner races.

MR128      = [8.000, 12.000, 3.500];             // C-405: bore, OD, width
MR128_RING = [9.200, 10.800];                    // inner ring OD, outer ring ID: the race model
FINGER_T   = 10.000;                             // a finger's hub, along y
GEAR_T     = 8.000;                              // the teeth's face width
COLLAR_T   = 0.500;

function y_span(y0, t) = [y0, y0 + t];
function claw_finger_y(b = false) = y_span(b ? claw_teeth_y()[1] + FIT_RUN : -FINGER_T / 2, FINGER_T);
function claw_finger_mid(b = false) = let(f = claw_finger_y(b)) (f[0] + f[1]) / 2;
function claw_teeth_y() = y_span(FINGER_T / 2 + FIT_RUN, GEAR_T);
function claw_seat_y(b = false) = b ? [claw_teeth_y()[1], claw_finger_y(true)[1] + FIT_RUN]
                                    : [claw_finger_y()[0] - FIT_RUN, claw_teeth_y()[0]];
function claw_collar_y(b = false) = b ? y_span(claw_seat_y(true)[1], COLLAR_T) : y_span(claw_seat_y()[0] - COLLAR_T, COLLAR_T);
// The MR128s: the rear cheek's behind collar A, the cap's in front of collar B.
function claw_rear_bearing_y() = y_span(claw_collar_y()[0] - MR128[2], MR128[2]);
function claw_front_bearing_y() = y_span(claw_collar_y(true)[1], MR128[2]);
function claw_journal_y(b = false) = b ? claw_front_bearing_y() : claw_rear_bearing_y();
// The cap: its rear face on the MR128s' faces, a floor beyond them.
CAP_FLOOR = 1.500;
function claw_cap_y() = [claw_front_bearing_y()[0], claw_front_bearing_y()[1] + CAP_FLOOR];
function claw_cheek_y() = [claw_rear_bearing_y()[0] - CAP_FLOOR, claw_rear_bearing_y()[1]];

// A shoulder on a race: on the inner alone, halfway across its ring; on the outer alone, bored to the
// running clearance off the inner ring (700-Differential/diff_params.scad's rule, an MR128's ring being
// too narrow to bore it halfway).
function claw_collar_d() = (MR128[0] + MR128_RING[0]) / 2;
function claw_floor_bore() = MR128_RING[0] + 2 * FIT_RUN;
function claw_mr128() = MR128;
function claw_mr128_ring() = MR128_RING;
// An MR128's seat, pressed.
function claw_seat_d(cfg) = fit_bore(MR128[1], fit_clearances(cfg)[1]);
// The cap's M3 x 10 bolts (C-609), (x, z) on the body's front face; and the cap's wall round its seats.
function claw_cap_bolts() = [[-22, 16], [0, 16], [25.5, 16]];
function claw_cap_wall() = 2.500;
// The Claw Body's front block, which the cap seats on: its half-width, its floor (the Static Finger's),
// and its top, FIT_RUN under the sectors so that each gear passes over it into its rear MR128.
function claw_block_x() = 29.000;
function claw_floor() = 10.000;
function claw_front_top() = claw_pivot().y - claw_sector_tip_r() - FIT_RUN;

// --- Seats and journals -----------------------------------------------------------------------------

HEX_AF  = 10.000;                                // the seats, across flats; a vertex on +Z
JOURNAL = MR128[0];                              // in the MR128s, at FIT_PRESS

function claw_hex_af() = HEX_AF;
function claw_shank_d() = 11.000;                // the pinion's, off its teeth: #912-002's flange's
function claw_journal_d(cfg) = fit_pin(JOURNAL, fit_clearances(cfg)[1]);
// The hex across flats, grown by c on every face; its flats face ±X.
module claw_hex_2d(c = 0) rotate(30) circle(r = (HEX_AF / 2 + c) / cos(30), $fn = 6);

// --- Finger -----------------------------------------------------------------------------------------
// The blade follows the legacy claw finger's curve (Reference/superseded/ClawFinger_published-920-002.stl,
// at y 0): a straight shank off the hub, tangent into an arc whose grip face is R20.277 over 66.4 deg,
// ended in a full round. The shank's length keeps the pivot-to-tip length of the claw's first design,
// and its lean puts the closed tips' rounds touching on x = 0.

HUB_R    = 9.000;                                // round the hex: 3.86 over a vertex
BLADE_T  = 7.000;                                // the blade, along y, about the mid-plane
BLADE_W  = 7.000;                                // the blade's width in its plane
GRIP_R   = 20.277;                               // the arc's grip face: 920-002's
GRIP_ARC = 66.400;                               // the arc's span: 920-002's
TIP_L    = 77.300;                               // pivot to the tip round's centre
ROOT_R   = 2.000;                                // the blade's fillet onto the hub
SCREW    = [3.000, 4.000];                       // C-618 M3 x 4 set screw: d, length

function claw_hub_r() = HUB_R;
function claw_blade_t() = BLADE_T;
function claw_blade_w() = BLADE_W;
function claw_screw() = SCREW;

// The centreline's arc radius, and the tip's centre with the shank upright: (-Rc (1 - cos A), Ls + Rc sin A).
function rc() = GRIP_R + BLADE_W / 2;
function tip0_x() = -rc() * (1 - cos(GRIP_ARC));
function claw_shank_l() = sqrt(TIP_L ^ 2 - tip0_x() ^ 2) - rc() * sin(GRIP_ARC);
// The lean, deg toward the roll axis, that puts the drive's tip round tangent to x = 0.
function claw_lean() = let(t = [tip0_x(), claw_shank_l() + rc() * sin(GRIP_ARC)])
    acos((BLADE_W / 2 - claw_pivot().x) / norm(t)) - atan2(t.y, t.x);
// The tip round's centre, in a finger's own (x, z), with the claw closed.
function claw_tip() = let(t = [tip0_x(), claw_shank_l() + rc() * sin(GRIP_ARC)], l = claw_lean())
    [t.x * cos(l) - t.y * sin(l), t.x * sin(l) + t.y * cos(l)];

// The blade upright: the shank from the pivot, the arc about (-Rc, Ls), the round at its end.
module blade_upright_2d() let(l = claw_shank_l(), r = rc(), w = BLADE_W / 2, n = 48) union() {
    translate([-w, 0]) square([BLADE_W, l]);
    translate([-r, l]) polygon(concat([for (i = [0 : n]) let(a = GRIP_ARC * i / n) (r + w) * [cos(a), sin(a)]],
                                      [for (i = [n : -1 : 0]) let(a = GRIP_ARC * i / n) (r - w) * [cos(a), sin(a)]]));
    translate([tip0_x(), l + r * sin(GRIP_ARC)]) circle(r = w);
}

// The drive finger's outline without its bore, in its own (x, z): the blade leaned, its root filleted
// onto the hub.
module claw_finger_solid_2d() offset(r = -ROOT_R) offset(r = ROOT_R) union() {
    rotate(claw_lean()) blade_upright_2d();
    circle(r = HUB_R);
}

// A finger's swept area over the travel, about the drive pivot, in the grip frame's (x, z): the body keeps
// FIT_RUN off it.
module claw_sweep_2d() let(p = claw_pivot())
    for (a = [0 : 1 : claw_open_max()]) translate(p) rotate(-a) claw_finger_solid_2d();


// --- Checks -----------------------------------------------------------------------------------------

// The tips' gap at an opening, deg: twice the drive's tip round's inner edge off x = 0.
function claw_tip_gap(open) = let(p = claw_pivot(), t = claw_tip())
    2 * (p.x + t.x * cos(open) + t.y * sin(open) - BLADE_W / 2);
// The pinion's journal's wall about its bolt's access bore.
function claw_pinion_wall(cfg) = (claw_journal_d(cfg) - fit_bore(5.5, fit_clearances(cfg)[0])) / 2;
// The finger's hub over the hex's vertex.
function claw_hub_wall(cfg) = HUB_R - (HEX_AF / 2 + fit_clearances(cfg)[0]) / cos(30);
// How far the hubs' bottom stands over the span XL-320's case top and pads (span_socket.scad's S3 step).
function claw_hub_over_servo() = claw_pivot().y - HUB_R - (span_axis().y + c102_case_dims()[0] + c102_pads()[0]);

assert(claw_sector_covers(), str("the sector's teeth ", claw_sector_arc(), " miss the follower's ", claw_follower_need()));
assert(GEAR_TURN % claw_sector_pitch() == 0 && GEAR_TURN % 60 == 0, "GEAR_TURN must keep the teeth and the hex");
assert(claw_pinion_wall("revised") >= 1.0, str("the pinion's journal wall is ", claw_pinion_wall("revised")));
assert(claw_hub_wall("revised") >= 1.0, str("the hub's wall is ", claw_hub_wall("revised")));
assert(claw_hub_over_servo() >= FIT_RUN, str("the hubs stand ", claw_hub_over_servo(), " over the servo"));
