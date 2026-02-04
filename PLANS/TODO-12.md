# TODO 12 Plan

Goal: Summarize evidence across all sources and identify which admixed individuals are plausibly explained by cross contamination.

## Inputs
- `output/TODO-01/admixture_summary.csv`
- `output/TODO-02/admixture_extraction_library_key.csv`
- `output/TODO-03/tissue_subsampling_permutation_summary.csv`
- `output/TODO-04/extraction_order_permutation_summary.csv`
- `output/TODO-05/extraction_plate_permutation_summary.csv`
- `output/TODO-06/library_plate_permutation_summary.csv`
- `output/TODO-07/dilution_plate_permutation_summary.csv`
- `output/TODO-08/index_pair_duplicate_summary.csv`
- `output/TODO-09/seq_name_duplicate_summary.csv`
- `output/TODO-10/decode_file_unmatched_decode_entries.csv`
- `output/TODO-10/decode_file_missing_expected_entries.csv`
- `output/TODO-11/generode_symlink_mismatch.csv`
- `data/och_extractions_only.xlsx`
- `data/Och_SSLibrariesforCapture_metadata.xlsx`

## Proposed Steps
1. Build a per-individual base table with admixture metrics (K2–K4, `admixedness`, `dominant_cluster`) and stable keys.
2. Derive evidence flags for each contamination source (tissue/extraction order, extraction/library/dilution plates, index duplicates, seq name duplicates, decode mismatches, symlink mismatches) by mapping individuals to flagged groups/pools/plates.
3. Aggregate evidence into per-individual summaries (flag counts, evidence sources, admixedness ranks) without hard purity thresholds.
4. Export full evidence tables and a candidate list sorted by admixedness with evidence flags.
5. Document outputs in `output/TODO-12/README.md` and update `output/README.md` + `scripts/README.md`.

## Outputs
- `scripts/12_contamination_evidence_summary.R`
- `output/TODO-12/contamination_evidence_by_individual.csv`
- `output/TODO-12/contamination_evidence_candidates.csv`
- `output/TODO-12/contamination_evidence_summary.csv`
- `output/TODO-12/README.md`

## Checks
- Keep admixture as continuous (no hard purity threshold).
- Preserve all individuals; add evidence flags rather than dropping records.
- Do not modify `data/` files.
