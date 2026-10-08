//! The per-group `render.json`: its schema is owned by
//! `specs/009.3-Render-Program.md`. This module reads it, checks its shape,
//! and turns its checks into jobs. What a check's own fields mean is for the
//! module of its kind.

use crate::plan::Job;
use anyhow::{bail, Context, Result};
use serde_json::Value;
use std::path::Path;

/// The file in a group directory that holds its config.
pub const CONFIG_FILE: &str = "render.json";

#[derive(Debug, Clone, PartialEq)]
pub struct Part {
    pub id: String,
    pub scad: String,
    /// The configurations the part exists in; `None` means all of them.
    pub configs: Option<Vec<String>>,
    pub meshes: bool,
}

#[derive(Debug, Clone, PartialEq)]
pub struct Check {
    pub kind: String,
    pub id: String,
    pub after: Vec<String>,
    pub weight: usize,
    pub writes: Vec<String>,
    /// The whole entry, for the module of the kind to read its own fields.
    pub fields: Value,
}

#[derive(Debug, Clone, PartialEq)]
pub struct GroupConfig {
    pub ref_dir: Option<String>,
    pub parts: Vec<Part>,
    pub checks: Vec<Check>,
}

/// Read `<dir>/render.json`.
pub fn load(dir: &Path) -> Result<GroupConfig> {
    let path = dir.join(CONFIG_FILE);
    let text = std::fs::read_to_string(&path).with_context(|| format!("reading {}", path.display()))?;
    parse(&text).with_context(|| format!("in {}", path.display()))
}

pub fn parse(text: &str) -> Result<GroupConfig> {
    let root: Value = serde_json::from_str(text).context("parsing the config")?;
    if !root.is_object() {
        bail!("the config is not a JSON object");
    }
    Ok(GroupConfig {
        ref_dir: opt_str(&root, "ref_dir")?,
        parts: list(&root, "parts")?.iter().map(part).collect::<Result<_>>()?,
        checks: list(&root, "checks")?.iter().map(check).collect::<Result<_>>()?,
    })
}

fn list<'a>(v: &'a Value, key: &str) -> Result<&'a [Value]> {
    match &v[key] {
        Value::Null => Ok(&[]),
        Value::Array(a) => Ok(a),
        other => bail!("\"{key}\" is not an array: {other}"),
    }
}

fn opt_str(v: &Value, key: &str) -> Result<Option<String>> {
    match &v[key] {
        Value::Null => Ok(None),
        Value::String(s) => Ok(Some(s.clone())),
        other => bail!("\"{key}\" is not a string: {other}"),
    }
}

fn req_str(v: &Value, key: &str) -> Result<String> {
    opt_str(v, key)?.with_context(|| format!("entry without a \"{key}\": {v}"))
}

fn strings(v: &Value, key: &str) -> Result<Option<Vec<String>>> {
    match &v[key] {
        Value::Null => Ok(None),
        Value::Array(a) => a
            .iter()
            .map(|s| s.as_str().map(str::to_owned).with_context(|| format!("\"{key}\" holds a non-string: {s}")))
            .collect::<Result<_>>()
            .map(Some),
        other => bail!("\"{key}\" is not an array: {other}"),
    }
}

fn part(v: &Value) -> Result<Part> {
    Ok(Part {
        id: req_str(v, "id")?,
        scad: req_str(v, "scad")?,
        configs: strings(v, "configs")?,
        meshes: v["meshes"].as_bool().unwrap_or(true),
    })
}

/// The files a check writes: its `writes` list, and its `out` file, which every kind
/// that renders names.
fn writes(v: &Value) -> Result<Vec<String>> {
    let mut w = strings(v, "writes")?.unwrap_or_default();
    w.extend(opt_str(v, "out")?.filter(|o| !w.contains(o)));
    Ok(w)
}

fn check(v: &Value) -> Result<Check> {
    let id = req_str(v, "id")?;
    let weight = match &v["weight"] {
        Value::Null => 1,
        w => w.as_u64().filter(|&n| n > 0).with_context(|| format!("{id}: weight is not a positive integer: {w}"))? as usize,
    };
    Ok(Check {
        kind: req_str(v, "kind").with_context(|| format!("check {id}"))?,
        after: strings(v, "after")?.unwrap_or_default(),
        writes: writes(v)?,
        fields: v.clone(),
        weight,
        id,
    })
}

impl GroupConfig {
    /// The parts present in `config`, in render order.
    pub fn parts_for(&self, config: &str) -> Vec<&Part> {
        let present = |p: &&Part| p.configs.as_ref().is_none_or(|cs| cs.iter().any(|c| c == config));
        self.parts.iter().filter(present).collect()
    }

    /// The checks as jobs, with ids and `after` targets qualified by `group`.
    /// A target that already names a group (`600-StrainWave/630-005`) is kept.
    pub fn jobs(&self, group: &str) -> Vec<Job> {
        let qualify = |id: &str| if id.contains('/') { id.to_owned() } else { format!("{group}/{id}") };
        self.checks
            .iter()
            .map(|c| Job {
                id: qualify(&c.id),
                after: c.after.iter().map(|a| qualify(a)).collect(),
                weight: c.weight,
                writes: c.writes.iter().map(|w| format!("{group}/{w}")).collect(),
            })
            .collect()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    const SAMPLE: &str = r#"{
        "ref_dir": "../Reference/meshes/700-Differential",
        "parts": [
            {"id": "730-001", "scad": "730-001_DiffBodyA.scad"},
            {"id": "720-004", "scad": "720-004_DiffShaftPulley.scad", "configs": ["revised"], "meshes": false}
        ],
        "checks": [
            {"kind": "dist_gate", "id": "gate", "tol": 0.15, "out": "out/g.stl"},
            {"kind": "counts", "id": "teeth", "after": ["gate", "600-StrainWave/630-005"], "weight": 2, "writes": ["out/a.stl"]}
        ]
    }"#;

    #[test]
    fn parses_parts_and_checks() {
        let c = parse(SAMPLE).unwrap();
        assert_eq!(c.ref_dir.as_deref(), Some("../Reference/meshes/700-Differential"));
        assert_eq!(c.parts.len(), 2);
        assert!(c.parts[0].meshes && c.parts[0].configs.is_none());
        assert!(!c.parts[1].meshes);
        assert_eq!(c.checks[1].after, ["gate", "600-StrainWave/630-005"]);
        assert_eq!(c.checks[1].weight, 2);
        assert_eq!(c.checks[0].fields["tol"], 0.15);
    }

    #[test]
    fn missing_sections_are_empty() {
        let c = parse("{}").unwrap();
        assert!(c.ref_dir.is_none() && c.parts.is_empty() && c.checks.is_empty());
    }

    #[test]
    fn parts_for_filters_by_configuration() {
        let c = parse(SAMPLE).unwrap();
        let ids = |cfg: &str| c.parts_for(cfg).iter().map(|p| p.id.clone()).collect::<Vec<_>>();
        assert_eq!(ids("revised"), ["730-001", "720-004"]);
        assert_eq!(ids("previous"), ["730-001"]);
    }

    #[test]
    fn jobs_qualify_ids_and_local_targets_only() {
        let jobs = parse(SAMPLE).unwrap().jobs("700-Differential");
        assert_eq!(jobs[0].id, "700-Differential/gate");
        assert_eq!(jobs[1].after, ["700-Differential/gate", "600-StrainWave/630-005"]);
        assert_eq!((jobs[1].weight, jobs[1].writes.clone()), (2, vec!["700-Differential/out/a.stl".to_string()]));
        assert_eq!(jobs[0].writes, ["700-Differential/out/g.stl"], "an out file is a write");
    }

    #[test]
    fn rejects_malformed_configs() {
        let bad = |t: &str| parse(t).unwrap_err().to_string();
        assert!(bad("[]").contains("not a JSON object"));
        assert!(bad("{").contains("parsing"));
        assert!(bad(r#"{"parts": 3}"#).contains("not an array"));
        assert!(bad(r#"{"ref_dir": 3}"#).contains("not a string"));
        assert!(bad(r#"{"parts": [{"id": "a"}]}"#).contains("\"scad\""));
        assert!(bad(r#"{"checks": [{"id": "a"}]}"#).contains("check a"));
        assert!(bad(r#"{"checks": [{"id": "a", "kind": "k", "weight": 0}]}"#).contains("weight"));
        assert!(bad(r#"{"checks": [{"id": "a", "kind": "k", "after": [1]}]}"#).contains("non-string"));
        assert!(bad(r#"{"checks": [{"id": "a", "kind": "k", "after": "b"}]}"#).contains("not an array"));
    }

    #[test]
    fn load_reads_the_file_and_names_it_on_error() {
        let dir = std::env::temp_dir().join(format!("render-check-cfg-{}", std::process::id()));
        std::fs::create_dir_all(&dir).unwrap();
        assert!(load(&dir).unwrap_err().to_string().contains("render.json"));
        std::fs::write(dir.join(CONFIG_FILE), SAMPLE).unwrap();
        assert_eq!(load(&dir).unwrap().parts.len(), 2);
        std::fs::write(dir.join(CONFIG_FILE), "{").unwrap();
        assert!(load(&dir).unwrap_err().to_string().contains("render.json"));
        std::fs::remove_dir_all(&dir).unwrap();
    }
}
