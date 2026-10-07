//! `render`: render one source to a file and hold the render to silence.
//!
//! Fields: `scad`, `out`, and optionally `config` (passed as `-D config=...`).
//! An `out` ending in `.csg` evaluates every parameter and assertion of the
//! source without meshing it, which is how an assembly is checked in seconds.

use super::{config_defines, render_judged, Env, Fields, Report};
use anyhow::Result;

pub fn run(env: &Env, f: &Fields, rep: &mut Report) -> Result<()> {
    render_judged(env, f.str("scad")?, f.str("out")?, &config_defines(f), rep).map(drop)
}

#[cfg(test)]
mod tests {
    use crate::kinds::testing::*;
    use serde_json::json;

    #[test]
    fn renders_the_source_in_the_named_configuration() {
        let fake = Fake::new();
        let o = check("render", json!({"scad": "a.scad", "out": "out/a.stl", "config": "previous"}), &fake);
        assert!(o.ok, "{}", o.output);
        assert_eq!(fake.calls(), vec!["openscad -o out/a.stl -D config=\"previous\" a.scad"]);
    }

    #[test]
    fn an_assertion_failure_fails_the_check() {
        let mut fake = Fake::new();
        fake.openscad_ok = false;
        let o = check("render", json!({"scad": "a.scad", "out": "out/a.csg"}), &fake);
        assert!(!o.ok && o.output.contains("OpenSCAD failed on a.scad"), "{}", o.output);
    }
}
