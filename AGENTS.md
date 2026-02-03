# Project Instructions

## Scope
- This repository contains analysis inputs and scripts for the Och (ostorhinchus_chrysopomus) project.
- Default working directory: `/mnt/c/Users/cbird/OneDrive - Texas A&M University-Corpus Christi/!students/Ty_Burris_Thesis/Data Analysis/Och`.

## Data Assumptions
- In `och_admixture_values.csv`, each unique sample ID represents a single individual.
- The FASTQ files were merged by a student; merge success is uncertain, but the admixture table should still be treated as individual-level data.

## Decode Conflicts
- `OcA0102311B` sequences combine two different individuals and cannot be disentangled.
- `OchACat039` sequences are from the same individual; treat as non-problematic.

## Guidance For Future Edits
- Do not change data handling logic without explicitly discussing assumptions above.
- Prefer adding diagnostics over dropping records when conflicts are detected.
