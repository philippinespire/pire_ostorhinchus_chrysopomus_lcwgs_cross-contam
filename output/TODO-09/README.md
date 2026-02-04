# TODO 9 Results

Outputs from sequence name integrity checks within sequencing pools and runs.
- [seq_name_duplicates_by_pool.csv](seq_name_duplicates_by_pool.csv): detailed duplicate sequencing names within each pool.
- [seq_name_duplicate_summary.csv](seq_name_duplicate_summary.csv): summary of duplicates and missing sequencing name values by pool and by run.

Interpretation:
- Use [seq_name_duplicates_by_pool.csv](seq_name_duplicates_by_pool.csv) to identify pools where multiple libraries share the same sequencing name or ID.
- [seq_name_duplicate_summary.csv](seq_name_duplicate_summary.csv) reports pool-level and run-level duplicate counts and highlights missing sequencing name values that need follow-up.
