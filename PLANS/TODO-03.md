# TODO 3 Plan

Goal: Test tissue subsampling order effects by sorting by `date_subsampling`, `subsampler`, `individual_id` and evaluating adjacency or periodic contamination patterns with permutation baselines.

## Inputs
- `output/admixture_extraction_library_key.csv`
- `data/och_extractions_only.xlsx`

## Proposed Steps
1. Load extraction metadata and normalize identifiers (`individual_id`, `extraction_id`) into canonical keys (strip `-`/`_`).
2. Join admixture metrics (e.g., `admixedness`, `max_prop`, `dominant_cluster`) from the key table onto the extraction data by canonical individual key.
3. Sort within each (`date_subsampling`, `subsampler`) group by `individual_id` numeric order (extract numeric portion).
4. Define adjacency-based metrics within each group:
   - Neighbor difference in `admixedness` (absolute delta between consecutive individuals).
   - Indicator of high admixedness followed by low (or vice versa) using quantiles, without hard thresholds.
5. Define periodic pattern tests:
   - Compare sequences against alternating (period-2) and period-3 patterns using correlation with synthetic patterns based on `admixedness` ranks.
6. Run permutation baselines within each (`date_subsampling`, `subsampler`) group by shuffling the order and recomputing adjacency/periodic metrics (e.g., 1,000 permutations).
7. Aggregate results across groups and report empirical p-values for observed metrics.
8. Save per-group metrics and permutation distributions for diagnostics.

## Outputs
- `output/tissue_subsampling_adjacency_metrics.csv`
- `output/tissue_subsampling_permutation_summary.csv`
- `output/tissue_subsampling_permutation_distributions.csv`

## Checks
- Report groups with fewer than 3 individuals (insufficient for periodic checks).
- Ensure each individual appears once per group; flag duplicates or missing joins.
- Preserve all records; do not drop unmatched individuals.
