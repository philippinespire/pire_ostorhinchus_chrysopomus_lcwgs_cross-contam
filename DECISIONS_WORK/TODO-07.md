# TODO-07 Decisions

## 2026-02-03 21:45 CST
Decision: Mirror the library-plate adjacency workflow for dilution plates using 4-neighbor adjacency metrics with within-plate permutations.
Rationale: Keeps dilution-plate tests comparable to library and extraction plate analyses without thresholds.
Options considered: Adjacency metrics only; include periodic metrics; focus on spatial adjacency with permutations.
Implications: Outputs include per-plate metrics, empirical p-values, and diagnostics.
Notes: Adjacency uses 4-neighbor (up/down/left/right) wells on each plate.
Links: `PLANS/TODO-07.md`.
---

## 2026-02-03 21:45 CST
Decision: Generate dilution plate visualizations (admixedness, K4 affiliation, dominant cluster heatmaps, and per-plate admixedness boxplot).
Rationale: Plate-layout plots help identify spatial mixing patterns that could indicate contamination.
Options considered: Metrics only; heatmaps only; heatmaps plus boxplot summaries.
Implications: Adds four PNG outputs for visual inspection alongside permutation results.
Notes: K4 heatmap uses orange-to-blue gradient (#FC8D62 to #8DA0CB).
Links: `PLANS/TODO-07.md`.
---
