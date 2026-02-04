# TODO 9 Plan

Goal: Check sequence name integrity within sequencing pools by finding duplicate `Test Lane Seq Name`, `NovoGeneSeqID`, `Full seq Name`, and decode names where they should be unique.

## Inputs
- `output/admixture_extraction_library_key.csv`
- `data/Och_SSLibrariesforCapture_metadata.xlsx`

## Proposed Steps
1. Load library metadata and normalize identifiers (`individual_id`, `extraction_id`, `library_id`) into canonical keys (strip `-`/`_`).
2. Extract sequencing name fields:
   - Test lane: `Test Lane Seq Name`, `NovoGeneSeqID`, `Sequence_ID`.
   - Full lane: `Full seq Name`, `Full seq decode`.
3. Build pool/run membership:
   - Test lane: `Pool for lcwgs test? = Yes`, group by `TestLanePool`, and retain `Pool Round` (Test Lane vs Test Lane 2).
   - Full lane: `Pool for full seq? = Yes`, group by `Pool`, retain `Pool Round`.
4. For each pool/run, identify duplicates for each name field:
   - Count duplicates of `Test Lane Seq Name` and `NovoGeneSeqID` within test lane pools/runs.
   - Count duplicates of `Full seq Name` and `Full seq decode` within full lane pools/runs.
5. Summarize duplicates across pools and runs and flag any pools with repeated names.
6. Save detailed duplicate tables and summary tables without dropping any records.

## Outputs
- `output/seq_name_duplicates_by_pool.csv`
- `output/seq_name_duplicate_summary.csv`

## Checks
- Report missing name values separately (do not drop).
- Preserve all rows and document counts per pool/run.
