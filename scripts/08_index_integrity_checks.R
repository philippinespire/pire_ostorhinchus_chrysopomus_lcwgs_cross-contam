#### SETUP ####
if (dir.exists("r_libs")) {
  .libPaths(c("r_libs", .libPaths()))
}

library(dplyr)
library(readr)
library(readxl)
library(stringr)
library(tidyr)

output_dir <- "output"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

yes_values <- c("yes", "y", "true", "1")

#### LOAD INPUTS ####
library_raw <- readxl::read_excel("data/Och_SSLibrariesforCapture_metadata.xlsx")

#### BUILD BASE TABLE ####
library_base <- 
  library_raw %>%
  transmute(
    individual_id = Individual_ID,
    extraction_id = Extraction_ID,
    library_id = Library_id,
    pool_round = `Pool Round`,
    test_lane_pool = TestLanePool,
    full_lane_pool = Pool,
    in_test_lane = `Pool for lcwgs test?`,
    in_full_lane = `Pool for full seq?`,
    i5_primer = `i5 Primer`,
    i5_index = `i5 Index for Novogene`,
    i7_primer = `i7 Primer`,
    i7_index = `i7 Index`,
    sequence_id = Sequence_ID,
    test_lane_seq_name = `Test Lane Seq Name`,
    novogene_seq_id = NovoGeneSeqID,
    full_seq_name = `Full seq Name`,
    full_seq_decode = `Full seq decode`,
    individual_key = stringr::str_replace_all(individual_id, "[-_]", "")
  ) %>%
  mutate(
    pool_round_lower = str_to_lower(as.character(pool_round)),
    in_test_lane_flag = str_to_lower(as.character(in_test_lane)) %in% yes_values,
    in_full_lane_flag = str_to_lower(as.character(in_full_lane)) %in% yes_values,
    run_type = case_when(
      str_detect(pool_round_lower, "test lane 2") ~ "test_lane_2",
      str_detect(pool_round_lower, "test lane") ~ "test_lane",
      str_detect(pool_round_lower, "full") ~ "full_lane",
      in_full_lane_flag ~ "full_lane",
      in_test_lane_flag ~ "test_lane",
      TRUE ~ NA_character_
    ),
    pool_id = case_when(
      run_type %in% c("test_lane", "test_lane_2") ~ as.character(test_lane_pool),
      run_type == "full_lane" ~ as.character(full_lane_pool),
      TRUE ~ NA_character_
    ),
    index_pair = if_else(
      is.na(i5_index) | is.na(i7_index),
      NA_character_,
      paste(i5_index, i7_index, sep = "|")
    ),
    run_key = case_when(
      !is.na(pool_round) & as.character(pool_round) != "" ~ paste(run_type, pool_round, sep = "|"),
      !is.na(run_type) ~ run_type,
      TRUE ~ NA_character_
    )
  )

#### DUPLICATES BY POOL ####
pool_duplicates <- 
  library_base %>%
  filter(!is.na(run_type), !is.na(pool_id), !is.na(index_pair)) %>%
  group_by(run_type, pool_round, pool_id, index_pair) %>%
  summarise(
    n_libraries = n(),
    library_ids = paste(unique(library_id), collapse = ";"),
    individual_ids = paste(unique(individual_id), collapse = ";"),
    extraction_ids = paste(unique(extraction_id), collapse = ";"),
    sequence_ids = paste(unique(sequence_id), collapse = ";"),
    test_lane_seq_names = paste(unique(test_lane_seq_name), collapse = ";"),
    novogene_seq_ids = paste(unique(novogene_seq_id), collapse = ";"),
    full_seq_names = paste(unique(full_seq_name), collapse = ";"),
    full_seq_decodes = paste(unique(full_seq_decode), collapse = ";"),
    .groups = "drop"
  ) %>%
  filter(n_libraries > 1)

#### DUPLICATES BY RUN ####
run_duplicates <- 
  library_base %>%
  filter(!is.na(run_key), !is.na(index_pair)) %>%
  group_by(run_type, pool_round, run_key, index_pair) %>%
  summarise(
    n_libraries = n(),
    library_ids = paste(unique(library_id), collapse = ";"),
    individual_ids = paste(unique(individual_id), collapse = ";"),
    extraction_ids = paste(unique(extraction_id), collapse = ";"),
    sequence_ids = paste(unique(sequence_id), collapse = ";"),
    test_lane_seq_names = paste(unique(test_lane_seq_name), collapse = ";"),
    novogene_seq_ids = paste(unique(novogene_seq_id), collapse = ";"),
    full_seq_names = paste(unique(full_seq_name), collapse = ";"),
    full_seq_decodes = paste(unique(full_seq_decode), collapse = ";"),
    .groups = "drop"
  ) %>%
  filter(n_libraries > 1)

#### SUMMARY COUNTS ####
pool_summary <- 
  library_base %>%
  filter(!is.na(run_type), !is.na(pool_id)) %>%
  group_by(run_type, pool_round, pool_id) %>%
  summarise(
    n_libraries = n(),
    n_missing_i5 = sum(is.na(i5_index)),
    n_missing_i7 = sum(is.na(i7_index)),
    n_missing_pairs = sum(is.na(index_pair)),
    .groups = "drop"
  )

pool_duplicate_counts <- 
  pool_duplicates %>%
  group_by(run_type, pool_round, pool_id) %>%
  summarise(
    n_duplicate_pairs = n(),
    n_libraries_in_duplicates = sum(n_libraries),
    .groups = "drop"
  )

pool_summary_final <- 
  pool_summary %>%
  left_join(pool_duplicate_counts, by = c("run_type", "pool_round", "pool_id")) %>%
  mutate(
    level = "pool",
    n_duplicate_pairs = replace_na(n_duplicate_pairs, 0),
    n_libraries_in_duplicates = replace_na(n_libraries_in_duplicates, 0)
  )

run_summary <- 
  library_base %>%
  filter(!is.na(run_key)) %>%
  group_by(run_type, pool_round, run_key) %>%
  summarise(
    n_libraries = n(),
    n_missing_i5 = sum(is.na(i5_index)),
    n_missing_i7 = sum(is.na(i7_index)),
    n_missing_pairs = sum(is.na(index_pair)),
    .groups = "drop"
  )

run_duplicate_counts <- 
  run_duplicates %>%
  group_by(run_type, pool_round, run_key) %>%
  summarise(
    n_duplicate_pairs = n(),
    n_libraries_in_duplicates = sum(n_libraries),
    .groups = "drop"
  )

run_summary_final <- 
  run_summary %>%
  left_join(run_duplicate_counts, by = c("run_type", "pool_round", "run_key")) %>%
  mutate(
    level = "run",
    pool_id = NA_character_,
    n_duplicate_pairs = replace_na(n_duplicate_pairs, 0),
    n_libraries_in_duplicates = replace_na(n_libraries_in_duplicates, 0)
  ) %>%
  select(
    level,
    run_type,
    pool_round,
    run_key,
    pool_id,
    n_libraries,
    n_missing_i5,
    n_missing_i7,
    n_missing_pairs,
    n_duplicate_pairs,
    n_libraries_in_duplicates
  )

summary_final <- 
  bind_rows(
    pool_summary_final %>%
      mutate(run_key = NA_character_) %>%
      select(
        level,
        run_type,
        pool_round,
        run_key,
        pool_id,
        n_libraries,
        n_missing_i5,
        n_missing_i7,
        n_missing_pairs,
        n_duplicate_pairs,
        n_libraries_in_duplicates
      ),
    run_summary_final
  )

#### EXPORT OUTPUTS ####
readr::write_csv(
  pool_duplicates,
  file.path(output_dir, "index_pair_duplicates_by_pool.csv")
)
readr::write_csv(
  summary_final,
  file.path(output_dir, "index_pair_duplicate_summary.csv")
)
