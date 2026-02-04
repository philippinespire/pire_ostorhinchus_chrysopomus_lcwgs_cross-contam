#### SETUP ####
if (dir.exists("r_libs")) {
  .libPaths(c("r_libs", .libPaths()))
}

library(dplyr)
library(readr)
library(readxl)
library(stringr)
library(tidyr)
library(purrr)

output_dir <- file.path("output", "TODO-12")
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

input_dir_01 <- file.path("output", "TODO-01")
input_dir_02 <- file.path("output", "TODO-02")
input_dir_03 <- file.path("output", "TODO-03")
input_dir_04 <- file.path("output", "TODO-04")
input_dir_05 <- file.path("output", "TODO-05")
input_dir_06 <- file.path("output", "TODO-06")
input_dir_07 <- file.path("output", "TODO-07")
input_dir_08 <- file.path("output", "TODO-08")
input_dir_09 <- file.path("output", "TODO-09")
input_dir_10 <- file.path("output", "TODO-10")
input_dir_11 <- file.path("output", "TODO-11")

yes_values <- c("yes", "y", "true", "1")

safe_min <- function(x) {
  if (all(is.na(x))) {
    NA_real_
  } else {
    min(x, na.rm = TRUE)
  }
}

#### LOAD INPUTS ####
admixture_key <- readr::read_csv(
  file = file.path(input_dir_02, "admixture_extraction_library_key.csv"),
  show_col_types = FALSE
)

extractions_raw <- readxl::read_excel("data/och_extractions_only.xlsx")

library_raw <- readxl::read_excel("data/Och_SSLibrariesforCapture_metadata.xlsx")

tissue_summary <- readr::read_csv(
  file = file.path(input_dir_03, "tissue_subsampling_permutation_summary.csv"),
  show_col_types = FALSE
)

extraction_summary <- readr::read_csv(
  file = file.path(input_dir_04, "extraction_order_permutation_summary.csv"),
  show_col_types = FALSE
)

extraction_plate_summary <- readr::read_csv(
  file = file.path(input_dir_05, "extraction_plate_permutation_summary.csv"),
  show_col_types = FALSE
)

library_plate_summary <- readr::read_csv(
  file = file.path(input_dir_06, "library_plate_permutation_summary.csv"),
  show_col_types = FALSE
)

dilution_plate_summary <- readr::read_csv(
  file = file.path(input_dir_07, "dilution_plate_permutation_summary.csv"),
  show_col_types = FALSE
)

index_duplicate_summary <- readr::read_csv(
  file = file.path(input_dir_08, "index_pair_duplicate_summary.csv"),
  show_col_types = FALSE
)

seq_duplicate_summary <- readr::read_csv(
  file = file.path(input_dir_09, "seq_name_duplicate_summary.csv"),
  show_col_types = FALSE
)

decode_unmatched <- readr::read_csv(
  file = file.path(input_dir_10, "decode_file_unmatched_decode_entries.csv"),
  show_col_types = FALSE
)

decode_missing <- readr::read_csv(
  file = file.path(input_dir_10, "decode_file_missing_expected_entries.csv"),
  show_col_types = FALSE
)

generode_mismatch <- readr::read_csv(
  file = file.path(input_dir_11, "generode_symlink_mismatch.csv"),
  show_col_types = FALSE
)

#### BASE INDIVIDUAL TABLE ####
individual_base <- 
  admixture_key %>%
  transmute(
    sample_id,
    sample,
    era,
    location,
    individual_key,
    K2,
    K3,
    K4,
    admixedness,
    max_prop,
    dominant_cluster,
    conflict_flag,
    missing_extraction,
    missing_library,
    missing_decode
  ) %>%
  distinct() %>%
  mutate(admixedness_rank = percent_rank(admixedness))

#### EXTRACTION KEYS ####
extractions_key <- 
  extractions_raw %>%
  transmute(
    individual_id,
    extraction_id,
    individual_key = str_replace_all(individual_id, "[-_]", ""),
    date_subsampling_date = as.Date(date_subsampling),
    subsampler = as.character(subsampler),
    date_extracting_date = as.Date(date_extracting),
    tube_stuffer = as.character(tube_stuffer),
    notes = as.character(notes)
  ) %>%
  mutate(
    subsampling_group = paste(date_subsampling_date, subsampler, sep = "|"),
    extraction_group = paste(date_extracting_date, tube_stuffer, sep = "|")
  )

notes_summary <- 
  extractions_key %>%
  mutate(
    notes_clean = str_squish(notes),
    notes_flag = !is.na(notes_clean) & notes_clean != ""
  ) %>%
  group_by(individual_key) %>%
  summarise(
    lab_notes_flag = any(notes_flag, na.rm = TRUE),
    lab_notes = paste(unique(notes_clean[notes_flag]), collapse = ";"),
    .groups = "drop"
  ) %>%
  mutate(lab_notes = na_if(lab_notes, ""))

#### EXTRACTION PLATE KEYS ####
elutions_long <- 
  extractions_raw %>%
  transmute(
    individual_id,
    extraction_id,
    elution1_plateid,
    elution1_plate_column,
    elution1_plate_row,
    elution2_plateid,
    elution2_plate_column,
    elution2_plate_row,
    elution3_plateid,
    elution3_plate_column,
    elution3_plate_row,
    elution4_plateid,
    elution4_plate_column,
    elution4_plate_row
  ) %>%
  mutate(across(matches("^elution[1-4]_plate"), as.character)) %>%
  pivot_longer(
    cols = matches("^elution[1-4]_plate"),
    names_to = c("elution", "field"),
    names_pattern = "elution(\\d+)_(plateid|plate_column|plate_row)",
    values_to = "value"
  ) %>%
  mutate(elution = as.integer(elution)) %>%
  pivot_wider(names_from = field, values_from = value) %>%
  left_join(extractions_key, by = c("individual_id", "extraction_id")) %>%
  mutate(
    plateid = as.character(plateid),
    plate_key = paste(plateid, elution, sep = "|")
  ) %>%
  filter(!is.na(plateid))

#### TISSUE SUBSAMPLING FLAGS ####
tissue_flags <- 
  tissue_summary %>%
  mutate(
    min_p = pmin(
      adj_abs_diff_mean_p_value,
      high_low_transition_p_value,
      period2_corr_p_value,
      period3_corr_p_value,
      na.rm = TRUE
    ),
    min_p = if_else(is.infinite(min_p), NA_real_, min_p),
    min_metric = case_when(
      min_p == adj_abs_diff_mean_p_value ~ "adj_abs_diff_mean",
      min_p == high_low_transition_p_value ~ "high_low_transition",
      min_p == period2_corr_p_value ~ "period2_corr",
      min_p == period3_corr_p_value ~ "period3_corr",
      TRUE ~ NA_character_
    ),
    tissue_subsampling_flag = !is.na(min_p) & min_p <= 0.05
  ) %>%
  select(
    subsampling_group,
    tissue_subsampling_flag,
    tissue_subsampling_min_p = min_p,
    tissue_subsampling_min_metric = min_metric
  )

#### EXTRACTION ORDER FLAGS ####
extraction_flags <- 
  extraction_summary %>%
  mutate(
    min_p = pmin(
      adj_abs_diff_mean_p_value,
      high_low_transition_p_value,
      period2_corr_p_value,
      period3_corr_p_value,
      na.rm = TRUE
    ),
    min_p = if_else(is.infinite(min_p), NA_real_, min_p),
    min_metric = case_when(
      min_p == adj_abs_diff_mean_p_value ~ "adj_abs_diff_mean",
      min_p == high_low_transition_p_value ~ "high_low_transition",
      min_p == period2_corr_p_value ~ "period2_corr",
      min_p == period3_corr_p_value ~ "period3_corr",
      TRUE ~ NA_character_
    ),
    extraction_order_flag = !is.na(min_p) & min_p <= 0.05
  ) %>%
  select(
    extraction_group,
    extraction_order_flag,
    extraction_order_min_p = min_p,
    extraction_order_min_metric = min_metric
  )

#### PLATE FLAGS ####
extraction_plate_flags <- 
  extraction_plate_summary %>%
  mutate(
    min_p = pmin(
      adj_abs_diff_mean_p_value,
      adj_abs_diff_median_p_value,
      cluster_mismatch_p_value,
      na.rm = TRUE
    ),
    min_p = if_else(is.infinite(min_p), NA_real_, min_p),
    extraction_plate_flag = !is.na(min_p) & min_p <= 0.05
  ) %>%
  select(
    plate_key,
    extraction_plate_flag,
    extraction_plate_min_p = min_p
  )

library_plate_flags <- 
  library_plate_summary %>%
  mutate(
    min_p = pmin(
      adj_abs_diff_mean_p_value,
      adj_abs_diff_median_p_value,
      cluster_mismatch_p_value,
      na.rm = TRUE
    ),
    min_p = if_else(is.infinite(min_p), NA_real_, min_p),
    library_plate_flag = !is.na(min_p) & min_p <= 0.05
  ) %>%
  select(
    plate_key,
    library_plate_flag,
    library_plate_min_p = min_p
  )

dilution_plate_flags <- 
  dilution_plate_summary %>%
  mutate(
    min_p = pmin(
      adj_abs_diff_mean_p_value,
      adj_abs_diff_median_p_value,
      cluster_mismatch_p_value,
      na.rm = TRUE
    ),
    min_p = if_else(is.infinite(min_p), NA_real_, min_p),
    dilution_plate_flag = !is.na(min_p) & min_p <= 0.05
  ) %>%
  select(
    plate_key,
    dilution_plate_flag,
    dilution_plate_min_p = min_p
  )

#### PLATE FLAGS PER INDIVIDUAL ####
individual_extraction_plate_flags <- 
  elutions_long %>%
  left_join(extraction_plate_flags, by = "plate_key") %>%
  group_by(individual_key) %>%
  summarise(
    extraction_plate_flag = any(extraction_plate_flag, na.rm = TRUE),
    extraction_plate_min_p = safe_min(extraction_plate_min_p),
    .groups = "drop"
  )

library_key <- 
  library_raw %>%
  transmute(
    individual_id = Individual_ID,
    individual_key = str_replace_all(Individual_ID, "[-_]", ""),
    extraction_id = Extraction_ID,
    library_id = Library_id,
    library_plate = `Library Plate`,
    library_plate_row = `Library plate row`,
    library_plate_col = `Library plate col`,
    dilution_plate = `Dilution Plate`,
    dilution_plate_row = `Dilution Plate Row`,
    dilution_plate_col = `Dilution Plate Col`,
    pool_round = `Pool Round`,
    test_lane_pool = `TestLanePool`,
    full_lane_pool = `Pool`,
    pool_for_full_seq = `Pool for full seq?`,
    novogene_seq_id = NovoGeneSeqID,
    sequence_id = Sequence_ID,
    full_seq_name = `Full seq Name`,
    full_seq_decode = `Full seq decode`
  )

individual_library_plate_flags <- 
  library_key %>%
  mutate(plate_key = as.character(library_plate)) %>%
  left_join(library_plate_flags, by = "plate_key") %>%
  group_by(individual_key) %>%
  summarise(
    library_plate_flag = any(library_plate_flag, na.rm = TRUE),
    library_plate_min_p = safe_min(library_plate_min_p),
    .groups = "drop"
  )

individual_dilution_plate_flags <- 
  library_key %>%
  mutate(plate_key = as.character(dilution_plate)) %>%
  left_join(dilution_plate_flags, by = "plate_key") %>%
  group_by(individual_key) %>%
  summarise(
    dilution_plate_flag = any(dilution_plate_flag, na.rm = TRUE),
    dilution_plate_min_p = safe_min(dilution_plate_min_p),
    .groups = "drop"
  )

#### ORDER FLAGS PER INDIVIDUAL ####
individual_order_flags <- 
  extractions_key %>%
  select(individual_key, subsampling_group, extraction_group) %>%
  distinct() %>%
  left_join(tissue_flags, by = "subsampling_group") %>%
  left_join(extraction_flags, by = "extraction_group") %>%
  group_by(individual_key) %>%
  summarise(
    tissue_subsampling_flag = any(tissue_subsampling_flag, na.rm = TRUE),
    tissue_subsampling_min_p = safe_min(tissue_subsampling_min_p),
    tissue_subsampling_min_metric = first(na.omit(tissue_subsampling_min_metric)),
    extraction_order_flag = any(extraction_order_flag, na.rm = TRUE),
    extraction_order_min_p = safe_min(extraction_order_min_p),
    extraction_order_min_metric = first(na.omit(extraction_order_min_metric)),
    .groups = "drop"
  )

#### INDEX DUPLICATE FLAGS ####
index_duplicate_pools <- 
  index_duplicate_summary %>%
  filter(level == "pool", n_duplicate_pairs > 0) %>%
  transmute(run_type, pool_id)

library_pools_test <- 
  library_key %>%
  transmute(
    individual_key,
    pool_round = as.character(pool_round),
    test_lane_pool = as.character(test_lane_pool)
  ) %>%
  mutate(
    pool_round_lower = str_to_lower(pool_round),
    run_type = case_when(
      str_detect(pool_round_lower, "test lane 2") ~ "test_lane_2",
      str_detect(pool_round_lower, "test lane") ~ "test_lane",
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(run_type), !is.na(test_lane_pool)) %>%
  transmute(individual_key, run_type, pool_id = test_lane_pool)

library_pools_full <- 
  library_key %>%
  mutate(
    in_full_lane_flag = str_to_lower(as.character(pool_for_full_seq)) %in% yes_values
  ) %>%
  filter(in_full_lane_flag, !is.na(full_lane_pool)) %>%
  transmute(individual_key, run_type = "full_lane", pool_id = full_lane_pool)

library_pools_long <- 
  bind_rows(library_pools_test, library_pools_full)

index_duplicate_flags <- 
  if (nrow(index_duplicate_pools) == 0) {
    tibble(individual_key = character(), index_duplicate_flag = logical())
  } else {
    library_pools_long %>%
      semi_join(index_duplicate_pools, by = c("run_type", "pool_id")) %>%
      distinct(individual_key) %>%
      mutate(index_duplicate_flag = TRUE)
  }

#### SEQ NAME DUPLICATE FLAGS ####
seq_duplicate_pools <- 
  seq_duplicate_summary %>%
  filter(level == "pool", n_duplicate_values > 0) %>%
  transmute(run_type, pool_id)

seq_duplicate_flags <- 
  if (nrow(seq_duplicate_pools) == 0) {
    tibble(individual_key = character(), seq_name_duplicate_flag = logical())
  } else {
    library_pools_long %>%
      semi_join(seq_duplicate_pools, by = c("run_type", "pool_id")) %>%
      distinct(individual_key) %>%
      mutate(seq_name_duplicate_flag = TRUE)
  }

#### DECODE MISMATCH FLAGS ####
expected_pairs_test <- 
  library_key %>%
  transmute(
    individual_key,
    pool_round = as.character(pool_round),
    novogene_seq_id = novogene_seq_id,
    sequence_id = sequence_id
  ) %>%
  mutate(
    pool_round_lower = str_to_lower(pool_round),
    run_label = case_when(
      str_detect(pool_round_lower, "test lane 2") ~ "test_lane_2",
      str_detect(pool_round_lower, "test lane") ~ "test_lane",
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(run_label), !is.na(novogene_seq_id), !is.na(sequence_id)) %>%
  transmute(
    run_label,
    decode_first = novogene_seq_id,
    decode_second = sequence_id,
    individual_key
  )

expected_pairs_full <- 
  library_key %>%
  mutate(
    in_full_lane_flag = str_to_lower(as.character(pool_for_full_seq)) %in% yes_values
  ) %>%
  filter(in_full_lane_flag, !is.na(full_seq_name), !is.na(full_seq_decode)) %>%
  transmute(
    run_label = "full_lane",
    decode_first = full_seq_name,
    decode_second = full_seq_decode,
    individual_key
  )

expected_pairs <- 
  bind_rows(expected_pairs_test, expected_pairs_full)

decode_unmatched_pairs <- 
  decode_unmatched %>%
  transmute(
    run_label,
    decode_first,
    decode_second
  )

decode_missing_pairs <- 
  decode_missing %>%
  transmute(
    run_label,
    decode_first = expected_first,
    decode_second = expected_second
  )

decode_issue_pairs <- 
  bind_rows(decode_unmatched_pairs, decode_missing_pairs) %>%
  distinct()

decode_mismatch_flags <- 
  if (nrow(decode_issue_pairs) == 0) {
    tibble(individual_key = character(), decode_mismatch_flag = logical())
  } else {
    expected_pairs %>%
      semi_join(
        decode_issue_pairs,
        by = c("run_label", "decode_first", "decode_second")
      ) %>%
      distinct(individual_key) %>%
      mutate(decode_mismatch_flag = TRUE)
  }

#### GENERODE MISMATCH FLAGS ####
generode_flags <- 
  if (nrow(generode_mismatch) == 0) {
    tibble(individual_key = character(), generode_mismatch_flag = logical())
  } else {
    generode_mismatch %>%
      transmute(individual_key = link_id_norm) %>%
      distinct() %>%
      mutate(generode_mismatch_flag = TRUE)
  }

#### COMBINE EVIDENCE ####
individual_evidence_base <- 
  individual_base %>%
  left_join(individual_order_flags, by = "individual_key") %>%
  left_join(individual_extraction_plate_flags, by = "individual_key") %>%
  left_join(individual_library_plate_flags, by = "individual_key") %>%
  left_join(individual_dilution_plate_flags, by = "individual_key") %>%
  left_join(index_duplicate_flags, by = "individual_key") %>%
  left_join(seq_duplicate_flags, by = "individual_key") %>%
  left_join(decode_mismatch_flags, by = "individual_key") %>%
  left_join(generode_flags, by = "individual_key") %>%
  left_join(notes_summary, by = "individual_key") %>%
  mutate(
    tissue_subsampling_flag = replace_na(tissue_subsampling_flag, FALSE),
    extraction_order_flag = replace_na(extraction_order_flag, FALSE),
    extraction_plate_flag = replace_na(extraction_plate_flag, FALSE),
    library_plate_flag = replace_na(library_plate_flag, FALSE),
    dilution_plate_flag = replace_na(dilution_plate_flag, FALSE),
    index_duplicate_flag = replace_na(index_duplicate_flag, FALSE),
    seq_name_duplicate_flag = replace_na(seq_name_duplicate_flag, FALSE),
    decode_mismatch_flag = replace_na(decode_mismatch_flag, FALSE),
    generode_mismatch_flag = replace_na(generode_mismatch_flag, FALSE),
    lab_notes_flag = replace_na(lab_notes_flag, FALSE)
  )

flag_columns <- c(
  "tissue_subsampling_flag",
  "extraction_order_flag",
  "extraction_plate_flag",
  "library_plate_flag",
  "dilution_plate_flag",
  "index_duplicate_flag",
  "seq_name_duplicate_flag",
  "decode_mismatch_flag",
  "generode_mismatch_flag",
  "lab_notes_flag"
)

flag_labels <- c(
  "tissue_subsampling",
  "extraction_order",
  "extraction_plate",
  "library_plate",
  "dilution_plate",
  "index_duplicate",
  "seq_name_duplicate",
  "decode_mismatch",
  "generode_mismatch",
  "lab_notes"
)

evidence_sources <- 
  individual_evidence_base %>%
  select(all_of(flag_columns)) %>%
  purrr::pmap_chr(
    function(...) {
      flags <- c(...)
      flags[is.na(flags)] <- FALSE
      paste(flag_labels[which(flags)], collapse = ";")
    }
  )

individual_evidence <- 
  individual_evidence_base %>%
  mutate(
    evidence_count = rowSums(select(., all_of(flag_columns)), na.rm = TRUE),
    evidence_sources = na_if(evidence_sources, ""),
    evidence_flag = evidence_count > 0,
    admixedness_percentile = round(admixedness_rank * 100, 1),
    candidate_flag = evidence_count >= 2 & admixedness_rank >= 0.75
  )

#### CANDIDATES AND SUMMARY ####
candidate_individuals <- 
  individual_evidence %>%
  filter(candidate_flag) %>%
  arrange(desc(admixedness), desc(evidence_count))

evidence_counts <- 
  individual_evidence %>%
  summarise(across(all_of(flag_columns), ~ sum(.x, na.rm = TRUE))) %>%
  pivot_longer(
    cols = everything(),
    names_to = "evidence_source",
    values_to = "n_individuals"
  ) %>%
  mutate(evidence_source = str_replace(evidence_source, "_flag$", ""))

overall_counts <- 
  tibble(
    evidence_source = c("any_evidence", "candidate_individuals", "total_individuals"),
    n_individuals = c(
      sum(individual_evidence$evidence_flag, na.rm = TRUE),
      sum(individual_evidence$candidate_flag, na.rm = TRUE),
      nrow(individual_evidence)
    )
  )

evidence_summary <- 
  bind_rows(overall_counts, evidence_counts)

#### EXPORT OUTPUTS ####
readr::write_csv(
  individual_evidence,
  file.path(output_dir, "contamination_evidence_by_individual.csv")
)

readr::write_csv(
  candidate_individuals,
  file.path(output_dir, "contamination_evidence_candidates.csv")
)

readr::write_csv(
  evidence_summary,
  file.path(output_dir, "contamination_evidence_summary.csv")
)
