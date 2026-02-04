#### SETUP ####
if (dir.exists("r_libs")) {
  .libPaths(c("r_libs", .libPaths()))
}

library(dplyr)
library(readr)
library(readxl)
library(stringr)
library(purrr)

output_dir <- "output"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

n_permutations <- 1000

cross_join <- function(x, y) {
  merge(x, y, by = NULL)
}

#### LOAD INPUTS ####
admixture_key <- readr::read_csv(
  file = file.path(output_dir, "admixture_extraction_library_key.csv"),
  show_col_types = FALSE
)

extractions_raw <- readxl::read_excel("data/och_extractions_only.xlsx")

#### BUILD ANALYSIS TABLE ####
admixture_metrics <- 
  admixture_key %>%
  select(
    individual_key,
    admixedness,
    dominant_cluster,
    conflict_flag
  )

extractions_key <- 
  extractions_raw %>%
  transmute(
    individual_id,
    extraction_id,
    individual_key = stringr::str_replace_all(individual_id, "[-_]", "")
  )

elution1 <- 
  extractions_raw %>%
  transmute(
    individual_id,
    extraction_id,
    elution = 1,
    plateid = elution1_plateid,
    plate_col = elution1_plate_column,
    plate_row = elution1_plate_row
  )

elution2 <- 
  extractions_raw %>%
  transmute(
    individual_id,
    extraction_id,
    elution = 2,
    plateid = elution2_plateid,
    plate_col = elution2_plate_column,
    plate_row = elution2_plate_row
  )

elution3 <- 
  extractions_raw %>%
  transmute(
    individual_id,
    extraction_id,
    elution = 3,
    plateid = elution3_plateid,
    plate_col = elution3_plate_column,
    plate_row = elution3_plate_row
  )

elution4 <- 
  extractions_raw %>%
  transmute(
    individual_id,
    extraction_id,
    elution = 4,
    plateid = elution4_plateid,
    plate_col = elution4_plate_column,
    plate_row = elution4_plate_row
  )

elutions_long <- 
  bind_rows(elution1, elution2, elution3, elution4) %>%
  left_join(extractions_key, by = c("individual_id", "extraction_id")) %>%
  left_join(admixture_metrics, by = "individual_key") %>%
  mutate(
    plate_row = as.character(plate_row),
    plate_row_num = case_when(
      str_detect(plate_row, "^[A-Za-z]+$") ~ match(str_to_upper(plate_row), LETTERS),
      str_detect(plate_row, "^[0-9]+$") ~ as.integer(plate_row),
      TRUE ~ NA_integer_
    ),
    plate_col_num = suppressWarnings(as.integer(plate_col)),
    plate_key = paste(plateid, elution, sep = "|")
  )

#### DIAGNOSTICS ####
missing_plate_coords <- 
  elutions_long %>%
  filter(is.na(plateid) | is.na(plate_row_num) | is.na(plate_col_num))

duplicate_wells <- 
  elutions_long %>%
  filter(!is.na(plateid), !is.na(plate_row_num), !is.na(plate_col_num)) %>%
  group_by(plate_key, plate_row_num, plate_col_num) %>%
  summarise(
    n_records = n(),
    extraction_ids = paste(unique(extraction_id), collapse = ";"),
    .groups = "drop"
  ) %>%
  filter(n_records > 1)

#### ADJACENCY METRICS ####
plate_wells <- 
  elutions_long %>%
  filter(!is.na(plateid), !is.na(plate_row_num), !is.na(plate_col_num)) %>%
  mutate(
    plate_row_num = as.integer(plate_row_num),
    plate_col_num = as.integer(plate_col_num)
  )

neighbor_offsets <- tibble(
  d_row = c(-1, 1, 0, 0),
  d_col = c(0, 0, -1, 1)
)

plate_groups <- plate_wells %>%
  group_by(plate_key) %>%
  group_split()

plate_keys <- plate_wells %>%
  group_by(plate_key) %>%
  group_keys()

summarise_perm <- function(perm_values, observed_value) {
  perm_mean <- mean(perm_values, na.rm = TRUE)
  perm_sd <- sd(perm_values, na.rm = TRUE)
  p_value <- if (is.na(observed_value) || all(is.na(perm_values))) {
    NA_real_
  } else {
    mean(abs(perm_values - perm_mean) >= abs(observed_value - perm_mean), na.rm = TRUE)
  }
  tibble(perm_mean = perm_mean, perm_sd = perm_sd, p_value = p_value)
}

compute_plate_metrics <- function(plate_df, plate_key_value) {
  wells <- 
    plate_df %>%
    arrange(plate_row_num, plate_col_num) %>%
    mutate(well_index = row_number())

  well_positions <- 
    wells %>%
    select(well_index, plate_row_num, plate_col_num)

  neighbor_index <- 
    cross_join(well_positions, neighbor_offsets) %>%
    mutate(
      neighbor_row = plate_row_num + d_row,
      neighbor_col = plate_col_num + d_col
    ) %>%
    inner_join(
      well_positions,
      by = c("neighbor_row" = "plate_row_num", "neighbor_col" = "plate_col_num"),
      suffix = c("_source", "_neighbor")
    ) %>%
    transmute(
      source_index = well_index_source,
      neighbor_index = well_index_neighbor
    )

  adj_diffs <- abs(wells$admixedness[neighbor_index$source_index] -
                     wells$admixedness[neighbor_index$neighbor_index])

  cluster_mismatch <- wells$dominant_cluster[neighbor_index$source_index] !=
    wells$dominant_cluster[neighbor_index$neighbor_index]

  observed_metrics <- tibble(
    adj_abs_diff_mean = mean(adj_diffs, na.rm = TRUE),
    adj_abs_diff_median = median(adj_diffs, na.rm = TRUE),
    cluster_mismatch_rate = mean(cluster_mismatch, na.rm = TRUE)
  )

  perm_metrics <- if (nrow(wells) >= 2 && nrow(neighbor_index) > 0 && n_permutations > 0) {
    purrr::map_dfr(
      seq_len(n_permutations),
      function(perm_index) {
        perm_vals <- wells$admixedness
        perm_dom <- wells$dominant_cluster
        non_missing_vals <- which(!is.na(perm_vals))
        non_missing_dom <- which(!is.na(perm_dom))
        if (length(non_missing_vals) > 1) {
          perm_vals[non_missing_vals] <- sample(perm_vals[non_missing_vals])
        }
        if (length(non_missing_dom) > 1) {
          perm_dom[non_missing_dom] <- sample(perm_dom[non_missing_dom])
        }
        perm_diffs <- abs(perm_vals[neighbor_index$source_index] -
                           perm_vals[neighbor_index$neighbor_index])
        perm_mismatch <- perm_dom[neighbor_index$source_index] !=
          perm_dom[neighbor_index$neighbor_index]
        tibble(
          adj_abs_diff_mean = mean(perm_diffs, na.rm = TRUE),
          adj_abs_diff_median = median(perm_diffs, na.rm = TRUE),
          cluster_mismatch_rate = mean(perm_mismatch, na.rm = TRUE),
          permutation = perm_index
        )
      }
    )
  } else {
    tibble(
      adj_abs_diff_mean = NA_real_,
      adj_abs_diff_median = NA_real_,
      cluster_mismatch_rate = NA_real_,
      permutation = NA_integer_
    )
  }

  metrics_row <- 
    observed_metrics %>%
    mutate(
      plate_key = plate_key_value,
      plateid = wells$plateid[1],
      elution = wells$elution[1],
      n_wells = nrow(wells),
      n_missing_admixedness = sum(is.na(wells$admixedness)),
      n_missing_dominant_cluster = sum(is.na(wells$dominant_cluster)),
      n_neighbor_pairs = nrow(neighbor_index)
    )

  perm_summary <- tibble(
    plate_key = plate_key_value,
    plateid = wells$plateid[1],
    elution = wells$elution[1],
    adj_abs_diff_mean_obs = observed_metrics$adj_abs_diff_mean,
    adj_abs_diff_mean_perm_mean = summarise_perm(perm_metrics$adj_abs_diff_mean, observed_metrics$adj_abs_diff_mean)$perm_mean,
    adj_abs_diff_mean_perm_sd = summarise_perm(perm_metrics$adj_abs_diff_mean, observed_metrics$adj_abs_diff_mean)$perm_sd,
    adj_abs_diff_mean_p_value = summarise_perm(perm_metrics$adj_abs_diff_mean, observed_metrics$adj_abs_diff_mean)$p_value,
    adj_abs_diff_median_obs = observed_metrics$adj_abs_diff_median,
    adj_abs_diff_median_perm_mean = summarise_perm(perm_metrics$adj_abs_diff_median, observed_metrics$adj_abs_diff_median)$perm_mean,
    adj_abs_diff_median_perm_sd = summarise_perm(perm_metrics$adj_abs_diff_median, observed_metrics$adj_abs_diff_median)$perm_sd,
    adj_abs_diff_median_p_value = summarise_perm(perm_metrics$adj_abs_diff_median, observed_metrics$adj_abs_diff_median)$p_value,
    cluster_mismatch_obs = observed_metrics$cluster_mismatch_rate,
    cluster_mismatch_perm_mean = summarise_perm(perm_metrics$cluster_mismatch_rate, observed_metrics$cluster_mismatch_rate)$perm_mean,
    cluster_mismatch_perm_sd = summarise_perm(perm_metrics$cluster_mismatch_rate, observed_metrics$cluster_mismatch_rate)$perm_sd,
    cluster_mismatch_p_value = summarise_perm(perm_metrics$cluster_mismatch_rate, observed_metrics$cluster_mismatch_rate)$p_value
  )

  perm_distribution <- 
    perm_metrics %>%
    mutate(
      plate_key = plate_key_value,
      plateid = wells$plateid[1],
      elution = wells$elution[1]
    )

  list(
    metrics = metrics_row,
    perm_summary = perm_summary,
    perm_dist = perm_distribution
  )
}

plate_results <- purrr::map2(
  plate_groups,
  plate_keys$plate_key,
  compute_plate_metrics
)

plate_metrics <- purrr::map_dfr(plate_results, "metrics")
plate_permutation_summary <- purrr::map_dfr(plate_results, "perm_summary")
plate_permutation_distributions <- purrr::map_dfr(plate_results, "perm_dist")

#### DIAGNOSTIC OUTPUTS ####
missing_coords_summary <- missing_plate_coords %>%
  summarise(
    diagnostic = "missing_plate_coordinates",
    count = n(),
    example_ids = paste(head(unique(extraction_id), 10), collapse = ";")
  )

duplicate_wells_summary <- duplicate_wells %>%
  summarise(
    diagnostic = "duplicate_plate_wells",
    count = n(),
    example_plate_keys = paste(head(unique(plate_key), 10), collapse = ";")
  )

plate_counts <- plate_wells %>%
  group_by(plate_key, plateid, elution) %>%
  summarise(
    n_wells = n(),
    n_missing_admixedness = sum(is.na(admixedness)),
    .groups = "drop"
  )

plate_diagnostics <- bind_rows(
  missing_coords_summary,
  duplicate_wells_summary
)

#### EXPORT OUTPUTS ####
readr::write_csv(
  plate_metrics,
  file.path(output_dir, "extraction_plate_adjacency_metrics.csv")
)
readr::write_csv(
  plate_permutation_summary,
  file.path(output_dir, "extraction_plate_permutation_summary.csv")
)
readr::write_csv(
  plate_permutation_distributions,
  file.path(output_dir, "extraction_plate_permutation_distributions.csv")
)
readr::write_csv(
  plate_diagnostics,
  file.path(output_dir, "extraction_plate_diagnostics.csv")
)
readr::write_csv(
  plate_counts,
  file.path(output_dir, "extraction_plate_counts.csv")
)
