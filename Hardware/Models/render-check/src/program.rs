//! The `render.rs` driver: discover the groups, build one job graph from their
//! configs, run it on the scheduler, and report in plan order. The behaviour is
//! owned by `specs/009.3-Render-Program.md`.

use crate::cli::Args;
use crate::config::{self, Check, GroupConfig};
use crate::kinds::{self, Env};
use crate::meshes::{self, MeshWork, Tools, OUT_DIR};
use crate::plan::{closure, Graph, Job};
use crate::sched::{run_jobs, JobResult, Outcome, Status};
use anyhow::{bail, Context, Result};
use std::collections::HashMap;
use std::path::Path;

/// The groups `target` names: every directory under `models` that holds a
/// config for `all`, otherwise the one directory.
pub fn groups(models: &Path, target: &str) -> Result<Vec<String>> {
    if target != "all" {
        if !models.join(target).join(config::CONFIG_FILE).is_file() {
            bail!("{target} has no {}", config::CONFIG_FILE);
        }
        return Ok(vec![target.to_owned()]);
    }
    let mut found: Vec<String> = std::fs::read_dir(models)?
        .filter_map(|e| e.ok())
        .filter(|e| e.path().join(config::CONFIG_FILE).is_file())
        .map(|e| e.file_name().to_string_lossy().into_owned())
        .collect();
    found.sort();
    Ok(found)
}

/// What a job does when it runs.
enum Task<'a> {
    Mesh(&'a dyn Tools, MeshWork),
    Check { tools: &'a dyn Tools, ref_dir: Option<String>, check: Check },
}

fn run_task(task: &Task, config: &str) -> Outcome {
    match task {
        Task::Mesh(tools, work) => meshes::mesh_outcome(*tools, work, config),
        Task::Check { tools, ref_dir, check } => kinds::run_check(&Env { tools: *tools, ref_dir: ref_dir.as_deref() }, check),
    }
}

/// The jobs of one group for the modes requested, with what runs each.
fn group_work<'a>(args: &Args, group: &str, cfg: &GroupConfig, tools: &'a dyn Tools) -> (Vec<Job>, Vec<Task<'a>>) {
    let (mut jobs, mut tasks) = (vec![], vec![]);
    if args.meshes {
        for w in meshes::mesh_work(group, cfg, &args.config) {
            jobs.push(w.job.clone());
            tasks.push(Task::Mesh(tools, w));
        }
    }
    if args.verify {
        for (job, check) in cfg.jobs(group).into_iter().zip(&cfg.checks) {
            jobs.push(job);
            tasks.push(Task::Check { tools, ref_dir: cfg.ref_dir.clone(), check: check.clone() });
        }
    }
    (jobs, tasks)
}

/// Resolve `--only`: an id as listed, or one local to the only group.
fn resolve_only(only: &str, groups: &[String]) -> String {
    match groups {
        [g] if !only.contains('/') => format!("{g}/{only}"),
        _ => only.to_owned(),
    }
}

fn restrict(jobs: Vec<Job>, only: &str) -> Result<Vec<Job>> {
    let keep = closure(&Graph::new(jobs.clone())?, only)?;
    Ok(jobs.into_iter().filter(|j| keep.contains(&j.id)).collect())
}

/// Every job's output in plan order, then the verdict. The exit status is 0
/// only when every job passed.
pub fn report(results: &[JobResult]) -> (String, i32) {
    let mut text = String::new();
    for r in results {
        let label = match r.status {
            Status::Passed => "PASS",
            Status::Failed => "FAIL",
            Status::Skipped => "SKIP",
        };
        text.push_str(&format!("{label}  {}\n{}", r.id, r.output));
    }
    let bad = results.iter().filter(|r| r.status != Status::Passed).count();
    text.push_str(&match bad {
        0 => format!("\nALL {} JOBS PASSED\n", results.len()),
        n => format!("\n{n} JOB(S) DID NOT PASS\n"),
    });
    (text, i32::from(bad > 0))
}

type Loaded = (String, GroupConfig, Box<dyn Tools>);
type ToolsFor<'a> = &'a dyn Fn(&Path) -> Result<Box<dyn Tools>>;

fn load_group(args: &Args, models: &Path, g: &str, tools_for: ToolsFor) -> Result<Loaded> {
    let dir = models.join(g);
    let cfg = config::load(&dir)?;
    if args.meshes {
        std::fs::create_dir_all(dir.join(OUT_DIR)).with_context(|| format!("creating {OUT_DIR} in {g}"))?;
    }
    Ok((g.to_owned(), cfg, tools_for(&dir)?))
}

/// The groups that `loaded` names in `after` entries and has not loaded.
fn missing_dependencies(loaded: &[Loaded], models: &Path) -> Vec<String> {
    let mut wanted: Vec<String> = loaded
        .iter()
        .flat_map(|(_, cfg, _)| cfg.checks.iter().flat_map(|c| c.after.iter()))
        .filter_map(|a| a.split_once('/').map(|(g, _)| g.to_owned()))
        .filter(|g| !loaded.iter().any(|l| &l.0 == g) && models.join(g).join(config::CONFIG_FILE).is_file())
        .collect();
    wanted.sort();
    wanted.dedup();
    wanted
}

/// The groups of the target and, transitively, the groups its checks wait on.
fn load_groups(args: &Args, models: &Path, tools_for: ToolsFor) -> Result<Vec<Loaded>> {
    let mut loaded = groups(models, &args.target)?.iter().map(|g| load_group(args, models, g, tools_for)).collect::<Result<Vec<_>>>()?;
    loop {
        let more = missing_dependencies(&loaded, models);
        if more.is_empty() {
            return Ok(loaded);
        }
        for g in more {
            loaded.push(load_group(args, models, &g, tools_for)?);
        }
    }
}

/// Replace each `group/*` in `after` with the ids of that group's jobs.
fn expand_group_waits(jobs: &mut [Job]) {
    let ids: Vec<String> = jobs.iter().map(|j| j.id.clone()).collect();
    for job in jobs {
        job.after = job
            .after
            .iter()
            .flat_map(|a| match a.strip_suffix('*') {
                Some(prefix) if prefix.ends_with('/') => ids.iter().filter(|i| i.starts_with(prefix)).cloned().collect(),
                _ => vec![a.clone()],
            })
            .collect();
    }
}

/// Run the program for `args` under `models`, with `tools_for` supplying the
/// tools of a group directory. Returns the report and the exit status.
pub fn execute(args: &Args, models: &Path, workers: usize, tools_for: &dyn Fn(&Path) -> Result<Box<dyn Tools>>) -> Result<(String, i32)> {
    let loaded = load_groups(args, models, tools_for)?;
    let targets = groups(models, &args.target)?;
    let (mut jobs, mut tasks) = (vec![], vec![]);
    for (g, cfg, tools) in &loaded {
        let (j, t) = group_work(args, g, cfg, tools.as_ref());
        jobs.extend(j);
        tasks.extend(t);
    }
    expand_group_waits(&mut jobs);
    let by_id: HashMap<String, Task> = jobs.iter().map(|j| j.id.clone()).zip(tasks).collect();
    if let Some(only) = &args.only {
        jobs = restrict(jobs, &resolve_only(only, &targets))?;
    }
    let graph = Graph::new(jobs)?;
    let results = run_jobs(&graph, args.jobs.unwrap_or(workers), args.fail_fast, |j| run_task(&by_id[&j.id], &args.config));
    Ok(report(&results))
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::cli::parse_args;
    use crate::Run;
    use serde_json::{json, Value};

    struct Stub;
    impl Tools for Stub {
        fn openscad(&self, args: &[&str]) -> Result<Run> {
            let bad = args.contains(&"bad.scad");
            Ok(Run { ok: !bad, stdout: String::new(), stderr: if bad { "ERROR: bad\n".into() } else { String::new() } })
        }
        fn scadmesh(&self, args: &[&str]) -> Result<(bool, Value)> {
            Ok((true, if args[0] == "info" { json!([{ "volume_mm3": 1.0 }]) } else { json!({}) }))
        }
        fn size(&self, _: &str) -> Result<u64> {
            Ok(2048)
        }
    }

    fn models(tag: &str, files: &[(&str, &str)]) -> std::path::PathBuf {
        let dir = std::env::temp_dir().join(format!("render-check-prog-{tag}-{}", std::process::id()));
        let _ = std::fs::remove_dir_all(&dir);
        for (g, text) in files {
            std::fs::create_dir_all(dir.join(g)).unwrap();
            std::fs::write(dir.join(g).join(config::CONFIG_FILE), text).unwrap();
        }
        dir
    }

    fn go(dir: &Path, cmd: &str) -> Result<(String, i32)> {
        let args = parse_args(cmd.split_whitespace().map(String::from))?;
        execute(&args, dir, 2, &|_| Ok(Box::new(Stub)))
    }

    const G: &str = r#"{"parts": [{"id": "a", "scad": "a.scad"}, {"id": "b", "scad": "b.scad"}]}"#;

    #[test]
    fn meshes_run_every_part_and_report_in_plan_order() {
        let dir = models("ok", &[("g", G)]);
        let (text, code) = go(&dir, "g --meshes").unwrap();
        assert_eq!(code, 0);
        assert!(text.find("g/mesh-a").unwrap() < text.find("g/mesh-b").unwrap());
        assert!(text.contains("  a ... 2 KiB") && text.contains("ALL 2 JOBS PASSED"), "{text}");
        assert!(dir.join("g").join(OUT_DIR).is_dir());
        std::fs::remove_dir_all(&dir).unwrap();
    }

    #[test]
    fn a_failing_part_fails_the_run_without_stopping_its_siblings() {
        let dir = models("fail", &[("g", r#"{"parts": [{"id": "a", "scad": "bad.scad"}, {"id": "b", "scad": "b.scad"}]}"#)]);
        let (text, code) = go(&dir, "g --meshes").unwrap();
        assert_eq!(code, 1);
        assert!(text.contains("FAIL  g/mesh-a") && text.contains("PASS  g/mesh-b") && text.contains("1 JOB(S)"), "{text}");
        std::fs::remove_dir_all(&dir).unwrap();
    }

    #[test]
    fn only_selects_one_job_by_local_or_qualified_id() {
        let dir = models("only", &[("g", G)]);
        for id in ["mesh-b", "g/mesh-b"] {
            let (text, _) = go(&dir, &format!("g --meshes --only {id}")).unwrap();
            assert!(text.contains("g/mesh-b") && !text.contains("g/mesh-a"), "{text}");
        }
        assert!(go(&dir, "g --meshes --only nope").is_err());
        std::fs::remove_dir_all(&dir).unwrap();
    }

    #[test]
    fn all_merges_every_group_that_has_a_config() {
        let dir = models("all", &[("g1", G), ("g2", G)]);
        std::fs::create_dir_all(dir.join("no-config")).unwrap();
        let (text, code) = go(&dir, "all --meshes").unwrap();
        assert_eq!(code, 0);
        assert!(text.contains("g1/mesh-a") && text.contains("g2/mesh-b") && text.contains("ALL 4 JOBS"), "{text}");
        let (only, _) = go(&dir, "all --meshes --only g2/mesh-a").unwrap();
        assert!(only.contains("ALL 1 JOBS") && only.contains("g2/mesh-a"), "{only}");
        std::fs::remove_dir_all(&dir).unwrap();
    }

    #[test]
    fn verify_reports_an_unported_check_kind_as_a_failure() {
        let dir = models("verify", &[("g", r#"{"checks": [{"kind": "assembly_echo", "id": "teeth"}]}"#)]);
        let (text, code) = go(&dir, "g").unwrap();
        assert_eq!(code, 1);
        assert!(text.contains("g/teeth") && text.contains("\"assembly_echo\" is not yet ported"), "{text}");
        std::fs::remove_dir_all(&dir).unwrap();
    }

    fn render_checks(ids: &[&str], after: &str) -> String {
        let one = |id: &&str| format!(r#"{{"kind": "render", "id": "{id}", "scad": "{id}.scad", "out": "out/{id}.stl", "after": [{after}]}}"#);
        format!(r#"{{"checks": [{}]}}"#, ids.iter().map(one).collect::<Vec<_>>().join(", "))
    }

    #[test]
    fn a_group_waits_on_another_groups_jobs_and_loads_it() {
        let dir = models("deps", &[("g1", &render_checks(&["top"], r#""g2/*""#)), ("g2", &render_checks(&["x", "y"], ""))]);
        let (text, code) = go(&dir, "g1").unwrap();
        assert_eq!(code, 0, "{text}");
        assert!(text.contains("g2/x") && text.contains("g2/y") && text.contains("ALL 3 JOBS"), "{text}");
        let (only, _) = go(&dir, "g1 --only top").unwrap();
        assert!(only.contains("ALL 3 JOBS"), "the wait comes along: {only}");
        std::fs::remove_dir_all(&dir).unwrap();
    }

    #[test]
    fn a_wait_on_a_failed_group_skips_the_dependent() {
        let bad = render_checks(&["bad"], "");
        let dir = models("depfail", &[("g1", &render_checks(&["top"], r#""g2/bad""#)), ("g2", &bad)]);
        let (text, code) = go(&dir, "g1").unwrap();
        assert_eq!(code, 1);
        assert!(text.contains("FAIL  g2/bad") && text.contains("SKIP  g1/top"), "{text}");
        std::fs::remove_dir_all(&dir).unwrap();
    }

    #[test]
    fn a_missing_group_is_an_error() {
        let dir = models("missing", &[("g", G)]);
        assert!(go(&dir, "nope --meshes").unwrap_err().to_string().contains("has no render.json"));
        std::fs::remove_dir_all(&dir).unwrap();
    }

    #[test]
    fn a_configuration_error_is_reported_before_any_job_runs() {
        let dir = models("cycle", &[("g", r#"{"checks": [{"kind": "k", "id": "a", "after": ["a"]}]}"#)]);
        assert!(go(&dir, "g").unwrap_err().to_string().contains("cycle"));
        std::fs::remove_dir_all(&dir).unwrap();
    }
}
