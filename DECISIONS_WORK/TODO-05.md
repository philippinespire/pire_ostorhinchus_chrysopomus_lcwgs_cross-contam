# TODO-05 Decisions

## 2026-02-03 20:58 CST
Decision: Add extraction-plate visualizations (admixedness heatmap, dominant-cluster heatmap, and per-plate admixedness boxplot).
Rationale: Plate-layout heatmaps directly highlight spatial patterns that may reflect contamination, while the boxplot summarizes overall admixedness distributions per plate.
Options considered: Metrics only; heatmap only; heatmap plus distribution summary.
Implications: Adds three PNG outputs for visual inspection alongside permutation results.
Notes: Heatmaps mirror plate coordinates and are faceted by plate.
Links: `PLANS/TODO-05.md`.
---

## 2026-02-03 18:10 CST
Decision: Use plate-neighbor adjacency metrics (mean/median absolute `admixedness` differences and dominant-cluster mismatch rate) with within-plate permutation baselines.
Rationale: Plate adjacency is spatial, so neighbor-based metrics directly test whether admixedness or cluster assignments are locally non-random without hard thresholds.
Options considered: Global plate clustering statistics; threshold-based adjacency; continuous adjacency with permutations.
Implications: Outputs include per-plate metrics and empirical p-values, plus diagnostics for missing or duplicate wells.
Notes: Adjacency uses 4-neighbor (up/down/left/right) wells on each plate.
Links: `PLANS/TODO-05.md`.
---
