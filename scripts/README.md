# Scripts

**01_admixture_summary.R**
Summarizes admixture proportions into reusable, continuous metrics. Produces long and wide tables plus per-sample metrics and QC outputs for downstream joins.

**02_build_key_table.R**
Builds a unified key table linking admixture summaries to extraction metadata, library metadata, and decode mappings. Generates diagnostics for unmatched or mismatched joins.

**03_tissue_subsampling_tests.R**
Tests whether tissue subsampling order shows non-random admixture patterns within each (`date_subsampling_date`, `subsampler`) group using continuous `admixedness` metrics and permutation baselines. Also generates K2–K4 and K4-only heatmaps by individual faceted by location and era.

Statistical hypotheses:
- Adjacency shifts: observed neighbor-to-neighbor changes in `admixedness` are consistent with random ordering within a subsampling group.
- High/low transitions: the observed rate of switching between lower and higher `admixedness` quantiles is consistent with random ordering.
- Period-2 pattern: the observed sequence is not more correlated with an alternating pattern than expected under random ordering.
- Period-3 pattern: the observed sequence is not more correlated with a period-3 pattern than expected under random ordering.

Each hypothesis is evaluated using empirical p-values derived from within-group permutations.

**04_extraction_order_tests.R**
Tests whether extraction order shows non-random admixture patterns within each (`date_extracting_date`, `tube_stuffer`) group using continuous `admixedness` metrics and permutation baselines.

Statistical hypotheses:
- Adjacency shifts: observed neighbor-to-neighbor changes in `admixedness` are consistent with random ordering within an extraction group.
- High/low transitions: the observed rate of switching between lower and higher `admixedness` quantiles is consistent with random ordering.
- Period-2 pattern: the observed sequence is not more correlated with an alternating pattern than expected under random ordering.
- Period-3 pattern: the observed sequence is not more correlated with a period-3 pattern than expected under random ordering.

Each hypothesis is evaluated using empirical p-values derived from within-group permutations.

**05_extraction_plate_adjacency.R**
Tests whether extraction plate layout shows non-random spatial adjacency patterns in `admixedness` and dominant genetic cluster using 4-neighbor wells within each plate and permutation baselines. Also generates plate-layout heatmaps (admixedness, K4 affiliation, dominant cluster) and per-plate admixedness summaries.

**06_library_plate_adjacency.R**
Tests whether library plate layout shows non-random spatial adjacency patterns in `admixedness` and dominant genetic cluster using 4-neighbor wells within each plate and permutation baselines. Also generates plate-layout heatmaps (admixedness, K4 affiliation, dominant cluster) and per-plate admixedness summaries.

**07_dilution_plate_adjacency.R**
Tests whether dilution plate layout shows non-random spatial adjacency patterns in `admixedness` and dominant genetic cluster using 4-neighbor wells within each plate and permutation baselines. Also generates plate-layout heatmaps (admixedness, K4 affiliation, dominant cluster) and per-plate admixedness summaries.

Statistical hypotheses:
- Adjacency differences: observed neighbor-to-neighbor `admixedness` differences are consistent with random arrangement within each plate.
- Cluster mismatch: observed dominant-cluster mismatch rates between neighboring wells are consistent with random arrangement within each plate.

Each hypothesis is evaluated using empirical p-values derived from within-plate permutations.
