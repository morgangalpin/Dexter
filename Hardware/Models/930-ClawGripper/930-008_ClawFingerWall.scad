// #930-008 Claw Finger Wall — parametric source.
// The wall over the fingers, a piece of its own, so that the Claw Cap (#930-005) is a plain flat plate that
// the 4-finger build can reuse. Three tines, left of, between and right of the blades, joined by the wall in
// front of the blades. It slides in from the front once the fingers are in and clamps between the Claw Body
// (#930-003) and the cap. A tapered lip runs right round it, to its corners: into the cap at the front, into
// the body's wall at the rear, and at each end, a shallower one, into a groove in a pillar's blend, which
// backs it on the inside. claw_params.scad owns its dimensions and gives the claw's mechanism.
//
// Designed, "revised" only: there is no reference mesh.
//
// FRAME. The grip frame (../900-ToolInterface/span_socket.scad), as the Claw Body's. It prints standing on
// its front lip, y 18.069, open upward, with no supports.
//
//     ID  feature        value
//     W1  wall           the housing's wall, claw_shell_path() (claw_gears.scad) in by 2.5, an even section,
//                        y -4 .. 15.569, from upper pillar to upper pillar, each end tangent to its pillar
//                        and normal to the wall, FIT_SLIP short of the body's opening
//     B1  blade slots ×2 the fingers' swept area, FIT_RUN off it, y -4 .. 4, through the rear lip. As measured:
//                        the centre tine 6.88 wide at the inner face, its narrowest, and 7.66 at the outer,
//                        its sides at the blades' lean; each outer tine 11.7 along the wall, its end lip
//                        included; the wall unbroken in front of them
//     R1  front lip      y 15.569 .. 18.069, as the body's rim: inset 1.15 from the outline, each face
//                        tapered 0.15, 1.35 wide at the seam and 1.05 at its end; into the cap's groove
//     R2  rear lip       y -4 .. -6.5, R1's section, cut by B1, into the body's rear groove
//     L1  end lips ×2    1.5 long, off each end along the wall, R1's section at R1's taper, 1.17 wide at the
//                        tip; the inner face leaves W1's inside tangent, as one curve to the lip's tip
//     —   corners        R1 and R2 run out to L1's tips, within L1's section, so that the lip is unbroken
//                        round W1
//
// FITS (revised). W1's rear shoulder seats on the rear edge of the body's opening, and its front shoulder
// takes the cap's rear face, so that the body and the cap clamp it. Each lip stands FIT_SLIP off its groove,
// as the body's rim stands off the cap's, and the fingers turn FIT_RUN off B1.

include <claw_gears.scad>

/* [Configuration] */
// Parameter set: designed in revised only
config = "revised"; // [revised]

/* [Hidden] */
$fn = 144;
LAP = 0.005;

assert(config == "revised", "#930-008 exists only in the revised configuration: it has no reference");

module slab(y, lo = 0, hi = 0) multmatrix(AXIS_Y) translate([0, 0, y[0] - lo]) linear_extrude(y[1] - y[0] + lo + hi) children();

// R1 or R2, out to the corners within L1's section, so that R2 slides in along the body's end grooves.
module wall_rim(y) intersection() {
    claw_tapered_ring(y, [claw_rim_outer(0), claw_rim_outer(1)], [claw_rim_inner(0), claw_rim_inner(1)]);
    slab([min(y), max(y)], 1, 1) {
        claw_wall_zone_2d();
        for (s = [-1, 1]) claw_wall_lip_2d(s);
    }
}

module claw_finger_wall(cfg = config) let(y = claw_wall_y(), l = claw_rim_l()) difference() {
    union() {
        slab(y) claw_wall_2d(cfg);
        wall_rim([y[0] + LAP, y[0] - l]);
        wall_rim([y[1] - LAP, y[1] + l]);
    }
    slab([y[0] - l - 1, claw_slot_y()]) claw_finger_clear_2d();
}

claw_finger_wall();
