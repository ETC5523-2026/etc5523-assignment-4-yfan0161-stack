library(shiny)
library(ggplot2)
library(bslib)

# Fine grid (interpolated) used only for drawing a smooth heatmap
heat_grid <- expand.grid(R0 = seq(1, 10, by = 0.1), VE = seq(0, 0.9, by = 0.01))
heat_grid$risk <- quarantineRisk::calculate_risk(heat_grid$R0, heat_grid$VE)

# Round the required VE UP to 2 decimals so the displayed value is never
# lower than the true threshold
th_label <- function(th) sprintf("%.2f", ceiling(th * 100 - 1e-9) / 100)

app_css <- "
.app-header {background:#2d6a4f; color:#fff; padding:18px 24px; border-radius:8px; margin-bottom:18px;}
.app-header h2 {margin:0 0 8px 0;}
.app-header p {margin:0 0 4px 0; font-size:1.05rem;}
.result-card {padding:16px 22px; border-radius:8px; background:#f8f9fa; border-left:6px solid #2d6a4f; margin-bottom:12px;}
.result-card.bad {border-left-color:#c1121f;}
.result-card.warn {border-left-color:#e9a100; background:#fff8e1;}
.result-card h2 {margin:2px 0;}
.result-card .status {font-weight:600;}
.note-box {background:#eef7f1; border-radius:8px; padding:12px 16px; margin:6px 0 16px 0;}
"

ui <- fluidPage(
  theme = bs_theme(bootswatch = "minty"),
  tags$head(tags$style(HTML(app_css))),

  div(
    class = "app-header",
    h2("Border Quarantine Breach Risk Explorer"),
    p(strong("Intended user: "),
      "public health students and policy analysts comparing outbreak scenarios."),
    p(strong("Question: "),
      "For a variant with a given transmissibility (R\u2080), how much vaccine
       efficacy is needed to keep border-quarantine breach risk at or below an
       acceptable level, compared with the pre-Delta baseline?")
  ),

  sidebarLayout(
    sidebarPanel(
      width = 4,
      h4("Scenario"),
      sliderInput("r0", "Virus transmissibility (R\u2080)",
                  min = 1, max = 10, value = 6, step = 0.1),
      sliderInput("ve", "Vaccine efficacy (VE)",
                  min = 0, max = 0.9, value = 0.6, step = 0.01),
      numericInput("target", "Acceptable risk (\u00d7 baseline)",
                   value = 1, step = 0.1),
      helpText("1 = the same risk as the pre-Delta, unvaccinated baseline.
                Use 0.5 to require half the baseline risk, or 2 to tolerate
                twice as much.")
    ),

    mainPanel(
      width = 8,
      tabsetPanel(
        tabPanel(
          "Explore",
          br(),
          # Weak state: one clear message instead of repeating it in every output
          uiOutput("target_warning"),
          conditionalPanel(
            condition = "input.target > 0",
            fluidRow(
              column(6, uiOutput("risk_card")),
              column(6, uiOutput("threshold_card"))
            ),
            uiOutput("takeaway"),
            h4("Risk across all scenarios"),
            plotOutput("heatmap", height = "380px"),
            h4("Risk at your chosen R\u2080, across vaccine efficacy"),
            plotOutput("cross", height = "300px")
          )
        ),

        tabPanel(
          "Fields and controls",
          br(),
          h4("Fields"),
          tags$table(
            class = "table table-sm",
            tags$thead(tags$tr(tags$th("Field"), tags$th("Meaning"))),
            tags$tbody(
              tags$tr(tags$td("R\u2080"),
                      tags$td("Basic reproduction number: the average number of people one infected
                               person infects. Higher = more transmissible variant (1 to 10).")),
              tags$tr(tags$td("VE"),
                      tags$td("Vaccine efficacy: the proportion by which vaccination reduces
                               infection (0 = no protection, 0.9 = 90% reduction).")),
              tags$tr(tags$td("Risk (\u00d7 baseline)"),
                      tags$td("Total infection force relative to the pre-Delta unvaccinated
                               baseline (value 1). It is a relative multiplier, not a probability."))
            )
          ),
          h4("Controls"),
          tags$ul(
            tags$li(strong("R\u2080 slider: "), "the transmissibility of the variant you are testing."),
            tags$li(strong("VE slider: "), "the vaccine efficacy in the population."),
            tags$li(strong("Acceptable risk: "), "your tolerance, as a multiple of the baseline.
                    It sets the dashed target line and the required VE. It must be greater than 0;
                    otherwise the app asks you to correct it.")
          )
        ),

        tabPanel(
          "How to interpret",
          br(),
          h4("Reading the outputs"),
          tags$ul(
            tags$li(strong("Risk card: "), "the modelled risk at your R\u2080 and VE, compared with
                    your target. Green border = below target, amber = about equal (within 5%),
                    red = above target."),
            tags$li(strong("Minimum VE card: "), "the lowest VE at which quarantine reaches your
                    target for that R\u2080 (rounded up to two decimals). This is the direct answer
                    to the app's question."),
            tags$li(strong("Heatmap: "), "dark green = low risk, yellow/red = high risk. The dashed
                    line marks your target. Combinations ", em("above and to the left"), " of the line
                    (high VE, low R\u2080) meet the target; those ", em("below and to the right"),
                    " exceed it. The white dot is your selection."),
            tags$li(strong("Line plot: "), "a slice of the heatmap at your R\u2080. The dotted red line
                    is the minimum VE; where the curve crosses the dashed line is the same point.")
          ),
          h4("Limitations"),
          tags$ul(
            tags$li("Values come from published modelling results for low-tolerance quarantine systems;
                    they are relative risks, not predicted probabilities of a breach."),
            tags$li("The data is a 10 \u00d7 10 grid; values between grid points are linearly
                    interpolated."),
            tags$li("The underlying results come from simulations and contain some noise, so the
                    dashed line is not perfectly smooth."),
            tags$li("Use for exploring scenarios and teaching, not for operational decisions.")
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {

  # Weak state: empty / zero / negative target
  target_ok <- reactive({
    is.numeric(input$target) && !is.na(input$target) && input$target > 0
  })

  target <- reactive({
    req(target_ok())
    input$target
  })

  output$target_warning <- renderUI({
    if (!target_ok()) {
      div(
        class = "result-card warn",
        strong("Please enter an acceptable risk greater than 0"),
        p("The acceptable risk is a multiple of the pre-Delta baseline
           (1 = the same risk as the baseline, 0.5 = half, 2 = twice).
           Results will appear once a valid value is entered.")
      )
    }
  })

  risk_now <- reactive({
    quarantineRisk::calculate_risk(input$r0, input$ve)
  })

  threshold <- reactive({
    quarantineRisk::find_threshold_ve(input$r0, target())
  })

  output$risk_card <- renderUI({
    tgt <- target()
    val <- risk_now()
    rel <- val / tgt
    if (abs(rel - 1) <= 0.05) {
      cls <- "warn"; status <- "About equal to your target"
    } else if (rel < 1) {
      cls <- ""; status <- "Below your target (lower risk)"
    } else {
      cls <- "bad"; status <- "Above your target (higher risk)"
    }
    div(
      class = paste("result-card", cls),
      p("Modelled risk for this scenario", style = "margin:0;"),
      h2(paste0(sprintf("%.2f", val), "\u00d7 baseline")),
      div(class = "status", status)
    )
  })

  output$threshold_card <- renderUI({
    tgt <- target()
    th <- threshold()
    if (is.na(th)) {
      div(
        class = "result-card warn",
        strong("Target not reachable"),
        p(paste0("Even at VE = 0.9, risk at R\u2080 = ", input$r0, " stays above ", tgt,
                 "\u00d7 baseline. Try a higher acceptable risk or a lower R\u2080."))
      )
    } else if (th == 0) {
      div(
        class = "result-card",
        p("Minimum VE needed", style = "margin:0;"),
        h2("No vaccination needed"),
        div(class = "status", "Risk already meets your target at this R\u2080.")
      )
    } else {
      div(
        class = "result-card",
        p("Minimum VE needed", style = "margin:0;"),
        h2(paste0("VE \u2265 ", th_label(th))),
        div(class = "status", paste0("to keep risk \u2264 ", tgt, "\u00d7 baseline"))
      )
    }
  })

  output$takeaway <- renderUI({
    tgt <- target()
    th <- threshold()
    val <- risk_now()
    msg <- if (is.na(th)) {
      paste0("At R\u2080 = ", input$r0, ", no modelled vaccine efficacy brings breach risk down to ",
             tgt, "\u00d7 baseline.")
    } else if (th == 0) {
      paste0("At R\u2080 = ", input$r0, ", quarantine meets your target of ", tgt,
             "\u00d7 baseline even without vaccination.")
    } else {
      verdict <- if (input$ve >= th) {
        " meets that requirement."
      } else if (val / tgt <= 1.05) {
        " is just below it (risk is within 5% of your target)."
      } else {
        " falls short of it."
      }
      paste0("At R\u2080 = ", input$r0, ", quarantine stays at or below ", tgt,
             "\u00d7 baseline only if vaccine efficacy is at least ", th_label(th),
             ". Your selected VE of ", input$ve, verdict)
    }
    div(class = "note-box", msg)
  })

  output$heatmap <- renderPlot({
    tgt <- target()
    p <- ggplot(heat_grid, aes(x = R0, y = VE)) +
      geom_raster(aes(fill = risk)) +
      scale_fill_gradientn(
        colours = c("#1b4332", "#52b788", "#d8f3dc", "#fff3b0", "#f4a261", "#c1121f"),
        name = "Risk\n(\u00d7 baseline)"
      ) +
      scale_x_continuous(breaks = 1:10, expand = c(0, 0)) +
      scale_y_continuous(expand = c(0, 0)) +
      labs(x = "Virus transmissibility (R\u2080)", y = "Vaccine efficacy (VE)") +
      theme_minimal(base_size = 14) +
      theme(panel.grid = element_blank(),
            axis.title = element_text(face = "bold"))

    if (tgt >= min(heat_grid$risk) && tgt <= max(heat_grid$risk)) {
      p <- p + geom_contour(aes(z = risk), breaks = tgt,
                            colour = "black", linewidth = 1, linetype = "dashed")
    }

    p + annotate("point", x = input$r0, y = input$ve,
                 shape = 21, size = 5, stroke = 1.5, fill = "white", colour = "black")
  })

  output$cross <- renderPlot({
    tgt <- target()
    th <- threshold()
    d <- data.frame(VE = seq(0, 0.9, by = 0.01))
    d$risk <- quarantineRisk::calculate_risk(input$r0, d$VE)

    p <- ggplot(d, aes(x = VE, y = risk)) +
      geom_hline(yintercept = tgt, linetype = "dashed") +
      geom_line(colour = "#2d6a4f", linewidth = 1.2) +
      annotate("point", x = input$ve, y = risk_now(),
               shape = 21, size = 5, stroke = 1.5, fill = "white", colour = "black") +
      labs(x = "Vaccine efficacy (VE)", y = "Risk (\u00d7 baseline)",
           subtitle = paste0("R\u2080 = ", input$r0, "; dashed line = your target (", tgt, "\u00d7)")) +
      theme_minimal(base_size = 14) +
      theme(axis.title = element_text(face = "bold"))

    if (!is.na(th)) {
      p <- p + geom_vline(xintercept = th, linetype = "dotted",
                          colour = "#c1121f", linewidth = 1)
    }
    p
  })
}

shinyApp(ui = ui, server = server)