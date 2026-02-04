# TODO 8 Plan

Goal: Check index integrity within sequencing pools to identify duplicate `i5` + `i7` index combinations among libraries sequenced together.

## Inputs
- `output/admixture_extraction_library_key.csv`
- `data/Och_SSLibrariesforCapture_metadata.xlsx`

## Proposed Steps
1. Load library metadata and normalize identifiers (`individual_id`, `extraction_id`, `library_id`) into canonical keys (strip `-`/`_`).
2. Extract index fields: `i5 Primer`, `i5 Index for Novogene`, `i7 Primer`, `i7 Index`.
3. Build pool membership for each sequencing context:
   - Test lane: `Pool for lcwgs test? = Yes` and group by `TestLanePool` (column BF).
   - Test lane 2: `Pool Round = Test Lane 2` and group by `TestLanePool`.
   - Full lane: `Pool for full seq? = Yes` and group by `Pool` (column CL).
   - Include `Pool Round` to map pools to runs.
4. For each pool, detect duplicate index pairs:
   - Primary key: (`i5 Index for Novogene`, `i7 Index`).
   - Report counts and which libraries share a duplicate combination.
5. Summarize duplicates across all pools and flag pools with any duplicates.
6. Save detailed and summary reports without dropping any records.

## Outputs
- `output/index_pair_duplicates_by_pool.csv`
- `output/index_pair_duplicate_summary.csv`

## Checks
- Report missing index values separately (do not drop).
- Preserve all rows and document counts per pool/run.
