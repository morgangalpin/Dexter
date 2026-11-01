//! Renders that need not run again. The rules are owned by
//! `specs/009.3-Render-Program.md` § Reusing a render; [`Reuse`] holds them to
//! every render of a run by standing in front of its tools.

use crate::meshes::Tools;
use crate::{diagnostics, Run};
use anyhow::Result;
use serde_json::{json, Value};
use std::time::{SystemTime, UNIX_EPOCH};

/// A toolset that runs a render only when its stamp does not cover it.
pub struct Reuse(pub Box<dyn Tools>);

/// The path a render writes.
fn output_of<'a>(args: &[&'a str]) -> Option<&'a str> {
    args.windows(2).find(|w| w[0] == "-o").map(|w| w[1])
}

/// The files a dependency list names: below its target's line, one to a line,
/// each but the last ending in a continuation, with their spaces escaped.
fn dependencies(text: &str) -> Vec<String> {
    let path = |line: &str| line.trim().trim_end_matches('\\').trim_end().replace("\\ ", " ");
    text.lines().skip(1).map(path).filter(|p| !p.is_empty()).collect()
}

fn now_ns() -> u64 {
    SystemTime::now().duration_since(UNIX_EPOCH).map_or(0, |d| d.as_nanos() as u64)
}

impl Reuse {
    /// What a stamp must name to cover a render with `args`.
    fn key(&self, args: &[&str]) -> String {
        format!("{}\n{}", self.0.openscad_id(), args.join("\n"))
    }

    /// Whether a stamp's file still has the time and size it had.
    fn unchanged(&self, dep: &Value) -> bool {
        match (dep[0].as_str(), dep[1].as_u64(), dep[2].as_u64()) {
            (Some(path), Some(time), Some(size)) => self.0.stat(path) == Some((time, size)),
            _ => false,
        }
    }

    /// The run a stamp stands for, if it covers this render.
    fn reused(&self, stamp: &str, out: &str, key: &str) -> Option<Run> {
        if !self.0.exists(out) {
            return None;
        }
        let v: Value = serde_json::from_str(&self.0.read(stamp).ok()?).ok()?;
        let deps = v["deps"].as_array()?;
        let covers = v["key"] == key && !deps.is_empty() && deps.iter().all(|d| self.unchanged(d));
        covers.then_some(Run { ok: true, stdout: v["stdout"].as_str()?.to_owned(), stderr: v["stderr"].as_str()?.to_owned() })
    }

    /// Stamp a render that began at `start`, unless a file it read was
    /// changed since then or one cannot be measured.
    fn stamp(&self, stamp: &str, deps: &str, key: &str, run: &Run, start: u64) -> Option<()> {
        let mut files = vec![];
        for path in dependencies(&self.0.read(deps).ok()?) {
            let (time, size) = self.0.stat(&path).filter(|(time, _)| *time <= start)?;
            files.push(json!([path, time, size]));
        }
        let text = json!({ "key": key, "stdout": run.stdout, "stderr": run.stderr, "deps": files }).to_string();
        self.0.write(stamp, &text).ok()
    }
}

impl Tools for Reuse {
    fn openscad(&self, args: &[&str]) -> Result<Run> {
        let Some(out) = output_of(args) else {
            return self.0.openscad(args);
        };
        let (stamp, deps, key) = (format!("{out}.stamp"), format!("{out}.deps"), self.key(args));
        if let Some(run) = self.reused(&stamp, out, &key) {
            return Ok(run);
        }
        self.0.remove(&stamp);
        let start = now_ns();
        let mut traced = vec!["-d", deps.as_str()];
        traced.extend(args);
        let run = self.0.openscad(&traced)?;
        if run.ok && diagnostics(&run.stderr).is_empty() {
            self.stamp(&stamp, &deps, &key, &run, start);
        }
        self.0.remove(&deps);
        Ok(run)
    }

    fn scadmesh(&self, args: &[&str]) -> Result<(bool, Value)> {
        self.0.scadmesh(args)
    }

    fn size(&self, path: &str) -> Result<u64> {
        self.0.size(path)
    }

    fn read(&self, path: &str) -> Result<String> {
        self.0.read(path)
    }

    fn exists(&self, path: &str) -> bool {
        self.0.exists(path)
    }

    fn remove(&self, path: &str) {
        self.0.remove(path)
    }

    fn ensure_parent(&self, path: &str) -> Result<()> {
        self.0.ensure_parent(path)
    }

    fn stat(&self, path: &str) -> Option<(u64, u64)> {
        self.0.stat(path)
    }

    fn write(&self, path: &str, text: &str) -> Result<()> {
        self.0.write(path, text)
    }

    fn openscad_id(&self) -> String {
        self.0.openscad_id()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use anyhow::bail;
    use std::collections::HashMap;
    use std::sync::atomic::{AtomicUsize, Ordering};
    use std::sync::{Arc, Mutex};

    /// An in-memory disk under a scripted OpenSCAD that reads `a.scad` and
    /// `lib/b c.scad`, writes its output and lists what it read.
    #[derive(Clone)]
    struct Disk {
        files: Arc<Mutex<HashMap<String, (u64, String)>>>,
        renders: Arc<AtomicUsize>,
        stderr: Arc<Mutex<String>>,
        ok: Arc<Mutex<bool>>,
        binary: Arc<Mutex<String>>,
    }

    impl Disk {
        fn new() -> Disk {
            let disk = Disk {
                files: Default::default(),
                renders: Default::default(),
                stderr: Arc::new(Mutex::new("ECHO: \"v = 4\"\n".into())),
                ok: Arc::new(Mutex::new(true)),
                binary: Arc::new(Mutex::new("openscad 1".into())),
            };
            disk.put("a.scad", 100, "module a();");
            disk.put("lib/b c.scad", 100, "module b();");
            disk
        }

        fn put(&self, path: &str, time: u64, text: &str) {
            self.files.lock().unwrap().insert(path.into(), (time, text.into()));
        }

        fn renders(&self) -> usize {
            self.renders.load(Ordering::SeqCst)
        }

        fn tools(&self) -> Reuse {
            Reuse(Box::new(self.clone()))
        }
    }

    impl Tools for Disk {
        fn openscad(&self, args: &[&str]) -> Result<Run> {
            self.renders.fetch_add(1, Ordering::SeqCst);
            let ok = *self.ok.lock().unwrap();
            if ok {
                self.put(output_of(args).unwrap(), 200, "mesh");
            }
            if let Some(d) = args.windows(2).find(|w| w[0] == "-d") {
                self.put(d[1], 200, "out.stl: \\\n\ta.scad \\\n\tlib/b\\ c.scad\n");
            }
            Ok(Run { ok, stdout: "out".into(), stderr: self.stderr.lock().unwrap().clone() })
        }
        fn scadmesh(&self, _: &[&str]) -> Result<(bool, Value)> {
            Ok((true, json!({"s": 1})))
        }
        fn size(&self, _: &str) -> Result<u64> {
            Ok(7)
        }
        fn read(&self, path: &str) -> Result<String> {
            match self.files.lock().unwrap().get(path) {
                Some(f) => Ok(f.1.clone()),
                None => bail!("no file {path}"),
            }
        }
        fn exists(&self, path: &str) -> bool {
            self.files.lock().unwrap().contains_key(path)
        }
        fn remove(&self, path: &str) {
            self.files.lock().unwrap().remove(path);
        }
        fn stat(&self, path: &str) -> Option<(u64, u64)> {
            self.files.lock().unwrap().get(path).map(|f| (f.0, f.1.len() as u64))
        }
        fn write(&self, path: &str, text: &str) -> Result<()> {
            self.put(path, 300, text);
            Ok(())
        }
        fn openscad_id(&self) -> String {
            self.binary.lock().unwrap().clone()
        }
    }

    const ARGS: [&str; 4] = ["-o", "out.stl", "-D", "config=\"revised\""];

    #[test]
    fn dependencies_are_read_below_the_target() {
        let text = "C:/g/out.stl: \\\n\tC:/g/a.scad \\\n\tC:/My\\ Docs/b.scad \\\n\tC:/g/c.scad\n";
        assert_eq!(dependencies(text), ["C:/g/a.scad", "C:/My Docs/b.scad", "C:/g/c.scad"]);
        assert!(dependencies("").is_empty());
    }

    #[test]
    fn an_unchanged_render_is_not_run_again_and_says_what_it_said() {
        let disk = Disk::new();
        let t = disk.tools();
        let first = t.openscad(&ARGS).unwrap();
        let second = t.openscad(&ARGS).unwrap();
        assert_eq!(disk.renders(), 1);
        assert!(second.ok);
        assert_eq!((second.stdout, second.stderr), (first.stdout, first.stderr));
        assert!(!disk.exists("out.stl.deps"), "the list is not left behind");
    }

    #[test]
    fn a_file_it_read_changing_either_way_renders_again() {
        for time in [90, 110] {
            let disk = Disk::new();
            let t = disk.tools();
            t.openscad(&ARGS).unwrap();
            disk.put("lib/b c.scad", time, "module b();");
            t.openscad(&ARGS).unwrap();
            assert_eq!(disk.renders(), 2, "time {time}");
        }
        let disk = Disk::new();
        let t = disk.tools();
        t.openscad(&ARGS).unwrap();
        disk.put("a.scad", 100, "module a(); // longer");
        t.openscad(&ARGS).unwrap();
        assert_eq!(disk.renders(), 2, "the same time at another size");
    }

    #[test]
    fn a_file_it_read_going_missing_renders_again() {
        let disk = Disk::new();
        let t = disk.tools();
        t.openscad(&ARGS).unwrap();
        disk.remove("a.scad");
        disk.put("a.scad", 100, "module a();");
        disk.remove("lib/b c.scad");
        t.openscad(&ARGS).unwrap();
        assert_eq!(disk.renders(), 2);
    }

    #[test]
    fn other_arguments_or_another_binary_render_again() {
        let disk = Disk::new();
        let t = disk.tools();
        t.openscad(&ARGS).unwrap();
        t.openscad(&["-o", "out.stl", "-D", "config=\"previous\""]).unwrap();
        assert_eq!(disk.renders(), 2);
        *disk.binary.lock().unwrap() = "openscad 2".into();
        t.openscad(&["-o", "out.stl", "-D", "config=\"previous\""]).unwrap();
        assert_eq!(disk.renders(), 3);
    }

    #[test]
    fn a_missing_output_renders_again() {
        let disk = Disk::new();
        let t = disk.tools();
        t.openscad(&ARGS).unwrap();
        disk.remove("out.stl");
        t.openscad(&ARGS).unwrap();
        assert_eq!(disk.renders(), 2);
    }

    #[test]
    fn a_render_with_a_diagnostic_is_never_kept() {
        let disk = Disk::new();
        *disk.stderr.lock().unwrap() = "WARNING: odd\n".into();
        let t = disk.tools();
        let r = t.openscad(&ARGS).unwrap();
        assert!(r.stderr.contains("WARNING"));
        t.openscad(&ARGS).unwrap();
        assert_eq!(disk.renders(), 2);
        assert!(!disk.exists("out.stl.stamp"));
    }

    #[test]
    fn a_failed_render_is_never_kept() {
        let disk = Disk::new();
        *disk.ok.lock().unwrap() = false;
        assert!(!disk.tools().openscad(&ARGS).unwrap().ok);
        assert!(!disk.exists("out.stl.stamp") && !disk.exists("out.stl.deps"));
    }

    #[test]
    fn a_file_edited_during_the_render_is_not_taken_as_rendered() {
        let disk = Disk::new();
        disk.put("a.scad", u64::MAX / 2, "module a();");
        disk.tools().openscad(&ARGS).unwrap();
        assert!(!disk.exists("out.stl.stamp"));
    }

    #[test]
    fn a_stale_stamp_goes_before_the_render_does() {
        let disk = Disk::new();
        let t = disk.tools();
        t.openscad(&ARGS).unwrap();
        assert!(disk.exists("out.stl.stamp"));
        disk.put("a.scad", 101, "module a();");
        *disk.ok.lock().unwrap() = false;
        t.openscad(&ARGS).unwrap();
        assert!(!disk.exists("out.stl.stamp"), "a failed render must not leave the old one");
    }

    #[test]
    fn an_unreadable_stamp_renders_again() {
        let disk = Disk::new();
        let t = disk.tools();
        t.openscad(&ARGS).unwrap();
        for text in ["not json", "{}", r#"{"key":"x","deps":[["a.scad"]]}"#] {
            disk.put("out.stl.stamp", 300, text);
            t.openscad(&ARGS).unwrap();
        }
        assert_eq!(disk.renders(), 4);
    }

    #[test]
    fn a_run_with_no_output_passes_straight_through() {
        let disk = Disk::new();
        assert_eq!(output_of(&["--version"]), None);
        struct Plain;
        impl Tools for Plain {
            fn openscad(&self, args: &[&str]) -> Result<Run> {
                Ok(Run { ok: args == ["--version"], stdout: String::new(), stderr: String::new() })
            }
            fn scadmesh(&self, _: &[&str]) -> Result<(bool, Value)> {
                bail!("unused")
            }
            fn size(&self, _: &str) -> Result<u64> {
                bail!("unused")
            }
        }
        assert!(Reuse(Box::new(Plain)).openscad(&["--version"]).unwrap().ok);
        assert!(!disk.exists("out.stl"));
    }

    #[test]
    fn everything_else_reaches_the_tools_beneath() {
        let disk = Disk::new();
        let t = disk.tools();
        assert_eq!(t.scadmesh(&["info"]).unwrap().1, json!({"s": 1}));
        assert_eq!(t.size("a.scad").unwrap(), 7);
        t.write("n.txt", "abc").unwrap();
        assert_eq!(t.read("n.txt").unwrap(), "abc");
        assert_eq!(t.stat("n.txt"), Some((300, 3)));
        assert!(t.exists("n.txt") && t.ensure_parent("x/y").is_ok());
        t.remove("n.txt");
        assert!(!t.exists("n.txt"));
        assert_eq!(t.openscad_id(), "openscad 1");
    }
}
