// 930-ClawGripper — the claw's design parameters, and the outlines its parts share.
// The single owner of the claw's dimensions: its parts include this file, and its assemblies use it.
//
// THE CLAW. Two curved fingers turn about two pivots along the span axis's direction, set symmetrically
// about the roll axis above the span XL-320, so that their straight shanks lean outward and their tips meet
// on the roll axis. Each finger's hub is toothed where it meets the other's, so that the drive finger
// (#930-001) turns the follower finger (#930-007) 1:1, equal and opposite. The drive pivot's Claw Gear
// (#930-002) is a toothed sector in front of a hex seat, between two Ø8 journals, in one piece; the
// follower pivot's Claw Follower Axle (#930-006) is the same without the sector. The Claw Pinion
// (#930-004), one piece with the sleeve on the servo's spline, drives the sector at claw_ratio() : 1.
// Each axle runs in an MR128 in the Claw Body's rear wall (#930-003) and another in the Claw Cap
// (#930-005), the body's lid; the pinion runs on the servo's spline and in a third MR128
// in the cap. A finger's closed hub, a hex bore, slides over its axle's seat, and one set screw passes
// in from the hub's far side, through the seat, and on into the hub's other side.
//
// FRAME. The grip frame (../900-ToolInterface/span_socket.scad): the roll axis on +Z, every axis along +Y.
// A finger, a gear and the pinion are each drawn in their own frame, whose origin is on its axis, whose y
// is the grip frame's, and whose (x, z) is the grip frame's about that axis with the claw closed; the
// drive pivot is the one on +X. Their 2D sections are drawn in that (x, z) and stacked along y by AXIS_Y.
// Angles in (x, z) are polar, from +X toward +Z.
//
// THE MIRROR. The follower's finger is the drive's mirrored about x = 0, as its motion is, but for its
// hub's teeth: two gears mesh along the line between their pivots where a tooth of the drive at 180 + e
// meets a gap of the follower at -e, which is where the mirror image of the drive's tooth would stand. So
// the follower's teeth stand half a pitch off the drive's mirror image (claw_hub_tooth0()), and the two
// fingers are two parts. Its set screw's line is the drive's mirrored, so the follower's axle is the
// drive's gear without the sector, its cross hole mirrored.
//
// MOTION. OPEN, deg: the drive pivot turns +OPEN about +Y (polar -OPEN), the follower -OPEN and the
// pinion -claw_ratio() * OPEN; 0 is closed, the tips meeting on x = 0, and claw_open_max() is fully open.

include <../print_fit.scad>
use <../900-ToolInterface/span_socket.scad>
use <../c102_servo.scad>

// Sections in (x, z) stacked along y: sends 2D y to z and extrusion z to y.
AXIS_Y = [[1, 0, 0, 0], [0, 0, 1, 0], [0, 1, 0, 0], [0, 0, 0, 1]];

// --- Gears ------------------------------------------------------------------------------------------
// A module-1.25 pinion of 10 teeth, profile-shifted against undercut, on the span axis, driving a sector
// cut from a 34-tooth gear on the drive pivot; and the fingers' hubs, each toothed as a 16-tooth gear,
// meshing on the roll axis's plane. The gears' geometry is computed here by the standard involute
// relations, so that the assemblies can use this file without BOSL2, whose core overrides a `use` would
// carry; claw_gears.scad draws the teeth with BOSL2 and asserts that it agrees.

MOD        = 1.250;
PA         = 20;
PINION_N   = 10;
SECTOR_N   = 34;
HUB_N      = 16;
MARGIN     = 2;                                   // the sector's teeth past the travel, pitches
HUB_MARGIN = 1;                                   // the hubs' teeth past the travel, pitches

function claw_mod() = MOD;
function claw_pa() = PA;
function claw_pinion_n() = PINION_N;
function claw_sector_n() = SECTOR_N;
function claw_hub_n() = HUB_N;
function claw_ratio() = SECTOR_N / PINION_N;
function claw_open_max() = 25;                    // deg, at the fingers
// Each gear's teeth thinned so that a flank stands FIT_SLIP off its mate's, normal to it, at the pitch
// circle: half of each gear's circular backlash per flank, times cos of the pressure angle, twice.
function claw_gear_backlash(cfg) = fit_clearances(cfg)[0] / cos(PA);
// The pinion's profile shift: the least that clears undercut, 1 - z sin^2(a) / 2 (BOSL2's "auto").
function claw_pinion_shift() = 1 - PINION_N * sin(PA) ^ 2 / 2;
// The involute function, and its inverse by Newton's method, deg.
function inv(a) = tan(a) - a * PI / 180;
function inv_of(c, a = 20, i = 0) = i == 8 ? a : inv_of(c, a - (inv(a) - c) / tan(a) ^ 2 * 180 / PI, i + 1);
// The pinion's working centre distance to the sector: its shift opens the pressure angle at the mesh.
function claw_pinion_dist() = let(z = PINION_N + SECTOR_N,
                                  aw = inv_of(2 * tan(PA) * claw_pinion_shift() / z + inv(PA)))
    MOD * z / 2 * cos(PA) / cos(aw);
// The pinion's tips shortened by what the shift adds beyond the distance opened, so that they keep the
// root clearance in the sector.
function claw_pinion_shorten() = claw_pinion_shift() - (claw_pinion_dist() - MOD * (PINION_N + SECTOR_N) / 2) / MOD;

// The pivots: the hubs' centre distance apart about the roll axis, unshifted, the drive's at the pinion's
// centre distance from the span axis. The drive pivot is (x, z); the follower is at -x.
function claw_pinion_axis() = span_axis();
function claw_pivot() = let(s = span_axis(), p = MOD * HUB_N / 2, d = claw_pinion_dist())
    [p, s.y + sqrt(d ^ 2 - (p - s.x) ^ 2)];
// From the drive pivot toward the pinion, and back, polar deg.
function claw_pinion_dir() = let(d = span_axis() - claw_pivot()) atan2(d.y, d.x) + 360;
function claw_pivot_dir() = claw_pinion_dir() - 180;

function claw_sector_pitch() = 360 / SECTOR_N;
function claw_hub_pitch() = 360 / HUB_N;
// A run of teeth of pitch p, a tooth on t0, over [lo, hi] polar: each end moved out to a gap's middle.
function gap_arc(t0, p, lo, hi) = let(g = t0 + p / 2) [g + p * floor((lo - g) / p), g + p * ceil((hi - g) / p)];
// The sector's teeth, polar in its gear's own frame: a tooth on a quarter pitch, and what the sector meets
// the pinion through over the travel (the drive turns polar -OPEN, so its mesh point runs to +OPEN in its
// frame), MARGIN pitches past each end, so that the pinion cannot run off it.
function claw_sector_tooth0() = claw_sector_pitch() / 4;
function claw_sector_arc() = let(p = claw_sector_pitch(), d = claw_pinion_dir())
    gap_arc(claw_sector_tooth0(), p, d - MARGIN * p, d + claw_open_max() + MARGIN * p);
// The hubs' teeth, polar in each finger's own frame: s = 1 the drive's, -1 the follower's. The drive's,
// a tooth on a quarter pitch, meet the follower's at polar 180 + OPEN in its frame, HUB_MARGIN pitches
// past each end; the follower's are the drive's mirrored about x = 0 and moved half a pitch onto its own
// gaps (THE MIRROR).
function claw_hub_tooth0(s = 1) = let(t = claw_hub_pitch() / 4) s > 0 ? t : 180 - t + claw_hub_pitch() / 2;
function claw_hub_arc(s = 1) = let(p = claw_hub_pitch(), m = HUB_MARGIN * p)
    s > 0 ? gap_arc(claw_hub_tooth0(), p, 180 - m, 180 + claw_open_max() + m)
          : let(a = claw_hub_arc(1)) [180 - a[1] + p / 2, 180 - a[0] + p / 2];
// The pinion's teeth against the sector's: where the sector has a tooth at the pinion's line + e, the
// pinion has a gap at its own line - ratio * e.
function claw_pinion_tooth0() = let(e = claw_sector_tooth0() - claw_pinion_dir())
    claw_pivot_dir() - claw_ratio() * e + 180 / PINION_N;
// BOSL2 draws a tooth on +Y, which AXIS_Y sends to +Z (polar 90).
function claw_sector_spin() = claw_sector_tooth0() - 90;
function claw_hub_spin(s = 1) = claw_hub_tooth0(s) - 90;
function claw_pinion_spin() = claw_pinion_tooth0() - 90;

// Tip and root radii: the pitch radius, one module out, and 1.25 modules in (BOSL2's root clearance), the
// pinion's tips out by its shift less the shortening.
function claw_sector_tip_r() = MOD * (SECTOR_N / 2 + 1);
function claw_hub_tip_r() = MOD * (HUB_N / 2 + 1);
function claw_hub_root_r() = MOD * (HUB_N / 2 - 1.25);
function claw_pinion_tip_r() = MOD * (PINION_N / 2 + 1 + claw_pinion_shift() - claw_pinion_shorten());

// A wedge from the origin over the polar arc a, out to r: what a run of teeth is cut to.
module claw_wedge_2d(a, r) let(n = ceil((a[1] - a[0]) / 2))
    polygon(concat([[0, 0]], [for (i = [0 : n]) let(t = a[0] + (a[1] - a[0]) * i / n) r * [cos(t), sin(t)]]));

// --- Along y (the grip frame's) ---------------------------------------------------------------------
// The rear wall's MR128, the fingers over the seats, the sleeve's front wall round the Span Mount's column,
// the sector and the pinion's teeth in front of it, the seam between the body and the cap, and the cap's
// MR128s against it; each axle's collars bear on its MR128s' inner races. The fingers stand on the roll
// axis, so the sleeve's wall sets how far forward the sector does.

MR128      = [8.000, 12.000, 3.500];             // C-405: bore, OD, width
MR128_RING = [9.200, 10.800];                    // inner ring OD, outer ring ID: the race model
FINGER_T   = 10.000;                             // a finger's hub, along y
GEAR_T     = 8.000;                              // the teeth's face width
COLLAR_T   = 0.500;
KEEL_WALL  = 1.000;                              // the keel's wall in front of the column's socket

function y_span(y0, t) = [y0, y0 + t];
function claw_finger_y() = y_span(-FINGER_T / 2, FINGER_T);
// The keel's front face: the column's socket, its corner's round included, and the wall in front of it.
function claw_keel_front() = span_column_reach("revised") + KEEL_WALL;
function claw_teeth_y() = y_span(claw_keel_front() + FIT_RUN, GEAR_T);
function claw_seat_y() = [claw_finger_y()[0] - FIT_RUN, claw_teeth_y()[0]];
// Collar A behind the seat; collar B in front of the teeth, FIT_RUN between them and the cap.
function claw_collar_y(b = false) = b ? y_span(claw_teeth_y()[1], COLLAR_T) : y_span(claw_seat_y()[0] - COLLAR_T, COLLAR_T);
// The MR128s: the rear wall's behind collar A, the cap's in front of collar B.
function claw_rear_bearing_y() = y_span(claw_collar_y()[0] - MR128[2], MR128[2]);
function claw_front_bearing_y() = y_span(claw_collar_y(true)[1], MR128[2]);
function claw_journal_y(b = false) = b ? claw_front_bearing_y() : claw_rear_bearing_y();
// The two flat plates, the lid and the container's rear wall: each an MR128's width and a floor beyond it,
// a relief off the inner rings, and a cover over them. The cap's rear face is the seam.
CAP_FLOOR = 1.500;
COVER_T   = 1.000;
function claw_cap_y() = [claw_front_bearing_y()[0], claw_front_bearing_y()[1] + CAP_FLOOR];
function claw_cheek_y() = [claw_rear_bearing_y()[0] - CAP_FLOOR, claw_rear_bearing_y()[1]];
function claw_cover_t() = COVER_T;
// The blade's slot through the wall, y ±: FIT_RUN off the blade's faces.
function claw_slot_y() = BLADE_T / 2 + FIT_RUN;
// The Claw Finger Wall (#930-008), from the body's wall behind the blades to the seam, and the length of the
// lip on each of its ends: the rim's section, shallower than the rim, into a groove in a pillar's blend.
WALL_LIP = 1.500;
function claw_wall_y() = [-claw_slot_y(), claw_cap_y()[0]];
function claw_wall_lip_l() = WALL_LIP;

// A shoulder on a race: on the inner alone, halfway across its ring; on the outer alone, bored to the
// running clearance off the inner ring (700-Differential/diff_params.scad's rule, an MR128's ring being
// too narrow to bore it halfway).
function claw_collar_d() = (MR128[0] + MR128_RING[0]) / 2;
function claw_floor_bore() = MR128_RING[0] + 2 * FIT_RUN;
function claw_mr128() = MR128;
function claw_mr128_ring() = MR128_RING;
// An MR128's seat, pressed.
function claw_seat_d(cfg) = fit_bore(MR128[1], fit_clearances(cfg)[1]);
// The cap's four M3 x 10 bolts (C-609), (x, z) on the seam, each in a pillar. The fingers' torque about
// their axes reaches the housing as forces in the seam's plane on the three MR128s, so the bolts stand
// round those, wide apart and close to them: outboard of each pivot, beside the pinion, and beyond the
// column.
BOLT = [3.000, 5.500, 3.000, 10.000];            // C-609 ISO 4762: d, head d, head h, length
BOLT_SINK = 0.200;                               // the head under the cap's front face
PILLAR_R  = 2.500;                               // a bolt's pillar, round its tapped hole
function claw_cap_bolt() = BOLT;
function claw_cap_bolts() = [[21.7, 42], [-21.7, 42], [24, 23], [-9.5, 19]];
function claw_pillar_r() = PILLAR_R;
// Where a bolt's head seats in its recess, and where its end stands in the body.
function claw_bolt_seat_y() = claw_cap_y()[1] - BOLT[2] - BOLT_SINK;
function claw_bolt_end_y() = claw_bolt_seat_y() - BOLT[3];
function claw_bolt_recess_d() = fit_bore(BOLT[1], FIT_SLIP);
// The wall's rim, in a groove in the cap, each as a pair of faces at their distances in from the outline,
// along y from the seam: the cap's lip outside the groove, 1 thick at the mouth; the rim's two faces, each
// tapering `RIM[2]` over its length; and the groove's, FIT_SLIP off them.
RIM = [1.000, 2.500, 0.150];                     // the lip, the rim's length, each face's taper
function claw_rim_fit() = FIT_SLIP;
function claw_rim_l() = RIM[1];
function claw_rim_outer(t) = RIM[0] + claw_rim_fit() + RIM[2] * t;   // t 0 at the seam, 1 at the rim's end
function claw_rim_inner(t) = SHELL_WALL - RIM[2] * t;
function claw_groove_outer(t) = RIM[0] + RIM[2] * t;
function claw_groove_inner(t) = SHELL_WALL + claw_rim_fit() - RIM[2] * t;
// The Claw Body's floor, the Static Finger's, from which the Span Mount's socket is cut.
function claw_floor() = 10.000;
// The fillet on the housing's exposed edges, the wall all round its inside, and the fillet that blends a
// pillar into that wall.
function claw_edge_r() = 1.500;
SHELL_WALL = 2.500;
function claw_shell_wall() = SHELL_WALL;
function claw_blend_r() = 3.000;
// The housing's top: the wall over where the hubs' teeth reach, FIT_RUN off their swept tips, which stand
// higher than the hubs' rounds, to z 54.871 as measured from the teeth at full travel.
function claw_shell_top() = 54.900 + SHELL_WALL;
// How far the housing stands from a bolt: the head's recess, 1 of cap, and the groove outside that.
function claw_bolt_boss() = claw_bolt_recess_d() / 2 + 1.0 + claw_groove_inner(0);
// The pinion's tunnel through the body, about the span axis, and the room round its teeth: FIT_RUN off each.
function claw_shank_tunnel_r() = claw_shank_d() / 2 + FIT_RUN;
function claw_teeth_tunnel_r() = claw_pinion_tip_r() + FIT_RUN;

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
// ended in a full round. The shank's base stands inward of the pivot, toward the other finger, as far as
// the follower's teeth allow, its root's fillet ending where they end; so the shank is off the pivot's
// radial line, and the space between the closed fingers is a diamond. The shank's length keeps the
// pivot-to-tip length of the claw's first design, and its lean, outward, puts the closed tips' rounds
// touching on x = 0. The hub is round but for its teeth (claw_hub_arc()), and its set screw's line runs
// from under the blade, where its hole stops, to the hub's far side.

HUB_R    = 9.000;                                // the hub off its teeth
BLADE_T  = 7.000;                                // the blade, along y, about the mid-plane
BLADE_W  = 7.000;                                // the blade's width in its plane
GRIP_R   = 20.277;                               // the arc's grip face: 920-002's
GRIP_ARC = 66.400;                               // the arc's span: 920-002's
TIP_L    = 77.300;                               // pivot to the tip round's centre
ROOT_R   = 2.000;                                // the blade's fillet onto the hub
BLADE_F  = 1.000;                                // the fillet on the blade's edges, where it is handled
SCREW    = [3.000, 16.000];                    // M3 x 16 set screw (DIN 916): d, length, through
                                                 // the hub and the seat, in from the hub's far side
SCREW_A  = 120.000;                              // its line, polar in the drive finger's frame:
                                                 // through two of the hex's flats

function claw_hub_r() = HUB_R;
function claw_blade_t() = BLADE_T;
function claw_blade_w() = BLADE_W;
function claw_root_r() = ROOT_R;
function claw_blade_fillet() = BLADE_F;
function claw_screw() = SCREW;
function claw_screw_dir(s = 1) = s > 0 ? SCREW_A : 180 - SCREW_A;
// Where the set screw's hole stops under the blade, from the pivot: 0.5 past the screw's end, so that the
// wall it leaves to the shank's inner edge holds.
function claw_screw_stop() = SCREW[1] / 2 + 0.500;

// The centreline's arc radius, and the tip's centre with the shank upright, its centreline at x = e:
// (e - Rc (1 - cos A), Ls + Rc sin A).
function rc() = GRIP_R + BLADE_W / 2;
function tip0_x(e = claw_base()) = e - rc() * (1 - cos(GRIP_ARC));
function claw_shank_l(e = claw_base()) = sqrt(TIP_L ^ 2 - tip0_x(e) ^ 2) - rc() * sin(GRIP_ARC);
function tip0(e = claw_base()) = [tip0_x(e), claw_shank_l(e) + rc() * sin(GRIP_ARC)];
// The lean, deg toward the roll axis (negative: outward), that puts the drive's tip round tangent to x = 0.
function claw_lean_at(e) = let(t = tip0(e)) acos((BLADE_W / 2 - claw_pivot().x) / norm(t)) - atan2(t.y, t.x);
// Where the follower's teeth end, polar in the drive's frame: the blade's root's fillet ends on the hub here.
function claw_root_dir() = 180 - claw_hub_arc(-1)[1];
// The shank's centreline off the pivot, negative: inward, so that the fillet, tangent to the hub at
// claw_root_dir(), is tangent to the shank's inner edge. The lean depends on it, so it is iterated.
function claw_base(i = 0, e = 0) = let(l = claw_lean_at(e), a = claw_root_dir())
    i == 6 ? e : claw_base(i + 1, (HUB_R + ROOT_R) * cos(a - l) + BLADE_W / 2 + ROOT_R);
function claw_lean() = claw_lean_at(claw_base());
// The tip round's centre, in the drive finger's own (x, z), with the claw closed.
function claw_tip() = let(t = tip0(), l = claw_lean())
    [t.x * cos(l) - t.y * sin(l), t.x * sin(l) + t.y * cos(l)];

// The blade upright, as a path: up the shank's +X side from the pivot's height, round the arc about
// (e - Rc, Ls) on its outer edge, over the tip's round, back along the arc's inner edge, and down the
// shank's -X side.
function blade_upright_path(n = 48) = let(e = claw_base(), l = claw_shank_l(), r = rc(), w = BLADE_W / 2, c = [e - r, l],
                                          t = c + r * [cos(GRIP_ARC), sin(GRIP_ARC)])
    concat([[e + w, 0]],
           [for (i = [0 : n]) let(a = GRIP_ARC * i / n) c + (r + w) * [cos(a), sin(a)]],
           [for (i = [1 : n / 2 - 1]) let(a = GRIP_ARC + 360 * i / n) t + w * [cos(a), sin(a)]],
           [for (i = [n : -1 : 0]) let(a = GRIP_ARC * i / n) c + (r - w) * [cos(a), sin(a)]],
           [[e - w, 0]]);


// --- Checks -----------------------------------------------------------------------------------------

// The tips' gap at an opening, deg: twice the drive's tip round's inner edge off x = 0.
function claw_tip_gap(open) = let(p = claw_pivot(), t = claw_tip())
    2 * (p.x + t.x * cos(open) + t.y * sin(open) - BLADE_W / 2);
// The pinion's journal's wall about its bolt's access bore.
function claw_pinion_wall(cfg) = (claw_journal_d(cfg) - fit_bore(5.5, fit_clearances(cfg)[0])) / 2;
// The finger's hub, at its teeth's root, over the hex's vertex.
function claw_hub_wall(cfg) = claw_hub_root_r() - (HEX_AF / 2 + fit_clearances(cfg)[0]) / cos(30);
// How far the hubs' teeth stand over the span XL-320's case top and pads (span_socket.scad's S3 step).
function claw_hub_over_servo() = claw_pivot().y - claw_hub_tip_r() - (span_axis().y + c102_case_dims()[0] + c102_pads()[0]);
// The set screw's hole, the seat's cross hole at its widest, off the drive hub's teeth, deg at the hub's
// face: the least of the two ends' margins.
function claw_screw_off_teeth() = let(a = claw_hub_arc(), h = asin(fit_bore(SCREW[0], FIT_SLIP) / 2 / HUB_R))
    min(a[0] - (SCREW_A + h), SCREW_A + 180 - h - a[1]);

// The wall from the set screw's hole's stop, at its corner on the teeth's side, to the shank's inner edge.
function claw_screw_wall() = let(a = SCREW_A, l = claw_lean(), c = claw_screw_stop() * [cos(a), sin(a)] - fit_pin(SCREW[0], FIT_TAP) / 2 * [sin(a), -cos(a)])
    c.x * cos(l) + c.y * sin(l) - (claw_base() - BLADE_W / 2);

// How far each pillar stands off what turns past it: the upper +X one off the sector's end, past which
// it stands, and off the hub's room; the lower +X one off the teeth's room and the sector's tips.
function claw_pillar_sector_end() = let(d = claw_cap_bolts()[0] - claw_pivot(), a = atan2(d.y, d.x) + 360 - claw_sector_arc()[1])
    norm(d) * sin(a) - FIT_RUN - PILLAR_R;
function claw_pillar_hub() = norm(claw_cap_bolts()[0] - claw_pivot()) - claw_hub_r() - FIT_RUN - PILLAR_R;
function claw_pillar_teeth() = norm(claw_cap_bolts()[2] - span_axis()) - PILLAR_R - claw_teeth_tunnel_r();
function claw_pillar_tips() = norm(claw_cap_bolts()[2] - claw_pivot()) - PILLAR_R - claw_sector_tip_r() - FIT_RUN;
// The pillar's wall round a tapped hole, and the rim's width at its end.
function claw_pillar_wall() = PILLAR_R - fit_pin(BOLT[0], FIT_TAP) / 2;
function claw_rim_tip() = claw_rim_inner(1) - claw_rim_outer(1);

assert(claw_keel_front() >= claw_finger_y()[1], "the sleeve's front stands behind the fingers' front");
assert(claw_pillar_sector_end() >= 0, str("the upper pillar stands ", claw_pillar_sector_end(), " off the sector's end"));
assert(claw_pillar_hub() >= 0, str("the upper pillar stands ", claw_pillar_hub(), " off the hub's room"));
assert(claw_pillar_teeth() >= 0, str("the lower pillar stands ", claw_pillar_teeth(), " off the teeth's room"));
assert(claw_pillar_tips() >= 0, str("the lower pillar stands ", claw_pillar_tips(), " off the sector's tips"));
assert(claw_pillar_wall() >= 1.0, str("the pillar's wall round its thread is ", claw_pillar_wall()));
assert(claw_rim_tip() >= 1.0, str("the rim's end is ", claw_rim_tip(), " wide"));
assert(claw_bolt_end_y() - 1 >= claw_keel_front() - 1, "the cap's bolts' holes reach the sleeve");
assert(2 * claw_hub_r() - claw_screw()[1] >= 1.0, "the set screw stands proud of the hub");
assert(claw_screw_off_teeth() >= 0, str("the set screw's hole reaches ", -claw_screw_off_teeth(), " deg into the hub's teeth"));
assert(claw_screw_wall() >= 1.0, str("the set screw's hole stops ", claw_screw_wall(), " off the shank's inner edge"));
assert(claw_pinion_wall("revised") >= 1.0, str("the pinion's journal wall is ", claw_pinion_wall("revised")));
assert(claw_hub_wall("revised") >= 1.0, str("the hub's wall is ", claw_hub_wall("revised")));
assert(claw_hub_over_servo() >= FIT_RUN, str("the hubs stand ", claw_hub_over_servo(), " over the servo"));
