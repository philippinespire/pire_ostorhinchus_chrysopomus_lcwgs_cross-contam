# TODO-09 Decisions

## 2026-02-03 22:34 CST
Decision: Exclude `Test Lane Seq Name` from duplicate checks because it is not unique.
Rationale: Per objectives, only `NovoGeneSeqID`, `Sequence_ID`, `Full seq Name`, and `Full seq decode` are expected to be unique within runs/pools.
Options considered: Keep all name fields; exclude only `Test Lane Seq Name`; separate reports per name type.
Implications: Duplicate checks now focus on the unique sequencing identifiers only.
Notes: `Test Lane Seq Name` is retained in metadata for context but not used in duplicate detection.
Links: `PLANS/TODO-09.md`.
---

## 2026-02-03 22:18 CST
Decision: Check duplicates for sequencing name fields within pools and runs derived from `Pool Round`.
Rationale: Duplicate sequence names or IDs within the same sequencing context can cause read misassignment and apparent admixture.
Options considered: Pool-only duplicates; run-only duplicates; include both pool and run summaries.
Implications: Outputs include duplicate details by pool and summary counts for pool/run contexts, plus missing name counts.
Notes: Fields checked include `Test Lane Seq Name`, `NovoGeneSeqID`, `Sequence_ID`, `Full seq Name`, and `Full seq decode`.
Links: `PLANS/TODO-09.md`.
---
