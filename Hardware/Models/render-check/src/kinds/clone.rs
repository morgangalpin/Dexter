//! `clone`: render a part and `scadmesh compare` it against its reference.
//!
//! A `tol` is the measured noise floor of the comparison, not slack: run
//! `compare` on a reference against itself with the part's own flags and see
//! what it reports. A documented departure from the reference is a
//! *deviation*, not a looser `tol`: the check is held to `delta` within
//! `dev_tol` instead of to zero, so the number has to still be there while the
//! checks around it stay at `tol`. `compare` has no per-check tolerance, so the
//! verdict is computed here from its `checks` array rather than from its exit
//! status.
//!
//! Fields: `part`, `scad`, `out`, `reference`, `tol`, optionally `config`,
//! `extra` (further `compare` flags, such as ignore ranges) and `deviations`
//! (a list of `{check, delta, dev_tol}`).

use super::{config_defines, reference_path, render_judged, Env, Fields, Report};
use anyhow::{Context, Result};
use serde_json::Value;

struct Deviation<'a> {
    check: &'a str,
    delta: f64,
    dev_tol: f64,
}

fn deviations<'a>(f: &Fields<'a>) -> Result<Vec<Deviation<'a>>> {
    f.items_or_empty("deviations")?.iter().map(|d| Ok(Deviation { check: d.str("check")?, delta: d.f64("delta")?, dev_tol: d.f64("dev_tol")? })).collect()
}

pub fn run(env: &Env, f: &Fields, rep: &mut Report) -> Result<()> {
    let out = f.str("out")?;
    render_judged(env, f.str("scad")?, out, &config_defines(f), rep)?;
    let (reference, tol) = (reference_path(env, f)?, f.f64("tol")?);
    let tol_text = tol.to_string();
    let mut args = vec!["compare", out, &reference, "--tol", &tol_text];
    args.extend(f.strings("extra")?);
    let (_, report) = env.tools.scadmesh(&args)?;
    let checks = report["checks"].as_array().with_context(|| format!("compare emitted no checks for {}", f.str("part").unwrap_or("?")))?;
    judge(f.str("part")?, checks, tol, &deviations(f)?, rep);
    Ok(())
}

fn held(part: &str, name: &str, delta: f64, dev: &Deviation, rep: &mut Report) -> bool {
    let off = (delta - dev.delta).abs();
    let ok = off <= dev.dev_tol;
    let label = format!(
        "{part} {name} holds its stated {:.3} mm departure (got {delta:.3}, off {off:.3} mm, tol {} mm)",
        dev.delta, dev.dev_tol
    );
    rep.record(&label, ok);
    ok
}

/// Every check is read; none is dropped. A NaN delta fails.
fn judge(part: &str, checks: &[Value], tol: f64, devs: &[Deviation], rep: &mut Report) {
    let (mut worst, mut ok) = (0.0_f64, true);
    for c in checks {
        let name = c["name"].as_str().unwrap_or_default();
        let delta = c["delta"].as_f64().unwrap_or(f64::NAN);
        match devs.iter().find(|d| d.check == name) {
            Some(dev) => ok &= held(part, name, delta, dev, rep),
            None => {
                worst = worst.max(delta);
                ok &= delta <= tol;
            }
        }
    }
    rep.record(&format!("{part} vs reference (worst {worst:.3} mm, tol {tol} mm)"), ok);
}

#[cfg(test)]
mod tests {
    use crate::kinds::testing::*;
    use serde_json::{json, Value};

    fn fields(extra: Value) -> Value {
        let mut v = json!({"part": "720-001", "scad": "a.scad", "out": "out/a.stl", "config": "previous",
                           "reference": "a.stl", "tol": 0.05, "extra": ["--axis", "y"]});
        if !extra.is_null() {
            v["deviations"] = extra;
        }
        v
    }

    fn compare(deltas: &[(&str, f64)]) -> Fake {
        let checks: Vec<Value> = deltas.iter().map(|(n, d)| json!({"name": n, "delta": d})).collect();
        Fake::new().with("compare", json!({"checks": checks}))
    }

    #[test]
    fn passes_when_every_delta_is_within_tolerance() {
        let fake = compare(&[("a", 0.01), ("b", 0.04)]);
        let o = check("clone", fields(Value::Null), &fake);
        assert!(o.ok && o.output.contains("720-001 vs reference (worst 0.040 mm, tol 0.05 mm)"), "{}", o.output);
        assert_eq!(fake.calls()[1], "scadmesh compare out/a.stl ref/a.stl --tol 0.05 --axis y");
    }

    #[test]
    fn fails_on_one_delta_over_tolerance() {
        assert!(!check("clone", fields(Value::Null), &compare(&[("a", 0.01), ("b", 0.06)])).ok);
    }

    #[test]
    fn a_stated_departure_is_held_two_sided() {
        let dev = json!([{"check": "bbox-dim0", "delta": 0.768, "dev_tol": 0.02}]);
        let ok = check("clone", fields(dev.clone()), &compare(&[("bbox-dim0", 0.77), ("a", 0.01)]));
        assert!(ok.ok && ok.output.contains("bbox-dim0 holds its stated 0.768 mm departure"), "{}", ok.output);
        assert!(!check("clone", fields(dev.clone()), &compare(&[("bbox-dim0", 0.0)])).ok, "the departure vanished");
        assert!(!check("clone", fields(dev), &compare(&[("bbox-dim0", 0.9)])).ok, "the departure grew");
    }

    #[test]
    fn a_nan_delta_fails() {
        let fake = Fake::new().with("compare", json!({"checks": [{"name": "a"}]}));
        assert!(!check("clone", fields(Value::Null), &fake).ok);
    }

    #[test]
    fn a_report_without_checks_is_an_error() {
        let o = check("clone", fields(Value::Null), &Fake::new().with("compare", json!({})));
        assert!(!o.ok && o.output.contains("compare emitted no checks for 720-001"), "{}", o.output);
    }
}
