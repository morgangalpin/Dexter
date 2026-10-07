//! `counts`: `scadmesh teeth` counts on the cross-section of rendered meshes.
//! Slice positions are in the render's own frame, which need not match the
//! reference's.
//!
//! Fields: `items`, a list of `{label, stl, args, key, expect}`. `args` are the
//! `teeth` flags after the mesh path. A negative value takes the joined form,
//! `--center=-21,21`, because in the spaced form clap reads `-2` as a flag.
//! `key` names the field of the report's `result` to compare with `expect`.

use super::{Env, Fields, Report};
use anyhow::Result;

pub fn run(env: &Env, f: &Fields, rep: &mut Report) -> Result<()> {
    f.items("items")?.iter().try_for_each(|item| one(env, item, rep))
}

fn one(env: &Env, item: &Fields, rep: &mut Report) -> Result<()> {
    let mut args = vec!["teeth", item.str("stl")?];
    args.extend(item.strings("args")?);
    let (_, json) = env.tools.scadmesh(&args)?;
    let got = json["result"][item.str("key")?].as_u64();
    rep.record(&format!("{} (got {got:?})", item.str("label")?), got == Some(item.u64("expect")?));
    Ok(())
}

#[cfg(test)]
mod tests {
    use crate::kinds::testing::*;
    use serde_json::json;

    fn items(expect: u64) -> serde_json::Value {
        json!({"items": [{"label": "40T", "stl": "out/a.stl", "args": ["--band", "1,2", "--center=-1,1"],
                          "key": "radius_peaks", "expect": expect}]})
    }

    #[test]
    fn passes_when_the_count_matches() {
        let fake = Fake::new().with("teeth", json!({"result": {"radius_peaks": 40}}));
        let o = check("counts", items(40), &fake);
        assert!(o.ok && o.output.contains("40T (got Some(40))"), "{}", o.output);
        assert_eq!(fake.calls(), vec!["scadmesh teeth out/a.stl --band 1,2 --center=-1,1"]);
    }

    #[test]
    fn fails_on_a_different_or_missing_count() {
        let fake = Fake::new().with("teeth", json!({"result": {"radius_peaks": 39}}));
        assert!(!check("counts", items(40), &fake).ok);
        assert!(!check("counts", items(40), &Fake::new()).ok);
    }

    #[test]
    fn every_item_is_judged() {
        let fake = Fake::new().with("teeth", json!({"result": {"radius_peaks": 1}}));
        let mut v = items(1);
        let first = v["items"][0].clone();
        v["items"].as_array_mut().unwrap().push(first);
        let o = check("counts", v, &fake);
        assert_eq!(o.output.matches("PASS").count(), 2);
    }
}
