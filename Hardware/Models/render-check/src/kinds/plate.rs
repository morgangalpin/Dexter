//! `plate`: an authored plate bolts to the part it exists to bolt to. The plate
//! has no reference mesh and most of its geometry is a free choice; exactly one
//! thing about it is not: its robot-side holes must line up with the mounting
//! holes on a reference part. The centres are read off that mesh rather than
//! copied from a spec, because a transcription this check trusted would be a
//! transcription nothing checks.
//!
//! The joint has real slack (the plate is tapped and the mount's holes are
//! clearance), but a tapped hole cannot be nudged on assembly, so `centre_tol`
//! is held far tighter than that slack. Both meshes are exports, so a few
//! hundredths of meshing noise has to be allowed.
//!
//! Fields: `scad`, `out` (the plate's mesh), `drawing` (the machining drawing,
//! rendered with `PROJECT=1`), `size` (the plate's extents in mm), `reference`
//! (the mount's mesh, relative to the group), `reference_at` and
//! `reference_diameter` and `reference_count` (the section of the mount that
//! holds exactly its mounting holes), `plate_at` (the plate's own section),
//! `tapped_diameter`, `bench_diameter` and `bench_count`, and optionally
//! `centre_tol` and `diameter_tol` in mm (both 0.05) and `size_tol` (0.01).

use super::{render_judged, Env, Fields, Report};
use anyhow::{Context, Result};
use serde_json::Value;

/// A loop's circle fit may not be worse than this to count as a hole.
const MAX_RMS: f64 = 0.05;

/// A loop of a section: centre, diameter and circle-fit rms.
struct Hole {
    centre: [f64; 2],
    diameter: f64,
    rms: f64,
}

pub fn run(env: &Env, f: &Fields, rep: &mut Report) -> Result<()> {
    let (scad, stl) = (f.str("scad")?, f.str("out")?);
    render_judged(env, scad, stl, &[], rep)?;
    render_judged(env, scad, f.str("drawing")?, &["PROJECT=1".into()], rep)?;
    check_size(env, f, rep)?;
    let tol = f.f64_or("diameter_tol", 0.05);
    let wanted = f.u64("reference_count")? as usize;
    let mount = holes(&section(env, f.str("reference")?, f.f64("reference_at")?)?, f.f64("reference_diameter")?, tol);
    rep.record(&format!("the mount has {} mounting holes, expected {wanted}", mount.len()), mount.len() == wanted);
    let plate = section(env, stl, f.f64("plate_at")?)?;
    check_pattern(&holes(&plate, f.f64("tapped_diameter")?, tol), &mount, f.f64_or("centre_tol", 0.05), rep);
    let bench = holes(&plate, f.f64("bench_diameter")?, tol).len();
    let want = f.u64("bench_count")? as usize;
    rep.record(&format!("bench side has {bench} holes, expected {want}"), bench == want);
    Ok(())
}

fn check_size(env: &Env, f: &Fields, rep: &mut Report) -> Result<()> {
    let (_, bbox) = env.tools.scadmesh(&["bbox", f.str("out")?])?;
    let want = f.f64_list("size")?;
    let tol = f.f64_or("size_tol", 0.01);
    let got: Vec<f64> = (0..3).map(|i| bbox["size_mm"][i].as_f64().unwrap_or(f64::NAN)).collect();
    let ok = want.len() == 3 && got.iter().zip(&want).all(|(g, w)| (g - w).abs() <= tol);
    rep.record(&format!("plate is {:.3} x {:.3} x {:.3} mm, expected {:?}", got[0], got[1], got[2], want), ok);
    Ok(())
}

fn section(env: &Env, stl: &str, at: f64) -> Result<Vec<Hole>> {
    let at = format!("--at={at}");
    let (_, json) = env.tools.scadmesh(&["slice", stl, "--axis", "z", &at])?;
    let num = |v: &Value| v.as_f64().unwrap_or(f64::NAN);
    let loops = json["loops"].as_array().with_context(|| format!("{stl} has no loops at {at}"))?;
    Ok(loops
        .iter()
        .map(|l| Hole { centre: [num(&l["circle"]["center"][0]), num(&l["circle"]["center"][1])], diameter: num(&l["circle"]["radius"]) * 2.0, rms: num(&l["circle"]["rms"]) })
        .collect())
}

/// Round-trip a coordinate to kill export noise before sorting and printing.
fn tidy(p: [f64; 2]) -> [f64; 2] {
    [(p[0] * 1e3).round() / 1e3, (p[1] * 1e3).round() / 1e3]
}

/// The centres of the clean circles of `nominal` diameter, in a stable order.
fn holes(loops: &[Hole], nominal: f64, tol: f64) -> Vec<[f64; 2]> {
    let mut found: Vec<[f64; 2]> =
        loops.iter().filter(|h| (h.diameter - nominal).abs() < tol && h.rms < MAX_RMS).map(|h| tidy(h.centre)).collect();
    found.sort_by(|a, b| a[0].total_cmp(&b[0]).then(a[1].total_cmp(&b[1])));
    found
}

fn check_pattern(plate: &[[f64; 2]], mount: &[[f64; 2]], tol: f64, rep: &mut Report) {
    if plate.len() != mount.len() {
        return rep.record(&format!("plate has {} tapped holes, the mount has {}", plate.len(), mount.len()), false);
    }
    let dist = |p: &[f64; 2], r: &[f64; 2]| ((p[0] - r[0]).powi(2) + (p[1] - r[1]).powi(2)).sqrt();
    let worst = plate.iter().zip(mount).map(|(p, r)| dist(p, r)).fold(0.0_f64, f64::max);
    rep.record(&format!("robot-side {} holes, worst offset {worst:.3} mm (tol {tol} mm)", plate.len()), worst <= tol);
}

#[cfg(test)]
mod tests {
    use crate::kinds::testing::*;
    use serde_json::{json, Value};

    fn fields() -> Value {
        json!({"scad": "p.scad", "out": "out/p.stl", "drawing": "out/p.dxf", "size": [200, 200, 9.5], "reference": "m.stl",
               "reference_at": 0.5, "reference_diameter": 6.0, "reference_count": 2, "plate_at": -4.75,
               "tapped_diameter": 5.0, "bench_diameter": 6.6, "bench_count": 1})
    }

    fn lp(x: f64, y: f64, d: f64) -> Value {
        json!({"circle": {"center": [x, y], "radius": d / 2.0, "rms": 0.001}})
    }

    fn fake(plate_x: f64) -> Fake {
        let mut f = Fake::new().with("bbox", json!({"size_mm": [200.0, 200.0, 9.5]}));
        f.by_path.push(("slice m.stl", json!({"loops": [lp(10.0, 0.0, 6.0), lp(-10.0, 0.0, 6.0), lp(0.0, 0.0, 30.0)]})));
        f.by_path.push(("slice out/p.stl", json!({"loops": [lp(10.0, 0.0, 5.0), lp(plate_x, 0.0, 5.0), lp(50.0, 50.0, 6.6)]})));
        f
    }

    #[test]
    fn a_plate_whose_holes_land_on_the_mounts_passes() {
        let f = fake(-10.01);
        let o = check("plate", fields(), &f);
        assert!(o.ok, "{}", o.output);
        assert!(o.output.contains("robot-side 2 holes, worst offset 0.010 mm"), "{}", o.output);
        assert_eq!(f.calls()[1], "openscad -o out/p.dxf -D PROJECT=1 p.scad");
    }

    #[test]
    fn a_hole_off_its_centre_fails() {
        let o = check("plate", fields(), &fake(-10.2));
        assert!(!o.ok && o.output.contains("FAIL  robot-side 2 holes, worst offset 0.200"), "{}", o.output);
    }

    #[test]
    fn a_wrong_size_or_hole_count_fails() {
        let mut f = fake(-10.0);
        f.reports.insert("bbox", json!({"size_mm": [200.0, 200.0, 9.0]}));
        assert!(check("plate", fields(), &f).output.contains("FAIL  plate is 200.000 x 200.000 x 9.000"));
        let mut v = fields();
        v["reference_count"] = json!(3);
        assert!(check("plate", v, &fake(-10.0)).output.contains("FAIL  the mount has 2 mounting holes, expected 3"));
        let mut v = fields();
        v["bench_count"] = json!(4);
        assert!(check("plate", v, &fake(-10.0)).output.contains("FAIL  bench side has 1 holes, expected 4"));
        let mut missing = fake(-10.0);
        missing.by_path[1].1 = json!({"loops": [lp(10.0, 0.0, 5.0)]});
        assert!(check("plate", fields(), &missing).output.contains("plate has 1 tapped holes, the mount has 2"));
    }

    #[test]
    fn a_section_without_loops_is_an_error() {
        let mut f = fake(-10.0);
        f.by_path[0].1 = json!({});
        assert!(check("plate", fields(), &f).output.contains("has no loops"));
    }
}
