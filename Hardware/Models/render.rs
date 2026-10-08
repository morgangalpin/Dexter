#!/bin/bash
//! 2>/dev/null; command -v rust-script >/dev/null 2>&1 || { echo "Error: Install rust-script with: cargo install rust-script" >&2; exit 1; }; exec rust-script "$0" "$@"
//! Render and verify the printed-part meshes of every group. Behaviour, options
//! and the `render.json` schema are owned by `specs/009.3-Render-Program.md`.
//!
//! ```cargo
//! [dependencies]
//! anyhow = "1"
//! render-check = { path = "render-check" }
//! ```

use render_check::{cli, program, Ctx};
use std::path::PathBuf;

fn main() -> anyhow::Result<()> {
    let args = cli::parse_args(std::env::args().skip(1))?;
    let models = PathBuf::from(std::env::var("RUST_SCRIPT_BASE_PATH")?);
    let workers = std::thread::available_parallelism().map_or(1, |n| n.get());
    let (text, code) = program::execute(&args, &models, workers, &|dir| Ok(Box::new(Ctx::new(dir.to_path_buf())?)))?;
    print!("{text}");
    std::process::exit(code);
}
