//! `--meshes`: build the binary STL cache a group's assembly imports. Each part
//! is rendered, then settled, repaired and pinched so that a renderer can take
//! it, and its enclosed volume is checked not to have moved. What the cache is
//! for, why it is binary, and why each step is safe are owned by
//! `specs/009.3-Render-Program.md`; the steps themselves are owned by
//! `openscad-tools`.

use crate::config::GroupConfig;
use crate::plan::Job;
use crate::sched::Outcome;
use crate::{run, sm_json, Ctx, Run};
use anyhow::{bail, Context, Result};
use serde_json::Value;

/// The directory, relative to the group, that holds the cache.
pub const OUT_DIR: &str = "out/asm";

/// Widest boundary loop, in mm, that `repair` may close. A gap the settling
/// opens is a collapsed sliver, reported by its length; the longest in the
/// 700-Differential set is 2.507 mm. The volume check is what makes this
/// allowance safe, because it catches a loop that was a real opening.
pub const MAX_SPAN: &str = "3";

/// Volume, in mm³, below which two measurements of one part are the same mesh.
/// Binary STL carries float32, so the last figure of a volume is noise.
pub const VOLUME_EPS: f64 = 1.0e-3;

/// The external tools a mesh build needs, so tests can stand in for them.
pub trait Tools: Send + Sync {
    /// Run OpenSCAD with `args`.
    fn openscad(&self, args: &[&str]) -> Result<Run>;
    /// Run `scadmesh <args> --json`; returns the exit status and the report.
    fn scadmesh(&self, args: &[&str]) -> Result<(bool, Value)>;
    /// The size in bytes of a file written by a tool.
    fn size(&self, path: &str) -> Result<u64>;
    /// The text of a file, relative to the group; for the constants a check reads from source.
    fn read(&self, path: &str) -> Result<String> {
        bail!("this toolset cannot read {path}")
    }
    /// Create the directory that will hold `path`, so a tool can write there.
    fn ensure_parent(&self, _path: &str) -> Result<()> {
        Ok(())
    }
}

impl Tools for Ctx {
    fn read(&self, path: &str) -> Result<String> {
        std::fs::read_to_string(self.dir.join(path)).with_context(|| format!("reading {path}"))
    }

    fn ensure_parent(&self, path: &str) -> Result<()> {
        match self.dir.join(path).parent() {
            Some(p) => std::fs::create_dir_all(p).with_context(|| format!("creating the directory of {path}")),
            None => Ok(()),
        }
    }

    fn openscad(&self, args: &[&str]) -> Result<Run> {
        run(&self.openscad, args, &self.dir)
    }

    fn scadmesh(&self, args: &[&str]) -> Result<(bool, Value)> {
        sm_json(args, self)
    }

    fn size(&self, path: &str) -> Result<u64> {
        Ok(std::fs::metadata(self.dir.join(path)).with_context(|| format!("reading the size of {path}"))?.len())
    }
}

/// The mesh path of part `id`, relative to its group.
pub fn mesh_path(id: &str) -> String {
    format!("{OUT_DIR}/{id}.stl")
}

/// A part that `--meshes` builds, with the job that builds it.
#[derive(Debug, Clone, PartialEq)]
pub struct MeshWork {
    pub job: Job,
    pub id: String,
    pub scad: String,
}

/// One job per mesh part of `config`, in render order. Jobs are independent,
/// and each owns the single file it writes.
pub fn mesh_work(group: &str, cfg: &GroupConfig, config: &str) -> Vec<MeshWork> {
    cfg.parts_for(config)
        .into_iter()
        .filter(|p| p.meshes)
        .map(|p| MeshWork {
            job: Job { writes: vec![format!("{group}/{}", mesh_path(&p.id))], ..Job::new(&format!("{group}/mesh-{}", p.id)) },
            id: p.id.clone(),
            scad: p.scad.clone(),
        })
        .collect()
}

/// Render one part. The mesh is exported in the part file's own top-level
/// orientation; the assembly undoes any that is not the module's frame.
fn render(tools: &dyn Tools, scad: &str, out: &str, config: &str) -> Result<()> {
    let define = format!("config=\"{config}\"");
    let r = tools.openscad(&["-o", out, "--export-format=binstl", "-D", &define, scad])?;
    if !r.ok {
        bail!("OpenSCAD failed rendering {scad}:\n{}", r.stderr.trim_end());
    }
    Ok(())
}

/// The volume a mesh encloses, as `scadmesh info` measures it.
fn volume(tools: &dyn Tools, path: &str) -> Result<f64> {
    let (_, json) = tools.scadmesh(&["info", path])?;
    json[0]["volume_mm3"].as_f64().with_context(|| format!("no volume reported for {path}"))
}

fn count(json: &Value, key: &str) -> u64 {
    json[key].as_u64().unwrap_or(0)
}

/// What the three steps did, as the notes to print; empty when nothing moved.
fn notes(settled: &Value, repaired: &Value, pinched: &Value) -> Vec<String> {
    let contacts = pinched["contacts"].as_array().map_or(0, |a| a.len()) as u64;
    [
        (count(settled, "merged"), "vertices settled"),
        (count(repaired, "filled"), "gaps filled"),
        (count(repaired, "dropped"), "facets dropped"),
        (contacts, "contacts opened"),
    ]
    .iter()
    .filter(|(n, _)| *n > 0)
    .map(|(n, label)| format!("{n} {label}"))
    .collect()
}

/// Settle, repair and pinch one mesh in place. `pinch` says through its exit
/// status whether a builder can take the result.
fn solidify(tools: &dyn Tools, path: &str) -> Result<Vec<String>> {
    let (_, settled) = tools.scadmesh(&["settle", path, "--out", path])?;
    let (_, repaired) = tools.scadmesh(&["repair", path, "--max-span", MAX_SPAN, "--out", path])?;
    let (ok, pinched) = tools.scadmesh(&["pinch", path, "--out", path])?;
    if !ok {
        bail!("{path} is still not a solid a renderer will take: {}", serde_json::to_string(&pinched)?);
    }
    Ok(notes(&settled, &repaired, &pinched))
}

/// Build one part's mesh and make it renderable, returning the line to print.
pub fn build_part(tools: &dyn Tools, id: &str, scad: &str, config: &str) -> Result<String> {
    let out = mesh_path(id);
    render(tools, scad, &out, config)?;
    let before = volume(tools, &out)?;
    let notes = solidify(tools, &out)?;
    let after = volume(tools, &out)?;
    if (after - before).abs() > VOLUME_EPS {
        bail!("{out} enclosed {before} mm3 as rendered and {after} mm3 once made renderable; nothing here may move geometry");
    }
    let kib = tools.size(&out)? / 1024;
    Ok(format!("{kib} KiB{}{}", if notes.is_empty() { "" } else { "  " }, notes.join(", ")))
}

/// Run one mesh job, reporting its line or its failure.
pub fn mesh_outcome(tools: &dyn Tools, work: &MeshWork, config: &str) -> Outcome {
    match build_part(tools, &work.id, &work.scad, config) {
        Ok(line) => Outcome { ok: true, output: format!("  {} ... {line}\n", work.id) },
        Err(e) => Outcome { ok: false, output: format!("  {} ... FAILED\n{e:#}\n", work.id) },
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::config::parse;
    use serde_json::json;
    use std::sync::Mutex;

    /// A scripted toolset: every call is recorded, volumes are served in order.
    struct Fake {
        calls: Mutex<Vec<String>>,
        volumes: Mutex<Vec<f64>>,
        render_ok: bool,
        pinch_ok: bool,
    }

    impl Fake {
        fn new(volumes: &[f64]) -> Fake {
            Fake { calls: Mutex::new(vec![]), volumes: Mutex::new(volumes.to_vec()), render_ok: true, pinch_ok: true }
        }
        fn calls(&self) -> Vec<String> {
            self.calls.lock().unwrap().clone()
        }
    }

    impl Tools for Fake {
        fn openscad(&self, args: &[&str]) -> Result<Run> {
            self.calls.lock().unwrap().push(format!("openscad {}", args.join(" ")));
            Ok(Run { ok: self.render_ok, stdout: String::new(), stderr: "ERROR: boom\n".into() })
        }
        fn scadmesh(&self, args: &[&str]) -> Result<(bool, Value)> {
            self.calls.lock().unwrap().push(format!("scadmesh {}", args[0]));
            Ok(match args[0] {
                "info" => (true, json!([{ "volume_mm3": self.volumes.lock().unwrap().remove(0) }])),
                "settle" => (true, json!({ "merged": 3 })),
                "repair" => (true, json!({ "filled": 1, "dropped": 2 })),
                _ => (self.pinch_ok, json!({ "contacts": [1] })),
            })
        }
        fn size(&self, _: &str) -> Result<u64> {
            Ok(4096)
        }
    }

    const CFG: &str = r#"{"parts": [
        {"id": "a", "scad": "a.scad"},
        {"id": "b", "scad": "b.scad", "configs": ["revised"]},
        {"id": "c", "scad": "c.scad", "meshes": false}]}"#;

    #[test]
    fn jobs_cover_the_mesh_parts_of_the_configuration() {
        let cfg = parse(CFG).unwrap();
        let ids = |c: &str| mesh_work("g", &cfg, c).iter().map(|w| w.job.id.clone()).collect::<Vec<_>>();
        assert_eq!(ids("revised"), ["g/mesh-a", "g/mesh-b"]);
        assert_eq!(ids("previous"), ["g/mesh-a"]);
        let w = &mesh_work("g", &cfg, "previous")[0];
        assert_eq!(w.job.writes, ["g/out/asm/a.stl"]);
        assert_eq!((w.id.as_str(), w.scad.as_str()), ("a", "a.scad"));
    }

    #[test]
    fn a_part_is_rendered_then_settled_repaired_and_pinched() {
        let t = Fake::new(&[10.0, 10.0]);
        let line = build_part(&t, "a", "a.scad", "revised").unwrap();
        assert_eq!(line, "4 KiB  3 vertices settled, 1 gaps filled, 2 facets dropped, 1 contacts opened");
        let calls = t.calls();
        assert_eq!(calls[0], "openscad -o out/asm/a.stl --export-format=binstl -D config=\"revised\" a.scad");
        let steps: Vec<_> = calls[1..].iter().map(String::as_str).collect();
        assert_eq!(steps, ["scadmesh info", "scadmesh settle", "scadmesh repair", "scadmesh pinch", "scadmesh info"]);
    }

    #[test]
    fn a_part_that_needed_no_repair_prints_only_its_size() {
        assert_eq!(notes(&json!({}), &json!({}), &json!({})), Vec::<String>::new());
    }

    #[test]
    fn a_volume_shift_fails_the_part() {
        let t = Fake::new(&[10.0, 10.5]);
        let e = build_part(&t, "a", "a.scad", "revised").unwrap_err().to_string();
        assert!(e.contains("nothing here may move geometry"), "{e}");
    }

    #[test]
    fn a_volume_within_tolerance_passes() {
        let t = Fake::new(&[10.0, 10.0005]);
        assert!(build_part(&t, "a", "a.scad", "revised").is_ok());
    }

    #[test]
    fn a_failed_render_reports_openscad_stderr() {
        let t = Fake { render_ok: false, ..Fake::new(&[]) };
        let e = build_part(&t, "a", "a.scad", "revised").unwrap_err().to_string();
        assert!(e.contains("OpenSCAD failed rendering a.scad") && e.contains("boom"), "{e}");
    }

    #[test]
    fn an_unsolid_result_fails_the_part() {
        let t = Fake { pinch_ok: false, ..Fake::new(&[10.0]) };
        let e = build_part(&t, "a", "a.scad", "revised").unwrap_err().to_string();
        assert!(e.contains("still not a solid"), "{e}");
    }

    #[test]
    fn a_missing_volume_is_an_error() {
        struct NoVolume;
        impl Tools for NoVolume {
            fn openscad(&self, _: &[&str]) -> Result<Run> {
                Ok(Run { ok: true, stdout: String::new(), stderr: String::new() })
            }
            fn scadmesh(&self, _: &[&str]) -> Result<(bool, Value)> {
                Ok((true, json!([{}])))
            }
            fn size(&self, _: &str) -> Result<u64> {
                Ok(0)
            }
        }
        assert!(build_part(&NoVolume, "a", "a.scad", "revised").unwrap_err().to_string().contains("no volume"));
    }

    #[test]
    fn outcomes_carry_the_line_or_the_failure() {
        let w = &mesh_work("g", &parse(CFG).unwrap(), "revised")[0];
        let ok = mesh_outcome(&Fake::new(&[1.0, 1.0]), w, "revised");
        assert!(ok.ok && ok.output.starts_with("  a ... 4 KiB"));
        let bad = mesh_outcome(&Fake { render_ok: false, ..Fake::new(&[]) }, w, "revised");
        assert!(!bad.ok && bad.output.contains("a ... FAILED"));
    }

    #[test]
    fn the_context_runs_real_processes_and_reads_sizes() {
        let dir = std::env::temp_dir().join(format!("render-check-mesh-{}", std::process::id()));
        std::fs::create_dir_all(&dir).unwrap();
        std::fs::write(dir.join("f.bin"), [0u8; 10]).unwrap();
        let ctx = Ctx { dir: dir.clone(), openscad: "definitely-not-a-tool".into(), scadmesh: "definitely-not-a-tool".into() };
        assert_eq!(ctx.size("f.bin").unwrap(), 10);
        assert!(ctx.size("missing.bin").is_err());
        assert!(ctx.openscad(&["x"]).is_err());
        assert!(ctx.scadmesh(&["x"]).is_err());
        std::fs::remove_dir_all(&dir).unwrap();
    }
}
