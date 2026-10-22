// #420-002 End Arm Hub Cap — parametric source.
// The cap that snaps over the End Arm Hub's open end (008.7 step 20). The four
// M3 all-thread rods pass through it, and it carries the MR128 that holds the
// stainless tube's outer end, pressed in before the Cap goes on (step 10).
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/400-EndArm/), in that mesh's
//                         frame.
//   config = "revised"  — the same part with its print fits drawn (FITS).
//
// FRAME. The axis is +Z through the origin, the plain face at z = 0 and the
// MR128 pocket opening in the face at z = 8. The flat on the outline is on -X.
// The reference mesh is already in this frame.
//
// CONSTRUCTION. Every section between the faces is the same outline with the
// same windows and holes, so the part is one 2D section extruded once (the
// mesh-to-scad ladder's rung 1). Only the bore steps, so it is one revolved
// cutter (rung 4) holding every step and the chamfer.
//
// The section's material is the outline's ring, plus a wheel inside it: a hub
// circle, a cross of two spokes, and a boss round each rod hole. Its concave
// corners are rounds of two sizes, so it is built as two closings (rung 5): the
// wheel is closed by R3, which rounds the hub-to-spoke and spoke-to-boss
// corners, then the ring is added and the whole closed by R1.15, which rounds the
// boss-to-ring corners and leaves the R3 ones as they are. The ring's inner
// edge runs parallel to the flat on -X, and its two corners there are rounded
// by an opening of the ring's inner region.
//
// Measured from the reference with scadmesh planes/radial/slice/arcs/profile
// (the window radii from the vertices of the section at z 6). The feature IDs
// are those of 420-002_EndArmHubCap.view.json, which labels each one on the
// mesh:
//
//     ID  feature                     value
//     O1  outline                     Ø45.000, cut by a flat at x -19.500
//     T1  faces                       z 0, z 8.000
//     W1  ring's inner edge           Ø37.750; parallel to the flat at x -16.754,
//                                     its corners there R3.63
//     W2  hub                         Ø19.750
//     W3  spokes                      8.000 wide, on the axes
//     W4  bosses                      R5.000 about each rod hole
//     W5  rounds                      R3.000 hub-spoke and spoke-boss,
//                                     R1.150 boss-ring (fitted by outline:
//                                     R1.0 and R1.25 leave 0.18 and 0.13)
//     H1  rod holes, 4 on the axes    Ø3.000 at r 15.250, through
//     B1  bore                        Ø7.980 to z 2.500, a 45 deg chamfer to
//                                     Ø7.000 at z 3.000, Ø7.000 to z 4.000
//     B2  MR128 pocket                Ø12.000, z 4.000 .. 8.000; its floor is the
//                                     bearing's seat
//
// FITS (../print_fit.scad), revised only:
//
//     B2, on the MR128's Ø12 OD          press
//     H1, on the M3 all-thread           slip
//     B2's floor, under the MR128        run: relieved FIT_RUN deep out to
//                                        FIT_SLIP outside the outer race's
//                                        land, so only the outer race seats
//                                        and the inner race, which turns with
//                                        the stainless tube, and the tube's
//                                        end stand clear
//
// B2's floor is otherwise a face contact, which takes no clearance.

include <../print_fit.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or its 2D section
layer = "part"; // [part, section]

/* [Hidden] */
$fn = 180;
epsilon = 0.01;

OUTLINE_R  = 22.500;                    // O1
FLAT_X     = -19.500;                   // O1's flat
HEIGHT     = 8.000;                     // T1
RING_R     = 18.875;                    // W1
RING_FLAT  = -16.754;                   // W1, parallel to the flat
RING_ROUND = 3.630;                     // W1's corners at the flat
HUB_R      = 9.875;                     // W2
SPOKE_W    = 8.000;                     // W3
BOSS_R     = 5.000;                     // W4
ROUND_HUB  = 3.000;                     // W5
ROUND_RING = 1.150;                     // W5
HOLE       = [15.250, 3.000];           // H1: centre radius, diameter
BORE       = [7.980, 2.500, 7.000, 3.000, 4.000];   // B1: Ø, z, Ø after the chamfer, z, z
POCKET_D   = 12.000;                    // B2
M3_D       = 3.000;                     // the all-thread
MR128_OD   = 12.000;
OUTER_LAND_D = 10.667;                  // the MR128's outer race land, D - (D - d) / 3
                                        // (endarm_assembly.scad draws its races so)

FITS = fit_clearances(config);
function hole_d()   = max(HOLE[1], fit_bore(M3_D, FITS[0]));
function pocket_d() = max(POCKET_D, fit_bore(MR128_OD, FITS[1]));

module on_axes() for (a = [0 : 90 : 270]) rotate(a) children();

// O1.
module outline_2d() {
    intersection() {
        circle(r = OUTLINE_R);
        translate([FLAT_X, -OUTLINE_R - 1]) square([2 * OUTLINE_R + 2, 2 * OUTLINE_R + 2]);
    }
}

// The ring between O1 and W1.
module ring_2d() {
    difference() {
        outline_2d();
        offset(r = RING_ROUND) offset(r = -RING_ROUND) intersection() {
            circle(r = RING_R);
            translate([RING_FLAT, -RING_R - 1]) square([2 * RING_R + 2, 2 * RING_R + 2]);
        }
    }
}

// The wheel inside the ring: hub, spokes out to the boss centres, and bosses,
// closed by R3.
module wheel_2d() {
    offset(r = -ROUND_HUB) offset(r = ROUND_HUB) union() {
        circle(r = HUB_R);
        on_axes() {
            translate([0, -SPOKE_W / 2]) square([HOLE[0], SPOKE_W]);
            translate([HOLE[0], 0]) circle(r = BOSS_R);
        }
    }
}

// The section: ring and wheel closed by ROUND_RING and kept inside O1 (the -X boss
// would otherwise stand past the flat), less the rod holes and B1's narrowest
// step, which runs through every height. The bore cutter takes the rest.
module section_2d() {
    difference() {
        intersection() {
            offset(r = -ROUND_RING) offset(r = ROUND_RING) union() {
                ring_2d();
                wheel_2d();
            }
            outline_2d();
        }
        on_axes() translate([HOLE[0], 0]) circle(d = hole_d(), $fn = 60);
        circle(d = BORE[2]);
    }
}

// The cutter's outline from B1's narrowest step to B2's floor: straight up to
// the floor, or, in revised, through B2's floor relief.
function relief() =
    let (r2 = BORE[2] / 2, rr = OUTER_LAND_D / 2 + FITS[0], zr = BORE[4] - FITS[2])
    FITS[2] > 0 ? [[r2, zr], [rr, zr], [rr, BORE[4]]] : [[r2, BORE[4]]];

// B1, B2 and the relief as one revolved cutter, run out past both faces.
module bore_cutter() {
    r1 = BORE[0] / 2;
    r2 = BORE[2] / 2;
    rp = pocket_d() / 2;
    rotate_extrude() polygon(concat([[0, -1], [r1, -1], [r1, BORE[1]], [r2, BORE[3]]],
                                    relief(),
                                    [[rp, BORE[4]], [rp, HEIGHT + 1], [0, HEIGHT + 1]]));
}

module end_arm_hub_cap() {
    difference() {
        linear_extrude(HEIGHT) section_2d();
        bore_cutter();
    }
}

if (layer == "section") section_2d();
else end_arm_hub_cap();
