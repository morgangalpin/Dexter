// Elliptical windows through a wall, and the rolling-ball rounds where they leave its faces. Used by
//
//     110-001_BaseMountBottom.scad   W1: on radial axes; rounds on the tower's face and the bore's
//     120-001_BaseLong.scad          W1: along each flat's normal, set off sideways; rounds on the
//                                    flat and on the bore's face
//
// A window w = [a, b, zc, e]: its semi-axes across and up, its centre's height, and its axis's offset
// across. Its frame has x out along its axis, y across it and z up. A part places a window by turning
// this frame about Z.
//
// A face f = ["cyl", rf, side] is the cylinder of radius rf about Z; f = ["plane", x0, side] is the
// plane x = x0. side is +1 where the material lies inside the face (r < rf, or x < x0) and -1 where it
// lies outside.
//
// The round and the prism are drawn on the same points round the ellipse, so that the round meets the
// prism's wall on the prism's own edges. even = "psi" spaces them evenly in the ellipse's parameter;
// even = "normal" spaces them evenly in the angle of its normal, which a narrow window needs: at the
// ends of a 5 × 38 ellipse the normal turns 22° between even-parameter points, and the loft between
// them leaves a membrane across the window's end.
//
// Used, not included: these are functions and modules only.

// The ellipse's point at angle psi from the top, and its normal into the material, both in [y, z].
function window_point(w, psi) = [w[3] + w[0] * sin(psi), w[2] + w[1] * cos(psi)];
function window_normal(w, psi) = let (n = [sin(psi) / w[0], cos(psi) / w[1]]) n / norm(n);

// The parameter of the i-th of n points round the ellipse.
function window_psi(w, i, n, even) = let (u = 360 * i / n)
    even == "normal" ? atan2(w[0] * sin(u), w[1] * cos(u)) : u;

// The ball's centre r off the face, over the point q in [y, z], and the face's normal out of the
// material at the ball.
function window_ball(f, q, r) = f[0] == "plane"
    ? [f[1] - f[2] * r, q.x, q.y]
    : [sqrt((f[1] - f[2] * r) ^ 2 - q.x ^ 2), q.x, q.y];
function window_face_normal(f, c) = f[0] == "plane" ? [f[2], 0, 0] : f[2] * [c.x, c.y, 0] / norm([c.x, c.y]);

// The ball's arc where the window leaves face f, at psi. The ball's centre is r off the window's wall
// and r off the face. The section runs from a point pushed into the window, round the corner pushed
// into the void, to a point pushed off the face, then back along the arc. The pushes into the window
// stay under three quarters of the ellipse's tightest radius of curvature (a² / b at its ends):
// pushed past it, they cross there and the loft folds. Pushed much less, the lid they make across a
// narrow window's end can dip under the end of its prism where the face turns the section aside, and
// leave a wafer (0.02 on 120-001 at a quarter).
function window_round_section(w, f, r, psi, n = 10) = let (
    p  = window_point(w, psi),
    m  = window_normal(w, psi),
    q  = p + r * m,
    c  = window_ball(f, q, r),
    n1 = [0, -m.x, -m.y],
    n2 = window_face_normal(f, c),
    a  = acos(n1 * n2),
    e  = 0.3,
    ew = min(e, 0.75 * min(w[0] ^ 2 / w[1], w[1] ^ 2 / w[0]))
) concat([c + (r + ew) * n1, c + r * (n1 + n2) / (1 + n1 * n2) + 2 * (ew * n1 + e * n2) / norm(n1 + n2),
          c + (r + e) * n2],
         [for (j = [0 : n]) let (t = j / n) c + r * (sin((1 - t) * a) * n2 + sin(t * a) * n1) / sin(a)]);

// One window's round on face f, lofted round the whole edge, its faces wound outward.
//
// fill = true adds window_fill. Where a narrow window's end leaves a face that is oblique to the
// round's sections (an offset window through a cylinder), the sections turn aside from one another
// faster than they advance, and leave a pocket uncovered close to the wall and the face: 0.02 .. 0.2
// thick, within 0.4 of the wall and up to about 2 of the face on 120-001.
module window_round(w, f, r, segments = 120, even = "psi", fill = false) {
    sections = [for (i = [0 : segments - 1]) window_round_section(w, f, r, window_psi(w, i, segments, even))];
    m = len(sections[0]);
    polyhedron(
        points = [for (s = sections) each s],
        faces = [for (i = [0 : segments - 1], j = [0 : m - 1])
            let (a = i * m, b = ((i + 1) % segments) * m, q = (j + 1) % m)
            each f[2] > 0 ? [[a + j, b + q, b + j], [a + j, a + q, b + q]]
                          : [[a + j, b + j, b + q], [a + j, b + q, a + q]]]);
    if (fill) window_fill(w, f, r, segments, even);
}

// What a round on face f is sure to remove next to the window's wall, in two steps: the window grown
// by 0.2 r to 0.28 r into the material, and grown by 0.05 r to 0.5 r into it, each from 0.3 outside
// the face. At depth d a rolling ball of radius r on a face square to the window still reaches
// r - √(r² - (r - d)²) from the wall: 0.31 r and 0.13 r at those depths. Each step keeps well inside
// that, because on a face oblique to the window the ball reaches less: grown by 0.04 r to 0.68 r
// (reach 0.053 r), the second step cut 0.17 into 120-001's window flanks.
module window_fill(w, f, r, segments, even) {
    for (step = [[0.2, 0.28], [0.05, 0.5]]) window_fill_step(w, f, r, segments, even, step);
}

module window_fill_step(w, f, r, segments, even, step) {
    s = step[0] * r;
    d = step[1] * r;
    e = 0.3;
    lo = f[0] == "plane" ? f[1] - max(f[2] * d, -f[2] * e) : max(0, f[1] - max(f[2] * d, -f[2] * e));
    hi = f[0] == "plane" ? f[1] + max(f[2] * e, -f[2] * d) : f[1] + max(f[2] * e, -f[2] * d);
    intersection() {
        translate([lo - 1, 0, 0]) rotate([0, 0, 90]) rotate([90, 0, 0]) linear_extrude(hi - lo + 2)
            offset(r = s) window_2d(w, segments, even);
        if (f[0] == "plane") let (h = [w[0] + abs(w[3]) + r + 1, w[1] + r + 1])
            translate([lo, -h.x, w[2] - h.y]) cube([hi - lo, 2 * h.x, 2 * h.y]);
        else translate([0, 0, w[2] - w[1] - r - 1]) difference() {
            cylinder(r = hi, h = 2 * (w[1] + r + 1));
            translate([0, 0, -1]) cylinder(r = lo, h = 2 * (w[1] + r + 2));
        }
    }
}

// The window's section, in [y, z].
module window_2d(w, segments = 120, even = "psi") {
    polygon([for (i = [segments - 1 : -1 : 0]) window_point(w, window_psi(w, i, segments, even))]);
}

// The window's prism, along its axis from x0 to x1.
module window_prism(w, x0, x1, segments = 120, even = "psi") {
    translate([x0, 0, 0]) rotate([0, 0, 90]) rotate([90, 0, 0]) linear_extrude(x1 - x0)
        window_2d(w, segments, even);
}
