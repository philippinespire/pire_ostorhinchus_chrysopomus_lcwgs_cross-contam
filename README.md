# Och LCWGS Cross-Contam Testing

This repository contains analysis inputs and scripts for the Och (ostorhinchus_chrysopomus) cross contamination assessment.

## Objective
Determine whether cross contamination can explain any of the admixed individuals in `och_admixture_values.csv`. See `OBJECTIVES.md` for full requirements and constraints.

## Data Assumptions
- Each unique sample ID in `och_admixture_values.csv` represents a single individual.
- FASTQ files were merged by a student; merge success is uncertain, but admixture values are treated as individual-level data.
- `OcA0102311B` sequences combine two different individuals and cannot be disentangled.
- `OchACat039` sequences are from the same individual and are non-problematic.

## Key Inputs
- `och_admixture_values.csv`: individual-level admixture summaries.
- `och_extractions_only.xlsx`: extraction metadata and tissue subsampling notes.
- `Och_SSLibrariesforCapture_metadata.xlsx`: library construction and sequencing metadata.
- `seq_reports/`: sequencing summary spreadsheets from Novogene.
- `*/fq_raw/decode_sedlist.txt`: decode mappings for each sequencing run.
- `generode_symlinks/`: captured symlink listings from the GenErode raw reads directory.

## Workflow And Tracking
- `TODO.md` contains the current plan.
- `INPROGRESS.md` contains only active work items.
- `COMPLETEDWORK.md` is append-only and logs finished work in reverse chronological order.

## Repo Layout
- `1st_sequencing_run/`: first test lane decode files.
- `2nd_sequencing_run/`: primary test lane decode files.
- `3rd_sequencing_run/`: test lane 2 decode files.
- `4th_sequencing_run/`: full lane decode files.
- `seq_reports/`: sequencing output summaries.
- `generode_symlinks/`: GenErode symlink listing captures.
