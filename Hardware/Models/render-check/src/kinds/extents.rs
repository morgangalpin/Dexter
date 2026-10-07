//! `extents`: a part that states its own extent for the assemblies to read. The
//! source echoes `<name> = [[min], [max]]` and the render's bounding box must
//! agree. This keeps an assembly's envelope assert, and its clearance checks,
//! measuring the parts themselves. The echo comes from a CSG export, which
//! evaluates the source in seconds.
//!
//! Fields: `part`, `scad`, `name` (the echoed variable), `stl` (the render the
//! box is compared with), `out` (the CSG file written), optionally `config` and
//! `tol` in mm (default 0.02).

use super::{config_defines, Env, Fields, Report};
use crate::echoed;
use anyhow::Result;
use serde_json::Value;

const DEFAULT_TOL: f64 = 0.02;

pub fn run(env: &Env, f: &Fields, rep: &mut Report) -> Result<()> {
    let (out, name) = (f.str("out")?, f.str("name")?);
    env.tools.ensure_parent(out)?;
    let mut args = vec!["-o", out];
    let defines = config_defines(f);
    defines.iter().for_each(|d| args.extend(["-D", d]));
    args.push(f.str("scad")?);
    let r = env.tools.openscad(&args)?;
    let stated: Option<Value> = echoed(&r.stderr, &format!("{name} = ")).and_then(|t| serde_json::from_str(t).ok());
    let (_, bbox) = env.tools.scadmesh(&["bbox", f.str("stl")?])?;
    let shown = stated.as_ref().map_or("not echoed".into(), |s| s.to_string());
    let label = format!("{} stated extent {name} matches its render ({}): {shown}", f.str("part")?, f.str_or("config", "default"));
    rep.record(&label, stated.is_some_and(|s| box_agrees(&s, &bbox, f.f64_or("tol", DEFAULT_TOL))));
    Ok(())
}

fn box_agrees(stated: &Value, bbox: &Value, tol: f64) -> bool {
    let near = |a: &Value, b: &Value| matches!((a.as_f64(), b.as_f64()), (Some(a), Some(b)) if (a - b).abs() <= tol);
    (0..3).all(|i| near(&stated[0][i], &bbox["min"][i]) && near(&stated[1][i], &bbox["max"][i]))
}

#[cfg(test)]
mod tests {
    use crate::kinds::testing::*;
    use serde_json::json;

    fn fields() -> serde_json::Value {
        json!({"part": "730-001", "scad": "a.scad", "name": "box", "stl": "out/a.stl", "out": "out/a-extent.csg", "config": "revised"})
    }

    fn fake(stderr: &str, max: f64) -> Fake {
        let mut f = Fake::new().with("bbox", json!({"min": [0, 0, 0], "max": [1, 2, max]}));
        f.stderr = stderr.into();
        f
    }

    #[test]
    fn a_stated_box_that_matches_the_render_passes() {
        let f = fake("ECHO: box = [[0, 0, 0], [1, 2, 3]]\n", 3.01);
        let o = check("extents", fields(), &f);
        assert!(o.ok && o.output.contains("730-001 stated extent box matches its render (revised)"), "{}", o.output);
        assert_eq!(f.calls()[0], "openscad -o out/a-extent.csg -D config=\"revised\" a.scad");
    }

    #[test]
    fn a_box_off_by_more_than_the_tolerance_fails() {
        assert!(!check("extents", fields(), &fake("ECHO: box = [[0, 0, 0], [1, 2, 3]]\n", 3.1)).ok);
    }

    #[test]
    fn a_box_that_is_not_echoed_or_not_json_fails() {
        let o = check("extents", fields(), &fake("", 3.0));
        assert!(!o.ok && o.output.contains("not echoed"), "{}", o.output);
        assert!(!check("extents", fields(), &fake("ECHO: box = oops\n", 3.0)).ok);
    }
}
