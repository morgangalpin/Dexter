//! `gear_fit`: a Stator Holder against the External Gear. CGAL cannot take this
//! pair at zero clearance: the keys then fit the slots line to line, and a
//! boolean over coincident faces fails and returns an operand. The fit is
//! checked where it is made instead, in each shared plane below the gear's end,
//! between the spigot's outline (the holder's outer loop) and the socket's (the
//! gear's inner loop). Drawn at zero clearance the two must be the same
//! section; at the slip clearance the spigot must stand in by it all round.
//! Above the gear's end the holder has nothing the gear could reach.
//!
//! Fields: `scad`, `config`, `nominal_out` and `fitted_out` (binary meshes, the
//! first drawn with `FIT_SLIP=0`), `gear` (the gear's mesh), `echo_file` and
//! `echo_name` (the height of the gear's end in the holder's frame), `sections`
//! (holder heights), `outline` (the spigot's outline length in mm) and `tol`
//! (section-area agreement in mm2: 0.01 mm of mean offset over `outline`,
//! with faceting alone accounting for about 1 mm2), and optionally
//! `print_fit`.

use super::fits::{clearances, DEFAULT_LIBRARY};
use super::{echoed_number, render_extra, Env, Fields, Report};
use anyhow::{Context, Result};

const BINARY: [&str; 2] = ["--export-format", "binstl"];

pub fn run(env: &Env, f: &Fields, rep: &mut Report) -> Result<()> {
    let (scad, config) = (f.str("scad")?, format!("config=\"{}\"", f.str("config")?));
    let (nominal, fitted) = (f.str("nominal_out")?, f.str("fitted_out")?);
    render_extra(env, scad, nominal, &[config.clone(), "FIT_SLIP=0".into()], &BINARY, rep)?;
    render_extra(env, scad, fitted, &[config], &BINARY, rep)?;
    let (slip, _) = clearances(env, f.str_or("print_fit", DEFAULT_LIBRARY))?;
    let on_gear = echoed_number(&env.tools.read(f.str("echo_file")?)?, f.str("echo_name")?)?;
    let gap = f.f64("outline")? * slip;
    for z in f.f64_list("sections")? {
        let drawn = loop_areas(env, nominal, "z", z)?.first().copied().context("no loop in the nominal section")?;
        let spigot = loop_areas(env, fitted, "z", z)?.first().copied().context("no loop in the fitted section")?;
        let socket = *loop_areas(env, f.str("gear")?, "x", on_gear - z)?.get(1).context("the gear section has no socket loop")?;
        let (lead, tol) = (format!("stator spigot at zero clearance is the gear's socket at holder z {z}"), f.f64("tol")?);
        rep.record(&format!("{lead} ({drawn:.2} vs {socket:.2} mm2)"), (drawn - socket).abs() < tol);
        let stands = format!("stator spigot stands in by the slip clearance at holder z {z}");
        let by = socket - spigot;
        rep.record(&format!("{stands} ({by:.2} mm2, ~{gap:.1} expected)"), (by - gap).abs() < gap / 2.0);
    }
    Ok(())
}

/// The areas of a section's loops, largest first.
fn loop_areas(env: &Env, stl: &str, axis: &str, at: f64) -> Result<Vec<f64>> {
    let at = format!("--at={at}");
    let (_, json) = env.tools.scadmesh(&["slice", stl, "--axis", axis, &at])?;
    let mut areas: Vec<f64> =
        json["loops"].as_array().context("slice emitted no loops")?.iter().filter_map(|l| l["area"].as_f64()).map(f64::abs).collect();
    areas.sort_by(|a, b| b.total_cmp(a));
    Ok(areas)
}

#[cfg(test)]
mod tests {
    use crate::kinds::testing::*;
    use serde_json::{json, Value};

    fn fields() -> Value {
        json!({"scad": "h.scad", "config": "revised", "nominal_out": "out/n.bin.stl", "fitted_out": "out/f.bin.stl",
               "gear": "g.stl", "echo_file": "out/a.echo", "echo_name": "stator_on_gear",
               "sections": [6], "outline": 100, "tol": 2.3})
    }

    fn fake(fitted_area: f64) -> Fake {
        let mut f = Fake::new();
        f.files.insert("../print_fit.scad", "FIT_SLIP = 0.2;\nFIT_PRESS = 0.1;\n");
        f.files.insert("out/a.echo", "ECHO: stator_on_gear = 20\n");
        f.by_path.push(("n.bin.stl", json!({"loops": [{"area": 100.0}]})));
        f.by_path.push(("f.bin.stl", json!({"loops": [{"area": fitted_area}]})));
        f.by_path.push(("g.stl", json!({"loops": [{"area": 900.0}, {"area": 100.0}]})));
        f
    }

    #[test]
    fn a_spigot_that_stands_in_by_the_slip_clearance_passes_both_tests() {
        let f = fake(80.0);
        let o = check("gear_fit", fields(), &f);
        assert!(o.ok, "{}", o.output);
        assert!(o.output.contains("is the gear's socket at holder z 6 (100.00 vs 100.00 mm2)"), "{}", o.output);
        assert!(o.output.contains("stands in by the slip clearance at holder z 6 (20.00 mm2, ~20.0 expected)"), "{}", o.output);
        assert_eq!(f.calls()[0], "openscad -o out/n.bin.stl -D config=\"revised\" -D FIT_SLIP=0 --export-format binstl h.scad");
        assert!(f.calls().contains(&"scadmesh slice g.stl --axis x --at=14".to_string()), "{:?}", f.calls());
    }

    #[test]
    fn a_spigot_with_no_clearance_or_off_its_seat_fails() {
        let o = check("gear_fit", fields(), &fake(100.0));
        assert!(o.output.contains("PASS  stator spigot at zero") && o.output.contains("FAIL  stator spigot stands in"), "{}", o.output);
        let mut off = fake(80.0);
        off.by_path[0].1 = json!({"loops": [{"area": 160.0}]});
        assert!(check("gear_fit", fields(), &off).output.contains("FAIL  stator spigot at zero"));
    }

    #[test]
    fn a_missing_loop_or_echo_is_an_error() {
        let mut none = fake(80.0);
        none.by_path[0].1 = json!({"loops": []});
        assert!(check("gear_fit", fields(), &none).output.contains("no loop in the nominal section"));
        let mut one = fake(80.0);
        one.by_path[2].1 = json!({"loops": [{"area": 1.0}]});
        assert!(check("gear_fit", fields(), &one).output.contains("no socket loop"));
        let mut bare = Fake::new();
        bare.files.insert("../print_fit.scad", "FIT_SLIP = 0.2;\nFIT_PRESS = 0.1;\n");
        assert!(check("gear_fit", fields(), &bare).output.contains("no file out/a.echo"));
    }
}
