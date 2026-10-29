// The gripper's socket on the Span Mount — shared cutters.
// Every gripper base is pushed down onto the Span Mount's strake column and strake, and over its upright
// plate and the span XL-320 (specs/008.11 step 46). This file owns that interface: the cutters a base
// subtracts so that it seats there, and the span axis it then turns about. The Static Finger
// (../920-ParallelGripper/920-001_StaticFinger.scad) and the Claw Body
// (../930-ClawGripper/930-003_ClawBody.scad) use it.
//
// FRAME. The grip frame, which is the Static Finger's: the roll axis on +Z through the origin, the span
// axis along +Y through span_axis(). The Span Mount (912-001_SpanMount.scad) stands in it turned -90 deg
// about Z and 1.5 lower (x = y_sm, y = -x_sm, z = z_sm + 1.5); tool_assembly.scad's grip_frame() places
// it.
//
//     ID  cutter          value
//     S1  column socket   the Span Mount's column C1 and web W1, turned -90 deg about Z, the web run on
//                         out into S3; from below the base's floor up to the column's top, z 24.2; the
//                         entry chamfered 0.3 at 45 deg
//     S2  strake slot     the section span_strake_w(); each base draws its own slot of that section
//     S3  plate slot      y < -3.743 (V1's +X face) below z 28, a tongue left in V1's notch, and y < -10.243
//                         below z 29.5, the two ceilings joined at 45 deg back from the +X end x 23.139
//
// FITS (revised). S1 slides over the column, a printed part: grown by FIT_SLIP. S2 takes the strake's top
// (C-502, 2.337 x 5.588), bonded: fit_bore at FIT_PRESS. S3 slides over the upright plate: its +Y face and
// +X end open by FIT_SLIP, so the plate's faces and its eye lobe clear the base. Beyond the plate, S3's
// ceiling and its outer step stand over the span XL-320, a bought part: they follow ../c102_servo.scad's
// case and pads, at FIT_PRESS. "previous" draws the Static Finger's reference.

include <../print_fit.scad>
use <../c102_servo.scad>

BIG = 100;
LAP = 0.005;

// The span axis (x, z), along +Y: the span XL-320's, and the Span Mount's eye E1.
function span_axis() = [14.139, 17.500];
// The column's top (S1's ceiling).
function span_column_top() = SOCKET[0];
// V1's +X face, the plane in front of which a base's parts may turn.
function span_plate_face() = PLATE_SLOT[0];
// #912-002's y 0 along the span axis: the Span Driver as steps 36-37 set it on the spline.
function span_driver_y() = -11.493;
// The Span Mount's base plate F1 under a base: its circle's radius about the roll axis, and its top z.
function span_base_disc() = [11.500, 5.500];
// The strake's top (C-502 bonded in the column, tool_assembly.scad's STRAKE), level with V1's notch's top.
function span_strake_top() = TONGUE[3];
// How far the column socket S1 reaches from the roll axis along ±X, its corners' round included.
function span_column_reach(cfg) = COLUMN[0] - COLUMN[1] * (sqrt(2) - 1) + fit_clearances(cfg)[0];

module along_y(y0, y1) translate([0, y1, 0]) rotate([90, 0, 0]) linear_extrude(y1 - y0) children();

// --- S1 -----------------------------------------------------------------------------------------

COLUMN    = [5.833, 1.000];        // |x| + |y| bound, corner radius
WEB       = [0.470, 0.500];        // faces y = ±(x + 0.47) in the Span Mount's frame, fillet radius
SOCKET    = [24.200, 0.300];       // ceiling z, entry chamfer

module column_sm_2d() let(a = (COLUMN[0] - WEB[0]) / 2) union() {
    hull() for (k = [0 : 3]) rotate(90 * k) translate([COLUMN[0] - COLUMN[1] * sqrt(2), 0]) circle(r = COLUMN[1], $fn = 72);
    polygon([[a, a + WEB[0]], [6, 6 + WEB[0]], [6, -6 - WEB[0]], [a, -a - WEB[0]]]);
}

module span_socket_2d(grow) rotate(-90) offset(delta = grow) union() {
    column_sm_2d();
    let(a = (COLUMN[0] - WEB[0]) / 2) intersection() {
        offset(r = -WEB[1]) offset(r = WEB[1]) column_sm_2d();
        for (s = [-1, 1]) translate([a - 0.8, s * (a + WEB[0]) - 0.8]) square(1.6);
    }
}

// S1, from 1 below the base's floor z to the column's top.
module span_column_socket(cfg, floor) let(g = fit_clearances(cfg)[0], n = 6) {
    translate([0, 0, floor - 1]) linear_extrude(SOCKET[0] - floor + 1) span_socket_2d(g);
    for (i = [0 : n - 1]) let(h = SOCKET[1] / n)
        translate([0, 0, floor - (i == 0 ? 1 : 0) + i * h]) linear_extrude(h + (i == 0 ? 1 : 0) + LAP)
            offset(r = SOCKET[1] - (i + 0.5) * h) span_socket_2d(g);
}

// --- S2 -----------------------------------------------------------------------------------------

STRAKE_SLOT = [5.500, 2.400];      // x, y: the reference's
STRAKE      = [5.588, 2.337];      // C-502, .220" x .092", along x and y here

// S2's section [x, y] for a config, and the reference's.
function span_strake_w(cfg) = let(c = fit_clearances(cfg)[1])
    cfg == "previous" ? STRAKE_SLOT : [fit_bore(STRAKE.x, c), fit_bore(STRAKE.y, c)];
function span_strake_ref_w() = STRAKE_SLOT;

// --- S3 -----------------------------------------------------------------------------------------

PLATE_SLOT = [-3.743, 28.000, 23.139];           // +Y face, ceiling, +X end
PLATE_STEP = [-10.243, 29.500];                  // the outer step: +Y face, ceiling
TONGUE     = [-7.243, 24.200, 5.000, 27.700, 5.617];   // -Y face, bottom, half-width there, top of its taper, half-width

// Beyond V1 the slot's ceiling and its outer step stand over the span XL-320, whose axis is the span
// axis and whose front face is V1's +X face (TONGUE's -Y face): the ceiling over its +X side, the step
// over its pads from their front edge. Its servo-frame (x, y, z) is this frame's (z - the axis's z,
// x - the axis's x, y - TONGUE's -Y face).
// The slot for a config: revised opens its +Y face and +X end by the slip clearance, and stands its
// ceiling off the servo's side by the press fit.
function span_plate_slot_at(cfg) = let(c = fit_clearances(cfg))
    [PLATE_SLOT[0] + c[0], cfg == "revised" ? span_axis().y + c102_case_dims()[0] + c[1] : PLATE_SLOT[1],
     PLATE_SLOT[2] + c[0]];

// The outer step for a config: +Y face, ceiling, +X end, which meets the slot's ceiling at 45 deg;
// revised stands it off the pads by the press fit.
function span_plate_step_at(cfg) = let(p = span_plate_slot_at(cfg), c = fit_clearances(cfg)[1], s = c102_pads(),
                                       z = cfg == "revised" ? span_axis().y + c102_case_dims()[0] + s[0] + c : PLATE_STEP[1])
    [cfg == "revised" ? TONGUE[0] + s[2][0][1] + c : PLATE_STEP[0], z, p[2] - (z - p[1])];

// S3, from 1 below the base's floor z.
module span_plate_slot(cfg, floor) let(p = span_plate_slot_at(cfg), q = span_plate_step_at(cfg)) difference() {
    union() {
        along_y(-BIG, p[0]) polygon([[-BIG, floor - 1], [p[2], floor - 1], [p[2], p[1]], [-BIG, p[1]]]);
        along_y(-BIG, q[0]) polygon([[-BIG, floor - 1], [p[2], floor - 1],
            [p[2], p[1]], [q[2], q[1]], [-BIG, q[1]]]);
    }
    along_y(TONGUE[0], p[0] + 1) polygon([[-TONGUE[2], TONGUE[1]], [TONGUE[2], TONGUE[1]],
        [TONGUE[4], TONGUE[3]], [TONGUE[4], BIG], [-TONGUE[4], BIG], [-TONGUE[4], TONGUE[3]]]);
}
