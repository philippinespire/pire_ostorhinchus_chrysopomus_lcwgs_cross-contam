# TODO 2 Plan

Goal: Build a unified key table that links admixture results to `data/och_extractions_only.xlsx` and `data/Och_SSLibrariesforCapture_metadata.xlsx`, preserving one row per individual and flagging known conflicts.

## Inputs
- `output/admixture_summary.csv` (from TODO #1)
- `data/och_extractions_only.xlsx`
- `data/Och_SSLibrariesforCapture_metadata.xlsx`

## Proposed Steps
1. Inspect column names and key identifiers in the extraction and library metadata files.
2. Parse `sample_id` from `output/admixture_summary.csv` into components (species code, era code, location code, individual id).
3. Derive a canonical individual key (e.g., `species + era + location + individual_id`) to use across all tables.
4. Create extraction metadata key(s) based on `individual_id` (and other available identifiers) while keeping all records.
5. Create library metadata key(s) based on `Extraction_ID`, `Library_id`, and any individual-level identifiers.
6. Join admixture to extraction metadata using the canonical individual key; summarize any one-to-many relationships without dropping rows.
7. Join the result to library metadata using `Extraction_ID` when available, otherwise fall back to individual key with clear diagnostics.
8. Flag known conflicts (`OcA0102311B`, `OchACat039`) and any mismatched or missing joins.
9. Produce a unified key table plus a diagnostics table of join outcomes.

## Outputs
- `output/admixture_extraction_library_key.csv` (one row per individual with join fields)
- `output/admixture_extraction_library_diagnostics.csv` (join counts, unmatched records, conflicts)

## Checks
- Confirm each individual has exactly 4 cluster probability rows before aggregation.
- Report any individuals with missing extraction or library metadata.
- Preserve all records; do not drop unmatched rows.
