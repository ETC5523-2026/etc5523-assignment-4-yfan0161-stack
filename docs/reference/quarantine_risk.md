# quarantine_risk: Quarantine breach risk dataset

Total infection force relative to the pre-Delta unvaccinated baseline,
across combinations of viral transmissibility (R0) and vaccine efficacy
(VE).

## Usage

``` r
quarantine_risk
```

## Format

A data frame with 100 rows and 3 variables:

- R0:

  Basic reproduction number, integer from 1 to 10

- VE:

  Vaccine efficacy, numeric from 0 to 0.9

- beta_ratio:

  Total infection force relative to the pre-Delta unvaccinated baseline
  (1 = baseline)

## Source

Zachreson, C., et al. (2022). COVID-19 in low-tolerance border
quarantine systems: Impact of the Delta variant of SARS-CoV-2. *Science
Advances*, 8(14), eabm3624. <https://doi.org/10.1126/sciadv.abm3624>

## Details

The values were transcribed from Figure 4 of Zachreson et al. (2022);
see `data-raw/DATASET.R` for the preparation script. The baseline
(value 1) is reached at R0 = 3 with no vaccination. The results come
from simulations, so the grid contains some noise and is not perfectly
monotone.
