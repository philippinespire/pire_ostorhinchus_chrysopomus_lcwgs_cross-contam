# Project Instructions

## Scope
- This repository contains analysis inputs and scripts for the Och (ostorhinchus_chrysopomus) project.
- Full objective details (authored by cbird) are documented in `OBJECTIVES.md`.

## Data Assumptions
- In `data/och_admixture_values.csv`, each unique sample ID represents a single individual.
- The FASTQ files were merged by a student; merge success is uncertain, but the admixture table should still be treated as individual-level data.

## Decode Conflicts
- `OcA0102311B` sequences combine two different individuals and cannot be disentangled.
- `OchACat039` sequences are from the same individual; treat as non-problematic.

## Guidance For Future Edits
- Do not change data handling logic without explicitly discussing assumptions above.
- Prefer adding diagnostics over dropping records when conflicts are detected.
- Follow the data organization principles in:
  `https://github.com/tamucc-comp-bio/how_to/blob/main/howto_organize_data.md`
- Use descriptive file and column names that are easy to interpret.

## Planning And Tracking
- Keep the current objective plan in `TODO.md`.
- When starting work on a plan item, add it to `INPROGRESS.md` and keep that file updated with active work only.
- When a todo is finished, append a dated entry to `COMPLETEDWORK.md` in reverse chronological order (newest first).
- Record decision logic and work rationale in `DECISIONS_WORK/TODO-XX.md` using reverse-chronological, timestamped entries.
- Before starting each TODO, create a plan in `PLANS/TODO-XX.md` and link it in `COMPLETEDWORK.md`.

## R Workflow Preferences
- Prefer R for analysis work.
- Use tidyverse-style pipelines where possible.
- Avoid modifying the same data container repeatedly; use unrolled pipeline style.
- Never save a data container into itself.
- Document code and break scripts into collapsable sections using `#### SECTION NAME ####` notation.
- When a pipe starts after assignment, place a line break right after `<- `.
