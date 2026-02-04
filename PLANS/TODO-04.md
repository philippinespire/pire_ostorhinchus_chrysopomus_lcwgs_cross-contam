# TODO 4 Plan

Goal: Test extraction order effects by sorting by `date_extracting`, `tube_stuffer`, `individual_id` and evaluating adjacency or periodic contamination patterns with permutation baselines.

## Inputs
- `output/admixture_extraction_library_key.csv`
- `data/och_extractions_only.xlsx`

## Proposed Steps
1. Load extraction metadata and normalize identifiers (`individual_id`, `extraction_id`) into canonical keys (strip `-`/`_`).
2. Join admixture metrics (`admixedness`, `max_prop`, `dominant_cluster`) from the key table onto the extraction data by canonical individual key.
3. Sort within each (`date_extracting`, `tube_stuffer`) group by `individual_id` numeric order (extract numeric portion).
4. Compute adjacency metrics within each group:
   - Neighbor absolute differences in `admixedness`.
   - High/low transition rate based on within-group quantiles.
5. Compute periodic pattern metrics:
   - Correlation with alternating (period-2) and period-3 patterns using `admixedness` ranks.
6. Generate permutation baselines within each group by shuffling order (e.g., 1,000 permutations) and recomputing metrics.
7. Aggregate observed vs permutation metrics with empirical p-values.
8. Save per-group metrics and permutation distributions for diagnostics.

## Outputs
- `output/extraction_order_adjacency_metrics.csv`
- `output/extraction_order_permutation_summary.csv`
- `output/extraction_order_permutation_distributions.csv`

## Checks
- Report groups with fewer than 3 individuals (insufficient for periodic checks).
- Flag missing admixture joins; do not drop unmatched individuals.
- Preserve all records and document counts per group.
