//! `--verify`: the check kinds a `render.json` may list. Each kind is a module
//! of this directory, runs one job against an injected toolset, and reports into
//! a buffered [`Report`] so concurrent jobs never interleave their output. The
//! kinds and their schema are owned by `specs/009.3-Render-Program.md`; the
//! fields a kind reads are documented at the head of its module.

pub mod clash;
pub mod clone;
pub mod counts;
pub mod diameters;
pub mod dist_gate;
pub mod empty;
pub mod extents;
pub mod face;
pub mod fits;
pub mod plate;
pub mod gear_fit;
pub mod probes;
pub mod render;
pub mod seat;

use crate::config::Check;
use crate::meshes::Tools;
use crate::sched::Outcome;
use crate::{diagnostics, Run};
use anyhow::{anyhow, bail, Context, Result};
use serde_json::Value;

/// What a check can see besides its own fields.
pub struct Env<'a> {
    pub tools: &'a dyn Tools,
    /// The group's `ref_dir`, which names where reference meshes live.
    pub ref_dir: Option<&'a str>,
}

/// The buffered verdicts of one job.
#[derive(Default)]
pub struct Report {
    pub text: String,
    pub failures: usize,
}

impl Report {
    pub fn record(&mut self, label: &str, ok: bool) {
        self.text.push_str(&format!("  {}  {label}\n", if ok { "PASS" } else { "FAIL" }));
        self.failures += usize::from(!ok);
    }

    /// A line of detail under the verdict it explains.
    pub fn note(&mut self, line: &str) {
        self.text.push_str(&format!("      {line}\n"));
    }

    pub fn outcome(self) -> Outcome {
        Outcome { ok: self.failures == 0, output: self.text }
    }
}

/// A typed view of one JSON object of a check, naming the check in its errors.
#[derive(Clone, Copy)]
pub struct Fields<'a> {
    v: &'a Value,
    id: &'a str,
}

impl<'a> Fields<'a> {
    pub fn new(v: &'a Value, id: &'a str) -> Fields<'a> {
        Fields { v, id }
    }

    fn missing(&self, key: &str, what: &str) -> anyhow::Error {
        anyhow!("{}: \"{key}\" is missing or is not {what}", self.id)
    }

    pub fn str(&self, key: &str) -> Result<&'a str> {
        self.v[key].as_str().ok_or_else(|| self.missing(key, "a string"))
    }

    pub fn f64(&self, key: &str) -> Result<f64> {
        self.v[key].as_f64().ok_or_else(|| self.missing(key, "a number"))
    }

    pub fn u64(&self, key: &str) -> Result<u64> {
        self.v[key].as_u64().ok_or_else(|| self.missing(key, "a whole number"))
    }

    pub fn f64_list(&self, key: &str) -> Result<Vec<f64>> {
        let list = self.v[key].as_array().ok_or_else(|| self.missing(key, "a list of numbers"))?;
        list.iter().map(|n| n.as_f64().ok_or_else(|| self.missing(key, "a list of numbers"))).collect()
    }

    pub fn opt_f64(&self, key: &str) -> Option<f64> {
        self.v[key].as_f64()
    }

    pub fn f64_or(&self, key: &str, default: f64) -> f64 {
        self.v[key].as_f64().unwrap_or(default)
    }

    pub fn v_bool(&self, key: &str) -> Result<bool> {
        self.v[key].as_bool().ok_or_else(|| self.missing(key, "true or false"))
    }

    pub fn str_or(&self, key: &str, default: &'a str) -> &'a str {
        self.v[key].as_str().unwrap_or(default)
    }

    /// A list of strings; absent means empty.
    pub fn strings(&self, key: &str) -> Result<Vec<&'a str>> {
        match &self.v[key] {
            Value::Null => Ok(vec![]),
            Value::Array(a) => a.iter().map(|s| s.as_str().ok_or_else(|| self.missing(key, "a list of strings"))).collect(),
            _ => Err(self.missing(key, "a list")),
        }
    }

    /// A list of three numbers, such as a point.
    pub fn point(&self, key: &str) -> Result<[f64; 3]> {
        let a = self.v[key].as_array().filter(|a| a.len() == 3);
        let n = |i: usize| a.and_then(|a| a[i].as_f64()).ok_or_else(|| self.missing(key, "three numbers"));
        Ok([n(0)?, n(1)?, n(2)?])
    }

    /// As `items`, with an absent list meaning none.
    pub fn items_or_empty(&self, key: &str) -> Result<Vec<Fields<'a>>> {
        if self.v[key].is_null() {
            return Ok(vec![]);
        }
        self.items(key)
    }

    /// The objects of a list, each as its own view.
    pub fn items(&self, key: &str) -> Result<Vec<Fields<'a>>> {
        let list = self.v[key].as_array().ok_or_else(|| self.missing(key, "a list"))?;
        Ok(list.iter().map(|v| Fields { v, id: self.id }).collect())
    }
}

/// The `-D config="..."` definition of a check that names a configuration.
pub fn config_defines(f: &Fields) -> Vec<String> {
    f.str("config").map(|c| vec![format!("config=\"{c}\"")]).unwrap_or_default()
}

/// The path of the check's reference mesh under the group's `ref_dir`.
pub fn reference_path(env: &Env, f: &Fields) -> Result<String> {
    let dir = env.ref_dir.context("the group's render.json has no \"ref_dir\"")?;
    Ok(format!("{dir}/{}", f.str("reference")?))
}

/// A number echoed as `ECHO: <name> = <value>` in OpenSCAD's stderr or an echo log.
pub fn echoed_number(text: &str, name: &str) -> Result<f64> {
    let value = crate::echoed(text, &format!("{name} = ")).with_context(|| format!("{name} not echoed"))?;
    value.parse().with_context(|| format!("{name} is not a number: {value}"))
}

/// Run OpenSCAD on `scad` into `out` and hold the run to exiting cleanly and
/// rendering silently. The diagnostics are a verdict of their own, separate
/// from the measurements that follow: a part that warns and then measures well
/// has not passed, it has measured a mesh nobody should be measuring.
pub fn render_judged(env: &Env, scad: &str, out: &str, defines: &[String], rep: &mut Report) -> Result<Run> {
    render_extra(env, scad, out, defines, &[], rep)
}

/// As `render_judged`, with `extra` OpenSCAD flags such as `--export-format binstl`.
pub fn render_extra(env: &Env, scad: &str, out: &str, defines: &[String], extra: &[&str], rep: &mut Report) -> Result<Run> {
    env.tools.ensure_parent(out)?;
    let mut args = vec!["-o", out];
    for d in defines {
        args.extend(["-D", d]);
    }
    args.extend(extra);
    args.push(scad);
    let r = env.tools.openscad(&args)?;
    if !r.ok {
        bail!("OpenSCAD failed on {scad}:\n{}", r.stderr.trim_end());
    }
    let complaints = diagnostics(&r.stderr);
    complaints.iter().for_each(|line| rep.note(line));
    rep.record(&format!("{scad} ({}) renders without diagnostics", defines.join(", ")), complaints.is_empty());
    Ok(r)
}

fn dispatch(env: &Env, check: &Check, rep: &mut Report) -> Result<()> {
    let f = Fields::new(&check.fields, &check.id);
    match check.kind.as_str() {
        "render" => render::run(env, &f, rep),
        "dist_gate" => dist_gate::run(env, &f, rep),
        "clone" => clone::run(env, &f, rep),
        "counts" => counts::run(env, &f, rep),
        "diameters" => diameters::run(env, &f, rep),
        "fits" => fits::run(env, &f, rep),
        "clash" => clash::run(env, &f, rep),
        "face" => face::run(env, &f, rep),
        "gear_fit" => gear_fit::run(env, &f, rep),
        "plate" => plate::run(env, &f, rep),
        "probes" => probes::run(env, &f, rep),
        "seat" => seat::run(env, &f, rep),
        "extents" => extents::run(env, &f, rep),
        "interference" => empty::interference(env, &f, rep),
        "keepout" => empty::keepout(env, &f, rep),
        other => bail!("check kind \"{other}\" is not yet ported"),
    }
}

/// Run one check. An error anywhere in it is a failed verdict, not a crash.
pub fn run_check(env: &Env, check: &Check) -> Outcome {
    let mut rep = Report::default();
    if let Err(e) = dispatch(env, check, &mut rep) {
        rep.note(&format!("error: {e:#}"));
        rep.failures += 1;
    }
    rep.outcome()
}

#[cfg(test)]
pub mod testing {
    use super::*;
    use std::collections::HashMap;
    use std::sync::Mutex;

    /// A scripted toolset: calls are recorded, OpenSCAD answers with a fixed
    /// run, and `scadmesh` answers by subcommand.
    pub struct Fake {
        pub calls: Mutex<Vec<String>>,
        pub openscad_ok: bool,
        pub stderr: String,
        pub scadmesh_ok: bool,
        pub reports: HashMap<&'static str, Value>,
        pub files: HashMap<&'static str, &'static str>,
        pub present: Vec<&'static str>,
        /// Answers chosen by the mesh path in the request, ahead of `reports`.
        pub by_path: Vec<(&'static str, Value)>,
    }

    impl Default for Fake {
        fn default() -> Fake {
            Fake::new()
        }
    }

    impl Fake {
        pub fn new() -> Fake {
            Fake {
                calls: Mutex::new(vec![]),
                openscad_ok: true,
                stderr: String::new(),
                scadmesh_ok: true,
                reports: HashMap::new(),
                files: HashMap::new(),
                present: vec![],
                by_path: vec![],
            }
        }

        pub fn with(mut self, sub: &'static str, report: Value) -> Fake {
            self.reports.insert(sub, report);
            self
        }

        pub fn calls(&self) -> Vec<String> {
            self.calls.lock().unwrap().clone()
        }
    }

    impl Tools for Fake {
        fn openscad(&self, args: &[&str]) -> Result<Run> {
            self.calls.lock().unwrap().push(format!("openscad {}", args.join(" ")));
            Ok(Run { ok: self.openscad_ok, stdout: String::new(), stderr: self.stderr.clone() })
        }

        fn scadmesh(&self, args: &[&str]) -> Result<(bool, Value)> {
            self.calls.lock().unwrap().push(format!("scadmesh {}", args.join(" ")));
            let line = args.join(" ");
            let by_path = self.by_path.iter().find(|(p, _)| line.contains(p)).map(|(_, v)| v.clone());
            Ok((self.scadmesh_ok, by_path.or_else(|| self.reports.get(args[0]).cloned()).unwrap_or(Value::Null)))
        }

        fn size(&self, _: &str) -> Result<u64> {
            Ok(0)
        }

        fn exists(&self, path: &str) -> bool {
            self.present.contains(&path)
        }

        fn remove(&self, path: &str) {
            self.calls.lock().unwrap().push(format!("remove {path}"));
        }

        fn read(&self, path: &str) -> Result<String> {
            self.files.get(path).map(|s| s.to_string()).with_context(|| format!("no file {path}"))
        }
    }

    /// Run one check of `kind` with `fields` (a JSON object body) against `tools`.
    pub fn check(kind: &str, fields: Value, tools: &Fake) -> Outcome {
        let mut v = fields;
        v["kind"] = kind.into();
        v["id"] = "t".into();
        let c = crate::config::parse(&serde_json::json!({ "checks": [v] }).to_string()).unwrap().checks.remove(0);
        run_check(&Env { tools, ref_dir: Some("ref") }, &c)
    }
}

#[cfg(test)]
mod tests {
    use super::testing::*;
    use super::*;
    use serde_json::json;

    #[test]
    fn a_report_counts_failures_and_indents_notes() {
        let mut r = Report::default();
        r.record("a", true);
        r.record("b", false);
        r.note("why");
        assert_eq!(r.text, "  PASS  a\n  FAIL  b\n      why\n");
        assert!(!r.outcome().ok);
    }

    #[test]
    fn fields_read_typed_values_and_name_the_check_on_error() {
        let v = json!({"s": "x", "n": 2.5, "u": 4, "l": ["a", "b"], "p": [1, 2, 3], "items": [{"s": "y"}]});
        let f = Fields::new(&v, "chk");
        assert_eq!((f.str("s").unwrap(), f.f64("n").unwrap(), f.u64("u").unwrap()), ("x", 2.5, 4));
        assert_eq!(f.strings("l").unwrap(), vec!["a", "b"]);
        assert_eq!(f.strings("absent").unwrap(), Vec::<&str>::new());
        assert_eq!(f.point("p").unwrap(), [1.0, 2.0, 3.0]);
        assert_eq!(f.items("items").unwrap()[0].str("s").unwrap(), "y");
        assert_eq!((f.items_or_empty("items").unwrap().len(), f.items_or_empty("none").unwrap().len()), (1, 0));
        assert_eq!((f.f64_or("zz", 7.0), f.str_or("zz", "d")), (7.0, "d"));
        let e = f.str("n").unwrap_err().to_string();
        assert!(e.contains("chk") && e.contains("\"n\""), "{e}");
        assert!(f.strings("s").is_err() && f.strings("p").is_err() && f.point("l").is_err() && f.items("s").is_err());
        assert!(f.f64("s").is_err() && f.u64("n").is_err());
    }

    #[test]
    fn config_defines_name_the_configuration_when_there_is_one() {
        let v = json!({"config": "revised"});
        assert_eq!(config_defines(&Fields::new(&v, "c")), vec!["config=\"revised\""]);
        assert!(config_defines(&Fields::new(&json!({}), "c")).is_empty());
    }

    #[test]
    fn an_unknown_kind_and_a_missing_field_are_failed_verdicts() {
        let o = check("assembly_echo", json!({}), &Fake::new());
        assert!(!o.ok && o.output.contains("\"assembly_echo\" is not yet ported"), "{}", o.output);
        let o = check("render", json!({}), &Fake::new());
        assert!(!o.ok && o.output.contains("\"scad\""), "{}", o.output);
    }

    #[test]
    fn a_reference_needs_the_groups_ref_dir() {
        let v = json!({"reference": "a.stl"});
        let f = Fields::new(&v, "c");
        let fake = Fake::new();
        assert_eq!(reference_path(&Env { tools: &fake, ref_dir: Some("../R") }, &f).unwrap(), "../R/a.stl");
        assert!(reference_path(&Env { tools: &fake, ref_dir: None }, &f).is_err());
    }

    #[test]
    fn a_render_failure_is_an_error_and_a_warning_is_a_failed_verdict() {
        let mut fake = Fake::new();
        fake.openscad_ok = false;
        fake.stderr = "ERROR: assert".into();
        let rep = &mut Report::default();
        let env = Env { tools: &fake, ref_dir: None };
        let err = render_judged(&env, "p.scad", "o.stl", &[], rep).err().unwrap();
        assert!(err.to_string().contains("OpenSCAD failed on p.scad"));
        let mut noisy = Fake::new();
        noisy.stderr = "WARNING: w\n".into();
        let env = Env { tools: &noisy, ref_dir: None };
        render_judged(&env, "p.scad", "o.stl", &["config=\"x\"".into()], rep).unwrap();
        assert_eq!(rep.failures, 1);
        assert!(rep.text.contains("WARNING: w") && rep.text.contains("p.scad (config=\"x\")"), "{}", rep.text);
        assert_eq!(noisy.calls(), vec!["openscad -o o.stl -D config=\"x\" p.scad"]);
    }
}
