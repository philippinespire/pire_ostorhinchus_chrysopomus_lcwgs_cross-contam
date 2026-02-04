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
library_raw <- readxl::read_excel(
  "data/Och_SSLibrariesforCapture_metadata.xlsx",
  na = c("", "NA", "N/A", "n/a")
)

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
    novogene_seq_id = NovoGeneSeqID,
    sequence_id = Sequence_ID,
    full_seq_name = `Full seq Name`,
    full_seq_decode = `Full seq decode`,
    individual_key = stringr::str_replace_all(individual_id, "[-_]", "")
  ) %>%
  mutate(
    pool_round_lower = str_to_lower(as.character(pool_round)),
    in_test_lane_flag = str_to_lower(as.character(in_test_lane)) %in% yes_values,
    in_full_lane_flag = str_to_lower(as.character(in_full_lane)) %in% yes_values
  )

#### BUILD LONG TABLE ####
seq_long <- 
  library_base %>%
  mutate(
    novogene_seq_id_all = novogene_seq_id,
    sequence_id_all = sequence_id,
    full_seq_name_all = full_seq_name,
    full_seq_decode_all = full_seq_decode,
    novogene_seq_id = na_if(novogene_seq_id, ""),
    sequence_id = na_if(sequence_id, ""),
    full_seq_name = na_if(full_seq_name, ""),
    full_seq_decode = na_if(full_seq_decode, "")
  ) %>%
  pivot_longer(
    cols = c(novogene_seq_id, sequence_id, full_seq_name, full_seq_decode),
    names_to = "seq_field",
    values_to = "seq_value"
  ) %>%
  mutate(
    run_type = case_when(
      seq_field %in% c("novogene_seq_id", "sequence_id") &
        str_detect(pool_round_lower, "test lane 2") ~ "test_lane_2",
      seq_field %in% c("novogene_seq_id", "sequence_id") &
        str_detect(pool_round_lower, "test lane") ~ "test_lane",
      seq_field %in% c("full_seq_name", "full_seq_decode") & in_full_lane_flag ~ "full_lane",
      TRUE ~ NA_character_
    ),
    pool_id = case_when(
      run_type %in% c("test_lane", "test_lane_2") ~ as.character(test_lane_pool),
      run_type == "full_lane" ~ as.character(full_lane_pool),
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(run_type))

#### DUPLICATES BY POOL ####
pool_duplicates <- 
  seq_long %>%
  filter(!is.na(pool_id), !is.na(seq_value)) %>%
  group_by(run_type, pool_id, seq_field, seq_value) %>%
  summarise(
    n_libraries = n(),
    library_ids = paste(unique(library_id), collapse = ";"),
    individual_ids = paste(unique(individual_id), collapse = ";"),
    extraction_ids = paste(unique(extraction_id), collapse = ";"),
    sequence_ids = paste(unique(na.omit(sequence_id_all)), collapse = ";"),
    novogene_seq_ids = paste(unique(na.omit(novogene_seq_id_all)), collapse = ";"),
    full_seq_names = paste(unique(na.omit(full_seq_name_all)), collapse = ";"),
    full_seq_decodes = paste(unique(na.omit(full_seq_decode_all)), collapse = ";"),
    .groups = "drop"
  ) %>%
  filter(n_libraries > 1)

#### DUPLICATES BY RUN ####
run_duplicates <- 
  seq_long %>%
  filter(!is.na(seq_value)) %>%
  group_by(run_type, seq_field, seq_value) %>%
  summarise(
    n_libraries = n(),
    library_ids = paste(unique(library_id), collapse = ";"),
    individual_ids = paste(unique(individual_id), collapse = ";"),
    extraction_ids = paste(unique(extraction_id), collapse = ";"),
    sequence_ids = paste(unique(na.omit(sequence_id_all)), collapse = ";"),
    novogene_seq_ids = paste(unique(na.omit(novogene_seq_id_all)), collapse = ";"),
    full_seq_names = paste(unique(na.omit(full_seq_name_all)), collapse = ";"),
    full_seq_decodes = paste(unique(na.omit(full_seq_decode_all)), collapse = ";"),
    .groups = "drop"
  ) %>%
  filter(n_libraries > 1)

#### SUMMARY COUNTS ####
pool_summary <- 
  seq_long %>%
  filter(!is.na(pool_id)) %>%
  group_by(run_type, pool_id, seq_field) %>%
  summarise(
    n_libraries = n(),
    n_missing = sum(is.na(seq_value)),
    .groups = "drop"
  )

pool_duplicate_counts <- 
  pool_duplicates %>%
  group_by(run_type, pool_id, seq_field) %>%
  summarise(
    n_duplicate_values = n(),
    n_libraries_in_duplicates = sum(n_libraries),
    .groups = "drop"
  )

pool_summary_final <- 
  pool_summary %>%
  left_join(pool_duplicate_counts, by = c("run_type", "pool_id", "seq_field")) %>%
  mutate(
    level = "pool",
    n_duplicate_values = replace_na(n_duplicate_values, 0),
    n_libraries_in_duplicates = replace_na(n_libraries_in_duplicates, 0)
  )

run_summary <- 
  seq_long %>%
  group_by(run_type, seq_field) %>%
  summarise(
    n_libraries = n(),
    n_missing = sum(is.na(seq_value)),
    .groups = "drop"
  )

run_duplicate_counts <- 
  run_duplicates %>%
  group_by(run_type, seq_field) %>%
  summarise(
    n_duplicate_values = n(),
    n_libraries_in_duplicates = sum(n_libraries),
    .groups = "drop"
  )

run_summary_final <- 
  run_summary %>%
  left_join(run_duplicate_counts, by = c("run_type", "seq_field")) %>%
  mutate(
    level = "run",
    pool_id = NA_character_,
    n_duplicate_values = replace_na(n_duplicate_values, 0),
    n_libraries_in_duplicates = replace_na(n_libraries_in_duplicates, 0)
  ) %>%
  select(
    level,
    run_type,
    pool_id,
    seq_field,
    n_libraries,
    n_missing,
    n_duplicate_values,
    n_libraries_in_duplicates
  )

summary_final <- 
  bind_rows(
    pool_summary_final %>%
      select(
        level,
        run_type,
        pool_id,
        seq_field,
        n_libraries,
        n_missing,
        n_duplicate_values,
        n_libraries_in_duplicates
      ),
    run_summary_final
  )

#### EXPORT OUTPUTS ####
readr::write_csv(
  pool_duplicates,
  file.path(output_dir, "seq_name_duplicates_by_pool.csv")
)
readr::write_csv(
  summary_final,
  file.path(output_dir, "seq_name_duplicate_summary.csv")
)
