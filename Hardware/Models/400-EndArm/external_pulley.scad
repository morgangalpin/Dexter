// The External pulleys' shared definition: #430-001 External Outer Pulley and
// #430-002 External Inner Pulley, the driven pulleys of the wrist's stage 1
// (specs/004 § Wrist and differential). Each part file includes this one.
//
//   config = "previous" — the previous version's 90T pulley, the reference
//                         mesh unchanged.
//   config = "revised"  — the 108T pulley of the 16T -> 108T stage (DC-12):
//                         the reference's hub, spokes and set-screw work kept
//                         inside R_CUT, and a new 108T GT2 rim outside it.
//
// The rim keeps the reference's axial stations. Its flanges and chamfers are
// stated as offsets over the tooth tip, measured on the 90T reference
// (scadmesh profile), so they stand the same height over the 108T tip as they
// did over the 90T one.

include <../gt2_pulley.scad>

/* [Configuration] */
// Parameter set: previous (reference mesh) or revised (108T, DC-12)
config = "previous"; // [previous, revised]

/* [Hidden] */
$fn = 256;
epsilon = 0.01;

REF_DIR       = "../Reference/meshes/400-EndArm/";
REF_TIP_R     = 28.397;    // the reference's 90T tip radius (measured)
EXT_TEETH     = 108;       // revised count
EXT_TIP_R     = gt2_tip_d(EXT_TEETH) / 2;
EXT_ROOT_R    = gt2_root_d(gt2_tip_d(EXT_TEETH)) / 2;
RIM_OVERLAP   = 0.5;       // new rim reaches this far inside R_CUT
ROOT_CLEAR    = 0.1;       // rim body stops this far inside the grooves

// The rim's meridional outline, from its inner radius r_in. `lower` and
// `upper` are [offset over the tip, z] points of the two flanges, bottom up;
// the belt band runs between the last of `lower` and the first of `upper`, at
// the groove bottoms less ROOT_CLEAR so the band's cylinder never lies on them.
function rim_profile(r_in, lower, upper) =
    let (rb = EXT_ROOT_R - ROOT_CLEAR)
    concat([[r_in, lower[0].y]],
           [for (p = lower) [EXT_TIP_R + p.x, p.y]],
           [[rb, lower[len(lower) - 1].y], [rb, upper[0].y]],
           [for (p = upper) [EXT_TIP_R + p.x, p.y]],
           [[r_in, upper[len(upper) - 1].y]]);

// The 108T rim: the turned outline plus the tooth ring over the band. The ring
// reaches epsilon into both chamfers, which stand outside the tip there.
module external_rim(r_in, lower, upper) {
    z0 = lower[len(lower) - 1].y;
    z1 = upper[0].y;
    rotate_extrude() polygon(rim_profile(r_in, lower, upper));
    translate([0, 0, z0 - epsilon]) linear_extrude(z1 - z0 + 2 * epsilon)
        difference() {
            gt2_teeth_2d(EXT_TEETH);
            circle(r = EXT_ROOT_R - 3 * ROOT_CLEAR);
        }
}

// One External pulley: the reference as-is, or its inside kept to r_cut and
// the 108T rim added outside.
module external_pulley(mesh, r_cut, lower, upper) {
    if (config == "previous")
        import(str(REF_DIR, mesh), convexity = 8);
    else union() {
        intersection() {
            import(str(REF_DIR, mesh), convexity = 8);
            cylinder(r = r_cut, h = 200, center = true);
        }
        external_rim(r_cut - RIM_OVERLAP, lower, upper);
    }
}
