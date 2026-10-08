//! The scheduler: runs a validated [`Graph`] on a pool of workers, starting a
//! job once every job it runs after has passed and keeping the weight of the
//! running jobs within the worker limit. The rules are those of
//! `specs/009.3-Render-Program.md`.

use crate::plan::Graph;
use std::panic::{catch_unwind, AssertUnwindSafe};
use std::sync::{Condvar, Mutex, MutexGuard};

/// What a job runner reports: whether the job passed, and what it printed.
pub struct Outcome {
    pub ok: bool,
    pub output: String,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Status {
    Passed,
    Failed,
    /// Not run, because a dependency did not pass or the run was stopped.
    Skipped,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct JobResult {
    pub id: String,
    pub status: Status,
    pub output: String,
}

#[derive(Clone, Copy, PartialEq, Eq)]
enum Slot {
    Pending,
    Running,
    Done(Status),
}

struct State {
    slots: Vec<Slot>,
    outputs: Vec<String>,
    used: usize,
    stopped: bool,
}

struct Shared<'a> {
    graph: &'a Graph,
    workers: usize,
    fail_fast: bool,
    state: Mutex<State>,
    wake: Condvar,
}

/// Run every job in `graph` with `runner`, at most `workers` weight at once,
/// and return the results in plan order. A job whose dependency did not pass
/// is skipped, and with `fail_fast` so is every job not yet started once one
/// fails. A runner that panics fails its job.
pub fn run_jobs<F>(graph: &Graph, workers: usize, fail_fast: bool, runner: F) -> Vec<JobResult>
where
    F: Fn(&crate::plan::Job) -> Outcome + Sync,
{
    let n = graph.jobs.len();
    let state = State { slots: vec![Slot::Pending; n], outputs: vec![String::new(); n], used: 0, stopped: false };
    let shared = Shared { graph, workers: workers.max(1), fail_fast, state: Mutex::new(state), wake: Condvar::new() };
    std::thread::scope(|s| {
        for _ in 0..shared.workers.min(n.max(1)) {
            s.spawn(|| work(&shared, &runner));
        }
    });
    collect(&shared)
}

fn collect(shared: &Shared) -> Vec<JobResult> {
    let state = shared.state.lock().unwrap();
    shared
        .graph
        .jobs
        .iter()
        .enumerate()
        .map(|(i, j)| JobResult {
            id: j.id.clone(),
            status: match state.slots[i] {
                Slot::Done(s) => s,
                _ => Status::Skipped,
            },
            output: state.outputs[i].clone(),
        })
        .collect()
}

fn work<F: Fn(&crate::plan::Job) -> Outcome>(shared: &Shared, runner: &F) {
    while let Some(i) = claim(shared) {
        let job = &shared.graph.jobs[i];
        let outcome = catch_unwind(AssertUnwindSafe(|| runner(job)))
            .unwrap_or_else(|_| Outcome { ok: false, output: format!("{}: the job panicked\n", job.id) });
        finish(shared, i, outcome);
    }
}

/// Block until a job can start and claim it, or return `None` once every job
/// is settled.
fn claim(shared: &Shared) -> Option<usize> {
    let mut state = shared.state.lock().unwrap();
    loop {
        settle_skips(shared, &mut state);
        if let Some(i) = next_ready(shared, &state) {
            state.slots[i] = Slot::Running;
            state.used += shared.graph.jobs[i].weight;
            return Some(i);
        }
        if state.slots.iter().all(|s| matches!(s, Slot::Done(_))) {
            return None;
        }
        state = shared.wake.wait(state).unwrap();
    }
}

fn finish(shared: &Shared, i: usize, outcome: Outcome) {
    let mut state = shared.state.lock().unwrap();
    let status = if outcome.ok { Status::Passed } else { Status::Failed };
    state.slots[i] = Slot::Done(status);
    state.outputs[i] = outcome.output;
    state.used -= shared.graph.jobs[i].weight;
    state.stopped |= shared.fail_fast && !outcome.ok;
    drop(state);
    shared.wake.notify_all();
}

/// Mark every pending job that can no longer run as skipped, to a fixed point.
fn settle_skips(shared: &Shared, state: &mut MutexGuard<State>) {
    loop {
        let doomed = (0..state.slots.len()).find(|&i| state.slots[i] == Slot::Pending && is_doomed(shared, state, i));
        match doomed {
            Some(i) => state.slots[i] = Slot::Done(Status::Skipped),
            None => return,
        }
    }
}

fn is_doomed(shared: &Shared, state: &State, i: usize) -> bool {
    state.stopped
        || shared.graph.deps[i]
            .iter()
            .any(|&d| matches!(state.slots[d], Slot::Done(Status::Failed | Status::Skipped)))
}

/// The first pending job, in plan order, whose dependencies have passed and
/// whose weight fits. A job heavier than the pool runs alone rather than never.
fn next_ready(shared: &Shared, state: &State) -> Option<usize> {
    (0..state.slots.len()).find(|&i| {
        let weight = shared.graph.jobs[i].weight;
        state.slots[i] == Slot::Pending
            && shared.graph.deps[i].iter().all(|&d| state.slots[d] == Slot::Done(Status::Passed))
            && (state.used == 0 || state.used + weight <= shared.workers)
    })
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::plan::Job;
    use std::sync::atomic::{AtomicUsize, Ordering};
    use std::sync::Mutex;
    use std::time::{Duration, Instant};

    fn job(id: &str, after: &[&str], weight: usize) -> Job {
        Job { after: after.iter().map(|s| s.to_string()).collect(), weight, ..Job::new(id) }
    }

    fn ok(output: &str) -> Outcome {
        Outcome { ok: true, output: output.into() }
    }

    fn statuses(r: &[JobResult]) -> Vec<Status> {
        r.iter().map(|j| j.status).collect()
    }

    #[test]
    fn runs_every_independent_job_and_keeps_plan_order() {
        let g = Graph::new(vec![job("a", &[], 1), job("b", &[], 1), job("c", &[], 1)]).unwrap();
        let r = run_jobs(&g, 3, false, |j| ok(&j.id));
        assert_eq!(r.iter().map(|j| j.id.as_str()).collect::<Vec<_>>(), ["a", "b", "c"]);
        assert_eq!(r.iter().map(|j| j.output.as_str()).collect::<Vec<_>>(), ["a", "b", "c"]);
        assert!(statuses(&r).iter().all(|s| *s == Status::Passed));
    }

    #[test]
    fn a_job_starts_only_after_its_dependencies_finish() {
        let g = Graph::new(vec![job("a", &[], 1), job("b", &["a"], 1), job("c", &["b"], 1)]).unwrap();
        let order = Mutex::new(vec![]);
        run_jobs(&g, 4, false, |j| {
            std::thread::sleep(Duration::from_millis(5));
            order.lock().unwrap().push(j.id.clone());
            ok("")
        });
        assert_eq!(*order.lock().unwrap(), ["a", "b", "c"]);
    }

    #[test]
    fn concurrency_never_exceeds_the_worker_limit() {
        let jobs = (0..8).map(|i| job(&format!("j{i}"), &[], 1)).collect();
        let g = Graph::new(jobs).unwrap();
        let (now, peak) = (AtomicUsize::new(0), AtomicUsize::new(0));
        run_jobs(&g, 3, false, |_| {
            let n = now.fetch_add(1, Ordering::SeqCst) + 1;
            peak.fetch_max(n, Ordering::SeqCst);
            std::thread::sleep(Duration::from_millis(10));
            now.fetch_sub(1, Ordering::SeqCst);
            ok("")
        });
        let p = peak.load(Ordering::SeqCst);
        assert!((1..=3).contains(&p), "peak {p}");
    }

    #[test]
    fn independent_jobs_overlap() {
        let g = Graph::new(vec![job("a", &[], 1), job("b", &[], 1)]).unwrap();
        let arrived = AtomicUsize::new(0);
        let met = AtomicUsize::new(0);
        run_jobs(&g, 2, false, |_| {
            arrived.fetch_add(1, Ordering::SeqCst);
            let deadline = Instant::now() + Duration::from_secs(5);
            while arrived.load(Ordering::SeqCst) < 2 && Instant::now() < deadline {
                std::thread::yield_now();
            }
            met.fetch_add(usize::from(arrived.load(Ordering::SeqCst) == 2), Ordering::SeqCst);
            ok("")
        });
        assert_eq!(met.load(Ordering::SeqCst), 2, "both jobs must be running at once");
    }

    #[test]
    fn a_heavy_job_excludes_its_neighbours() {
        let g = Graph::new(vec![job("heavy", &[], 2), job("light", &[], 1)]).unwrap();
        let (now, peak) = (AtomicUsize::new(0), AtomicUsize::new(0));
        run_jobs(&g, 2, false, |_| {
            peak.fetch_max(now.fetch_add(1, Ordering::SeqCst) + 1, Ordering::SeqCst);
            std::thread::sleep(Duration::from_millis(20));
            now.fetch_sub(1, Ordering::SeqCst);
            ok("")
        });
        assert_eq!(peak.load(Ordering::SeqCst), 1);
    }

    #[test]
    fn a_job_heavier_than_the_pool_still_runs() {
        let g = Graph::new(vec![job("huge", &[], 9)]).unwrap();
        assert_eq!(statuses(&run_jobs(&g, 2, false, |_| ok(""))), [Status::Passed]);
    }

    #[test]
    fn a_failure_skips_its_dependants_but_not_its_siblings() {
        let g = Graph::new(vec![job("a", &[], 1), job("b", &["a"], 1), job("c", &["b"], 1), job("d", &[], 1)]).unwrap();
        let r = run_jobs(&g, 2, false, |j| Outcome { ok: j.id != "a", output: String::new() });
        assert_eq!(statuses(&r), [Status::Failed, Status::Skipped, Status::Skipped, Status::Passed]);
    }

    #[test]
    fn fail_fast_skips_jobs_not_yet_started() {
        let g = Graph::new(vec![job("a", &[], 1), job("b", &[], 1), job("c", &[], 1)]).unwrap();
        let r = run_jobs(&g, 1, true, |j| Outcome { ok: j.id != "a", output: String::new() });
        assert_eq!(statuses(&r), [Status::Failed, Status::Skipped, Status::Skipped]);
    }

    #[test]
    fn a_panicking_runner_fails_its_job_and_the_run_completes() {
        let g = Graph::new(vec![job("a", &[], 1), job("b", &["a"], 1), job("c", &[], 1)]).unwrap();
        let r = run_jobs(&g, 2, false, |j| if j.id == "a" { panic!("boom") } else { ok("") });
        assert_eq!(statuses(&r), [Status::Failed, Status::Skipped, Status::Passed]);
        assert!(r[0].output.contains("panicked"));
    }

    #[test]
    fn an_empty_graph_returns_no_results() {
        let g = Graph::new(vec![]).unwrap();
        assert!(run_jobs(&g, 4, false, |_| ok("")).is_empty());
    }

    #[test]
    fn zero_workers_is_treated_as_one() {
        let g = Graph::new(vec![job("a", &[], 1)]).unwrap();
        assert_eq!(statuses(&run_jobs(&g, 0, false, |_| ok(""))), [Status::Passed]);
    }
}
