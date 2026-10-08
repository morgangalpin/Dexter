//! The command line of `render.rs`, whose options are owned by
//! `specs/009.3-Render-Program.md`.

use anyhow::{bail, Context, Result};

#[derive(Debug, Clone, PartialEq)]
pub struct Args {
    /// A group directory name, or `all`.
    pub target: String,
    pub meshes: bool,
    pub verify: bool,
    pub config: String,
    pub jobs: Option<usize>,
    pub only: Option<String>,
    pub fail_fast: bool,
}

pub const USAGE: &str = "usage: render.rs <group-dir | all> [--meshes] [--verify] [--config previous|revised] [--jobs N] [--only ID] [--fail-fast]";

fn value(it: &mut impl Iterator<Item = String>, flag: &str) -> Result<String> {
    it.next().with_context(|| format!("{flag} needs a value\n{USAGE}"))
}

fn positive(text: &str) -> Result<usize> {
    text.parse::<usize>().ok().filter(|&n| n > 0).with_context(|| format!("--jobs needs a positive integer, not {text}"))
}

/// Parse the arguments after the program name. With neither mode flag,
/// `--verify` is implied.
pub fn parse_args(args: impl IntoIterator<Item = String>) -> Result<Args> {
    let mut it = args.into_iter();
    let mut a = Args { target: String::new(), meshes: false, verify: false, config: "revised".into(), jobs: None, only: None, fail_fast: false };
    while let Some(arg) = it.next() {
        match arg.as_str() {
            "--meshes" => a.meshes = true,
            "--verify" => a.verify = true,
            "--fail-fast" => a.fail_fast = true,
            "--config" => a.config = value(&mut it, "--config")?,
            "--only" => a.only = Some(value(&mut it, "--only")?),
            "--jobs" => a.jobs = Some(positive(&value(&mut it, "--jobs")?)?),
            s if s.starts_with("--") => bail!("unknown option {s}\n{USAGE}"),
            s if a.target.is_empty() => a.target = s.trim_end_matches(['/', '\\']).to_owned(),
            s => bail!("unexpected argument {s}\n{USAGE}"),
        }
    }
    if a.target.is_empty() {
        bail!("no group given\n{USAGE}");
    }
    a.verify |= !a.meshes;
    Ok(a)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn parse(s: &str) -> Result<Args> {
        parse_args(s.split_whitespace().map(String::from))
    }

    #[test]
    fn defaults_to_verify_of_the_revised_configuration() {
        let a = parse("700-Differential").unwrap();
        assert_eq!((a.meshes, a.verify, a.config.as_str(), a.jobs, a.fail_fast), (false, true, "revised", None, false));
    }

    #[test]
    fn meshes_alone_does_not_imply_verify_but_both_may_be_given() {
        let a = parse("g --meshes").unwrap();
        assert!(a.meshes && !a.verify);
        let b = parse("g --meshes --verify").unwrap();
        assert!(b.meshes && b.verify);
    }

    #[test]
    fn reads_every_option_and_trims_a_trailing_slash() {
        let a = parse("700-Differential/ --config previous --jobs 4 --only mesh-710-001 --fail-fast").unwrap();
        assert_eq!(a.target, "700-Differential");
        assert_eq!((a.config.as_str(), a.jobs, a.only.as_deref(), a.fail_fast), ("previous", Some(4), Some("mesh-710-001"), true));
    }

    #[test]
    fn rejects_bad_command_lines() {
        let bad = |s: &str| parse(s).unwrap_err().to_string();
        assert!(bad("").contains("no group"));
        assert!(bad("g h").contains("unexpected argument h"));
        assert!(bad("g --nope").contains("unknown option"));
        assert!(bad("g --jobs").contains("needs a value"));
        assert!(bad("g --jobs 0").contains("positive integer"));
        assert!(bad("g --jobs x").contains("positive integer"));
    }
}
