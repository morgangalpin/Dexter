//! Checks that pass when an OpenSCAD render comes out empty: the intersection
//! of two parts that must not overlap, and a keep-out volume that no part may
//! enter. OpenSCAD reports an empty top level object as its only complaint; any
//! other diagnostic is printed and fails the check.
//!
//! `interference` fields: `scad` (an assembly that takes an `interference` pair
//! of names and a `geometry` of `scad`), `a`, `b`, `out`, and optionally
//! `config`. Pairs that meet at a shoulder render a zero-thickness face, which
//! this check cannot tell from an overlap, so such pairs are not listed.
//!
//! `keepout` fields: `label`, `scad`, `out`, optionally `config`, and `defines`
//! (further `-D` definitions, such as `keepout_check=true`).

use super::{config_defines, Env, Fields, Report};
use crate::diagnostics;
use anyhow::Result;

pub fn interference(env: &Env, f: &Fields, rep: &mut Report) -> Result<()> {
    let (a, b) = (f.str("a")?, f.str("b")?);
    let mut defines = config_defines(f);
    defines.extend(["geometry=\"scad\"".to_owned(), format!("interference=[\"{a}\",\"{b}\"]")]);
    let label = format!("{a} and {b} do not overlap ({})", f.str_or("config", "default"));
    verdict(env, f, defines, &label, rep)
}

pub fn keepout(env: &Env, f: &Fields, rep: &mut Report) -> Result<()> {
    let mut defines = config_defines(f);
    defines.extend(f.strings("defines")?.into_iter().map(String::from));
    verdict(env, f, defines, f.str("label")?, rep)
}

fn verdict(env: &Env, f: &Fields, defines: Vec<String>, label: &str, rep: &mut Report) -> Result<()> {
    let out = f.str("out")?;
    env.tools.ensure_parent(out)?;
    let mut args = vec!["-o", out];
    defines.iter().for_each(|d| args.extend(["-D", d]));
    args.push(f.str("scad")?);
    let r = env.tools.openscad(&args)?;
    let complaints = diagnostics(&r.stderr);
    let empty = complaints.len() == 1 && complaints[0].contains("top level object is empty");
    if !empty {
        complaints.iter().for_each(|line| rep.note(line));
    }
    rep.record(label, empty);
    Ok(())
}

#[cfg(test)]
mod tests {
    use crate::kinds::testing::*;
    use serde_json::json;

    fn pair() -> serde_json::Value {
        json!({"scad": "asm.scad", "a": "730-001", "b": "720-004", "out": "out/i.stl", "config": "revised"})
    }

    fn fake(stderr: &str) -> Fake {
        let mut f = Fake::new();
        f.stderr = stderr.into();
        f
    }

    #[test]
    fn an_empty_intersection_passes() {
        let f = fake("Current top level object is empty.\n");
        let o = check("interference", pair(), &f);
        assert!(o.ok && o.output.contains("730-001 and 720-004 do not overlap (revised)"), "{}", o.output);
        let want = "openscad -o out/i.stl -D config=\"revised\" -D geometry=\"scad\" -D interference=[\"730-001\",\"720-004\"] asm.scad";
        assert_eq!(f.calls(), vec![want]);
    }

    #[test]
    fn a_non_empty_render_or_extra_complaint_fails_and_is_shown() {
        let o = check("interference", pair(), &fake(""));
        assert!(!o.ok, "{}", o.output);
        let o = check("interference", pair(), &fake("Current top level object is empty.\nWARNING: odd\n"));
        assert!(!o.ok && o.output.contains("WARNING: odd"), "{}", o.output);
        assert!(!check("interference", pair(), &fake("WARNING: x\n")).ok);
    }

    #[test]
    fn a_keepout_adds_its_own_definitions() {
        let f = fake("Current top level object is empty.\n");
        let v = json!({"label": "clear of the teeth", "scad": "b.scad", "out": "out/k.stl", "config": "revised", "defines": ["keepout_check=true"]});
        assert!(check("keepout", v, &f).ok);
        assert_eq!(f.calls(), vec!["openscad -o out/k.stl -D config=\"revised\" -D keepout_check=true b.scad"]);
    }
}
