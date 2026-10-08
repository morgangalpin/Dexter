//! `seat`: a Stator Holder's revised seat for C-201's circular spline, probed
//! against the hole pattern as 007.1 states it rather than as the seat library
//! cuts it, so the probes test the library. The seat's print fits are checked
//! with it.
//!
//! Fields: `part` (the stem), `scad`, `out`, `facing` (+1 when the recess opens
//! toward +Z, -1 toward -Z) and optionally `config` (default `revised`) and
//! `print_fit`. The part echoes `seat_floor`, the floor's height in its frame.

use super::fits::{self, FitSpec};
use super::{render_judged, Env, Fields, Report};
use crate::{echoed, seat_fit_probes, seat_probe_points, Fit};
use anyhow::{Context, Result};

pub fn run(env: &Env, f: &Fields, rep: &mut Report) -> Result<()> {
    let (stem, out, facing) = (f.str("part")?, f.str("out")?, f.f64("facing")?);
    let define = format!("config=\"{}\"", f.str_or("config", "revised"));
    let r = render_judged(env, f.str("scad")?, out, &[define], rep)?;
    let floor: f64 = echoed(&r.stderr, "seat_floor = ").context("seat_floor not echoed")?.parse()?;
    let probes = seat_probe_points(floor, facing);
    let points: Vec<[f64; 3]> = probes.iter().map(|p| p.at).collect();
    for (p, inside) in probes.iter().zip(fits::solid(env, out, &points)?) {
        rep.record(&format!("{stem} (revised) seat: {}", p.label), inside == p.solid);
    }
    let specs: Vec<FitSpec> = seat_fit_probes(floor, facing).into_iter().map(spec).collect();
    fits::judge(env, f.str_or("print_fit", fits::DEFAULT_LIBRARY), out, &format!("{stem} (revised) seat"), &specs, rep)
}

fn spec(p: crate::FitProbe) -> FitSpec {
    FitSpec { label: p.label.to_owned(), at: p.at, toward: p.toward, slip: p.fit == Fit::Slip }
}

#[cfg(test)]
mod tests {
    use crate::kinds::testing::*;
    use serde_json::{json, Value};

    fn fields() -> Value {
        json!({"part": "200-002", "scad": "h.scad", "out": "out/revised/200-002.stl", "facing": -1})
    }

    /// Answers every probe with the expected side, by reading its own request.
    fn fake(stderr: &str, all_solid_ok: bool) -> Fake {
        let n = crate::seat_probe_points(5.0, -1.0).len() + 6;
        let probes: Vec<Value> = (0..n).map(|i| json!({"inside": i % 2 == 1 && all_solid_ok})).collect();
        let mut f = Fake::new().with("solid", json!({"probes": probes}));
        f.stderr = stderr.into();
        f.files.insert("../print_fit.scad", "FIT_SLIP = 0.2;\nFIT_PRESS = 0.1;\n");
        f
    }

    #[test]
    fn an_unechoed_floor_is_an_error() {
        let o = check("seat", fields(), &fake("", true));
        assert!(!o.ok && o.output.contains("seat_floor not echoed"), "{}", o.output);
    }

    #[test]
    fn the_floor_positions_the_probes_and_each_is_judged() {
        let f = fake("ECHO: seat_floor = 5\n", true);
        let o = check("seat", fields(), &f);
        assert!(o.output.contains("200-002 (revised) seat: floor, material under it"), "{}", o.output);
        assert!(o.output.contains("200-002 (revised) seat fit, recess on the flange (press)"), "{}", o.output);
        assert!(f.calls()[0].starts_with("openscad -o out/revised/200-002.stl -D config=\"revised\" h.scad"));
        assert!(!check("seat", fields(), &fake("ECHO: seat_floor = 5\n", false)).ok);
    }
}
