# TODO-09 Decisions

## 2026-02-03 22:18 CST
Decision: Check duplicates for sequencing name fields within pools and runs derived from `Pool Round`.
Rationale: Duplicate sequence names or IDs within the same sequencing context can cause read misassignment and apparent admixture.
Options considered: Pool-only duplicates; run-only duplicates; include both pool and run summaries.
Implications: Outputs include duplicate details by pool and summary counts for pool/run contexts, plus missing name counts.
Notes: Fields checked include `Test Lane Seq Name`, `NovoGeneSeqID`, `Sequence_ID`, `Full seq Name`, and `Full seq decode`.
Links: `PLANS/TODO-09.md`.
---
