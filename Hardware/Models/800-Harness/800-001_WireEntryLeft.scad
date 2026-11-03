// #800-001 Wire Entry (Left) — parametric source.
// One half of the wire entry: a half pipe that brings wires down into a
// saddle, whose bore (Ø14.14) and U-shaped legs clip round a round member.
// The pair splits on the plane x = 0; #800-002 is this half's mirror image.
// No step in 008 places the pair, and what the saddle clips onto is open
// (DC-14, specs/009 § Power inlet mounting).
//
//   config = "previous" — faithful recreation of the reference mesh
//                         (../Reference/meshes/800-Harness/).
//   config = "revised"  — identical to "previous"; see FITS.
//
// FRAME. The reference's own: the pipe's axis on +z through the origin, the
// split plane x = 0, this half at x <= 0. The saddle is drawn in its own
// frame S, the part turned -45 deg about x (y_S = (y + z)/sqrt 2,
// z_S = (z - y)/sqrt 2), in which every face of the saddle is square to an
// axis; the part is S turned +45 deg about x.
//
// Measured from the reference (scadmesh planes/slice/arcs/solid, in both
// frames); feature IDs as in 800-001_WireEntryLeft.view.json:
//
//     ID  feature           value
//     P1  pipe              R7.5 outer, R5.0 bore, about the z axis, to z 30;
//                           kept behind the U's mouth and above the base
//     S1  saddle (S)        x -18 .. 0; y_S -2.697 .. 5.303 (the back face);
//                           z_S -6.697 .. 17.303
//     L1  legs (S)          x -18 .. -14; y_S on to -12.697
//     B1  saddle bore (S)   R7.069 about the x axis at (y_S -2.696, z_S 5.304),
//                           opening through the legs as a slot as wide as it
//     T1  turned channel    P1's bore stops at the back face; below it the
//                           bore's section in that plane (an ellipse R5 by
//                           R5 sqrt 2, centred z_S 5.303, where the pipe's
//                           axis crosses it) runs on along -y_S into B1
//     R1  T1's crease       R3 rolling ball where T1 meets P1's bore: a fillet
//                           at the floor, a round at the roof (the crease is
//                           concave at one and convex at the other)
//     C1  pipe chamfer      1.5 x 1.5, square to the edge, where P1 leaves the
//                           back face; it dies into the base and the top face
//                           where the face is narrower than its leg
//
// The back face, B1's height and the point where the pipe's axis crosses the
// back face are one value (5.303 = 7.5 / sqrt 2) in the reference; B1's centre
// reads 5.304 and is kept as measured.
//
// CONSTRUCTION. A region split. S1 and L1 are profile per layer along x (the
// saddle's section with and without its legs, extruded), turned into the
// part's frame; P1 is a tube, kept to S1's front and base. T1 and B1 are cut
// as one cutter each; C1 is a lofted fill of triangles square to the edge,
// and R1 a rolling ball lofted along the crease (a filler at the floor, a
// cutter at the roof). `piece` draws S1, C1 or T1 alone, in S.
//
// FITS (../print_fit.scad): none is drawn. The saddle's mate is not known
// (DC-14), so its bore keeps the reference's Ø14.14; the halves meet face to
// face on the split plane, a seat.

include <BOSL2/std.scad>
include <../print_fit.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]

/* [Hidden] */
// Which half this file draws; #800-002 includes it and names its own.
SIDE = "left";
$fn = 180;
LAP      = 0.005;
TILT     = 45;                       // the saddle's frame S is the part turned by -TILT about x
BLOCK_X  = [-18.000, 0.000];         // S1
LEG_X    = -14.000;                  // L1 runs from BLOCK_X[0] to here
BACK_Y   = [-2.697, 5.303];          // S1, in S; [1] is the back face
LEG_Y    = -12.697;                  // L1, in S
BLOCK_Z  = [-6.697, 17.303];         // S1, in S
BORE     = [-2.696, 5.304, 7.069];   // B1, in S: y, z, radius
PIPE     = [7.500, 5.000, 30.000];   // P1: outer r, bore r, top z (reference frame)
CHAMFER  = 1.500;                    // C1's legs
CREASE_R = 3.000;                    // R1
CREASE_SPAN = 60;                    // R1 runs this far (deg) either side of floor and roof

// The saddle's x-section in S (2D y, z): back strip, or back strip and legs.
module saddle_2d(legs) difference() {
    y0 = legs ? LEG_Y : BACK_Y[0];
    translate([y0, BLOCK_Z[0]]) square([BACK_Y[1] - y0, BLOCK_Z[1] - BLOCK_Z[0]]);
    translate([BORE[0], BORE[1]]) circle(r = BORE[2], $fn = 360);
    translate([LEG_Y - 1, BORE[1] - BORE[2]]) square([BORE[0] - LEG_Y + 1, 2 * BORE[2]]);
}

// The saddle in S: the legs' layer and the back's, each extruded along x.
module saddle_s() {
    translate([BLOCK_X[0], 0, 0]) rotate([90, 0, 90])
        linear_extrude(LEG_X - BLOCK_X[0] + LAP) saddle_2d(true);
    translate([LEG_X, 0, 0]) rotate([90, 0, 90])
        linear_extrude(BLOCK_X[1] - LEG_X) saddle_2d(false);
}

// The S half-spaces the pipe is kept to: behind the U's mouth, above the base.
module pipe_keep_s() translate([-50, BACK_Y[0] + LAP, BLOCK_Z[0] + LAP]) cube([100, 100, 100]);

module pipe_o() difference() {
    translate([0, 0, -40]) cylinder(r = PIPE[0], h = PIPE[2] + 40);
    translate([0, 0, -41]) cylinder(r = PIPE[1], h = PIPE[2] + 42);
}

module half_keep() translate([-50, -50, -50]) cube([50, 100, 100]);

// The pipe's bore turned into the saddle: the bore above the plane y_S =
// BORE[1] (where it crosses the saddle's bore axis height), and below it
// that plane's section of the bore (an ellipse PIPE[1] by PIPE[1] * sqrt 2),
// carried on along -y_S out through the U's mouth.
module channel_s() {
    intersection() {
        rotate([-TILT, 0, 0]) translate([0, 0, -60]) cylinder(r = PIPE[1], h = 120);
        translate([-50, BORE[1], -50]) cube([100, 100, 100]);
    }
    translate([0, BORE[1] + LAP, BORE[1]]) rotate([90, 0, 0])
        linear_extrude(60) scale([1, sqrt(2)]) circle(r = PIPE[1]);
}

// C1, the chamfer where the pipe leaves the back face, in S. Round the
// edge (the ellipse where the pipe's outer cylinder meets the plane y_S =
// BACK_Y[1]) each station is the triangle of a point inside the pipe's wall
// under the face, and the points CHAMFER from the edge on the pipe (carried
// back onto the cylinder) and on the face, each square to the edge.
A_S = [0, 1, 1] / sqrt(2);                  // the pipe's axis in S
E1  = [1, 0, 0];
E2  = [0, 1, -1] / sqrt(2);
function pipe_edge(phi) = let (t = BACK_Y[1] * sqrt(2) - PIPE[0] * sin(phi))
    PIPE[0] * (cos(phi) * E1 + sin(phi) * E2) + t * A_S;
function chamfer_section(phi) = let (
    e = pipe_edge(phi),
    tg = unit(pipe_edge(phi + 0.5) - pipe_edge(phi - 0.5)),
    n = cos(phi) * E1 + sin(phi) * E2,
    up = unit(A_S - (A_S * tg) * tg),
    nf = [n.x, 0, n.z],
    out = unit(nf - (nf * tg) * tg),
    a = e + CHAMFER * up,
    ax = (a * A_S) * A_S)
    [e - 0.5 * up - 0.8 * out, ax + PIPE[0] * unit(a - ax), e + CHAMFER * out];
// R1, the round where the channel's turned part meets the pipe's bore (the
// ellipse in the plane y_S = BACK_Y[1]). A ball of CREASE_R rolls in the
// channel against both: the bore's cylinder and the turned part's elliptic
// prism. Each station is the crease point, pushed into the material, and the
// arc of the ball between its two contacts; what lies between is material.
// The round is drawn where the surfaces meet at more than CREASE_MIN deg,
// round the floor (psi -90) and the roof (psi 90).
function crease_pt(psi) = [PIPE[1] * cos(psi), BACK_Y[1], BACK_Y[1] + PIPE[1] * sqrt(2) * sin(psi)];
// s = 1 rolls the ball in the channel (the floor, where the crease is
// concave and the round is a fillet of material); s = -1 rolls it in the
// material (the roof, where the crease is convex and the round cuts).
function crease_section(psi, s) = let (
    e = crease_pt(psi),
    np = -unit([e.x / PIPE[1]^2, 0, (e.z - BACK_Y[1]) / (2 * PIPE[1]^2)]),
    nc = -unit(e - (e * A_S) * A_S),
    g = acos(min(1, np * nc)),
    c = e + s * CREASE_R * unit(np + nc) / cos(g / 2))
    concat([e - s * 0.05 * unit(np + nc)],
           [for (t = [0 : 0.125 : 1]) c - s * CREASE_R * unit(np + (nc - np) * t)]);
module crease_round(mid, s) vnf_polyhedron(outward(vnf_vertex_array(
    [for (psi = [mid - CREASE_SPAN : 2 : mid + CREASE_SPAN]) crease_section(psi, s)],
    col_wrap = true, caps = true)));

function outward(vnf) = vnf_volume(vnf) < 0 ? vnf_reverse_faces(vnf) : vnf;
module chamfer_s() intersection() {
    vnf_polyhedron(outward(vnf_vertex_array([for (i = [0 : 179]) chamfer_section(2 * i)],
                                            col_wrap = true, row_wrap = true, caps = false)));
    translate([-50, BACK_Y[1] - 1, BLOCK_Z[0]]) cube([100, 50, BLOCK_Z[1] - BLOCK_Z[0]]);
}

module wire_entry_left() intersection() {
    difference() {
        union() {
            cut_body();
            rotate([TILT, 0, 0]) crease_round(-90, 1);
        }
        rotate([TILT, 0, 0]) crease_round(90, -1);
    }
    half_keep();
}

module cut_body() {
    difference() {
        union() {
            rotate([TILT, 0, 0]) saddle_s();
            rotate([TILT, 0, 0]) chamfer_s();
            intersection() { pipe_o(); rotate([TILT, 0, 0]) pipe_keep_s(); }
        }
        rotate([TILT, 0, 0]) channel_s();
        rotate([TILT, 0, 0]) translate([-50, BORE[0], BORE[1]]) rotate([0, 90, 0])
            cylinder(r = BORE[2], h = 100, $fn = 360);
    }
}

// A piece drawn alone, in S, to check it; "" draws the part.
piece = ""; // [, saddle, chamfer, channel]

if (piece == "saddle") saddle_s();
else if (piece == "chamfer") chamfer_s();
else if (piece == "channel") channel_s();
else if (SIDE == "left") wire_entry_left();
else mirror([1, 0, 0]) wire_entry_left();
