// #730-001 Diff Body A — parametric source (DC-2), faithful recreation.
// The static wrist frame: it carries the J4 pivot bearings — the 6705 in
// the Ø32 top seat and a 6703 in the Ø23 bottom seat (008.6 step 1) — on
// which the Diff Gear Shaft's Ø25 section and Ø17 rear journal turn. The
// GT2 belts pass through the arm's central slot from the arm (-X) side;
// the two M3 screws at (-25, +/-8.7) retain the assembly.
//
// This file is a recreation of 730-001_DiffBodyA.stl, not an authored
// redesign: it is gated on `scadmesh dist` +/-0.15 mm in both directions,
// the same contract as the other six 700-series parts. It replaces an
// authored shell that held every bore and axis in the right place but
// rendered 62,023 mm3 against the reference's 25,509 mm3 — 2.43x the
// material in the same envelope, because the reference is a frame and the
// authored version was a block. See specs/009 § Differential detail design.
//
// The part as measured:
//   - Two bearing bosses, top and bottom, joined by ONE half-annular rib on
//     +X and TWO arm webs. The middle is open: there is no hub material at
//     all between z=6 and z=16.
//   - The outer shell is mirror-symmetric about z=11 over z in [2,20]; the
//     caps below 2 and above 20 differ, since the bottom takes the 6703 and
//     the top carries the Ø60 plate, the 6705, the pins and the pocket track.
//   - The arm's outer section is a 20 x 20 rounded rectangle, R4, spanning
//     z in [1,21] — which is why the arm is absent at z=0.5.
//   - The belt slot is 6 x 6 mm (y +/-3, z 8..14) centred on z=11: a 6 mm
//     GT2 belt, matching the 40T GT2 pulleys in diff_params.scad. Over the
//     boxy part of the arm the slot opens into an hourglass lead-in; see
//     belt_slot_2d().
//   - Three features are not the simple round holes they look like from the
//     top, and each is modelled as measured rather than as drawn: the end-stop
//     pockets are annular sectors with flat ends (pocket_2d), the screw
//     clearance holes are D-shaped (d_hole_2d), and the belt slot flares
//     (belt_slot_2d).
//
// House style is followed except for edge breaks: no chamfer or roundover is
// added for printability, because every edge here has to match a measurement.

include <diff_params.scad>

/* [Hidden] */
H            = 22.0;    // overall height (J4 axis along Z)

// Bearing ladder, bottom up: [diameter, z_low, z_high]. Measured on the
// reference's own sections, not taken from the bearing catalogue, so a seat
// that was cut oversize stays oversize.
LADDER = [
    [BRG_6703[1], 0.0,  5.0],    // Ø23 6703 seat
    [20.0,        5.0,  6.0],    // Ø20 waist, into the open middle
    [26.0,       16.0, 17.0],    // Ø26 spacer shoulder
    [BRG_6705[1], 17.0, H],      // Ø32 6705 seat
];

HUB_D        = 40.0;            // plate hub diameter, z 0..6 and 16..20
TOP_D        = 60.0;            // top plate, z 20..22 — sets the ±30 envelope
PLATE_LO     = [0.0, 6.0];
PLATE_HI     = [16.0, 20.0];
TOP_PLATE    = [20.0, H];

RIB          = [16.0, 20.0, 6.0, 16.0];  // [r_in, r_out, z_low, z_high]
RELIEF_R     = 14.0;            // Ø28 relief the arm's concave end wraps

// Arm. The tip is x = ARM_TIP; "previous" reproduces the reference's 80.984 mm
// overall width, "revised" trims the arm to fit the HDI-940 cover envelope.
ARM_TIP      = -(BODY_A_LEN - TOP_D / 2);
ARM_STEP_X   = -36.0;           // where the outer section meets the plates
ARM_FAR      = [20.0, 20.0, 4.0];  // [width y, height z, corner radius]
ARM_FAR_Z    = 11.0;            // centre of the rounded section

// Belt slot. The waist is the slot proper; over the boxy arm (x from the tip
// to ARM_STEP_X) it opens through 45-degree flares into a much larger mouth,
// so the two GT2 belts can fan out to their pulleys without rubbing. The
// mouth's z limits are symmetric about z=11, like the rest of the shell.
SLOT         = [3.0, 8.0, 14.0, -12.0];    // [half-width y, z_lo, z_hi, x_inner]
MOUTH_Y      = 6.350;             // mouth half-width; the flare runs at 45 deg
MOUTH_Z      = [3.348, 18.652];   // mouth z limits (11 -/+ 7.652)

SCREW_POS    = [[-25.026, 8.692], [-25.027, -8.713]];
SCREW_CLEAR  = [4.598, 18.008];   // Ø, up to this z
SCREW_FLAT   = 1.800;             // clearance holes are D-shaped: flat this far
                                  // from the axis, on the outboard side
SCREW_TAP    = 3.194;             // Ø above SCREW_CLEAR[1], round and coaxial
PIN_POS      = [[-32.621, 4.0], [-32.621, -4.0]];
PIN          = [3.99, 18.652];    // Ø, floor z — 3.348 deep, not the 2.6 once
                                  // authored, and not the round 3.0 it looks like

// Code-disk end-stop pockets. Not round holes: each is an annular sector
// closed by two flat end faces, described in pocket_2d().
POCKET       = [20.0, 27.0, 2.5, 2.0, 20.0];  // [r_in, r_out, chord, fillet, floor z]
POCKET_ANG   = [30, -30, 90, -90];

echo(str("Diff Body A width=", BODY_A_LEN, " mm  arm tip x=", ARM_TIP));
assert(ARM_TIP < min(PIN_POS[0][0], SCREW_POS[0][0]) - 2,
       "Body A arm is too short to carry its screw and pin features");

// ---------------------------------------------------------------------------
// 2D outlines. Each is a single polygon or a union of leaves — never an
// internally boolean module, so the preview tree stays flat (009 § geometry
// verification: a boolean cutter doubles the normalized tree).
// ---------------------------------------------------------------------------

function arc_pts(r, a0, a1, n = 64) =
    [for (i = [0:n]) r * [cos(a0 + (a1 - a0) * i / n), sin(a0 + (a1 - a0) * i / n)]];

// The arm as it meets the plates: a step at x=-36, a short chamfer, then a
// straight taper onto the hub circle at (-9.929, +/-17.361).
module arm_plate_2d(join_y) {
    polygon([
        [ARM_STEP_X,  10.999], [-34.996,  12.229], [-9.929,  17.361],
        [0,  join_y], [0, -join_y],
        [-9.929, -17.361], [-34.996, -12.229], [ARM_STEP_X, -10.999],
    ]);
}

// The arm as it meets the Ø60 top plate: the taper lands further out, at
// (-26.555, +/-13.957), because the plate it joins is larger.
module arm_top_2d() {
    polygon([
        [ARM_STEP_X,  10.999], [-34.996,  12.229], [-26.555,  13.957],
        [0,  13.957], [0, -13.957],
        [-26.555, -13.957], [-34.996, -12.229], [ARM_STEP_X, -10.999],
    ]);
}

// The arm through the open middle: narrower than the plates, and closed by
// the Ø28 relief rather than by a hub.
//
// The relief arc already lands on (-8.660, -/+11), so those points are NOT
// repeated around it. A duplicated vertex is a zero-length edge, and CGAL
// drops the whole polygon rather than the edge — silently, leaving the mid
// band with nothing but the rib (009 § geometry verification records the
// same trap for exactly collinear vertices).
module arm_mid_2d() {
    a0 = atan2(-11.0, -8.660) + 360;   // where the flank meets the relief
    polygon(concat(
        [[ARM_TIP, -10.0], [ARM_STEP_X, -10.0], [ARM_STEP_X, -11.0]],
        arc_pts(RELIEF_R, a0, 360 - a0),
        [[ARM_STEP_X, 11.0], [ARM_STEP_X, 10.0], [ARM_TIP, 10.0]]
    ));
}

// The rib that carries the whole +X side: an annulus over exactly the half
// plane x >= 0, measured at R16.00 and R20.00 and constant over z 6..16.
module rib_2d() {
    polygon(concat(arc_pts(RIB[1], -90, 90), arc_pts(RIB[0], 90, -90)));
}

// The belt lead-in, in the arm's own Y-Z section. Measured identically at
// every x from the tip to ARM_STEP_X, so it extrudes rather than lofts: the
// 6 x 6 waist flares out at 45 degrees to a 12.700 x 15.304 mouth. Written in
// [z - ARM_FAR_Z, y] because yrot(90) sends the extrusion axis to +X; both the
// profile and the arm are symmetric about z = ARM_FAR_Z, so the sign the
// rotation puts on z does not matter.
module belt_slot_2d() {
    f   = MOUTH_Y - SLOT[0];        // 3.350 of flare, at 45 deg
    zlo = SLOT[1] - f;              // 4.650: mouth wall breaks into the flare
    zhi = SLOT[2] + f;              // 17.350
    polygon([
        for (p = [
            [-SLOT[0], SLOT[1]], [-MOUTH_Y, zlo], [-MOUTH_Y, MOUTH_Z[0]],
            [ MOUTH_Y, MOUTH_Z[0]], [ MOUTH_Y, zlo], [ SLOT[0], SLOT[1]],
            [ SLOT[0], SLOT[2]], [ MOUTH_Y, zhi], [ MOUTH_Y, MOUTH_Z[1]],
            [-MOUTH_Y, MOUTH_Z[1]], [-MOUTH_Y, zhi], [-SLOT[0], SLOT[2]],
        ]) [p[1] - ARM_FAR_Z, p[0]]
    ]);
}

// A screw clearance hole: a circle with one flat, the flat on +Y. The chord
// meets the circle at asin(flat/r), and the arc is drawn the long way round
// from there; the chord itself is the polygon's closing edge.
module d_hole_2d(d, flat) {
    r = d / 2;
    s = asin(flat / r);
    polygon(arc_pts(r, 180 - s, 360 + s, 48));
}

// One end-stop pocket, centred on +X. It is an annular sector R20..R27 whose
// ends are not radial faces but flat planes 2.5 mm from the J4 axis, with all
// four corners rounded R2. Every corner is convex, so a morphological opening
// reproduces them exactly: eroding then dilating by the fillet radius returns
// the arcs to R20/R27 and the end planes to 2.5 mm while leaving the corners
// rounded. The reference's inner arc ends at 18.19 deg off centre and its
// outer arc at 19.63 deg; this construction gives both to within 0.01 mm.
module pocket_2d() {
    ri = POCKET[0];  ro = POCKET[1];  c = POCKET[2];
    a_in  = acos(c / ri) - 60;
    a_out = acos(c / ro) - 60;
    offset(r = POCKET[3]) offset(r = -POCKET[3])
        polygon(concat(arc_pts(ri, -a_in, a_in, 32),
                       arc_pts(ro, a_out, -a_out, 32)));
}

module plate(zspan, hub_d, join_y) {
    translate([0, 0, zspan[0]]) linear_extrude(zspan[1] - zspan[0])
        union() {
            circle(d = hub_d);
            arm_plate_2d(join_y);
        }
}

// ---------------------------------------------------------------------------
// The part.
// ---------------------------------------------------------------------------

module diff_body_a() {
    difference() {
        union() {
            plate(PLATE_LO, HUB_D, 17.361);
            plate(PLATE_HI, HUB_D, 17.361);
            translate([0, 0, TOP_PLATE[0]]) linear_extrude(TOP_PLATE[1] - TOP_PLATE[0])
                union() {
                    circle(d = TOP_D);
                    arm_top_2d();
                }
            translate([0, 0, RIB[2]]) linear_extrude(RIB[3] - RIB[2]) rib_2d();
            translate([0, 0, RIB[2]]) linear_extrude(RIB[3] - RIB[2]) arm_mid_2d();
            // The arm's outer section, rounded in the Y-Z plane.
            translate([ARM_TIP, 0, ARM_FAR_Z]) yrot(90)
                linear_extrude(ARM_STEP_X - ARM_TIP)
                    rect([ARM_FAR[1], ARM_FAR[0]], rounding = ARM_FAR[2]);
        }

        // Bearing ladder.
        for (s = LADDER)
            translate([0, 0, s[1] - epsilon])
                cyl(d = s[0], h = s[2] - s[1] + 2 * epsilon, anchor = BOTTOM);

        // Belt slot: the 6 x 6 waist runs the length of the arm and out into
        // the open middle through the Ø28 relief, which is what closes it —
        // SLOT[3] only has to reach past the relief, not land on it. The
        // hourglass mouth is cut over the boxy section alone, ending exactly
        // at ARM_STEP_X where the arm meets the plates.
        translate([ARM_TIP - epsilon, -SLOT[0], SLOT[1]])
            cuboid([SLOT[3] - ARM_TIP + epsilon, 2 * SLOT[0], SLOT[2] - SLOT[1]],
                   anchor = BOTTOM + LEFT + FRONT);
        translate([ARM_TIP - epsilon, 0, ARM_FAR_Z]) yrot(90)
            linear_extrude(ARM_STEP_X - ARM_TIP + epsilon) belt_slot_2d();

        // Retaining screws: a D-shaped clearance hole below, its flat facing
        // outboard, and a round tapped hole above it on the same axis.
        for (p = SCREW_POS) {
            translate([p[0], p[1], -epsilon]) zrot(p[1] > 0 ? 0 : 180)
                linear_extrude(SCREW_CLEAR[1] + epsilon)
                    d_hole_2d(SCREW_CLEAR[0], SCREW_FLAT);
            translate([p[0], p[1], SCREW_CLEAR[1]])
                cyl(d = SCREW_TAP, h = H - SCREW_CLEAR[1] + epsilon, anchor = BOTTOM);
        }

        for (p = PIN_POS)
            translate([p[0], p[1], PIN[1]])
                cyl(d = PIN[0], h = H - PIN[1] + epsilon, anchor = BOTTOM);

        for (a = POCKET_ANG)
            zrot(a) up(POCKET[4])
                linear_extrude(H - POCKET[4] + epsilon) pocket_2d();
    }
}

diff_body_a();
