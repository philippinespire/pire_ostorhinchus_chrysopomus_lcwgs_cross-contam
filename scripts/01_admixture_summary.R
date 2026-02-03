library(tidyverse)

dir.create("output", showWarnings = FALSE, recursive = TRUE)

admixture_raw <- readr::read_csv(
  "data/och_admixture_values.csv",
  show_col_types = FALSE
)

admixture_long <- admixture_raw %>%
  mutate(
    sample = Sample,
    sample_id = stringr::str_replace(sample, "\\..*$", "")
  ) %>%
  transmute(
    sample_id,
    sample,
    era,
    location,
    cluster = Cluster,
    prop = Prop
  )

cluster_order <- admixture_long %>%
  distinct(cluster) %>%
  arrange(cluster) %>%
  pull(cluster)

admixture_wide <- admixture_long %>%
  mutate(cluster = factor(cluster, levels = cluster_order)) %>%
  tidyr::pivot_wider(
    names_from = cluster,
    values_from = prop
  )

admixture_metrics <- admixture_long %>%
  group_by(sample_id, sample, era, location) %>%
  summarise(
    prop_sum = sum(prop, na.rm = TRUE),
    max_prop = max(prop, na.rm = TRUE),
    dominant_cluster = cluster[which.max(prop)],
    entropy = -sum(if_else(prop > 0, prop * log(prop), 0), na.rm = TRUE),
    effective_clusters = exp(entropy),
    .groups = "drop"
  ) %>%
  mutate(admixedness = 1 - max_prop)

admixture_qc <- admixture_long %>%
  group_by(sample_id, sample, era, location) %>%
  summarise(
    n_clusters = n(),
    prop_sum = sum(prop, na.rm = TRUE),
    prop_sum_diff = prop_sum - 1,
    .groups = "drop"
  )

admixture_summary <- admixture_wide %>%
  left_join(
    admixture_metrics,
    by = c("sample_id", "sample", "era", "location")
  )

readr::write_csv(admixture_long, "output/admixture_long.csv")
readr::write_csv(admixture_metrics, "output/admixture_metrics.csv")
readr::write_csv(admixture_summary, "output/admixture_summary.csv")
readr::write_csv(admixture_qc, "output/admixture_qc.csv")
