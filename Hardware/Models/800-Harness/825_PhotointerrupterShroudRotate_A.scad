// #825 Photointerrupter Shroud (Rotate), body (A) — parametric source.
// Holds the lower T-1 package of each of J5's two beams, under the code disk
// (#710-004, 100 slots), and clips onto Diff Body B's Ø31 shell (#730-002, its
// r 15.5 about the J4 pivot axis, with the 12.46 flats at the tips of the
// clip) to read the disk from there. Its tab stands below the 2 mm gap the
// disk runs in (z -8.5 to -6.5); #825 B (825_PhotointerrupterShroudRotate_B.scad)
// sits above the gap on the wall's top, pinned to it by #19 nails.
//
//   config = "previous" — faithful recreation of the reference mesh
//                         (../Reference/meshes/800-Harness/).
//   config = "revised"  — the print fits below drawn.
//
// FRAME. The reference's own: the disk turns about the z axis through the
// origin; the clip's axis is parallel to x, through (y, z) = (0, -40.05); the
// part's top face (the wall) is z -6.5.
//
// Measured from the reference (scadmesh planes/slice/arcs/solid; the arcs
// tool merges short straight runs into false arcs, so the 2D outlines below
// are read from the section points). Feature IDs are those of
// 825_PhotointerrupterShroudRotate_A.view.json:
//
//     ID  feature        value                                          span
//     W1  wall           x -7.7 .. 7.511, y -30.191 back face, to the
//                        disk side face: the cylinder r 27.05 about
//                        the z axis, ending in a concave R2 fillet onto
//                        the ledge z -27.343                       z -27.343 .. -6.5
//     T1  tab            the plan of ../photo_shroud_rotate.scad
//                        (wedge +-20 deg, arc r 20.5)              z -14.5 .. -8.5
//     B1  beam bore, at (-3.296, -23.013), B2 at (3.059, -23.048), each:
//                        Ø3.0 round, for the T-1 body              z -13.5 .. -8.5
//                        Ø4.0 round counterbore, for its flange    z -14.5 .. -13.5
//     N1  nail holes     Ø1.0 at (-2.095, -28.62), (1.905, -28.62) z -24 .. -6.5
//     N2  neck           the back face turns under W1 in three
//                        rounds (R5.04, R6.24, R6.5) to the flat
//                        underside z -34.345, and a concave R5.02
//                        runs it into the clip's outer face
//     C1  hoops          two C-sections, x -7.7 .. -4.096 and 3.905 .. 7.511:
//                        bore r 15.5 and outer r 18.5, both about
//                        (0, -40.05); the tips end on the flats y = +-12.46,
//                        the +y tip's top rising 15.4 deg to the outer face,
//                        the -y tip's top likewise, floor z -31.343
//                        beside it, a concave R2.05 onto a 45 deg ramp
//                        and a convex R2.71 onto the ledge z -27.343
//     C2  chamfer        1.5 x 1.5 on the hoops' outer end edges: the
//                        outline of the wall's back face, neck and clip's
//                        outer face (not the bore, the tips or the
//                        wall's disk-side face) offset inward
//                        by up to 1.5 over x -7.7 .. -6.2, and 6.011 .. 7.511
//     C3  bars           between the hoops (x -4.096 .. 3.905), the clip
//                        is cut away from 30 deg above +y round the bottom to
//                        the horizontal on -y, leaving two bars 4.0 wide along
//                        the rays at -45 and -135 deg
//
// The C1 hoops are Diff Body B's grip; each 12.46 flat is the width of that
// body's chimney base (730-002 FLAT_Y), so the clip's tips straddle it.
//
// CONSTRUCTION. Profile per layer along x. The three layers are each one 2D
// section in (y, z): hoop (C1 with W1, N2), the middle (the hoop less C3's
// cut-away), and the hoop again. Their union is intersected with the chamfered
// envelope (C2): the hoop's outer outline, with the bore and tips filled in,
// swept by BOSL2 offset_sweep with a 1.5 chamfer over each end, and plain
// between. The wall's disk-side face is a surface of revolution about the z
// axis (the tab's arc is the same axis), so it is cut after the layers by one
// revolved cutter (W1's r 27.05 face, its R2 fillet and the ledge below it),
// then the tab is added and the bores and nail holes cut. `layer` draws one
// 2D section of the part: hoop (cut at x -5.5), mid (x 0) or plan (z -12).
//
// FITS (../print_fit.scad), revised only, per side:
//
//     C1 bore, r 15.5, Diff Body B's printed shell        slip (r 15.65)
//     B1, B2 Ø3.0 run, the T-1 body (a bought Ø3.0)       press (Ø3.1)
//
// The Ø4.0 counterbore already clears the T-1's flange by more than the press
// fit; both keep their size. N1's Ø1.0 is the intended drive fit of a #19 nail
// (Ø1.07) and keeps its size. probes-825-A-wide holds the counterbore and the
// nail hole open, and fits-825-A the clip's bore.

include <BOSL2/std.scad>
include <BOSL2/rounding.scad>
include <../print_fit.scad>
include <photo_shroud_rotate.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// 2D layer to draw alone, for outline checks; "part" draws the part
layer = "part"; // [part, hoop, mid, plan]

/* [Hidden] */
HOOP_AT = -5.500;                     // layer "hoop": the part cut at this x
MID_AT  = 0.000;                      // layer "mid": cut at this x
PLAN_AT = -12.000;                    // layer "plan": cut at this z
$fn = 96;
LAP     = 0.005;
X_END   = [-7.700, 7.511];
X_HOOP  = [-4.096, 3.905];            // the middle layer's span
CH      = 1.5;                        // C2, the chamfer's width and length
TOP_Z   = -6.500;                     // W1's top face
CTR     = [0.0, -40.050];             // C1's axis, in (y, z)
R_BORE  = 15.500;
R_OUT   = 18.500;
TIP_Y   = 12.460;                     // the tips' flats, at +-
TIP_LOW = 12.581;                     // the -y tip's flat leans out to this at the bore
TIP_TOP = -28.540;                  // where the flat meets the rising top
RAMP_Z  = -31.343;                    // N2's floor beside the -y tip
LEDGE_Z = -27.343;
WALL_R  = 27.050;                     // W1's face, about the z axis
FILLET  = 2.0;                        // W1's concave R2 fillet onto the ledge
BARS    = [-45, -135];                // C3, the rays the bars lie on
BAR_W   = 4.0;
CUT_TO  = 30;                         // C3's cut-away runs from -180 up to this
BODY_D  = T1_BODY_D;                  // B1, B2: the T-1 body (photo_shroud.scad)
FLANGE_D = 4.000;                     // counterbore
TAB_Z   = [-14.500, -8.500];          // T1
CBORE_Z = -13.500;
NAIL_Z  = [-24.000, TOP_Z];

function press(cfg) = fit_clearances(cfg)[1];
function slip(cfg) = fit_clearances(cfg)[0];
function r_bore(cfg) = R_BORE + slip(cfg);

// --- 2D outline helpers (u = y, v = z) --------------------------------------
function p_ang(c, p) = atan2(p.y - c.y, p.x - c.x);

// The points of an arc about c from p0 to p1, p0 excluded, clockwise when cw.
function p_arc(c, p0, p1, cw = false, step = 3) =
    let(a0 = p_ang(c, p0), a1 = p_ang(c, p1),
        d = cw ? -((a0 - a1 + 720) % 360) : ((a1 - a0 + 720) % 360),
        n = max(1, ceil(abs(d) / step)), r0 = norm(p0 - c), r1 = norm(p1 - c))
    [for (i = [1 : n]) let(a = a0 + d * i / n, r = r0 + (r1 - r0) * i / n)
        c + r * [cos(a), sin(a)]];

// A point on the clip's outer face (or bore) at polar angle a.
function on_clip(r, a) = CTR + r * [cos(a), sin(a)];

// N2: the back face, down the wall and round its neck, to the clip's outer
// face at the horizontal on -y.
NECK = [[-30.191, -28.272], [-28.551, -31.983], [-25.414, -34.173],
        [-23.429, -34.345], [-18.500, -40.050]];
NECK_C = [[-25.147, -28.254], [-23.531, -28.238], [-23.893, -27.841],
          [-23.503, -39.360]];

function wall_back() = concat(
    [[-30.191, TOP_Z], NECK[0]],
    p_arc(NECK_C[0], NECK[0], NECK[1]),
    p_arc(NECK_C[1], NECK[1], NECK[2]),
    p_arc(NECK_C[2], NECK[2], NECK[3]),
    p_arc(NECK_C[3], NECK[3], NECK[4], cw = true));

// The hoop's section: the wall's back face, the neck, the clip's outer face
// round the bottom to the +y tip, the bore back to the -y tip, the floor and
// ramp beside it, and the wall's inner face (cut to W1's face afterwards).
function hoop_path(cfg) = let(
        rb = r_bore(cfg), zt = CTR.y + sqrt(rb * rb - TIP_Y * TIP_Y),
        zl = CTR.y + sqrt(rb * rb - TIP_LOW * TIP_LOW),
        out_l2 = [-16.323, RAMP_Z], fl = [-18.411, RAMP_Z],
        ramp_c = [-18.411, -29.295], ramp_p = [-19.849, -30.757],
        ledge_c = [-24.310, -30.035], ramp_top = [-22.973, -27.686])
    concat(
    wall_back(),
    p_arc(CTR, [-R_OUT, CTR.y], [15.016, -29.244]),
    [[TIP_Y, TIP_TOP], [TIP_Y, zt]],
    p_arc(CTR, [TIP_Y, zt], [-TIP_LOW, zl], cw = true),
    [[-TIP_Y, TIP_TOP], [-15.016, -29.244]],
    p_arc(CTR, [-15.016, -29.244], out_l2),
    [fl],
    p_arc(ramp_c, fl, ramp_p, cw = true),
    [ramp_top],
    p_arc(ledge_c, ramp_top, [ledge_c.x, LEDGE_Z]),
    [[ledge_c.x, TOP_Z]]);

// The chamfer's envelope outline: as the hoop's, with the bore, tips and
// wall's inner side filled, so that only the outer edges are offset.
function env_path() = concat(
    [[-30.191, 5.0]],
    wall_back(),
    p_arc(CTR, [-R_OUT, CTR.y], on_clip(R_OUT, 60)),
    [[on_clip(R_OUT, 60).x, 5.0]]);

module hoop_2d() polygon(hoop_path(config));

// C3's cut-away: the clip's ring between -180 deg and CUT_TO, less the bars.
module cutaway_2d() difference() {
    intersection() {
        translate(CTR) difference() { circle(r = R_OUT + 1, $fn = 144); circle(r = R_BORE - 1.5, $fn = 144); }
        translate(CTR) polygon(concat([[0, 0]],
            [for (a = [-180 : 30 : CUT_TO]) 40 * [cos(a), sin(a)]],
            [40 * [cos(CUT_TO), sin(CUT_TO)]]));
    }
    for (a = BARS) translate(CTR) rotate(a) translate([R_BORE - 3, -BAR_W / 2])
        square([R_OUT - R_BORE + 6, BAR_W]);
}

module mid_2d() difference() { hoop_2d(); cutaway_2d(); }

// --- 3D ---------------------------------------------------------------------
// A 2D section (u = y, v = z) extruded along x from x0 to x1.
module xext(x0, x1) translate([x0, 0, 0]) rotate([90, 0, 90])
    linear_extrude(x1 - x0) children();

// One end of the envelope: the outline offset in by CH at x 0, full at x CH.
module env_end() translate([0, 0, 0]) rotate([90, 0, 90])
    offset_sweep(env_path(), height = CH, bottom = os_chamfer(width = CH, height = CH),
                 offset = "delta");

module envelope() union() {
    translate([X_END[0], 0, 0]) env_end();
    xext(X_END[0] + CH - LAP, X_END[1] - CH + LAP) polygon(env_path());
    translate([X_END[1], 0, 0]) mirror([1, 0, 0]) env_end();
}

module layers() union() {
    xext(X_END[0], X_HOOP[0] + LAP) hoop_2d();
    xext(X_HOOP[0], X_HOOP[1] + LAP) mid_2d();
    xext(X_HOOP[1], X_END[1]) hoop_2d();
}

// W1's disk-side face: the r 27.05 cylinder, its R2 fillet and the ledge.
module wall_cutter() rotate_extrude($fn = 288) polygon(concat(
    [[0, LEDGE_Z], [WALL_R - FILLET, LEDGE_Z]],
    [for (a = [-90 : 6 : 0]) [WALL_R - FILLET, LEDGE_Z + FILLET] + FILLET * [cos(a), sin(a)]],
    [[WALL_R, TOP_Z + 2], [0, TOP_Z + 2]]));

module tab() translate([0, 0, TAB_Z[0]])
    linear_extrude(TAB_Z[1] - TAB_Z[0] + LAP) tab_plan_2d();

// B1 and B2's run of sections, from below the tab to above it.
function bore_runs(cfg) = [
    [-15.5, CBORE_Z, "round", FLANGE_D],
    [CBORE_Z, -7.5, "round", fit_bore(BODY_D, press(cfg))]];

module shroud_rotate_a() difference() {
    union() {
        difference() { intersection() { layers(); envelope(); } wall_cutter(); }
        tab();
    }
    beam_bores(bore_runs(config));
    nail_holes(NAIL_Z[0], NAIL_Z[1] + 1);
}

// The part cut at x = at, as 2D (y, z).
module section_x_2d(at) projection(cut = true)
    multmatrix([[0, 1, 0, 0], [0, 0, 1, 0], [1, 0, 0, -at], [0, 0, 0, 1]])
        shroud_rotate_a();

if (layer == "hoop") section_x_2d(HOOP_AT);
else if (layer == "mid") section_x_2d(MID_AT);
else if (layer == "plan") projection(cut = true) translate([0, 0, -PLAN_AT]) shroud_rotate_a();
else shroud_rotate_a();
