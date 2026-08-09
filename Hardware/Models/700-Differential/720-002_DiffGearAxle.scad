// #720-002 Diff Gear Axle — parametric source (DC-2).
// One of the two side bevels of the wrist differential: a 20T straight bevel
// crown on a hub bored Ø8 for the CF rod, with a Ø9 boss at the top.
//
// Authored in the reference mesh's own coordinates, which already base the
// part at z = 0, so it compares to 720-002_DiffGearAxle.stl without alignment.
// The reference is a single merged solid (scadmesh segment), so both
// directions of `dist` are meaningful against it.
//
// Built the way the reference was built:
//   1. revolve the measured meridional profile      -> hub, root cone, skirt
//   2. loft one tooth about the gear's apex, x20    -> the bevel crown
//
// The crown is governed by four cones, and every one of them was recovered by
// fitting measured radius against height rather than assumed from gear theory:
//
//   skirt (lower tip)   r = 14.89283 + 1.44762 z
//   upper tip           r = 27.69775 - 1.14793 z
//   root                r = 20.38555 - 0.84936 z    apex on the axis at 24.001
//   tooth inner face    r = z + 2.0954              45 deg
//
// Their four intersections define the crown outright, and each was checked
// against an independent measurement rather than trusted:
//
//   root ^ skirt   z =  2.3913, r = 18.3545   teeth begin (mesh face at 2.429)
//   skirt ^ tip    z =  4.9334, r = 22.0346   the tip crown ring
//   root ^ inner   z =  9.8899, r = 11.9853   teeth part company with the hub
//   inner ^ tip    z = 11.9195, r = 14.0149   the tooth's top corner
//
// The last two are the useful ones. Horizontal sections show the teeth turning
// into 20 free-standing islands between z = 9.70 and 9.90, which is where
// root ^ inner says they must; and the meridional profile independently
// reports the tooth's top corner at (14.007, 11.919) against the computed
// (14.0149, 11.9195). The root cone's slope also lands within 0.07% of
// 710-002's, as two halves of a 1:1 bevel pair should.
//
// Because the teeth are straight bevel teeth, their flanks are ruled surfaces
// through the gear apex: a section scales linearly with distance from it. One
// measured section therefore reproduces the whole tooth exactly, lofted
// between two scaled copies -- a hull between them IS the ruled surface, with
// no approximation. That is why this part needs one section where 710-002
// needed seventeen: 710-002's crown had to be lofted through measured
// sections because its own flanks were not recoverable this way.
//
// One reference defect must NOT be reproduced. The bottom face is triangulated
// with a coarse inner boundary while the bore wall beside it carries 104
// facets, so 18 of its triangles (38.9 mm² in total) cut chords straight
// across the Ø8 bore, reaching in to r = 2.65. Sections taken 0.01 mm above
// that face show the bore clean and round at Ø8.000, so the flaps are a
// tessellation artifact of the export and not a counterbore. They are the
// whole of this part's reference→candidate distance: 1.338 mm max over 0.198%
// of samples, against a p95 of 0.029 mm. Candidate→reference, which the
// artifact cannot reach, is 0.100 max / 0.012 RMS / 0.029 p95.

include <diff_params.scad>

/* [Hidden] */
Z_TOP = 14.000;    // top face of the boss

// Meridional outline, measured (scadmesh profile) for the hub and the fillet,
// and continued down the fitted root and skirt cones, which the profile itself
// cannot see: its cutting plane is fixed on the x-z plane and this part has a
// tooth centred there, so below the fillet it reports the tooth, not the hub.
// The fillet points were each confirmed against a horizontal section (11.233
// at z = 11.0, 11.596 at 10.5, 11.826 at 10.0 -- all within 0.001 mm).
BODY_PROFILE = [
    [ 4.000,  0.000],   // Ø8 rod bore, bottom
    [ 4.000, 14.000],   // Ø8 rod bore, top
    [ 4.087, 13.992],   // roundover onto the boss top face
    [ 4.152, 13.976],
    [ 4.219, 13.949],
    [ 4.284, 13.911],
    [ 4.343, 13.864],
    [ 4.396, 13.805],
    [ 4.441, 13.735],
    [ 4.478, 13.640],
    [ 4.500, 13.500],
    [ 4.500, 12.000],   // Ø9 boss
    [ 9.000, 12.000],   // shoulder out to the hub
    [ 9.203, 11.993],   // hub fillet, sweeping down to the tooth roots
    [ 9.492, 11.958],
    [ 9.710, 11.915],
    [ 9.886, 11.866],
    [10.064, 11.805],
    [10.245, 11.729],
    [10.428, 11.638],
    [10.610, 11.530],
    [10.834, 11.373],
    [10.999, 11.236],
    [11.152, 11.089],
    [11.294, 10.933],
    [11.424, 10.767],
    [11.541, 10.594],
    [11.646, 10.414],
    [11.738, 10.226],
    [11.817, 10.030],
    [11.892,  9.793],   // undercut at the base of the tooth's inner face
    [12.150,  9.700],   // back on the root cone (measured 12.1495)
    [18.354,  2.391],   // root cone, down to where the teeth begin
    [14.893,  0.000],   // skirt cone, down to the bottom face
];

// The four cones, as fitted.
APEX_Z     = 24.001;                        // root cone apex, on the axis
SECTION_Z  = 6.000;                         // height the tooth was measured at
CROWN_ENVELOPE = [                          // bounds the teeth; see above
    [ 4.4867,  2.3913],                     // inner cone, at the tooth start
    [18.3545,  2.3913],                     // root ^ skirt
    [22.0346,  4.9334],                     // skirt ^ tip, the crown ring
    [14.0149, 11.9195],                     // inner ^ tip, the tooth top
];
TOOTH_Z = [2.200, 12.100];                  // loft ends, outside the envelope
SLAB    = 0.001;

// tooth cross-section measured at z = 6, hulled; two points pushed
// inward to r = root - 0.45 so the tooth seats into the body.
TOOTH_SECTION = [
    [14.7611, -1.5222],
    [15.2538, -1.573],
    [16.0742, -1.5936],
    [16.1293, -1.5949],
    [16.1736, -1.5954],
    [16.1946, -1.5957],
    [16.2702, -1.5954],
    [16.3561, -1.594],
    [16.4228, -1.592],
    [16.4525, -1.5911],
    [16.5271, -1.5878],
    [16.5594, -1.5864],
    [16.6771, -1.5796],
    [16.7683, -1.5731],
    [16.8055, -1.5705],
    [16.9055, -1.5619],
    [16.9447, -1.5586],
    [17.0951, -1.5437],
    [17.2138, -1.5304],
    [17.2567, -1.5255],
    [17.4296, -1.5037],
    [17.5684, -1.4842],
    [17.6141, -1.4778],
    [17.7636, -1.4547],
    [17.8102, -1.4475],
    [18.0182, -1.4125],
    [18.1906, -1.381],
    [18.2383, -1.3723],
    [18.4707, -1.3266],
    [18.7155, -1.275],
    [18.973, -1.217],
    [19.1975, -1.1632],
    [19.2435, -1.1522],
    [19.3468, -1.1259],
    [19.5271, -1.0801],
    [19.8241, -1.0002],
    [20.0941, -0.9237],
    [20.1348, -0.9121],
    [20.4593, -0.8152],
    [20.7981, -0.709],
    [20.7981, 0.709],
    [20.4593, 0.8152],
    [20.1348, 0.9121],
    [20.0941, 0.9237],
    [19.8241, 1.0002],
    [19.5271, 1.0801],
    [19.4825, 1.0914],
    [19.2435, 1.1522],
    [19.1975, 1.1632],
    [18.973, 1.217],
    [18.7155, 1.275],
    [18.4707, 1.3266],
    [18.2383, 1.3723],
    [18.1906, 1.381],
    [18.0182, 1.4125],
    [17.8102, 1.4475],
    [17.7636, 1.4547],
    [17.6141, 1.4778],
    [17.5684, 1.4842],
    [17.4296, 1.5037],
    [17.2567, 1.5255],
    [17.2138, 1.5304],
    [17.0951, 1.5437],
    [16.9447, 1.5586],
    [16.9055, 1.5619],
    [16.8055, 1.5705],
    [16.7683, 1.5731],
    [16.6771, 1.5796],
    [16.5594, 1.5864],
    [16.5271, 1.5878],
    [16.4525, 1.5911],
    [16.4228, 1.592],
    [16.3561, 1.594],
    [16.2702, 1.5954],
    [16.1946, 1.5957],
    [16.1736, 1.5954],
    [16.1293, 1.5949],
    [16.0742, 1.5936],
    [16.0595, 1.5931],
    [16.0293, 1.5919],
    [15.9943, 1.5901],
    [15.9777, 1.589],
    [15.9694, 1.5885],
    [15.9546, 1.5873],
    [15.9497, 1.5869],
    [14.7665, 1.4692],
];

// Radial scale of the tooth section at height z. Linear, because every tooth
// surface is ruled through the apex.
function tooth_scale(z) = (APEX_Z - z) / (APEX_Z - SECTION_Z);

// One tooth, as the exact ruled solid between two scaled copies of the
// measured section. The ends sit outside the envelope, which trims them.
module tooth() {
    hull() {
        up(TOOTH_Z[0]) linear_extrude(SLAB)
            scale(tooth_scale(TOOTH_Z[0])) polygon(TOOTH_SECTION);
        up(TOOTH_Z[1]) linear_extrude(SLAB)
            scale(tooth_scale(TOOTH_Z[1])) polygon(TOOTH_SECTION);
    }
}

// The crown: twenty teeth, trimmed to the cone envelope. The envelope's inner
// bound is the tooth's 45-degree inner face, not the root cone, so each tooth
// runs on past the root and buries itself in the hub. That keeps the union
// with the body an overlap rather than a shared face, and leaves the visible
// root surface to the body, where it was measured.
module crown() {
    intersection() {
        rotate_extrude() polygon(CROWN_ENVELOPE);
        zrot_copies(n = BEVEL_TEETH) tooth();
    }
}

// The clip holds the tip crown to the 44.055 datum. The two tip cones cross
// at r = 22.0346 where the mesh's extreme vertex is 22.0275, so the reference
// crown ring carries about 0.007 mm of break; the clip reproduces it and keeps
// the outside diameter on the number the rest of the design quotes.
module diff_gear_axle() {
    intersection() {
        union() { rotate_extrude() polygon(BODY_PROFILE); crown(); }
        down(epsilon) cyl(d = BEVEL_OD, h = Z_TOP + 2*epsilon, anchor = BOTTOM);
    }
}

diff_gear_axle();
