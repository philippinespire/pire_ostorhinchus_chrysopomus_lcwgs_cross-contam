# TODO 10 Plan

Goal: Verify decode files against metadata for each sequencing run as described in `OBJECTIVES.md`.

## Inputs
- `data/Och_SSLibrariesforCapture_metadata.xlsx`
- `data/pire_ostorhinchus_chrysopomus_lcwgs/2nd_sequencing_run/fq_raw/decode_sedlist.txt`
- `data/pire_ostorhinchus_chrysopomus_lcwgs/3rd_sequencing_run/fq_raw/decode_sedlist.txt`
- `data/pire_ostorhinchus_chrysopomus_lcwgs/4th_sequencing_run/fq_raw/decode_sedlist.txt`

## Proposed Steps
1. Parse each `decode_sedlist.txt` file into pairs (`decode_first`, `decode_second`) from `s/first/second/` lines.
2. Build expected pairs from metadata:
   - Test Lane: `Pool Round = Test Lane` and compare `NovoGeneSeqID` (CE) to `Sequence_ID` (CF).
   - Test Lane 2: `Pool Round = Test Lane 2` and compare `NovoGeneSeqID` (CE) to `Sequence_ID` (CF).
   - Full lane: `Pool for full seq? = Yes` and compare `Full seq Name` (CM) to `Full seq decode` (CN).
3. For each run, identify:
   - Decode entries not found in metadata (unexpected).
   - Expected pairs missing from decode files.
4. Summarize counts per run.

## Outputs
- `output/decode_file_unmatched_decode_entries.csv`
- `output/decode_file_missing_expected_entries.csv`
- `output/decode_file_comparison_summary.csv`

## Checks
- Preserve all entries; do not drop mismatches.
- Report run labels and decode file paths with each discrepancy.
