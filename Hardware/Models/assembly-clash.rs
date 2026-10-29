#!/bin/bash
//! 2>/dev/null; command -v rust-script >/dev/null 2>&1 || { echo "Error: Install rust-script with: cargo install rust-script" >&2; exit 1; }; exec rust-script "$0" "$@"
//! Check an assembly for overlaps, print-fit clearances and bearing bridging.
//!
//! ```text
//! ./assembly-clash.rs 100-Base/base_assembly.clash.json [--reuse] [--set NAME=VALUE ...] [-- <scadmesh clash options>]
//! ```
//!
//! The manifest sits beside the assembly it describes and is named
//! `<assembly>.clash.json`; its format is `openscad-tools/specs/003-CLI.md`
//! § The clash manifest. This script exports each listed part in assembled
//! position, through the assembly's `part` variable, as binary STL into
//! `out/clash/`, then runs `scadmesh clash` on them. The slip, press and
//! running clearances are read from `print_fit.scad`, never restated here.
//!
//! `--set NAME=VALUE`, repeatable, overrides one of the assembly's variables
//! (a pose, such as a gripper's `OPEN`) in every export, and keeps that pose's
//! meshes apart in `out/clash/NAME_VALUE/`.
//!
//! `--reuse` keeps the meshes already in the mesh directory that are newer than
//! every `.scad` in the directory, so a re-run after changing only a rule or a
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

const USAGE: &str = "usage: assembly-clash.rs <assembly>.clash.json [--reuse] [--set NAME=VALUE ...]";

/// The manifest and flags this script was given.
struct Args {
    manifest: PathBuf,
    reuse: bool,
    sets: Vec<String>,
    passthrough: Vec<String>,
}

fn parse_args(args: &[String]) -> Result<Args> {
    let (own, rest) = match args.iter().position(|a| a == "--") {
        Some(i) => (&args[..i], args[i + 1..].to_vec()),
        None => (args, Vec::new()),
    };
    let (mut manifest, mut reuse, mut sets) = (None, false, Vec::new());
    let mut it = own.iter();
    while let Some(a) = it.next() {
        match a.as_str() {
            "--reuse" => reuse = true,
            "--set" => sets.push(it.next().context(USAGE)?.clone()),
            s if s.starts_with("--set=") => sets.push(s["--set=".len()..].to_string()),
            s if !s.starts_with("--") && manifest.is_none() => manifest = Some(PathBuf::from(s)),
            other => bail!("unexpected argument {other}\n{USAGE}"),
        }
    }
    for s in &sets {
        if !s.split_once('=').is_some_and(|(n, v)| !n.is_empty() && !v.is_empty()) {
            bail!("--set takes NAME=VALUE, not {s}");
        }
    }
    Ok(Args { manifest: manifest.context(USAGE)?, reuse, sets, passthrough: rest })
}

/// Where a pose's meshes go: `out/clash/`, or for overridden variables a
/// subdirectory named by them, e.g. `out/clash/OPEN_12`.
fn mesh_dir(sets: &[String]) -> String {
    if sets.is_empty() {
        return MESH_DIR.to_string();
    }
    let name: Vec<String> = sets.iter().map(|s| s.chars().map(|c| if c.is_ascii_alphanumeric() || c == '.' || c == '-' { c } else { '_' }).collect()).collect();
    format!("{MESH_DIR}/{}", name.join("_"))
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

/// The OpenSCAD arguments that export one part with the given overrides.
fn export_args(scad: &str, id: &str, out: &str, sets: &[String]) -> Vec<String> {
    let mut args: Vec<String> = [BACKEND, "-o", out, "--export-format=binstl", "-D"].map(String::from).to_vec();
    args.push(format!("part=\"{id}\""));
    for s in sets {
        args.extend(["-D".to_string(), s.clone()]);
    }
    args.push(scad.to_string());
    args
}

/// Export one part, in assembled position, as binary STL on the Manifold
/// engine, and hold the render to silence.
fn export_part(ctx: &Ctx, scad: &str, id: &str, out: &str, sets: &[String]) -> Result<()> {
    let owned = export_args(scad, id, out, sets);
    let args: Vec<&str> = owned.iter().map(String::as_str).collect();
    let r = run(&ctx.openscad, &args, &ctx.dir)?;
    let complaints = diagnostics(&r.stderr);
    if !r.ok || !complaints.is_empty() {
        bail!("exporting {id} failed:\n{}", if r.ok { complaints.join("\n") } else { r.stderr.trim_end().to_string() });
    }
    Ok(())
}

/// Export every part not already fresh, returning how many were exported.
fn export(ctx: &Ctx, scad: &str, ids: &[String], reuse: bool, sets: &[String]) -> Result<usize> {
    let sources = newest_source(&ctx.dir)?;
    let dir = mesh_dir(sets);
    let mut made = 0;
    for id in ids {
        let out = format!("{dir}/{id}.stl");
        if reuse && fresh(&ctx.dir.join(&out), sources) {
            continue;
        }
        println!("  exporting {id}");
        export_part(ctx, scad, id, &out, sets)?;
        made += 1;
    }
    Ok(made)
}

fn clash_args(manifest: &str, mesh_dir: &str, fits: (f64, f64, f64), extra: &[String]) -> Vec<String> {
    let mut args: Vec<String> = ["clash", manifest, "--mesh-dir", mesh_dir].map(String::from).to_vec();
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
    let dir = mesh_dir(&args.sets);
    std::fs::create_dir_all(ctx.dir.join(&dir))?;
    let ids = part_ids(&std::fs::read_to_string(&manifest)?)?;
    let scad = assembly_of(&manifest)?;
    println!("Exporting {} parts of {scad} to {dir}/", ids.len());
    let made = export(&ctx, &scad, &ids, args.reuse, &args.sets)?;
    println!("{made} exported, {} reused", ids.len() - made);
    let name = manifest.file_name().and_then(|n| n.to_str()).context("manifest name")?;
    let cmd = clash_args(name, &dir, print_fits(&std::fs::read_to_string(ctx.dir.join("../print_fit.scad")).context("reading ../print_fit.scad")?)?, &args.passthrough);
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
    fn sets_are_collected_in_either_form() {
        let a = parse_args(&["--set".into(), "OPEN=12".into(), "m.clash.json".into(), "--set=ROLL=90".into()]).unwrap();
        assert_eq!(a.manifest, PathBuf::from("m.clash.json"));
        assert_eq!(a.sets, ["OPEN=12", "ROLL=90"]);
        assert!(!a.reuse);
        assert!(parse_args(&["m.clash.json".into(), "--set".into()]).is_err());
        assert!(parse_args(&["m.clash.json".into(), "--set=OPEN".into()]).is_err());
        assert!(parse_args(&["m.clash.json".into(), "--bogus".into()]).is_err());
        assert!(parse_args(&["a.clash.json".into(), "b.clash.json".into()]).is_err());
    }

    #[test]
    fn each_pose_has_its_own_mesh_dir() {
        assert_eq!(mesh_dir(&[]), MESH_DIR);
        assert_eq!(mesh_dir(&["OPEN=12".into()]), format!("{MESH_DIR}/OPEN_12"));
        assert_eq!(mesh_dir(&["OPEN=-2.5".into(), "ROLL=90".into()]), format!("{MESH_DIR}/OPEN_-2.5_ROLL_90"));
    }

    #[test]
    fn sets_become_defines_before_the_source() {
        let a = export_args("asm.scad", "gear", "out/clash/gear.stl", &["OPEN=12".into()]);
        assert_eq!(a.last().unwrap(), "asm.scad");
        assert!(a.windows(2).any(|w| w == ["-D", "part=\"gear\""]));
        assert!(a.windows(2).any(|w| w == ["-D", "OPEN=12"]));
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
        let c = clash_args("m.json", MESH_DIR, (0.15, 0.05, 0.5), &["--spacing=0.1".to_string()]);
        assert_eq!(c[..4], ["clash", "m.json", "--mesh-dir", MESH_DIR]);
        assert!(c.windows(2).any(|w| w == ["--run", "0.5"]));
        assert_eq!(c.last().unwrap(), "--spacing=0.1");
    }
}
