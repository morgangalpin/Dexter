// 800-Harness bought-part stand-ins: the C-716 fan and its four C-619 screws,
// drawn only so the Fan Bracket's views show what it holds.
//
// NOTHING HERE IS A PART MODEL. Neither is printed, and neither is gated
// against a reference. The fan's frame, holes and thickness are its datasheet's
// (specs/007.1, C-716). Its impeller bore is the CAD fan body's (specs/009,
// DC-11(b)), and its hub, blades and struts are illustration. The screw's
// thread, length and head are C-619's; the datasheet gives the flat head's
// diameter but not its angle, so the head is drawn at 90 degrees, the usual
// countersink.
//
// FRAME. The fan's axis on +Z through the origin, its faces at z = 0 and
// z = FAN_DEPTH. A screw's axis on +Z, its head's top face at z = 0 and its
// shank down.
//
// The Fan Bracket includes this file for these sizes, so nothing is drawn at
// top level.

FAN_SIDE   = 40.0;            // C-716 frame
FAN_DEPTH  = 10.0;
FAN_R      = 2.0;             // frame corners, as the bracket's seat draws them
FAN_HOLE   = 4.3;             // C-716 holes
FAN_PITCH  = 32.0;            // on a square about the axis
FAN_BORE   = 37.698;          // DC-11(b)
FAN_HUB    = 21.0;            // illustration
FAN_BLADES = 7;
FAN_SCREW  = [5.0, 10.0, 6.3];  // C-619: thread, overall length, flat head

HW_FN = 48;                   // stand-ins are drawn, not measured

// The height of the screw's head: its 90 degree cone, from the head down to
// the thread.
function fan_screw_head_h() = (FAN_SCREW[2] - FAN_SCREW[0]) / 2;

module c716_fan() {
    difference() {
        linear_extrude(FAN_DEPTH)
            offset(r = FAN_R) offset(delta = -FAN_R) square(FAN_SIDE, center = true);
        translate([0, 0, -1]) cylinder(d = FAN_BORE, h = FAN_DEPTH + 2, $fn = 2 * HW_FN);
        for (i = [-1, 1], j = [-1, 1])
            translate([i, j, 0] * FAN_PITCH / 2 - [0, 0, 1])
                cylinder(d = FAN_HOLE, h = FAN_DEPTH + 2, $fn = HW_FN);
    }
    cylinder(d = FAN_HUB, h = FAN_DEPTH - 0.5, $fn = HW_FN);
    // The struts, on the face away from the bracket, that carry the hub.
    for (a = [0 : 90 : 270])
        rotate(a) translate([FAN_HUB / 4, -0.75, 0]) cube([FAN_SIDE / 2 - 0.5 - FAN_HUB / 4, 1.5, 1.5]);
    for (i = [0 : FAN_BLADES - 1])
        rotate(i * 360 / FAN_BLADES) translate([0, 0, 2])
            linear_extrude(FAN_DEPTH - 3, twist = -30, slices = 8)
                translate([FAN_HUB / 2 - 0.5, -0.4]) square([(FAN_BORE - FAN_HUB) / 2, 0.8]);
}

module c619_screw() {
    head = fan_screw_head_h();
    translate([0, 0, -head]) cylinder(d1 = FAN_SCREW[0], d2 = FAN_SCREW[2], h = head, $fn = HW_FN);
    translate([0, 0, -FAN_SCREW[1]]) cylinder(d = FAN_SCREW[0], h = FAN_SCREW[1] - head + 0.01, $fn = HW_FN);
}
