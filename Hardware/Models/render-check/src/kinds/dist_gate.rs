//! `dist_gate`: render a part and hold its surface within a two-sided
//! Hausdorff distance of its reference mesh.
//!
//! `compare` matches extracted feature planes and diameters, so a part can
//! satisfy every mating interface while its shell is nothing like the
//! reference. The gate measures the surfaces themselves, so a missing feature
//! or a wrong hole shape is charged.
//!
//! Fields: `part`, `scad`, `out`, `reference` (under the group's `ref_dir`),
//! `tol` in mm, and optionally `config`.

use super::{config_defines, reference_path, render_judged, Env, Fields, Report};
use anyhow::Result;

pub fn run(env: &Env, f: &Fields, rep: &mut Report) -> Result<()> {
    let out = f.str("out")?;
    render_judged(env, f.str("scad")?, out, &config_defines(f), rep)?;
    let tol = f.f64("tol")?.to_string();
    let reference = reference_path(env, f)?;
    let (ok, report) = env.tools.scadmesh(&["dist", out, &reference, "--tol", &tol])?;
    let worst = report["hausdorff"].as_f64().unwrap_or(f64::NAN);
    rep.record(&format!("{} surface vs reference (hausdorff {worst:.3} mm, tol {tol} mm)", f.str("part")?), ok);
    Ok(())
}

#[cfg(test)]
mod tests {
    use crate::kinds::testing::*;
    use serde_json::json;

    fn fields() -> serde_json::Value {
        json!({"part": "730-001", "scad": "a.scad", "out": "out/a.stl", "config": "previous", "reference": "a.stl", "tol": 0.15})
    }

    #[test]
    fn measures_the_render_against_the_reference() {
        let fake = Fake::new().with("dist", json!({"hausdorff": 0.1234}));
        let o = check("dist_gate", fields(), &fake);
        assert!(o.ok && o.output.contains("730-001 surface vs reference (hausdorff 0.123 mm, tol 0.15 mm)"), "{}", o.output);
        assert_eq!(fake.calls()[1], "scadmesh dist out/a.stl ref/a.stl --tol 0.15");
    }

    #[test]
    fn a_surface_over_tolerance_fails() {
        let mut fake = Fake::new().with("dist", json!({"hausdorff": 0.9}));
        fake.scadmesh_ok = false;
        assert!(!check("dist_gate", fields(), &fake).ok);
    }
}
