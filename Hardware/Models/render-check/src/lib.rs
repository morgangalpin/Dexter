//! Shared machinery for the per-group `render-all.rs` scripts and the
//! scripts that render beside them: finding OpenSCAD and `scadmesh`, running
//! them, reading a group's part list, holding a render to silence, and
//! tallying the verdicts. Each group's script owns its own checks and calls
//! into this crate for everything else, through a path dependency:
//!
//! ```text
//! //! ```cargo
//! //! [dependencies]
//! //! render-check = { path = "../render-check" }
//! //! ```
//! ```

pub mod cli;
pub mod config;
pub mod kinds;
pub mod meshes;
pub mod plan;
pub mod program;
pub mod sched;

use anyhow::{bail, Context, Result};
use serde_json::Value;
use std::path::{Path, PathBuf};
use std::process::Command;

/// Absolute paths tried for OpenSCAD before falling back to `$PATH`.
///
/// `openscad.exe` is deliberate on Windows, and the choice is not obvious.
/// That binary is built for the GUI subsystem, so run from an interactive
/// console it attaches to no terminal and appears to print nothing — which is
/// why the install also ships `openscad.com`, a wrapper that republishes
/// everything on stdout. The wrapper is the wrong tool here: the checks read
/// stdout and stderr apart, and the diagnostics they need are the stderr ones.
/// Redirected to a pipe, as `Command::output` does, `openscad.exe` writes
/// them there correctly. Use `openscad.com` when reading by eye, `.exe` when
/// reading by program.
const OPENSCAD_CANDIDATES: [&str; 3] = [
    "C:/Program Files/OpenSCAD/openscad.exe",
    "/usr/bin/openscad",
    "/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD",
];

/// Paths tried for `scadmesh`, relative to this crate: the standalone
/// `openscad-tools` project checked out beside this repository's parent.
/// Falls back to `$PATH`, or set `$SCADMESH`.
const SCADMESH_CANDIDATES: [&str; 2] = [
    "../../../../../openscad-tools/target/release/scadmesh.exe",
    "../../../../../openscad-tools/target/release/scadmesh",
];

/// Resolve a tool: `$env_key` wins, then the first existing candidate
/// (resolved relative to `dir`), then the bare name via `$PATH`.
pub fn tool(env_key: &str, candidates: &[&str], name: &str, dir: &Path) -> String {
    if let Ok(v) = std::env::var(env_key) {
        return v;
    }
    candidates
        .iter()
        .map(|c| dir.join(c))
        .find(|p| p.exists())
        .map_or_else(|| name.to_string(), |p| p.to_string_lossy().into_owned())
}

/// Where the tools run and which binaries they are.
pub struct Ctx {
    pub dir: PathBuf,
    pub openscad: String,
    pub scadmesh: String,
}

impl Ctx {
    /// A context for the group directory `dir`, with `out/` created in it.
    pub fn new(dir: PathBuf) -> Result<Ctx> {
        std::fs::create_dir_all(dir.join("out"))?;
        let here = Path::new(env!("CARGO_MANIFEST_DIR"));
        Ok(Ctx {
            openscad: tool("OPENSCAD", &OPENSCAD_CANDIDATES, "openscad", here),
            scadmesh: tool("SCADMESH", &SCADMESH_CANDIDATES, "scadmesh", here),
            dir,
        })
    }

    /// The context for the script rust-script is running.
    pub fn for_script() -> Result<Ctx> {
        let base = std::env::var("RUST_SCRIPT_BASE_PATH")
            .context("RUST_SCRIPT_BASE_PATH unset - run this file as a rust-script")?;
        Ctx::new(PathBuf::from(base))
    }
}
/// The `(id, scad)` pairs of the parts the group's `render.json` lists for
/// `config`, in render order. The schema is owned by
/// `specs/009.3-Render-Program.md`.
pub fn group_parts(ctx: &Ctx, config: &str) -> Result<Vec<(String, String)>> {
    let cfg = config::load(&ctx.dir)?;
    Ok(cfg.parts_for(config).into_iter().map(|p| (p.id.clone(), p.scad.clone())).collect())
}

/// A finished tool run. Both streams are kept: `scadmesh` reports on stdout,
/// OpenSCAD diagnoses on stderr, and neither can stand in for the other.
pub struct Run {
    pub ok: bool,
    pub stdout: String,
    pub stderr: String,
}

pub fn run(exe: &str, args: &[&str], dir: &Path) -> Result<Run> {
    let out = Command::new(exe)
        .args(args)
        .current_dir(dir)
        .output()
        .with_context(|| format!("running {exe} - set $OPENSCAD / $SCADMESH if it is not on PATH"))?;
    Ok(Run {
        ok: out.status.success(),
        stdout: String::from_utf8_lossy(&out.stdout).into_owned(),
        stderr: String::from_utf8_lossy(&out.stderr).into_owned(),
    })
}

/// The lines on OpenSCAD's stderr that mean the mesh cannot be trusted,
/// picked out of the cache and timing chatter that surrounds them.
///
/// The exit status cannot do this job. OpenSCAD exits 0 for `ERROR: The given
/// mesh is not closed! Unable to convert to CGAL_Nef_Polyhedron`, which is the
/// one diagnostic that most directly invalidates an export, and 0 again for
/// every `WARNING:`. It exits 1 only when the top level object comes out
/// empty or a script-level assertion fails. So a render that quietly dropped a
/// subtree, or silently ignored a misspelled variable, would reach the
/// measurements as if nothing had happened.
///
/// `Simple: no` is caught as well as the explicit complaints. It sits in the
/// summary block rather than in a warning, and it is how a self-intersecting
/// or non-manifold export announces itself while OpenSCAD exits 0 and writes
/// the file. A `.csg` export evaluates no geometry and prints no such block.
///
/// Nothing here is filtered as benign: the point of the check is to notice
/// the first part that stops rendering clean.
pub fn diagnostics(stderr: &str) -> Vec<&str> {
    const MARKERS: [&str; 4] = ["ERROR:", "WARNING:", "UI-WARNING:", "TRACE:"];
    stderr
        .lines()
        .map(str::trim)
        .filter(|line| {
            MARKERS.iter().any(|m| line.starts_with(m))
                || line.contains("not a simple polyhedron")
                || line.contains("top level object is empty")
                || line.contains("nonplanar faces")
                || (line.starts_with("Simple:") && line.ends_with("no"))
        })
        .collect()
}

/// Pass/fail bookkeeping for one script run.
#[derive(Default)]
pub struct Tally {
    pub failures: usize,
}

impl Tally {
    pub fn record(&mut self, label: &str, ok: bool) {
        println!("{}  {label}", if ok { "PASS" } else { "FAIL" });
        if !ok {
            self.failures += 1;
        }
    }

    /// The closing line a script prints, and the exit status it returns.
    pub fn verdict(&self) -> (String, i32) {
        match self.failures {
            0 => ("ALL CHECKS PASSED".into(), 0),
            n => (format!("{n} CHECK(S) FAILED"), 1),
        }
    }

    pub fn finish(&self) -> ! {
        let (line, code) = self.verdict();
        println!("\n{line}");
        std::process::exit(code);
    }
}

/// Hold a finished OpenSCAD run to exiting cleanly and rendering silently.
/// The tally entry is deliberately separate from the measurements that follow:
/// a part that warns and then measures well has not passed, it has measured a
/// mesh nobody should be measuring.
pub fn judge(r: &Run, what: &str, tally: &mut Tally) -> Result<()> {
    if !r.ok {
        bail!("OpenSCAD failed on {what}:\n{}", r.stderr.trim_end());
    }
    let complaints = diagnostics(&r.stderr);
    for line in &complaints {
        println!("      {line}");
    }
    tally.record(&format!("{what} renders without diagnostics"), complaints.is_empty());
    Ok(())
}

/// The OpenSCAD arguments that render `scad` to `out` with `-D` definitions,
/// and `extra` before the source.
fn render_args<'a>(scad: &'a str, out: &'a str, defines: &[&'a str], extra: &[&'a str]) -> Vec<&'a str> {
    let mut args = vec!["-o", out];
    for d in defines {
        args.extend(["-D", d]);
    }
    args.extend(extra);
    args.push(scad);
    args
}

fn render_judged(scad: &str, args: &[&str], defines: &[&str], ctx: &Ctx, tally: &mut Tally) -> Result<Run> {
    let r = run(&ctx.openscad, args, &ctx.dir)?;
    judge(&r, &format!("{scad} ({})", defines.join(", ")), tally)?;
    Ok(r)
}

/// Render `scad` to `out` with `-D` definitions, and judge the run.
pub fn render_with(scad: &str, out: &str, defines: &[&str], ctx: &Ctx, tally: &mut Tally) -> Result<Run> {
    render_judged(scad, &render_args(scad, out, defines, &[]), defines, ctx, tally)
}

/// As `render_with`, but to a binary STL. OpenSCAD's ASCII export rounds to
/// six significant digits, which can leave a section plane cutting a mesh
/// whose neighbouring facets no longer quite meet, so `slice` returns open
/// polylines; a section taken for its area wants the float32 export.
pub fn render_binary(scad: &str, out: &str, defines: &[&str], ctx: &Ctx, tally: &mut Tally) -> Result<Run> {
    render_judged(scad, &render_args(scad, out, defines, &["--export-format", "binstl"]), defines, ctx, tally)
}

/// Render one configuration of one part.
pub fn render(scad: &str, out: &str, config: &str, ctx: &Ctx, tally: &mut Tally) -> Result<Run> {
    render_with(scad, out, &[&format!("config=\"{config}\"")], ctx, tally)
}

/// Run `scadmesh <args> --json` and parse its report.
pub fn sm_json(args: &[&str], ctx: &Ctx) -> Result<(bool, Value)> {
    let mut full: Vec<&str> = args.to_vec();
    full.push("--json");
    let r = run(&ctx.scadmesh, &full, &ctx.dir)?;
    let json = serde_json::from_str(&r.stdout).with_context(|| format!("parsing scadmesh output for {args:?}"))?;
    Ok((r.ok, json))
}

/// A part reproduced closely enough to be gated on two-sided surface
/// distance. `tol` is the Hausdorff limit in mm; the render must sit inside
/// it in both directions, with no sampled point over.
pub struct DistGate {
    pub stem: &'static str,
    pub scad: &'static str,
    pub reference: &'static str,
    pub tol: f64,
}

/// Render the gate's part faithfully to `out/<stem>.stl` and measure its
/// surface against `ref_dir/<reference>`.
pub fn dist_gate(gate: &DistGate, ref_dir: &str, ctx: &Ctx, tally: &mut Tally) -> Result<()> {
    let out = format!("out/{}.stl", gate.stem);
    render(gate.scad, &out, "previous", ctx, tally)?;
    let tol = gate.tol.to_string();
    let reference = format!("{ref_dir}/{}", gate.reference);
    let (ok, report) = sm_json(&["dist", &out, &reference, "--tol", &tol], ctx)?;
    let worst = report["hausdorff"].as_f64().unwrap_or(f64::NAN);
    tally.record(
        &format!("{} surface vs reference (hausdorff {worst:.3} mm, tol {tol} mm)", gate.stem),
        ok,
    );
    Ok(())
}

/// Read `ECHO: "<prefix><value>"` or `ECHO: <name> = <value>` off OpenSCAD's
/// stderr: the text after `tag` on the first line carrying it, with any
/// closing quote removed.
pub fn echoed<'a>(stderr: &'a str, tag: &str) -> Option<&'a str> {
    stderr.lines().find_map(|l| {
        let rest = l.trim().strip_prefix("ECHO: ")?;
        let rest = rest.strip_prefix('"').unwrap_or(rest);
        Some(rest.strip_prefix(tag)?.trim_end_matches('"'))
    })
}

/// Probe points with `scadmesh solid`, returning inside/outside per point.
pub fn probe(stl: &str, points: &[[f64; 3]], ctx: &Ctx) -> Result<Vec<bool>> {
    let args: Vec<String> = points
        .iter()
        .map(|p| format!("--probe={},{},{}", p[0], p[1], p[2]))
        .collect();
    let mut full = vec!["solid", stl];
    full.extend(args.iter().map(String::as_str));
    let (_, json) = sm_json(&full, ctx)?;
    let probes = json["probes"].as_array().context("scadmesh solid emitted no probes")?;
    Ok(probes.iter().map(|p| p["inside"].as_bool().unwrap_or(false)).collect())
}

/// How an assembly clash render came out. OpenSCAD reports an empty
/// intersection by refusing to export it; a seat, where two parts share a
/// face, exports a surface with no volume. Both are clear. A CGAL failure
/// returns one operand as the result, so its output says nothing about the
/// pair, and the check fails rather than measure it.
#[derive(Debug, PartialEq)]
pub enum Clash {
    Clear,
    Overlap(f64),
    Unjudged,
}

/// Overlap below this, in mm³, is contact rather than interference.
pub const CLASH_TOL: f64 = 1e-3;

/// Judge a clash render from its stderr, and the exported volume when there
/// was one.
pub fn clash_verdict(stderr: &str, volume: Option<f64>) -> Clash {
    if stderr.contains("CGAL error") || stderr.contains("not closed") {
        return Clash::Unjudged;
    }
    match volume {
        None if stderr.contains("top level object is empty") => Clash::Clear,
        None => Clash::Unjudged,
        Some(v) if v.abs() < CLASH_TOL => Clash::Clear,
        Some(v) => Clash::Overlap(v.abs()),
    }
}

/// Render the intersection of parts `a` and `b` of an assembly that takes a
/// two-name `clash` list, and record whether they are clear of each other.
pub fn clash_free(scad: &str, a: &str, b: &str, ctx: &Ctx, tally: &mut Tally) -> Result<()> {
    let out = format!("out/clash-{a}-{b}.stl");
    let _ = std::fs::remove_file(ctx.dir.join(&out));
    let define = format!("clash=[\"{a}\",\"{b}\"]");
    let r = run(&ctx.openscad, &["-o", &out, "-D", &define, scad], &ctx.dir)?;
    let volume = if ctx.dir.join(&out).exists() {
        let (_, info) = sm_json(&["info", &out], ctx)?;
        info[0]["volume_mm3"].as_f64()
    } else {
        None
    };
    let (label, ok) = match clash_verdict(&r.stderr, volume) {
        Clash::Clear => (format!("{a} clear of {b}"), true),
        Clash::Overlap(v) => (format!("{a} clear of {b} (overlap {v:.3} mm3)"), false),
        Clash::Unjudged => (format!("{a} clear of {b} (OpenSCAD could not intersect them)"), false),
    };
    tally.record(&label, ok);
    Ok(())
}

/// C-201's circular spline hole pattern, 6 on Ø44 from 30 deg (007.1 C-201).
/// Stated here rather than read from the seat library, so the probes check
/// that library instead of repeating it.
pub const SPLINE_HOLES: (f64, f64, usize) = (22.0, 30.0, 6);
/// The retired pattern: pegs on Ø43 at 0/90/180/270, screw holes at 45 deg.
pub const OLD_PEGS_R: f64 = 21.5;

/// A point the seat must leave as material (`true`) or void.
pub struct SeatProbe {
    pub label: String,
    pub at: [f64; 3],
    pub solid: bool,
}

/// The probes that say a holder seats C-201: `floor` is the floor's height in
/// the part's frame and `facing` is +1 when the recess opens toward +Z, -1
/// toward -Z. Depths are below the floor, into the part.
pub fn seat_probe_points(floor: f64, facing: f64) -> Vec<SeatProbe> {
    let z = |depth: f64| floor - facing * depth;
    let polar = |r: f64, deg: f64, depth: f64| {
        let a = deg.to_radians();
        [r * a.cos(), r * a.sin(), z(depth)]
    };
    let mut p = vec![
        SeatProbe { label: "floor, material under it".into(), at: polar(23.0, 0.0, 0.1), solid: true },
        SeatProbe { label: "floor, void over it".into(), at: polar(23.0, 0.0, -0.1), solid: false },
        SeatProbe { label: "pilot, void in it".into(), at: polar(18.5, 0.0, 2.1), solid: false },
        SeatProbe { label: "pilot floor, material under it".into(), at: polar(18.5, 0.0, 2.3), solid: true },
        SeatProbe { label: "old peg, gone".into(), at: polar(OLD_PEGS_R, 0.0, -2.0), solid: false },
        SeatProbe { label: "old peg bore, filled".into(), at: polar(OLD_PEGS_R, 0.0, 1.0), solid: true },
        SeatProbe { label: "old screw hole, filled".into(), at: polar(OLD_PEGS_R, 45.0, 1.0), solid: true },
    ];
    let (r, first, n) = SPLINE_HOLES;
    for i in 0..n {
        let deg = first + 360.0 / n as f64 * i as f64;
        p.push(SeatProbe { label: format!("hole at {deg} deg, clearance"), at: polar(r, deg, 1.0), solid: false });
        p.push(SeatProbe { label: format!("hole at {deg} deg, nut pocket"), at: polar(r, deg, 3.0), solid: false });
        p.push(SeatProbe { label: format!("hole at {deg} deg, pocket wall"), at: polar(r + 3.0, deg, 3.0), solid: true });
    }
    p
}

/// The seat's print fits, from the drawing's nominals: the flange's Ø50h6 in
/// the recess, the step's Ø38h7 in the pilot, and the M3 nut's outer flat in
/// the pocket on the hole at 30 deg.
pub fn seat_fit_probes(floor: f64, facing: f64) -> Vec<FitProbe> {
    let z = |depth: f64| floor - facing * depth;
    let (c30, s30) = (30f64.to_radians().cos(), 30f64.to_radians().sin());
    let flat = SPLINE_HOLES.0 + 5.5 / 2.0;
    vec![
        FitProbe { label: "recess on the flange", at: [25.0, 0.0, z(-1.5)], toward: [-1.0, 0.0, 0.0], fit: Fit::Press },
        FitProbe { label: "pilot on the step", at: [19.0, 0.0, z(1.1)], toward: [-1.0, 0.0, 0.0], fit: Fit::Press },
        FitProbe { label: "M3 nut pocket", at: [flat * c30, flat * s30, z(3.5)], toward: [-c30, -s30, 0.0], fit: Fit::Slip },
    ]
}

/// Render a Stator Holder's revised config to `out/revised/<stem>.stl` and
/// probe C-201's seat, and its fits, at the floor the part echoes as
/// `seat_floor`.
pub fn check_seat(scad: &str, stem: &str, facing: f64, ctx: &Ctx, tally: &mut Tally) -> Result<()> {
    std::fs::create_dir_all(ctx.dir.join("out/revised"))?;
    let stl = format!("out/revised/{stem}.stl");
    let r = render(scad, &stl, "revised", ctx, tally)?;
    let floor: f64 = echoed(&r.stderr, "seat_floor = ").context("seat_floor not echoed")?.parse()?;
    let probes = seat_probe_points(floor, facing);
    let points: Vec<[f64; 3]> = probes.iter().map(|p| p.at).collect();
    for (p, inside) in probes.iter().zip(probe(&stl, &points, ctx)?) {
        tally.record(&format!("{stem} (revised) seat: {}", p.label), inside == p.solid);
    }
    check_fits(&stl, &format!("{stem} (revised) seat"), &seat_fit_probes(floor, facing), ctx, tally)
}

/// A print-fit class of `../print_fit.scad`.
#[derive(Clone, Copy, Debug, PartialEq)]
pub enum Fit {
    Slip,
    Press,
}

/// A value assigned in an OpenSCAD source as `NAME = value;`.
pub fn scad_constant(source: &str, name: &str) -> Option<f64> {
    source.lines().find_map(|line| {
        let (lhs, rhs) = line.split_once('=')?;
        if lhs.trim() != name {
            return None;
        }
        rhs.split(';').next()?.trim().parse().ok()
    })
}

/// The two print-fit clearances per side, read from the library every part
/// includes, so the checks follow it when a machine is qualified.
pub fn print_fit(ctx: &Ctx) -> Result<(f64, f64)> {
    let path = ctx.dir.join("../print_fit.scad");
    let source = std::fs::read_to_string(&path).with_context(|| format!("reading {}", path.display()))?;
    let get = |name| scad_constant(&source, name).with_context(|| format!("{name} not in print_fit.scad"));
    Ok((get("FIT_SLIP")?, get("FIT_PRESS")?))
}

/// One fit on a revised render: `at` lies on the mate's nominal surface and
/// `toward` is the unit direction from the part toward the mate. The part's
/// wall must stand back from `at` by the class clearance, so a point halfway
/// into that gap is void and one just behind the wall is material.
pub struct FitProbe {
    pub label: &'static str,
    pub at: [f64; 3],
    pub toward: [f64; 3],
    pub fit: Fit,
}

/// How far behind the drawn wall the material probe sits.
const FIT_WALL_PROBE: f64 = 0.05;

/// The gap and wall points of a probe at clearance `c`.
pub fn fit_points(p: &FitProbe, c: f64) -> ([f64; 3], [f64; 3]) {
    let back = |d: f64| [p.at[0] - p.toward[0] * d, p.at[1] - p.toward[1] * d, p.at[2] - p.toward[2] * d];
    (back(c / 2.0), back(c + FIT_WALL_PROBE))
}

/// Check every fit of a revised render against the class clearances.
pub fn check_fits(stl: &str, part: &str, probes: &[FitProbe], ctx: &Ctx, tally: &mut Tally) -> Result<()> {
    let (slip, press) = print_fit(ctx)?;
    let mut points = Vec::new();
    for p in probes {
        let c = if p.fit == Fit::Slip { slip } else { press };
        let (gap, wall) = fit_points(p, c);
        points.push(gap);
        points.push(wall);
    }
    let inside = probe(stl, &points, ctx)?;
    for (p, pair) in probes.iter().zip(inside.chunks(2)) {
        let class = if p.fit == Fit::Slip { "slip" } else { "press" };
        tally.record(&format!("{part} fit, {} ({class}): gap open, wall behind it", p.label), !pair[0] && pair[1]);
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn scad_constant_reads_an_assignment_and_ignores_the_rest() {
        let src = "// FIT_SLIP = 9;\nFIT_SLIP    = 0.15;\nFIT_PRESS = 0.05; // per side\nfunction f() = 1;";
        assert_eq!(scad_constant(src, "FIT_SLIP"), Some(0.15));
        assert_eq!(scad_constant(src, "FIT_PRESS"), Some(0.05));
        assert_eq!(scad_constant(src, "MISSING"), None);
    }

    #[test]
    fn group_parts_reads_the_config_beside_the_script() {
        let dir = std::env::temp_dir().join(format!("render-check-parts-{}", std::process::id()));
        let ctx = Ctx::new(dir.clone()).unwrap();
        assert!(group_parts(&ctx, "revised").is_err());
        let text = r#"{"parts": [{"id": "a", "scad": "a.scad"}, {"id": "b", "scad": "b.scad", "configs": ["revised"]}]}"#;
        std::fs::write(dir.join(config::CONFIG_FILE), text).unwrap();
        assert_eq!(group_parts(&ctx, "revised").unwrap().len(), 2);
        assert_eq!(group_parts(&ctx, "previous").unwrap(), [("a".to_string(), "a.scad".to_string())]);
        std::fs::remove_dir_all(dir).unwrap();
    }

    #[test]
    fn render_args_put_definitions_and_extras_before_the_source() {
        let args = render_args("p.scad", "o.stl", &["a=1", "b=2"], &["--export-format", "binstl"]);
        assert_eq!(args, vec!["-o", "o.stl", "-D", "a=1", "-D", "b=2", "--export-format", "binstl", "p.scad"]);
        assert_eq!(render_args("p.scad", "o.stl", &[], &[]), vec!["-o", "o.stl", "p.scad"]);
    }

    #[test]
    fn seat_fits_run_into_the_part_from_either_facing() {
        let up = seat_fit_probes(5.0, 1.0);
        let down = seat_fit_probes(11.0, -1.0);
        assert_eq!(up.len(), 3);
        assert!((up[0].at[2] - 6.5).abs() < 1e-9 && (down[0].at[2] - 9.5).abs() < 1e-9);
        assert!((up[1].at[2] - 3.9).abs() < 1e-9 && (down[1].at[2] - 12.1).abs() < 1e-9);
        let r = (up[2].at[0].powi(2) + up[2].at[1].powi(2)).sqrt();
        assert!((r - 24.75).abs() < 1e-9);
    }

    #[test]
    fn fit_points_stand_back_from_the_mate() {
        let p = FitProbe { label: "bore", at: [5.0, 0.0, 1.0], toward: [-1.0, 0.0, 0.0], fit: Fit::Slip };
        let (gap, wall) = fit_points(&p, 0.2);
        assert!((gap[0] - 5.1).abs() < 1e-12 && (wall[0] - 5.25).abs() < 1e-12);
        assert_eq!((gap[2], wall[2]), (1.0, 1.0));
    }

    #[test]
    fn clash_verdict_tells_contact_from_overlap_and_failure() {
        assert_eq!(clash_verdict("Current top level object is empty.", None), Clash::Clear);
        assert_eq!(clash_verdict("Simple: no", Some(-4.7e-11)), Clash::Clear);
        assert_eq!(clash_verdict("Simple: yes", Some(-2.5)), Clash::Overlap(2.5));
        assert_eq!(clash_verdict("ERROR: CGAL error in CGALUtils", Some(40.0)), Clash::Unjudged);
        assert_eq!(clash_verdict("ERROR: The given mesh is not closed!", None), Clash::Unjudged);
        assert_eq!(clash_verdict("ERROR: something else", None), Clash::Unjudged);
    }

    #[test]
    fn seat_probes_run_into_the_part_from_either_facing() {
        let up = seat_probe_points(5.0, 1.0);
        let down = seat_probe_points(11.0, -1.0);
        assert_eq!(up.len(), 7 + 18);
        let pilot = |p: &[SeatProbe]| p.iter().find(|s| s.label.starts_with("pilot floor")).unwrap().at[2];
        assert!((pilot(&up) - 2.7).abs() < 1e-9);
        assert!((pilot(&down) - 13.3).abs() < 1e-9);
        let hole = up.iter().find(|s| s.label == "hole at 90 deg, clearance").unwrap();
        assert!(hole.at[0].abs() < 1e-9 && (hole.at[1] - 22.0).abs() < 1e-9 && !hole.solid);
    }

    #[test]
    fn diagnostics_keeps_complaints_and_drops_chatter() {
        let err = "Compiling design\nWARNING: x\nECHO: 1\n  ERROR: y\nSimple: no\nSimple: yes\n\
                   Volumes: 2\nCurrent top level object is empty.\nTRACE: z";
        assert_eq!(
            diagnostics(err),
            vec!["WARNING: x", "ERROR: y", "Simple: no", "Current top level object is empty.", "TRACE: z"]
        );
        assert!(diagnostics("Rendering Polygon Mesh using CGAL...\nSimple: yes").is_empty());
    }

    #[test]
    fn tally_counts_failures_and_gives_the_verdict() {
        let mut t = Tally::default();
        t.record("a", true);
        assert_eq!(t.verdict(), ("ALL CHECKS PASSED".into(), 0));
        t.record("b", false);
        t.record("c", false);
        assert_eq!(t.verdict(), ("2 CHECK(S) FAILED".into(), 1));
    }

    #[test]
    fn tool_prefers_env_then_candidate_then_name() {
        let dir = Path::new(env!("CARGO_MANIFEST_DIR"));
        assert_eq!(tool("RENDER_CHECK_UNSET_VAR", &["nope"], "bare", dir), "bare");
        let found = tool("RENDER_CHECK_UNSET_VAR", &["nope", "Cargo.toml"], "bare", dir);
        assert!(found.ends_with("Cargo.toml"));
        std::env::set_var("RENDER_CHECK_SET_VAR", "from-env");
        assert_eq!(tool("RENDER_CHECK_SET_VAR", &["Cargo.toml"], "bare", dir), "from-env");
    }

    #[test]
    fn echoed_reads_both_echo_forms() {
        let err = "ECHO: \"J3 Attach: -D hub_drop=0.687\"\nECHO: body_box = [[0, 0], [1, 1]]\n";
        assert_eq!(echoed(err, "J3 Attach: -D hub_drop="), Some("0.687"));
        assert_eq!(echoed(err, "body_box = "), Some("[[0, 0], [1, 1]]"));
        assert_eq!(echoed(err, "missing"), None);
    }

    #[test]
    fn judge_fails_hard_on_exit_and_softly_on_warnings() {
        let mut t = Tally::default();
        let bad = Run { ok: false, stdout: String::new(), stderr: "ERROR: assert".into() };
        assert!(judge(&bad, "p", &mut t).is_err());
        let noisy = Run { ok: true, stdout: String::new(), stderr: "WARNING: w".into() };
        judge(&noisy, "p", &mut t).unwrap();
        let clean = Run { ok: true, stdout: String::new(), stderr: "Volumes: 2".into() };
        judge(&clean, "p", &mut t).unwrap();
        assert_eq!(t.failures, 1);
    }

    #[test]
    fn run_reports_a_missing_binary_as_an_error() {
        assert!(run("render-check-no-such-binary", &[], Path::new(".")).is_err());
    }

    #[test]
    fn ctx_new_creates_out_and_finds_tools() {
        let dir = std::env::temp_dir().join("render-check-ctx-test");
        let ctx = Ctx::new(dir.clone()).unwrap();
        assert!(dir.join("out").is_dir());
        assert!(!ctx.openscad.is_empty() && !ctx.scadmesh.is_empty());
    }
}
