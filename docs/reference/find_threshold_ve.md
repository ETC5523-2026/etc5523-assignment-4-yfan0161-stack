# Minimum vaccine efficacy needed to reach a target risk

For a given R0, finds the smallest vaccine efficacy (VE) at which the
interpolated breach risk is at or below `target` times the baseline. The
risk curve is interpolated linearly between VE grid points, and the
first VE at which the curve reaches the target is returned.

## Usage

``` r
find_threshold_ve(r0, target = 1)
```

## Arguments

- r0:

  Single number. Basic reproduction number, between 1 and 10.

- target:

  Single positive number. Acceptable risk as a multiple of the baseline.
  Default is 1 (same risk as the pre-Delta unvaccinated baseline).

## Value

A single number: the minimum VE (rounded to 3 decimals). Returns `0` if
the target is already met with no vaccination, and `NA` if the target is
not met even at the highest modelled VE (0.9).

## Examples

``` r
find_threshold_ve(r0 = 6)
#> [1] 0.504
find_threshold_ve(r0 = 6, target = 0.5)
#> [1] 0.654
find_threshold_ve(r0 = 10, target = 0.1)  # NA: not reachable
#> [1] NA
```
