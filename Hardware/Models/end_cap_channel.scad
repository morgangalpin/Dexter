// Motor End Cap wire channel and lug corners: what the End Caps that carry a
// channel (#311-001, #511-001) share. The channel runs from the centre bore
// out to a notch along +X, standing on the motor seat, with filleted ceiling
// corners and rounds into the seat; the bore's round runs on round it. Its
// seat rounds run on until they meet a lug or open into the notch, and the
// lugs' root fillets run up onto them there.
//
// The caller passes its own sizes, each part's measured:
//
//     s          the seat's z, the face the motor's rear bears on
//     bore       [radius, round]: the centre bore, and its round into the
//                seat and the channel's ceiling
//     ch         [half-width at mid-height, height above the seat, round]:
//                the channel's section, its ceiling fillets and seat rounds
//                all of the one radius
//     outer_r    a radius beyond the part, bounding the cutters
//
// FRAME. The caller's: the axis on +Z, the channel along +X.

epsilon = 0.01;
ARC_STEP = 5;      // degrees per facet on every round and fillet

// A round on the edge where a vertical wall at radius r0 meets a face at z,
// the material lying beyond r0 and above z; the cutter reaches `under` below z.
module edge_round(r0, z, r, under = epsilon)
    translate([0, 0, z]) rotate_extrude() polygon([
        [r0 - epsilon, -under], [r0 + r, -under],
        for (t = [0 : ARC_STEP : 90]) [r0 + r - r * sin(t), r - r * cos(t)],
        [r0 - epsilon, r]]);

// The wire channel's section, y across and z up from the seat.
module channel_2d(ch) {
    w = ch[0]; h = ch[1]; r = ch[2];
    half = [[w + r, -epsilon],
            for (t = [ARC_STEP : ARC_STEP : 90 - ARC_STEP]) [w + r - r * sin(t), r - r * cos(t)],
            [w, r],
            for (t = [ARC_STEP : ARC_STEP : 90 - ARC_STEP]) [w - r + r * cos(t), r + r * sin(t)],
            [w - r, h]];
    polygon(concat([[0, -epsilon]], half, [for (i = [len(half) - 1 : -1 : 0]) [-half[i][0], half[i][1]]]));
}

// The motor's pocket under the seat: its square, and the notches the lugs'
// corners were rounded on, closed by the corner radius where they meet.
module motor_pocket_2d(face, notch_half, r_c, reach)
    offset(r = -r_c) offset(delta = r_c) union() {
        square(2 * face, center = true);
        for (a = [0 : 90 : 270]) rotate(a) translate([0, -notch_half]) square([reach, 2 * notch_half]);
    }

// A solid lofted through sections of equal point count, capped at both ends.
module loft(stations) {
    n = len(stations[0]);
    last = len(stations) - 1;
    polyhedron(
        points = [for (sec = stations) each sec],
        faces = concat(
            // The caps are fans of triangles: a section is planar only to rounding,
            // and CGAL rejects an n-gon that is not exactly planar.
            [for (k = [1 : n - 2]) [0, k, k + 1]],
            [for (k = [1 : n - 2]) [last * n, last * n + k + 1, last * n + k]],
            [for (i = [0 : last - 1], k = [0 : n - 1]) each [
                [i * n + k, (i + 1) * n + k, (i + 1) * n + (k + 1) % n],
                [i * n + k, (i + 1) * n + (k + 1) % n, i * n + (k + 1) % n]]]));
}

// The arc from a to b about c, the short way, in 90 / ARC_STEP steps, so that
// every section has as many points and a quarter round's are its facets.
function unit(v) = v / norm(v);
function arc_points(c, a, b) =
    let (u = unit(a - c), v = unit(b - c), phi = acos(u * v), w = unit(v - (u * v) * u),
         n = 90 / ARC_STEP)
    [for (k = [0 : n]) c + norm(a - c) * (cos(k * phi / n) * u + sin(k * phi / n) * w)];

// --- The bore's round round the channel's sides ----------------------------
// The bore's round runs on round the ceiling's side fillets. At fillet angle
// t (0 at the wall, 90 at the flat) a ball rests on the bore and on the
// fillet, and past t 90 it runs on along the flat, where its ball is the bore
// round's. The ball's centre lies on both faces' offset surfaces, so it
// touches the bore and the fillet themselves, and the blend runs out tangent
// into each.
//
// As the reference has it, the ball keeps the bore round's setback from the
// seam on both faces' tangent planes, so it grows from the bore round at the
// flat as the faces open out toward the wall. The blend stops at the plane of
// the channel's wall, so toward the wall it narrows onto the bore to the
// seam, and below the fillets the wall meets the bore sharp.
//
// With `round_sides`, the ball keeps the bore round's radius instead, and the
// round runs on down the channel's sides to the seat: at the wall the ball is
// the one resting on the seat, the bore and the channel's seat round at once,
// so a corner of that ball (side_corner) closes the round there.
function ball_radius(seam, t, bore) =
    let (nb = -[seam[0], seam[1], 0] / bore[0],   // face normals, into the void
         nc = -[0, cos(t), sin(t)],
         edge = unit(cross(nb, nc)),
         ub0 = unit(cross(edge, nb)), ub = ub0 * nc > 0 ? -ub0 : ub0,   // along each face,
         uc0 = unit(cross(edge, nc)), uc = uc0 * nb > 0 ? -uc0 : uc0)   // away from the seam
    bore[1] * tan(acos(ub * uc) / 2);

function blend_station(t, s, bore, ch, round_sides) =   // [seam, ball centre, on the bore, on the fillet]
    let (tf = min(t, 90),   // on the flat, the fillet's axis moves in along it
         axis = [ch[0] - ch[2] - ch[2] * max(t - 90, 0) * PI / 180, s + ch[2]],   // along x
         dir = [cos(tf), sin(tf)],
         on_fillet = axis + ch[2] * dir,
         seam = [sqrt(bore[0] * bore[0] - on_fillet[0] * on_fillet[0]), on_fillet[0], on_fillet[1]],
         rho = round_sides ? bore[1] : ball_radius(seam, tf, bore),
         c = axis + (ch[2] + rho) * dir,
         centre = [sqrt(pow(bore[0] + rho, 2) - c[0] * c[0]), c[0], c[1]],
         on_bore = [centre[0], centre[1], 0] * bore[0] / (bore[0] + rho) + [0, 0, centre[2]])
    // on the flat the section is radial, and so is the seam it starts from
    [t > 90 ? [on_bore[0], on_bore[1], on_fillet[1]] : seam, centre, on_bore,
     [centre[0], on_fillet[0], on_fillet[1]]];

// The cutter's section at fillet angle t: from a point in the void past the
// seam, out along the bore to the ball, round the ball's near side, and back
// along the fillet. The ends sit 0.1 into the void so no cutter face lies on
// a face the part has.
function blend_section(t, s, bore, ch, round_sides) =
    let (b = blend_station(t, s, bore, ch, round_sides), seam = b[0], m = 0.1,
         nb = -[seam[0], seam[1], 0] / bore[0], nc = -[0, cos(min(t, 90)), sin(min(t, 90))])
    concat([seam + m * (nb + nc), b[2] + m * unit([-b[2][0], -b[2][1], 0])],
           arc_points(b[1], b[2], b[3]),
           [b[3] + m * nc]);

// The sections lofted from the wall (t 0) to the flat (t 90), and two steps
// on along the flat, lapping the bore round there.
module side_blend(s, bore, ch, round_sides, step = 2.5)
    loft([for (t = [0 : step : 90 + 2 * step]) blend_section(t, s, bore, ch, round_sides)]);

// A ball about the x axis, its facets on the same 5 deg steps from -z as the
// channel's seat round, so that the two meet facet for facet.
module x_ball(c, r)
    translate(c) rotate([0, 90, 0]) rotate_extrude($fn = 360 / ARC_STEP)
        polygon(concat([[0, -r]], [for (t = [ARC_STEP : ARC_STEP : 180 - ARC_STEP]) r * [sin(t), -cos(t)]], [[0, r]]));

// The side round's foot: the ball at the wall rests on the seat, the bore and
// the channel's seat round, its centre on the seat round's axis. Material it
// is nearest to, and does not reach, is cut: the wedge short of the seat
// round's axis, up to the bore round's radial plane, and below the ball's
// centre, where the side blend's first section lies.
module side_corner(s, bore, ch) {
    assert(bore[1] == ch[2], "the side round's foot needs the bore round and the channel's round equal");
    v = [sqrt(pow(bore[0] + bore[1], 2) - pow(ch[0] + ch[2], 2)), ch[0] + ch[2], s + ch[2]];
    difference() {
        translate([0, 0, s - 0.1]) linear_extrude(ch[2] + 0.1 + epsilon) polygon([[0, 0], [v[0], 0], [v[0], v[1]]]);
        x_ball(v, bore[1]);
    }
}

// The channel cutter: its section run out to outer_r, the bore's round
// carried on into its ceiling and round its fillets, and the lot kept to the
// region its children draw in plan: the motor's pocket and the notches, so
// that the channel stops where it meets a lug.
module wire_channel(s, bore, ch, outer_r, round_sides = false)
    intersection() {
        union() {
            translate([0, 0, s]) rotate([90, 0, 90]) linear_extrude(outer_r) channel_2d(ch);
            intersection() {   // the bore's round into the channel's flat ceiling, out to
                               // just short of the radial plane through the ball at the
                               // flat's edge, inside side_blend's lap; past that plane
                               // the fillet falls away under it
                edge_round(bore[0], s + ch[1], bore[1], under = 0.05);   // into the channel
                a = asin((ch[0] - ch[2]) / (bore[0] + bore[1])) - 0.25;
                translate([0, 0, s]) linear_extrude(2 * ch[1])
                    polygon([[0, 0], outer_r * [cos(a), -sin(a)], outer_r * [cos(a), sin(a)]]);
            }
            for (m = [0, 1]) mirror([0, m, 0]) {
                intersection() {   // without round_sides, not onto the bore past the wall
                    side_blend(s, bore, ch, round_sides);
                    translate([0, 0, s]) cube([outer_r, ch[0] + (round_sides ? ch[2] : 0), 3 * ch[1]]);
                }
                if (round_sides) side_corner(s, bore, ch);
            }
        }
        translate([0, 0, s - 1]) linear_extrude(ch[1] + 2) children();
    }

// --- The lugs' root fillets ------------------------------------------------
// A lug's root fillet is a ball of radius f rolled between the lug and the
// ceiling over it. The ceiling is the seat, or, given `ch`, the channel's seat
// round where the channel crosses: its section is the same at every x, so the
// ball touches it at its own x. ceiling_z is the ceiling's z at y, or with f
// the z of the centre of a ball of radius f under it.
function ceiling_z(y, s, ch, f = 0) =
    let (yl = is_undef(ch) ? -1 : ch[0] + ch[2])   // the seat round's axis, at z s + ch[2]
    y >= yl ? s - f : s + ch[2] - sqrt(pow(ch[2] + f, 2) - pow(yl - y, 2));

// Where a ball of radius f centred at o touches the ceiling.
function ceiling_contact(o, s, ch, f) =
    is_undef(ch) || o[1] >= ch[0] + ch[2] ? o + [0, 0, f]
    : o + f * unit([0, ch[0] + ch[2] - o[1], s + ch[2] - o[2]]);

// The notch, [half-width, floor radius, floor fillet radius, edge round], lies
// along +x beyond its floor, its floor's corners rounded. The ceiling stops at
// it, its edge there rounded by the last; notch_grown is the round's axis.
function notch_grown(notch) = let (e = len(notch) > 3 ? notch[3] : 0)
    [notch[0] + e, notch[1] - e, notch[2] + e, e];
function notch_corner(notch) = [notch[1] + notch[2], notch[0] - notch[2]];
function in_notch(q, notch) =
    let (c = notch_corner(notch))
    q[0] > notch[1] && abs(q[1]) < notch[0]
    && (q[0] >= c[0] || abs(q[1]) <= c[1] || norm([q[0], abs(q[1])] - c) <= notch[2]);

// The point of the notch's +y edge nearest q, a point in the notch.
function notch_edge(q, notch) =
    let (c = notch_corner(notch),
         cands = concat([[max(q[0], c[0]), notch[0]], [notch[1], min(q[1], c[1])]],
                        q[0] < c[0] && q[1] > c[1] ? [c + notch[2] * unit(q - c)] : []),
         d = [for (p = cands) norm(p - q)])
    cands[search(min(d), d)[0]];

// A ball of radius f under the ceiling, over o (in plan): [its centre, where it
// touches the ceiling, that touch's z]. Where the ceiling has stopped at the
// notch the ball rolls over its edge instead: on the edge's round of radius e,
// so its centre keeps f + e from the round's axis, until it lies level with the
// axis and touches nothing. On the seat that touch, out of the section's plane,
// is undef: the section keeps to its plane (fillet_section), as the touch
// twists the loft past what CGAL will cut. On the channel's seat round the
// ball already touches out of the plane, and the touch on the edge carries on.
function ceiling_ball(o, s, ch, f, notch) =
    let (centre = [o[0], o[1], ceiling_z(o[1], s, ch, f)],
         touch = ceiling_contact(centre, s, ch, f),
         g = notch_grown(notch), e = g[3])
    !in_notch([touch[0], touch[1]], g) ? [centre, touch, touch[2]]
    : let (q = notch_edge([touch[0], touch[1]], g), d = min(norm(q - o), f + e),
           axis = [q[0], q[1], ceiling_z(q[1], s, ch) + e],
           c = [o[0], o[1], axis[2] - sqrt(pow(f + e, 2) - d * d)],
           on = c + f * unit(axis - c))
      [c, is_undef(ch) ? undef : on, on[2]];

// The fillet's section where the ball touches the lug at w (in plan), the lug
// lying along n (in plan, into it): in from the lug and the ceiling's edge, the
// ball's touch on the lug, round its near side to its touch on the ceiling.
// On the seat's edge, the ball's own circle in the section's plane, up to the
// touch's height, stands for the ball, so the section stays in its plane. Its
// other points sit 0.1 into the material, so no face of it lies on one the
// part has.
function fillet_section(w, n, s, ch, f, notch, m = 0.1) =
    let (b = ceiling_ball([w[0] - f * n[0], w[1] - f * n[1]], s, ch, f, notch),
         c = b[0],
         on_lug = [w[0], w[1], c[2]],
         top = asin(max(-1, min(1, (b[2] - c[2]) / f))),
         arc = is_undef(b[1]) ? [for (k = [0 : 90 / ARC_STEP]) let (a = k * top / (90 / ARC_STEP))
                                     c + f * [cos(a) * n[0], cos(a) * n[1], sin(a)]]
                              : arc_points(c, on_lug, b[1]),
         end = arc[len(arc) - 1],
         inward = m * [n[0], n[1], 0])
    concat([[w[0], w[1], ceiling_z(w[1], s, ch) + m] + inward, on_lug + inward],
           arc, [end + m * (end - c) / f]);

// How far round the corner, about p, the lug runs before the notch takes it:
// the angle where the corner's arc enters the notch, or 270.
function corner_end(p, r_c, notch, lo = 180, hi = 270, k = 20) =
    !in_notch(p + r_c * [cos(hi), sin(hi)], notch) ? hi
    : k == 0 ? lo
    : let (mid = (lo + hi) / 2)
      in_notch(p + r_c * [cos(mid), sin(mid)], notch) ? corner_end(p, r_c, notch, lo, mid, k - 1)
                                                      : corner_end(p, r_c, notch, mid, hi, k - 1);

// FRAME. A lug's inner face on x = face, along +y from its notch-side corner,
// rounded r_c about [face + r_c, y_c], out to y = far; the notch along +x. The
// fillet runs from where the notch takes the corner, and a step on into the
// notch, which the caller cuts off, round the corner and out along the face.
// Where the channel's seat round crosses the face the sections close up, as
// the ceiling climbs.
module root_fillet(s, ch, face, y_c, r_c, f, far, notch) {
    p = [face + r_c, y_c];
    a_end = corner_end(p, r_c, notch);
    corner = concat(a_end < 270 ? [min(a_end + ARC_STEP, 270), a_end] : [a_end],
                    [for (a = [ARC_STEP * floor((a_end - 0.5) / ARC_STEP) : -ARC_STEP : 180 + ARC_STEP]) a]);
    yl = is_undef(ch) ? y_c : max(ch[0] + ch[2], y_c);
    ys = yl > y_c ? [for (k = [0 : 6]) y_c + k * (yl - y_c) / 6, far] : [y_c, far];
    loft(concat(
        [for (a = corner) fillet_section(p + r_c * [cos(a), sin(a)], -[cos(a), sin(a)], s, ch, f, notch)],
        [for (y = ys) fillet_section([face, y], [1, 0], s, ch, f, notch)]));
}
