# TODO-11 Decisions

## 2026-02-03 22:30 CST
Decision: Compare normalized individual IDs between GenErode symlink names and original FASTQ filenames.
Rationale: Ensures symlink naming consistency by verifying that normalized identifiers match across link and target names.
Options considered: Exact string match; normalized ID comparison; ignore mismatches.
Implications: Outputs include mismatch rows and summary counts by era.
Notes: Normalization removes `-` and `_` and compares prefixes before `Ex`.
Links: `PLANS/TODO-11.md`.
---
