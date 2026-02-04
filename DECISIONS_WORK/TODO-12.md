# TODO-12 Decisions

## 2026-02-04 00:17 CST
Decision: Define a candidate list using `evidence_count >= 2` and `admixedness` in the top quartile (`admixedness_percentile >= 75`).
Rationale: Provides a focused, reproducible shortlist without imposing a hard purity cutoff while still emphasizing stronger admixture signals.
Options considered: List all individuals with any evidence flag; require higher evidence thresholds (>=3 or >=4); use a fixed admixedness cutoff.
Implications: `output/TODO-12/contamination_evidence_candidates.csv` is a prioritized subset rather than a strict classification.
Notes: Users can adjust thresholds post hoc using the full evidence table.
Links: `PLANS/TODO-12.md`.
---

## 2026-02-04 00:17 CST
Decision: Include extraction `notes` as a lab-notes evidence flag in the summary table.
Rationale: Notes capture lab-observed issues that may indicate contamination risk beyond statistical tests.
Options considered: Exclude notes; include notes as a separate non-counted annotation; include notes as a counted evidence source.
Implications: `lab_notes_flag` and `lab_notes` are included in `contamination_evidence_by_individual.csv` and contribute to `evidence_count`.
Notes: Notes remain qualitative and should be interpreted alongside quantitative evidence.
Links: `PLANS/TODO-12.md`.
---
