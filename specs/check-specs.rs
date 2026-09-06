#!/bin/bash
//! 2>/dev/null; command -v rust-script >/dev/null 2>&1 || { echo "Error: Install rust-script with: cargo install rust-script" >&2; exit 1; }; exec rust-script "$0" "$@"
//!
//! Specification consistency checker.
//!
//! Enforces the rules in specs/README.md that a reviewer cannot hold in their head:
//!
//!   1. Single source of truth — no run of prose is restated across two documents.
//!      Each set of information has one owner (README § Document ownership); every
//!      other document links to the owner rather than repeating it.
//!   2. Design status lives only in 009 — no other document labels its own maturity.
//!   3. Every cross-document link resolves, both the file and the heading anchor.
//!
//! Run from the repository root (the directory holding specs/ and CHANGES.md):
//!
//!     ./specs/check-specs.rs            # report and exit non-zero on any failure
//!     ./specs/check-specs.rs --span 10  # tighten the duplication threshold
//!
//! Legitimate overlaps go in specs/.duplication-allow, one normalized phrase per
//! line (`#` comments ignored). A finding is suppressed when its text contains an
//! allowed phrase, so an entry should be the distinctive middle of the overlap.

use std::collections::{BTreeMap, BTreeSet, HashMap};
use std::fs;
use std::path::{Path, PathBuf};

/// Length of the word n-gram used to seed a match. Shorter finds more, and noisier.
const GRAM: usize = 8;
/// A merged run must reach this many words to be reported. Below it, an overlap is
/// a shared phrase (a part number, a stock sentence opener) rather than restated
/// information.
const DEFAULT_MIN_SPAN: usize = 12;

/// Documents allowed to carry `[Specified]` / `[Provisional]` / `[TBD]` markers.
/// README defines the scheme, 009 owns the status of every item, and CHANGES
/// records the marker each revision was written with.
const STATUS_OWNERS: [&str; 3] = ["README.md", "009-Design-Completion.md", "CHANGES.md"];

struct Doc {
    path: String,
    /// Prose with code fences dropped and link syntax reduced to its text.
    text: String,
    /// (lowercased word, byte offset into `text`)
    words: Vec<(String, usize)>,
    /// GitHub heading anchors this document defines.
    anchors: BTreeSet<String>,
}

fn main() {
    let mut min_span = DEFAULT_MIN_SPAN;
    let args: Vec<String> = std::env::args().collect();
    if let Some(i) = args.iter().position(|a| a == "--span") {
        min_span = args
            .get(i + 1)
            .and_then(|v| v.parse().ok())
            .unwrap_or(DEFAULT_MIN_SPAN);
    }

    if !Path::new("specs").is_dir() {
        eprintln!("error: run from the repository root (no specs/ directory here)");
        std::process::exit(2);
    }

    let docs = load_docs();
    if docs.is_empty() {
        eprintln!("error: no specification documents found");
        std::process::exit(2);
    }
    let allow = load_allowlist();

    let mut failures = 0;
    failures += check_duplication(&docs, &allow, min_span);
    failures += check_status_ownership(&docs);
    failures += check_links(&docs);

    if failures == 0 {
        println!("specs OK — {} documents checked", docs.len());
    } else {
        println!("\n{} problem(s) found", failures);
        std::process::exit(1);
    }
}

// ---------------------------------------------------------------- loading

fn load_docs() -> Vec<Doc> {
    let mut paths: Vec<PathBuf> = fs::read_dir("specs")
        .expect("read specs/")
        .filter_map(|e| e.ok().map(|e| e.path()))
        .filter(|p| p.extension().map(|e| e == "md").unwrap_or(false))
        .collect();
    paths.sort();
    if Path::new("CHANGES.md").exists() {
        paths.push(PathBuf::from("CHANGES.md"));
    }

    paths
        .iter()
        .map(|p| {
            let raw = fs::read_to_string(p).unwrap_or_default();
            let text = normalize(&raw);
            Doc {
                path: p.to_string_lossy().replace('\\', "/"),
                words: tokenize(&text),
                anchors: headings(&raw),
                text,
            }
        })
        .collect()
}

fn load_allowlist() -> Vec<String> {
    fs::read_to_string("specs/.duplication-allow")
        .unwrap_or_default()
        .lines()
        .map(|l| l.trim().to_string())
        .filter(|l| !l.is_empty() && !l.starts_with('#'))
        .map(|l| squash(&l.to_lowercase()))
        .collect()
}

/// Drop fenced code, reduce `[text](url)` to `text`, and strip markdown punctuation
/// so a table cell and a sentence carrying the same claim compare equal.
fn normalize(raw: &str) -> String {
    let mut out = String::with_capacity(raw.len());
    let mut in_fence = false;
    for line in raw.lines() {
        if line.trim_start().starts_with("```") {
            in_fence = !in_fence;
            out.push('\n');
            continue;
        }
        if in_fence {
            out.push('\n');
            continue;
        }
        out.push_str(&strip_links(line));
        out.push('\n');
    }
    out.chars()
        .map(|c| if "`*_>#|".contains(c) { ' ' } else { c })
        .collect()
}

fn strip_links(line: &str) -> String {
    // `[text](url)` -> `text`, leaving other bracket use untouched.
    let b: Vec<char> = line.chars().collect();
    let mut out = String::new();
    let mut i = 0;
    while i < b.len() {
        if b[i] == '[' {
            if let Some(close) = find(&b, i + 1, ']') {
                if close + 1 < b.len() && b[close + 1] == '(' {
                    if let Some(paren) = find(&b, close + 2, ')') {
                        out.extend(&b[i + 1..close]);
                        i = paren + 1;
                        continue;
                    }
                }
            }
        }
        out.push(b[i]);
        i += 1;
    }
    out
}

fn find(b: &[char], from: usize, target: char) -> Option<usize> {
    (from..b.len()).find(|&i| b[i] == target)
}

fn tokenize(text: &str) -> Vec<(String, usize)> {
    let mut words = Vec::new();
    let mut cur = String::new();
    let mut start = 0;
    for (i, c) in text.char_indices() {
        let wordish = c.is_alphanumeric() || (!cur.is_empty() && (c == '-' || c == '\'' || c == '\u{2019}'));
        if wordish {
            if cur.is_empty() {
                start = i;
            }
            cur.push(c.to_lowercase().next().unwrap_or(c));
        } else if !cur.is_empty() {
            words.push((std::mem::take(&mut cur), start));
        }
    }
    if !cur.is_empty() {
        words.push((cur, start));
    }
    words
}

fn squash(s: &str) -> String {
    s.split_whitespace().collect::<Vec<_>>().join(" ")
}

// ------------------------------------------------------- rule 1: duplication

fn check_duplication(docs: &[Doc], allow: &[String], min_span: usize) -> usize {
    // gram -> [(doc index, word index)]
    let mut grams: HashMap<String, Vec<(usize, usize)>> = HashMap::new();
    for (d, doc) in docs.iter().enumerate() {
        // CHANGES.md quotes the design as it stood in each revision; that overlap is
        // the point of a history log, not a second source of truth.
        if doc.words.len() < GRAM || doc.path.ends_with("CHANGES.md") {
            continue;
        }
        for i in 0..=doc.words.len() - GRAM {
            let key = doc.words[i..i + GRAM]
                .iter()
                .map(|(w, _)| w.as_str())
                .collect::<Vec<_>>()
                .join(" ");
            grams.entry(key).or_default().push((d, i));
        }
    }

    // Collect, per pair of documents, the word indices in each that a shared gram covers.
    let mut pairs: BTreeMap<(usize, usize), BTreeSet<usize>> = BTreeMap::new();
    for locs in grams.values() {
        if locs.len() < 2 {
            continue;
        }
        for (ai, &(da, ia)) in locs.iter().enumerate() {
            for &(db, _) in locs.iter().skip(ai + 1) {
                if da == db {
                    continue; // within one document, repetition is that document's business
                }
                let key = if da < db { (da, db) } else { (db, da) };
                let idx = if da < db { ia } else { ia };
                pairs.entry(key).or_default().insert(idx);
            }
        }
    }

    let mut findings = Vec::new();
    for ((a, b), starts) in &pairs {
        for (from, to) in merge_runs(starts) {
            let len = to - from + GRAM;
            if len < min_span {
                continue;
            }
            let quote = span_text(&docs[*a], from, to + GRAM);
            if allow.iter().any(|p| squash(&quote.to_lowercase()).contains(p.as_str())) {
                continue;
            }
            findings.push((len, docs[*a].path.clone(), docs[*b].path.clone(), quote));
        }
    }
    findings.sort_by(|x, y| y.0.cmp(&x.0));

    for (len, a, b, quote) in &findings {
        println!("DUPLICATED  {} words: {} <-> {}", len, a, b);
        println!("            \"{}\"", truncate(quote, 240));
    }
    if !findings.is_empty() {
        println!(
            "\n  Each of these states the same thing in two documents. Decide which one owns it\n  \
             (specs/README.md § Document ownership), keep it there, and replace the other with a\n  \
             link. If the overlap is unavoidable, add a phrase from it to specs/.duplication-allow.\n"
        );
    }
    findings.len()
}

/// Turn a set of gram start indices into maximal runs of consecutive starts.
fn merge_runs(starts: &BTreeSet<usize>) -> Vec<(usize, usize)> {
    let mut runs = Vec::new();
    let mut it = starts.iter().copied();
    let Some(first) = it.next() else {
        return runs;
    };
    let (mut lo, mut hi) = (first, first);
    for i in it {
        if i == hi + 1 {
            hi = i;
        } else {
            runs.push((lo, hi));
            lo = i;
            hi = i;
        }
    }
    runs.push((lo, hi));
    runs
}

fn span_text(doc: &Doc, from: usize, to: usize) -> String {
    let start = doc.words[from].1;
    let last = &doc.words[to.min(doc.words.len() - 1)];
    let end = (last.1 + last.0.len()).min(doc.text.len());
    squash(&doc.text[start..end])
}

fn truncate(s: &str, n: usize) -> String {
    if s.chars().count() <= n {
        return s.to_string();
    }
    let head: String = s.chars().take(n).collect();
    format!("{}…", head)
}

// ---------------------------------------------------- rule 2: status ownership

fn check_status_ownership(docs: &[Doc]) -> usize {
    const MARKERS: [&str; 3] = ["[Specified]", "[Provisional]", "[TBD]"];
    let mut problems = 0;
    for doc in docs {
        let name = doc.path.rsplit('/').next().unwrap_or(&doc.path);
        if STATUS_OWNERS.contains(&name) {
            continue;
        }
        let raw = fs::read_to_string(&doc.path).unwrap_or_default();
        for (n, para) in paragraphs(&raw) {
            if !MARKERS.iter().any(|m| para.contains(m)) {
                continue;
            }
            // A marker is fine when the paragraph is talking *about* 009's scheme.
            if para.contains("009-Design-Completion.md") || para.contains("README.md#design-status") {
                continue;
            }
            println!(
                "STATUS      {}:{} carries a design-status marker; 009 owns status",
                doc.path, n
            );
            println!("            \"{}\"", truncate(&squash(para), 160));
            problems += 1;
        }
    }
    problems
}

/// (1-based line number of the paragraph's first line, paragraph text)
fn paragraphs(raw: &str) -> Vec<(usize, &str)> {
    let mut out = Vec::new();
    let mut line_no = 1;
    let mut start_byte = 0;
    let mut start_line = 1;
    let mut blank = true;
    for line in raw.split_inclusive('\n') {
        let is_blank = line.trim().is_empty();
        if blank && !is_blank {
            start_byte = line.as_ptr() as usize - raw.as_ptr() as usize;
            start_line = line_no;
        }
        if !blank && is_blank {
            let end = line.as_ptr() as usize - raw.as_ptr() as usize;
            out.push((start_line, &raw[start_byte..end]));
        }
        blank = is_blank;
        line_no += 1;
    }
    if !blank {
        out.push((start_line, &raw[start_byte..]));
    }
    out
}

// ------------------------------------------------------------- rule 3: links

fn check_links(docs: &[Doc]) -> usize {
    let by_path: HashMap<&str, &Doc> = docs.iter().map(|d| (d.path.as_str(), d)).collect();
    let mut problems = 0;

    for doc in docs {
        let raw = fs::read_to_string(&doc.path).unwrap_or_default();
        let dir = Path::new(&doc.path).parent().unwrap_or(Path::new("."));
        for target in link_targets(&raw) {
            let (file, anchor) = match target.split_once('#') {
                Some((f, a)) => (f, Some(a)),
                None => (target.as_str(), None),
            };
            if file.starts_with("http") {
                continue;
            }
            let resolved = if file.is_empty() {
                doc.path.clone()
            } else {
                normalize_path(&dir.join(file)).replace('\\', "/")
            };
            if !file.is_empty() && !Path::new(&resolved).exists() {
                println!("BAD LINK    {} -> {} (no such file)", doc.path, resolved);
                problems += 1;
                continue;
            }
            let Some(anchor) = anchor else { continue };
            let Some(target_doc) = by_path.get(resolved.as_str()) else {
                continue; // outside the spec set (a model file, a directory): file existence is enough
            };
            if !target_doc.anchors.contains(anchor) {
                println!("BAD ANCHOR  {} -> {}#{}", doc.path, resolved, anchor);
                problems += 1;
            }
        }
    }
    problems
}

fn link_targets(raw: &str) -> Vec<String> {
    let b: Vec<char> = raw.chars().collect();
    let mut out = Vec::new();
    let mut i = 0;
    while i < b.len() {
        if b[i] == ']' && i + 1 < b.len() && b[i + 1] == '(' {
            if let Some(close) = find(&b, i + 2, ')') {
                let t: String = b[i + 2..close].iter().collect();
                if !t.contains(char::is_whitespace) {
                    out.push(t);
                }
                i = close + 1;
                continue;
            }
        }
        i += 1;
    }
    out
}

fn normalize_path(p: &Path) -> String {
    let mut parts: Vec<String> = Vec::new();
    for c in p.components() {
        match c.as_os_str().to_string_lossy().as_ref() {
            "." => {}
            ".." => {
                parts.pop();
            }
            s => parts.push(s.to_string()),
        }
    }
    parts.join("/")
}

/// GitHub's heading-to-anchor rule: drop link syntax and markdown punctuation,
/// discard anything that is not a word character, space or hyphen, then
/// lowercase and join with hyphens.
fn headings(raw: &str) -> BTreeSet<String> {
    let mut out = BTreeSet::new();
    let mut in_fence = false;
    for line in raw.lines() {
        if line.trim_start().starts_with("```") {
            in_fence = !in_fence;
            continue;
        }
        if in_fence || !line.starts_with('#') {
            continue;
        }
        let title = line.trim_start_matches('#').trim();
        if title.is_empty() {
            continue;
        }
        let text = strip_links(title);
        let cleaned: String = text
            .chars()
            .filter(|c| !"`*[]".contains(*c))
            .filter(|c| c.is_alphanumeric() || c.is_whitespace() || *c == '-' || *c == '_')
            .collect();
        // Each space becomes one hyphen — GitHub does not collapse runs, so
        // "Tool interface (roll + grip)" anchors as `tool-interface-roll--grip`.
        out.insert(
            cleaned
                .trim()
                .to_lowercase()
                .chars()
                .map(|c| if c.is_whitespace() { '-' } else { c })
                .collect(),
        );
    }
    out
}
