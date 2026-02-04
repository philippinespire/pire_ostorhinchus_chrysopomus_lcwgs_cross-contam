#### SETUP ####
if (dir.exists("r_libs")) {
  .libPaths(c("r_libs", .libPaths()))
}

library(dplyr)
library(readr)
library(stringr)
library(purrr)
library(tidyr)

output_dir <- "output"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

#### LOAD INPUTS ####
symlink_files <- tibble(
  era = c("historical", "modern"),
  file_path = c(
    "data/pire_ostorhinchus_chrysopomus_lcwgs/GenErode_Och_20k/data/raw_reads_symlinks/historical/generode_hist_symlinks.txt",
    "data/pire_ostorhinchus_chrysopomus_lcwgs/GenErode_Och_20k/data/raw_reads_symlinks/modern/generode_cont_symlinks.txt"
  )
)

#### PARSE SYMLINK FILES ####
parse_symlink_file <- function(path, era) {
  lines <- readr::read_lines(path)
  matches <- stringr::str_match(lines, "\\s(\\S+)\\s->\\s(\\S+)$")
  tibble(
    era = era,
    file_path = path,
    link_path = matches[, 2],
    target_path = matches[, 3]
  ) %>%
    filter(!is.na(link_path), !is.na(target_path))
}

symlink_entries <- 
  symlink_files %>%
  mutate(entries = purrr::map2(file_path, era, parse_symlink_file)) %>%
  select(entries) %>%
  unnest(entries) %>%
  mutate(
    link_base = basename(link_path),
    target_base = basename(target_path),
    link_id_raw = str_split_fixed(link_base, "_Ex", 2)[, 1],
    target_id_raw = str_split_fixed(target_base, "-Ex", 2)[, 1],
    link_id_norm = str_replace_all(link_id_raw, "[-_]", ""),
    target_id_norm = str_replace_all(target_id_raw, "[-_]", ""),
    id_match = link_id_norm == target_id_norm
  )

#### OUTPUT TABLES ####
symlink_mismatches <- 
  symlink_entries %>%
  filter(!id_match)

symlink_summary <- 
  symlink_entries %>%
  group_by(era, file_path) %>%
  summarise(
    n_total = n(),
    n_mismatches = sum(!id_match),
    mismatch_rate = if_else(n_total > 0, n_mismatches / n_total, NA_real_),
    example_links = paste(head(link_base, 5), collapse = ";"),
    .groups = "drop"
  )

#### EXPORT OUTPUTS ####
readr::write_csv(
  symlink_mismatches,
  file.path(output_dir, "generode_symlink_mismatch.csv")
)
readr::write_csv(
  symlink_summary,
  file.path(output_dir, "generode_symlink_summary.csv")
)
