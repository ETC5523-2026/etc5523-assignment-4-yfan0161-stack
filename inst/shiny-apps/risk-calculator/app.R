library(shiny)
library(ggplot2)
library(bslib)

ui <- fluidPage(
  theme = bs_theme(bootswatch = "minty"),
  titlePanel("Border Quarantine Breach Risk Calculator"),
  
  sidebarLayout(
    sidebarPanel(
      h4("Adjust parameters"),
      
      sliderInput("r0", "Virus transmissibility (R₀)",
                  min = 1, max = 10, value = 6, step = 0.1),
      numericInput("r0_num", "Or enter exact R₀ value", value = 6, min = 0, max = 15),
      
      sliderInput("ve", "Vaccine efficacy",
                  min = 0, max = 0.9, value = 0.6, step = 0.01),
      numericInput("ve_num", "Or enter exact vaccine efficacy", value = 0.6, min = 0, max = 1),
      
      hr(),
      h5("How to use"),
      p("Use the sliders for quick exploration, or type exact values in the boxes above."),
      p("This tool is designed for public health students and policy analysts
        who want to quickly compare quarantine performance under different outbreak scenarios.")
    ),
    
    mainPanel(
      h4("Question this tool helps answer"),
      p("Given a virus's transmissibility and population vaccine coverage,
        will border quarantine keep breach risk at or below pre-Delta baseline levels?"),
      br(),
      
      h3("Current risk level"),
      uiOutput("risk_card"),
      br(),
      
      h3("Risk heatmap"),
      plotOutput("heatmap"),
      br(),
      
      h4("How to interpret the results"),
      p("The white dot on the heatmap marks your current selection.
        Darker green = lower breach risk; brighter yellow = higher breach risk."),
      p("The thick green line is the baseline threshold.
        If your selection falls below the line, quarantine performance is better than the pre-Delta unvaccinated scenario;
        if it falls above, breach risk is elevated and additional measures may be needed.")
    )
  )
)

server <- function(input, output, session) {
  
  # 双向同步滑块和数字输入
  observeEvent(input$r0, {
    updateNumericInput(session, "r0_num", value = input$r0)
  })
  observeEvent(input$r0_num, {
    updateSliderInput(session, "r0", value = input$r0_num)
  })
  observeEvent(input$ve, {
    updateNumericInput(session, "ve_num", value = input$ve)
  })
  observeEvent(input$ve_num, {
    updateSliderInput(session, "ve", value = input$ve_num)
  })
  
  current_risk <- reactive({
    req(input$r0_num, input$ve_num)
    tryCatch({
      calculate_risk(input$r0_num, input$ve_num)
    }, error = function(e) {
      NULL
    })
  })
  
  output$risk_card <- renderUI({
    if (is.null(current_risk())) {
      div(
        style = "padding: 20px; background: #fff3cd; border-radius: 8px;",
        strong("Invalid input"),
        p("R₀ must be between 1 and 10, and vaccine efficacy must be between 0 and 0.9.
          Please check your values and try again.")
      )
    } else {
      val <- current_risk()
      status <- if (val < 1) "Below baseline (safer)" else "Above baseline (elevated risk)"
      color <- if (val < 1) "#2d6a4f" else "#dc3545"
      
      div(
        style = paste0("padding: 24px; border-radius: 8px;
                       border-left: 6px solid ", color, ";
                       background: #f8f9fa;"),
        h2(paste(val, "× baseline")),
        h4(status, style = paste0("color:", color, ";"))
      )
    }
  })
  
  output$heatmap <- renderPlot({
    ggplot(quarantine_risk, aes(x = R0, y = VE)) +
      geom_tile(aes(fill = beta_ratio), color = "white", linewidth = 0.2) +
      geom_contour(aes(z = beta_ratio), breaks = 1,
                   color = "#2d6a4f", linewidth = 1.2) +
      geom_point(x = input$r0_num, y = input$ve_num,
                 color = "white", size = 5, stroke = 2) +
      scale_fill_gradientn(
        colours = c("#2d6a4f", "#52b788", "#95d5b2",
                    "#d8f3dc", "#fff3b0", "#ffd60a"),
        limits = c(0, 7.5),
        name = "Risk relative\nto baseline"
      ) +
      labs(x = "Virus transmissibility (R₀)", y = "Vaccine efficacy") +
      theme_minimal(base_size = 14) +
      theme(
        panel.grid = element_blank(),
        axis.title = element_text(color = "#2d6a4f", face = "bold")
      ) +
      scale_y_continuous(expand = c(0, 0)) +
      scale_x_continuous(expand = c(0, 0), breaks = 1:10)
  })
}

shinyApp(ui = ui, server = server)
