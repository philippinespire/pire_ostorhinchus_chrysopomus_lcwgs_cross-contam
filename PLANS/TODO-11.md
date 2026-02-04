# TODO 11 Plan

Goal: Verify `data/pire_ostorhinchus_chrysopomus_lcwgs/GenErode_Och_20k/data/raw_reads_symlinks/` link naming consistency with original FASTQ names.

## Inputs
- `data/pire_ostorhinchus_chrysopomus_lcwgs/GenErode_Och_20k/data/raw_reads_symlinks/historical/generode_hist_symlinks.txt`
- `data/pire_ostorhinchus_chrysopomus_lcwgs/GenErode_Och_20k/data/raw_reads_symlinks/modern/generode_cont_symlinks.txt`

## Proposed Steps
1. Parse symlink listings into `link_name` and `target_name` from the `->` mappings.
2. Extract the individual ID from link names (prefix before `_Ex`).
3. Extract the individual ID from target names (prefix before `-Ex`), then normalize by removing `-` and `_`.
4. Compare normalized target IDs to link IDs; flag mismatches.
5. Summarize mismatch counts by era (historical vs modern).

## Outputs
- `output/generode_symlink_mismatch.csv`
- `output/generode_symlink_summary.csv`

## Checks
- Preserve all entries; do not drop mismatches.
- Report example link/target pairs for quick inspection.
