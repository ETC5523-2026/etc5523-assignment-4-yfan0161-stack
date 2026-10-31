#' Internal: risk lookup grid
#'
#' Reshapes `quarantine_risk` into a matrix (rows = R0, columns = VE).
#' @return A list with elements `r0`, `ve` and `z`.
#' @noRd
risk_grid <- function() {
  d <- quarantineRisk::quarantine_risk
  r0_grid <- sort(unique(d$R0))
  ve_grid <- round(sort(unique(d$VE)), 10)
  z <- matrix(NA_real_, nrow = length(r0_grid), ncol = length(ve_grid))
  z[cbind(match(d$R0, r0_grid), match(round(d$VE, 10), ve_grid))] <- d$beta_ratio
  list(r0 = r0_grid, ve = ve_grid, z = z)
}

#' Calculate quarantine breach risk
#'
#' Returns the breach risk, relative to the pre-Delta unvaccinated baseline,
#' for a given R0 and vaccine efficacy. Values between grid points of
#' [quarantine_risk] are obtained by bilinear interpolation.
#'
#' @param r0 Numeric. Basic reproduction number, between 1 and 10. Can be a
#'   vector.
#' @param ve Numeric. Vaccine efficacy, between 0 and 0.9. Can be a vector.
#'   `r0` and `ve` must have length 1 or the same length.
#' @param digits Integer. Number of decimal places to round the result to.
#'   Default is 3.
#'
#' @return Numeric vector: risk multiplier relative to baseline (1 = same
#'   as the baseline).
#' @export
#'
#' @examples
#' calculate_risk(r0 = 6, ve = 0.6)
#' calculate_risk(r0 = c(2, 4, 6), ve = 0.5)
calculate_risk <- function(r0, ve, digits = 3) {
  if (!is.numeric(r0) || !is.numeric(ve) || length(r0) == 0 || length(ve) == 0) {
    stop("`r0` and `ve` must be non-empty numeric values.", call. = FALSE)
  }
  if (anyNA(r0) || anyNA(ve)) {
    stop("`r0` and `ve` must not contain missing values.", call. = FALSE)
  }
  n <- max(length(r0), length(ve))
  if (!(length(r0) %in% c(1, n)) || !(length(ve) %in% c(1, n))) {
    stop("`r0` and `ve` must have length 1 or the same length.", call. = FALSE)
  }

  g <- risk_grid()
  r_rng <- range(g$r0)
  v_rng <- range(g$ve)
  tol <- 1e-8
  if (any(r0 < r_rng[1] - tol | r0 > r_rng[2] + tol)) {
    stop("R0 must be between ", r_rng[1], " and ", r_rng[2], ".", call. = FALSE)
  }
  if (any(ve < v_rng[1] - tol | ve > v_rng[2] + tol)) {
    stop("Vaccine efficacy must be between ", v_rng[1], " and ", v_rng[2], ".",
         call. = FALSE)
  }

  r0 <- rep_len(pmin(pmax(r0, r_rng[1]), r_rng[2]), n)
  ve <- rep_len(pmin(pmax(ve, v_rng[1]), v_rng[2]), n)

  i <- pmin(findInterval(r0, g$r0), length(g$r0) - 1)
  j <- pmin(findInterval(ve, g$ve), length(g$ve) - 1)
  fr <- (r0 - g$r0[i]) / (g$r0[i + 1] - g$r0[i])
  fv <- (ve - g$ve[j]) / (g$ve[j + 1] - g$ve[j])

  out <- (1 - fr) * (1 - fv) * g$z[cbind(i, j)] +
    fr * (1 - fv) * g$z[cbind(i + 1, j)] +
    (1 - fr) * fv * g$z[cbind(i, j + 1)] +
    fr * fv * g$z[cbind(i + 1, j + 1)]

  round(out, digits)
}

#' Minimum vaccine efficacy needed to reach a target risk
#'
#' For a given R0, finds the smallest vaccine efficacy (VE) at which the
#' interpolated breach risk is at or below `target` times the baseline.
#' The risk curve is interpolated linearly between VE grid points, and the
#' first VE at which the curve reaches the target is returned.
#'
#' @param r0 Single number. Basic reproduction number, between 1 and 10.
#' @param target Single positive number. Acceptable risk as a multiple of the
#'   baseline. Default is 1 (same risk as the pre-Delta unvaccinated baseline).
#'
#' @return A single number: the minimum VE (rounded to 3 decimals). Returns
#'   `0` if the target is already met with no vaccination, and `NA` if the
#'   target is not met even at the highest modelled VE (0.9).
#' @export
#'
#' @examples
#' find_threshold_ve(r0 = 6)
#' find_threshold_ve(r0 = 6, target = 0.5)
#' find_threshold_ve(r0 = 10, target = 0.1)  # NA: not reachable
find_threshold_ve <- function(r0, target = 1) {
  if (!is.numeric(r0) || length(r0) != 1 || is.na(r0)) {
    stop("`r0` must be a single non-missing number.", call. = FALSE)
  }
  if (!is.numeric(target) || length(target) != 1 || is.na(target) || target <= 0) {
    stop("`target` must be a single number greater than 0.", call. = FALSE)
  }

  g <- risk_grid()
  r_rng <- range(g$r0)
  if (r0 < r_rng[1] - 1e-8 || r0 > r_rng[2] + 1e-8) {
    stop("R0 must be between ", r_rng[1], " and ", r_rng[2], ".", call. = FALSE)
  }
  r0 <- min(max(r0, r_rng[1]), r_rng[2])

  i <- min(findInterval(r0, g$r0), length(g$r0) - 1)
  fr <- (r0 - g$r0[i]) / (g$r0[i + 1] - g$r0[i])
  row <- (1 - fr) * g$z[i, ] + fr * g$z[i + 1, ]

  k <- which(row <= target)
  if (length(k) == 0) {
    return(NA_real_)
  }
  k <- k[1]
  if (k == 1) {
    return(0)
  }
  ve <- g$ve[k - 1] +
    (row[k - 1] - target) / (row[k - 1] - row[k]) * (g$ve[k] - g$ve[k - 1])
  round(ve, 3)
}