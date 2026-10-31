# Get started with quarantineRisk

## Installation

You can install the package from GitHub:

``` r

# install.packages("devtools")
devtools::install_github("ETC5523-2026/etc5523-assignment-4-yfan0161-stack")
```

## Load the package

``` r

library(quarantineRisk)
```

## Calculate risk for a specific scenario

Use
[`calculate_risk()`](https://ETC5523-2026.github.io/etc5523-assignment-4-yfan0161-stack/reference/calculate_risk.md)
to get the relative breach risk for a given combination of viral
transmissibility and vaccine efficacy.

``` r

calculate_risk(r0 = 6, ve = 0.6)
#> [1] 0.74
```

The returned value is a multiplier relative to a pre-Delta unvaccinated
baseline.

- Values **below 1** mean the system is safer than baseline.
- Values **above 1** mean elevated breach risk.

For example, at an R₀ of 6 and 50% vaccine efficacy, the risk is
approximately equal to baseline:

``` r

calculate_risk(r0 = 6, ve = 0.5)
#> [1] 1.01
```

## Launch the interactive Shiny app

To explore the full heatmap and adjust parameters in real time, launch
the built-in application:

``` r

run_app()
```

The app provides:

- Two sliders to adjust R₀ and vaccine efficacy
- A numeric summary of current risk level and status
- An interactive heatmap with a marker showing your current selection
- A thick baseline contour line showing where risk equals 1× baseline

## Worked example

At an R₀ of 6 (comparable to the Delta variant) and 50% vaccine
efficacy:

``` r

calculate_risk(r0 = 6, ve = 0.5)
#> [1] 1.01
```

The result is very close to 1, meaning breach risk is roughly equal to
the pre-Delta baseline. If vaccine efficacy drops to 30%, risk rises
well above baseline:

    calculate_risk(r0 = 6, ve = 0.3)

This suggests that for a Delta-like variant, vaccine coverage below 50%
significantly erodes the protective effect of border quarantine.
