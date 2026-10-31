# Calculate quarantine breach risk

Returns relative breach risk for a given R0 and vaccine efficacy, using
bilinear interpolation from the baseline dataset.

## Usage

``` r
calculate_risk(r0, ve)
```

## Arguments

- r0:

  Numeric. Basic reproduction number, between 1 and 10.

- ve:

  Numeric. Vaccine efficacy, between 0 and 0.9.

## Value

Numeric value: risk multiplier relative to baseline.

## Examples

``` r
calculate_risk(r0 = 6, ve = 0.6)
#> [1] 0.74
```
