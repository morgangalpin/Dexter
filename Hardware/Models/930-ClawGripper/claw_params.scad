// 930-ClawGripper — the claw's design parameters, and the outlines its parts share.
// The single owner of the claw's dimensions: its parts include this file, and its assemblies use it.
//
// THE CLAW. Two curved fingers (#930-001) turn about two pivots along the span axis's direction, one on
// the span axis and one its mirror across the roll axis, so that their tips meet on the roll axis. Each
// pivot carries a Claw Gear (#930-002); the two gears mesh 1:1, so the fingers turn equal and opposite.
// The span XL-320 drives through the Span Driver's head, which stands in the drive finger's socket; on
// both pivots the gear's nose, of the head's outline, stands in the same socket from the other side. Each
// gear turns on a Ø8 journal in two MR128s in the Claw Body (#930-003): the Pinion Bearing EXT (#920-006)
// in the 2-finger claw, the Claw Axle (#930-004) in the 4-finger claw, whose nose carries a second finger
// beyond the bearings.
//
// FRAME. The grip frame (../900-ToolInterface/span_socket.scad): the roll axis on +Z, the pivots along +Y
// through (±claw_pivot().x, claw_pivot().y). A finger, a gear and an axle are each drawn in their own
// frame, whose origin is on the pivot's axis and whose (x, z) is the grip frame's with the claw closed; the
// drive pivot is the one on +X. Their 2D sections are drawn in that (x, z) and stacked along y by AXIS_Y.
//
// THE FLIP. One finger serves both pivots: it is symmetric about its own mid-plane, so the follower's is
// the drive finger turned 180 deg about Z. One gear serves both, drawn the same way up: a tooth stands a
// quarter of a pitch off the finger's line (claw_gear_spin()), which is what lets two identical gears mesh
// with the fingers mirror images of each other (for a pitch p, a tooth at angle t needs a gap at 180 - t
// on the other gear; with both gears' teeth at t0 + k p, 2 t0 = p / 2 mod p).
//
// MOTION. OPEN, deg: the drive pivot turns +OPEN about +Y, the follower -OPEN; 0 is closed, the tips'
// faces meeting on x = 0, and claw_open_max() is fully open.

include <../print_fit.scad>
use <../900-ToolInterface/span_socket.scad>
use <../900-ToolInterface/912-002_SpanDriver.scad>

// Sections in (x, z) stacked along y: sends 2D y to z and extrusion z to y.
AXIS_Y = [[1, 0, 0, 0], [0, 0, 1, 0], [0, 1, 0, 0], [0, 0, 0, 1]];

// --- Pivots and travel ------------------------------------------------------------------------------

function claw_pivot() = span_axis();             // the drive pivot (x, z); the follower is at -x
function claw_open_max() = 25;                   // deg

// --- Along y (the grip frame's) ---------------------------------------------------------------------
// The Span Driver's head, then the inner finger in front of V1, the gear's boss through the body's front
// wall, its teeth in the pocket, then the journal's two MR128s in the bearing plate, and the 4-finger's
// outer finger beyond the journal's collar.

FINGER_T = 10.000;                               // a finger's hub, along y
GEAR_T   = 6.000;                                // the teeth's face width
EXT_LEN  = [7.500, 8.500];                       // #920-006: J1's end, C1's end, from its shoulder

function y_span(y0, t) = [y0, y0 + t];
function claw_head_y() = let(h = head_y_span()) y_span(span_driver_y() + h[0], h[1] - h[0]);   // [-3.493, 1.507]
function claw_finger_y() = y_span(span_plate_face() + FIT_RUN, FINGER_T);   // the inner finger, [-3.243, 6.757]
function claw_nose_y() = [claw_head_y()[1] + 0.250, claw_finger_y()[1]];   // the gear's nose
function claw_teeth_y() = y_span(11.500, GEAR_T);                           // see claw_disc_margin()
function claw_front_wall_y() = [claw_finger_y()[1] + FIT_RUN, claw_teeth_y()[0] - FIT_RUN];
function claw_journal_y() = claw_teeth_y()[1] + FIT_RUN;                   // #920-006's y 0: its shoulder,
                                                                           // the inner MR128's face
function claw_seats_y() = let(j = claw_journal_y()) [[j, j + 3.5], [j + 4.0, j + 7.5]];   // MR128 8x12x3.5
function claw_plate_y() = [claw_journal_y(), claw_seats_y()[1][1]];        // the body's bearing plate
function claw_outer_finger_y() = y_span(claw_journal_y() + EXT_LEN[1], FINGER_T);   // 4-finger only
function claw_finger_mid(outer = false) = let(f = outer ? claw_outer_finger_y() : claw_finger_y()) (f[0] + f[1]) / 2;

// --- Gear -------------------------------------------------------------------------------------------

function claw_gear_teeth() = 20;
function claw_gear_mod() = 2 * claw_pivot().x / claw_gear_teeth();   // the pivots' spacing, 1:1
function claw_gear_pa() = 20;
function claw_gear_pitch() = 360 / claw_gear_teeth();                  // deg
function claw_gear_spin() = -claw_gear_pitch() / 4;                    // off a tooth on +Z (BOSL2's +Y)
function claw_gear_tip_r() = claw_gear_mod() * (claw_gear_teeth() / 2 + 1);
// Each gear's teeth thinned so that a flank stands FIT_SLIP off its mate's, normal to it, at the pitch
// circle: half of each gear's circular backlash per flank, times cos of the pressure angle, twice.
function claw_gear_backlash(cfg) = fit_clearances(cfg)[0] / cos(claw_gear_pa());
function claw_boss_d() = 12.000;                                       // through the front wall

// --- Finger -----------------------------------------------------------------------------------------
// The grip: a circle on the roll axis that the closed fingers' inner faces follow over its top, and below
// it a straight face, tangent to it, down to the hub's inner edge. The tips' faces meet on x = 0.

HUB_R   = 7.000;                                 // round the socket: 1.35 over the head's arc
BLADE_T = 6.000;                                 // the blade, along y, about the mid-plane
BLADE_W = 9.000;                                 // the blade's width, normal to the grip's faces
TIP_Z   = 93.500;                                // the tips' top, the Static Finger's finger's
GRIP_R  = 16.000;                                // the grip circle's radius
EDGE_R  = 1.000;                                 // the blade's convex edges' round
ROOT_R  = 2.000;                                 // the blade's fillet onto the hub
SCREW   = [3.000, 2.500];                        // C-606 M3 set screw: d, off the mid-plane

function claw_hub_r() = HUB_R;
function claw_blade_t() = BLADE_T;
function claw_grip() = [[0, TIP_Z - BLADE_W - GRIP_R], GRIP_R];        // centre (x, z), radius
function claw_tip_z() = TIP_Z;
function claw_screw() = SCREW;
// The set screws' holes, y off a finger's mid-plane: the drive finger's is +, the follower's (turned)
// the other, so that both are reached from outside the claw and stand in the gear's nose.
function claw_screw_y() = claw_finger_mid() + SCREW[1];

// The space between the closed fingers, in the grip frame's (x, z).
module claw_grip_2d() let(g = claw_grip(), p = claw_pivot(), r = p.x - HUB_R) hull() {
    translate(g[0]) circle(r = g[1]);
    for (s = [-1, 1]) translate([s * r, p.y]) square(0.001, center = true);
}

// The drive finger's outline without its socket, in its own (x, z): the blade's convex edges rounded,
// then its root filleted onto the hub.
module claw_finger_solid_2d() let(p = claw_pivot()) translate(-p)
    offset(r = -ROOT_R) offset(r = ROOT_R) union() {
        offset(r = EDGE_R) offset(delta = -EDGE_R) difference() {
            intersection() {
                offset(r = BLADE_W) claw_grip_2d();
                translate([0, p.y]) square([2 * p.x, TIP_Z]);
            }
            claw_grip_2d();
        }
        translate(p) circle(r = HUB_R);
    }

// The socket: the Span Driver's head (#912-002 D1) grown by FIT_SLIP, open downward through the hub so
// that the finger drops onto the head and the gear's nose.
module claw_socket_2d(cfg) let(c = fit_clearances(cfg)[0], w = 3.500 + c) union() {
    offset(delta = c) head_2d();
    translate([-w, -HUB_R - 1]) square([2 * w, HUB_R + 1]);
}

// The gear's nose: the head's outline as drawn.
module claw_nose_2d() head_2d();

// A finger's swept area over the travel, about the drive pivot, in the grip frame's (x, z): the body keeps
// FIT_RUN off it.
module claw_sweep_2d() let(p = claw_pivot())
    for (a = [0 : 1 : claw_open_max()]) translate(p) rotate(-a) claw_finger_solid_2d();

// --- Checks -----------------------------------------------------------------------------------------

// How far the drive gear's tip circle, on the teeth's -Y face, stands from the Span Mount's base-plate
// circle's top edge, the nearest over x (the follower's is its mirror): at each x, the rim's height
// over the plate's top and the face's distance past the edge, combined.
function claw_disc_margin() = let(d = span_base_disc(), p = claw_pivot(), y0 = claw_teeth_y()[0],
                                  t = claw_gear_tip_r())
    min([for (x = [p.x - t + 0.05 : 0.05 : d[0]]) let(
        z = p.y - sqrt(t ^ 2 - (p.x - x) ^ 2), ye = sqrt(d[0] ^ 2 - x ^ 2),
        dy = y0 - ye, dz = z - d[1])
        dy <= 0 && dz <= 0 ? -1 : norm([max(0, dy), max(0, dz)])]);
// The body's wall about the column, between S1 and the fingers' hubs' running clearance.
function claw_column_wall(cfg) = claw_pivot().x - HUB_R - FIT_RUN - span_column_reach(cfg);
// The tips' gap at an opening, deg.
function claw_tip_gap(open) = let(p = claw_pivot(), t = [0, TIP_Z] - p)
    2 * (p.x + t.x * cos(open) + t.y * sin(open));

assert(claw_disc_margin() >= FIT_RUN, str("the gears stand ", claw_disc_margin(), " over the base plate"));
assert(claw_column_wall("revised") >= 1.0, str("the column's wall is ", claw_column_wall("revised")));
assert(claw_nose_y()[0] > claw_head_y()[1], "the gear's nose overlaps the Span Driver's head");
