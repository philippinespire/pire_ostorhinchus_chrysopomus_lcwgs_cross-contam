# TODO-10 Decisions

## 2026-02-03 22:28 CST
Decision: Parse decode sedlist files into first/second names and compare them to expected metadata pairs per sequencing run.
Rationale: Directly checks whether decode mappings match library metadata for each run without assumptions about order.
Options considered: Count-only checks; full pairwise comparison; ignore missing entries.
Implications: Outputs include unmatched decode entries, missing expected pairs, and per-run summary counts.
Notes: 1st sequencing run is ignored per objectives; comparisons use Test Lane, Test Lane 2, and Full Lane definitions.
Links: `PLANS/TODO-10.md`.
---
