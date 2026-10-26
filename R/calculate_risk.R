#' Calculate quarantine breach risk
#'
#' Returns relative breach risk for a given R0 and vaccine efficacy,
#' using bilinear interpolation from the baseline dataset.
#'
#' @param r0 Numeric. Basic reproduction number, between 1 and 10.
#' @param ve Numeric. Vaccine efficacy, between 0 and 0.9.
#'
#' @return Numeric value: risk multiplier relative to baseline.
#' @export
#'
#' @examples
#' calculate_risk(r0 = 6, ve = 0.6)
calculate_risk <- function(r0, ve) {
  if (r0 < 1 || r0 > 10) {
    stop("R0 must be between 1 and 10.")
  }
  if (ve < 0 || ve > 0.9) {
    stop("Vaccine efficacy must be between 0 and 0.9.")
  }

  ve_idx <- round(ve * 10)
  r0_lower <- floor(r0)
  r0_upper <- ceiling(r0)
  ve_lower_idx <- floor(ve * 10)
  ve_upper_idx <- ceiling(ve * 10)

  get_val <- function(r_idx, v_idx) {
    quarantine_risk$beta_ratio[
      quarantine_risk$R0 == r_idx & (round(quarantine_risk$VE * 10) == v_idx)
    ]
  }

  if (r0_lower == r0_upper && ve_lower_idx == ve_upper_idx) {
    return(round(get_val(r0_lower, ve_lower_idx), 3))
  }

  v11 <- get_val(r0_lower, ve_lower_idx)
  v21 <- get_val(r0_upper, ve_lower_idx)
  v12 <- get_val(r0_lower, ve_upper_idx)
  v22 <- get_val(r0_upper, ve_upper_idx)

  if (r0_lower == r0_upper) {
    r_ratio <- 0
  } else {
    r_ratio <- (r0 - r0_lower) / (r0_upper - r0_lower)
  }

  if (ve_lower_idx == ve_upper_idx) {
    v_ratio <- 0
  } else {
    v_ratio <- (ve - ve_lower_idx / 10) / ((ve_upper_idx - ve_lower_idx) / 10)
  }

  v1 <- v11 * (1 - r_ratio) + v21 * r_ratio
  v2 <- v12 * (1 - r_ratio) + v22 * r_ratio
  result <- v1 * (1 - v_ratio) + v2 * v_ratio

  return(round(result, 3))
}

