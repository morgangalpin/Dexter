// 930-ClawGripper — the claw's gear outlines, drawn with BOSL2.
// The parts that cut teeth or keep clear of them include this file: the Claw Fingers (#930-001,
// #930-007), the Claw Gear (#930-002), the Claw Pinion (#930-004) and the Claw Body (#930-003). It
// includes claw_params.scad, which owns every dimension; the assemblies use claw_params.scad alone,
// because a `use` of a file that includes BOSL2 carries BOSL2's overrides of the core modules without the
// special variables they read. The asserts below hold claw_params.scad's involute arithmetic to BOSL2's.
//
// FRAME. claw_params.scad's: each outline in its part's own (x, z), polar from +X toward +Z.

include <BOSL2/std.scad>
include <BOSL2/gears.scad>
include <claw_params.scad>

// The sector: the 34-tooth gear's teeth over claw_sector_arc(), cut to their wedge, on a web of the
// finger's hub's radius round the seat.
module claw_sector_2d(cfg) let(a = claw_sector_arc()) union() {
    intersection() {
        spur_gear2d(mod = claw_mod(), teeth = claw_sector_n(), pressure_angle = claw_pa(), profile_shift = 0,
                    backlash = claw_gear_backlash(cfg), gear_spin = claw_sector_spin());
        claw_wedge_2d(a, 2 * claw_sector_tip_r());
    }
    circle(r = claw_hub_r());
}

// A finger's outline without its bore or its hub's teeth, as a path in its own (x, z): s = 1 the drive's,
// its blade leaned and its root filleted onto the round hub; -1 the follower's, the drive's mirrored
// about x = 0.
function claw_finger_path(s = 1) = let(r = claw_root_r(),
                                       u = union(rot(claw_lean(), p = blade_upright_path()), circle(r = claw_hub_r(), $fn = 144))[0],
                                       f = offset(offset(u, r = r, $fn = 48), r = -r, $fn = 48))
    s > 0 ? f : reverse(xflip(f));
module claw_finger_solid_2d(s = 1) polygon(claw_finger_path(s));

// A finger's swept area over the travel without its hub's teeth, which stay inside the wall, about its
// pivot, in the grip frame's (x, z): s = 1 the drive's, turning polar -OPEN, -1 the follower's, turning
// +OPEN. The body's blade slots keep FIT_RUN off it.
module claw_sweep_2d(s = 1) let(p = claw_pivot(), f = claw_finger_path(s))
    for (a = [0 : 1 : claw_open_max()]) translate([s * p.x, p.y]) rotate(-s * a) polygon(f);

// Where a finger's hub is toothed: its teeth's wedge outside their root, so that the round hub, cut by it,
// overlaps the teeth round the bore rather than meeting them on the wedge's edge there.
module claw_teeth_zone_2d(s = 1) difference() {
    claw_wedge_2d(claw_hub_arc(s), 2 * claw_hub_tip_r());
    circle(r = claw_hub_root_r() - 0.5);
}

// A finger's outline without its bore: its blade and round hub, and the hub's teeth over their arc, cut to
// their wedge; s = 1 the drive's, -1 the follower's.
module claw_finger_2d(cfg, s = 1) let(a = claw_hub_arc(s), r = 2 * claw_hub_tip_r()) union() {
    difference() {
        claw_finger_solid_2d(s);
        claw_teeth_zone_2d(s);
    }
    intersection() {
        spur_gear2d(mod = claw_mod(), teeth = claw_hub_n(), pressure_angle = claw_pa(), profile_shift = 0,
                    backlash = claw_gear_backlash(cfg), gear_spin = claw_hub_spin(s));
        claw_wedge_2d(a, r);
    }
}

// A finger's hub, off its blade: round but for its teeth.
module claw_hub_2d(cfg, s = 1) intersection() {
    claw_finger_2d(cfg, s);
    union() {
        circle(r = claw_hub_r());
        claw_wedge_2d(claw_hub_arc(s), 2 * claw_hub_tip_r());
    }
}

// What the fingers cut through the body's wall, grown by FIT_RUN, in the grip frame's (x, z). The closing,
// by c, takes out the slivers between the two.
module claw_finger_clear_2d(c = 0.600) offset(r = -c) offset(r = FIT_RUN + c) for (s = [-1, 1]) claw_sweep_2d(s);

// Where the fingers' cutouts leave a groove in the wall's rim filled: the cap's and the body's, FIT_SLIP off
// the cut in the rim.
module claw_groove_land_2d() offset(delta = -claw_rim_fit()) claw_finger_clear_2d();

// The housing's outline in the grip frame's (x, z), the cap's and the body's: symmetric about the roll axis, flat
// along the top and along the bottom, under the Span Mount's bolts, each side one arc about its own centre
// (claw_shell_centre()), and each corner rounded tangent to its flat and its arc.
// What the walls keep round, as [centre, radius]: the hubs and their teeth, the pinion, the sector's swept tips
// and the cap's bolts, on +X.
function claw_shell_keep() = let(p = claw_pivot(), w = FIT_RUN + claw_shell_wall(), a = claw_sector_arc(), t = claw_sector_tip_r(),
                                 lo = a[0] - claw_open_max(), n = ceil((a[1] - lo) / 2))
    concat([[p, claw_hub_r() + w], [span_axis(), claw_pinion_tip_r() + w]],
           [for (i = [0 : n]) let(u = lo + (a[1] - lo) * i / n) [p + t * [cos(u), sin(u)], w]],
           [for (i = [0, 2]) [claw_cap_bolts()[i], claw_bolt_boss()]]);
// The side's radius: the least that keeps them all.
function claw_shell_r() = let(c = claw_shell_centre()) max([for (k = claw_shell_keep()) norm(k[0] - c) + k[1]]);
// The corners' radii, bottom and top: the walls they turn round, the pinion's and the hub's.
function claw_corner_r() = let(k = claw_shell_keep()) [k[1][1], k[0][1]];
// A corner's centre, f below or above the flat at z (d = 1 or -1), inside the side's arc.
function claw_corner_centre(z, d, f) = let(c = claw_shell_centre(), q = z + d * f) [c.x + sqrt((claw_shell_r() - f) ^ 2 - (q - c.y) ^ 2), q];
// An arc about c from polar a0 to a1, in steps of 1 deg or less.
function claw_arc(c, r, a0, a1) = let(n = ceil(a1 - a0)) [for (i = [0 : n]) let(t = a0 + (a1 - a0) * i / n) c + r * [cos(t), sin(t)]];
// The +X side, from the bottom flat to the top one.
function claw_shell_side() = let(c = claw_shell_centre(), f = claw_corner_r(), b = claw_corner_centre(claw_floor(), 1, f[0]),
                                 t = claw_corner_centre(claw_shell_top(), -1, f[1]), bd = b - c, td = t - c,
                                 ba = atan2(bd.y, bd.x), ta = atan2(td.y, td.x))
    concat(claw_arc(b, f[0], -90, ba), claw_arc(c, claw_shell_r(), ba, ta), claw_arc(t, f[1], ta, 90));
function claw_shell_path() = let(s = claw_shell_side()) deduplicate(concat(s, reverse(xflip(s))), closed = true);

// The housing's inside in the grip frame's (x, z): the outline in by the wall, less the bolts' pillars, each
// pillar blended into the wall by a fillet tangent to both.
module claw_cavity_2d() let(f = claw_blend_r()) offset(r = f) offset(delta = -f) difference() {
    offset(delta = -claw_shell_wall()) polygon(claw_shell_path());
    for (b = claw_cap_bolts()) translate(b) circle(r = claw_pillar_r(), $fn = 72);
}

// A ring round the housing along y, between two convex faces, each `s(t)` in from the outline at t 0 and 1:
// the wall's rim on the body and the groove in the cap, tapered.
module claw_tapered_ring(y, outer, inner) let(l = y[1] - y[0]) difference() {
    claw_outline_taper(y, outer);
    claw_outline_taper([y[0] - l, y[1] + l], [2 * inner[0] - inner[1], 2 * inner[1] - inner[0]]);
}
// The outline, s[t] in from it at y[t], as a frustum.
module claw_outline_taper(y, s) hull() for (t = [0, 1])
    multmatrix(AXIS_Y) translate([0, 0, y[t]]) linear_extrude(0.001) offset(delta = -s[t]) polygon(claw_shell_path());

// The Claw Finger Wall's ends, s = 1 on +X: each a radius of the side's arc, tangent to the upper pillar on the
// side toward the blades.
function claw_wall_normal(s) = let(d = claw_cap_bolts()[0] - claw_shell_centre(), a = atan2(d.y, d.x) + asin(claw_pillar_r() / norm(d)))
    [s * cos(a), sin(a)];
function claw_wall_along(s) = let(n = claw_wall_normal(s)) [-s * n.y, abs(n.x)];
function claw_wall_end(s, f = 0) = claw_cap_bolts()[s > 0 ? 0 : 1] + (claw_pillar_r() + f) * claw_wall_along(s);
// Where that line, moved f toward the blades, leaves the outline `p`, by bisection.
function claw_wall_edge(s, f, p, lo = 0, hi = 20, i = 0) = let(m = (lo + hi) / 2, q = claw_wall_end(s, f) + m * claw_wall_normal(s))
    i == 24 ? q : point_in_polygon(q, p) >= 0 ? claw_wall_edge(s, f, p, m, hi, i + 1) : claw_wall_edge(s, f, p, lo, m, i + 1);

// The zone of the wall that the Claw Finger Wall takes, its ends moved f toward the blades.
module claw_wall_zone_2d(f = 0) let(a = claw_wall_end(-1, f), b = claw_wall_end(1, f))
    polygon([a, a + 40 * claw_wall_normal(-1), b + 40 * claw_wall_normal(1), b]);

// The lip on an end, in a part's own section, its faces grown by c: the rim's faces at the rim's taper, the
// inner one leaving the wall's inside tangent, so that the two are one curve to the lip's end.
module claw_wall_lip_2d(s, c = 0) let(l = claw_wall_lip_l(), k = l / claw_rim_l(), n = claw_wall_normal(s), o = claw_rim_outer(0), w = claw_rim_inner(0),
                                      out = offset(claw_shell_path(), delta = -o, closed = true),
                                      in = offset(claw_shell_path(), delta = -w, closed = true))
    offset(delta = c) polygon(concat([for (i = [-3 : 8]) let(t = i / 8) claw_wall_edge(s, -l * t, out) + (o - claw_rim_outer(k * max(t, 0))) * n],
                                     [for (i = [8 : -1 : -3]) let(t = i / 8) claw_wall_edge(s, -l * t, in) + (w - claw_rim_inner(k * t * max(t, 0))) * n]));

// The Claw Finger Wall's section: the housing's wall, even all the way, within the zone, and its lips.
module claw_wall_2d(cfg) let(f = fit_clearances(cfg)[0]) {
    intersection() {
        difference() {
            polygon(claw_shell_path());
            offset(delta = -claw_shell_wall()) polygon(claw_shell_path());
        }
        claw_wall_zone_2d(f);
    }
    for (s = [-1, 1]) claw_wall_lip_2d(s);
}

module claw_pinion_2d(cfg) spur_gear2d(mod = claw_mod(), teeth = claw_pinion_n(), pressure_angle = claw_pa(),
    profile_shift = claw_pinion_shift(), shorten = claw_pinion_shorten(), backlash = claw_gear_backlash(cfg),
    gear_spin = claw_pinion_spin());

// The sector's swept area over the travel, about the drive pivot, turning polar -OPEN, in the grip frame's
// (x, z).
module claw_gear_sweep_2d() let(p = claw_pivot())
    for (a = [0 : 1 : claw_open_max()]) translate(p) rotate(-a) claw_sector_2d("revised");

function near(a, b) = abs(a - b) < 1e-6;
assert(near(claw_pinion_shift(), auto_profile_shift(claw_pinion_n(), claw_pa())), "the pinion's shift differs from BOSL2's");
assert(near(claw_pinion_dist(), gear_dist(mod = claw_mod(), teeth1 = claw_pinion_n(), teeth2 = claw_sector_n())),
       str("the pinion's centre distance ", claw_pinion_dist(), " differs from BOSL2's"));
assert(near(claw_pinion_shorten(), gear_shorten(claw_pinion_n(), claw_sector_n())), "the pinion's shortening differs from BOSL2's");
assert(near(claw_pivot().x * 2, gear_dist(mod = claw_mod(), teeth1 = claw_hub_n(), teeth2 = claw_hub_n(),
                                          profile_shift1 = 0, profile_shift2 = 0)),
       "the pivots' spacing differs from BOSL2's");
assert(near(claw_sector_tip_r(), outer_radius(mod = claw_mod(), teeth = claw_sector_n())), "the sector's tip differs from BOSL2's");
assert(near(claw_hub_tip_r(), outer_radius(mod = claw_mod(), teeth = claw_hub_n(), profile_shift = 0)), "the hubs' tip differs from BOSL2's");
assert(claw_hub_root_r() <= root_radius(mod = claw_mod(), teeth = claw_hub_n(), profile_shift = 0), "the hubs' root stands outside BOSL2's");
assert(near(claw_pinion_tip_r(), outer_radius(mod = claw_mod(), teeth = claw_pinion_n(), shorten = claw_pinion_shorten())),
       "the pinion's tip differs from BOSL2's");
assert(claw_hub_r() < root_radius(mod = claw_mod(), teeth = claw_sector_n()), "the sector's web reaches its root");
assert(claw_corner_centre(claw_shell_top(), -1, claw_corner_r()[1]).x >= claw_pivot().x - 0.5, "the top's flat stops short of the hub");
