//! `face`: a face of a render stands at the height the part says it does. At
//! each stated point, the render is material 0.1 mm behind the face and void
//! 0.1 mm in front of it.
//!
//! Fields: `part`, `scad`, `out`, optionally `config` and `defines`, and
//! `faces`, a list of `{name, at: [x, y], up, z?}` where `up` is true for a face
//! looking toward +Z. A face without `z` stands at the height the render echoes
//! as the name in `face_echo`. `defines_from_echo`, a list of `{define, file,
//! name}`, passes a value another job echoed into a log file as a definition,
//! so the render matches what an assembly asked for. `probes`, a list of
//! `{label, at: [x, y, 0], offset, solid}`, judges a point `offset` above the
//! echoed face height (a face without `face_echo` may not carry probes): material
//! when `solid` is true, void otherwise.

use super::fits::solid;
use super::{config_defines, echoed_number, render_judged, Env, Fields, Report};
use anyhow::Result;

pub fn run(env: &Env, f: &Fields, rep: &mut Report) -> Result<()> {
    let mut defines = config_defines(f);
    defines.extend(f.strings("defines")?.into_iter().map(String::from));
    for d in f.items_or_empty("defines_from_echo")? {
        let value = echoed_number(&env.tools.read(d.str("file")?)?, d.str("name")?)?;
        defines.push(format!("{}={value}", d.str("define")?));
    }
    let out = f.str("out")?;
    let r = render_judged(env, f.str("scad")?, out, &defines, rep)?;
    for face in f.items("faces")? {
        let z = match face.opt_f64("z") {
            Some(z) => z,
            None => echoed_number(&r.stderr, f.str("face_echo")?)?,
        };
        probe_face(env, f.str("part")?, out, &face, z, rep)?;
    }
    probe_offsets(env, f, out, &r.stderr, rep)
}

/// The `probes`, each a stated offset from the echoed face height.
fn probe_offsets(env: &Env, f: &Fields, stl: &str, stderr: &str, rep: &mut Report) -> Result<()> {
    let items = f.items_or_empty("probes")?;
    if items.is_empty() {
        return Ok(());
    }
    let seat = echoed_number(stderr, f.str("face_echo")?)?;
    for item in items {
        let [x, y, _] = item.point("at")?;
        let at = [x, y, ((seat + item.f64("offset")?) * 1e6).round() / 1e6];
        let got = solid(env, stl, &[at])?[0];
        rep.record(&format!("{} {}", f.str("part")?, item.str("label")?), got == item.v_bool("solid")?);
    }
    Ok(())
}

fn probe_face(env: &Env, part: &str, stl: &str, face: &Fields, z: f64, rep: &mut Report) -> Result<()> {
    let up = face.v_bool("up")?;
    let [x, y, _] = face.point("at")?;
    let (behind, front) = if up { ("below", "above") } else { ("above", "below") };
    let d = if up { 0.1 } else { -0.1 };
    let inside = solid(env, stl, &[[x, y, z - d], [x, y, z + d]])?;
    let name = face.str("name")?;
    rep.record(&format!("{part} {name} at z {z:.3} (material {behind})"), inside[0]);
    rep.record(&format!("{part} {name} at z {z:.3} (void {front})"), !inside[1]);
    Ok(())
}

#[cfg(test)]
mod tests {
    use crate::kinds::testing::*;
    use serde_json::{json, Value};

    fn fields() -> Value {
        json!({"part": "511-001 (revised)", "scad": "c.scad", "out": "out/c.stl", "config": "revised",
               "face_echo": "end_cap_seat",
               "faces": [{"name": "seat", "at": [0, -16, 0], "up": false}]})
    }

    fn fake(stderr: &str, inside: [bool; 2]) -> Fake {
        let mut f = Fake::new().with("solid", json!({"probes": [{"inside": inside[0]}, {"inside": inside[1]}]}));
        f.stderr = stderr.into();
        f
    }

    #[test]
    fn material_behind_and_void_in_front_of_an_echoed_face() {
        let f = fake("ECHO: end_cap_seat = 4.5\n", [true, false]);
        let o = check("face", fields(), &f);
        assert!(o.ok && o.output.contains("511-001 (revised) seat at z 4.500 (void below)"), "{}", o.output);
        assert_eq!(f.calls()[1], "scadmesh solid out/c.stl --probe=0,-16,4.6 --probe=0,-16,4.4");
        assert!(!check("face", fields(), &fake("ECHO: end_cap_seat = 4.5\n", [true, true])).ok);
        assert!(!check("face", fields(), &fake("ECHO: end_cap_seat = 4.5\n", [false, false])).ok);
    }

    #[test]
    fn a_probe_is_an_offset_above_the_echoed_face() {
        let mut v = fields();
        v["probes"] = json!([{"label": "side round", "at": [9.56, 6.06, 0.0], "offset": 0.9, "solid": true}]);
        let mut f = Fake::new().with("solid", json!({"probes": [{"inside": true}, {"inside": false}]}));
        f.stderr = "ECHO: end_cap_seat = -1.2
".into();
        let o = check("face", v.clone(), &f);
        assert!(o.ok && o.output.contains("511-001 (revised) side round"), "{}", o.output);
        assert_eq!(f.calls()[2], "scadmesh solid out/c.stl --probe=9.56,6.06,-0.3");
        v["probes"][0]["solid"] = json!(false);
        assert!(!check("face", v, &f).ok);
    }

    #[test]
    fn a_face_looking_up_probes_below_then_above() {
        let mut v = fields();
        v["faces"] = json!([{"name": "hub face", "at": [12, 0, 0], "up": true, "z": 9.0}]);
        let f = fake("", [true, false]);
        assert!(check("face", v, &f).ok);
        assert_eq!(f.calls()[1], "scadmesh solid out/c.stl --probe=12,0,8.9 --probe=12,0,9.1");
    }

    #[test]
    fn a_face_without_a_height_needs_the_echo() {
        let o = check("face", fields(), &fake("", [true, false]));
        assert!(!o.ok && o.output.contains("end_cap_seat not echoed"), "{}", o.output);
    }

    #[test]
    fn a_definition_can_come_from_another_jobs_echo_log() {
        let mut v = fields();
        v["defines"] = json!(["a=1"]);
        v["defines_from_echo"] = json!([{"define": "hub_drop", "file": "out/assembly.echo", "name": "j3_hub_drop"}]);
        let mut f = fake("ECHO: end_cap_seat = 4.5\n", [true, false]);
        f.files.insert("out/assembly.echo", "ECHO: j3_hub_drop = 0.687\n");
        assert!(check("face", v.clone(), &f).ok);
        assert_eq!(f.calls()[0], "openscad --backend=manifold -o out/c.stl -D config=\"revised\" -D a=1 -D hub_drop=0.687 c.scad");
        let o = check("face", v, &fake("", [true, false]));
        assert!(!o.ok && o.output.contains("no file out/assembly.echo"), "{}", o.output);
    }
}
