// #630-006 Flex Spline Cap — parametric source.
// Clamps the strain-wave drive's flexspline hub to the Flex Spline Attach
// (#630-005) from inside the cup, one per drive (J1, J2, J3). Six M2 screws
// come up through the Attach and the hub into M2 nuts held in this part.
//
//   config = "previous" — faithful recreation of the reference mesh
//                         (../Reference/meshes/600-StrainWave/).
//   config = "revised"  — cut for C-201's flexspline hub
//                         (c201_spline_seat.scad), to match the Attach's
//                         revised hub seat.
//
// FRAME. The reference's own: the axis on +Z, the nut face at z = 0, the face
// that bears on the hub at z = 4.000. In the drive the part stands upside
// down, its bearing face on the hub's inner face.
//
// Measured from the reference (scadmesh slice/profile/radial):
//
//     feature                      value                  z span
//     body                         Ø23.0                  0 .. 2
//     its chamfer                  45 deg, to Ø19.0       2 .. 4
//     centre bore                  Ø5.5                   0 .. 4
//     screw holes, 6 on Ø12        Ø2.0, from 0 deg       0 .. 5
//     nubs round them              Ø3.3                   4 .. 5
//     nut traps                    hex 4.0 AF, flats
//                                  facing the axis        0 .. 1.5
//
// The reference's Ø19 face and nubs are not C-201's hub, whose holes are
// Ø4.5 on Ø17, outside that face. The revised part bears on the hub with a
// Ø22.0 land, inside the hub's Ø22.5 so it never loads the cup's thin bottom
// beyond it, and stands its Ø25 body 0.5 off that bottom. It has no nubs:
// the Attach's fill the hub's holes. Its traps are 2.0 deep, so the nut sits
// below the face and an M2 x 12 passes through it at the longest path, J1's
// and J2's.
//
//     body                         Ø25.0                  0 .. 3.5
//     land                         Ø22.0                  3.5 .. 4
//     centre bore                  Ø5.5                   0 .. 4
//     screw holes, 6 on Ø17        Ø2.0 (M2), from 0 deg  0 .. 4
//     nut traps                    hex 4.0 AF (the M2
//                                  nut), flats facing
//                                  the axis               0 .. 2
//
// FITS (../print_fit.scad), revised only: the screw holes and nut traps
// draw the slip clearance per side over the M2 sizes above. The land bears
// on a face and takes none.

include <../print_fit.scad>
use <c201_spline_seat.scad>
use <630-005_FlexSplineAttach.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]

/* [Hidden] */
$fn = 144;
epsilon = 0.01;

FACE        = 4.000;             // bears on the hub
BORE_D      = 5.500;
HOLE_D      = 2.000;
NUT         = [4.000, 1.600];    // M2 hex: across flats, thickness
SCREW_LEN   = 12.000;            // M2 x 12 (#641-002), under the head
// previous
BODY        = [23.000, 2.000];   // diameter, top of the straight
CHAMFER_TO  = 19.000;            // diameter at the face
HOLE_PCD    = 12.000;
NUB         = [3.300, 1.000];    // diameter, height above the face
TRAP_PREV   = 1.500;
// revised
BODY_REV    = [25.000, 3.500];   // diameter, top
LAND_D      = 22.000;
TRAP_REV    = 2.000;

function cap_face() = FACE;
function cap_trap(cfg) = cfg == "previous" ? TRAP_PREV : TRAP_REV;

// The screw's path from its head to the top of its nut, at a drop of zero:
// through the Attach from its head seat to its hub face, the hub, and this
// part from its face to the bottom of the trap, where the nut sits.
function screw_path(cfg) = attach_hub_face("revised", 0) - attach_head_seat()
                           + fs_hub()[1] + FACE - cap_trap(cfg) + NUT[1];

module profile(cfg)
    if (cfg == "previous")
        polygon([[BORE_D / 2, 0], [BODY[0] / 2, 0], [BODY[0] / 2, BODY[1]],
                 [CHAMFER_TO / 2, FACE], [BORE_D / 2, FACE]]);
    else
        polygon([[BORE_D / 2, 0], [BODY_REV[0] / 2, 0], [BODY_REV[0] / 2, BODY_REV[1]],
                 [LAND_D / 2, BODY_REV[1]], [LAND_D / 2, FACE], [BORE_D / 2, FACE]]);

module holes(cfg) {
    if (cfg == "previous") for (a = [0 : 60 : 300]) rotate(a) translate([HOLE_PCD / 2, 0]) children();
    else fs_hub_holes() children();
}

function slip(cfg) = fit_clearances(cfg)[0];

// A hexagon with one pair of flats facing the axis, when placed on +X.
module nut_trap_2d(c) rotate(30) circle(d = fit_bore(NUT[0], c) / cos(30), $fn = 6);

module flex_spline_cap(cfg = config) {
    top = cfg == "previous" ? FACE + NUB[1] : FACE;
    difference() {
        union() {
            rotate_extrude() profile(cfg);
            if (cfg == "previous") holes(cfg) translate([0, 0, FACE - epsilon]) cylinder(d = NUB[0], h = NUB[1] + epsilon, $fn = 48);
        }
        holes(cfg) {
            translate([0, 0, -epsilon]) cylinder(d = fit_bore(HOLE_D, slip(cfg)), h = top + 2 * epsilon, $fn = 48);
            translate([0, 0, -epsilon]) linear_extrude(cap_trap(cfg) + epsilon) nut_trap_2d(slip(cfg));
        }
    }
}

assert(screw_path("revised") <= SCREW_LEN, "an M2 x 12 does not pass through its nut");

flex_spline_cap();
echo(cap_screw_spare = SCREW_LEN - screw_path(config));
