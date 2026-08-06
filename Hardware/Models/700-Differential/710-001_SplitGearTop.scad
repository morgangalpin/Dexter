// #710-001 Split Gear Top — parametric source (DC-2).
// The differential's output bevel gear (20T, meshing both input bevels at
// 90 deg). It spins on Diff Body B's stub: a 6703 in the Ø23 seat rides the
// Ø17 journal, an MR128 in the Ø12 seat rides the Ø8 shaft tip (008.6
// step 5). The Rotate Code Disk (#710-004) mounts over the Ø37 body. The
// cage windows expose the Split Gear Bottom's four brad holes; the four
// reamed side holes here carry the 1" #19 locking brads ~6 mm deep
// (008.6 steps 7-9). Three 25 mm CF strakes bridge into the Bottom
// through the base slots (step 11).
//
// Geometry solved from 710-001_SplitGearTop.stl (scadmesh slice sweeps).
// Tooth flanks are BOSL2 involute bevel teeth — verified by tooth count and
// OD rather than vertex match. This part carries the datum bevel OD,
// BEVEL_OD = 44.055 (the DC-11(f) check datum).

include <diff_params.scad>
include <BOSL2/gears.scad>

/* [Hidden] */
Z0          = -1.0;     // base face
Z_TOP       = 24.41;    // crown tip truncation plane
BODY_D      = 37.0;     // main body diameter
COLLAR      = [38.0, 7.0, 8.0];    // [Ø, z0, z1] code-disk stop collar
STEP_Z      = [8.759, 10.1];       // body -> cage tube chamfer
TUBE_D      = 35.0;     // cage tube outer diameter
CAGE_ID     = 28.0;     // core cavity diameter
WINDOW_Z    = [11.515, 14.5];      // cage window band
SLOT_Z      = [11.515, 12.969];    // brad-sight slot band (posts merge above)
WINDOW_A    = 26.2;     // window angular width, centered between quadrants
SLOT_A      = 5.8;      // sight slot angular width, centered on quadrants
RING_Z      = [15.45, 18.4];       // solid ring under the gear
SEAT_MR128  = 3.5;      // MR128 seat depth (Ø12 from the base)
SEAT_6703   = [3.9, 8.2];          // 6703 seat span (Ø23)
BORE_SMALL  = 8.5;      // through-bore between the two seats
GROOVE      = [[15.9, 28.0], [17.3, 35.06], [18.5, 28.0]];  // mesh clearance
CROWN_Z     = 21.0;     // gear body cut flat here; tooth toes stay proud
CROWN_D     = 32.2;     // crown pocket diameter
SG_APEX     = 39.52;    // bevel pitch-cone apex (virtual, above the part)
SG_FW       = 6.6;      // bevel face width
// Tooth envelope trim: rising to the Ø44.055 datum, then declining over
// the crown-prong region (traced from the reference).
TIP_TRIM    = [[18.0, 37.2], [20.4, 44.26], [21.9, 38.6], [24.5, 37.0]];
STRAKE_A    = [90, 210, 330];      // strake slot angles
STRAKE_R    = 14.25;    // strake slot center radius
STRAKE_TOP  = 7.5;      // strake slots reach up from the base
BRAD_R      = 15.67;    // brad hole circle radius
BRAD_HOLE_Z = [2.98, 8.98];        // reamed 6 mm deep from the cage floor

module split_gear_teeth() {
    intersection() {
        up(SG_APEX)
            bevel_gear(mod=BEVEL_MOD, teeth=BEVEL_TEETH,
                       mate_teeth=BEVEL_TEETH, face_width=SG_FW,
                       spiral=0, cutter_radius=0, slices=24, anchor="apex");
        union() {
            for (i = [0 : len(TIP_TRIM) - 2])
                up(TIP_TRIM[i][0])
                    cyl(d1=TIP_TRIM[i][1], d2=TIP_TRIM[i+1][1],
                        h=TIP_TRIM[i+1][0] - TIP_TRIM[i][0], anchor=BOTTOM);
        }
    }
}

module cage_cuts() {
    for (q = [45, 135, 225, 315])
        zrot(q) up(WINDOW_Z[0])
            pie_slice(ang=WINDOW_A, r=TUBE_D/2 + 1,
                      h=WINDOW_Z[1] - WINDOW_Z[0], spin=-WINDOW_A/2);
    for (q = [0, 90, 180, 270])
        zrot(q) up(SLOT_Z[0])
            pie_slice(ang=SLOT_A, r=TUBE_D/2 + 1,
                      h=SLOT_Z[1] - SLOT_Z[0], spin=-SLOT_A/2);
}

module split_gear_top() {
    difference() {
        union() {
            up(Z0) cyl(d=BODY_D, h=STEP_Z[0] - Z0, anchor=BOTTOM);
            up(COLLAR[1]) cyl(d=COLLAR[0], h=COLLAR[2] - COLLAR[1], anchor=BOTTOM);
            up(STEP_Z[0]) cyl(d1=BODY_D, d2=TUBE_D, h=STEP_Z[1] - STEP_Z[0],
                              anchor=BOTTOM);
            up(STEP_Z[1]) cyl(d=TUBE_D, h=RING_Z[0] - STEP_Z[1], anchor=BOTTOM);
            up(RING_Z[0]) cyl(d1=TUBE_D, d2=BODY_D, h=1.5, anchor=BOTTOM);
            up(RING_Z[0] + 1.5)
                cyl(d=BODY_D, h=RING_Z[1] - RING_Z[0] - 1.5, anchor=BOTTOM);
            split_gear_teeth();
        }
        // Bore ladder, bottom up: MR128 seat, through-bore, 6703 seat, cavity.
        up(Z0 - epsilon) cyl(d=BRG_MR128[1], h=SEAT_MR128 - Z0, anchor=BOTTOM);
        up(SEAT_MR128 - epsilon)
            cyl(d=BORE_SMALL, h=SEAT_6703[0] - SEAT_MR128 + 2*epsilon, anchor=BOTTOM);
        up(SEAT_6703[0]) cyl(d=BRG_6703[1], h=SEAT_6703[1] - SEAT_6703[0],
                             anchor=BOTTOM);
        // Seat lead-in chamfer (bearing press guide), then the cavity mouth.
        up(SEAT_6703[1] - epsilon)
            cyl(d1=BRG_6703[1], d2=25.12, h=STEP_Z[0] - SEAT_6703[1] + epsilon,
                anchor=BOTTOM);
        up(STEP_Z[0] - epsilon)
            cyl(d1=25.12, d2=CAGE_ID, h=8.98 - STEP_Z[0] + epsilon, anchor=BOTTOM);
        up(8.98 - epsilon)
            cyl(d=CAGE_ID, h=CROWN_Z - 8.98 + 2*epsilon, anchor=BOTTOM);
        // Mesh-clearance groove (input gear teeth sweep through here).
        up(GROOVE[0][0]) cyl(d1=GROOVE[0][1], d2=GROOVE[1][1],
                             h=GROOVE[1][0] - GROOVE[0][0], anchor=BOTTOM);
        up(GROOVE[1][0]) cyl(d1=GROOVE[1][1], d2=GROOVE[2][1],
                             h=GROOVE[2][0] - GROOVE[1][0], anchor=BOTTOM);
        // Crown pocket: the gear body is cut flat at CROWN_Z; the tooth
        // toes remain proud as 20 tapering prongs (code-disk end stop).
        up(CROWN_Z) cyl(d=CROWN_D, h=Z_TOP - CROWN_Z + 1, anchor=BOTTOM);
        // Truncate the crown tips flat.
        up(Z_TOP) cyl(d=50, h=3, anchor=BOTTOM);
        cage_cuts();
        for (a = STRAKE_A)
            zrot(a) right(STRAKE_R) up(Z0 - epsilon)
                cuboid([STRAKE_25[2], STRAKE_25[1], STRAKE_TOP - Z0],
                       anchor=BOTTOM);
        for (q = [0, 90, 180, 270])
            zrot(q) right(BRAD_R) up(BRAD_HOLE_Z[0])
                cyl(d=BRAD_D + 0.1, h=BRAD_HOLE_Z[1] - BRAD_HOLE_Z[0] + epsilon,
                    anchor=BOTTOM);
    }
}

split_gear_top();
