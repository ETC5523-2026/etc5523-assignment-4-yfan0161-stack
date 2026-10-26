#' Quarantine breach risk dataset
#'
#' Total infection force relative to baseline, across different values of
#' viral transmissibility (R0) and vaccine efficacy (VE).
#'
#' @format A data frame with 100 rows and 3 variables:
#' \describe{
#'   \item{R0}{Basic reproduction number, integer from 1 to 10}
#'   \item{VE}{Vaccine efficacy, numeric from 0 to 0.9}
#'   \item{beta_ratio}{Total infection force relative to pre-Delta unvaccinated baseline}
#' }
#' @source Zachreson et al. (2022). COVID-19 in low-tolerance border quarantine systems. *Science Advances*.
"quarantine_risk"
