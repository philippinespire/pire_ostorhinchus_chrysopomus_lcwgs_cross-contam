# TODO 5 Plan

Goal: Test extraction plate adjacency effects using `elution[1234]_plateid`, `elution[1234]_row`, `elution[1234]_column` to see whether admixed wells cluster near wells from different genetic groups.

## Inputs
- `output/admixture_extraction_library_key.csv`
- `data/och_extractions_only.xlsx`

## Proposed Steps
1. Load extraction metadata and normalize identifiers (`individual_id`, `extraction_id`) into canonical keys (strip `-`/`_`).
2. Join admixture metrics (`admixedness`, `dominant_cluster`) from the key table onto extraction metadata by canonical individual key.
3. Reshape elution plate fields into a long table with one row per elution well (`elution1`–`elution4`).
4. Standardize plate coordinates (row letter to index, column to integer) and flag missing/duplicate wells.
5. For each plate, compute adjacency metrics based on 4-neighbor wells:
   - Mean/median absolute differences in `admixedness` between adjacent wells.
   - Dominant cluster mismatch rate between adjacent wells.
6. Generate permutation baselines by shuffling `admixedness` and `dominant_cluster` within each plate and recomputing metrics.
7. Aggregate observed vs permutation metrics with empirical p-values per plate.
8. Save per-plate metrics, permutation summaries, distributions, and diagnostics.

## Outputs
- `output/extraction_plate_adjacency_metrics.csv`
- `output/extraction_plate_permutation_summary.csv`
- `output/extraction_plate_permutation_distributions.csv`
- `output/extraction_plate_diagnostics.csv`

## Checks
- Report plates with fewer than 2 wells (insufficient adjacency).
- Flag missing coordinates or duplicated wells; do not drop unmatched individuals.
- Preserve all records and document counts per plate.
