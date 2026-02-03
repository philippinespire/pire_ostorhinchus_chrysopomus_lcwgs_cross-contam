# Output Files

This directory contains generated analysis outputs. Sections are organized by TODO.

**TODO 1**
Outputs from admixture summarization using continuous metrics.
- `admixture_long.csv`: long-format admixture table with one row per sample and cluster.
- `admixture_metrics.csv`: per-sample metrics including `max_prop`, `admixedness`, entropy, and effective clusters.
- `admixture_summary.csv`: wide-format K1–K4 probabilities joined to summary metrics.
- `admixture_qc.csv`: QC checks for cluster counts and probability sums.

**TODO 2**
Outputs from linking admixture, extraction, library, and decode metadata.
- `admixture_extraction_library_key.csv`: unified key table with joined identifiers and flags.
- `admixture_extraction_library_diagnostics.csv`: diagnostics for unmatched joins and decode mismatches.

**TODO 3**
Outputs from tissue subsampling order tests.
- `tissue_subsampling_adjacency_metrics.csv`: per-group adjacency and periodic metrics.
- `tissue_subsampling_permutation_summary.csv`: permutation-based summaries and p-values.
- `tissue_subsampling_permutation_distributions.csv`: full permutation distributions per group.
