//! `outline`: hold a 2D profile a part is built from within a two-sided
//! Hausdorff distance of the reference mesh's section.
//!
//! A part drawn as stacked or swept profiles passes `layer="<layer>"` to
//! export one of them as an SVG, which is cut from the reference across
//! `axis` at `at` and compared before anything is extruded. A stacked part is
//! cut across z mid-layer; a part swept along another axis is cut across that
//! axis, in the coordinates `scadmesh slice` reports for it.
//!
//! Fields: `part`, `scad`, `out` (the SVG), `layer`, `reference` (under the
//! group's `ref_dir`), `axis`, `at`, `tol` in mm, and optionally `config`.

use super::{config_defines, reference_path, render_judged, Env, Fields, Report};
use anyhow::Result;

pub fn run(env: &Env, f: &Fields, rep: &mut Report) -> Result<()> {
    let (out, layer) = (f.str("out")?, f.str("layer")?);
    let mut defines = config_defines(f);
    defines.push(format!("layer=\"{layer}\""));
    render_judged(env, f.str("scad")?, out, &defines, rep)?;
    let (axis, at, tol) = (f.str("axis")?, f.f64("at")?, f.f64("tol")?);
    let reference = reference_path(env, f)?;
    let (at_flag, tol_text) = (format!("--at={at}"), tol.to_string());
    let (ok, report) = env.tools.scadmesh(&["outline", out, &reference, "--axis", axis, &at_flag, "--tol", &tol_text])?;
    let num = |k: &str| report[k].as_f64().unwrap_or(f64::NAN);
    rep.record(
        &format!(
            "{} {layer} profile vs section at {axis} {at} (hausdorff {:.3} mm, tol {tol} mm; area {:.3} vs {:.3} mm2)",
            f.str("part")?,
            num("hausdorff"),
            num("candidate_area"),
            num("reference_area"),
        ),
        ok,
    );
    Ok(())
}

#[cfg(test)]
mod tests {
    use crate::kinds::testing::*;
    use serde_json::json;

    fn fields() -> serde_json::Value {
        json!({"part": "100-003", "scad": "p.scad", "out": "out/2d/100-003-skirt.svg", "config": "previous",
               "layer": "skirt", "reference": "p.stl", "axis": "y", "at": -4.0, "tol": 0.15})
    }

    #[test]
    fn cuts_the_reference_on_the_axis_and_names_both_areas() {
        let report = json!({"hausdorff": 0.1306, "candidate_area": 425.8, "reference_area": 427.2});
        let fake = Fake::new().with("outline", report);
        let o = check("outline", fields(), &fake);
        assert!(
            o.ok && o.output.contains(
                "100-003 skirt profile vs section at y -4 (hausdorff 0.131 mm, tol 0.15 mm; area 425.800 vs 427.200 mm2)"
            ),
            "{}",
            o.output
        );
        let calls = fake.calls();
        assert_eq!(calls[0], "openscad -o out/2d/100-003-skirt.svg -D config=\"previous\" -D layer=\"skirt\" p.scad");
        assert_eq!(calls[1], "scadmesh outline out/2d/100-003-skirt.svg ref/p.stl --axis y --at=-4 --tol 0.15");
    }

    #[test]
    fn a_profile_over_tolerance_fails_and_a_missing_report_reads_nan() {
        let mut fake = Fake::new();
        fake.scadmesh_ok = false;
        let o = check("outline", fields(), &fake);
        assert!(!o.ok && o.output.contains("NaN"), "{}", o.output);
    }
}
