//! `fits`: the print fits of a render, each probed from its mate's nominal
//! surface in the part's own frame. A bought mate (a bearing, or a strake, rod
//! or tube bonded in) is a `press` fit; a printed mate or a fastener's
//! clearance is a `slip` fit. The clearances are read from the library every
//! part includes, so the checks follow it when a machine is qualified.
//!
//! Fields: `part` (the label), `stl`, `probes` (a list of `{label, at, toward,
//! fit}`, where `at` lies on the mate's surface and `toward` is the unit
//! direction from the part toward the mate), and optionally `print_fit`, the
//! library path (default `../print_fit.scad`). The part's wall must stand back
//! from `at` by the class clearance: a point halfway into that gap is void and
//! one just behind the wall is material.

use super::{Env, Fields, Report};
use crate::{fit_points, scad_constant, Fit, FitProbe};
use anyhow::{bail, Context, Result};

const DEFAULT_LIBRARY: &str = "../print_fit.scad";

pub fn run(env: &Env, f: &Fields, rep: &mut Report) -> Result<()> {
    let (slip, press) = clearances(env, f.str_or("print_fit", DEFAULT_LIBRARY))?;
    let probes = f.items("probes")?;
    let mut points = Vec::new();
    for p in &probes {
        let (gap, wall) = fit_points(&to_probe(p)?, if is_slip(p)? { slip } else { press });
        points.extend([gap, wall]);
    }
    let inside = solid(env, f.str("stl")?, &points)?;
    for (p, pair) in probes.iter().zip(inside.chunks(2)) {
        let class = if is_slip(p)? { "slip" } else { "press" };
        let label = format!("{} fit, {} ({class}): gap open, wall behind it", f.str("part")?, p.str("label")?);
        rep.record(&label, !pair[0] && pair[1]);
    }
    Ok(())
}

fn is_slip(p: &Fields) -> Result<bool> {
    match p.str("fit")? {
        "slip" => Ok(true),
        "press" => Ok(false),
        other => bail!("fit \"{other}\" is neither slip nor press"),
    }
}

fn to_probe(p: &Fields) -> Result<FitProbe> {
    let fit = if is_slip(p)? { Fit::Slip } else { Fit::Press };
    Ok(FitProbe { label: "", at: p.point("at")?, toward: p.point("toward")?, fit })
}

fn clearances(env: &Env, library: &str) -> Result<(f64, f64)> {
    let source = env.tools.read(library)?;
    let get = |name| scad_constant(&source, name).with_context(|| format!("{name} not in {library}"));
    Ok((get("FIT_SLIP")?, get("FIT_PRESS")?))
}

/// `scadmesh solid` inside/outside for each point, in order.
fn solid(env: &Env, stl: &str, points: &[[f64; 3]]) -> Result<Vec<bool>> {
    let flags: Vec<String> = points.iter().map(|p| format!("--probe={},{},{}", p[0], p[1], p[2])).collect();
    let mut args = vec!["solid", stl];
    args.extend(flags.iter().map(String::as_str));
    let (_, json) = env.tools.scadmesh(&args)?;
    let probes = json["probes"].as_array().context("scadmesh solid emitted no probes")?;
    Ok(probes.iter().map(|p| p["inside"].as_bool().unwrap_or(false)).collect())
}

#[cfg(test)]
mod tests {
    use crate::kinds::testing::*;
    use serde_json::{json, Value};

    const LIB: &str = "FIT_SLIP = 0.2;\nFIT_PRESS = 0.1;\n";

    fn fake(inside: &[bool]) -> Fake {
        let probes: Vec<Value> = inside.iter().map(|i| json!({"inside": i})).collect();
        let mut f = Fake::new().with("solid", json!({"probes": probes}));
        f.files.insert("../print_fit.scad", LIB);
        f
    }

    fn probes(fit: &str) -> Value {
        json!({"part": "710-003", "stl": "out/a.stl",
               "probes": [{"label": "bore", "at": [4, 0, 1], "toward": [-1, 0, 0], "fit": fit}]})
    }

    #[test]
    fn a_press_fit_probes_half_the_clearance_and_just_behind_the_wall() {
        let f = fake(&[false, true]);
        let o = check("fits", probes("press"), &f);
        assert!(o.ok && o.output.contains("710-003 fit, bore (press): gap open, wall behind it"), "{}", o.output);
        assert_eq!(f.calls(), vec!["scadmesh solid out/a.stl --probe=4.05,0,1 --probe=4.15,0,1"]);
    }

    #[test]
    fn a_slip_fit_uses_the_slip_clearance() {
        let f = fake(&[false, true]);
        assert!(check("fits", probes("slip"), &f).ok);
        assert_eq!(f.calls(), vec!["scadmesh solid out/a.stl --probe=4.1,0,1 --probe=4.25,0,1"]);
    }

    #[test]
    fn a_closed_gap_or_a_missing_wall_fails() {
        assert!(!check("fits", probes("press"), &fake(&[true, true])).ok);
        assert!(!check("fits", probes("press"), &fake(&[false, false])).ok);
    }

    #[test]
    fn a_bad_class_a_missing_library_or_a_missing_report_is_an_error() {
        assert!(check("fits", probes("loose"), &fake(&[false, true])).output.contains("neither slip nor press"));
        assert!(check("fits", probes("press"), &Fake::new()).output.contains("no file ../print_fit.scad"));
        let mut no_constants = Fake::new();
        no_constants.files.insert("../print_fit.scad", "");
        assert!(check("fits", probes("press"), &no_constants).output.contains("FIT_SLIP not in"));
        let mut empty = Fake::new();
        empty.files.insert("../print_fit.scad", LIB);
        assert!(check("fits", probes("press"), &empty).output.contains("emitted no probes"));
    }
}
