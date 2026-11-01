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

// A convex path's long sides bowed outward by `rise` of their length, in a parabola, so that they read
// as gentle curves; its top and bottom stay straight, the bottom over the Span Mount's column foot.
function bowed(path, rise = 0.060, least = 8, n = 12) = let(k = len(path))
    [for (i = [0 : k - 1]) let(a = path[i], d = path[(i + 1) % k] - a, l = norm(d), m = [d.y, -d.x] / max(l, 1e-9))
        each (l >= least && abs(m.x) > 0.5 ? [for (j = [0 : n - 1]) let(t = j / n) a + d * t + m * rise * l * 4 * t * (1 - t)] : [a])];

// The housing's outline in the grip frame's (x, z), the cap's and the body's: the hull of the walls round
// the hubs and their teeth, the sector's swept arc, the pinion and the cap's bolts, its sides bowed. The arc's end is
// rounded, so that the hull leaves it tangent.
function claw_shell_path() = let(ccw = claw_shell_hull(), q = bowed(ccw)) ccw_polygon(select(q, hull(q)));
function claw_shell_hull() = let(p = claw_pivot(), w = FIT_RUN + claw_shell_wall(), a = claw_sector_arc(), r = claw_sector_tip_r() + w,
                                 lo = a[0] - claw_open_max(), e = 3.000, n = ceil((a[1] - lo) / 2),
                                 pts = concat(move(p, circle(r = claw_hub_r() + w, $fn = 96)),
                                              move([-p.x, p.y], circle(r = claw_hub_r() + w, $fn = 96)),
                                              move(span_axis(), circle(r = claw_pinion_tip_r() + w, $fn = 96)),
                                              [for (i = [0 : n]) let(t = lo + (a[1] - lo) * i / n) p + r * [cos(t), sin(t)]],
                                              move(p + (r - e) * [cos(a[1]), sin(a[1])], circle(r = e, $fn = 48)),
                                              [for (s = [-1, 1]) [s * p.x, claw_shell_top()]],
                                              [for (b = claw_cap_bolts()) each move(b, circle(r = claw_bolt_boss(), $fn = 48))]))
    ccw_polygon(select(pts, hull(pts)));

// The housing's inside in the grip frame's (x, z): the outline in by the wall, less the bolts' pillars, each
// pillar blended into the wall as a rounded triangle.
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

// The Claw Finger Wall's ends, s = 1 on +X: each a line normal to the straight of the wall between the
// hub's round and the bolt's boss, tangent to the upper pillar on the side toward the blades.
function claw_wall_normal(s) = let(b = claw_cap_bolts()[0], p = claw_pivot(), d = b - p, w = FIT_RUN + claw_shell_wall(),
                                   a = atan2(d.y, d.x) + acos((claw_hub_r() + w - claw_bolt_boss()) / norm(d)))
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
