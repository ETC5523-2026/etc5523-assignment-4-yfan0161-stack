# Quarantine breach risk dataset

Total infection force relative to baseline, across different values of
viral transmissibility (R0) and vaccine efficacy (VE).

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

  Total infection force relative to pre-Delta unvaccinated baseline

## Source

Zachreson et al. (2022). COVID-19 in low-tolerance border quarantine
systems. *Science Advances*.
