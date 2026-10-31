# Reproducible preparation of the `quarantine_risk` dataset.
# Source: Zachreson et al. (2022), "COVID-19 in low-tolerance border quarantine
# systems", Science Advances. Values transcribed from <FIGURE/TABLE NUMBER>
# of the paper into data-raw/zachreson2022_beta_ratio.csv
# (rows = R0, columns = vaccine efficacy).
# Run from the package root:  source("data-raw/DATASET.R")

library(readr)
library(dplyr)
library(tidyr)

raw <- read_csv("data-raw/zachreson2022_beta_ratio.csv", show_col_types = FALSE)

quarantine_risk <- raw |>
  pivot_longer(-R0, names_to = "VE", values_to = "beta_ratio") |>
  mutate(R0 = as.integer(R0), VE = as.numeric(VE)) |>
  arrange(R0, VE)

# Sanity checks
stopifnot(
  nrow(quarantine_risk) == 100,
  !anyNA(quarantine_risk),
  all(quarantine_risk$beta_ratio > 0),
  all(quarantine_risk$R0 %in% 1:10),
  all(quarantine_risk$VE >= 0 & quarantine_risk$VE <= 0.9)
)

usethis::use_data(quarantine_risk, overwrite = TRUE)
