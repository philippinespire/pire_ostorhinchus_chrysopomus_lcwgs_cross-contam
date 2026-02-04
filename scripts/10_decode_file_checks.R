#### SETUP ####
if (dir.exists("r_libs")) {
  .libPaths(c("r_libs", .libPaths()))
}

library(dplyr)
library(readr)
library(readxl)
library(stringr)
library(purrr)
library(tidyr)

output_dir <- file.path("output", "TODO-10")
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

yes_values <- c("yes", "y", "true", "1")

#### LOAD INPUTS ####
metadata_raw <- readxl::read_excel("data/Och_SSLibrariesforCapture_metadata.xlsx")

decode_files <- tibble(
  run_label = c("test_lane", "test_lane_2", "full_lane"),
  file_path = c(
    "data/pire_ostorhinchus_chrysopomus_lcwgs/2nd_sequencing_run/fq_raw/decode_sedlist.txt",
    "data/pire_ostorhinchus_chrysopomus_lcwgs/3rd_sequencing_run/fq_raw/decode_sedlist.txt",
    "data/pire_ostorhinchus_chrysopomus_lcwgs/4th_sequencing_run/fq_raw/decode_sedlist.txt"
  )
)

#### PARSE DECODE FILES ####
parse_decode <- function(path, run_label) {
  lines <- readr::read_lines(path)
  matches <- stringr::str_match(lines, "^s/([^/]+)/([^/]+)/")
  tibble(
    run_label = run_label,
    file_path = path,
    decode_first = matches[, 2],
    decode_second = matches[, 3]
  ) %>%
    filter(
      !is.na(decode_first),
      !is.na(decode_second),
      !(decode_first == "Sequence" & decode_second == "Extraction_ID")
    )
}

decode_entries <- 
  decode_files %>%
  mutate(entries = purrr::map2(file_path, run_label, parse_decode)) %>%
  select(entries) %>%
  unnest(entries) %>%
  mutate(pair_key = paste(decode_first, decode_second, sep = "|"))

#### BUILD EXPECTED PAIRS ####
metadata <- 
  metadata_raw %>%
  transmute(
    pool_round = `Pool Round`,
    in_full_lane = `Pool for full seq?`,
    novogene_seq_id = NovoGeneSeqID,
    sequence_id = Sequence_ID,
    full_seq_name = `Full seq Name`,
    full_seq_decode = `Full seq decode`
  ) %>%
  mutate(
    pool_round_lower = str_to_lower(as.character(pool_round)),
    in_full_lane_flag = str_to_lower(as.character(in_full_lane)) %in% yes_values
  )

expected_test_lane <- 
  metadata %>%
  filter(pool_round_lower == "test lane") %>%
  transmute(
    run_label = "test_lane",
    expected_first = novogene_seq_id,
    expected_second = sequence_id
  )

expected_test_lane_2 <- 
  metadata %>%
  filter(pool_round_lower == "test lane 2") %>%
  transmute(
    run_label = "test_lane_2",
    expected_first = novogene_seq_id,
    expected_second = sequence_id
  )

expected_full_lane <- 
  metadata %>%
  filter(in_full_lane_flag) %>%
  transmute(
    run_label = "full_lane",
    expected_first = full_seq_name,
    expected_second = full_seq_decode
  )

expected_pairs <- 
  bind_rows(expected_test_lane, expected_test_lane_2, expected_full_lane) %>%
  filter(!is.na(expected_first), !is.na(expected_second)) %>%
  mutate(pair_key = paste(expected_first, expected_second, sep = "|"))

#### COMPARE DECODE VS EXPECTED ####
unmatched_decode <- 
  decode_entries %>%
  anti_join(
    expected_pairs,
    by = c("run_label", "pair_key")
  )

missing_expected <- 
  expected_pairs %>%
  anti_join(
    decode_entries %>% select(run_label, pair_key),
    by = c("run_label", "pair_key")
  )

comparison_summary <- 
  decode_entries %>%
  group_by(run_label, file_path) %>%
  summarise(
    n_decode_pairs = n_distinct(pair_key),
    .groups = "drop"
  ) %>%
  left_join(
    expected_pairs %>%
      group_by(run_label) %>%
      summarise(n_expected_pairs = n_distinct(pair_key), .groups = "drop"),
    by = "run_label"
  ) %>%
  left_join(
    unmatched_decode %>%
      group_by(run_label) %>%
      summarise(n_unmatched_decode = n_distinct(pair_key), .groups = "drop"),
    by = "run_label"
  ) %>%
  left_join(
    missing_expected %>%
      group_by(run_label) %>%
      summarise(n_missing_expected = n_distinct(pair_key), .groups = "drop"),
    by = "run_label"
  ) %>%
  mutate(
    n_expected_pairs = replace_na(n_expected_pairs, 0),
    n_unmatched_decode = replace_na(n_unmatched_decode, 0),
    n_missing_expected = replace_na(n_missing_expected, 0)
  )

#### EXPORT OUTPUTS ####
readr::write_csv(
  unmatched_decode,
  file.path(output_dir, "decode_file_unmatched_decode_entries.csv")
)
readr::write_csv(
  missing_expected,
  file.path(output_dir, "decode_file_missing_expected_entries.csv")
)
readr::write_csv(
  comparison_summary,
  file.path(output_dir, "decode_file_comparison_summary.csv")
)
