# Output Files

This directory contains generated analysis outputs. Sections are organized by TODO.

**TODO 1**
Outputs from admixture summarization using continuous metrics.
- `admixture_long.csv`: long-format admixture table with one row per sample and cluster.
- `admixture_metrics.csv`: per-sample metrics including `max_prop`, `admixedness`, entropy, and effective clusters.
- `admixture_summary.csv`: wide-format K1–K4 probabilities joined to summary metrics.
- `admixture_qc.csv`: QC checks for cluster counts and probability sums.

**TODO 2**
Outputs from linking admixture, extraction, library, and decode metadata.
- `admixture_extraction_library_key.csv`: unified key table with joined identifiers and flags.
- `admixture_extraction_library_diagnostics.csv`: diagnostics for unmatched joins and decode mismatches.

**TODO 3**
Outputs from tissue subsampling order tests.
- `tissue_subsampling_adjacency_metrics.csv`: per-group adjacency and periodic metrics.
- `tissue_subsampling_permutation_summary.csv`: permutation-based summaries and p-values.
- `tissue_subsampling_permutation_distributions.csv`: full permutation distributions per group.
- `tissue_subsampling_admixture_heatmap.png`: heatmap of K1–K4 proportions by individual, faceted by era and location.

Interpretation:
- Use `tissue_subsampling_permutation_summary.csv` to identify groups (by `date_subsampling_date` and `subsampler`) with low empirical p-values, indicating non-random adjacency or periodic patterns in `admixedness`.
- `adj_abs_diff_mean` reflects average neighbor-to-neighbor changes in `admixedness`; higher-than-expected values suggest abrupt shifts between consecutive samples.
- `high_low_transition_rate` captures switches between lower and higher quantiles of `admixedness` without hard thresholds.
- `period2_corr` and `period3_corr` summarize similarity to alternating or every-third patterns; compare observed values to permutation means and p-values.
- `tissue_subsampling_admixture_heatmap.png` helps visualize whether admixture patterns align with location/era structure (biological signal) versus scattered, isolated changes that could reflect contamination.

**TODO 4**
Outputs from extraction order tests.
- `extraction_order_adjacency_metrics.csv`: per-group adjacency and periodic metrics.
- `extraction_order_permutation_summary.csv`: permutation-based summaries and p-values.
- `extraction_order_permutation_distributions.csv`: full permutation distributions per group.

Interpretation:
- Use `extraction_order_permutation_summary.csv` to identify extraction groups (by `date_extracting_date` and `tube_stuffer`) with low empirical p-values, indicating non-random adjacency or periodic patterns in `admixedness`.
- `adj_abs_diff_mean` reflects average neighbor-to-neighbor changes in `admixedness` across extraction order.
- `high_low_transition_rate` captures switches between lower and higher `admixedness` quantiles without hard thresholds.
- `period2_corr` and `period3_corr` summarize similarity to alternating or period-3 patterns; compare observed values to permutation means and p-values.

Flagged groups (min p-value across metrics <= 0.05):
| extraction_group | date_extracting_date | tube_stuffer | n_group | n_nonmissing_admixedness | min_p | min_metric |
| --- | --- | --- | --- | --- | --- | --- |
| 2022-10-05\|Chandy_Jablonski | 2022-10-05 | Chandy_Jablonski | 12 | 12 | 0.000 | adj_abs_diff_mean_p_value |
| 2023-03-01\|John_Schaefer | 2023-03-01 | John_Schaefer | 36 | 16 | 0.026 | adj_abs_diff_mean_p_value |
| 2022-09-27\|John_Schaefer | 2022-09-27 | John_Schaefer | 21 | 21 | 0.030 | adj_abs_diff_mean_p_value |
| 2022-11-09\|John_Schaefer | 2022-11-09 | John_Schaefer | 41 | 41 | 0.049 | adj_abs_diff_mean_p_value |

**TODO 5**
Outputs from extraction plate adjacency tests.
- `extraction_plate_adjacency_metrics.csv`: per-plate adjacency metrics across 4-neighbor wells.
- `extraction_plate_permutation_summary.csv`: permutation-based summaries and p-values.
- `extraction_plate_permutation_distributions.csv`: full permutation distributions per plate.
- `extraction_plate_diagnostics.csv`: counts of missing or duplicated plate coordinates.
- `extraction_plate_counts.csv`: well counts and missingness per plate and elution.
- `extraction_plate_admixedness_heatmap.png`: plate-layout heatmaps of continuous admixedness, faceted by plate.
- `extraction_plate_cluster_heatmap.png`: plate-layout heatmaps of dominant clusters, faceted by plate.
- `extraction_plate_admixedness_boxplot.png`: per-plate admixedness distribution summary.

Interpretation:
- Use `extraction_plate_permutation_summary.csv` to identify plates with low empirical p-values, indicating non-random adjacency patterns in `admixedness` or dominant clusters.
- `adj_abs_diff_mean` and `adj_abs_diff_median` summarize how sharply `admixedness` changes between neighboring wells (up/down/left/right).
- `cluster_mismatch_rate` captures how often adjacent wells have different dominant clusters; elevated values may indicate spatial mixing on the plate.
- Check `extraction_plate_diagnostics.csv` for missing or duplicated coordinates that could bias adjacency metrics and `extraction_plate_counts.csv` to confirm plate sizes.
- `extraction_plate_admixedness_heatmap.png` highlights spatial gradients or patchiness in admixedness.
- `extraction_plate_cluster_heatmap.png` shows spatial mixing of dominant clusters across the plate.
- `extraction_plate_admixedness_boxplot.png` helps compare overall admixedness distributions across plates.

Flagged plates (min p-value across metrics <= 0.05):
| plate_key | plateid | elution | n_wells | n_missing_admixedness | min_p | min_metric |
| --- | --- | --- | --- | --- | --- | --- |
| Och-A_001_E1\|1 | Och-A_001_E1 | 1 | 77 | 0 | 0.000 | adj_abs_diff_median_p_value |
| Mix-A_005_E1\|1 | Mix-A_005_E1 | 1 | 24 | 0 | 0.005 | adj_abs_diff_mean_p_value |
| Mix-C_008_E1\|1 | Mix-C_008_E1 | 1 | 43 | 1 | 0.013 | adj_abs_diff_mean_p_value |
