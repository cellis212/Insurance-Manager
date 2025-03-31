# Insurance Simulation Game - Advanced Analytics Module
# This file contains a Shiny module for advanced analytics features

library(shiny)
library(plotly)
library(forecast)

#' Advanced Analytics UI Module
#' 
#' @param id Namespace ID for the module
#' @return A UI definition for the advanced analytics dashboard
advancedAnalyticsUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    h2("Advanced Analytics Dashboard"),
    p("Gain deeper insights into your insurance company's performance with advanced predictive analytics and scenario modeling."),
    
    tabsetPanel(
      # Predictive Models Tab
      tabPanel("Predictive Models",
        fluidRow(
          column(4,
            div(class = "executive-card",
              h3("Forecast Settings"),
              selectInput(ns("forecastMetric"), "Metric to Forecast:",
                         choices = c("Premium Revenue" = "revenue", 
                                    "Loss Ratio" = "loss_ratio",
                                    "Combined Ratio" = "combined_ratio",
                                    "Market Share" = "market_share")),
              selectInput(ns("forecastHorizon"), "Forecast Horizon:",
                         choices = c("1 Year" = 1, "3 Years" = 3, "5 Years" = 5)),
              selectInput(ns("forecastLine"), "Insurance Line:",
                         choices = c("All Lines" = "all", "Home", "Auto", "Health", "Life", "Annuities")),
              selectInput(ns("forecastRegion"), "Region:",
                         choices = c("All Regions" = "all", "Iowa", "Georgia", "Florida")),
              hr(),
              actionButton(ns("generateForecastBtn"), "Generate Forecast", class = "btn-primary")
            )
          ),
          column(8,
            plotlyOutput(ns("forecastPlot"), height = "300px"),
            div(class = "executive-card",
              h4("Forecast Interpretation"),
              htmlOutput(ns("forecastInterpretation")),
              h5("Confidence Intervals"),
              p("Shaded areas represent the 80% and 95% confidence intervals for the forecast."),
              p("Wider intervals indicate greater uncertainty in future predictions.")
            )
          )
        )
      ),
      
      # Scenario Analysis Tab
      tabPanel("Scenario Analysis",
        fluidRow(
          column(4,
            div(class = "executive-card",
              h3("Scenario Parameters"),
              sliderInput(ns("scenarioMarketCondition"), "Market Condition:",
                         min = -1, max = 1, value = 0, step = 0.1),
              sliderInput(ns("scenarioPremiumAdjustment"), "Premium Adjustment:",
                         min = 80, max = 120, value = 100, step = 1),
              sliderInput(ns("scenarioInvestmentAggression"), "Investment Aggression:",
                         min = 0, max = 10, value = 5, step = 1),
              selectInput(ns("scenarioLine"), "Insurance Line:",
                         choices = c("All Lines" = "all", "Home", "Auto", "Health", "Life", "Annuities")),
              selectInput(ns("scenarioRegion"), "Region:",
                         choices = c("All Regions" = "all", "Iowa", "Georgia", "Florida")),
              actionButton(ns("runScenarioBtn"), "Run Scenario", class = "btn-primary")
            )
          ),
          column(8,
            plotlyOutput(ns("scenarioPlot"), height = "300px"),
            div(class = "executive-card",
              h4("Scenario Results"),
              tableOutput(ns("scenarioTable")),
              h5("Interpretation"),
              htmlOutput(ns("scenarioInterpretation"))
            )
          )
        )
      ),
      
      # Competitive Analysis Tab
      tabPanel("Competitive Analysis",
        fluidRow(
          column(12,
            div(class = "executive-card",
              h3("Market Comparison"),
              p("See how your company compares to competitors across key metrics."),
              selectInput(ns("competitiveMetric"), "Metric:",
                         choices = c("Premium Rates" = "premium", 
                                    "Market Share" = "market_share",
                                    "Loss Ratio" = "loss_ratio",
                                    "Combined Ratio" = "combined_ratio")),
              selectInput(ns("competitiveLine"), "Insurance Line:",
                         choices = c("All Lines" = "all", "Home", "Auto", "Health", "Life", "Annuities")),
              selectInput(ns("competitiveRegion"), "Region:",
                         choices = c("All Regions" = "all", "Iowa", "Georgia", "Florida"))
            )
          )
        ),
        fluidRow(
          column(6,
            plotlyOutput(ns("competitiveBarPlot"), height = "300px")
          ),
          column(6,
            plotlyOutput(ns("competitiveRadarPlot"), height = "300px")
          )
        ),
        fluidRow(
          column(12,
            div(class = "executive-card",
              h4("Competitive Positioning Analysis"),
              htmlOutput(ns("competitiveAnalysis"))
            )
          )
        )
      ),
      
      # Trend Analysis Tab
      tabPanel("Trend Analysis",
        fluidRow(
          column(4,
            div(class = "executive-card",
              h3("Performance Trends"),
              selectInput(ns("trendMetric"), "Metric:",
                         choices = c("Premium Revenue" = "revenue", 
                                    "Loss Ratio" = "loss_ratio",
                                    "Combined Ratio" = "combined_ratio",
                                    "Market Share" = "market_share",
                                    "Profit" = "profit")),
              selectInput(ns("trendLine"), "Insurance Line:",
                         choices = c("All Lines" = "all", "Home", "Auto", "Health", "Life", "Annuities")),
              selectInput(ns("trendRegion"), "Region:",
                         choices = c("All Regions" = "all", "Iowa", "Georgia", "Florida")),
              checkboxInput(ns("showTrendline"), "Show Trend Line", value = TRUE),
              checkboxInput(ns("showSeasonality"), "Show Seasonality", value = FALSE)
            )
          ),
          column(8,
            plotlyOutput(ns("trendPlot"), height = "400px")
          )
        ),
        fluidRow(
          column(12,
            div(class = "executive-card",
              h4("Key Performance Indicators Over Time"),
              tableOutput(ns("trendTable")),
              h5("Trend Analysis"),
              htmlOutput(ns("trendAnalysis"))
            )
          )
        )
      )
    )
  )
}

#' Advanced Analytics Server Module
#' 
#' @param id Namespace ID for the module
#' @param userProfile Reactive values containing user profile data
#' @param gameData Reactive values containing game data
#' @return Server module function
advancedAnalyticsServer <- function(id, userProfile, gameData) {
  moduleServer(id, function(input, output, session) {
    
    # Reactive values to store current analytics results
    analytics <- reactiveValues(
      forecast = NULL,
      scenario = NULL,
      competitive = NULL,
      trend = NULL
    )
    
    # Generate forecast data
    observeEvent(input$generateForecastBtn, {
      # In a real implementation, this would use historical data from gameData
      # For now, we'll generate simulated data
      
      # Create historical data (10 periods)
      historical_periods <- 1:10
      
      if (input$forecastMetric == "revenue") {
        historical_values <- c(1000000, 1050000, 1150000, 1200000, 1180000, 1250000, 1300000, 1400000, 1450000, 1500000)
        y_label <- "Premium Revenue ($)"
        interpretation <- "Revenue shows an overall positive trend with projected continued growth. 
                          Consider capitalizing on this momentum by carefully expanding into new markets."
      } else if (input$forecastMetric == "loss_ratio") {
        historical_values <- c(68, 70, 72, 71, 69, 67, 65, 63, 64, 62)
        y_label <- "Loss Ratio (%)"
        interpretation <- "Loss ratio is showing a gradual improving trend, indicating better risk selection and 
                          pricing. Continue monitoring underwriting guidelines and claims management practices."
      } else if (input$forecastMetric == "combined_ratio") {
        historical_values <- c(98, 99, 97, 96, 95, 94, 93, 92, 91, 90)
        y_label <- "Combined Ratio (%)"
        interpretation <- "The combined ratio forecast shows continued improvement, suggesting increasing 
                          profitability. Focus on maintaining expense controls while ensuring adequate 
                          customer service levels."
      } else {
        historical_values <- c(7.5, 7.8, 8.0, 8.2, 8.4, 8.6, 8.8, 9.0, 9.1, 9.2)
        y_label <- "Market Share (%)"
        interpretation <- "Market share has been steadily growing and is projected to continue this trend. 
                          Consider competitive positioning and pricing strategy to maintain momentum."
      }
      
      # Create time series
      ts_data <- ts(historical_values, frequency = 1)
      
      # Forecast future values
      forecast_horizon <- as.numeric(input$forecastHorizon)
      forecast_model <- forecast::auto.arima(ts_data)
      forecast_result <- forecast::forecast(forecast_model, h = forecast_horizon)
      
      # Store results in reactive values
      analytics$forecast <- list(
        historical_periods = historical_periods,
        historical_values = historical_values,
        forecast_periods = (max(historical_periods) + 1):(max(historical_periods) + forecast_horizon),
        forecast_mean = as.numeric(forecast_result$mean),
        forecast_lower = as.numeric(forecast_result$lower[,1]),  # 80% CI lower
        forecast_upper = as.numeric(forecast_result$upper[,1]),  # 80% CI upper
        forecast_lower95 = as.numeric(forecast_result$lower[,2]),  # 95% CI lower
        forecast_upper95 = as.numeric(forecast_result$upper[,2]),  # 95% CI upper
        y_label = y_label,
        interpretation = interpretation
      )
    })
    
    # Generate forecast plot
    output$forecastPlot <- renderPlotly({
      if (is.null(analytics$forecast)) {
        return(plotly_empty())
      }
      
      f <- analytics$forecast
      
      # Create plot
      plot_ly() %>%
        # Historical data
        add_trace(x = f$historical_periods, y = f$historical_values,
                 type = 'scatter', mode = 'lines+markers',
                 line = list(color = '#00AEEF', width = 2),
                 marker = list(color = '#00AEEF', size = 8),
                 name = 'Historical') %>%
        # Forecast mean
        add_trace(x = f$forecast_periods, y = f$forecast_mean,
                 type = 'scatter', mode = 'lines+markers',
                 line = list(color = '#28A745', width = 2, dash = 'dash'),
                 marker = list(color = '#28A745', size = 8),
                 name = 'Forecast') %>%
        # 80% Confidence interval
        add_ribbons(x = f$forecast_periods, 
                   ymin = f$forecast_lower, ymax = f$forecast_upper,
                   fillcolor = 'rgba(40, 167, 69, 0.2)', line = list(color = 'transparent'),
                   name = '80% Confidence Interval') %>%
        # 95% Confidence interval
        add_ribbons(x = f$forecast_periods, 
                   ymin = f$forecast_lower95, ymax = f$forecast_upper95,
                   fillcolor = 'rgba(40, 167, 69, 0.1)', line = list(color = 'transparent'),
                   name = '95% Confidence Interval') %>%
        layout(
          title = paste("Forecast of", input$forecastMetric),
          xaxis = list(title = "Time Period", gridcolor = '#3D3D3D'),
          yaxis = list(title = f$y_label, gridcolor = '#3D3D3D'),
          paper_bgcolor = '#1D1D1D',
          plot_bgcolor = '#1D1D1D',
          font = list(color = '#FFFFFF'),
          legend = list(orientation = 'h', y = -0.2)
        )
    })
    
    # Forecast interpretation
    output$forecastInterpretation <- renderUI({
      if (is.null(analytics$forecast)) {
        return(NULL)
      }
      
      HTML(paste("<p>", analytics$forecast$interpretation, "</p>"))
    })
    
    # Run scenario analysis
    observeEvent(input$runScenarioBtn, {
      # In a real implementation, this would use simulation functions from backend/simulation.R
      # For now, we'll generate simulated scenario data
      
      market_condition <- input$scenarioMarketCondition
      premium_adjustment <- input$scenarioPremiumAdjustment
      investment_aggression <- input$scenarioInvestmentAggression
      
      # Create baseline and scenario result data
      baseline_results <- data.frame(
        metric = c("Premium Revenue", "Market Share", "Loss Ratio", "Combined Ratio", "Investment Return", "Profit"),
        value = c(1500000, 9.2, 62, 90, 5.5, 150000)
      )
      
      # Apply scenario adjustments
      # Market condition affects investment return and loss ratio
      investment_effect <- market_condition * 2  # -2% to +2% effect on investment return
      loss_ratio_effect <- -market_condition * 3  # +3% to -3% effect on loss ratio
      
      # Premium adjustment affects revenue, market share, and loss ratio
      premium_effect <- (premium_adjustment - 100) / 100
      revenue_effect <- premium_effect * 0.5  # Premium increase doesn't fully translate to revenue due to elasticity
      market_share_effect <- -premium_effect * 0.3  # Higher premiums reduce market share
      
      # Investment aggression affects returns and risk
      investment_return_effect <- (investment_aggression - 5) * 0.5  # -2.5% to +2.5% effect
      investment_risk_effect <- (investment_aggression - 5) * 0.2  # -1% to +1% volatility
      
      # Calculate scenario values
      scenario_revenue <- baseline_results$value[1] * (1 + revenue_effect)
      scenario_market_share <- baseline_results$value[2] + market_share_effect
      scenario_loss_ratio <- baseline_results$value[3] + loss_ratio_effect
      scenario_combined_ratio <- baseline_results$value[4] + loss_ratio_effect  # Simplified
      scenario_investment_return <- baseline_results$value[5] + investment_effect + investment_return_effect
      
      # Calculate profit (simplistic)
      combined_ratio_impact <- (baseline_results$value[4] - scenario_combined_ratio) / 100
      investment_impact <- (scenario_investment_return - baseline_results$value[5]) / 100
      profit_impact <- scenario_revenue * (combined_ratio_impact + investment_impact)
      scenario_profit <- baseline_results$value[6] + profit_impact
      
      scenario_results <- data.frame(
        metric = baseline_results$metric,
        baseline = baseline_results$value,
        scenario = c(scenario_revenue, scenario_market_share, scenario_loss_ratio, 
                    scenario_combined_ratio, scenario_investment_return, scenario_profit),
        change = c(scenario_revenue - baseline_results$value[1],
                  scenario_market_share - baseline_results$value[2],
                  scenario_loss_ratio - baseline_results$value[3],
                  scenario_combined_ratio - baseline_results$value[4],
                  scenario_investment_return - baseline_results$value[5],
                  scenario_profit - baseline_results$value[6])
      )
      
      # Determine if changes are positive or negative
      scenario_results$direction <- ifelse(scenario_results$metric %in% c("Loss Ratio", "Combined Ratio"),
                                         ifelse(scenario_results$change < 0, "positive", "negative"),
                                         ifelse(scenario_results$change > 0, "positive", "negative"))
      
      # Generate interpretation
      if (scenario_profit > baseline_results$value[6]) {
        interpretation <- paste("<strong>This scenario is projected to increase profit by $", 
                              format(round(scenario_profit - baseline_results$value[6]), big.mark = ","), 
                              ".</strong> ", sep="")
        
        if (scenario_loss_ratio < baseline_results$value[3]) {
          interpretation <- paste(interpretation, "The improved loss ratio suggests better underwriting performance. ", sep="")
        } 
        
        if (scenario_investment_return > baseline_results$value[5]) {
          interpretation <- paste(interpretation, "Higher investment returns contribute significantly to the improved results. ", sep="")
        }
        
        if (scenario_market_share < baseline_results$value[2]) {
          interpretation <- paste(interpretation, "Note that market share decreases in this scenario, which may have long-term implications.", sep="")
        }
      } else {
        interpretation <- paste("<strong>This scenario is projected to decrease profit by $", 
                              format(round(baseline_results$value[6] - scenario_profit), big.mark = ","), 
                              ".</strong> ", sep="")
        
        if (scenario_loss_ratio > baseline_results$value[3]) {
          interpretation <- paste(interpretation, "The worsened loss ratio suggests underwriting challenges. ", sep="")
        } 
        
        if (scenario_investment_return < baseline_results$value[5]) {
          interpretation <- paste(interpretation, "Lower investment returns contribute to the reduced profitability. ", sep="")
        }
        
        if (scenario_market_share > baseline_results$value[2]) {
          interpretation <- paste(interpretation, "The increased market share may provide long-term benefits despite short-term profit reduction.", sep="")
        }
      }
      
      # Store results in reactive values
      analytics$scenario <- list(
        results = scenario_results,
        interpretation = interpretation
      )
    })
    
    # Scenario plot
    output$scenarioPlot <- renderPlotly({
      if (is.null(analytics$scenario)) {
        return(plotly_empty())
      }
      
      results <- analytics$scenario$results
      
      # Calculate percentage changes for plotting
      percentage_change <- results$change / results$baseline * 100
      
      # Create colors based on direction
      colors <- ifelse(results$direction == "positive", "#28A745", "#DC3545")
      
      # Create plot
      plot_ly() %>%
        add_trace(x = results$metric, y = percentage_change,
                 type = 'bar',
                 marker = list(color = colors),
                 name = 'Change (%)') %>%
        layout(
          title = "Scenario Impact - Percentage Change from Baseline",
          xaxis = list(title = "", gridcolor = '#3D3D3D'),
          yaxis = list(title = "Change (%)", gridcolor = '#3D3D3D'),
          paper_bgcolor = '#1D1D1D',
          plot_bgcolor = '#1D1D1D',
          font = list(color = '#FFFFFF')
        )
    })
    
    # Scenario results table
    output$scenarioTable <- renderTable({
      if (is.null(analytics$scenario)) {
        return(NULL)
      }
      
      results <- analytics$scenario$results
      
      # Format results for display
      formatted_results <- data.frame(
        Metric = results$metric,
        Baseline = format_value(results$metric, results$baseline),
        Scenario = format_value(results$metric, results$scenario),
        Change = format_change(results$metric, results$change)
      )
      
      formatted_results
    }, striped = TRUE, hover = TRUE, bordered = TRUE, width = "100%")
    
    # Scenario interpretation
    output$scenarioInterpretation <- renderUI({
      if (is.null(analytics$scenario)) {
        return(NULL)
      }
      
      HTML(analytics$scenario$interpretation)
    })
    
    # Initialize competitive analysis data
    observe({
      # In a real implementation, this would use market data from gameData
      # For now, we'll generate simulated competitive data
      
      # Create data for the company and competitors
      companies <- c("Your Company", "Competitor A", "Competitor B", "Competitor C")
      
      # Generate metrics for each company
      premium_rates <- c(100, 95, 105, 110)
      market_share <- c(9.2, 12.5, 8.7, 15.3)
      loss_ratio <- c(62, 68, 59, 72)
      combined_ratio <- c(90, 95, 88, 98)
      
      # Create radar chart data with normalized values (0-1 scale)
      # For loss ratio and combined ratio, lower is better so we invert
      normalize_min_max <- function(x) (x - min(x)) / (max(x) - min(x))
      normalize_inverse <- function(x) 1 - normalize_min_max(x)
      
      radar_data <- data.frame(
        company = companies,
        premium_rate = normalize_inverse(premium_rates),  # Lower is better
        market_share = normalize_min_max(market_share),  # Higher is better
        loss_ratio = normalize_inverse(loss_ratio),  # Lower is better
        combined_ratio = normalize_inverse(combined_ratio),  # Lower is better
        customer_satisfaction = c(0.85, 0.70, 0.90, 0.65),  # Simulated data
        innovation = c(0.75, 0.60, 0.80, 0.50)  # Simulated data
      )
      
      competitive_data <- list(
        companies = companies,
        premium_rates = premium_rates,
        market_share = market_share,
        loss_ratio = loss_ratio,
        combined_ratio = combined_ratio,
        radar_data = radar_data
      )
      
      # Generate interpretation
      if (premium_rates[1] > mean(premium_rates[-1])) {
        premium_position <- "higher than"
      } else {
        premium_position <- "lower than"
      }
      
      if (market_share[1] > mean(market_share[-1])) {
        market_position <- "stronger than"
      } else {
        market_position <- "weaker than"
      }
      
      if (loss_ratio[1] < mean(loss_ratio[-1])) {
        underwriting_position <- "better than"
      } else {
        underwriting_position <- "worse than"
      }
      
      interpretation <- paste(
        "Your company's premium rates are ", premium_position, " the market average. ",
        "Your market share is ", market_position, " average, ",
        "and your underwriting performance is ", underwriting_position, " your competitors. ",
        "Consider your competitive positioning in relation to your strategic goals.",
        sep = ""
      )
      
      analytics$competitive <- list(
        data = competitive_data,
        interpretation = interpretation
      )
    })
    
    # Competitive bar plot
    output$competitiveBarPlot <- renderPlotly({
      if (is.null(analytics$competitive)) {
        return(plotly_empty())
      }
      
      comp <- analytics$competitive$data
      
      # Select metric based on input
      if (input$competitiveMetric == "premium") {
        metric_values <- comp$premium_rates
        y_title <- "Premium Rate Index"
        plot_title <- "Premium Rates by Company"
      } else if (input$competitiveMetric == "market_share") {
        metric_values <- comp$market_share
        y_title <- "Market Share (%)"
        plot_title <- "Market Share by Company"
      } else if (input$competitiveMetric == "loss_ratio") {
        metric_values <- comp$loss_ratio
        y_title <- "Loss Ratio (%)"
        plot_title <- "Loss Ratio by Company"
      } else {
        metric_values <- comp$combined_ratio
        y_title <- "Combined Ratio (%)"
        plot_title <- "Combined Ratio by Company"
      }
      
      # Create colors (highlight your company)
      colors <- c("#00AEEF", "#999999", "#999999", "#999999")
      
      # Create plot
      plot_ly() %>%
        add_trace(x = comp$companies, y = metric_values,
                 type = 'bar',
                 marker = list(color = colors),
                 name = input$competitiveMetric) %>%
        layout(
          title = plot_title,
          xaxis = list(title = "", gridcolor = '#3D3D3D'),
          yaxis = list(title = y_title, gridcolor = '#3D3D3D'),
          paper_bgcolor = '#1D1D1D',
          plot_bgcolor = '#1D1D1D',
          font = list(color = '#FFFFFF')
        )
    })
    
    # Competitive radar plot
    output$competitiveRadarPlot <- renderPlotly({
      if (is.null(analytics$competitive)) {
        return(plotly_empty())
      }
      
      # Get radar data
      radar <- analytics$competitive$data$radar_data
      
      # Create radar chart for all companies
      plot_data <- list()
      for (i in 1:nrow(radar)) {
        company <- radar$company[i]
        
        # Create category values
        r_values <- as.numeric(radar[i, 2:ncol(radar)])
        theta_values <- colnames(radar)[2:ncol(radar)]
        
        # Add first point again to close the loop
        r_values <- c(r_values, r_values[1])
        theta_values <- c(theta_values, theta_values[1])
        
        plot_data[[i]] <- list(
          type = "scatterpolar",
          r = r_values,
          theta = theta_values,
          fill = "toself",
          name = company,
          line = list(
            color = if(company == "Your Company") "#00AEEF" else "#999999",
            width = if(company == "Your Company") 3 else 2
          ),
          fillcolor = if(company == "Your Company") "rgba(0, 174, 239, 0.3)" else "rgba(153, 153, 153, 0.1)"
        )
      }
      
      # Create layout
      layout <- list(
        polar = list(
          radialaxis = list(
            visible = TRUE,
            range = c(0, 1)
          )
        ),
        title = "Competitive Positioning",
        paper_bgcolor = '#1D1D1D',
        plot_bgcolor = '#1D1D1D',
        font = list(color = '#FFFFFF')
      )
      
      # Create plot
      p <- plot_ly()
      for (item in plot_data) {
        p <- add_trace(p, type = item$type, r = item$r, theta = item$theta, 
                      fill = item$fill, name = item$name, line = item$line, fillcolor = item$fillcolor)
      }
      
      p %>% layout(layout)
    })
    
    # Competitive analysis
    output$competitiveAnalysis <- renderUI({
      if (is.null(analytics$competitive)) {
        return(NULL)
      }
      
      HTML(paste("<p>", analytics$competitive$interpretation, "</p>"))
    })
    
    # Initialize trend analysis data
    observe({
      # In a real implementation, this would use historical data from gameData
      # For now, we'll generate simulated trend data
      
      # Create time periods
      periods <- 1:10
      period_labels <- paste("Q", rep(1:4, length.out = 10), " ", rep(2022:2024, each = 4, length.out = 10), sep = "")
      
      # Generate data for different metrics
      revenue <- c(1000000, 1050000, 1150000, 1200000, 1180000, 1250000, 1300000, 1400000, 1450000, 1500000)
      loss_ratio <- c(68, 70, 72, 71, 69, 67, 65, 63, 64, 62)
      combined_ratio <- c(98, 99, 97, 96, 95, 94, 93, 92, 91, 90)
      market_share <- c(7.5, 7.8, 8.0, 8.2, 8.4, 8.6, 8.8, 9.0, 9.1, 9.2)
      profit <- c(20000, 10500, 34500, 48000, 59000, 75000, 91000, 112000, 130500, 150000)
      
      # Create summary table with key statistics
      summary_data <- data.frame(
        Metric = c("Premium Revenue", "Loss Ratio", "Combined Ratio", "Market Share", "Profit"),
        `Starting Value` = c(revenue[1], loss_ratio[1], combined_ratio[1], market_share[1], profit[1]),
        `Current Value` = c(revenue[10], loss_ratio[10], combined_ratio[10], market_share[10], profit[10]),
        `Change` = c(
          revenue[10] - revenue[1],
          loss_ratio[10] - loss_ratio[1],
          combined_ratio[10] - combined_ratio[1],
          market_share[10] - market_share[1],
          profit[10] - profit[1]
        ),
        `% Change` = c(
          (revenue[10] - revenue[1]) / revenue[1] * 100,
          (loss_ratio[10] - loss_ratio[1]) / loss_ratio[1] * 100,
          (combined_ratio[10] - combined_ratio[1]) / combined_ratio[1] * 100,
          (market_share[10] - market_share[1]) / market_share[1] * 100,
          (profit[10] - profit[1]) / profit[1] * 100
        ),
        `Trend` = c("Increasing", "Decreasing", "Decreasing", "Increasing", "Increasing")
      )
      
      # Generate trend analysis text
      trend_analysis <- "
        <p>The company shows strong positive trends across key metrics. Revenue and profit are steadily increasing, 
        while loss ratio and combined ratio are decreasing, indicating improved operational efficiency. 
        Market share growth suggests effective competitive positioning.</p>
        
        <p>Consider investigating the slight uptick in loss ratio in the most recent period to ensure it doesn't 
        become a trend. The overall trajectory remains strong, with profitability improving significantly.</p>
      "
      
      analytics$trend <- list(
        periods = periods,
        period_labels = period_labels,
        revenue = revenue,
        loss_ratio = loss_ratio,
        combined_ratio = combined_ratio,
        market_share = market_share,
        profit = profit,
        summary = summary_data,
        analysis = trend_analysis
      )
    })
    
    # Trend plot
    output$trendPlot <- renderPlotly({
      if (is.null(analytics$trend)) {
        return(plotly_empty())
      }
      
      t <- analytics$trend
      periods <- t$periods
      period_labels <- t$period_labels
      
      # Select metric based on input
      if (input$trendMetric == "revenue") {
        metric_values <- t$revenue
        y_title <- "Premium Revenue ($)"
        plot_title <- "Premium Revenue Trend"
      } else if (input$trendMetric == "loss_ratio") {
        metric_values <- t$loss_ratio
        y_title <- "Loss Ratio (%)"
        plot_title <- "Loss Ratio Trend"
      } else if (input$trendMetric == "combined_ratio") {
        metric_values <- t$combined_ratio
        y_title <- "Combined Ratio (%)"
        plot_title <- "Combined Ratio Trend"
      } else if (input$trendMetric == "market_share") {
        metric_values <- t$market_share
        y_title <- "Market Share (%)"
        plot_title <- "Market Share Trend"
      } else {
        metric_values <- t$profit
        y_title <- "Profit ($)"
        plot_title <- "Profit Trend"
      }
      
      # Create the plot
      p <- plot_ly() %>%
        add_trace(x = periods, y = metric_values,
                 type = 'scatter', mode = 'lines+markers',
                 line = list(color = '#00AEEF', width = 2),
                 marker = list(color = '#00AEEF', size = 8),
                 name = input$trendMetric)
      
      # Add trend line if selected
      if (input$showTrendline) {
        # Fit linear model
        trend_model <- lm(metric_values ~ periods)
        trend_predictions <- predict(trend_model, newdata = data.frame(periods = periods))
        
        p <- p %>%
          add_trace(x = periods, y = trend_predictions,
                   type = 'scatter', mode = 'lines',
                   line = list(color = '#28A745', width = 2, dash = 'dash'),
                   name = 'Trend Line')
      }
      
      # Add seasonality if selected (simplified)
      if (input$showSeasonality) {
        # Create a simple seasonal component (this would normally be extracted from the data)
        seasonal_component <- rep(c(0.05, -0.03, 0.02, -0.04), length.out = length(periods))
        seasonal_effect <- mean(abs(metric_values)) * seasonal_component
        seasonally_adjusted <- metric_values - seasonal_effect
        
        p <- p %>%
          add_trace(x = periods, y = seasonally_adjusted,
                   type = 'scatter', mode = 'lines',
                   line = list(color = '#FFC107', width = 2, dash = 'dot'),
                   name = 'Seasonally Adjusted')
      }
      
      # Complete the layout
      p %>% layout(
        title = plot_title,
        xaxis = list(
          title = "Time Period", 
          gridcolor = '#3D3D3D',
          ticktext = period_labels,
          tickvals = periods
        ),
        yaxis = list(title = y_title, gridcolor = '#3D3D3D'),
        paper_bgcolor = '#1D1D1D',
        plot_bgcolor = '#1D1D1D',
        font = list(color = '#FFFFFF')
      )
    })
    
    # Trend table
    output$trendTable <- renderTable({
      if (is.null(analytics$trend)) {
        return(NULL)
      }
      
      analytics$trend$summary
    }, striped = TRUE, hover = TRUE, bordered = TRUE, width = "100%")
    
    # Trend analysis
    output$trendAnalysis <- renderUI({
      if (is.null(analytics$trend)) {
        return(NULL)
      }
      
      HTML(analytics$trend$analysis)
    })
    
    # Helper function for formatting values
    format_value <- function(metric, value) {
      if (metric %in% c("Premium Revenue", "Profit")) {
        return(paste0("$", format(round(value), big.mark = ",")))
      } else if (metric %in% c("Loss Ratio", "Combined Ratio", "Investment Return")) {
        return(paste0(round(value, 1), "%"))
      } else if (metric == "Market Share") {
        return(paste0(round(value, 1), "%"))
      } else {
        return(format(round(value, 2), nsmall = 2))
      }
    }
    
    # Helper function for formatting changes
    format_change <- function(metric, change) {
      direction <- ifelse(
        metric %in% c("Loss Ratio", "Combined Ratio"),
        ifelse(change < 0, "positive", "negative"),
        ifelse(change > 0, "positive", "negative")
      )
      
      color_class <- ifelse(direction == "positive", "text-success", "text-danger")
      arrow <- ifelse(change > 0, "↑", "↓")
      
      if (metric %in% c("Premium Revenue", "Profit")) {
        formatted <- paste0("$", format(abs(round(change)), big.mark = ","))
      } else if (metric %in% c("Loss Ratio", "Combined Ratio", "Investment Return", "Market Share")) {
        formatted <- paste0(abs(round(change, 1)), "%")
      } else {
        formatted <- format(abs(round(change, 2)), nsmall = 2)
      }
      
      return(paste0('<span class="', color_class, '">', arrow, ' ', formatted, '</span>'))
    }
  })
} 