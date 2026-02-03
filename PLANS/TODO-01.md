# TODO 1 Plan

Goal: Summarize admixture data into reusable continuous metrics without hard pure/admixed thresholds.

## Inputs
- `data/och_admixture_values.csv`

## Proposed Steps
1. Load admixture data and standardize sample identifiers.
2. Reshape to long format with `cluster` and `prop` columns.
3. Produce a wide table with one row per individual and K1–K4 probabilities.
4. Calculate continuous metrics (max cluster probability, admixedness, entropy, effective clusters).
5. Generate QC summaries (prop sum, cluster count per individual).
6. Save outputs for downstream joins.

## Outputs
- `output/admixture_long.csv`
- `output/admixture_metrics.csv`
- `output/admixture_summary.csv`
- `output/admixture_qc.csv`

## Checks
- Ensure each individual has four cluster entries.
- Confirm probability sums are near 1 with small residuals.
