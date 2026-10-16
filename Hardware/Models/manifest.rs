#!/bin/bash
//! 2>/dev/null; command -v rust-script >/dev/null 2>&1 || { echo "Error: Install rust-script with: cargo install rust-script" >&2; exit 1; }; exec rust-script "$0" "$@"
//! Regenerate `MANIFEST.csv`: every model and model-source file under Hardware/Models with its size,
//! SHA-256 and, for STLs, format and triangle count (README § Layout owns the column meanings).
//!
//! ```text
//! ./manifest.rs [--check]
//! ```
//!
//! Run it from anywhere. The file set is what git tracks or would track (`git ls-files -co
//! --exclude-standard`), less the derived and configuration files in `EXCLUDED_PATHS` and `EXCLUDED_NAMES`. Rows already in the manifest
//! keep their order, so a regeneration diffs only what changed; rows for files that are gone drop out, and
//! new files are appended in path order. Sizes and hashes are of the repository bytes: text files count with
//! LF endings. `--check` writes nothing and exits 1 when the manifest is out of date.
//!
//! ```cargo
//! [dependencies]
//! anyhow = "1"
//! sha2 = "0.10"
//! ```

use anyhow::{bail, Context, Result};
use sha2::{Digest, Sha256};
use std::collections::BTreeMap;
use std::path::Path;
use std::process::Command;

const HEADER: &str = "path,group,bytes,stl_format_triangles,sha256";
const MANIFEST: &str = "MANIFEST.csv";
const TEXT_EXTENSIONS: [&str; 8] = ["step", "scad", "rs", "json", "md", "toml", "csv", "txt"];
/// Derived at the top level; the other Markdown files are model sources' documentation and are listed.
const EXCLUDED_PATHS: [&str; 3] = [MANIFEST, "PART-INDEX.md", "README.md"];
const EXCLUDED_NAMES: [&str; 3] = ["render.json", ".gitignore", "Cargo.lock"];

/// One manifest row.
#[derive(Debug, Clone, PartialEq)]
struct Row {
    path: String,
    group: String,
    bytes: usize,
    format: String,
    sha256: String,
}

impl Row {
    fn to_line(&self) -> String {
        format!("{},{},{},{},{}", self.path, self.group, self.bytes, self.format, self.sha256)
    }
}

fn extension(path: &str) -> &str {
    Path::new(path).extension().and_then(|e| e.to_str()).unwrap_or("")
}

fn file_name(path: &str) -> &str {
    path.rsplit('/').next().unwrap_or(path)
}

/// Whether a path belongs in the manifest: derived and configuration files do not.
fn included(path: &str) -> bool {
    !EXCLUDED_PATHS.contains(&path)
        && !EXCLUDED_NAMES.contains(&file_name(path))
        && !path.starts_with("out/")
        && !path.contains("/out/")
        && !path.contains("/target/")
}

/// The directory a file belongs to: a `NNN-Name` part group or `Reference`, else `(all)`.
fn group_of(path: &str) -> String {
    match path.split_once('/') {
        Some((dir, _)) if dir == "Reference" || is_part_group(dir) => dir.to_string(),
        _ => "(all)".to_string(),
    }
}

fn is_part_group(dir: &str) -> bool {
    let b = dir.as_bytes();
    b.len() > 4 && b[..3].iter().all(u8::is_ascii_digit) && b[3] == b'-'
}

fn is_text(path: &str) -> bool {
    TEXT_EXTENSIONS.contains(&extension(path)) || file_name(path).starts_with('.')
}

/// Text counted with LF endings, as the repository stores it.
fn normalize(bytes: &[u8]) -> Vec<u8> {
    let mut out = Vec::with_capacity(bytes.len());
    for (i, &b) in bytes.iter().enumerate() {
        if !(b == b'\r' && bytes.get(i + 1) == Some(&b'\n')) {
            out.push(b);
        }
    }
    out
}

/// `binary/<triangles>` when the size is exactly a binary STL's, else `ascii-or-nonstd`.
fn stl_format(bytes: &[u8]) -> String {
    if bytes.len() >= 84 {
        let n = u32::from_le_bytes([bytes[80], bytes[81], bytes[82], bytes[83]]) as usize;
        if bytes.len() == 84 + 50 * n {
            return format!("binary/{n}");
        }
    }
    "ascii-or-nonstd".to_string()
}

fn hex(digest: &[u8]) -> String {
    digest.iter().map(|b| format!("{b:02x}")).collect()
}

fn make_row(path: &str, raw: &[u8]) -> Row {
    let data = if is_text(path) { normalize(raw) } else { raw.to_vec() };
    let format = if extension(path) == "stl" { stl_format(&data) } else { String::new() };
    Row {
        path: path.to_string(),
        group: group_of(path),
        bytes: data.len(),
        format,
        sha256: hex(&Sha256::digest(&data)),
    }
}

/// Rows already in the manifest keep their order; new paths follow in path order.
fn merge(existing: &[String], fresh: BTreeMap<String, Row>) -> Vec<Row> {
    let mut fresh = fresh;
    let mut rows: Vec<Row> = existing.iter().filter_map(|p| fresh.remove(p)).collect();
    rows.extend(fresh.into_values());
    rows
}

/// The paths of a manifest's rows, in order.
fn existing_paths(text: &str) -> Vec<String> {
    text.lines().skip(1).filter_map(|l| l.split(',').next()).map(str::to_string).collect()
}

fn render(rows: &[Row], eol: &str) -> String {
    let mut out = String::from(HEADER);
    out.push_str(eol);
    for r in rows {
        out.push_str(&r.to_line());
        out.push_str(eol);
    }
    out
}

fn git_files(root: &Path) -> Result<Vec<String>> {
    let out = Command::new("git").current_dir(root).args(["ls-files", "-co", "--exclude-standard", "."]).output()
        .context("running git ls-files")?;
    if !out.status.success() {
        bail!("git ls-files failed: {}", String::from_utf8_lossy(&out.stderr));
    }
    Ok(String::from_utf8_lossy(&out.stdout).lines().map(str::to_string).collect())
}

fn gather(root: &Path, paths: &[String]) -> Result<BTreeMap<String, Row>> {
    let mut rows = BTreeMap::new();
    for p in paths.iter().filter(|p| included(p)) {
        let raw = std::fs::read(root.join(p)).with_context(|| format!("reading {p}"))?;
        rows.insert(p.clone(), make_row(p, &raw));
    }
    Ok(rows)
}

/// The manifest's text for the files under `root`, given its current text.
fn build(root: &Path, current: &str) -> Result<String> {
    let rows = merge(&existing_paths(current), gather(root, &git_files(root)?)?);
    Ok(render(&rows, if current.contains("\r\n") { "\r\n" } else { "\n" }))
}

fn run(root: &Path, check: bool) -> Result<bool> {
    let path = root.join(MANIFEST);
    let current = std::fs::read_to_string(&path).unwrap_or_default();
    let next = build(root, &current)?;
    if next == current {
        return Ok(true);
    }
    if !check {
        std::fs::write(&path, next)?;
    }
    Ok(false)
}

fn main() -> Result<()> {
    let check = std::env::args().any(|a| a == "--check");
    let root = models_dir()?;
    let current = run(&root, check)?;
    println!("{}", if current { "MANIFEST.csv is current" } else if check { "MANIFEST.csv is out of date" } else { "MANIFEST.csv updated" });
    if check && !current {
        std::process::exit(1);
    }
    Ok(())
}

/// The directory holding the manifest: the current one, else Hardware/Models under the repository.
fn models_dir() -> Result<std::path::PathBuf> {
    let here = std::env::current_dir()?;
    if here.join(MANIFEST).exists() {
        return Ok(here);
    }
    let top = Command::new("git").args(["rev-parse", "--show-toplevel"]).output().context("running git")?;
    Ok(Path::new(String::from_utf8_lossy(&top.stdout).trim()).join("Hardware/Models"))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn groups_follow_the_first_directory() {
        assert_eq!(group_of("200-ArmBody/a.scad"), "200-ArmBody");
        assert_eq!(group_of("Reference/meshes/x.stl"), "Reference");
        assert_eq!(group_of("print_fit.scad"), "(all)");
        assert_eq!(group_of("render-check/src/lib.rs"), "(all)");
    }

    #[test]
    fn derived_and_configuration_files_are_excluded() {
        assert!(!included("MANIFEST.csv"));
        assert!(!included("PART-INDEX.md"));
        assert!(!included("200-ArmBody/render.json"));
        assert!(!included("200-ArmBody/out/asm/a.stl"));
        assert!(included("200-ArmBody/a.view.json"));
        assert!(included("render.rs"));
        assert!(included("Reference/onshape-v1/README.md"));
    }

    #[test]
    fn text_is_counted_with_lf_endings() {
        let row = make_row("a.scad", b"x\r\ny\r\n");
        assert_eq!(row.bytes, 4);
        assert_eq!(row, make_row("a.scad", b"x\ny\n"));
    }

    #[test]
    fn binary_files_are_counted_as_they_are() {
        assert_eq!(make_row("a.f3d", b"x\r\ny").bytes, 4);
    }

    #[test]
    fn stl_format_is_binary_only_at_the_exact_size() {
        let mut stl = vec![0u8; 84 + 50];
        stl[80] = 1;
        assert_eq!(stl_format(&stl), "binary/1");
        stl.push(0);
        assert_eq!(stl_format(&stl), "ascii-or-nonstd");
        assert_eq!(stl_format(b"solid x"), "ascii-or-nonstd");
        assert_eq!(make_row("a.stl", &vec![0u8; 84]).format, "binary/0");
        assert_eq!(make_row("a.scad", b"x").format, "");
    }

    #[test]
    fn merge_keeps_order_drops_the_gone_and_appends_the_new() {
        let rows: BTreeMap<String, Row> = ["b.scad", "z.scad", "a.scad"].iter().map(|p| (p.to_string(), make_row(p, b"x"))).collect();
        let existing = vec!["b.scad".to_string(), "gone.scad".to_string(), "a.scad".to_string()];
        let merged: Vec<String> = merge(&existing, rows).into_iter().map(|r| r.path).collect();
        assert_eq!(merged, ["b.scad", "a.scad", "z.scad"]);
    }

    #[test]
    fn render_round_trips_through_existing_paths() {
        let rows = vec![make_row("a.scad", b"x"), make_row("b.scad", b"y")];
        let text = render(&rows, "\n");
        assert!(text.starts_with(HEADER));
        assert_eq!(existing_paths(&text), ["a.scad", "b.scad"]);
        assert!(render(&rows, "\r\n").contains("\r\n"));
    }

    #[test]
    fn an_empty_manifest_has_no_paths() {
        assert!(existing_paths("").is_empty());
    }

    #[test]
    fn run_writes_then_reports_current() {
        let dir = std::env::temp_dir().join(format!("manifest-test-{}", std::process::id()));
        std::fs::create_dir_all(dir.join("200-ArmBody")).unwrap();
        std::fs::write(dir.join("200-ArmBody/a.scad"), "x\n").unwrap();
        Command::new("git").current_dir(&dir).args(["init", "-q"]).status().unwrap();
        assert!(!run(&dir, true).unwrap());
        assert!(!run(&dir, false).unwrap());
        assert!(run(&dir, true).unwrap());
        let text = std::fs::read_to_string(dir.join(MANIFEST)).unwrap();
        assert!(text.contains("200-ArmBody/a.scad,200-ArmBody,2,,"));
        std::fs::remove_dir_all(&dir).unwrap();
    }
}
