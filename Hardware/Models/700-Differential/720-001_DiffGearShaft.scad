// #720-001 Diff Gear Shaft — parametric source (DC-2).
// Input-B of the differential: a hollow shaft that spins in Diff Body B's
// two 6703 bearings (Ø17 end journals) while the CF rod (input A) runs
// through it on two MR128 bearings pressed into the Ø12 end seats
// (008.6 steps 4, 12, 21). Integrated on the shaft: a 20T bevel gear
// facing the Diff Gear Axle's bevel (both mesh the Split Gear at 90 deg)
// and a 40T GT2 pulley section for its drive belt.
//
// Geometry solved from 720-001_DiffGearShaft.stl (scadmesh slice sweeps).
// The reference mesh contains a degenerate internal Ø15.5 shell (an export
// artifact, visible as Ø0.2 sliver loops in every cross-section); it is
// intentionally not reproduced. Tooth flanks are BOSL2 involute bevel
// teeth — verified by tooth count and OD rather than vertex match.
//
// The part is modeled with the shaft along +Z (z equals the reference
// mesh's y coordinate) and rotated into the reference orientation at the
// bottom of the file.

include <diff_params.scad>
include <BOSL2/gears.scad>

/* [Hidden] */
Z0          = -10.96;   // shaft start (front journal end)
Z1          = 49.64;    // shaft end (rear journal end)
JOURNAL_D   = 17.0;     // 6703 inner-race journals, both ends
FRONT_STEPS = [[11.54, 19.0], [13.46, 23.0]];  // [z, Ø] steps before the gear
GEAR_Z0     = 14.25;    // bevel teeth begin
APEX_Z      = 1.75;     // bevel pitch-cone apex (virtual, inside the shaft)
FACE_W      = 7.4;      // bevel face width
// Back trim: full diameter to z 20.6 (tips reach the Ø43.2 maximum), a
// steep facet down to the clean back cone, then the back cone itself.
TRIM_Z      = [20.43, 21.7, 24.9];
TRIM_D      = [43.21, 35.8, 27.0];
BACK_CONE   = [[21.7, 35.8], [24.9, 27.0]];    // exposed clean back cone
D27_TOP     = 28.04;    // Ø27 section top
D25_TOP     = 34.04;    // Ø25 section top / pulley start
PULLEY_TOP  = 42.04;    // pulley section top
D25B_TOP    = 42.90;    // second Ø25 collar top
D19B_TOP    = 44.03;    // Ø19 collar top / rear journal start
BORE_D      = 10.0;     // rod clearance bore
SEAT_D      = 12.0;     // MR128 press seats
SEAT_FRONT  = 3.0;      // front seat depth
SEAT_REAR   = 2.7;      // rear seat depth

module shaft_bevel_gear() {
    intersection() {
        up(APEX_Z) zflip()
            bevel_gear(mod=BEVEL_MOD, teeth=BEVEL_TEETH,
                       mate_teeth=BEVEL_TEETH, face_width=FACE_W,
                       spiral=0, cutter_radius=0, slices=24, anchor="apex");
        union() {
            up(Z0) cyl(d=46, h=TRIM_Z[0] - Z0, anchor=BOTTOM);
            up(TRIM_Z[0]) cyl(d1=TRIM_D[0], d2=TRIM_D[1],
                              h=TRIM_Z[1] - TRIM_Z[0], anchor=BOTTOM);
            up(TRIM_Z[1]) cyl(d1=TRIM_D[1], d2=TRIM_D[2],
                              h=TRIM_Z[2] - TRIM_Z[1], anchor=BOTTOM);
        }
    }
}

module diff_gear_shaft() {
    difference() {
        union() {
            up(Z0) cyl(d=JOURNAL_D, h=FRONT_STEPS[0][0] - Z0, anchor=BOTTOM);
            up(FRONT_STEPS[0][0])
                cyl(d=FRONT_STEPS[0][1],
                    h=FRONT_STEPS[1][0] - FRONT_STEPS[0][0], anchor=BOTTOM);
            up(FRONT_STEPS[1][0])
                cyl(d=FRONT_STEPS[1][1], h=GEAR_Z0 - FRONT_STEPS[1][0],
                    anchor=BOTTOM);
            shaft_bevel_gear();
            up(BACK_CONE[0][0])
                cyl(d1=BACK_CONE[0][1], d2=BACK_CONE[1][1],
                    h=BACK_CONE[1][0] - BACK_CONE[0][0], anchor=BOTTOM);
            up(BACK_CONE[1][0])
                cyl(d=27.0, h=D27_TOP - BACK_CONE[1][0], anchor=BOTTOM);
            up(D27_TOP) cyl(d=25.0, h=D25_TOP - D27_TOP, anchor=BOTTOM);
            up(D25_TOP) linear_extrude(PULLEY_TOP - D25_TOP)
                gt2_pulley_teeth_2d();
            up(PULLEY_TOP) cyl(d=25.0, h=D25B_TOP - PULLEY_TOP, anchor=BOTTOM);
            up(D25B_TOP) cyl(d=19.0, h=D19B_TOP - D25B_TOP, anchor=BOTTOM);
            up(D19B_TOP) cyl(d=JOURNAL_D, h=Z1 - D19B_TOP, anchor=BOTTOM);
        }
        up(Z0 - epsilon) cyl(d=BORE_D, h=Z1 - Z0 + 2*epsilon, anchor=BOTTOM);
        up(Z0 - epsilon) cyl(d=SEAT_D, h=SEAT_FRONT + epsilon, anchor=BOTTOM);
        up(Z1 - SEAT_REAR) cyl(d=SEAT_D, h=SEAT_REAR + epsilon, anchor=BOTTOM);
    }
}

// Reference STL orientation: shaft axis along +Y.
xrot(-90) diff_gear_shaft();
