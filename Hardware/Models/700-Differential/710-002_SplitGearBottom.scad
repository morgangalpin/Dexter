// #710-002 Split Gear Bottom -- parametric source (DC-2).
// The inner half of the split output bevel gear: it presses into the Split
// Gear Top (008.6 step 8) and carries the apex-side half of the 20 bevel
// teeth. Tooth clocking against the Top half is set during assembly by
// driving brads through the four radial holes (008.6 steps 8-9).
//
// STRUCTURE -- this mirrors how the part was actually authored. The reference
// STL is an assembly export holding two *unmerged* solids, which
//   scadmesh segment ../Reference/meshes/700-Differential/710-002_SplitGearBottom.stl
// separates: a turned body (Ø27, z 4..22, 5732.609 mm3, tessellated at
// 3.85 tris/mm2) and a tooth crown (Ø34.81, z 18.5..27.368, 1619.975 mm3, at
// 6.91 tris/mm2). They sum to the 7352.584 mm3 the whole file encloses. The
// two densities are the giveaway: a single body is never meshed two ways, so
// these were separate solids unioned only at export. This file rebuilds them
// the same way -- revolve a body, revolve a crown blank, stand the teeth on
// it, drill the brads -- rather than carving one blank.
//
// It rebuilds them merged, which is what a finished part is, and that is the
// one way the reference cannot be matched. An unmerged export keeps both
// solids' whole boundaries, the crown's included where it runs inside the
// body, and a merged model has no such surface to offer; see the crown's
// bottom face below for what that costs a vertex-matching comparison.
// Measured on the surfaces instead of on the vertices the two agree:
// `scadmesh surface`, which sweeps radius fields and so is blind to
// tessellation, puts this render's envelope 0.010 mm from the reference at
// worst, at z 24.46, where the tooth tips meet the parting cone.
//
// The body profile is measured, not inferred from diameters and face heights:
//   scadmesh segment ... --out body.stl --keep 0
//   scadmesh profile body.stl --axis z --simplify 0.005
// That is what carries the convex flank between the Ø17 stub and the Ø27
// wall, which no list of diameters can express.
//
// THE CROWN IS NOT DEFINED HERE. This part carries half of the differential's
// one bevel gear; 710-001 carries the other half and the two side gears carry
// whole ones, so the gear lives in diff_bevel.scad. All this file supplies is
// where its apex sits on this axis -- the same apex 710-001 states -- and that
// this half keeps what lies INSIDE the 45-degree parting cone. Sections of this
// mesh supply exactly the material inside that cone which 710-001 lacks: at
// matching heights the two together enclose the same area as 720-002's whole
// tooth ring, to 0.007 mm2 in 858.
//
// An earlier revision generated the teeth with a BOSL2 bevel_gear() and got
// nothing: with the pitch apex on the axis at z 7 and a 45-degree pitch angle,
// that gear's teeth stand at r ~19, while this crown's material lies between
// r 12.2 and r 16.2, so the intersection met only the gear's solid hub.

include <diff_bevel.scad>

/* [Hidden] */

// Where the gear's apex sits on this part's axis. 710-001 states the same
// number; that the two halves share it is what puts them on one cone.
BEVEL_APEX_Z = 39.5770;

function cone_pt(cone, z) = [bevel_r(cone, z - BEVEL_APEX_Z), z];
function bevel_pt(p)      = [p.x, p.y + BEVEL_APEX_Z];

// ---------------------------------------------------------------- body ----
// Measured meridional profile of the turned body, [r, z]. Walk it from the
// bottom bore lip: up the funnel, out through the bore ladder, across the top
// face, down the Ø27 wall, through the convex flank, and back along the stub.
//
// Axial positions come from a single meridional section, which measures them
// exactly -- facets run parallel to the axis, so they cannot bias a height.
// Radii on the turned surfaces are circle fits over full horizontal sections
// (`scadmesh slice`), which average the facets out; a single cut reads a
// bore's *inscribed* radius, low by r*(1 - cos(pi/n)).
//
// Three things measured on this section are not turned features and are not
// carried here. A 0.003 mm wall at Ø13 spanning z 4..13 is one of the
// assembly export's zero-thickness internal shells. The dip to Ø24 across
// z 12.0..13.5 is the brad hole the cutting plane happens to pass through;
// it is drilled below as four discrete holes. A ring of vertices at z 17.250
// on the Ø27 wall is a tessellation seam rather than a step: the reference
// changes triangulation density across it, from 430 outline points below to
// 308 above, at one diameter and one area -- Ø27.000 and 572.397 mm2 are read
// on both sides -- so there is nothing there to model, and the ring stands as
// a 0.250 mm plane mismatch.
//
// A fourth is deliberate. The reference's funnel and Ø8.5 wire bore are not on
// the axis: circle fits at z 6.3, 6.5, 6.6, 6.7 and 6.9 all centre them on
// (-0.039, 0.138), 0.143 mm off it, while every turned surface around them fits
// the axis to 0.001 mm. That is a slip in the original, not a feature -- it is
// a clearance hole for wire -- so the bore is modelled concentric and the
// 0.143 mm shows up as this part's whole excursion past the 0.15 mm tolerance,
// 0.011% of samples.
BODY_PROFILE = [
    [ 6.500,  4.000],   // bottom face, Ø13 bore mouth
    [ 6.500,  4.500],   // Ø13 wall -- the lip inside the bottom opening
    [ 6.250,  4.500],   // step in to the funnel mouth, 0.25 mm wide
    [ 4.250,  6.500],   // 45-degree funnel down to the wire bore
    [ 4.250, 13.500],   // Ø8.5 wire bore
    [ 6.000, 13.500],   // Ø12 MR128 seat
    [ 6.000, 17.000],
    [ 9.000, 17.000],   // Ø18 sleeve bore
    [ 9.000, 21.000],
    [12.000, 21.000],   // Ø24 mouth (buried: the crown's Ø23 bore is smaller)
    [12.000, 22.000],
    [13.500, 22.000],   // top face, outer
    [13.500, 11.000],   // Ø27 wall
    [12.900, 10.692],   // convex flank, stub-ward
    [12.292, 10.399],
    [11.677, 10.124],
    [11.054,  9.865],
    [10.424,  9.623],
    [ 9.789,  9.398],
    [ 9.135,  9.184],
    [ 9.000,  9.119],
    [ 8.877,  9.035],
    [ 8.767,  8.933],
    [ 8.674,  8.816],
    [ 8.599,  8.687],
    [ 8.544,  8.548],
    [ 8.511,  8.402],
    [ 8.500,  8.253],
    [ 8.500,  4.000],   // Ø17 wire-guide stub
];

// The bottom lip, stated once because it is easy to lose in simplification:
// the Ø13 mouth is a straight wall from the bottom face to z 4.5, and the
// funnel starts 0.25 mm inboard of it. Sections read Ø13.000 (rms 0.0000) up
// to z 4.45 and the funnel at r 6.1998 by z 4.55; the funnel's 45 degrees
// extrapolate back to r 6.25 at z 4.5 exactly.

// Brad holes: four radial Ø1.5 holes on Ø27, floored at Ø24. The meridional
// section reads the hole at 0 degrees as a 1.496 mm tall notch spanning
// z 12.002..13.498 at r 12.000 -- a Ø1.5 bore centred at z 12.75, drilled to
// a radius of 12. The #680-001 brad (BRAD_D = 1.8) is larger, so it presses in.
BRAD_HOLE_D = 1.5;
BRAD_Z      = 12.75;
BRAD_FLOOR  = 12.0;     // drilled depth, as a radius
BRAD_A      = [0, 90, 180, 270];
assert(BRAD_D > BRAD_HOLE_D, "brad must be an interference fit in its hole");

// --------------------------------------------------------------- crown ----
// The blank the teeth stand on. Only the Ø23 bore is this part's own; the
// other three sides are the gear's parting, root and inner cones, taken from
// diff_bevel.scad rather than restated.
//
// The bore's bottom and the parting cone's foot are the same point: the cone
// r = z - 7 passes through (11.500, 18.500) exactly, which is what lets the
// crown's outer face be the surface 710-001 presses onto.
//
// That point is a knife edge and not a face: sections read the bore at
// Ø23.000 and the parting cone at Ø23.020 by z 18.51. In the reference it is
// nonetheless the heaviest plane in the file, 11088 vertices on that one
// edge, because the crown is a solid in its own right there. It is buried --
// probes at z 18.5 return material from r 9 to r 13.5, so the edge lies 2 mm
// inside the body -- and a merged model therefore cannot put a vertex on it.
// That absence is the largest mismatch a vertex-matching comparison of this
// part reports, 1.500 mm, and no change to the geometry can close it.
//
// Where the root cone dives inside the inner cone, at (11.985, 25.338), the
// teeth part company with the blank -- and the slots between them therefore
// have no floor. Sections return one lobed ring up to z 25.30 and 20 separate
// prongs from z 25.32, which is that crossing. Reading the transition as a flat
// slot floor -- which loop counting alone invites, since a lobed ring is still
// a single loop -- left an earlier revision with a full-radius ring wherever
// the teeth should have been separated, wrong by 1.9 mm at the worst point.
CROWN_BORE_D = BRG_6703[1];     // Ø23, the 6703 outer race
CROWN_Z0     = 18.500;          // crown's bottom face, on the parting cone
CROWN_BLANK  = [
    [CROWN_BORE_D / 2, CROWN_Z0],
    bevel_pt(BEVEL_SPLIT_ROOT),     // up the parting cone to the tooth roots
    bevel_pt(BEVEL_INNER_ROOT),     // in along the root cone
    cone_pt(BEVEL_INNER, bevel_z(BEVEL_INNER, CROWN_BORE_D / 2)
                         + BEVEL_APEX_Z),   // in along the inner cone, to bore
];
assert(abs(bevel_r(BEVEL_SPLIT, CROWN_Z0 - BEVEL_APEX_Z) - CROWN_BORE_D / 2)
       < 0.01, "the crown's bottom face is not on the parting cone");

// The bevel: the blank, plus this half's twenty teeth. BEVEL_ENVELOPE_INNER is
// bounded outside by the parting cone, so what it keeps is exactly what
// 710-001's envelope does not.
module crown() {
    rotate_extrude() polygon(CROWN_BLANK);
    up(BEVEL_APEX_Z) bevel_crown(BEVEL_ENVELOPE_INNER);
}

module split_gear_bottom() {
    difference() {
        union() {
            rotate_extrude() polygon(BODY_PROFILE);
            crown();
        }
        for (a = BRAD_A)
            zrot(a) up(BRAD_Z) right(BRAD_FLOOR) yrot(90)
                cyl(d = BRAD_HOLE_D, h = BEVEL_OD / 2 - BRAD_FLOOR, anchor = BOTTOM);
    }
}

split_gear_bottom();
