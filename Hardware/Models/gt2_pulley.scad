// GT2 timing-pulley tooth ring, shared by every printed GT2 pulley in the
// model set: the differential's inputs (700-Differential) and the External
// pulleys at the elbow (400-EndArm). Include it; it defines constants.
//
// The tooth form is the one measured on the built 40T pulleys (720-003,
// 720-001's band): a tip circle with one round groove per tooth. The groove is
// R0.8, and its bottom sits GT2_TOOTH_H inside the tip circle -- measured as
// tip Ø24.970 over root Ø23.400. Stating the groove by its depth rather than
// by its centre radius is what lets one form serve every tooth count: the
// centre follows from the tip, so a larger pulley gets the same tooth.
//
// Plain rotate/translate, not BOSL2, so the file includes into any part.

GT2_PITCH    = 2.0;     // belt pitch
GT2_PLD      = 0.254;   // pitch line distance (belt standard)
GT2_TOOTH_H  = 0.785;   // tip circle to groove bottom (measured, 40T)
GT2_GROOVE_R = 0.8;     // groove radius (measured, 40T)
GT2_BELT_BACK = 0.63;   // belt back over the tip circle: the 1.38 mm belt
                        //   less its 0.75 mm tooth, which sits in the groove

// Tip diameter of an n-tooth pulley: pitch Ø n*p/PI, less the PLD each side.
function gt2_tip_d(n) = n * GT2_PITCH / PI - 2 * GT2_PLD;

// Groove-bottom (root) diameter for a given tip diameter.
function gt2_root_d(tip_d) = tip_d - 2 * GT2_TOOTH_H;

// 2D section of the tooth ring: the tip disc less n grooves. tip_d defaults
// to the standard for n; a measured pulley passes its own.
module gt2_teeth_2d(n, tip_d = undef) {
    td = is_undef(tip_d) ? gt2_tip_d(n) : tip_d;
    gc = td / 2 - GT2_TOOTH_H + GT2_GROOVE_R;
    difference() {
        circle(d = td);
        for (i = [0 : n - 1])
            rotate(i * 360 / n) translate([gc, 0]) circle(r = GT2_GROOVE_R);
    }
}
