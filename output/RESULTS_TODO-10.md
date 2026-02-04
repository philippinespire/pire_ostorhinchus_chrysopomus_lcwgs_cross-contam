# TODO 10 Results

Outputs from decode file checks against metadata.
- [decode_file_unmatched_decode_entries.csv](TODO-10/decode_file_unmatched_decode_entries.csv): decode entries not found in metadata expectations.
- [decode_file_missing_expected_entries.csv](TODO-10/decode_file_missing_expected_entries.csv): expected metadata pairs missing from decode files.
- [decode_file_comparison_summary.csv](TODO-10/decode_file_comparison_summary.csv): per-run counts of decode vs expected pairs and mismatches.

Interpretation:
- Use [decode_file_comparison_summary.csv](TODO-10/decode_file_comparison_summary.csv) to identify runs with mismatches.
- Review [decode_file_unmatched_decode_entries.csv](TODO-10/decode_file_unmatched_decode_entries.csv) and [decode_file_missing_expected_entries.csv](TODO-10/decode_file_missing_expected_entries.csv) to trace specific discrepancies.
