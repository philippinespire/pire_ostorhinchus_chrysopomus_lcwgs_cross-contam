# TODO-11 Decisions

## 2026-02-03 22:40 CST
Decision: Parse target IDs using either `_Ex` or `-Ex` as the split point.
Rationale: Modern GenErode target filenames use `_Ex` while earlier parsing assumed `-Ex`, inflating mismatch counts.
Options considered: Keep `-Ex` split only; use `_Ex` only; allow both.
Implications: Mismatch counts now reflect true ID inconsistencies rather than parsing artifacts.
Notes: Link IDs also parsed with `_Ex|-Ex` for consistency.
Links: `PLANS/TODO-11.md`.
---

## 2026-02-03 22:30 CST
Decision: Compare normalized individual IDs between GenErode symlink names and original FASTQ filenames.
Rationale: Ensures symlink naming consistency by verifying that normalized identifiers match across link and target names.
Options considered: Exact string match; normalized ID comparison; ignore mismatches.
Implications: Outputs include mismatch rows and summary counts by era.
Notes: Normalization removes `-` and `_` and compares prefixes before `Ex`.
Links: `PLANS/TODO-11.md`.
---
