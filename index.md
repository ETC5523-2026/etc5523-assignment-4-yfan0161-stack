# quarantineRisk

An R package with an interactive Shiny app to explore how viral
transmissibility and vaccine efficacy affect border quarantine breach
risk.

## Installation

You can install the development version of quarantineRisk from GitHub:

``` r

# install.packages("devtools")
devtools::install_github("ETC5523-2026/etc5523-assignment-4-yfan0161-stack")
```

## Usage

### Calculate risk for a single scenario

    library(quarantineRisk)
    calculate_risk(r0 = 6, ve = 0.6)

### Launch the interactive app

    run_app()

## Data source

Data is adapted from Zachreson et al. (2022), *COVID-19 in low-tolerance
border quarantine systems*, Science Advances.

## Website

Full documentation:
<https://ETC5523-2026.github.io/etc5523-assignment-4-yfan0161-stack/>

## AI-use declaration

Generative AI declaration: I used ChatGPT to suggest Shiny UI layout
alternatives and help debug package build errors. I checked and revised
all generated code and text.
