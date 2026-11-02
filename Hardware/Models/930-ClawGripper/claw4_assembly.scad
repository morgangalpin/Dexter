// 930-ClawGripper 4-finger assembly — placement model.
// Places the 4-finger claw on the tool interface: claw2_assembly.scad's, with this build's longer body, wall,
// axles and pinion, a second pair of fingers with their set screws, the rear pair turned 180 deg about the roll
// axis, and the same Claw Gear and Claw Cap, the cap at this build's seam. Each pivot's two fingers turn together,
// and each tip meets the tip opposite it.
// claw2_assembly.scad owns the placement, the frames and the parts' modules, and claw_params.scad the pairs'
// places.

use <claw2_assembly.scad>

part = "all";   // "all", or one name from claw_parts() or claw_race_parts() for per-part export
OPEN = 0;       // deg, 0 closed .. claw_open_max()
$fn = 96;       // claw2_assembly.scad's, which use does not carry over
$claw_fingers = 4;

claw_echoes(OPEN);
claw_assembly(part, OPEN);
