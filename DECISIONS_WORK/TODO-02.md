# TODO-02 Decisions

## 2026-02-03 17:24 CST
Decision: Use a canonical individual key by stripping `-` and `_` from IDs for cross-table joins, and use decode files to map sequence names to `Sequence_ID` while extracting `extraction_id` from `Sequence_ID` when possible.
Rationale: Naming conventions differ across admixture, extraction, library, and decode outputs; a canonical key plus decode mapping maximizes linkage without dropping records.
Options considered: Hard-join on exact string IDs; manually curate rename tables; canonicalize IDs and supplement with decode mappings.
Implications: The unified key table will include concatenated IDs and explicit diagnostics for unmatched or ambiguous mappings.
Notes: This supports TODO #2 and will be revisited if canonicalization creates ambiguous collisions.
Links: `PLANS/TODO-02.md`.
---
