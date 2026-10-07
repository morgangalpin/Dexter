//! The job graph: the jobs a run holds, the order they depend on one another
//! in, and the validation that rejects a graph that cannot be scheduled.
//! The rules are those of `specs/009.3-Render-Program.md`.

use anyhow::{bail, Result};
use std::collections::HashMap;

/// One unit of work. `id` is qualified by its group (`group/check`), `after`
/// holds the qualified ids that must pass first, `weight` is the number of
/// worker slots it holds while running, and `writes` the output paths it owns.
#[derive(Debug, Clone, PartialEq)]
pub struct Job {
    pub id: String,
    pub after: Vec<String>,
    pub weight: usize,
    pub writes: Vec<String>,
}

impl Job {
    pub fn new(id: &str) -> Job {
        Job { id: id.into(), after: vec![], weight: 1, writes: vec![] }
    }
}

/// A validated set of jobs with its dependencies resolved to indices.
#[derive(Debug)]
pub struct Graph {
    pub jobs: Vec<Job>,
    pub deps: Vec<Vec<usize>>,
}

impl Graph {
    /// Validate `jobs` and resolve their dependencies. Fails, before any job
    /// can run, on a repeated id, an unknown `after` target, two jobs writing
    /// one path, a zero weight, or a cycle.
    pub fn new(jobs: Vec<Job>) -> Result<Graph> {
        let index = index_of(&jobs)?;
        check_writes(&jobs)?;
        let deps = resolve(&jobs, &index)?;
        check_acyclic(&jobs, &deps)?;
        Ok(Graph { jobs, deps })
    }
}

fn index_of(jobs: &[Job]) -> Result<HashMap<&str, usize>> {
    let mut index = HashMap::new();
    for (i, j) in jobs.iter().enumerate() {
        if j.weight == 0 {
            bail!("{}: weight must be at least 1", j.id);
        }
        if index.insert(j.id.as_str(), i).is_some() {
            bail!("duplicate job id {}", j.id);
        }
    }
    Ok(index)
}

fn check_writes(jobs: &[Job]) -> Result<()> {
    let mut owner: HashMap<&str, &str> = HashMap::new();
    for j in jobs {
        for w in &j.writes {
            if let Some(first) = owner.insert(w, &j.id) {
                bail!("{w} is written by both {first} and {}", j.id);
            }
        }
    }
    Ok(())
}

fn resolve(jobs: &[Job], index: &HashMap<&str, usize>) -> Result<Vec<Vec<usize>>> {
    jobs.iter()
        .map(|j| {
            j.after
                .iter()
                .map(|a| match index.get(a.as_str()) {
                    Some(&i) => Ok(i),
                    None => bail!("{} runs after {a}, which is not a job", j.id),
                })
                .collect()
        })
        .collect()
}

/// Depth-first search with three colours; a grey node reached again is a cycle.
fn check_acyclic(jobs: &[Job], deps: &[Vec<usize>]) -> Result<()> {
    let mut colour = vec![0u8; jobs.len()];
    for i in 0..jobs.len() {
        visit(i, jobs, deps, &mut colour)?;
    }
    Ok(())
}

fn visit(i: usize, jobs: &[Job], deps: &[Vec<usize>], colour: &mut [u8]) -> Result<()> {
    match colour[i] {
        2 => return Ok(()),
        1 => bail!("dependency cycle through {}", jobs[i].id),
        _ => colour[i] = 1,
    }
    for &d in &deps[i] {
        visit(d, jobs, deps, colour)?;
    }
    colour[i] = 2;
    Ok(())
}

/// The ids of `target` and every job it depends on, in plan order. Used by
/// `--only`. Fails when `target` is not a job.
pub fn closure(graph: &Graph, target: &str) -> Result<Vec<String>> {
    let Some(start) = graph.jobs.iter().position(|j| j.id == target) else {
        bail!("{target} is not a job");
    };
    let mut keep = vec![false; graph.jobs.len()];
    let mut stack = vec![start];
    while let Some(i) = stack.pop() {
        if !std::mem::replace(&mut keep[i], true) {
            stack.extend(&graph.deps[i]);
        }
    }
    Ok(graph.jobs.iter().zip(keep).filter(|(_, k)| *k).map(|(j, _)| j.id.clone()).collect())
}

#[cfg(test)]
mod tests {
    use super::*;

    fn job(id: &str, after: &[&str]) -> Job {
        Job { after: after.iter().map(|s| s.to_string()).collect(), ..Job::new(id) }
    }

    #[test]
    fn resolves_dependencies_to_indices() {
        let g = Graph::new(vec![job("a", &[]), job("b", &["a"]), job("c", &["a", "b"])]).unwrap();
        assert_eq!(g.deps, vec![vec![], vec![0], vec![0, 1]]);
    }

    #[test]
    fn rejects_a_repeated_id() {
        let e = Graph::new(vec![job("a", &[]), job("a", &[])]).unwrap_err();
        assert!(e.to_string().contains("duplicate job id a"));
    }

    #[test]
    fn rejects_an_unknown_target() {
        let e = Graph::new(vec![job("a", &["ghost"])]).unwrap_err();
        assert!(e.to_string().contains("ghost"));
    }

    #[test]
    fn rejects_a_zero_weight() {
        let e = Graph::new(vec![Job { weight: 0, ..Job::new("a") }]).unwrap_err();
        assert!(e.to_string().contains("weight"));
    }

    #[test]
    fn rejects_two_writers_of_one_path() {
        let w = |id: &str| Job { writes: vec!["out/x.stl".into()], ..Job::new(id) };
        let e = Graph::new(vec![w("a"), w("b")]).unwrap_err();
        assert!(e.to_string().contains("out/x.stl is written by both a and b"));
    }

    #[test]
    fn rejects_a_cycle() {
        let e = Graph::new(vec![job("a", &["b"]), job("b", &["a"])]).unwrap_err();
        assert!(e.to_string().contains("cycle"));
    }

    #[test]
    fn rejects_a_self_dependency() {
        assert!(Graph::new(vec![job("a", &["a"])]).is_err());
    }

    #[test]
    fn accepts_a_diamond() {
        let jobs = vec![job("a", &[]), job("b", &["a"]), job("c", &["a"]), job("d", &["b", "c"])];
        assert!(Graph::new(jobs).is_ok());
    }

    #[test]
    fn closure_keeps_the_target_and_its_ancestors_in_order() {
        let g = Graph::new(vec![job("a", &[]), job("x", &[]), job("b", &["a"]), job("c", &["b"])]).unwrap();
        assert_eq!(closure(&g, "c").unwrap(), vec!["a", "b", "c"]);
        assert_eq!(closure(&g, "a").unwrap(), vec!["a"]);
    }

    #[test]
    fn closure_rejects_an_unknown_target() {
        let g = Graph::new(vec![job("a", &[])]).unwrap();
        assert!(closure(&g, "zzz").is_err());
    }
}
