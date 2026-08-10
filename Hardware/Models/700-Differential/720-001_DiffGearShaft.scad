// #720-001 Diff Gear Shaft — parametric source (DC-2).
// Input-B of the differential: a hollow shaft that spins in Diff Body B's
// two 6703 bearings (Ø17 end journals) while the CF rod (input A) runs
// through it on two MR128 bearings pressed into the Ø12 end seats
// (008.6 steps 4, 12, 21). Integrated on the shaft: a 20T bevel gear
// facing the Diff Gear Axle's bevel (both mesh the Split Gear at 90 deg)
// and a 40T GT2 pulley section for its drive belt.
//
// Body geometry solved from 720-001_DiffGearShaft.stl (scadmesh slice
// sweeps). The reference mesh contains a degenerate internal Ø15.5 shell
// (an export artifact, visible as Ø0.2 sliver loops in every cross-section);
// it is intentionally not reproduced.
//
// The bevel is NOT this part's own reference tooth form. This shaft's crown
// is the previous revision of the gear the other three bevels share -- see
// diff_bevel.scad's header and 009 DC-2 for the measurement that found this
// and the decision that follows it. This file cuts the shaft to the shared
// crown instead, for a matched set of four: teeth mismatch the reference by
// up to ~0.17 mm on the flanks, logged as an explicit tolerance exception
// in 009, in exchange for one gear definition instead of two.
//
// The part is modeled with the shaft along +Z (z equals the reference
// mesh's y coordinate) and rotated into the reference orientation at the
// bottom of the file.

include <diff_bevel.scad>

/* [Hidden] */
Z0          = -10.96;   // shaft start (front journal end)
Z1          = 49.64;    // shaft end (rear journal end)
JOURNAL_D   = 17.0;     // 6703 inner-race journals, both ends
FRONT_STEPS = [[11.54, 19.0], [13.46, 23.0]];  // [z, Ø] steps before the gear
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

// Where the shared crown's apex sits on this shaft's own axis. Measured
// directly on this part's mesh: the top-land (face) cone fitted from
// eight consecutive one-degree-apart sections (y 14.5..18.5, scadmesh
// apex) gives r = 1.18342 (y - 0.5065), constant to five decimals pair to
// pair, and agrees with the v1 STEP CONICAL_SURFACE apex (0.5064895,
// see diff_bevel.scad's header) to 0.0001 mm. Unlike 720-002, this
// shaft's own face and root cones both carry a POSITIVE slope in y (the
// gear stands at y > apex, not y < apex as diff_bevel.scad's own frame
// has it) -- the two facing bevels were exported in mirrored senses, so
// the shared crown is placed mirrored below rather than plain up().
BEVEL_APEX_Z = 0.5065;

// Rotational clocking: diff_bevel.scad centres a tooth on its own +x axis,
// which has no reason to line up with wherever this shaft's reference mesh
// happened to be exported. Measured directly at y = 17.0 (scadmesh slice,
// tip-land points within 0.05 mm of the section's max radius, clustered
// into 20 teeth): tooth centres sit at 8.97 deg mod the 18 deg pitch,
// constant across all 20 to +/-0.2 deg.
BEVEL_PHASE = 8.9722;

function cone_pt(cone, y) = [bevel_r(cone, BEVEL_APEX_Z - y), y];
function bevel_pt(p)      = [p.x, BEVEL_APEX_Z - p.y];

module crown() {
    up(BEVEL_APEX_Z) zrot(BEVEL_PHASE) mirror([0, 0, 1]) bevel_crown(BEVEL_ENVELOPE);
}

// Hub between the front journal stack and the back cone: the true root
// cone, straight from the toe-root corner (bevel_pt(BEVEL_INNER_ROOT)) to
// the heel-root corner (bevel_pt(BEVEL_HEEL_ROOT)) -- teeth can reach all
// the way to the heel-root corner, so the hub must cover that whole run or
// leave a gap under them near the back edge. Past the heel-root corner the
// profile drops straight to the axis rather than angling back to the
// measured back cone's own (smaller, closer) start point: the two profiles
// would otherwise cross themselves at y = 21.7 (both edges of the polygon
// pass through the same y at different radii, self-intersecting rather
// than forming a simple closed curve). Ending square instead leaves a
// harmless overlap with the back cone's own frustum over the 0.5 mm they
// share, and a similarly small radial step where the two don't line up --
// preferred over rehandling the tighter miter, which does not affect the
// tooth region. The short run from the old Ø23 journal step (13.46) up
// onto the cone (14.745) is the one place this hub is not an exact
// reference measurement, an unavoidable consequence of grafting the shared
// crown onto this shaft's own body.
GEAR_HUB_HEEL = bevel_pt(BEVEL_HEEL_ROOT);
GEAR_HUB_PROFILE = [
    [0.000, 13.460],
    [11.500, 13.460],                  // FRONT_STEPS[1] end
    bevel_pt(BEVEL_INNER_ROOT),        // onto the shared root cone
    GEAR_HUB_HEEL,                     // heel-root corner -- covers the teeth fully
    [0.000, GEAR_HUB_HEEL.y],
];

module gear_hub() {
    rotate_extrude() polygon(GEAR_HUB_PROFILE);
}

module diff_gear_shaft() {
    difference() {
        union() {
            up(Z0) cyl(d=JOURNAL_D, h=FRONT_STEPS[0][0] - Z0, anchor=BOTTOM);
            up(FRONT_STEPS[0][0])
                cyl(d=FRONT_STEPS[0][1],
                    h=FRONT_STEPS[1][0] - FRONT_STEPS[0][0], anchor=BOTTOM);
            gear_hub();
            crown();
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
