# COMPLETED WORK

Objective: Determine whether cross contamination can explain any of the admixed individuals in `data/och_admixture_values.csv`.

Notes:
- Append only.
- Within each section, list entries in reverse chronological order with date and time stamps.

## 1. Define admixed criteria from `data/och_admixture_values.csv` and produce a reproducible list of admixed and pure individuals.
- 2026-02-03 17:12 CST — Generated continuous admixture summaries from `data/och_admixture_values.csv` using cluster probabilities (no hard thresholds). Outputs: `output/admixture_long.csv`, `output/admixture_metrics.csv`, `output/admixture_summary.csv`, `output/admixture_qc.csv`. Script: `scripts/01_admixture_summary.R`.
- [Plan](PLANS/TODO-01.md)
- [Decision log](DECISIONS_WORK/TODO-01.md)

---

## 2. Build a unified key table that links admixture results to `data/och_extractions_only.xlsx` and `data/Och_SSLibrariesforCapture_metadata.xlsx`, preserving one row per individual and flagging known conflicts.
- 2026-02-03 17:36 CST — Built unified key table and diagnostics linking admixture, extraction, library, and decode mappings. Outputs: `output/admixture_extraction_library_key.csv`, `output/admixture_extraction_library_diagnostics.csv`. Script: `scripts/02_build_key_table.R`.
- [Plan](PLANS/TODO-02.md)
- [Decision log](DECISIONS_WORK/TODO-02.md)

---

## 3. Test tissue subsampling order effects by sorting by `date_subsampling`, `subsampler`, `individual_id` and evaluating adjacency or periodic contamination patterns with permutation baselines.
- 2026-02-03 17:48 CST — Tested tissue subsampling order effects with adjacency and periodic metrics plus permutation baselines. Outputs: `output/tissue_subsampling_adjacency_metrics.csv`, `output/tissue_subsampling_permutation_summary.csv`, `output/tissue_subsampling_permutation_distributions.csv`. Script: `scripts/03_tissue_subsampling_tests.R`.
- [Plan](PLANS/TODO-03.md)
- [Decision log](DECISIONS_WORK/TODO-03.md)

---

## 4. Test extraction order effects by sorting by `date_extracting`, `tube_stuffer`, `individual_id` and evaluating adjacency or periodic contamination patterns with permutation baselines.
- 2026-02-03 18:01 CST — Tested extraction order effects with adjacency and periodic metrics plus permutation baselines. Outputs: `output/extraction_order_adjacency_metrics.csv`, `output/extraction_order_permutation_summary.csv`, `output/extraction_order_permutation_distributions.csv`. Script: `scripts/04_extraction_order_tests.R`.
- [Plan](PLANS/TODO-04.md)
- [Decision log](DECISIONS_WORK/TODO-04.md)

---

## 5. Test extraction plate adjacency effects using `elution[1234]_plateid`, `elution[1234]_row`, `elution[1234]_column` to see whether admixed wells cluster near discordant pure wells.
- 2026-02-04 10:30 CST — Tested extraction plate adjacency patterns using 4-neighbor wells with permutation baselines. Outputs: `output/extraction_plate_adjacency_metrics.csv`, `output/extraction_plate_permutation_summary.csv`, `output/extraction_plate_permutation_distributions.csv`, `output/extraction_plate_diagnostics.csv`, `output/extraction_plate_counts.csv`. Script: `scripts/05_extraction_plate_adjacency.R`.
- [Plan](PLANS/TODO-05.md)
- [Decision log](DECISIONS_WORK/TODO-05.md)

---

## 6. Test library plate adjacency effects using `Library Plate`, `Library plate row`, `Library plate col` from `data/Och_SSLibrariesforCapture_metadata.xlsx`.
- 2026-02-03 21:50 CST — Tested library plate adjacency patterns using 4-neighbor wells with permutation baselines. Outputs: `output/library_plate_adjacency_metrics.csv`, `output/library_plate_permutation_summary.csv`, `output/library_plate_permutation_distributions.csv`, `output/library_plate_diagnostics.csv`, `output/library_plate_counts.csv`, `output/library_plate_admixedness_heatmap.png`, `output/library_plate_k4_heatmap.png`, `output/library_plate_cluster_heatmap.png`, `output/library_plate_admixedness_boxplot.png`. Script: `scripts/06_library_plate_adjacency.R`.
- [Plan](PLANS/TODO-06.md)
- [Decision log](DECISIONS_WORK/TODO-06.md)

---

## 7. Test dilution plate adjacency effects using `Dilution Plate`, `Dilution Plate Row`, `Dilution Plate Col`.
- No entries yet.

---

## 8. Check index integrity within sequencing pools: duplicates of `i5` and `i7` index combinations within the same pool or run.
- No entries yet.

---

## 9. Check seq name integrity within sequencing pools: duplicates of `Test Lane Seq Name`, `NovoGeneSeqID`, `Full seq Name`, and decode names where they should be unique.
- No entries yet.

---

## 10. Verify decode files against metadata for each sequencing run as described in `OBJECTIVES.md` using `data/pire_ostorhinchus_chrysopomus_lcwgs/*/fq_raw/decode_sedlist.txt`.
- No entries yet.

---

## 11. Verify `data/pire_ostorhinchus_chrysopomus_lcwgs/GenErode_Och_20k/data/raw_reads_symlinks/` link naming consistency with original FASTQ names.
- No entries yet.

---

## 12. Summarize evidence across all sources and identify which admixed individuals are plausibly explained by cross contamination.
- No entries yet.
