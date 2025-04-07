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
source("modules/auction_module.R")
source("modules/tech_tree_module.R")

# UI Definition
ui <- fluidPage(
  theme = shinytheme("darkly"),
  useShinyjs(),
  
  # Include custom CSS
  includeCSS("www/custom.css"),
  
  # Include custom JavaScript
  tags$script(src = "simulation.js"),
  
  # Application title
  titlePanel("Insurance Simulation Game"),
  
  # Sidebar with navigation menu
  sidebarLayout(
    sidebarPanel(
      h3("Executive Offices"),
      actionButton("inboxBtn", "CEO's Office (Inbox)", 
                  icon = icon("briefcase"), 
                  class = "btn-block"),
      
      actionButton("simCtrlBtn", "Chief Actuary's Office", 
                  icon = icon("calculator"), 
                  class = "btn-block"),
      
      actionButton("riskBtn", "CRO's Office", 
                  icon = icon("shield-alt"), 
                  class = "btn-block"),
      
      actionButton("auctionBtn", "CFO's Office", 
                  icon = icon("chart-line"), 
                  class = "btn-block"),
      
      actionButton("analyticsBtn", "Analytics Dashboard", 
                  icon = icon("chart-bar"), 
                  class = "btn-block"),
      
      actionButton("techTreeBtn", "Tech Tree & Skills", 
                  icon = icon("project-diagram"), 
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
      
      # Hidden profile button that will be triggered programmatically
      div(style = "display: none;",
        actionButton("profileBtn", "Executive Profile", icon = icon("user"))
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
  
  observeEvent(input$riskBtn, {
    output$mainContent <- renderUI({
      riskManagementUI()
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
  
  observeEvent(input$auctionBtn, {
    output$mainContent <- renderUI({
      auctionUI("auction")
    })
  })
  
  observeEvent(input$adminBtn, {
    output$mainContent <- renderUI({
      adminUIModule("adminPanel")
    })
  })
  
  observeEvent(input$techTreeBtn, {
    output$mainContent <- renderUI({
      techTreeUI("techTree")
    })
    
    # Add test buttons to showcase skill point events
    if (input$isAdmin) {
      insertUI(
        selector = "#mainContent",
        where = "beforeEnd",
        ui = div(
          style = "margin-top: 20px; padding: 15px; background-color: #333; border: 1px solid #555;",
          h3("Admin: Skill Point Event Testing"),
          p("Use these buttons to simulate skill point award events:"),
          div(
            style = "display: flex; gap: 10px;",
            actionButton("testPerformanceEvent", "Simulate Performance Achievement", class = "btn-info"),
            actionButton("testInnovationEvent", "Simulate Innovation Event", class = "btn-success"),
            actionButton("testEducationalEvent", "Simulate Educational Event", class = "btn-warning")
          )
        )
      )
    }
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
  
  # Initialize auction module
  auctionData <- auctionServer("auction", userProfile, gameData)
  
  # Initialize tech tree module
  techTreeData <- techTreeServer("techTree", userProfile, gameData)
  
  # Export profile initialization status to UI
  output$profileInitialized <- reactive({
    userProfile$initialized
  })
  outputOptions(output, "profileInitialized", suspendWhenHidden = FALSE)
  
  # Inbox UI - CEO's Office
  inboxUI <- function() {
    tagList(
      h2("CEO's Office - Inbox"),
      p("Messages from C-suite executives and external stakeholders will appear here."),
      
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
      ),
      
      # New auction-related inbox message
      div(class = "inbox-message",
        h4("Asset and Risk Management Auctions Available"),
        p(class = "inbox-message-sender", "From: CFO and CRO Offices"),
        p("We have identified several investment opportunities and risk management tools that could strengthen our portfolio and reduce our risk exposure. Visit the CFO's Office to participate in auctions."),
        p(class = "inbox-message-time", "Received: Today at 10:45 AM"),
        actionButton("goToAuctionsBtn", "Visit CFO's Office", class = "btn-sm btn-info")
      )
    )
  }
  
  # Observer for the "Go to Auctions" button in the inbox
  observeEvent(input$goToAuctionsBtn, {
    output$mainContent <- renderUI({
      auctionUI("auction")
    })
  })
  
  # Chief Actuary's Office UI
  simulationControlsUI <- function() {
    tagList(
      h2("Chief Actuary's Office - Premium Pricing"),
      p("Set premium rates for different insurance products across regions."),
      
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
      
      # Save button
      div(style = "margin-top: 20px;",
        actionButton("savePricingDecisions", "Save Pricing Decisions", class = "btn-primary")
      )
    )
  }
  
  # CRO's Office UI
  riskManagementUI <- function() {
    tagList(
      h2("CRO's Office - Risk Management"),
      p("Manage risk exposure and implement risk mitigation strategies."),
      
      # Risk management sliders
      h3("Risk Management Strategy"),
      fluidRow(
        column(6, 
              div(class = "metric-card",
                p(class = "metric-title", "Reinsurance Level"),
                span(class = "metric-value", "50"),
                span(class = "metric-unit", "%"),
                sliderInput("reinsuranceSlider", NULL,
                           min = 0, max = 100, value = 50, step = 5, post = "%")
              )
        ),
        column(6, 
              div(class = "metric-card",
                p(class = "metric-title", "Risk Mitigation Investment"),
                span(class = "metric-value", "5"),
                span(class = "metric-unit", "%"),
                sliderInput("riskMitigationSlider", NULL,
                           min = 1, max = 10, value = 5, step = 1, post = "%")
              )
        )
      ),
      
      h3("Regional Risk Exposure"),
      fluidRow(
        column(4, 
              div(class = "metric-card",
                p(class = "metric-title", "Iowa"),
                selectInput("iowaRiskExposure", NULL,
                           choices = c("Low" = "low", 
                                      "Medium" = "medium", 
                                      "High" = "high"),
                           selected = "medium")
              )
        ),
        column(4, 
              div(class = "metric-card",
                p(class = "metric-title", "Georgia"),
                selectInput("georgiaRiskExposure", NULL,
                           choices = c("Low" = "low", 
                                      "Medium" = "medium", 
                                      "High" = "high"),
                           selected = "medium")
              )
        ),
        column(4, 
              div(class = "metric-card",
                p(class = "metric-title", "Florida"),
                selectInput("floridaRiskExposure", NULL,
                           choices = c("Low" = "low", 
                                      "Medium" = "medium", 
                                      "High" = "high"),
                           selected = "medium")
              )
        )
      ),
      
      # Save button
      div(style = "margin-top: 20px;",
        actionButton("saveRiskDecisions", "Save Risk Management Decisions", class = "btn-primary")
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
  observeEvent(input$savePricingDecisions, {
    if (!userProfile$initialized) {
      showNotification("Please set up your profile first.", type = "warning")
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
      )
    )
    
    # Save decisions to file
    success <- save_player_decision(userProfile$player_id, decision_data, gameData$currentTurn)
    
    if (success) {
      showNotification("Pricing decisions saved successfully!", type = "message")
    } else {
      showNotification("Error saving pricing decisions. Please try again.", type = "error")
    }
  })
  
  # Save risk management decisions
  observeEvent(input$saveRiskDecisions, {
    if (!userProfile$initialized) {
      showNotification("Please set up your profile first.", type = "warning")
      return()
    }
    
    # Create risk management data structure
    risk_data <- list(
      reinsurance_level = input$reinsuranceSlider,
      risk_mitigation = input$riskMitigationSlider,
      regional_exposure = list(
        Iowa = input$iowaRiskExposure,
        Georgia = input$georgiaRiskExposure,
        Florida = input$floridaRiskExposure
      )
    )
    
    # Save decisions to file
    success <- save_player_decision(userProfile$player_id, risk_data, gameData$currentTurn)
    
    if (success) {
      showNotification("Risk management decisions saved successfully!", type = "message")
    } else {
      showNotification("Error saving risk management decisions. Please try again.", type = "error")
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
  
  # Update the userProfile reactiveValues to include skills
  observe({
    if (userProfile$initialized && !is.null(userProfile$player_id) && is.null(userProfile$skills)) {
      userProfile$skills <- load_player_skills(userProfile$player_id)
    }
  })
  
  # Test event handlers
  observeEvent(input$testPerformanceEvent, {
    if (userProfile$initialized && !is.null(userProfile$player_id)) {
      # Award a skill point for performance achievement
      techTreeData <- techTreeServer("techTree", userProfile, gameData)
      tech_tree_result <- techTreeData()
      result <- tech_tree_result$awardPoints(1, "Achieved quarterly profit target")
      
      if (result) {
        showNotification("Performance achievement recognized! You earned 1 skill point.", type = "message")
        
        # Add inbox message about the achievement
        insertUI(
          selector = ".inbox-message:first-child",
          where = "beforeBegin",
          ui = div(class = "inbox-message",
            h4("Quarterly Performance Achievement"),
            p(class = "inbox-message-sender", "From: CFO Office"),
            p("Congratulations! Your company has exceeded its quarterly profit targets. As a result, you've earned a skill point to invest in your executive capabilities."),
            p(class = "inbox-message-time", paste0("Received: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S")))
          )
        )
      }
    } else {
      showNotification("Please set up your profile first.", type = "warning")
    }
  })
  
  observeEvent(input$testInnovationEvent, {
    if (userProfile$initialized && !is.null(userProfile$player_id)) {
      # Award two skill points for innovation
      techTreeData <- techTreeServer("techTree", userProfile, gameData)
      tech_tree_result <- techTreeData()
      result <- tech_tree_result$awardPoints(2, "Successfully implemented digital platform initiative")
      
      if (result) {
        showNotification("Innovation achievement recognized! You earned 2 skill points.", type = "message")
        
        # Add inbox message about the achievement
        insertUI(
          selector = ".inbox-message:first-child",
          where = "beforeBegin",
          ui = div(class = "inbox-message",
            h4("Digital Transformation Success"),
            p(class = "inbox-message-sender", "From: Chief Innovation Officer"),
            p("Your leadership in implementing our new digital platform has been outstanding. The project was completed ahead of schedule and under budget. As recognition, you've been awarded 2 skill points."),
            p(class = "inbox-message-time", paste0("Received: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S")))
          )
        )
      }
    } else {
      showNotification("Please set up your profile first.", type = "warning")
    }
  })
  
  observeEvent(input$testEducationalEvent, {
    if (userProfile$initialized && !is.null(userProfile$player_id)) {
      # Award a skill point for educational achievement
      techTreeData <- techTreeServer("techTree", userProfile, gameData)
      tech_tree_result <- techTreeData()
      result <- tech_tree_result$awardPoints(1, "Completed executive training program")
      
      if (result) {
        showNotification("Educational achievement recognized! You earned 1 skill point.", type = "message")
        
        # Add inbox message about the achievement
        insertUI(
          selector = ".inbox-message:first-child",
          where = "beforeBegin",
          ui = div(class = "inbox-message",
            h4("Executive Education Completed"),
            p(class = "inbox-message-sender", "From: HR Department"),
            p("Congratulations on completing the Advanced Risk Management training program. Your dedication to professional development has earned you 1 skill point to enhance your capabilities."),
            p(class = "inbox-message-time", paste0("Received: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S")))
          )
        )
      }
    } else {
      showNotification("Please set up your profile first.", type = "warning")
    }
  })
}

# Run the application
shinyApp(ui = ui, server = server) 