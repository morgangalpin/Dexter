// 930-ClawGripper 4-finger assembly — placement model.
// Places the 4-finger claw on the tool interface: claw2_assembly.scad's claw, with a Claw Axle in place
// of each Pinion Bearing EXT, held by an M3 x 25, and a second Claw Finger on each axle's nose beyond the
// body's bearing plate, with its set screw. Each pivot's two fingers turn together, and each tip meets the
// tip opposite it. claw2_assembly.scad owns the placement, the frames and the parts' modules.

use <claw2_assembly.scad>

part = "all";   // "all", or one name from claw_parts(4) or claw_race_parts() for per-part export
OPEN = 0;       // deg, 0 closed .. claw_open_max()
$fn = 96;       // claw2_assembly.scad's, which use does not carry over

claw_echoes(4, OPEN);
claw_assembly(4, part, OPEN);
