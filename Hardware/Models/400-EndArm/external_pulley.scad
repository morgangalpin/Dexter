// The External pulleys' shared definition: #430-001 External Outer Pulley and
// #430-002 External Inner Pulley, the driven pulleys of the wrist's stage 1
// (specs/004 § Wrist and differential). Each part file includes this one, and
// passes its own parametric body, the reference's 90T pulley, as the child of
// external_pulley().
//
//   config = "previous" — the previous version's 90T pulley, a faithful
//                         recreation of the reference mesh
//                         (../Reference/meshes/400-EndArm/).
//   config = "revised"  — the 108T pulley of the 16T -> 108T stage (DC-12):
//                         the body's hub, spokes and set-screw work kept inside
//                         R_CUT, with their print fits, and a new 108T GT2 rim
//                         outside it.
//
// The 108T rim keeps the reference's axial stations. Its flanges and chamfers
// are stated as offsets over the tooth tip, measured on the 90T reference
// (scadmesh profile), so they stand the same height over the 108T tip as they
// did over the 90T one.

include <../gt2_pulley.scad>
include <../print_fit.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised (108T, DC-12)
config = "previous"; // [previous, revised]

/* [Hidden] */
$fn = 256;
epsilon = 0.01;

REF_TEETH     = 90;        // the reference's count
REF_TIP_R     = 28.397;    // the reference's 90T tip radius (measured)
REF_ROOT_R    = gt2_root_d(2 * REF_TIP_R) / 2;
EXT_TEETH     = 108;       // revised count
EXT_TIP_R     = gt2_tip_d(EXT_TEETH) / 2;
EXT_ROOT_R    = gt2_root_d(gt2_tip_d(EXT_TEETH)) / 2;
RIM_OVERLAP   = 0.5;       // new rim reaches this far inside R_CUT
ROOT_CLEAR    = 0.1;       // a band's turned core stops this far inside the grooves

// The 90T band of the reference, z0 .. z1: the rounded-tip tooth form of
// gt2_pulley.scad at the measured tip, its grooves turned half a pitch so that
// a tooth is on 0 deg, over a core the part's own profile stops at
// REF_ROOT_R - ROOT_CLEAR.
module ref_band(z0, z1) {
    translate([0, 0, z0 - epsilon]) linear_extrude(z1 - z0 + 2 * epsilon)
        difference() {
            rotate(180 / REF_TEETH) gt2_teeth_rounded_2d(REF_TEETH, 2 * REF_TIP_R);
            circle(r = REF_ROOT_R - 3 * ROOT_CLEAR);
        }
}

// One window of an External pulley's web, centred on +X: the annulus between
// hub and rim within the sector between the spokes either side (at +-60 deg,
// three windows to a pulley), less the spokes. w = [inner r, outer r, spoke
// half-width, inner corner R, outer corner R]: the corners are rounded by two
// openings, the smaller kept near the hub and the larger near the rim.
module pulley_window_2d(w) {
    module raw() difference() {
        intersection() {
            difference() { circle(r = w[1]); circle(r = w[0]); }
            polygon([[0, 0], 60 * [cos(-60), sin(-60)], [60, 0], 60 * [cos(60), sin(60)]]);
        }
        for (a = [60, -60]) rotate(a) translate([-50, -w[2]]) square([100, 2 * w[2]]);
    }
    intersection() {
        offset(r = w[3]) offset(r = -w[3]) raw();
        union() {
            offset(r = w[4]) offset(r = -w[4]) raw();
            circle(r = (w[0] + w[1]) / 2);
        }
    }
}

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

// One External pulley: its body as given, or the body kept to r_cut and the
// 108T rim added outside. The body draws its own fits from `config`; the part
// cuts anything that runs out through the rim after this.
module external_pulley(r_cut, lower, upper) {
    if (config == "previous") children();
    else union() {
        intersection() {
            children();
            cylinder(r = r_cut, h = 200, center = true);
        }
        external_rim(r_cut - RIM_OVERLAP, lower, upper);
    }
}
