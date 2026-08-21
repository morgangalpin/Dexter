// 700-Differential shared bevel crown — one 20-tooth straight bevel, carried
// by three parts (DC-2).
//
// #710-001 Split Gear Top and #710-002 Split Gear Bottom are one gear sawn in
// half along a 45-degree cone; #720-002 Diff Gear Axle carries a whole one. The
// tooth is defined once here and each part intersects it with its own envelope,
// which is also what guarantees they mesh: they cannot drift apart in edit.
//
// #720-001 Diff Gear Shaft is the differential's third bevel and is NOT covered
// by this file. It carries the PREVIOUS revision of this gear: the one the v1
// design used for all four bevels, which the other three parts were cut to and
// it was not. Both are 20T, and at a matched height their root radii agree to
// 0.03 mm, which is why the difference is easy to miss.
//
// The tip cone settles it. #720-001's top land runs at r = 1.18343 (y - 0.5068),
// fitted over five sections a millimetre apart and constant to 1e-5 in slope. The
// v1 STEP files state that cone exactly -- one CONICAL_SURFACE of semi-angle
// 49.80181717642289 deg, slope 1.1834163, apex 0.5064895 -- and state the SAME
// one in all four gears: KP0086 Outter Front, KP0087 and KP0092 Side, KP0088
// Inner Front. #720-001's mesh reproduces it to 1.4e-5 in slope and 0.0004 mm in
// apex. This gear's face cone is 1.14792, a 48.94 deg half-angle that appears in
// no v1 file, and #710-002 and #720-002 measure 1.1478 independently.
//
// The root cones part company the same way: #720-001 runs r = 0.84175 y with its
// apex on the origin (constant to 1e-4 over y 15..19), this gear 0.84952 with the
// apex 0.131 mm beyond the face apex.
//
// What that costs, measured rather than inferred: sections of #720-001 and
// #720-002 taken anywhere in the tooth zone, best-fitted for scale, clocking and
// hand, leave 0.64 mm max and 0.16 mm rms -- against 0.0000 mm for #710-001
// against #720-002. Restricted to the flanks alone it is 0.171 max, 0.083 rms;
// the root land carries the rest, being the narrower of the two. So the pair
// still meshes, but on a tooth form one revision behind. See DC-2 for the
// decision that follows. Do not assume this file describes it.
//
// That is measured, not assumed. Sections of #710-001 and of #720-002 taken at
// matching heights (z 21.500 and 6.052, a 15.4484 mm shift) return outlines
// 0.0001 mm apart over 4088 sample points, with the teeth already clocked
// alike; the same sections of #710-002 supply exactly the material inside the
// 45-degree cone that #710-001 lacks, its area agreeing with #720-002's to
// 0.007 mm^2 in 858. Every cone below was fitted on #720-002 and every fit is
// exact to the printed digits over six heights.
//
// FRAME. Everything here is stated in the gear's own frame: z = 0 at the gear
// apex, the gear standing at negative z, one tooth centred on the +x axis.
// A part positions it by translating its own apex height; nothing else about
// the part reaches into this file.
//
// FOUR CONES define the whole crown, and their six intersections define every
// edge of it, so no corner coordinate is typed twice:
//
//   face (tip)  r = -1.14792 z              apex on the axis, 48.943 deg
//   root        r = -0.11121 - 0.84952 z    apex 0.131 mm below, 40.360 deg
//   heel        r = 49.82164 + 1.44761 z    the back face at the large end
//   inner       r =  26.2240 + z            45 deg, the toe-side tooth face
//
// The pitch cone is the 45-degree r = -z, which is what a 1:1 pair at 90
// degrees must have; the face cone's apex sits on it exactly, and the root
// cone's 0.131 mm offset is the usual tilted root line.
//
// THE TOOTH IS RULED THROUGH THE APEX, so one section reproduces all of it:
// scaling a section about the axis by z1/z0 is exactly the surface between the
// two heights, which linear_extrude(scale=) draws with no approximation and no
// facets across the flank. The apex was measured, not taken from the cones:
// scaling a section at one height onto a measured section at another and
// minimising the mismatch puts it at z = 0 to within 0.02 mm on two
// independent pairs of heights, each agreeing to 0.002 mm.
//
// The flank itself is a single cubic Bezier through four control points. It was
// fitted to 253 measured points -- the median over 9 heights x 20 teeth, each
// scaled back to the section height, which agree among themselves to 0.002 mm
// -- and it holds them to 0.006 mm max, 0.003 rms. A gear tooth flank has no
// closed form in this plane, so it is measured; but it is a cubic to well
// inside a hundredth of a millimetre, and saying so costs four points instead
// of the several hundred a polyline needs.

include <diff_params.scad>

/* [Hidden] */

// ---------------------------------------------------------------- cones ----
// Each cone is [r at z = 0, dr/dz]. Radius grows downward, so the three that
// open away from the apex carry a negative slope.
BEVEL_TIP   = [ 0.00000, -1.14792];
BEVEL_ROOT  = [-0.11121, -0.84952];
BEVEL_HEEL  = [49.82164,  1.44761];
BEVEL_INNER = [26.22400,  1.00000];
BEVEL_PITCH = [ 0.00000, -1.00000];

// The 45-degree cone the Split Gear is parted on. It belongs to that pair
// rather than to the gear, but it is stated here with the others because it is
// what makes 710-001 and 710-002 halves of one crown.
BEVEL_SPLIT = [32.57700,  1.00000];

function bevel_r(cone, z) = cone[0] + cone[1] * z;
function bevel_z(cone, r) = (r - cone[0]) / cone[1];

// ---------------------------------------------------------------- apexes ----
// Where this crown's apex sits on each carrying part's own axis, and how the
// shaft's copy is clocked. The apex IS the gear's placement: every cone above
// is stated in the gear's own frame, so a part positions the gear by stating
// this one number, and diff_assembly.scad positions the PART by putting that
// same point on the differential centre.
//
// They are stated here, with the gear, for two reasons. The Split Gear's two
// halves are one gear and must not drift apart, and one number they both read
// is what guarantees it. And `use <part.scad>` imports a file's modules and
// functions but NONE of its variables, so an apex left in a part file is
// unreachable from the assembly and would have to be typed there a second time.
//
// How each was measured stays in the part that owns it -- 720-001's in
// particular, whose frame is mirrored, and whose phase is the one clocking
// measurement in the set.
BEVEL_APEX_SPLIT  = 39.5770;    // 710-001 and 710-002: one gear, one apex
BEVEL_APEX_AXLE   = 24.1286;    // 720-002
BEVEL_APEX_SHAFT  =  0.5065;    // 720-001, mirrored frame -- see that file
BEVEL_PHASE_SHAFT =  8.9722;    // 720-001's tooth centres, mod the pitch
BEVEL_PITCH_ANG   = 360 / BEVEL_TEETH;      // 18 degrees

// Where two cones meet, as the [r, z] a revolved profile wants.
function bevel_meet(a, b) =
    let (z = (b[0] - a[0]) / (a[1] - b[1])) [bevel_r(a, z), z];

// The root cone dropped 0.35 mm inward. An envelope bounded by the root cone
// itself would cut the teeth off on exactly the surface the blank they stand on
// ends at, and a shared face is not a join: CGAL returns the teeth as twenty
// separate solids, the blank's top face survives the union underneath them, and
// the export carries interior surface that measures over a millimetre from
// anything real. Bounding on this cone instead buries the teeth in the blank.
BEVEL_ROOT_UNDER = [BEVEL_ROOT[0] - 0.35, BEVEL_ROOT[1]];

BEVEL_HEEL_ROOT  = bevel_meet(BEVEL_HEEL,  BEVEL_ROOT);   // teeth begin
BEVEL_HEEL_TIP   = bevel_meet(BEVEL_HEEL,  BEVEL_TIP);    // crown ring, sharp
BEVEL_INNER_TIP  = bevel_meet(BEVEL_INNER, BEVEL_TIP);    // the tooth's toe
BEVEL_INNER_ROOT = bevel_meet(BEVEL_INNER, BEVEL_ROOT);   // teeth stand free
BEVEL_SPLIT_ROOT = bevel_meet(BEVEL_SPLIT, BEVEL_ROOT);
BEVEL_SPLIT_TIP  = bevel_meet(BEVEL_SPLIT, BEVEL_TIP);

// The crown ring is truncated to BEVEL_OD rather than run out to where the
// heel and face cones would cross. Both references measure their widest point
// at Ø44.055 while the cones cross at Ø44.069, so the edge carries a 0.007 mm
// break; modelling the datum reproduces it and keeps the one specified
// diameter in charge of the part's size.
BEVEL_RING_R = BEVEL_OD / 2;
BEVEL_RING   = [[BEVEL_RING_R, bevel_z(BEVEL_HEEL, BEVEL_RING_R)],
                [BEVEL_RING_R, bevel_z(BEVEL_TIP,  BEVEL_RING_R)]];
assert(BEVEL_RING[0].y < BEVEL_RING[1].y,
       "BEVEL_OD is past where the heel and face cones cross");
assert(abs(BEVEL_HEEL_TIP.x - BEVEL_RING_R) < 0.02,
       "BEVEL_OD disagrees with the fitted heel and face cones");

// ---------------------------------------------------------------- tooth ----
// One tooth's cross-section, measured at 18 mm below the apex. Only the flank
// is data: the tip land is the face cone and the foot is a buried tail, both
// computed. The tail continues the flank's own line 0.45 mm inside the root
// cone, so that the tooth is always either buried in the blank it stands on or
// clipped by the envelope, and never leaves a seam at the root. 0.45 rather
// than a whisker: 720-002's hub is undercut to 0.29 mm inside the root cone
// where the teeth break free of it, and a shallower tail stands proud of that
// undercut by 0.135 mm.
BEVEL_SECTION_Z = -18.000;
BEVEL_R_TIP     = bevel_r(BEVEL_TIP,  BEVEL_SECTION_Z);
BEVEL_R_ROOT    = bevel_r(BEVEL_ROOT, BEVEL_SECTION_Z);
BEVEL_TIP_HALF  = 1.95204;      // half the tip land, in degrees; constant on
                                // every height sampled, to 0.0009 deg
BEVEL_FLANK = [                 // cubic Bezier, root end first
    [15.8400, 1.5755],
    [17.4508, 1.6196],
    [19.1272, 1.1724],
    [20.6506, 0.7038],
];
BEVEL_FOOT  = [14.6576, 1.4592];    // buried, on the flank's own line

assert(abs(norm(BEVEL_FLANK[3]) - BEVEL_R_TIP) < 0.002,
       "the flank does not end on the face cone");
assert(norm(BEVEL_FOOT) < BEVEL_R_ROOT - 0.40,
       "the tooth's foot is not buried deep enough under the root cone");

// Half the outline, foot first, tip corner last. Twelve steps put the drawn
// polyline 0.001 mm inside the Bezier at worst, which is well under the
// 0.006 mm the Bezier itself sits from the measurements.
BEVEL_STEPS = 12;

function bevel_half(steps) =
    concat([BEVEL_FOOT], bezier_curve(BEVEL_FLANK, splinesteps = steps));

// The tip land, interior points only: its ends are the flanks' last points.
function bevel_tip_land(steps) =
    [ for (i = [1 : steps - 1])
        let (a = BEVEL_TIP_HALF * (2 * i / steps - 1))
            BEVEL_R_TIP * [cos(a), sin(a)] ];

// The closed section, counter-clockwise: up the -y flank, across the tip land,
// down the +y flank, and closed by a chord across the buried foot.
function bevel_section(steps = BEVEL_STEPS, tip_steps = 4) =
    let (half = bevel_half(steps))
    concat([ for (p = half) [p.x, -p.y] ],
           bevel_tip_land(tip_steps),
           reverse(half));

// One tooth between two heights. Scaling by z1/z0 IS the ruled surface through
// the apex, so this is exact wherever the tooth is a tooth; the ends are meant
// to overrun the envelope, which trims them back to the cones.
module bevel_tooth(z0, z1, steps = BEVEL_STEPS) {
    assert(z0 < z1 && z1 < 0, "bevel_tooth wants z0 < z1 < 0, below the apex");
    up(z0) linear_extrude(height = z1 - z0, scale = z1 / z0, convexity = 6)
        scale(z0 / BEVEL_SECTION_Z) polygon(bevel_section(steps));
}

BEVEL_Z_HEEL = BEVEL_HEEL_ROOT.y - 0.5;     // overrun, both ends
BEVEL_Z_TOE  = BEVEL_INNER_TIP.y + 0.5;

module bevel_teeth(z0 = BEVEL_Z_HEEL, z1 = BEVEL_Z_TOE, steps = BEVEL_STEPS) {
    zrot_copies(n = BEVEL_TEETH) bevel_tooth(z0, z1, steps);
}

// A crown: the teeth, trimmed to whatever envelope the part bounds them with.
// Keep this a plain intersection of single-leaf children -- an envelope that
// is itself a difference cannot be normalized away and will empty the preview.
module bevel_crown(envelope, steps = BEVEL_STEPS) {
    intersection() {
        rotate_extrude() polygon(envelope);
        bevel_teeth(steps = steps);
    }
}

// ------------------------------------------------------------ envelopes ----
// A whole gear: the teeth run from the heel plane to the toe, bounded outside
// by the heel cone and the face cone and inside by the 45-degree inner face.
BEVEL_ENVELOPE = [
    [bevel_r(BEVEL_INNER, BEVEL_HEEL_ROOT.y), BEVEL_HEEL_ROOT.y],
    BEVEL_HEEL_ROOT,
    BEVEL_RING[0],
    BEVEL_RING[1],
    BEVEL_INNER_TIP,
];

// The Split Gear's two halves, parted on BEVEL_SPLIT: the top half keeps what
// lies outside that cone, the bottom half what lies inside it.
BEVEL_ENVELOPE_OUTER = [
    [bevel_r(BEVEL_SPLIT, BEVEL_HEEL_ROOT.y), BEVEL_HEEL_ROOT.y],
    BEVEL_HEEL_ROOT,
    BEVEL_RING[0],
    BEVEL_RING[1],
    BEVEL_SPLIT_TIP,
];
BEVEL_ENVELOPE_INNER = [
    bevel_meet(BEVEL_SPLIT, BEVEL_ROOT_UNDER),
    BEVEL_SPLIT_TIP,
    BEVEL_INNER_TIP,
    bevel_meet(BEVEL_INNER, BEVEL_ROOT_UNDER),
];

echo(str("diff_bevel: ", BEVEL_TEETH, "T, ring Ø", BEVEL_OD,
         " at z ", BEVEL_RING[0].y, ", teeth ", BEVEL_HEEL_ROOT.y,
         " .. ", BEVEL_INNER_TIP.y));
