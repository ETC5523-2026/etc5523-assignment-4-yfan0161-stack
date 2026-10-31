# Calculate quarantine breach risk

Returns the breach risk, relative to the pre-Delta unvaccinated
baseline, for a given R0 and vaccine efficacy. Values between grid
points of
[quarantine_risk](https://ETC5523-2026.github.io/etc5523-assignment-4-yfan0161-stack/reference/quarantine_risk.md)
are obtained by bilinear interpolation.

## Usage

``` r
calculate_risk(r0, ve, digits = 3)
```

## Arguments

- r0:

  Numeric. Basic reproduction number, between 1 and 10. Can be a vector.

- ve:

  Numeric. Vaccine efficacy, between 0 and 0.9. Can be a vector. `r0`
  and `ve` must have length 1 or the same length.

- digits:

  Integer. Number of decimal places to round the result to. Default is
  3.

## Value

Numeric vector: risk multiplier relative to baseline (1 = same as the
baseline).

## Examples

``` r
calculate_risk(r0 = 6, ve = 0.6)
#> [1] 0.74
calculate_risk(r0 = c(2, 4, 6), ve = 0.5)
#> [1] 0.188 0.469 1.010
```
