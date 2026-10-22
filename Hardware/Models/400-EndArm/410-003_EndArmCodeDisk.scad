// #410-003 End Arm Code Disk — parametric source.
// J3's encoder wheel. It sits on the outside of the Axis Intersection hub,
// raised side in (008.7 step 14), held by the four M3 all-thread rods that
// pass through its holes (step 15), and the end-arm photointerrupter (#823)
// reads its slits.
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/400-EndArm/), in that mesh's
//                         frame.
//   config = "revised"  — the same part with its print fits drawn (FITS).
//
// FRAME. The axis is +Z through the origin, the flat face at z = 0 and the hub
// rising from the other face. The reference mesh is already in this frame.
//
// CONSTRUCTION. The disc is two constant sections, each drawn whole in 2D and
// extruded once, as #300-002's is (the mesh-to-scad ladder's rung 1), and the
// hub a third:
//
//     lower layer   z 0 .. 0.25     disc - bore - holes - underside groove
//     upper layer   z 0.25 .. 1.5   disc - bore - holes - code slits
//     hub           z 1.5 .. 4      ring - bore - holes
//
// The slits are drafted: each narrows by the same amount on every side as it
// rises, so a slit is not a constant section. slit_2d(z) owns its section at
// any height, and each slit is cut as the hull of its sections at the upper
// layer's two faces (rung 6), copied round the axis (rung 7). `layer =
// "lower"`, `"upper"` or `"hub"` draws that profile in 2D, the upper one with
// its slits at mid-layer, for verification against the mesh's section
// (scadmesh outline; render.rs --verify does this).
//
// Measured from the reference with scadmesh planes/radial/slice/arcs/pattern
// and profile. The feature IDs are those of 410-003_EndArmCodeDisk.view.json,
// which labels each one on the mesh:
//
//     ID  feature                     value
//     D1  outer edge                  Ø76.222
//     F1  top face, F2 flat face      z 1.5, z 0
//     B1  bore                        Ø23.000, through
//     H1  rod holes, 4 on the axes    Ø3.000 at r 15.250, through
//     G1  underside groove            Ø66.000 .. Ø73.000, lower layer only
//     C1  code slits, 157             centred on (k + 3/4) * 360/157 deg; each
//                                     the gap between two bars (C2), its ends
//                                     arcs at r 31.515 and 37.485 at z 0.25
//     C2  bars between the slits      0.492 wide at z 0.25, parallel-sided, so
//                                     each slit widens outward (0.77 to 1.01)
//     C1, C2 draft                    every side moves 0.061 per mm up: at
//                                     z 1.5 the ends are at r 31.591 and 37.409
//                                     and the bars 0.643 wide
//     U1  hub                         Ø41.000, z 1.5 .. 4.0
//
// FITS (../print_fit.scad), revised only:
//
//     H1, on the M3 all-thread           slip
//     U1's face, on the 6807's inner     run: the face ends FIT_RUN inside
//     race                               the race's land and is rebated
//                                        FIT_RUN deep outside that, so it
//                                        turns clear of the shield's edge
//
// The faces are clamped between nuts and the hub: face contacts, which take no
// clearance. B1 turns round the External Inner Pulley's hub (R10.5) 1.0 off,
// above the running clearance (endarm_assembly.scad), so it keeps its size.

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or one layer's 2D profile
layer = "part"; // [part, lower, upper, hub]

include <../print_fit.scad>

/* [Hidden] */
$fn = 240;
epsilon = 0.01;

DISC_D   = 76.222;                  // D1
HEIGHT   = 1.500;                   // F1
LOWER_H  = 0.250;                   // the lower layer's top
BORE_D   = 23.000;                  // B1
HOLE     = [15.250, 3.000];         // H1: centre radius, diameter
M3_D     = 3.000;                   // the all-thread
GROOVE_D = [66.000, 73.000];        // G1: inner and outer diameter
SLITS    = 157;                     // C1
SLIT_AT  = 0.75;                    // C1: the first slit's angle, in pitches
SLIT     = [31.515, 37.485];        // C1 at z = LOWER_H: inner and outer end radius
BAR      = 0.492;                   // C2 at z = LOWER_H: the bars' width
DRAFT    = 0.061;                   // C1, C2: each side moves this far per mm up
HUB      = [20.500, 4.000];         // U1: radius, top z
LAND_D   = 39.000;                  // the 6807's inner race land, d + (D - d) / 3
                                    // (endarm_assembly.scad draws its races so)

FITS = fit_clearances(config);
function hole_d() = max(HOLE[1], fit_bore(M3_D, FITS[0]));

// One slit's section at height z, centred on +X: the band between its end
// arcs, less the bars either side, each bar BAR wide about its own radial
// line half a pitch away; every side drafted.
module slit_2d(z) {
    d = DRAFT * (z - LOWER_H);
    h = 180 / SLITS;
    b = BAR / 2 + d;
    // a bar's edge facing the slit: its radial line, moved b toward the slit
    function edge(s, r) = r * [cos(s * h), sin(s * h)] - s * b * [-sin(s * h), cos(s * h)];
    intersection() {
        difference() {
            circle(r = SLIT[1] - d, $fn = 2 * 360);
            circle(r = SLIT[0] + d, $fn = 2 * 360);
        }
        polygon([edge(-1, 20), edge(-1, 45), edge(1, 45), edge(1, 20)]);
    }
}

module slit_places() {
    for (k = [0 : SLITS - 1]) rotate((k + SLIT_AT) * 360 / SLITS) children();
}

module through_2d() {
    circle(d = BORE_D);
    for (a = [0 : 90 : 270]) rotate(a) translate([HOLE[0], 0]) circle(d = hole_d(), $fn = 48);
}

module lower_2d() {
    difference() {
        circle(d = DISC_D);
        through_2d();
        difference() { circle(d = GROOVE_D[1]); circle(d = GROOVE_D[0]); }
    }
}

// The upper layer's section, with the slits cut at height slit_z when given.
module upper_2d(slit_z = undef) {
    difference() {
        circle(d = DISC_D);
        through_2d();
        if (!is_undef(slit_z)) slit_places() slit_2d(slit_z);
    }
}

module hub_2d() difference() { circle(r = HUB[0]); through_2d(); }

// A slit's cutter: the hull of thin slices of its section at the layer's two
// faces, run out ε below the layer's lap and a millimetre above the top face
// on the same draft.
module slit_cutter() {
    top = HEIGHT + 1;
    hull() {
        translate([0, 0, LOWER_H - 2 * epsilon]) linear_extrude(2 * epsilon) slit_2d(LOWER_H);
        translate([0, 0, top - epsilon]) linear_extrude(epsilon) slit_2d(top);
    }
}

// The upper layer, slit before it is joined to the rest.
module upper_layer() {
    difference() {
        translate([0, 0, LOWER_H - epsilon]) linear_extrude(HEIGHT - LOWER_H + epsilon) upper_2d();
        slit_places() slit_cutter();
    }
}

// U1's rebate (revised): outside FIT_RUN inside the land, the face FIT_RUN
// back, run out past the hub's side and its face.
module hub_rebate() {
    if (FITS[2] > 0)
        translate([0, 0, HUB[1] - FITS[2]]) linear_extrude(FITS[2] + 1)
            difference() { circle(r = HUB[0] + 1); circle(r = LAND_D / 2 - FITS[2]); }
}

module end_arm_code_disk() {
    union() {
        linear_extrude(LOWER_H) lower_2d();
        upper_layer();
        difference() {
            translate([0, 0, HEIGHT - epsilon]) linear_extrude(HUB[1] - HEIGHT + epsilon) hub_2d();
            hub_rebate();
        }
    }
}

if (layer == "lower") lower_2d();
else if (layer == "upper") upper_2d((LOWER_H + HEIGHT) / 2);
else if (layer == "hub") hub_2d();
else end_arm_code_disk();
