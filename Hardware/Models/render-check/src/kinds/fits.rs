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

pub const DEFAULT_LIBRARY: &str = "../print_fit.scad";

/// One fit to check: where the mate's surface is, which way the mate lies, and the class.
pub struct FitSpec {
    pub label: String,
    pub at: [f64; 3],
    pub toward: [f64; 3],
    pub slip: bool,
}

pub fn run(env: &Env, f: &Fields, rep: &mut Report) -> Result<()> {
    let specs = f.items("probes")?.iter().map(spec).collect::<Result<Vec<_>>>()?;
    judge(env, f.str_or("print_fit", DEFAULT_LIBRARY), f.str("stl")?, f.str("part")?, &specs, rep)
}

/// Probe every fit of `stl` against the class clearances of `library`.
pub fn judge(env: &Env, library: &str, stl: &str, part: &str, specs: &[FitSpec], rep: &mut Report) -> Result<()> {
    let (slip, press) = clearances(env, library)?;
    let mut points = Vec::new();
    for s in specs {
        let (gap, wall) = fit_points(&to_probe(s), if s.slip { slip } else { press });
        points.extend([gap, wall]);
    }
    let inside = solid(env, stl, &points)?;
    for (s, pair) in specs.iter().zip(inside.chunks(2)) {
        let class = if s.slip { "slip" } else { "press" };
        rep.record(&format!("{part} fit, {} ({class}): gap open, wall behind it", s.label), !pair[0] && pair[1]);
    }
    Ok(())
}

fn spec(p: &Fields) -> Result<FitSpec> {
    let slip = match p.str("fit")? {
        "slip" => true,
        "press" => false,
        other => bail!("fit \"{other}\" is neither slip nor press"),
    };
    Ok(FitSpec { label: p.str("label")?.to_owned(), at: p.point("at")?, toward: p.point("toward")?, slip })
}

fn to_probe(s: &FitSpec) -> FitProbe {
    FitProbe { label: "", at: s.at, toward: s.toward, fit: if s.slip { Fit::Slip } else { Fit::Press } }
}

pub fn clearances(env: &Env, library: &str) -> Result<(f64, f64)> {
    let source = env.tools.read(library)?;
    let get = |name| scad_constant(&source, name).with_context(|| format!("{name} not in {library}"));
    Ok((get("FIT_SLIP")?, get("FIT_PRESS")?))
}

/// `scadmesh solid` inside/outside for each point, in order.
pub fn solid(env: &Env, stl: &str, points: &[[f64; 3]]) -> Result<Vec<bool>> {
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
