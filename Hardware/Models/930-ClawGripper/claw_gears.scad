// 930-ClawGripper — the claw's gear outlines, drawn with BOSL2.
// The parts that cut teeth or keep clear of them include this file: the Claw Gear (#930-002), the Claw
// Pinion (#930-004) and the Claw Body (#930-003). It includes claw_params.scad, which owns every
// dimension; the assemblies use claw_params.scad alone, because a `use` of a file that includes BOSL2
// carries BOSL2's overrides of the core modules without the special variables they read. The asserts
// below hold claw_params.scad's involute arithmetic to BOSL2's.
//
// FRAME. claw_params.scad's: each outline in its gear's own (x, z), polar from +X toward +Z.

include <BOSL2/std.scad>
include <BOSL2/gears.scad>
include <claw_params.scad>

// The sector: the 30-tooth gear's teeth over claw_sector_arc(), on a disc inside its root.
module claw_sector_2d(cfg) let(a = claw_sector_arc(), r = 2 * claw_sector_tip_r()) union() {
    intersection() {
        spur_gear2d(mod = claw_mod(), teeth = claw_sector_n(), pressure_angle = claw_pa(), profile_shift = 0,
                    backlash = claw_gear_backlash(cfg), gear_spin = claw_sector_spin());
        polygon(concat([[0, 0]], [for (t = [a[0] : 2 : a[1]]) r * [cos(t), sin(t)]], [r * [cos(a[1]), sin(a[1])]]));
    }
    circle(r = claw_sector_disc_r());
}

module claw_pinion_2d(cfg) spur_gear2d(mod = claw_mod(), teeth = claw_pinion_n(), pressure_angle = claw_pa(),
    profile_shift = claw_pinion_shift(), shorten = claw_pinion_shorten(), backlash = claw_gear_backlash(cfg),
    gear_spin = claw_pinion_spin());

// A gear's swept area over the travel, about its pivot, in the grip frame's (x, z): its sector. s = 1 the
// drive, -1 the follower (turned claw_gear_turn()).
module claw_gear_sweep_2d(s) let(p = claw_pivot())
    for (a = [0 : 1 : claw_open_max()]) translate([s * p.x, p.y]) rotate(s > 0 ? -a : a + claw_gear_turn()) claw_sector_2d("revised");

function near(a, b) = abs(a - b) < 1e-6;
assert(near(claw_pinion_shift(), auto_profile_shift(claw_pinion_n(), claw_pa())), "the pinion's shift differs from BOSL2's");
assert(near(claw_pinion_dist(), gear_dist(mod = claw_mod(), teeth1 = claw_pinion_n(), teeth2 = claw_sector_n())),
       str("the pinion's centre distance ", claw_pinion_dist(), " differs from BOSL2's"));
assert(near(claw_pinion_shorten(), gear_shorten(claw_pinion_n(), claw_sector_n())), "the pinion's shortening differs from BOSL2's");
assert(near(claw_pivot().x * 2, gear_dist(mod = claw_mod(), teeth1 = claw_sector_n(), teeth2 = claw_sector_n())),
       "the pivots' spacing differs from BOSL2's");
assert(near(claw_sector_tip_r(), outer_radius(mod = claw_mod(), teeth = claw_sector_n())), "the sector's tip differs from BOSL2's");
assert(near(claw_pinion_tip_r(), outer_radius(mod = claw_mod(), teeth = claw_pinion_n(), shorten = claw_pinion_shorten())),
       "the pinion's tip differs from BOSL2's");
assert(claw_sector_disc_r() < root_radius(mod = claw_mod(), teeth = claw_sector_n()), "the sector's disc reaches its root");
