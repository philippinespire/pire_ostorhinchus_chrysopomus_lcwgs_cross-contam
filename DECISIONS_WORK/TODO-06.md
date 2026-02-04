# TODO-06 Decisions

## 2026-02-03 21:35 CST
Decision: Mirror the extraction-plate adjacency workflow for library plates using 4-neighbor adjacency metrics with within-plate permutations.
Rationale: Maintains methodological consistency while targeting the library plate handling step.
Options considered: Use only adjacency metrics; include periodic metrics; focus on spatial (plate) adjacency with permutations.
Implications: Outputs include per-plate metrics, empirical p-values, and diagnostics without hard thresholds.
Notes: Adjacency uses 4-neighbor (up/down/left/right) wells on each plate.
Links: `PLANS/TODO-06.md`.
---

## 2026-02-03 21:35 CST
Decision: Generate library plate visualizations (admixedness, K4 affiliation, dominant cluster heatmaps, and per-plate admixedness boxplot).
Rationale: Plate-layout plots help identify spatial mixing patterns that could indicate contamination.
Options considered: Metrics only; heatmaps only; heatmaps plus boxplot summaries.
Implications: Adds four PNG outputs for visual inspection alongside permutation results.
Notes: K4 heatmap uses orange-to-blue gradient (#FC8D62 to #8DA0CB).
Links: `PLANS/TODO-06.md`.
---
