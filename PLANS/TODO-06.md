# TODO 6 Plan

Goal: Test library plate adjacency effects using `Library Plate`, `Library plate row`, `Library plate col` to see whether admixed wells cluster near wells from different genetic groups.

## Inputs
- `output/admixture_extraction_library_key.csv`
- `data/Och_SSLibrariesforCapture_metadata.xlsx`

## Proposed Steps
1. Load library metadata and normalize identifiers (`individual_id`, `extraction_id`, `library_id`) into canonical keys (strip `-`/`_`).
2. Join admixture metrics (`admixedness`, `dominant_cluster`, `K2`, `K3`, `K4`) from the key table onto library metadata by canonical individual key.
3. Standardize library plate coordinates (row letter to index, column to integer) and create a `plate_key` (e.g., `Library Plate`).
4. Flag missing/duplicate wells; preserve all records with diagnostics rather than dropping.
5. For each library plate, compute adjacency metrics based on 4-neighbor wells:
   - Mean/median absolute differences in `admixedness` between adjacent wells.
   - Dominant cluster mismatch rate between adjacent wells.
6. Generate permutation baselines by shuffling `admixedness` and `dominant_cluster` within each plate and recomputing metrics.
7. Aggregate observed vs permutation metrics with empirical p-values per plate.
8. Generate plate-layout heatmaps:
   - Admixedness heatmap (continuous).
   - K4 affiliation heatmap (orange-to-blue gradient).
   - Dominant cluster heatmap.
   - Admixedness boxplot per plate.
9. Save per-plate metrics, permutation summaries/distributions, diagnostics, and plots.

## Outputs
- `output/library_plate_adjacency_metrics.csv`
- `output/library_plate_permutation_summary.csv`
- `output/library_plate_permutation_distributions.csv`
- `output/library_plate_diagnostics.csv`
- `output/library_plate_counts.csv`
- `output/library_plate_admixedness_heatmap.png`
- `output/library_plate_k4_heatmap.png`
- `output/library_plate_cluster_heatmap.png`
- `output/library_plate_admixedness_boxplot.png`

## Checks
- Report plates with fewer than 2 wells (insufficient adjacency).
- Flag missing coordinates or duplicated wells; do not drop unmatched individuals.
- Preserve all records and document counts per plate.
