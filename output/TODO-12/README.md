# TODO 12 Results

Outputs from cross-contamination evidence synthesis.
- [contamination_evidence_by_individual.csv](contamination_evidence_by_individual.csv): per-individual admixture metrics (K2–K4, `admixedness`) with evidence flags for each contamination source plus evidence counts and ranks.
- [contamination_evidence_candidates.csv](contamination_evidence_candidates.csv): prioritized subset with multiple evidence sources (`evidence_count >= 2`) and higher admixture (top quartile by `admixedness_percentile`), sorted by admixedness.
- [contamination_evidence_summary.csv](contamination_evidence_summary.csv): counts of individuals flagged per evidence source plus overall totals.

Interpretation:
- Admixture is treated as continuous; there is no hard purity cutoff. Admixedness is defined as `1 - max_prop` across K2–K4 per individual (K1 merged into K2).
- Use `admixedness` and `admixedness_percentile` to rank intensity.
- `evidence_sources` lists which contamination mechanisms flagged an individual; `evidence_count` summarizes how many sources point to that individual.
- `candidate_flag` is a prioritization rule (multiple evidence sources + high admixture) rather than a strict classification.
- `conflict_flag` denotes known special cases (see `AGENTS.md`) and should be interpreted separately from contamination evidence.
