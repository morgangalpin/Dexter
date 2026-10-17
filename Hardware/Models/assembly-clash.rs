#!/bin/bash
//! 2>/dev/null; command -v rust-script >/dev/null 2>&1 || { echo "Error: Install rust-script with: cargo install rust-script" >&2; exit 1; }; exec rust-script "$0" "$@"
//! Check an assembly for overlaps, print-fit clearances and bearing bridging.
//!
//! ```text
//! ./assembly-clash.rs 100-Base/base_assembly.clash.json [--reuse] [-- <scadmesh clash options>]
//! ```
//!
//! The manifest sits beside the assembly it describes and is named
//! `<assembly>.clash.json`; its format is `openscad-tools/specs/003-CLI.md`
//! § The clash manifest. This script exports each listed part in assembled
//! position, through the assembly's `part` variable, as binary STL into
//! `out/clash/`, then runs `scadmesh clash` on them. The slip, press and
//! running clearances are read from `print_fit.scad`, never restated here.
//!
//! `--reuse` keeps the meshes already in `out/clash/` that are newer than every
//! `.scad` in the directory, so a re-run after changing only a rule or a
//! manifest takes seconds. Exits 1 when the check finds a violation.
//!
//! ```cargo
//! [dependencies]
//! anyhow = "1"
//! serde_json = "1"
//! render-check = { path = "render-check" }
//! ```

use anyhow::{bail, Context, Result};
use render_check::meshes::BACKEND;
use render_check::{diagnostics, print_fits, run, Ctx};
use std::path::{Path, PathBuf};
use std::time::SystemTime;

const MESH_DIR: &str = "out/clash";

/// The manifest and flags this script was given.
struct Args {
    manifest: PathBuf,
    reuse: bool,
    passthrough: Vec<String>,
}

fn parse_args(args: &[String]) -> Result<Args> {
    let (own, rest) = match args.iter().position(|a| a == "--") {
        Some(i) => (&args[..i], args[i + 1..].to_vec()),
        None => (args, Vec::new()),
    };
    let manifest = own.iter().find(|a| !a.starts_with("--")).context("usage: assembly-clash.rs <assembly>.clash.json [--reuse]")?;
    Ok(Args { manifest: PathBuf::from(manifest), reuse: own.iter().any(|a| a == "--reuse"), passthrough: rest })
}

/// The part ids a manifest lists, in order.
fn part_ids(text: &str) -> Result<Vec<String>> {
    let json: serde_json::Value = serde_json::from_str(text).context("parsing the manifest")?;
    let parts = json["parts"].as_array().context("the manifest has no parts array")?;
    parts.iter().map(|p| Ok(p["id"].as_str().context("a part has no id")?.to_string())).collect()
}

/// The assembly a manifest named `<stem>.clash.json` describes.
fn assembly_of(manifest: &Path) -> Result<String> {
    let name = manifest.file_name().and_then(|n| n.to_str()).context("manifest name")?;
    let stem = name.strip_suffix(".clash.json").with_context(|| format!("{name} is not <assembly>.clash.json"))?;
    Ok(format!("{stem}.scad"))
}

/// The newest modification time among the `.scad` files in `dir`.
fn newest_source(dir: &Path) -> Result<SystemTime> {
    let mut newest = SystemTime::UNIX_EPOCH;
    for entry in std::fs::read_dir(dir)? {
        let path = entry?.path();
        if path.extension().is_some_and(|e| e == "scad") {
            newest = newest.max(std::fs::metadata(&path)?.modified()?);
        }
    }
    Ok(newest)
}

fn fresh(path: &Path, sources: SystemTime) -> bool {
    std::fs::metadata(path).and_then(|m| m.modified()).is_ok_and(|t| t > sources)
}

/// Export one part, in assembled position, as binary STL on the Manifold
/// engine, and hold the render to silence.
fn export_part(ctx: &Ctx, scad: &str, id: &str, out: &str) -> Result<()> {
    let define = format!("part=\"{id}\"");
    let args = [BACKEND, "-o", out, "--export-format=binstl", "-D", &define, scad];
    let r = run(&ctx.openscad, &args, &ctx.dir)?;
    let complaints = diagnostics(&r.stderr);
    if !r.ok || !complaints.is_empty() {
        bail!("exporting {id} failed:\n{}", if r.ok { complaints.join("\n") } else { r.stderr.trim_end().to_string() });
    }
    Ok(())
}

/// Export every part not already fresh, returning how many were exported.
fn export(ctx: &Ctx, scad: &str, ids: &[String], reuse: bool) -> Result<usize> {
    let sources = newest_source(&ctx.dir)?;
    let mut made = 0;
    for id in ids {
        let out = format!("{MESH_DIR}/{id}.stl");
        if reuse && fresh(&ctx.dir.join(&out), sources) {
            continue;
        }
        println!("  exporting {id}");
        export_part(ctx, scad, id, &out)?;
        made += 1;
    }
    Ok(made)
}

fn clash_args(manifest: &str, fits: (f64, f64, f64), extra: &[String]) -> Vec<String> {
    let mut args: Vec<String> = ["clash", manifest, "--mesh-dir", MESH_DIR].map(String::from).to_vec();
    for (flag, v) in [("--slip", fits.0), ("--press", fits.1), ("--run", fits.2)] {
        args.extend([flag.to_string(), v.to_string()]);
    }
    args.extend(extra.iter().cloned());
    args
}

fn main() -> Result<()> {
    let args = parse_args(&std::env::args().skip(1).collect::<Vec<_>>())?;
    let manifest = std::fs::canonicalize(&args.manifest).context("reading the manifest")?;
    let dir = manifest.parent().context("manifest directory")?.to_path_buf();
    let ctx = Ctx::new(dir)?;
    std::fs::create_dir_all(ctx.dir.join(MESH_DIR))?;
    let ids = part_ids(&std::fs::read_to_string(&manifest)?)?;
    let scad = assembly_of(&manifest)?;
    println!("Exporting {} parts of {scad} to {MESH_DIR}/", ids.len());
    let made = export(&ctx, &scad, &ids, args.reuse)?;
    println!("{made} exported, {} reused", ids.len() - made);
    let name = manifest.file_name().and_then(|n| n.to_str()).context("manifest name")?;
    let cmd = clash_args(name, print_fits(&std::fs::read_to_string(ctx.dir.join("../print_fit.scad")).context("reading ../print_fit.scad")?)?, &args.passthrough);
    let refs: Vec<&str> = cmd.iter().map(String::as_str).collect();
    let r = run(&ctx.scadmesh, &refs, &ctx.dir)?;
    print!("{}", r.stdout);
    eprint!("{}", r.stderr);
    std::process::exit(if r.ok { 0 } else { 1 });
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn arguments_split_at_the_double_dash() {
        let a = parse_args(&["m.clash.json".into(), "--reuse".into(), "--".into(), "--spacing".into(), "0.1".into()]).unwrap();
        assert!(a.reuse);
        assert_eq!(a.passthrough, ["--spacing", "0.1"]);
        assert!(parse_args(&[]).is_err());
    }

    #[test]
    fn the_assembly_is_named_by_the_manifest() {
        assert_eq!(assembly_of(Path::new("d/base_assembly.clash.json")).unwrap(), "base_assembly.scad");
        assert!(assembly_of(Path::new("d/base.json")).is_err());
    }

    #[test]
    fn part_ids_come_in_manifest_order() {
        assert_eq!(part_ids(r#"{"parts":[{"id":"b"},{"id":"a"}]}"#).unwrap(), ["b", "a"]);
        assert!(part_ids("{}").is_err());
    }

    #[test]
    fn the_clearances_are_passed_to_scadmesh() {
        let c = clash_args("m.json", (0.15, 0.05, 0.5), &["--spacing=0.1".to_string()]);
        assert_eq!(c[..4], ["clash", "m.json", "--mesh-dir", MESH_DIR]);
        assert!(c.windows(2).any(|w| w == ["--run", "0.5"]));
        assert_eq!(c.last().unwrap(), "--spacing=0.1");
    }
}
