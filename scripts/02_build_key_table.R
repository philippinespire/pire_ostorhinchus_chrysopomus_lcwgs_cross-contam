#### SETUP ####
if (dir.exists("r_libs")) {
  .libPaths(c("r_libs", .libPaths()))
}

library(dplyr)
library(readr)
library(stringr)
library(readxl)
library(purrr)

output_dir <- "output"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

#### LOAD INPUTS ####
admixture_summary <- readr::read_csv(
  file = file.path(output_dir, "admixture_summary.csv"),
  show_col_types = FALSE
)

extractions_raw <- readxl::read_excel("data/och_extractions_only.xlsx")

library_raw <- readxl::read_excel(
  path = "data/Och_SSLibrariesforCapture_metadata.xlsx",
  sheet = "Sheet1"
)

decode_files <- list.files(
  path = "data/pire_ostorhinchus_chrysopomus_lcwgs",
  pattern = "decode_sedlist\\.txt$",
  recursive = TRUE,
  full.names = TRUE
)

#### CANONICALIZE KEYS ####
admixture_key <- 
  admixture_summary %>%
  mutate(individual_key = str_replace_all(sample_id, "[-_]", ""))

extractions_key <- 
  extractions_raw %>%
  transmute(
    extraction_individual_id = individual_id,
    extraction_id = extraction_id,
    extraction_individual_key = str_replace_all(individual_id, "[-_]", ""),
    extraction_id_key = str_replace_all(extraction_id, "[-_]", "")
  )

extractions_summary <- 
  extractions_key %>%
  group_by(extraction_individual_key) %>%
  summarise(
    extraction_individual_ids = paste(unique(extraction_individual_id), collapse = ";"),
    extraction_ids = paste(unique(extraction_id), collapse = ";"),
    n_extractions = n_distinct(extraction_id),
    .groups = "drop"
  )

library_key <- 
  library_raw %>%
  transmute(
    library_individual_id = Individual_ID,
    library_extraction_id = Extraction_ID,
    library_id = Library_id,
    library_plate = `Library Plate`,
    library_plate_row = `Library plate row`,
    library_plate_col = `Library plate col`,
    pool_round = `Pool Round`,
    test_lane_seq_name = `Test Lane Seq Name`,
    novogene_seq_id = NovoGeneSeqID,
    sequence_id = Sequence_ID,
    full_seq_name = `Full seq Name`,
    full_seq_decode = `Full seq decode`,
    library_individual_key = str_replace_all(Individual_ID, "[-_]", ""),
    library_extraction_key = str_replace_all(Extraction_ID, "[-_]", "")
  )

library_summary <- 
  library_key %>%
  group_by(library_individual_key) %>%
  summarise(
    library_individual_ids = paste(unique(library_individual_id), collapse = ";"),
    library_extraction_ids = paste(unique(library_extraction_id), collapse = ";"),
    library_ids = paste(unique(library_id), collapse = ";"),
    sequence_ids = paste(unique(sequence_id), collapse = ";"),
    novogene_seq_ids = paste(unique(novogene_seq_id), collapse = ";"),
    full_seq_names = paste(unique(full_seq_name), collapse = ";"),
    full_seq_decodes = paste(unique(full_seq_decode), collapse = ";"),
    n_library_rows = n(),
    n_library_extractions = n_distinct(library_extraction_id),
    .groups = "drop"
  )

#### PARSE DECODE FILES ####
decode_lines <- 
  purrr::map_dfr(
    decode_files,
    function(file_path) {
      run_dir <- stringr::str_extract(file_path, "[^/]+_sequencing_run")
      tibble(
        run_dir = run_dir,
        line = readr::read_lines(file_path)
      )
    }
  )

decode_map_raw <- 
  decode_lines %>%
  filter(str_starts(line, "s/"))

decode_map_parsed <- 
  decode_map_raw %>%
  mutate(match = str_match(line, "^s/([^/]+)/([^/]+)/$")) %>%
  transmute(
    run_dir,
    seq_name = match[, 2],
    sequence_id = match[, 3]
  ) %>%
  filter(!is.na(seq_name), seq_name != "Sequence")

decode_map_keys <- 
  decode_map_parsed %>%
  mutate(
    extraction_id = str_extract(sequence_id, "Och-[A-Za-z]+_[0-9]{3}-Ex[0-9]+"),
    individual_id = str_replace(extraction_id, "-Ex[0-9]+$", ""),
    individual_key = str_replace_all(individual_id, "[-_]", "")
  )

decode_summary <- 
  decode_map_keys %>%
  group_by(individual_key) %>%
  summarise(
    decode_seq_names = paste(unique(seq_name), collapse = ";"),
    decode_sequence_ids = paste(unique(sequence_id), collapse = ";"),
    n_decode_entries = n(),
    .groups = "drop"
  )

library_sequence_lookup <- 
  library_key %>%
  transmute(seq = sequence_id) %>%
  bind_rows(library_key %>% transmute(seq = full_seq_decode)) %>%
  filter(!is.na(seq)) %>%
  distinct()

library_seqname_lookup <- 
  library_key %>%
  transmute(seq_name = novogene_seq_id) %>%
  bind_rows(library_key %>% transmute(seq_name = full_seq_name)) %>%
  bind_rows(library_key %>% transmute(seq_name = test_lane_seq_name)) %>%
  filter(!is.na(seq_name)) %>%
  distinct()

decode_missing_seq_id <- 
  decode_map_keys %>%
  anti_join(library_sequence_lookup, by = c("sequence_id" = "seq"))

decode_missing_seq_name <- 
  decode_map_keys %>%
  anti_join(library_seqname_lookup, by = c("seq_name" = "seq_name"))

#### BUILD UNIFIED KEY TABLE ####
admixture_with_extraction <- 
  admixture_key %>%
  left_join(extractions_summary, by = c("individual_key" = "extraction_individual_key"))

admixture_with_library <- 
  admixture_with_extraction %>%
  left_join(library_summary, by = c("individual_key" = "library_individual_key"))

admixture_with_decode <- 
  admixture_with_library %>%
  left_join(decode_summary, by = "individual_key")

admixture_key_table <- 
  admixture_with_decode %>%
  mutate(
    conflict_flag = case_when(
      str_detect(coalesce(sample_id, ""), "OcA0102311B") |
        str_detect(coalesce(decode_seq_names, ""), "OcA0102311B") ~ "OcA0102311B",
      str_detect(coalesce(sample_id, ""), "OchACat039") |
        str_detect(coalesce(extraction_individual_ids, ""), "Och-ACat_039") ~ "OchACat039",
      TRUE ~ NA_character_
    ),
    missing_extraction = is.na(extraction_ids),
    missing_library = is.na(library_ids),
    missing_decode = is.na(decode_seq_names)
  )

#### DIAGNOSTICS ####
unmatched_extractions <- 
  extractions_summary %>%
  anti_join(admixture_key, by = c("extraction_individual_key" = "individual_key")) %>%
  transmute(
    diagnostic = "extraction_without_admixture",
    id = extraction_individual_ids,
    count = n_extractions
  )

unmatched_library <- 
  library_summary %>%
  anti_join(admixture_key, by = c("library_individual_key" = "individual_key")) %>%
  transmute(
    diagnostic = "library_without_admixture",
    id = library_individual_ids,
    count = n_library_rows
  )

unmatched_decode <- 
  decode_summary %>%
  anti_join(admixture_key, by = "individual_key") %>%
  transmute(
    diagnostic = "decode_without_admixture",
    id = decode_sequence_ids,
    count = n_decode_entries
  )

decode_missing_seq_id_summary <- if (nrow(decode_missing_seq_id) == 0) {
  tibble(
    diagnostic = "decode_sequence_id_not_in_metadata",
    id = NA_character_,
    count = 0
  )
} else {
  decode_missing_seq_id %>%
    summarise(
      diagnostic = "decode_sequence_id_not_in_metadata",
      id = paste(unique(sequence_id), collapse = ";"),
      count = n_distinct(sequence_id)
    )
}

decode_missing_seq_name_summary <- if (nrow(decode_missing_seq_name) == 0) {
  tibble(
    diagnostic = "decode_seq_name_not_in_metadata",
    id = NA_character_,
    count = 0
  )
} else {
  decode_missing_seq_name %>%
    summarise(
      diagnostic = "decode_seq_name_not_in_metadata",
      id = paste(unique(seq_name), collapse = ";"),
      count = n_distinct(seq_name)
    )
}

diagnostics_counts <- tibble(
  diagnostic = c(
    "admixture_individuals",
    "missing_extraction",
    "missing_library",
    "missing_decode"
  ),
  id = NA_character_,
  count = c(
    nrow(admixture_key_table),
    sum(admixture_key_table$missing_extraction, na.rm = TRUE),
    sum(admixture_key_table$missing_library, na.rm = TRUE),
    sum(admixture_key_table$missing_decode, na.rm = TRUE)
  )
)

diagnostics <- bind_rows(
  diagnostics_counts,
  decode_missing_seq_id_summary,
  decode_missing_seq_name_summary,
  unmatched_extractions,
  unmatched_library,
  unmatched_decode
)

#### EXPORT OUTPUTS ####
readr::write_csv(
  admixture_key_table,
  file.path(output_dir, "admixture_extraction_library_key.csv")
)
readr::write_csv(
  diagnostics,
  file.path(output_dir, "admixture_extraction_library_diagnostics.csv")
)
