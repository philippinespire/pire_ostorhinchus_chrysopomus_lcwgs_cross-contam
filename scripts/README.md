# Scripts

**01_admixture_summary.R**
Summarizes admixture proportions into reusable, continuous metrics. Produces long and wide tables plus per-sample metrics and QC outputs for downstream joins.

**02_build_key_table.R**
Builds a unified key table linking admixture summaries to extraction metadata, library metadata, and decode mappings. Generates diagnostics for unmatched or mismatched joins.

**03_tissue_subsampling_tests.R**
Tests whether tissue subsampling order shows non-random admixture patterns within each (`date_subsampling_date`, `subsampler`) group using continuous `admixedness` metrics and permutation baselines.

Statistical hypotheses:
- Adjacency shifts: observed neighbor-to-neighbor changes in `admixedness` are consistent with random ordering within a subsampling group.
- High/low transitions: the observed rate of switching between lower and higher `admixedness` quantiles is consistent with random ordering.
- Period-2 pattern: the observed sequence is not more correlated with an alternating pattern than expected under random ordering.
- Period-3 pattern: the observed sequence is not more correlated with a period-3 pattern than expected under random ordering.

Each hypothesis is evaluated using empirical p-values derived from within-group permutations.
