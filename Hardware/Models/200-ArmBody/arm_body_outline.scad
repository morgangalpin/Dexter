// The Arm Body's outline about the J2 axis, shared by the two parts that carry it.
//
//     200-001_ArmBody.scad             T1/P1, the tube's section from z -7 to 91
//     200-002_PivotStatorHolder.scad   the flange, which matches the Arm Body's top
//
// A R36.500 circle with four ears on 0/90/180/270 deg. Each ear is the Stator Balancer slot grown by
// R4: its outer face 41.547 from the axis, its corners R4 on centres (37.547, ±5.031), and R4 concave
// fillets where it meets the circle. The slot itself (K1 on the Arm Body, the ear slot on the holder)
// is 10.000 across, from r 33.516 to 37.516; each part cuts its own. Measured on both references
// (scadmesh arcs): 200-001 at z 42 and 88 gives the circle R36.5, corners R4.0 on (37.50, ±5.00) and
// fillets R4.0; 200-002 gives the same.
//
// Included, not used, so that its constants reach the including file.

ARM_BODY_R    = 36.500;
ARM_BODY_EAR  = [37.547, 5.031, 4.000];   // corner centres' x and ±y, their radius
ARM_BODY_SLOT = [33.516, 37.516, 5.000];  // inner and outer radius, half-width

// One ear on +X, reaching in to the circle's inside.
module arm_body_ear_2d()
    offset(r = ARM_BODY_EAR[2]) translate([ARM_BODY_R - ARM_BODY_EAR[2] - 1, -ARM_BODY_EAR[1]])
        square([ARM_BODY_EAR[0] - ARM_BODY_R + ARM_BODY_EAR[2] + 1, 2 * ARM_BODY_EAR[1]]);

// The outline without its slots.
module arm_body_outline_2d()
    offset(r = -ARM_BODY_EAR[2]) offset(delta = ARM_BODY_EAR[2]) union() {
        circle(r = ARM_BODY_R);
        for (a = [0 : 90 : 270]) rotate(a) arm_body_ear_2d();
    }

// The four slots, each [radial, across] in size and centred on the measured slot's centre.
module arm_body_slots_2d(size = [ARM_BODY_SLOT[1] - ARM_BODY_SLOT[0], 2 * ARM_BODY_SLOT[2]])
    for (a = [0 : 90 : 270]) rotate(a)
        translate([(ARM_BODY_SLOT[0] + ARM_BODY_SLOT[1]) / 2, 0]) square(size, center = true);
