# TODO 4 Results

Outputs from extraction order tests.
- [extraction_order_adjacency_metrics.csv](extraction_order_adjacency_metrics.csv): per-group adjacency and periodic metrics.
- [extraction_order_permutation_summary.csv](extraction_order_permutation_summary.csv): permutation-based summaries and p-values.
- [extraction_order_permutation_distributions.csv](extraction_order_permutation_distributions.csv): full permutation distributions per group.

Interpretation:
- Admixedness is defined as `1 - max_prop` across K2–K4 per individual (K1 merged into K2).
- Use [extraction_order_permutation_summary.csv](extraction_order_permutation_summary.csv) to identify extraction groups (by `date_extracting_date` and `tube_stuffer`) with low empirical p-values, indicating non-random adjacency or periodic patterns in `admixedness`.
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
