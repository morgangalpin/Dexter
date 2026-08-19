// #710-001 Split Gear Top — parametric source (DC-2).
// The differential's output bevel: the outer half of a 20T straight bevel
// crown, carried on a castellated cage whose windows clear the two side gears,
// over a bearing stack and three CF strake slots.
//
// Authored in the reference mesh's own coordinates (z -1.000 .. 24.410), so
// it compares to 710-001_SplitGearTop.stl without alignment.
//
// The reference is TWO unmerged solids (scadmesh segment): a cage body of
// 10895.311 mm³ meshed at 2.52 triangles/mm², and a bevel crown of
// 2844.032 mm³ at 6.69 — never merged, overlapping between z 15.448 and
// 18.100. They are measured separately here and unioned into one solid, which
// is why this file is built body-then-crown-then-cuts. That is also why the
// reference→candidate direction of `dist` is not meaningful against this
// file: it flags every surface buried in the overlap.
//
// Three of the reference's features lie inside that overlap, so the union this
// file renders cannot carry them and the checks report each as a miss. None of
// them is a defect to fix, because a solid has no interior faces:
//   z 15.448  the crown's back face, an annulus r 14.000 .. 14.890 standing
//             inside the cage wall, which runs r 14.000 .. 17.499 there;
//   z 17.840  BEVEL_HEEL_ROOT, where the teeth begin, at Ø36.709 inside the
//             Ø36.997 body; `compare` counts it twice, as a diameter and as a
//             plane;
//   z 18.100  the cage's top face, roofed over by the crown out to r 18.731
//             against the cage's own 18.497. This is the point `dist` reports
//             worst in the reference→candidate direction, and it lies 2.170 mm
//             from the Ø28 bore, the nearest surface this file does have.
//
// Two further "features" of the reference are its mesher's rather than the
// part's. The Ø32.488 band is an intermediate ring along the brad holes' axis,
// at depth |x| = 16.2366 -- 37 vertices on a Ø1.4986 circle centred at
// z 12.2486, which is the hole this file already states. Their distance from
// the part's axis varies across that circle, which spreads them over
// Ø32.473 .. 32.508 and reads as a diameter. The ladder of planes from
// z 18.358 to 20.391 is the tooth flanks' tessellation, which this file has no
// counterpart for: its teeth are ruled through the apex and carry no rings.
//
// `compare` therefore cannot be satisfied here at its default 0.001 mm
// tolerance, and no edit to this file would change that. Run against ITSELF
// with this part's ignore ranges the reference still fails, at 0.074 mm: the
// check bins vertex radii and measures their spacing rather than a dimension.
//
// Built in that order:
//   1. revolve the measured meridional profile   -> the cage, as a full ring
//   2. cut the windows, brad holes and strakes   -> the castellation
//   3. stand the shared crown on its ring        -> the bevel
//
// THE CROWN IS NOT DEFINED HERE. This part carries half of the differential's
// one bevel gear -- #710-002 Split Gear Bottom carries the other half, and the
// two side gears carry whole ones -- so the gear lives in diff_bevel.scad and
// this file supplies only two things: where its apex sits on this axis, and
// which side of the parting cone this half keeps. Sections of this mesh and of
// 720-002's, taken 15.4484 mm apart, agree to 0.0001 mm over 4088 points, which
// is what says the two are the same gear rather than two similar ones.
//
// The parting cone is the 45-degree BEVEL_SPLIT: everything outside it is this
// part, everything inside is 710-002, and the teeth run across it uninterrupted.
// That is why the two halves have to be clocked on assembly by driving brads
// through the four radial holes (008.6 steps 8-9) -- they are one set of teeth.
//
// Agreement, candidate→reference: see specs/009-Design-Completion.md § DC-2.

include <diff_bevel.scad>

/* [Hidden] */
Z_BASE = -1.000;    // base face, in the reference frame
Z_CAGE =  18.100;   // top face of the cage

// Where the gear's apex sits on this part's axis. Every conical surface of the
// crown follows from this one number and diff_bevel.scad; 710-002 states the
// same apex, which is what keeps the two halves on one cone.
BEVEL_APEX_Z = 39.5770;

function cone_pt(cone, z) = [bevel_r(cone, z - BEVEL_APEX_Z), z];
function bevel_pt(p)      = [p.x, p.y + BEVEL_APEX_Z];

// Meridional outline of the cage, measured (scadmesh profile), taken as a full
// ring: the windows are cut in step 2 rather than carried here. The profile
// arrives as two loops because its cutting plane is fixed on the x-z plane and
// a brad hole sits there, so the cage is severed at that angle between
// z 11.500 and 12.999; the two loops are rejoined along r = 14.000 and
// r = 17.500, which is what the sections either side of the gap measure.
BODY_PROFILE = [
    [ 5.994, -1.000],   // Ø12 MR128 seat, from the base
    [ 6.000,  3.000],
    [ 4.241,  3.000],   // step in to the Ø8.5 through-bore
    [ 4.241,  4.000],
    [11.500,  4.000],   // step out to the Ø23 6703 seat
    [11.490,  8.750],
    [11.942,  8.750],   // chamfer up into the Ø28 core cavity
    [11.977,  8.782],
    [12.100,  8.866],
    [12.235,  8.931],
    [12.377,  8.975],
    [12.525,  8.997],
    [13.998,  9.000],
    [14.000, 11.500],   // Ø28 cavity, straight to the top face
    [13.999, 18.100],
    [18.497, 18.100],   // cage top face
    [18.498, 17.000],
    [18.490, 17.000],
    [17.490, 16.010],   // chamfer down to the cage tube
    [17.500, 12.999],
    [17.500, 11.500],   // Ø35 cage tube, through the window band
    [17.490,  9.990],
    [18.490,  9.000],   // chamfer out to the code-disk stop collar
    [18.500,  9.000],
    [18.500,  8.000],
    [18.990,  8.000],   // Ø37.98 collar
    [18.990,  7.000],
    [18.500,  7.000],
    [18.500, -1.000],   // Ø37 body, down to the base
];

// The blank the teeth stand on. Only its Ø28 core is this part's own: the
// other three sides are the gear's heel, root and parting cones, so they are
// taken from diff_bevel.scad rather than restated as coordinates.
//
// Its back face at z 15.448 sits 24.129 mm below the apex -- the same plane, in
// the gear's frame, as 720-002's bottom face. The gear blank is the same on
// both parts; only what is hung under it differs.
CROWN_BACK_Z  = 15.448;
CROWN_CORE_R  = 14.000;     // Ø28 core cavity, carried up from BODY_PROFILE
CROWN_SPLIT_Z = bevel_z(BEVEL_SPLIT, CROWN_CORE_R) + BEVEL_APEX_Z;  // 21.000
CROWN_RING = [
    [CROWN_CORE_R, CROWN_BACK_Z],
    cone_pt(BEVEL_HEEL, CROWN_BACK_Z),      // out to the heel cone
    bevel_pt(BEVEL_HEEL_ROOT),              // up the heel to where teeth begin
    bevel_pt(BEVEL_SPLIT_ROOT),             // down the root to the parting cone
    [CROWN_CORE_R, CROWN_SPLIT_Z],          // in along the parting cone to Ø28
];

// Castellation, all measured. The windows are STRAIGHT SLOTS, not sectors:
// their walls run parallel to the slot centreline, 3.500 mm either side of it,
// which a radial wall does not do. Reading them as sectors put the wall 0.7 mm
// out at the bore. Width is a constant 7.000 mm at every height sampled
// between z 11.6 and 14.0, so the ends are square, and the top face sits
// between the sections at 14.48 (open) and 14.52 (closed).
WINDOW_W   = 7.000;
WINDOW_ANG = [45, 135, 225, 315];
WINDOW_Z   = [11.500, 14.500];

// The four narrow openings on the quadrants are not slots at all: they are the
// brad holes, drilled radially. Their width through the band is a circular
// chord -- 0.745, 1.193, 1.494, 1.017 mm at z 11.60, 11.80, 12.20, 12.80 --
// which fits a Ø1.497 hole on an axis at z = 12.250 to within 0.003 mm. That
// is the Ø1.5 brad 710-002 is drilled for, and the cage floor at z = 11.500
// falls tangent to the holes.
BRAD_D     = 1.497;
BRAD_ANG   = [0, 90, 180, 270];
BRAD_Z     = 12.250;

// #710-005 CF strakes, 5.6 x 2.5 mm in section, slotted from the base.
STRAKE    = [5.6, 2.5];
STRAKE_R  = [13.000, 15.500];   // measured inner and outer faces
STRAKE_ANG = [90, 210, 330];
STRAKE_TOP = 8.000;

// The bevel: the ring, plus this half's twenty teeth. BEVEL_ENVELOPE_OUTER is
// the whole-gear envelope with its toe-side face replaced by the parting cone,
// so what it keeps is exactly what 710-002's envelope does not.
module crown() {
    rotate_extrude() polygon(CROWN_RING);
    up(BEVEL_APEX_Z) bevel_crown(BEVEL_ENVELOPE_OUTER);
}

// The castellation, the brad holes and the strake slots. These cut the cage
// only, never the crown: the windows stop at z = 14.500 and the strakes at
// 8.000, while the crown ring starts at 15.448.
//
// Every tool here is a single primitive. Nothing in this module may be a
// module that is internally boolean -- BOSL2's pie_slice() and any of its
// rounded/chamfered relatives are. A difference nested inside a subtrahend
// cannot be normalized away: A - (B - C) becomes (A - B) | (A & C), so each
// one doubles the preview tree, and eight of them is 2^8. That is what was
// pushing this file past the normalizer's limit and emptying the preview,
// which is a GUI-only failure the F6 render never shows.
module cage_cuts() {
    for (a = WINDOW_ANG)
        zrot(a) up(WINDOW_Z[0])
            translate([12, -WINDOW_W / 2, 0])
                cube([9, WINDOW_W, WINDOW_Z[1] - WINDOW_Z[0]]);
    for (a = BRAD_ANG)
        zrot(a) up(BRAD_Z) yrot(90)
            cylinder(d = BRAD_D, h = 21);
    for (a = STRAKE_ANG)
        zrot(a - 90) up(Z_BASE - epsilon)
            translate([-STRAKE[0] / 2, STRAKE_R[0], 0])
                cube([STRAKE[0],
                      STRAKE_R[1] - STRAKE_R[0],
                      STRAKE_TOP - Z_BASE + epsilon]);
}

// Cut the cage BEFORE unioning the crown on, not after. Cutting afterwards is
// what the shape reads like and it renders correctly, but it will not preview:
// OpenCSG normalization distributes each cut across every term of the union,
// and the crown alone is twenty teeth, so the tree passes 200000 elements,
// normalization aborts, and the part disappears from the GUI until a full F6.
// Cutting the cage while it is still a single revolved solid keeps the
// difference at one term and leaves a plain union on top.
module split_gear_top() {
    union() {
        difference() {
            rotate_extrude() polygon(BODY_PROFILE);
            cage_cuts();
        }
        crown();
    }
}

split_gear_top();
