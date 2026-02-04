# TODO-03 Decisions

## 2026-02-03 21:04 CST
Decision: Add a K4-only heatmap (red scale) by individual, faceted by location and era.
Rationale: Isolates K4 signal to evaluate whether that cluster shows spatial/era structure or scattered contamination signatures.
Options considered: K1–K4 heatmap only; separate heatmaps for each cluster; K4-only heatmap.
Implications: Adds `output/tissue_subsampling_k4_heatmap.png` for targeted review.
Notes: Uses continuous K4 proportions without thresholds.
Links: `PLANS/TODO-03.md`.
---

## 2026-02-03 20:10 CST
Decision: Add a K1–K4 heatmap by individual, faceted by location and era, to visualize admixture patterns alongside subsampling-order tests.
Rationale: Supports distinguishing biological structure (consistent location/era patterns) from scattered, isolated admixture changes consistent with contamination.
Options considered: Numeric summaries only; individual-level heatmap without facets; heatmap faceted by location and era.
Implications: Adds `output/tissue_subsampling_admixture_heatmap.png` for visual review alongside permutation metrics.
Notes: Heatmap uses continuous cluster proportions without hard thresholds.
Links: `PLANS/TODO-03.md`.
---

## 2026-02-03 17:44 CST
Decision: Use continuous admixedness metrics (mean adjacent absolute difference, high/low transition rate based on within-group quantiles, and period-2/period-3 correlation patterns) with permutation baselines within each (`date_subsampling`, `subsampler`) group.
Rationale: Avoids hard purity thresholds while still testing for adjacency and periodic signals that would indicate contamination patterns.
Options considered: Binary admixed/pure adjacency tests; fixed thresholds for high/low; continuous metrics with permutation tests.
Implications: Outputs include per-group metrics and permutation-derived p-values; small groups (<3) are flagged as insufficient for periodic checks.
Notes: Metrics are computed on non-missing admixedness values and preserve all records with diagnostics.
Links: `PLANS/TODO-03.md`.
---
