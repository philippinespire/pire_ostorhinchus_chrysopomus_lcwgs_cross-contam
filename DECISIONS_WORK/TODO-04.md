# TODO-04 Decisions

## 2026-02-03 17:55 CST
Decision: Use the same continuous adjacency and periodic metrics as TODO #3, applied within (`date_extracting`, `tube_stuffer`) groups with permutation baselines.
Rationale: Keeps extraction-order tests comparable to subsampling-order tests without introducing arbitrary thresholds.
Options considered: Binary admixed/pure transitions; fixed cutoffs; continuous metrics with permutation tests.
Implications: Outputs provide per-group metrics and empirical p-values, with small groups flagged for limited inference.
Notes: Metrics rely on non-missing `admixedness` values while preserving all records.
Links: `PLANS/TODO-04.md`.
---
