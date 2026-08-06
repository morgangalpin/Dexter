// #730-002 Diff Body B — parametric source (DC-2), authored functional body.
// The pivoting differential carrier. The Diff Gear Shaft spins in the two
// 6703s pressed into the tunnel ends (008.6 steps 3, 12); the shaft's Ø25
// section and Ø17 rear journal continue outward into Diff Body A's 6705 /
// 6703, making the shaft the J4 pivot axle. Perpendicular to the tunnel,
// the Ø17 stub carries the Split Gear on its 6703, and the Ø8 tube above
// it carries the Split Gear's MR128, the thrust stack (2x AS0819 +
// AXK0819), and the epoxied Diff Keeper (008.6 steps 5, 23). The six tool
// conductors enter through the two channels and run up the tube's bore
// (3 + 3, step 14).
//
// This file is an authored redesign (DC-2 is an authoring task): bearing
// seats, journals, bores, axis positions, and overall spans are taken from
// measurements of 730-002_DiffBodyB.stl; the sculpted outer shell is
// replaced by a clean parametric body. The reference frame is preserved:
// tunnel along Y at (x, z) = (21, 20.5), stub along +Z at (x, y) = (21, -21).

include <diff_params.scad>

/* [Hidden] */
AXIS_XZ     = [21.0, 20.5];   // tunnel axis position (x, z)
STUB_XY     = [21.0, -21.0];  // stub / output axis position (x, y)
TUNNEL_Y    = [-50.5, 8.5];   // tunnel span
BOSS_OD     = 30.0;     // tunnel boss outer diameter
TUNNEL_ID   = 19.0;     // shaft clearance bore
SEAT_DEPTH  = 4.0;      // 6703 seat depth at each tunnel end
STUB_D      = 17.0;     // Split Gear 6703 journal
STUB_Z      = [30.5, 48.5];   // stub span
TUBE_D      = THRUST_AXK0819[0];  // thrust stack and Diff Keeper ride this
TUBE_Z      = [48.5, 72.0];   // tube span
WIRE_D      = 5.0;      // wire bore through stub and tube
CAVITY_D    = 38.0;     // gear cavity around the stub axis
CAVITY_Z    = [8.0, 30.5];
SKIRT       = [[6.0, 36.0], [-38.0, -4.0], [-8.5, 8.0]];  // x, y, z spans
SKIRT_LAP   = 1.0;      // skirt/web overlap, so they share volume
CHANNEL_D   = 5.5;      // wire entry channels (2x, 3 conductors each)
CHANNEL_X   = [14.0, 28.0];   // channel positions along x, at y = -21

module diff_body_b() {
    difference() {
        union() {
            // Tunnel tube.
            translate([AXIS_XZ[0], TUNNEL_Y[0], AXIS_XZ[1]])
                ycyl(d=BOSS_OD, h=TUNNEL_Y[1] - TUNNEL_Y[0], anchor=FRONT);
            // Stub column and thrust tube.
            translate([STUB_XY[0], STUB_XY[1], STUB_Z[0]])
                cyl(d=STUB_D, h=STUB_Z[1] - STUB_Z[0], anchor=BOTTOM);
            translate([STUB_XY[0], STUB_XY[1], TUBE_Z[0] - epsilon])
                cyl(d=TUBE_D, h=TUBE_Z[1] - TUBE_Z[0] + epsilon, anchor=BOTTOM);
            // Web joining tunnel, stub base, and the lower skirt.
            translate([STUB_XY[0], STUB_XY[1], CAVITY_Z[0]])
                cyl(d=CAVITY_D + 6, h=STUB_Z[0] - CAVITY_Z[0] + 4, anchor=BOTTOM);
            // The skirt runs SKIRT_LAP past the web's underside rather than
            // meeting it exactly, so the two solids share volume instead of
            // a single coincident plane.
            translate([SKIRT[0][0], SKIRT[1][0], SKIRT[2][0]])
                cuboid([SKIRT[0][1] - SKIRT[0][0], SKIRT[1][1] - SKIRT[1][0],
                        SKIRT[2][1] - SKIRT[2][0] + SKIRT_LAP],
                       anchor=BOTTOM+LEFT+FRONT);
        }
        // Shaft clearance bore and the two 6703 seats.
        translate([AXIS_XZ[0], TUNNEL_Y[0] - epsilon, AXIS_XZ[1]])
            ycyl(d=TUNNEL_ID, h=TUNNEL_Y[1] - TUNNEL_Y[0] + 2*epsilon,
                 anchor=FRONT);
        translate([AXIS_XZ[0], TUNNEL_Y[0] - epsilon, AXIS_XZ[1]])
            ycyl(d=BRG_6703[1], h=SEAT_DEPTH + epsilon, anchor=FRONT);
        translate([AXIS_XZ[0], TUNNEL_Y[1] + epsilon, AXIS_XZ[1]])
            ycyl(d=BRG_6703[1], h=SEAT_DEPTH + epsilon, anchor=BACK);
        // Gear cavity around the stub axis (Split Gear and bevel mesh).
        translate([STUB_XY[0], STUB_XY[1], CAVITY_Z[0]])
            cyl(d=CAVITY_D, h=CAVITY_Z[1] - CAVITY_Z[0], anchor=BOTTOM);
        // Wire bore up the stub and tube.
        translate([STUB_XY[0], STUB_XY[1], CAVITY_Z[1] - epsilon])
            cyl(d=WIRE_D, h=TUBE_Z[1] - CAVITY_Z[1] + 2*epsilon, anchor=BOTTOM);
        // Wire entry channels into the cavity.
        for (x = CHANNEL_X)
            translate([x, STUB_XY[1], SKIRT[2][0] - epsilon])
                cyl(d=CHANNEL_D, h=CAVITY_Z[0] - SKIRT[2][0] + 2*epsilon,
                    anchor=BOTTOM);
    }
}

diff_body_b();
