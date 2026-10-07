//! `clash`: two parts of an assembly that must not overlap, rendered as their
//! intersection. The assembly takes a two-name `clash` list.
//!
//! OpenSCAD reports an empty intersection by refusing to export it; a seat,
//! where two parts share a face, exports a surface with no volume. Both are
//! clear. A CGAL failure returns one operand as the result, so its output says
//! nothing about the pair, and the check fails rather than measure it.
//!
//! Fields: `scad`, `a`, `b`, `out`.

use super::{Env, Fields, Report};
use crate::{clash_verdict, Clash};
use anyhow::Result;

pub fn run(env: &Env, f: &Fields, rep: &mut Report) -> Result<()> {
    let (a, b, out) = (f.str("a")?, f.str("b")?, f.str("out")?);
    env.tools.remove(out);
    env.tools.ensure_parent(out)?;
    let define = format!("clash=[\"{a}\",\"{b}\"]");
    let r = env.tools.openscad(&["-o", out, "-D", &define, f.str("scad")?])?;
    let volume = if env.tools.exists(out) { env.tools.scadmesh(&["info", out])?.1[0]["volume_mm3"].as_f64() } else { None };
    let (label, ok) = match clash_verdict(&r.stderr, volume) {
        Clash::Clear => (format!("{a} clear of {b}"), true),
        Clash::Overlap(v) => (format!("{a} clear of {b} (overlap {v:.3} mm3)"), false),
        Clash::Unjudged => (format!("{a} clear of {b} (OpenSCAD could not intersect them)"), false),
    };
    rep.record(&label, ok);
    Ok(())
}

#[cfg(test)]
mod tests {
    use crate::kinds::testing::*;
    use serde_json::json;

    fn fields() -> serde_json::Value {
        json!({"scad": "asm.scad", "a": "stator", "b": "attach", "out": "out/clash.stl"})
    }

    #[test]
    fn a_refused_export_is_clear_and_a_stale_file_is_removed_first() {
        let mut f = Fake::new();
        f.stderr = "Current top level object is empty.\n".into();
        let o = check("clash", fields(), &f);
        assert!(o.ok && o.output.contains("stator clear of attach"), "{}", o.output);
        assert_eq!(f.calls()[0], "remove out/clash.stl");
        assert_eq!(f.calls()[1], "openscad -o out/clash.stl -D clash=[\"stator\",\"attach\"] asm.scad");
    }

    #[test]
    fn an_exported_volume_is_an_overlap_unless_it_is_contact() {
        let mut f = Fake::new().with("info", json!([{"volume_mm3": 2.5}]));
        f.present.push("out/clash.stl");
        let o = check("clash", fields(), &f);
        assert!(!o.ok && o.output.contains("overlap 2.500 mm3"), "{}", o.output);
        let mut seat = Fake::new().with("info", json!([{"volume_mm3": 0.0}]));
        seat.present.push("out/clash.stl");
        assert!(check("clash", fields(), &seat).ok);
    }

    #[test]
    fn a_failed_intersection_is_unjudged_and_fails() {
        let mut f = Fake::new();
        f.stderr = "ERROR: CGAL error\n".into();
        let o = check("clash", fields(), &f);
        assert!(!o.ok && o.output.contains("could not intersect"), "{}", o.output);
    }
}
