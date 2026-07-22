library(tidyverse)
library(pheatmap)
library(here)
library(fs)
library(janitor)
library(readxl)

#### USER DEFINED VARIABLES ####
ngsremix_file <- 
  here(
    "data",
    "ngsRemix",
    "ngsremix_fixed_k3"
  )

path_output <- 
  here(
    "data",
    "ngsRemix",
    "plots"
  )

path_bamlist <- 
  here(
    "data/ngsRemix/bam_list_all_fullpath.txt"
  )

path_admixture <- 
  here(
    "data/och_admixture_values.csv"
  )

path_extractions <- 
  here(
    "data/och_extractions_only.xlsx"
  )

# Make output directory if needed
dir_create(path_output)


#### WRANGLE DATA ####

metadata <-
  read_tsv(
    path_bamlist,
    col_names = FALSE
  ) %>%
  rename("sample" = "X1") %>%
  clean_names() %>%
  mutate(
    sample = 
      basename(sample) %>%
      str_remove(., "\\..*"),
    index = seq(1,length(sample))
  ) %>%
  left_join(
    read_csv(path_admixture) %>%
      clean_names() %>%
      mutate(
        sample = str_remove(sample,"\\..*"),
        cluster = str_to_lower(cluster)
      ) %>%
      pivot_wider(
        names_from = "cluster",
        names_prefix = "prop_",
        values_from = "prop"
      ),
    by = join_by(sample == sample)
  ) %>%
  mutate(
    sample = 
      basename(sample) %>%
      str_remove(., "\\..*"),
    individual_id = 
      str_replace(sample,
                  "Och",
                  "Och\\-") %>%
      str_replace(.,
                  "\\-([AC]...)",
                  "\\-\\1_"),
    index = seq(1,length(sample))
  ) %>%
  select(
    index,
    sample,
    individual_id,
    everything()
  ) %>%
  left_join(
    read_excel(path_extractions) %>%
      select(
        individual_id,
        extraction_id,
        plateid,
        elution1_plateid,
        elution1_plate_row,
        elution1_plate_column
      ) %>%
      mutate(
        well_extraction = 
          str_c(
            elution1_plate_row,
            str_pad(elution1_plate_column, width = 2, side = "left", pad = "0"),
            sep = ""
          )
      ),
    by = join_by(individual_id)
  ) %>%
  select(-contains("elution1")) %>%
  rename(plate_extraction = plateid)

# Derived relatedness
relatedness <- 
  read.table(
    ngsremix_file,
    header = TRUE
  ) %>%
  mutate(
    r = 0.5 * k1 + k2,
    kinship = 0.25 * k1 + 0.5 * k2
  ) %>%
  left_join(
    metadata %>%
      select(
        sample,
        index,
        plate_extraction,
        well_extraction
      ),
    by = join_by(ind1 == index)
  ) %>%
  rename(
    indid1 = sample,
    plate_extraction1 = plate_extraction,
    well_extraction1 = well_extraction
  ) %>%
  left_join(
    metadata %>%
      select(
        sample, 
        index,
        plate_extraction,
        well_extraction
      ),
    by = join_by(ind2 == index)
  ) %>%
  rename(
    indid2 = sample,
    plate_extraction2 = plate_extraction,
    well_extraction2 = well_extraction
  ) %>%
  mutate(
    era1 = 
      str_sub(indid1,4,4),
    era2 = 
      str_sub(indid2,4,4),
    pop1 = 
      str_sub(indid1,4,7),
    pop2 = 
      str_sub(indid2,4,7),
    Well_extr_indid1 = 
      str_c(
        well_extraction1,
        str_remove(indid1,"Och")
      ),
    Well_extr_indid2 = 
      str_c(
        well_extraction2,
        str_remove(indid2,"Och")
      ),
    
    well_extr_row1 = match(str_sub(as.character(well_extraction1), 1, 1), LETTERS),
    well_extr_row2 = match(str_sub(as.character(well_extraction2), 1, 1), LETTERS),
    
    well_extr_col1 = parse_number(as.character(well_extraction1)),
    well_extr_col2 = parse_number(as.character(well_extraction2)),
    
    well_extr_distance = case_when(
      plate_extraction1 == plate_extraction2 ~
        sqrt(
          (well_extr_row1 - well_extr_row2)^2 +
            (well_extr_col1 - well_extr_col2)^2
        ),
      TRUE ~ NA_real_
    )
  )


#### Plotting Functions ####

ggheatmap <-
  function(
    data = relatedness, 
    pop1_col = pop1,
    pop2_col = pop2,
    popsmpl = "ATum",
    x_col = indid2, 
    y_col = indid1,
    fill_col = r
  ){
    
    heatmap_data <-
      data %>%
      filter(
        {{pop1_col}} == 
          popsmpl & 
          {{pop2_col}} == 
          popsmpl
      )
    
    
    heatmap_data_full <-
      bind_rows(
        heatmap_data %>%
          transmute(
            x = {{x_col}},
            y = {{y_col}},
            fill_value = {{fill_col}}
          ),
        heatmap_data %>%
          transmute(
            x = {{y_col}},
            y = {{x_col}},
            fill_value = {{fill_col}}
          )
      ) %>%
      distinct(x, y, .keep_all = TRUE)
    
    heatmap_data_full %>%
    ggplot() +
      aes(
        x= x,
        y = y,
        fill = fill_value
      ) +
      geom_tile() +
      scale_fill_gradient(
        low= "white", 
        high = "red",
        na.value = "grey"
      ) +
      theme(
        axis.text.x = element_text(
          angle = 90,
          hjust = 1,
          vjust = 0.5
        )
      ) +
      labs(
        title = popsmpl,
        x = as_label(enquo(x_col)),
        y = as_label(enquo(y_col)),
        fill = as_label(enquo(fill_col))
      )
  }

#### EXTRACTION HEATMAPS ####

ggheatmap(
  pop1_col = plate_extraction1,
  pop2_col = plate_extraction2,
  popsmpl = "Mix-A_005",
  x_col = Well_extr_indid2,
  y_col = Well_extr_indid1
)

ggheatmap(
  pop1_col = plate_extraction1,
  pop2_col = plate_extraction2,
  popsmpl = "Och-A_001",
  x_col = Well_extr_indid2,
  y_col = Well_extr_indid1
)

ggheatmap(
  pop1_col = plate_extraction1,
  pop2_col = plate_extraction2,
  popsmpl = "Och-C_001",
  x_col = Well_extr_indid2,
  y_col = Well_extr_indid1
)

ggheatmap(
  pop1_col = plate_extraction1,
  pop2_col = plate_extraction2,
  popsmpl = "Mix-C_010",
  x_col = Well_extr_indid2,
  y_col = Well_extr_indid1
)

ggheatmap(
  pop1_col = plate_extraction1,
  pop2_col = plate_extraction2,
  popsmpl = "Och-C_002",
  x_col = Well_extr_indid2,
  y_col = Well_extr_indid1
)

ggheatmap(
  pop1_col = plate_extraction1,
  pop2_col = plate_extraction2,
  popsmpl = "Mix-C_005",
  x_col = Well_extr_indid2,
  y_col = Well_extr_indid1
)

ggheatmap(
  pop1_col = plate_extraction1,
  pop2_col = plate_extraction2,
  popsmpl = "Mix-C_008",
  x_col = Well_extr_indid2,
  y_col = Well_extr_indid1
)

#[1] "Mix-A_005" "Och-A_001" "Och-C_001" 
# "Mix-C_010"
#[5] "Och-C_002" "Mix-C_005" "Mix-C_008"

ggheatmap(popsmpl = "ACat")
ggheatmap(popsmpl = "ACan")
ggheatmap(popsmpl = "ATum")
ggheatmap(popsmpl = "CBur")
ggheatmap(popsmpl = "CCat")
ggheatmap(popsmpl = "CTum")


#[1] "ACan" "ACat" "ATum" "CBur" "CCat" "CTum"


#### SCATTERPLOT R vs Plate Position ####
relatedness %>%
  filter(
    !is.na(well_extr_distance),
    !is.na(r),
    plate_extraction1 == plate_extraction2
  ) %>%
  mutate(
    plate_extraction = plate_extraction1
  ) %>%
  ggplot() +
  aes(
    x = well_extr_distance,
    y = r,
    color = plate_extraction
  ) +
  geom_point(
    alpha = 0.6,
    size = 2
  ) +
  geom_smooth(color = "black") +
  theme_minimal() +
  facet_wrap(plate_extraction ~.) +
  labs(
    title = "Relatedness versus extraction-well distance",
    x = "Distance between wells on extraction plate",
    y = "Relatedness, r",
    color = "Extraction plate"
  )


#### TEST EFFECT of PLATE PROXIMITY on R ####

library(lme4)
library(lmerTest)
library(broom.mixed)

model_df <-
  relatedness %>%
  filter(
    plate_extraction1 == plate_extraction2,
    !is.na(r),
    !is.na(well_extraction1),
    !is.na(well_extraction2),
    indid1 != indid2
  ) %>%
  mutate(
    plate_extraction = factor(plate_extraction1),
    
    row1 = match(str_sub(as.character(well_extraction1), 1, 1), LETTERS),
    row2 = match(str_sub(as.character(well_extraction2), 1, 1), LETTERS),
    
    col1 = parse_number(as.character(well_extraction1)),
    col2 = parse_number(as.character(well_extraction2)),
    
    row_distance = abs(row1 - row2),
    col_distance = abs(col1 - col2),
    
    well_extr_distance = sqrt(row_distance^2 + col_distance^2),
    
    same_row = row_distance == 0,
    same_col = col_distance == 0,
    
    era_pair = map2_chr(
      era1,
      era2,
      ~ str_c(sort(c(.x, .y)), collapse = "_")
    ) %>%
      factor(),
    
    indid1 = factor(indid1),
    indid2 = factor(indid2)
  )


m_row_col <-
  lmer(
    r ~ row_distance +
      col_distance +
      era_pair +
      (1 | plate_extraction) +
      (1 | indid1) +
      (1 | indid2),
    data = model_df,
    REML = FALSE
  )

summary(m_row_col)
anova(m_row_col)


m_no_spatial <-
  lmer(
    r ~ era_pair +
      (1 | plate_extraction) +
      (1 | indid1) +
      (1 | indid2),
    data = model_df,
    REML = FALSE
  )

anova(m_no_spatial, m_row_col)


m_no_row <-
  update(m_row_col, . ~ . - row_distance)

m_no_col <-
  update(m_row_col, . ~ . - col_distance)

anova(m_no_row, m_row_col)
anova(m_no_col, m_row_col)

tidy(
  m_row_col,
  effects = "fixed",
  conf.int = TRUE
) %>%
  filter(term %in% c("row_distance", "col_distance"))


m_same_row_col <-
  lmer(
    r ~ same_row +
      same_col +
      era_pair +
      (1 | plate_extraction) +
      (1 | indid1) +
      (1 | indid2),
    data = model_df,
    REML = FALSE
  )

summary(m_same_row_col)
anova(m_same_row_col)


#### Directional Cross Contamination in Extraction using Relatedness ####

pipette_df <-
  model_df %>%
  mutate(
    same_channel = row_distance == 0,
    col_lag = abs(col1 - col2),
    
    col_early = pmin(col1, col2),
    col_late  = pmax(col1, col2),
    
    later_col_z = as.numeric(scale(col_late)),
    
    same_row_lag1 = same_channel & col_lag == 1,
    same_row_lag2 = same_channel & col_lag == 2,
    same_row_lag3plus = same_channel & col_lag >= 3,
    
    same_col_diff_row = row_distance > 0 & col_lag == 0,
    
    same_row_inv_lag = if_else(
      same_channel & col_lag > 0,
      1 / col_lag,
      0
    ),
    
    same_row_inv_lag_late_col =
      same_row_inv_lag * later_col_z
  )

m_pipette_lag <-
  lmer(
    r ~ same_row_lag1 +
      same_row_lag2 +
      same_row_lag3plus +
      same_col_diff_row +
      era_pair +
      (1 | plate_extraction) +
      (1 | indid1) +
      (1 | indid2),
    data = pipette_df,
    REML = FALSE
  )

summary(m_pipette_lag)
anova(m_pipette_lag)


m_row_col <-
  lmer(
    r ~ row_distance +
      col_distance +
      era_pair +
      (1 | plate_extraction) +
      (1 | indid1) +
      (1 | indid2),
    data = pipette_df,
    REML = FALSE
  )

m_pipette_direction <-
  lmer(
    r ~ row_distance +
      col_distance +
      same_row_inv_lag +
      same_row_inv_lag_late_col +
      era_pair +
      (1 | plate_extraction) +
      (1 | indid1) +
      (1 | indid2),
    data = pipette_df,
    REML = FALSE
  )

anova(m_row_col, m_pipette_direction)
summary(m_pipette_direction)

pipette_df %>%
  filter(same_channel) %>%
  ggplot() +
  aes(
    x = col_lag,
    y = r,
    color = plate_extraction
  ) +
  geom_jitter(
    width = 0.08,
    height = 0,
    alpha = 0.5
  ) +
  geom_smooth(
    aes(group = 1),
    method = "lm",
    se = TRUE,
    color = "black"
  ) +
  theme_minimal() +
  labs(
    title = "Relatedness among wells in the same pipettor channel",
    x = "Column lag",
    y = "Relatedness, r",
    color = "Extraction plate"
  )


pipette_df %>%
  filter(same_channel) %>%
  group_by(
    plate_extraction,
    potential_recipient_col = col_late
  ) %>%
  summarise(
    mean_r_to_upstream = mean(r, na.rm = TRUE),
    n_pairs = n(),
    .groups = "drop"
  ) %>%
  ggplot() +
  aes(
    x = potential_recipient_col,
    y = mean_r_to_upstream,
    color = plate_extraction
  ) +
  geom_point(size = 2) +
  geom_smooth(
    method = "lm",
    se = FALSE
  ) +
  theme_minimal() +
  labs(
    title = "Mean relatedness to upstream wells",
    x = "Potential recipient column",
    y = "Mean r to upstream wells",
    color = "Extraction plate"
  )

#### Refit the baseline model using pipette_df:####

m_row_col_pipette_df <-
  lmer(
    r ~ row_distance +
      col_distance +
      era_pair +
      (1 | plate_extraction) +
      (1 | indid1) +
      (1 | indid2),
    data = pipette_df,
    REML = FALSE
  )

anova(m_row_col_pipette_df, m_pipette_direction)

#### only same-row adjacent pairs: ####

pipette_df %>%
  filter(
    same_channel,
    col_lag == 1
  ) %>%
  mutate(
    potential_recipient_col = col_late
  ) %>%
  ggplot() +
  aes(
    x = potential_recipient_col,
    y = r,
    color = plate_extraction
  ) +
  geom_jitter(
    width = 0.08,
    height = 0,
    alpha = 0.6
  ) +
  geom_smooth(
    method = "lm",
    se = FALSE
  ) +
  theme_minimal() +
  labs(
    title = "Relatedness between adjacent same-row wells",
    x = "Potential recipient column",
    y = "Relatedness, r",
    color = "Extraction plate"
  )

adjacent_df <-
  pipette_df %>%
  filter(
    same_channel,
    col_lag == 1
  ) %>%
  mutate(
    potential_recipient_col = col_late
  )

m_adjacent_direction <-
  lmer(
    r ~ potential_recipient_col +
      era_pair +
      (1 | plate_extraction) +
      (1 | indid1) +
      (1 | indid2),
    data = adjacent_df,
    REML = FALSE
  )

summary(m_adjacent_direction)

#### MATRIX FUNCTIONS ####

make_matrix <- 
  function(df, value_col) {
    all_ids <- sort(unique(c(df$indid1, df$indid2)))
    
    mat <- matrix(NA, nrow = length(all_ids), ncol = length(all_ids))
    rownames(mat) <- all_ids
    colnames(mat) <- all_ids
    
    for (i in seq_len(nrow(df))) {
      id1 <- as.character(df$indid1[i])
      id2 <- as.character(df$indid2[i])
      val <- df[[value_col]][i]
      
      mat[id1, id2] <- val
      mat[id2, id1] <- val
    }
    
    diag(mat) <- NA
    mat
  }

make_matrix_extraction <- 
  function(df, value_col) {
    all_ids <- sort(unique(c(df$well_extraction1, df$wellextraction2)))
    
    mat <- matrix(NA, nrow = length(all_ids), ncol = length(all_ids))
    rownames(mat) <- all_ids
    colnames(mat) <- all_ids
    
    for (i in seq_len(nrow(df))) {
      id1 <- as.character(df$well_extraction1[i])
      id2 <- as.character(df$well_extraction2[i])
      val <- df[[value_col]][i]
      
      mat[id1, id2] <- val
      mat[id2, id1] <- val
    }
    
    diag(mat) <- NA
    mat
  }




#### GENERIC HEATMAPS ####
k1_matrix <- make_matrix(relatedness, "k1")
k2_matrix <- make_matrix(relatedness, "k2")
r_matrix  <- make_matrix(relatedness, "r")
r_matrix_ATum  <- 
  make_matrix(
    filter(relatedness, pop1 == "ATum" & pop2 == "ATum"), 
    "r"
  )
# r_matrix  <- make_matrix(relatedness, "r")

png(
  str_c(
    path_output,
    "/k1_heatmap.png"
  )
)

pheatmap(
  k1_matrix,
  main = "NGSremix k1: one allele shared IBD",
  color = colorRampPalette(c("white", "red"))(100),
  cluster_rows = FALSE,
  cluster_cols = FALSE,
  na_col = "grey"
)

dev.off()

png(
  str_c(
    path_output,
    "/k2_heatmap.png"
  )
)

pheatmap(
  k2_matrix,
  main = "NGSremix k2: two alleles shared IBD",
  color = colorRampPalette(c("white", "red"))(100),
  cluster_rows = FALSE,
  cluster_cols = FALSE,
  na_col = "grey"
)

dev.off()

png(
  str_c(
    path_output,
    "/relatedness_heatmap.png"
  )
)

pheatmap(
  r_matrix,
  main = "NGSremix relatedness: r = 0.5*k1 + k2",
  color = colorRampPalette(c("white", "red"))(100),
  cluster_rows = FALSE,
  cluster_cols = FALSE,
  na_col = "grey"
)

dev.off()

png(
  str_c(
    path_output,
    "/relatedness_heatmap_ATum.png"
  )
)

pheatmap(
  r_matrix_ATum,
  main = "NGSremix relatedness: r = 0.5*k1 + k2",
  color = colorRampPalette(c("white", "red"))(100),
  cluster_rows = FALSE,
  cluster_cols = FALSE,
  na_col = "grey"
)

dev.off()

png(
  str_c(
    path_output,
    "/relatedness_heatmap.png"
  )
)

pheatmap(
  r_matrix,
  main = "NGSremix relatedness: r = 0.5*k1 + k2",
  color = colorRampPalette(c("white", "red"))(100),
  cluster_rows = FALSE,
  cluster_cols = FALSE,
  na_col = "grey"
)

dev.off()




