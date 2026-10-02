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
include <../print_fit.scad>

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

// A hub's own fits exist only in the mesh, so its print-fit clearance is cut
// by growing the mesh's voids: inside `hub` = [r, z0, z1] and outside r_in,
// every void (bore, slots, holes) is swept by an octagonal prism whose flats
// stand c off its axis, which moves each wall back by c, and by at most 1.08c
// where a corner faces it. The hub's end faces lie outside the region and
// stay where they are.
module hub_fit(mesh, hub, c, r_in = 0)
    minkowski() {
        difference() {
            translate([0, 0, hub[1] + epsilon]) cylinder(r = hub[0], h = hub[2] - hub[1] - 2 * epsilon, $fn = 64);
            if (r_in > 0) cylinder(r = r_in, h = 200, center = true, $fn = 64);
            import(str(REF_DIR, mesh), convexity = 8);
        }
        cylinder(r = c / cos(22.5), h = 2 * c, center = true, $fn = 8);
    }

// One External pulley: the reference as-is, or its inside kept to r_cut and
// the 108T rim added outside. `hub`, when given, is [r, z0, z1, rod_r]: the
// region hub_fit() opens, and the radius of the bore the rod runs in. The
// whole region opens by the press clearance, for the rod; past rod_r + 0.5,
// where only the set-screw holes and nut slots are, it opens again by the
// slip clearance, for the fasteners.
module external_pulley(mesh, r_cut, lower, upper, hub = undef) {
    if (config == "previous")
        import(str(REF_DIR, mesh), convexity = 8);
    else difference() {
        union() {
            intersection() {
                import(str(REF_DIR, mesh), convexity = 8);
                cylinder(r = r_cut, h = 200, center = true);
            }
            external_rim(r_cut - RIM_OVERLAP, lower, upper);
        }
        if (hub != undef) {
            hub_fit(mesh, hub, fit_clearances(config)[1]);
            hub_fit(mesh, hub, fit_clearances(config)[0], hub[3] + 0.5);
        }
    }
}
