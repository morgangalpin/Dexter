//! `probes`: points that must be material or void in a render, as
//! `scadmesh solid` reports them.
//!
//! Fields: `part` (the label prefix), `stl`, and `items`, a list of
//! `{label, at, solid}` where `solid` is true for material and false for void.

use super::fits::solid;
use super::{Env, Fields, Report};
use anyhow::Result;

pub fn run(env: &Env, f: &Fields, rep: &mut Report) -> Result<()> {
    let items = f.items("items")?;
    let points = items.iter().map(|i| i.point("at")).collect::<Result<Vec<_>>>()?;
    let inside = solid(env, f.str("stl")?, &points)?;
    for (item, got) in items.iter().zip(inside) {
        let want = item.v_bool("solid")?;
        rep.record(&format!("{} {}", f.str("part")?, item.str("label")?), got == want);
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use crate::kinds::testing::*;
    use serde_json::json;

    fn fields() -> serde_json::Value {
        json!({"part": "630-006 (revised)", "stl": "out/a.stl", "items": [
            {"label": "land", "at": [1, 2, 3], "solid": true},
            {"label": "nut trap", "at": [4, 5, 6], "solid": false}]})
    }

    fn fake(inside: [bool; 2]) -> Fake {
        Fake::new().with("solid", json!({"probes": [{"inside": inside[0]}, {"inside": inside[1]}]}))
    }

    #[test]
    fn material_and_void_are_each_judged() {
        let f = fake([true, false]);
        let o = check("probes", fields(), &f);
        assert!(o.ok && o.output.contains("630-006 (revised) nut trap"), "{}", o.output);
        assert_eq!(f.calls(), vec!["scadmesh solid out/a.stl --probe=1,2,3 --probe=4,5,6"]);
        assert_eq!(check("probes", fields(), &fake([true, true])).output.matches("FAIL").count(), 1);
        assert!(!check("probes", fields(), &fake([false, false])).ok);
    }
}
