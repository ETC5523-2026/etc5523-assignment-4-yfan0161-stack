# quarantineRisk

An R package with an interactive Shiny app to explore how viral
transmissibility (R0) and vaccine efficacy (VE) affect border quarantine
breach risk.

**Intended user:** public health students and policy analysts.

**Question the app helps answer:** for a variant with a given R0, how
much vaccine efficacy is needed to keep border-quarantine breach risk at
or below an acceptable level, relative to the pre-Delta unvaccinated
baseline?

## Installation

``` r
# install.packages("devtools")
devtools::install_github("ETC5523-2026/etc5523-assignment-4-yfan0161-stack")
```

## Usage

### Launch the interactive app

``` r
library(quarantineRisk)
run_app()
```

### Calculate risk for a single scenario

``` r
calculate_risk(r0 = 6, ve = 0.6)      # risk relative to baseline
find_threshold_ve(r0 = 6, target = 1) # minimum VE to keep risk <= baseline
```

## Data

The package includes `quarantine_risk`, a 100-row data frame (R0 = 1 to
10, VE = 0 to 0.9) giving total infection force relative to the
pre-Delta unvaccinated baseline (1 = baseline). The values were
transcribed from Figure 4 of Zachreson et al. (2022), *COVID-19 in
low-tolerance border quarantine systems: Impact of the Delta variant of
SARS-CoV-2*, Science Advances, 8(14), eabm3624
(<https://doi.org/10.1126/sciadv.abm3624>), which is open access under a
CC BY 4.0 licence. The raw values and the preparation script are in
`data-raw/`. Values are relative risks from simulation results, not
probabilities of a breach.

## Website

Full documentation:
<https://ETC5523-2026.github.io/etc5523-assignment-4-yfan0161-stack/>

## AI-use declaration

Generative AI declaration: I used ChatGPT to suggest Shiny UI layout
alternatives and help debug package build errors. I used Claude
(Anthropic) to review my package against the assignment criteria and to
suggest revisions to the Shiny app, the
[`find_threshold_ve()`](https://ETC5523-2026.github.io/etc5523-assignment-4-yfan0161-stack/reference/find_threshold_ve.md)
function, tests, documentation and vignette. I checked, tested and
revised all generated code and text.
