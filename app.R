# Insurance Simulation Game - Main Application File
# Project: Insurance Manager Simulation
# Created: 2025-03-31

# Load required libraries
library(shiny)
library(shinythemes)
library(shinydashboard)
library(plotly)
library(jsonlite)
library(shinyjs)

# Source backend modules
source("backend/simulation.R")
source("backend/data_ops.R")
source("backend/admin_ui.R")
source("modules/profile_module.R")
source("modules/advanced_analytics_module.R")

# UI Definition
ui <- fluidPage(
  theme = shinytheme("darkly"),
  useShinyjs(),
  
  # Include custom CSS
  includeCSS("www/custom.css"),
  
  # Application title
  titlePanel("Insurance Simulation Game"),
  
  # Sidebar with navigation menu
  sidebarLayout(
    sidebarPanel(
      h3("Navigation"),
      actionButton("profileBtn", "Executive Profile", 
                  icon = icon("user"), 
                  class = "btn-block"),
      
      actionButton("inboxBtn", "Inbox", 
                  icon = icon("envelope"), 
                  class = "btn-block"),
      
      actionButton("simCtrlBtn", "Simulation Controls", 
                  icon = icon("sliders"), 
                  class = "btn-block"),
      
      actionButton("analyticsBtn", "Analytics Dashboard", 
                  icon = icon("chart-line"), 
                  class = "btn-block"),
      
      conditionalPanel(
        condition = "input.isAdmin == true",
        hr(),
        actionButton("adminBtn", "Administrator Panel", 
                    icon = icon("cogs"), 
                    class = "btn-block btn-warning")
      ),
      
      hr(),
      conditionalPanel(
        condition = "input.profileBtn > 0 || output.profileInitialized == true",
        h4("Executive Profile"),
        uiOutput("profileSummary")
      ),
      
      checkboxInput("isAdmin", "Enable Admin Mode", value = FALSE)
    ),
    
    # Main panel displays chosen content
    mainPanel(
      uiOutput("mainContent")
    )
  )
)

# Server logic
server <- function(input, output, session) {
  
  # Initialize reactive values
  userProfile <- reactiveValues(
    initialized = FALSE,
    major = NULL,
    gradSchool = NULL,
    university = NULL,
    username = NULL,
    player_id = NULL,
    skills = NULL,
    financial = NULL,
    market = NULL
  )
  
  gameData <- reactiveValues(
    currentTurn = 0,
    gameState = NULL
  )
  
  # Initialize or load game state
  observe({
    latestTurn <- get_latest_turn()
    if (latestTurn > 0) {
      gameData$currentTurn <- latestTurn
      gameData$gameState <- load_game_state(latestTurn)
    }
  })
  
  # Handle navigation button clicks
  observeEvent(input$profileBtn, {
    output$mainContent <- renderUI({
      profileUI("playerProfile")
    })
  })
  
  observeEvent(input$inboxBtn, {
    output$mainContent <- renderUI({
      inboxUI()
    })
  })
  
  observeEvent(input$simCtrlBtn, {
    output$mainContent <- renderUI({
      simulationControlsUI()
    })
  })
  
  observeEvent(input$analyticsBtn, {
    output$mainContent <- renderUI({
      if (input$isAdmin && exists("advancedAnalyticsUI")) {
        advancedAnalyticsUI("advancedAnalytics")
      } else {
        analyticsDashboardUI()
      }
    })
  })
  
  observeEvent(input$adminBtn, {
    output$mainContent <- renderUI({
      adminUIModule("adminPanel")
    })
  })
  
  # Default view on startup
  output$mainContent <- renderUI({
    if (!userProfile$initialized) {
      profileUI("playerProfile")
    } else {
      inboxUI()
    }
  })
  
  # Initialize profile module
  profileData <- profileServer("playerProfile", userProfile)
  
  # Export profile initialization status to UI
  output$profileInitialized <- reactive({
    userProfile$initialized
  })
  outputOptions(output, "profileInitialized", suspendWhenHidden = FALSE)
  
  # Inbox UI
  inboxUI <- function() {
    tagList(
      h2("Inbox"),
      p("Messages from C-suite executives will appear here."),
      
      # Placeholder for inbox messages
      div(class = "inbox-message",
        h4("Welcome to your new role as CEO"),
        p(class = "inbox-message-sender", "From: Board of Directors"),
        p("We're excited to have you lead our insurance company. Your decisions will shape our future success."),
        p(class = "inbox-message-time", "Received: Today at 9:00 AM")
      ),
      
      div(class = "inbox-message",
        h4("Quarterly Financial Results"),
        p(class = "inbox-message-sender", "From: CFO Office"),
        p("I've prepared the quarterly financial results for your review. Our combined ratio is at 95%, which is within our target range."),
        p(class = "inbox-message-time", "Received: Yesterday at 2:30 PM")
      ),
      
      div(class = "inbox-message",
        h4("Risk Management Concerns"),
        p(class = "inbox-message-sender", "From: CRO Office"),
        p("We need to discuss our exposure in Florida. Recent hurricane models suggest we may be underpicing our home insurance products in coastal areas."),
        p(class = "inbox-message-time", "Received: 2 days ago at 11:15 AM")
      )
    )
  }
  
  # Simulation Controls UI
  simulationControlsUI <- function() {
    tagList(
      h2("Simulation Controls"),
      p("Set your strategic parameters for the insurance business."),
      
      # Premium rate adjustment sliders
      h3("Premium Adjustment by Line"),
      fluidRow(
        column(4, 
              div(class = "metric-card",
                p(class = "metric-title", "Home Insurance"),
                span(class = "metric-value", "100"),
                span(class = "metric-unit", "%"),
                sliderInput("homeInsSlider", NULL,
                           min = 80, max = 120, value = 100, step = 1, post = "%")
              )
        ),
        column(4, 
              div(class = "metric-card",
                p(class = "metric-title", "Auto Insurance"),
                span(class = "metric-value", "100"),
                span(class = "metric-unit", "%"),
                sliderInput("autoInsSlider", NULL,
                           min = 80, max = 120, value = 100, step = 1, post = "%")
              )
        ),
        column(4, 
              div(class = "metric-card",
                p(class = "metric-title", "Health Insurance"),
                span(class = "metric-value", "100"),
                span(class = "metric-unit", "%"),
                sliderInput("healthInsSlider", NULL,
                           min = 80, max = 120, value = 100, step = 1, post = "%")
              )
        )
      ),
      
      # Investment portfolio sliders
      h3("Investment Portfolio Allocation"),
      fluidRow(
        column(4, 
              div(class = "metric-card",
                p(class = "metric-title", "Equity Allocation"),
                span(class = "metric-value", "40"),
                span(class = "metric-unit", "%"),
                sliderInput("equitySlider", NULL,
                           min = 0, max = 100, value = 40, step = 5, post = "%")
              )
        ),
        column(4, 
              div(class = "metric-card",
                p(class = "metric-title", "Bond Allocation"),
                span(class = "metric-value", "50"),
                span(class = "metric-unit", "%"),
                sliderInput("bondSlider", NULL,
                           min = 0, max = 100, value = 50, step = 5, post = "%")
              )
        ),
        column(4, 
              div(class = "metric-card",
                p(class = "metric-title", "Cash Allocation"),
                span(class = "metric-value", "10"),
                span(class = "metric-unit", "%"),
                sliderInput("cashSlider", NULL,
                           min = 0, max = 100, value = 10, step = 5, post = "%")
              )
        )
      ),
      
      # Validation message for investment allocation
      htmlOutput("investmentValidation"),
      
      # Save button
      div(style = "margin-top: 20px;",
        actionButton("saveDecisions", "Save Decisions", class = "btn-primary")
      )
    )
  }
  
  # Analytics Dashboard UI
  analyticsDashboardUI <- function() {
    tagList(
      h2("Analytics Dashboard"),
      p("View key performance metrics for your insurance company."),
      
      div(class = "analytics-header",
        actionButton("viewAdvancedAnalyticsBtn", "View Advanced Analytics", class = "btn-info"),
        hr()
      ),
      
      # KPI Cards
      fluidRow(
        column(3,
              div(class = "metric-card positive",
                p(class = "metric-title", "Overall Loss Ratio"),
                span(class = "metric-value", "65"),
                span(class = "metric-unit", "%"),
                p(class = "metric-change text-success", HTML("<i class='fa fa-arrow-down'></i> -5% from last year"))
              )
        ),
        column(3,
              div(class = "metric-card negative",
                p(class = "metric-title", "Combined Ratio"),
                span(class = "metric-value", "98"),
                span(class = "metric-unit", "%"),
                p(class = "metric-change text-danger", HTML("<i class='fa fa-arrow-up'></i> +2% from last year"))
              )
        ),
        column(3,
              div(class = "metric-card positive",
                p(class = "metric-title", "Market Share"),
                span(class = "metric-value", "8.2"),
                span(class = "metric-unit", "%"),
                p(class = "metric-change text-success", HTML("<i class='fa fa-arrow-up'></i> +0.5% from last year"))
              )
        ),
        column(3,
              div(class = "metric-card positive",
                p(class = "metric-title", "Investment Return"),
                span(class = "metric-value", "7.5"),
                span(class = "metric-unit", "%"),
                p(class = "metric-change text-success", HTML("<i class='fa fa-arrow-up'></i> +1.2% from last year"))
              )
        )
      ),
      
      # Example visualizations
      fluidRow(
        column(6,
              h4("Loss Ratio by Insurance Line"),
              plotlyOutput("lossRatioPlot")
        ),
        column(6,
              h4("Combined Ratio Trend"),
              plotlyOutput("combinedRatioPlot")
        )
      ),
      
      fluidRow(
        column(6,
              h4("Investment Performance"),
              plotlyOutput("investmentPlot")
        ),
        column(6,
              h4("Market Share"),
              plotlyOutput("marketSharePlot")
        )
      )
    )
  }
  
  # Profile summary in sidebar
  output$profileSummary <- renderUI({
    if (!userProfile$initialized) {
      return(NULL)
    }
    
    tagList(
      div(class = "executive-card",
        p(class = "executive-detail",
          span(class = "executive-label", "Username: "), 
          userProfile$username
        ),
        p(class = "executive-detail",
          span(class = "executive-label", "Major: "), 
          userProfile$major
        ),
        p(class = "executive-detail",
          span(class = "executive-label", "Grad School: "), 
          userProfile$gradSchool
        ),
        p(class = "executive-detail",
          span(class = "executive-label", "University: "), 
          userProfile$university
        ),
        
        # If skills are available, show them
        if (!is.null(userProfile$skills)) {
          tagList(
            hr(),
            p(class = "executive-detail",
              span(class = "executive-label", "Investing: "), 
              paste0(userProfile$skills$investing, "/10")
            ),
            p(class = "executive-detail",
              span(class = "executive-label", "Risk Mgmt: "), 
              paste0(userProfile$skills$riskManagement, "/10")
            ),
            p(class = "executive-detail",
              span(class = "executive-label", "Marketing: "), 
              paste0(userProfile$skills$marketing, "/10")
            )
          )
        }
      )
    )
  })
  
  # Investment allocation validation
  output$investmentValidation <- renderUI({
    total <- input$equitySlider + input$bondSlider + input$cashSlider
    
    if (total != 100) {
      return(
        div(class = "alert alert-danger",
          strong("Investment allocation must total 100%. "),
          paste0("Current total: ", total, "%")
        )
      )
    } else {
      return(
        div(class = "alert alert-success",
          strong("Investment allocation is valid. "),
          "Total: 100%"
        )
      )
    }
  })
  
  # Sample plot outputs (to be replaced with actual simulation data)
  output$lossRatioPlot <- renderPlotly({
    plot_ly(
      x = c("Home", "Auto", "Health"),
      y = c(65, 72, 81),
      type = "bar",
      marker = list(color = c("#00AEEF", "#00AEEF", "#00AEEF"))
    ) %>% layout(
      title = "Loss Ratio by Line (%)",
      paper_bgcolor = '#1D1D1D',
      plot_bgcolor = '#1D1D1D',
      yaxis = list(gridcolor = '#3D3D3D'),
      xaxis = list(gridcolor = '#3D3D3D'),
      font = list(color = '#FFFFFF')
    )
  })
  
  output$combinedRatioPlot <- renderPlotly({
    plot_ly(
      x = c("Y-3", "Y-2", "Y-1", "Current"),
      y = c(95, 97, 93, 91),
      type = "scatter",
      mode = "lines+markers",
      line = list(color = '#00AEEF'),
      marker = list(color = '#00AEEF')
    ) %>% layout(
      title = "Combined Ratio Trend (%)",
      paper_bgcolor = '#1D1D1D',
      plot_bgcolor = '#1D1D1D',
      yaxis = list(gridcolor = '#3D3D3D'),
      xaxis = list(gridcolor = '#3D3D3D'),
      font = list(color = '#FFFFFF')
    )
  })
  
  output$investmentPlot <- renderPlotly({
    plot_ly(
      labels = c("Equity", "Bonds", "Cash"),
      values = c(40, 50, 10),
      type = "pie",
      marker = list(
        colors = c('#00AEEF', '#28A745', '#FFC107')
      )
    ) %>% layout(
      title = "Investment Allocation",
      paper_bgcolor = '#1D1D1D',
      plot_bgcolor = '#1D1D1D',
      font = list(color = '#FFFFFF')
    )
  })
  
  output$marketSharePlot <- renderPlotly({
    plot_ly(
      x = c("Home", "Auto", "Health"),
      y = c(8.2, 6.7, 4.5),
      type = "bar",
      marker = list(color = c("#00AEEF", "#00AEEF", "#00AEEF"))
    ) %>% layout(
      title = "Market Share by Line (%)",
      paper_bgcolor = '#1D1D1D',
      plot_bgcolor = '#1D1D1D',
      yaxis = list(gridcolor = '#3D3D3D'),
      xaxis = list(gridcolor = '#3D3D3D'),
      font = list(color = '#FFFFFF')
    )
  })
  
  # Save decisions functionality
  observeEvent(input$saveDecisions, {
    if (!userProfile$initialized) {
      showNotification("Please set up your profile first.", type = "warning")
      return()
    }
    
    # Check investment allocation
    total_investment <- input$equitySlider + input$bondSlider + input$cashSlider
    if (total_investment != 100) {
      showNotification("Investment allocation must total 100%.", type = "error")
      return()
    }
    
    # Create decision data structure
    decision_data <- list(
      premium_adjustments = list(
        Home = list(
          Iowa = input$homeInsSlider,
          Georgia = input$homeInsSlider,
          Florida = input$homeInsSlider
        ),
        Auto = list(
          Iowa = input$autoInsSlider,
          Georgia = input$autoInsSlider,
          Florida = input$autoInsSlider
        ),
        Health = list(
          Iowa = input$healthInsSlider,
          Georgia = input$healthInsSlider,
          Florida = input$healthInsSlider
        )
      ),
      investment = list(
        equity_allocation = input$equitySlider,
        bond_allocation = input$bondSlider,
        cash_allocation = input$cashSlider
      ),
      service_quality = 5,  # Default values, would be adjustable in full implementation
      brand_recognition = 5,
      bundling_discount = 0,
      risk_management_quality = 5
    )
    
    # Save decisions to file
    success <- save_player_decision(userProfile$player_id, decision_data, gameData$currentTurn)
    
    if (success) {
      showNotification("Decisions saved successfully!", type = "message")
    } else {
      showNotification("Error saving decisions. Please try again.", type = "error")
    }
  })
  
  # Initialize advanced analytics module if it exists
  if (exists("advancedAnalyticsServer")) {
    advancedAnalyticsServer("advancedAnalytics", userProfile, gameData)
  }
  
  # View advanced analytics button
  observeEvent(input$viewAdvancedAnalyticsBtn, {
    output$mainContent <- renderUI({
      advancedAnalyticsUI("advancedAnalytics")
    })
  })
  
  # Initialize admin module
  adminResults <- adminServerModule("adminPanel", gameData)
  
  # Update gameData when admin module makes changes
  observe({
    adminData <- adminResults()
    gameData$currentTurn <- adminData$currentTurn
    gameData$gameState <- adminData$gameState
  })
}

# Run the application
shinyApp(ui = ui, server = server) 