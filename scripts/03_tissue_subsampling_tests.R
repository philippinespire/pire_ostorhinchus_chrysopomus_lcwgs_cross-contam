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
library(ggplot2)

output_dir <- "output"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

n_permutations <- 1000

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
    max_prop,
    dominant_cluster,
    K1,K2,K3,K4,
    conflict_flag
  )

extractions_key <- 
  extractions_raw %>%
  transmute(
    individual_id,
    extraction_id,
    date_subsampling,
    subsampler,
    date_subsampling_date = as.Date(stringr::str_sub(date_subsampling, 1, 10)),
    individual_key = stringr::str_replace_all(individual_id, "[-_]", ""),
    individual_num = suppressWarnings(as.integer(stringr::str_extract(individual_id, "\\d+")))
  )

subsampling_joined <- 
  extractions_key %>%
  left_join(admixture_metrics, by = "individual_key")

subsampling_grouped <- 
  subsampling_joined %>%
  arrange(date_subsampling_date, subsampler, individual_num, individual_id) %>%
  group_by(date_subsampling_date, subsampler)

group_list <- 
  subsampling_grouped %>%
  group_split()

group_keys <- 
  subsampling_grouped %>%
  group_keys()

metrics_from_admix <- function(admix_values) {
  n_nonmissing <- length(admix_values)
  adj_abs_diff_mean <- if (n_nonmissing >= 2) {
    mean(abs(diff(admix_values)), na.rm = TRUE)
  } else {
    NA_real_
  }
  adj_abs_diff_median <- if (n_nonmissing >= 2) {
    median(abs(diff(admix_values)), na.rm = TRUE)
  } else {
    NA_real_
  }
  high_low_transition_rate <- if (n_nonmissing >= 2) {
    quantiles <- quantile(admix_values, probs = c(0.33, 0.67), na.rm = TRUE, names = FALSE)
    categories <- dplyr::case_when(
      admix_values <= quantiles[1] ~ "low",
      admix_values >= quantiles[2] ~ "high",
      TRUE ~ "mid"
    )
    transitions <- paste(head(categories, -1), tail(categories, -1), sep = "->")
    mean(transitions %in% c("high->low", "low->high"), na.rm = TRUE)
  } else {
    NA_real_
  }
  rank_values <- if (n_nonmissing > 0) {
    rank(admix_values, ties.method = "average", na.last = "keep")
  } else {
    numeric(0)
  }
  period2_corr <- if (n_nonmissing >= 2) {
    suppressWarnings(cor(rank_values, rep(c(1, -1), length.out = n_nonmissing), use = "pairwise.complete.obs"))
  } else {
    NA_real_
  }
  period3_corr <- if (n_nonmissing >= 3) {
    suppressWarnings(cor(rank_values, rep(c(1, 0, -1), length.out = n_nonmissing), use = "pairwise.complete.obs"))
  } else {
    NA_real_
  }
  tibble(
    adj_abs_diff_mean,
    adj_abs_diff_median,
    high_low_transition_rate,
    period2_corr,
    period3_corr
  )
}

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

#### PERMUTATION TESTS ####
results <- purrr::map2(
  group_list,
  seq_along(group_list),
  function(group_df, index) {
    key_row <- group_keys[index, ]
    group_id <- paste(
      coalesce(as.character(key_row$date_subsampling_date), "NA"),
      coalesce(key_row$subsampler, "NA"),
      sep = "|"
    )
    admix_values <- group_df$admixedness
    admix_nonmissing <- admix_values[!is.na(admix_values)]
    observed_metrics <- metrics_from_admix(admix_nonmissing)
    observed_row <- 
      observed_metrics %>%
      mutate(
        date_subsampling_date = key_row$date_subsampling_date,
        subsampler = key_row$subsampler,
        subsampling_group = group_id,
        n_group = nrow(group_df),
        n_nonmissing_admixedness = length(admix_nonmissing),
        n_missing_admixedness = sum(is.na(admix_values))
      ) %>%
      select(
        subsampling_group,
        date_subsampling_date,
        subsampler,
        n_group,
        n_nonmissing_admixedness,
        n_missing_admixedness,
        adj_abs_diff_mean,
        adj_abs_diff_median,
        high_low_transition_rate,
        period2_corr,
        period3_corr
      )
    perm_metrics <- if (length(admix_nonmissing) >= 2 && n_permutations > 0) {
      purrr::map_dfr(
        seq_len(n_permutations),
        function(perm_index) {
          permuted <- sample(admix_nonmissing)
          metrics_from_admix(permuted) %>%
            mutate(permutation = perm_index)
        }
      )
    } else {
      tibble(
        adj_abs_diff_mean = NA_real_,
        adj_abs_diff_median = NA_real_,
        high_low_transition_rate = NA_real_,
        period2_corr = NA_real_,
        period3_corr = NA_real_,
        permutation = NA_integer_
      )
    }
    perm_metrics_group <- 
      perm_metrics %>%
      mutate(
        subsampling_group = group_id,
        date_subsampling_date = key_row$date_subsampling_date,
        subsampler = key_row$subsampler
      )
    adj_summary <- summarise_perm(
      perm_metrics$adj_abs_diff_mean,
      observed_metrics$adj_abs_diff_mean
    )
    high_low_summary <- summarise_perm(
      perm_metrics$high_low_transition_rate,
      observed_metrics$high_low_transition_rate
    )
    period2_summary <- summarise_perm(
      perm_metrics$period2_corr,
      observed_metrics$period2_corr
    )
    period3_summary <- summarise_perm(
      perm_metrics$period3_corr,
      observed_metrics$period3_corr
    )
    perm_summary_row <- tibble(
      subsampling_group = group_id,
      date_subsampling_date = key_row$date_subsampling_date,
      subsampler = key_row$subsampler,
      adj_abs_diff_mean_obs = observed_metrics$adj_abs_diff_mean,
      adj_abs_diff_mean_perm_mean = adj_summary$perm_mean,
      adj_abs_diff_mean_perm_sd = adj_summary$perm_sd,
      adj_abs_diff_mean_p_value = adj_summary$p_value,
      high_low_transition_obs = observed_metrics$high_low_transition_rate,
      high_low_transition_perm_mean = high_low_summary$perm_mean,
      high_low_transition_perm_sd = high_low_summary$perm_sd,
      high_low_transition_p_value = high_low_summary$p_value,
      period2_corr_obs = observed_metrics$period2_corr,
      period2_corr_perm_mean = period2_summary$perm_mean,
      period2_corr_perm_sd = period2_summary$perm_sd,
      period2_corr_p_value = period2_summary$p_value,
      period3_corr_obs = observed_metrics$period3_corr,
      period3_corr_perm_mean = period3_summary$perm_mean,
      period3_corr_perm_sd = period3_summary$perm_sd,
      period3_corr_p_value = period3_summary$p_value
    )
    list(
      metrics = observed_row,
      perm_summary = perm_summary_row,
      perm_dist = perm_metrics_group
    )
  }
)

#### AGGREGATE OUTPUTS ####
adjacency_metrics <- purrr::map_dfr(results, "metrics")
permutation_summary <- purrr::map_dfr(results, "perm_summary")
permutation_distributions <- purrr::map_dfr(results, "perm_dist")

#### EXPORT OUTPUTS ####
readr::write_csv(
  adjacency_metrics,
  file.path(output_dir, "tissue_subsampling_adjacency_metrics.csv")
)
readr::write_csv(
  permutation_summary,
  file.path(output_dir, "tissue_subsampling_permutation_summary.csv")
)
readr::write_csv(
  permutation_distributions,
  file.path(output_dir, "tissue_subsampling_permutation_distributions.csv")
)

#### VISUALIZATIONS ####
heatmap_data <- 
  admixture_key %>%
  select(individual_key, location, era, K1, K2, K3, K4) %>%
  arrange(location, era, individual_key) %>%
  mutate(individual_key = as.character(individual_key)) %>%
  tidyr::pivot_longer(
    cols = c(K1, K2, K3, K4),
    names_to = "cluster",
    values_to = "prop"
  ) %>%
  mutate(
    cluster = factor(cluster, levels = c("K1", "K2", "K3", "K4")),
    individual_key = factor(individual_key, levels = unique(individual_key))
  )

heatmap_plot <- 
  heatmap_data %>%
  ggplot(aes(x = cluster, y = individual_key, fill = prop)) +
  geom_tile() +
  facet_wrap(era ~ location, scales = "free_y") +
  scale_fill_gradient(low = "white", high = "#0b5fa5", na.value = "grey90") +
  labs(
    title = "Admixture Proportions by Individual",
    subtitle = "Faceted by era and location to contrast biological structure vs contamination",
    x = "Genetic cluster",
    y = "Individual key",
    fill = "Cluster proportion"
  ) +
  theme_minimal() +
  theme(
    panel.grid = element_blank(),
    axis.text.y = element_text(size = 6),
    axis.text.x = element_text(size = 8),
    strip.text = element_text(size = 8)
  )

ggsave(
  filename = file.path(output_dir, "tissue_subsampling_admixture_heatmap.png"),
  plot = heatmap_plot,
  width = 12,
  height = 10,
  units = "in",
  dpi = 300
)

k4_heatmap_data <- 
  admixture_key %>%
  select(individual_key, location, era, K4) %>%
  arrange(location, era, individual_key) %>%
  mutate(individual_key = as.character(individual_key)) %>%
  mutate(individual_key = factor(individual_key, levels = unique(individual_key)))

k4_heatmap_plot <- 
  k4_heatmap_data %>%
  ggplot(aes(x = "K4", y = individual_key, fill = K4)) +
  geom_tile() +
  facet_wrap(era ~ location, scales = "free_y") +
  scale_fill_gradient(low = "white", high = "#b30000", na.value = "grey90") +
  labs(
    title = "K4 Affiliation by Individual",
    subtitle = "Faceted by era and location",
    x = "Cluster",
    y = "Individual key",
    fill = "K4 proportion"
  ) +
  theme_minimal() +
  theme(
    panel.grid = element_blank(),
    axis.text.y = element_text(size = 6),
    axis.text.x = element_text(size = 8),
    strip.text = element_text(size = 8)
  )

ggsave(
  filename = file.path(output_dir, "tissue_subsampling_k4_heatmap.png"),
  plot = k4_heatmap_plot,
  width = 12,
  height = 10,
  units = "in",
  dpi = 300
)
