# TODO-08 Decisions

## 2026-02-03 22:05 CST
Decision: Check for duplicate i5+i7 index pairs within pools and within runs defined by `Pool Round`.
Rationale: Duplicate index combinations within a sequencing pool or run can cause read misassignment and apparent admixture.
Options considered: Pool-only duplicates; run-only duplicates; pool and run summaries together.
Implications: Outputs include pool-level duplicate details and a summary covering both pools and runs, plus missing index counts.
Notes: Index pairs are built from `i5 Index for Novogene` and `i7 Index`; missing values are tracked separately.
Links: `PLANS/TODO-08.md`.
---
