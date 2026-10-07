//! `diameters`: a mating diameter that must appear on a cross-section of a
//! rendered mesh, as `scadmesh slice` reports it.
//!
//! Fields: `items`, a list of `{label, stl, args, diameter}`, and optionally
//! `tol` in mm (default 0.05). `args` are the `slice` flags after the mesh path.

use super::{Env, Fields, Report};
use anyhow::Result;
use serde_json::Value;

const DEFAULT_TOL: f64 = 0.05;

pub fn run(env: &Env, f: &Fields, rep: &mut Report) -> Result<()> {
    let tol = f.f64_or("tol", DEFAULT_TOL);
    f.items("items")?.iter().try_for_each(|item| one(env, item, tol, rep))
}

fn one(env: &Env, item: &Fields, tol: f64, rep: &mut Report) -> Result<()> {
    let mut args = vec!["slice", item.str("stl")?];
    args.extend(item.strings("args")?);
    let (_, json) = env.tools.scadmesh(&args)?;
    rep.record(item.str("label")?, has_diameter(&json, item.f64("diameter")?, tol));
    Ok(())
}

fn has_diameter(json: &Value, diameter: f64, tol: f64) -> bool {
    json["loops"].as_array().is_some_and(|loops| {
        loops.iter().any(|l| l["circle"]["radius"].as_f64().is_some_and(|r| (2.0 * r - diameter).abs() <= tol))
    })
}

#[cfg(test)]
mod tests {
    use crate::kinds::testing::*;
    use serde_json::{json, Value};

    fn items(diameter: f64, tol: Value) -> Value {
        let mut v = json!({"items": [{"label": "seat", "stl": "out/a.stl", "args": ["--at=2.0"], "diameter": diameter}]});
        v["tol"] = tol;
        v
    }

    fn slice() -> Fake {
        Fake::new().with("slice", json!({"loops": [{"circle": null}, {"circle": {"radius": 11.51}}]}))
    }

    #[test]
    fn finds_a_loop_of_the_stated_diameter_within_tolerance() {
        let fake = slice();
        assert!(check("diameters", items(23.0, Value::Null), &fake).ok);
        assert_eq!(fake.calls(), vec!["scadmesh slice out/a.stl --at=2.0"]);
    }

    #[test]
    fn fails_when_no_loop_matches_and_honours_a_wider_tolerance() {
        assert!(!check("diameters", items(23.2, Value::Null), &slice()).ok);
        assert!(check("diameters", items(23.2, json!(0.25)), &slice()).ok);
        assert!(!check("diameters", items(23.0, Value::Null), &Fake::new()).ok);
    }
}
