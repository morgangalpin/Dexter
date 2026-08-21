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
//   2. drop the shared crown on at the gear's apex  -> the bevel
//
// The crown is not defined here. It is the differential's one bevel gear,
// defined once in diff_bevel.scad and carried identically by this part, by both
// halves of the Split Gear, and by the Diff Gear Shaft. All this file supplies
// is where the gear's apex sits on this part's axis. The four cones that govern
// the crown were fitted on THIS part's reference mesh -- it is the only one of
// the three that carries a whole, unsplit tooth -- so the shared file's numbers
// and this part's geometry are the same measurement.
//
// The hub's own profile ends on those same cones rather than repeating them:
// the root cone carries the tooth roots down to where the teeth begin, and the
// heel cone carries the skirt from there to the bottom face.
//
// Two reference defects share the bottom face, and neither may be reproduced.
//
// The face is triangulated with a coarse inner boundary while the bore wall
// beside it carries 104 facets, so 18 of its triangles (38.9 mm² in total) cut
// chords straight across the Ø8 bore, reaching in to r = 2.65. Sections taken
// 0.01 mm above that face show the bore clean and round at Ø8.000, so the
// flaps are a tessellation artifact of the export and not a counterbore. They
// are the whole of this part's reference→candidate distance.
//
// The same face also carries a seam at Ø17.000, drawn as a regular 27-gon
// inscribed on that circle: its vertices sit at r = 8.500000 exactly, 360/27 =
// 13.3333 degrees apart, and the subdivision points along each chord fall away
// to the polygon's inradius, 8.5 cos(180/27) = 8.44253. All 1366 vertices
// involved lie at z = 0.000000, so the seam bounds no step; and over a
// 97-degree sector inside it, 66 facets are duplicated with their normals
// reversed. That makes the region an internal coplanar face of the assembly
// export rather than part geometry, so a revolved bottom face neither can
// carry it nor should. It has to be read for what it is, because the
// measurement it produces is loud: `scadmesh compare` clusters the seam's
// vertices into a band of weighted mean Ø16.9248, finds no candidate radius
// near it, and matches it instead to the Ø18.000 hub shoulder, reporting
// 1.075 mm against a surface that is in fact flat and exact. The band belongs
// in the harness's ignore list, not in this profile.

include <diff_bevel.scad>

/* [Hidden] */
Z_TOP = 14.000;         // top face of the boss

// Where the gear's apex sits on this part's axis. Everything conical about the
// crown follows from this one number and diff_bevel.scad, which is where the
// number itself is stated so the assembly can read it too.
BEVEL_APEX_Z = BEVEL_APEX_AXLE;

function cone_pt(cone, z) = [bevel_r(cone, z - BEVEL_APEX_Z), z];
function bevel_pt(p)      = [p.x, p.y + BEVEL_APEX_Z];

// Meridional outline, measured (scadmesh profile) for the hub and the fillet,
// and continued down the fitted root and heel cones, which the profile itself
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
    cone_pt(BEVEL_ROOT, 9.700),     // back on the root cone (measured 12.1495)
    bevel_pt(BEVEL_HEEL_ROOT),      // root cone down to where the teeth begin
    cone_pt(BEVEL_HEEL, 0.000),     // heel cone down to the bottom face
];

// Twenty teeth, trimmed to the whole-gear envelope. The envelope's inner bound
// is the tooth's 45-degree inner face, not the root cone, so each tooth runs on
// past the root and buries itself in the hub: the union is then an overlap
// rather than a shared face, and the visible root surface belongs to the hub,
// where it was measured.
module crown() {
    up(BEVEL_APEX_Z) bevel_crown(BEVEL_ENVELOPE);
}

module diff_gear_axle() {
    union() {
        rotate_extrude() polygon(BODY_PROFILE);
        crown();
    }
}

diff_gear_axle();
