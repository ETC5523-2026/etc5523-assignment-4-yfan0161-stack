#' Launch the quarantine risk Shiny app
#'
#' Opens an interactive application to explore quarantine breach risk
#' across different transmissibility and vaccine efficacy scenarios.
#'
#' @return No return value; launches the Shiny app in the default browser.
#' @export
#'
#' @examples
#' \dontrun{
#' run_app()
#' }
run_app <- function() {
  app_dir <- system.file("shiny-apps", "risk-calculator", package = "quarantineRisk")
  if (app_dir == "") {
    stop("App directory not found. Reinstall the package.", call. = FALSE)
  }
  shiny::runApp(app_dir, display.mode = "normal")
}
