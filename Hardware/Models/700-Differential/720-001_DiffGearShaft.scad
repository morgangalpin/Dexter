// #720-001 Diff Gear Shaft — parametric source (DC-2).
// Input-B of the differential: a hollow shaft that spins in Diff Body B's
// two 6703 bearings (Ø17 end journals) while the CF rod (input A) runs
// through it on two MR128 bearings pressed into the Ø12 end seats
// (008.6 steps 4, 12, 21). Integrated on the shaft: a 20T bevel gear
// facing the Diff Gear Axle's bevel (both mesh the Split Gear at 90 deg)
// and a 40T GT2 pulley section for its drive belt.
//
// Body geometry solved from 720-001_DiffGearShaft.stl (scadmesh slice
// sweeps and vertex fits).
//
// The bevel is NOT this part's own reference tooth form. This shaft's crown
// is the previous revision of the gear the other three bevels share -- see
// diff_bevel.scad's header and 009 DC-2 for the measurement that found this
// and the decision that follows it. This file cuts the shaft to the shared
// crown instead, for a matched set of four: teeth mismatch the reference by
// up to ~0.17 mm on the flanks, logged as an explicit tolerance exception
// in 009, in exchange for one gear definition instead of two.
//
// What the shared crown does NOT excuse is the crown's ENVELOPE -- where the
// teeth start, stop and are trimmed. That belongs to this part, is measured
// on this part, and is stated below: a flat toe plane, a coaxial cut blunting
// the tips, and a 60-degree back cone that the teeth and the ring behind them
// share. Only the tip cut is compromised by the borrowed tooth form, and its
// own section says what was traded for what.
//
// The part is modeled with the shaft along +Z (z equals the reference
// mesh's y coordinate) and rotated into the reference orientation at the
// bottom of the file.

include <diff_bevel.scad>

/* [Reference detail] */
// Reproduce the twelve Ø0.2 through-holes the reference mesh carries (WALL
// HOLES below). They are real voids in the reference and unbuildable at that
// size; set false to render the shaft as a manufacturable part.
wall_holes = true;

/* [Hidden] */
Z0          = -10.96;   // shaft start (front journal end)
Z1          = 49.64;    // shaft end (rear journal end)
JOURNAL_D   = 17.0;     // 6703 inner-race journals, both ends
FRONT_STEPS = [[11.54, 19.0], [13.040, 23.0]];  // [z, Ø] steps before the gear
D27_D       = 27.0;     // collar behind the gear
D27_TOP     = 28.04;    // Ø27 section top
D25_TOP     = 34.04;    // Ø25 section top / pulley start
PULLEY_TOP  = 42.04;    // pulley section top
D25B_TOP    = 42.79;    // second Ø25 collar top
D19B_TOP    = 44.04;    // Ø19 collar top / rear journal start, rear 6703 face
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
// The value is stated in diff_bevel.scad with the other two apexes, so that
// diff_assembly.scad places this shaft from the same number this file builds
// the crown on.
BEVEL_APEX_Z = BEVEL_APEX_SHAFT;

// Rotational clocking: diff_bevel.scad centres a tooth on its own +x axis,
// which has no reason to line up with wherever this shaft's reference mesh
// happened to be exported. Measured directly at y = 17.0 (scadmesh slice,
// tip-land points within 0.05 mm of the section's max radius, clustered
// into 20 teeth): tooth centres sit at 8.97 deg mod the 18 deg pitch,
// constant across all 20 to +/-0.2 deg. Stated in diff_bevel.scad, because
// the assembly has to clock this gear against the other two from it.
BEVEL_PHASE = BEVEL_PHASE_SHAFT;

// ----------------------------------------------------------- this frame ----
// diff_bevel.scad states its cones in the gear's own frame: z = 0 at the
// apex, gear at negative z. crown() mirrors that frame onto this shaft, so
// each bevel cone has a counterpart here. Both are [r at the frame origin,
// dr/d(axis)]; shaft_cone() converts one to the other, and bevel_pt() maps
// a shaft-frame [r, z] point back for the envelope diff_bevel.scad wants.
function shaft_cone(c) = [c[0] + c[1] * BEVEL_APEX_Z, -c[1]];
function shaft_r(c, z) = c[0] + c[1] * z;
function shaft_z(c, r) = (r - c[0]) / c[1];
function shaft_meet(a, b) =
    let (z = (b[0] - a[0]) / (a[1] - b[1])) [shaft_r(a, z), z];
function bevel_pt(p) = [p.x, BEVEL_APEX_Z - p.y];

SHAFT_ROOT       = shaft_cone(BEVEL_ROOT);        // r = 0.84952 z - 0.54149
SHAFT_ROOT_UNDER = shaft_cone(BEVEL_ROOT_UNDER);  // the same, dropped 0.35
SHAFT_TIP        = shaft_cone(BEVEL_TIP);         // r = 1.14792 (z - 0.5065)

// THE BACK CONE. One 60-degree cone carries both the back face of the ring
// the teeth stand on AND the back face of every tooth: they are the same
// surface, which is why the reference shows no step between them. Fitted to
// the 853 mesh vertices that lie on it, r = 55.4982 - tan(60) z holds every
// one to 0.000014 mm, so the slope is the exact trigonometric value and only
// the intercept is data.
BACK_CONE = [55.4982, -tan(60)];

// THE TOE PLANE. The teeth are cut off square, on one plane normal to the
// axis, rather than on the 45-degree toe cone of a textbook bevel. Measured:
// the section at z = 13.45 is a clean Ø23.0 circle (fit rms 0.001) and the
// section at 13.50 already carries all 20 teeth; scadmesh fit puts the plane
// at 13.464 with 153.111 mm2 of face on it, and the 600 vertices sitting on
// it run from r = 11.5000 (the Ø23 land) out to 15.3345 (this part's own
// face cone). The teeth's front faces therefore stand on the Ø23 cylinder,
// and the Ø19->Ø23 step is 0.424 mm ahead of them at 13.040.
TOE_PLANE = 13.4643;

// THE TIP CYLINDER. Where the face cone and the back cone would cross in a
// sharp circular edge, the reference has a cylindrical land instead: one
// turned cut, coaxial with the shaft, blunting all 20 tips together. Measured
// on the reference, it is 160 vertices at r = 21.7500 exactly (Ø43.500), and
// the surface says the same as the vertices: sectioned every few hundredths
// through the feature, the largest loop radius reads 21.75000 unchanged from
// z 18.90 to 19.48 and falls away on the face cone below and the back cone
// above, putting the cut's two edges at z 18.8855 and 19.4845. The land it
// leaves on each tooth is a trapezoid, 1.298 mm across the toe edge and
// 1.835 mm across the heel edge; its axial span is that 0.5990 and its two
// sloping side edges measure 0.6564 mm, the flanks carrying the difference.
//
// THE CUT DIAMETER AND THE LAND CANNOT BOTH BE HELD, and this file holds the
// land. The reference's own teeth stand on a 1.18343 face cone and reach
// Ø44.300 before the cut, so turning them to Ø43.500 takes 0.40 mm off the
// radius and opens that 0.5990 mm land. The shared crown's face cone is the
// shallower 1.14792 (diff_bevel.scad's header), so its teeth run roughly
// 0.6 mm shorter in radius and cross the back cone at Ø43.5424 unaided; the
// same Ø43.500 cut would take 0.0212 mm off them and leave a land of 0.0307,
// z 19.4538 .. 19.4845 -- sharp tips with a diameter that happens to match.
//
// THE BLUNTING IS THE FEATURE AND THE DIAMETER IS NOT. A tip land exists to
// keep a knife edge off the tooth: it carries the burr, the chipped corner and
// the stress riser out of the part, and being clearance over the mating root
// rather than a meshing surface, its diameter is free where its existence is
// not. Ø43.500 is the size that opened a 0.5990 mm land on the tooth form the
// reference was cut with. That tooth form is superseded -- the shared crown is
// the design of record and this part's departure from the reference's own is
// already a stated exception (009 DC-2, CR-3A7) -- so carrying the old
// diameter onto the new form reproduces the number and discards the thing the
// number was for. The wider blunt is preferred to the closer match: this file
// cuts to the land at r = 21.3577 (Ø42.7153), taking a comparable 0.414 mm off
// the radius where the reference took 0.400. Solving it from the land rather
// than typing a diameter also keeps the blunt right if either cone is ever
// re-measured, which typing Ø43.500 would not.
//
// The cost is stated rather than hidden. This part's OD becomes Ø42.7153
// against the reference's Ø43.500, 0.785 mm under on its largest dimension,
// and measured against the reference mesh the bounding box comes in 0.768 mm
// short -- not 0.785, because the gear's transverse extent is set by the land
// corners of the tooth nearest the axis rather than by the tip cylinder
// itself. That term is deliberate, and it is why render-all.rs gives 720-001
// the loosest tolerance of the seven with the bbox check named in its comment.
// Holding the diameter instead scores 0.047 mm there, and two-sided surface
// distance is 0.568 mm outward either way against 0.456 inward rather than
// 0.429. Those numbers say the diameter matches the older part better, which
// is not in dispute and is not what is being chosen. The pair is unaffected
// either way: the tip land does not mesh. See 009 DC-2 and CR-3A7, which
// adjudicated it this way.
TIP_LAND = 0.5990;      // axial span of the land, measured on the reference

// Where a coaxial cut must sit for the face cone and the back cone to leave a
// land this wide between them.
function cut_r_for_land(land) =
    (land + BACK_CONE[0] / BACK_CONE[1] - SHAFT_TIP[0] / SHAFT_TIP[1])
    / (1 / BACK_CONE[1] - 1 / SHAFT_TIP[1]);

TIP_R = cut_r_for_land(TIP_LAND);

assert(abs((shaft_z(BACK_CONE, TIP_R) - shaft_z(SHAFT_TIP, TIP_R)) - TIP_LAND)
       < 1e-6, "the tip cut does not leave the land it was solved for");
assert(TIP_R < shaft_meet(BACK_CONE, SHAFT_TIP).x,
       "the tip cut is outside where the face and back cones cross: no land");

// ------------------------------------------------------------- envelope ----
// The crown, bounded by this part's own surfaces: square across the toe,
// out to the tip cylinder, back down the back cone, and closed along the
// root cone dropped under (BEVEL_ROOT_UNDER -- see diff_bevel.scad for why
// the teeth must be buried in the blank rather than share a face with it).
CROWN_TOE_ROOT = [shaft_r(SHAFT_ROOT_UNDER, TOE_PLANE), TOE_PLANE];
CROWN_HEEL     = shaft_meet(BACK_CONE, SHAFT_ROOT_UNDER);
CROWN_TIP_BACK = [TIP_R, shaft_z(BACK_CONE, TIP_R)];

CROWN_ENVELOPE = [
    bevel_pt(CROWN_TOE_ROOT),
    bevel_pt(CROWN_HEEL),
    bevel_pt(CROWN_TIP_BACK),
    bevel_pt([TIP_R, TOE_PLANE]),
];

assert(CROWN_TIP_BACK.y > TOE_PLANE && CROWN_HEEL.y > CROWN_TIP_BACK.y,
       "the toe plane, tip cylinder and back cone do not stack up the shaft");

module crown() {
    up(BEVEL_APEX_Z) zrot(BEVEL_PHASE) mirror([0, 0, 1])
        bevel_crown(CROWN_ENVELOPE);
}

// ------------------------------------------------------------------ hub ----
// Everything the crown stands on, from the Ø23 step to the Ø27 collar: the
// Ø23 land ahead of the teeth, the shared root cone under them, the back
// cone behind them, and the fillet that lands the back cone on Ø27.
//
// THE FILLET. R2.000 exactly -- fitted to the 463 mesh vertices between the
// back cone and Ø27 with rms 0.00000 mm, the radius free. It is tangent to
// both, so neither tangent point is typed: the centre follows from the two
// surfaces and the radius alone.
FILLET_R  = 2.0;
D23_R     = FRONT_STEPS[1][1] / 2;
D27_R     = D27_D / 2;

FILLET_CP = [D27_R + FILLET_R,
             (BACK_CONE[0] - D27_R - FILLET_R
              + FILLET_R * norm([1, BACK_CONE[1]])) / -BACK_CONE[1]];
FILLET_N  = [1, -BACK_CONE[1]] / norm([1, BACK_CONE[1]]);
FILLET_T  = FILLET_CP - FILLET_R * FILLET_N;    // tangent on the back cone
FILLET_A0 = atan2(FILLET_T.y - FILLET_CP.y, FILLET_T.x - FILLET_CP.x);

assert(abs(shaft_r(BACK_CONE, FILLET_T.y) - FILLET_T.x) < 1e-6,
       "the fillet's tangent point is not on the back cone");

// 24 steps put the drawn polyline 0.0004 mm inside the arc, an order under
// the 0.006 mm the tooth flank itself carries.
FILLET_STEPS = 24;
function fillet_arc(steps) =
    [ for (i = [0 : steps])
        let (a = FILLET_A0 + (-180 - FILLET_A0) * i / steps)
            FILLET_CP + FILLET_R * [cos(a), sin(a)] ];

// The Ø23 land runs to wherever the root cone under the teeth climbs out of
// it, which for the shared crown is 14.175. This part's own root cone leaves
// the land at 13.660 instead: the shared crown's root sits 0.40 mm below it
// (their apexes differ -- diff_bevel.scad's header), so the land overruns by
// 0.51 mm. That is the one place this hub is not an exact reference
// measurement, and it follows from the crown swap rather than from the
// envelope this file measures.
HUB_PROFILE = concat(
    [[0, FRONT_STEPS[1][0]],
     [D23_R, FRONT_STEPS[1][0]],
     [D23_R, shaft_z(SHAFT_ROOT, D23_R)],       // onto the shared root cone
     shaft_meet(BACK_CONE, SHAFT_ROOT)],        // root meets the back cone
    fillet_arc(FILLET_STEPS),                   // back cone, then the fillet
    [[D27_R, D27_TOP],
     [0, D27_TOP]]
);

module gear_hub() {
    rotate_extrude() polygon(HUB_PROFILE);
}

// ------------------------------------------------------------ wall holes ----
// Twelve Ø0.2 holes on a Ø15.5 circle, 30 deg apart with one on +x, running
// the whole 60.6 mm of the part. They are voids, not slivers: every one of
// the 3864 triangles around a single hole has its normal pointing at that
// hole's own axis, the lateral area over any span matches pi*0.2*span to
// three decimals, and the mesh stays one closed manifold with them in it.
// They sit in the wall between the Ø10 bore and the Ø17 journal and clear
// both everywhere along the shaft.
//
// Nothing in the differential uses them and nothing can make them: Ø0.2 by
// 60.6 mm is 303:1, past drilling and far past printing. No other part in
// the reference set carries anything like them. They are reproduced because
// they are in the reference, behind `wall_holes` so the buildable shaft is
// one flag away -- see 009 DC-2 for the adjudication.
WALL_HOLE_D   = 0.2;
WALL_HOLE_PCD = 15.5;
WALL_HOLE_N   = 12;

module wall_hole_cuts() {
    zrot_copies(n = WALL_HOLE_N)
        right(WALL_HOLE_PCD / 2)
            up(Z0 - epsilon)
                cyl(d = WALL_HOLE_D, h = Z1 - Z0 + 2 * epsilon,
                    anchor = BOTTOM, $fn = 48);
}

// ----------------------------------------------------------------- part ----
// Every stacked section reaches `epsilon` into its neighbour rather than
// butting against it. At each joint the intruding section is the smaller
// diameter, so the overlap is buried and changes no surface -- but it leaves
// the union with volume to work on instead of a shared face. Butting was
// tolerated while the shaft was solid; with the wall holes cutting through
// them, the coincident faces at D27_TOP came back from CGAL as 936 edges
// carrying four triangles each and a mesh that was not closed.
module diff_gear_shaft() {
    difference() {
        union() {
            up(Z0) cyl(d=JOURNAL_D,
                       h=FRONT_STEPS[0][0] - Z0 + epsilon, anchor=BOTTOM);
            up(FRONT_STEPS[0][0])
                cyl(d=FRONT_STEPS[0][1],
                    h=FRONT_STEPS[1][0] - FRONT_STEPS[0][0] + epsilon,
                    anchor=BOTTOM);
            gear_hub();
            crown();
            up(D27_TOP - epsilon)
                cyl(d=25.0, h=D25_TOP - D27_TOP + epsilon, anchor=BOTTOM);
            up(D25_TOP - epsilon)
                linear_extrude(PULLEY_TOP - D25_TOP + 2*epsilon)
                    gt2_pulley_teeth_2d();
            up(PULLEY_TOP) cyl(d=25.0, h=D25B_TOP - PULLEY_TOP, anchor=BOTTOM);
            up(D25B_TOP - epsilon)
                cyl(d=19.0, h=D19B_TOP - D25B_TOP + epsilon, anchor=BOTTOM);
            up(D19B_TOP - epsilon)
                cyl(d=JOURNAL_D, h=Z1 - D19B_TOP + epsilon, anchor=BOTTOM);
        }
        up(Z0 - epsilon) cyl(d=BORE_D, h=Z1 - Z0 + 2*epsilon, anchor=BOTTOM);
        up(Z0 - epsilon) cyl(d=SEAT_D, h=SEAT_FRONT + epsilon, anchor=BOTTOM);
        up(Z1 - SEAT_REAR) cyl(d=SEAT_D, h=SEAT_REAR + epsilon, anchor=BOTTOM);
        if (wall_holes) wall_hole_cuts();
    }
}

// Reference STL orientation: shaft axis along +Y.
xrot(-90) diff_gear_shaft();
