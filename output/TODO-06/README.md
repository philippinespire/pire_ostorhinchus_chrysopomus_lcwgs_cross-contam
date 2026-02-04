# TODO 6 Results

Outputs from library plate adjacency tests.
- [library_plate_adjacency_metrics.csv](library_plate_adjacency_metrics.csv): per-plate adjacency metrics across 4-neighbor wells.
- [library_plate_permutation_summary.csv](library_plate_permutation_summary.csv): permutation-based summaries and p-values.
- [library_plate_permutation_distributions.csv](library_plate_permutation_distributions.csv): full permutation distributions per plate.
- [library_plate_diagnostics.csv](library_plate_diagnostics.csv): counts of missing or duplicated plate coordinates.
- [library_plate_counts.csv](library_plate_counts.csv): well counts and missingness per plate.
- [library_plate_admixedness_heatmap.png](library_plate_admixedness_heatmap.png): plate-layout heatmaps of continuous admixedness, faceted by plate.
- [library_plate_k4_heatmap.png](library_plate_k4_heatmap.png): plate-layout heatmaps of K4 affiliation, faceted by plate.
- [library_plate_cluster_heatmap.png](library_plate_cluster_heatmap.png): plate-layout heatmaps of dominant clusters, faceted by plate.
- [library_plate_admixedness_boxplot.png](library_plate_admixedness_boxplot.png): per-plate admixedness distribution summary.

Interpretation:
- Use [library_plate_permutation_summary.csv](library_plate_permutation_summary.csv) to identify plates with low empirical p-values, indicating non-random adjacency patterns in `admixedness` or dominant clusters.
- `adj_abs_diff_mean` and `adj_abs_diff_median` summarize how sharply `admixedness` changes between neighboring wells (up/down/left/right).
- `cluster_mismatch_rate` captures how often adjacent wells have different dominant clusters; elevated values may indicate spatial mixing on the plate.
- Check [library_plate_diagnostics.csv](library_plate_diagnostics.csv) for missing or duplicated coordinates that could bias adjacency metrics and [library_plate_counts.csv](library_plate_counts.csv) to confirm plate sizes.
- [library_plate_admixedness_heatmap.png](library_plate_admixedness_heatmap.png) highlights spatial gradients or patchiness in admixedness.
- [library_plate_k4_heatmap.png](library_plate_k4_heatmap.png) isolates K4 spatial patterns within plates.
- [library_plate_cluster_heatmap.png](library_plate_cluster_heatmap.png) shows spatial mixing of dominant clusters across the plate.
- [library_plate_admixedness_boxplot.png](library_plate_admixedness_boxplot.png) helps compare overall admixedness distributions across plates.

Plots:
![](library_plate_admixedness_heatmap.png)
![](library_plate_k4_heatmap.png)
![](library_plate_cluster_heatmap.png)
![](library_plate_admixedness_boxplot.png)
