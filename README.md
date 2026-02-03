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

```
.
├── AGENTS.md
├── OBJECTIVES.md
├── README.md
├── TODO.md
├── data
│   ├── och_admixture_values.csv
│   ├── och_extractions_only.xlsx
│   ├── Och_SSLibrariesforCapture_metadata.xlsx
│   ├── seq_reports
│   │   ├── PIRE-Adu-Och-Sde-Sin_December2024_SeqSummary.xlsx
│   │   ├── PIRE-Cha-Och-TestLane_SeqSummary.xlsx
│   │   ├── PIRE_Och-TestLane2_SeqSummary.xlsx
│   │   └── README.md
│   └── pire_ostorhinchus_chrysopomus_lcwgs
│       ├── 1st_sequencing_run
│       │   └── fq_raw
│       │       ├── decode_sedlist.txt
│       │       └── README.md
│       ├── 2nd_sequencing_run
│       │   └── fq_raw
│       │       ├── decode_sedlist.txt
│       │       └── README.md
│       ├── 3rd_sequencing_run
│       │   └── fq_raw
│       │       ├── decode_sedlist.txt
│       │       └── README.md
│       ├── 4th_sequencing_run
│       │   └── fq_raw
│       │       ├── decode_sedlist.txt
│       │       └── README.md
│       └── GenErode_Och_20k
│           └── data
│               └── raw_reads_symlinks
│                   ├── historical
│                   │   └── generode_hist_symlinks.txt
│                   └── modern
│                       └── generode_cont_symlinks.txt
├── output
└── scripts
```

