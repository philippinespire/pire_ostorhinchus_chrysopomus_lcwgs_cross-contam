# COMPLETED WORK

Objective: Determine whether cross contamination can explain any of the admixed individuals in `data/och_admixture_values.csv`.

Notes:
- Append only.
- Within each section, list entries in reverse chronological order with date and time stamps.

## 1. Define admixed criteria from `data/och_admixture_values.csv` and produce a reproducible list of admixed and pure individuals.
- 2026-02-03 17:12 CST — Generated continuous admixture summaries from `data/och_admixture_values.csv` using cluster probabilities (no hard thresholds). Outputs: `output/admixture_long.csv`, `output/admixture_metrics.csv`, `output/admixture_summary.csv`, `output/admixture_qc.csv`. Script: `scripts/01_admixture_summary.R`.
- Decision log: `DECISIONS_WORK/TODO-01.md`

---

## 2. Build a unified key table that links admixture results to `data/och_extractions_only.xlsx` and `data/Och_SSLibrariesforCapture_metadata.xlsx`, preserving one row per individual and flagging known conflicts.
- No entries yet.

---

## 3. Test tissue subsampling order effects by sorting by `date_subsampling`, `subsampler`, `individual_id` and evaluating adjacency or periodic contamination patterns with permutation baselines.
- No entries yet.

---

## 4. Test extraction order effects by sorting by `date_extracting`, `tube_stuffer`, `individual_id` and evaluating adjacency or periodic contamination patterns with permutation baselines.
- No entries yet.

---

## 5. Test extraction plate adjacency effects using `elution[1234]_plateid`, `elution[1234]_row`, `elution[1234]_column` to see whether admixed wells cluster near discordant pure wells.
- No entries yet.

---

## 6. Test library plate adjacency effects using `Library Plate`, `Library plate row`, `Library plate col` from `data/Och_SSLibrariesforCapture_metadata.xlsx`.
- No entries yet.

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
