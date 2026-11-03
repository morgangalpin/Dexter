// Photointerrupter shroud features shared by #821 .. #825. No part and no
// top-level geometry: it only defines modules.
//
// Each shroud straddles its joint's code disk. An emitter (C-704) and a
// detector (C-705), both Lite-On T-1 packages, face each other across the
// disk along two beam axes parallel to the disk's axis, one per encoder
// channel, on one radius of the slit track. The beam bore that holds them is
// the feature every shroud shares: along its axis it is a run of sections,
//
//     "round"  a circle of diameter a
//     "flat"   a circle of diameter a, cut flat at local x = b (the package's
//              flange flat); the flat keeps its local x whatever the spin
//     "slit"   a circle of diameter a cut to a radial slit b wide, which is
//              the aperture across the disk; it turns with the spin
//     "key"    a circle of diameter a with a radial slot b wide running from
//              its centre in towards the disk's axis (out through a jaw's
//              underside); it turns with the spin
//     "cone"   a cone from diameter a to diameter b, cut flat at local x = c
//              when a sixth value c is given
//
// The packages' body, T1_BODY_D, is every shroud's press-fit mate. Their
// flange's diameter is not on record; every shroud seats it in a counterbore
// of Ø4.0 or more, taken as clearance round the flange, so a counterbore keeps
// its drawn size and only a flat that keys the flange is a fit.

T1_BODY_D = 3.0;      // C-704 / C-705 T-1 body

// Each section is written [z0, z1, kind, a, b] in the bore's local frame: the beam axis
// on +z, local x across the part, local y pointing in towards the disk's axis
// before the spin. A part places the bore on its beam axis, spins it so the
// slit lies radial, and states every section's numbers in its own header.

module beam_section_2d(s, spin) {
    d = s[3];
    if (s[2] == "round") circle(d = d);
    else if (s[2] == "flat") intersection() {
        circle(d = d);
        translate([s[4] - 2 * d, -d]) square([2 * d, 2 * d]);
    }
    else if (s[2] == "slit") intersection() {
        circle(d = d);
        rotate(spin) square([s[4], 2 * d], center = true);
    }
    else if (s[2] == "key") union() {
        circle(d = d);
        rotate(spin) translate([-s[4] / 2, 0]) square([s[4], 10 * d]);
    }
}

// One beam bore. `lap` runs each section a little into the next, so the
// cutter has no internal faces.
module beam_bore(segs, spin = 0, lap = 0.005) {
    for (s = segs) translate([0, 0, s[0] - lap])
        if (s[2] == "cone") beam_cone(s, s[1] - s[0] + 2 * lap);
        else linear_extrude(s[1] - s[0] + 2 * lap) beam_section_2d(s, spin);
}

// A "cone" section, cut flat at local x = s[5] when it is given.
module beam_cone(s, h) intersection() {
    cylinder(h = h, d1 = s[3], d2 = s[4]);
    if (len(s) > 5) translate([s[5] - 2 * s[4], -s[4], 0]) cube([2 * s[4], 2 * s[4], h]);
}

// A vertical (local z) hole run of [z0, z1, d] steps at (x, y).
module stepped_hole(at, steps, lap = 0.005) {
    for (s = steps) translate([at[0], at[1], s[0] - lap])
        cylinder(h = s[1] - s[0] + 2 * lap, d = s[2]);
}
