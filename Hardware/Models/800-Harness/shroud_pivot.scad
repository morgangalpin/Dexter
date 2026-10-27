// #822 Photointerrupter Shroud (Pivot): what its two halves (A and B) share.
// No part and no top-level geometry. Frame: the reference's, the code disk's
// axis on z through the origin. Each half's header owns its own layers.
//
//     the sector         between the radial edges ANG, out to R_OUT
//     K1 corner cut      R K_R about K1_C, where the 190 deg edge meets the
//                        inner wall
//     B1, B2 beam axes   on BEAM_R at BEAM_A
//     N1 nail holes      NAILS, Ø NAIL_D (a #19 nail drives into them)
//
// and the plane geometry both halves draw their sections with.

R_OUT   = 53.5;
ANG     = [190, 230];                    // the radial edges, degrees
K1_C    = [-37.544, -5.026];             // K1's centre
K_R     = 4.0;                           // K1's radius (and A's round K2's)
BEAM_R  = 45.0;
BEAM_A  = [208.0, 216.5];                // B1, B2: degrees from +x
NAILS   = [[-48.362, -16.190], [-37.534, -34.529]];
NAIL_D  = 1.0;

function pol(r, a) = r * [cos(a), sin(a)];
function arc_pts(c, r, a0, a1, n = 48) =
    [for (i = [0 : n]) c + pol(r, a0 + (a1 - a0) * i / n)];
function ang(p) = (atan2(p[1], p[0]) + 360) % 360;   // 0 .. 360

// The point where the circle about the origin of radius ro meets the circle
// about c of radius rc, on the side of larger angle.
function circle_meet(c, ro, rc) = let(
    d = norm(c), x = (d * d + ro * ro - rc * rc) / (2 * d), h = sqrt(ro * ro - x * x),
    u = c / d) x * u + h * [-u[1], u[0]];

// The point where the radial edge at angle a meets the circle about c (radius rc).
function edge_meet(a, c, rc) = let(
    u = pol(1, a), b = u * c, t = b + sqrt(rc * rc - (c * c - b * b))) t * u;
