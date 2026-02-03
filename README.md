# Och LCWGS Cross-Contam Testing

This repository contains analysis inputs and scripts for the Och (ostorhinchus_chrysopomus) cross contamination assessment.

## Objective
Determine whether cross contamination can explain any of the admixed individuals in `data/och_admixture_values.csv`. See `OBJECTIVES.md` for full requirements and constraints.

## Data Assumptions
- Each unique sample ID in `data/och_admixture_values.csv` represents a single individual.
- FASTQ files were merged by a student; merge success is uncertain, but admixture values are treated as individual-level data.
- `OcA0102311B` sequences combine two different individuals and cannot be disentangled.
- `OchACat039` sequences are from the same individual and are non-problematic.

## Key Inputs
- `data/och_admixture_values.csv`: individual-level admixture summaries.
- `data/och_extractions_only.xlsx`: extraction metadata and tissue subsampling notes.
- `data/Och_SSLibrariesforCapture_metadata.xlsx`: library construction and sequencing metadata.
- `data/seq_reports/`: sequencing summary spreadsheets from Novogene.
- `data/pire_ostorhinchus_chrysopomus_lcwgs/*/fq_raw/decode_sedlist.txt`: decode mappings for each sequencing run.
- `data/pire_ostorhinchus_chrysopomus_lcwgs/GenErode_Och_20k/data/raw_reads_symlinks/`: captured symlink listings from the GenErode raw reads directory (mirrors the Wahab repo layout).

## Workflow And Tracking
- `TODO.md` contains the current plan.
- `INPROGRESS.md` contains only active work items.
- `COMPLETEDWORK.md` is append-only and logs finished work in reverse chronological order.

## Repo Layout
- `data/`: analysis inputs and external metadata.
- `data/pire_ostorhinchus_chrysopomus_lcwgs/`: mirrors the Wahab repo layout for sequencing runs and GenErode symlink captures.
- `data/seq_reports/`: sequencing output summaries.
- `scripts/`: analysis scripts (when added).
- `output/`: analysis outputs (when generated).

Note: `OBJECTIVES.md` uses the Wahab repo-relative paths; in this repo those assets live under `data/pire_ostorhinchus_chrysopomus_lcwgs/` and `data/`.
