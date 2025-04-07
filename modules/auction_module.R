# Insurance Simulation Game - Auction Module
# This module implements the Risk Management and Investment Auction functionality

#' UI function for the auction module
#' 
#' @param id The module ID
#' @return A UI definition that can be included in the app
auctionUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    h2("Asset and Risk Management Auctions"),
    p("Participate in auctions to acquire investment assets and risk management tools."),
    
    # Auction type selector
    radioButtons(
      ns("auctionType"), 
      "Select Auction Type:",
      choices = c(
        "Investment Assets (CFO)" = "investment",
        "Risk Management Tools (CRO)" = "risk_management"
      ),
      selected = "investment"
    ),
    
    # Auction status display
    conditionalPanel(
      condition = paste0("input['", ns("auctionType"), "'] == 'investment'"),
      h3("Investment Asset Auction"),
      p("Bid on equities, bonds, and other financial instruments to optimize your investment portfolio."),
      
      # Available investment assets
      div(class = "auction-items",
        uiOutput(ns("investmentAssets"))
      )
    ),
    
    conditionalPanel(
      condition = paste0("input['", ns("auctionType"), "'] == 'risk_management'"),
      h3("Risk Management Tools Auction"),
      p("Bid on reinsurance, derivatives, and other risk management tools to reduce your exposure."),
      
      # Available risk management tools
      div(class = "auction-items",
        uiOutput(ns("riskManagementTools"))
      )
    ),
    
    # Bidding controls
    hr(),
    h3("Place Your Bid"),
    fluidRow(
      column(6,
        selectInput(
          ns("selectedAsset"),
          "Select Item to Bid On:",
          choices = NULL
        )
      ),
      column(6,
        numericInput(
          ns("bidAmount"),
          "Bid Amount:",
          value = 1000,
          min = 0,
          step = 100
        )
      )
    ),
    
    # Current utility display
    fluidRow(
      column(6,
        div(class = "auction-utility-display",
          h4("Your Current Utility"),
          uiOutput(ns("utilityDisplay"))
        )
      ),
      column(6,
        actionButton(
          ns("placeBid"),
          "Place Bid",
          class = "btn-primary btn-block",
          icon = icon("gavel")
        )
      )
    ),
    
    # Auction history and results
    hr(),
    h3("Auction History"),
    dataTableOutput(ns("auctionHistory"))
  )
}

#' Server function for the auction module
#' 
#' @param id The module ID
#' @param userProfile Reactive values containing user profile information
#' @param gameData Reactive values containing game state
#' @return Reactive values containing auction results
auctionServer <- function(id, userProfile, gameData) {
  moduleServer(id, function(input, output, session) {
    # Initialize reactive values for auction data
    auctionData <- reactiveValues(
      investment_assets = list(),
      risk_tools = list(),
      bids = list(),
      history = data.frame(
        auction_type = character(),
        asset_name = character(),
        bid_amount = numeric(),
        result = character(),
        turn = numeric(),
        stringsAsFactors = FALSE
      )
    )
    
    # Get available assets based on auction type
    observe({
      if (!is.null(gameData$gameState)) {
        if (input$auctionType == "investment") {
          auctionData$investment_assets <- generate_investment_assets(gameData$gameState)
          updateSelectInput(
            session, 
            "selectedAsset",
            choices = sapply(auctionData$investment_assets, function(x) x$name)
          )
        } else {
          auctionData$risk_tools <- generate_risk_tools(gameData$gameState)
          updateSelectInput(
            session, 
            "selectedAsset",
            choices = sapply(auctionData$risk_tools, function(x) x$name)
          )
        }
      }
    })
    
    # Render investment assets
    output$investmentAssets <- renderUI({
      ns <- session$ns
      
      if (length(auctionData$investment_assets) == 0) {
        return(div(class = "alert alert-info", "No investment assets available for auction."))
      }
      
      asset_cards <- lapply(auctionData$investment_assets, function(asset) {
        div(class = "asset-card",
          h4(asset$name),
          p(class = "asset-description", asset$description),
          div(class = "asset-details",
            span(class = "asset-label", "Starting Price: "),
            span(class = "asset-value", paste0("$", format(asset$base_price, big.mark = ","))),
            br(),
            span(class = "asset-label", "Expected Return: "),
            span(class = "asset-value", paste0(format(asset$expected_return, digits = 2), "%")),
            br(),
            span(class = "asset-label", "Risk Level: "),
            span(class = "asset-value", asset$risk_level)
          ),
          actionButton(ns(paste0("select_", asset$id)), "Select", class = "btn-sm btn-primary")
        )
      })
      
      do.call(tagList, asset_cards)
    })
    
    # Render risk management tools
    output$riskManagementTools <- renderUI({
      ns <- session$ns
      
      if (length(auctionData$risk_tools) == 0) {
        return(div(class = "alert alert-info", "No risk management tools available for auction."))
      }
      
      tool_cards <- lapply(auctionData$risk_tools, function(tool) {
        div(class = "asset-card",
          h4(tool$name),
          p(class = "asset-description", tool$description),
          div(class = "asset-details",
            span(class = "asset-label", "Starting Price: "),
            span(class = "asset-value", paste0("$", format(tool$base_price, big.mark = ","))),
            br(),
            span(class = "asset-label", "Risk Reduction: "),
            span(class = "asset-value", paste0(format(tool$risk_reduction * 100, digits = 2), "%")),
            br(),
            span(class = "asset-label", "Coverage: "),
            span(class = "asset-value", tool$coverage)
          ),
          actionButton(ns(paste0("select_", tool$id)), "Select", class = "btn-sm btn-primary")
        )
      })
      
      do.call(tagList, tool_cards)
    })
    
    # Handle selection buttons for investment assets
    observe({
      for (asset in auctionData$investment_assets) {
        local({
          asset_id <- asset$id
          asset_name <- asset$name
          
          observeEvent(input[[paste0("select_", asset_id)]], {
            updateSelectInput(session, "selectedAsset", selected = asset_name)
          })
        })
      }
    })
    
    # Handle selection buttons for risk tools
    observe({
      for (tool in auctionData$risk_tools) {
        local({
          tool_id <- tool$id
          tool_name <- tool$name
          
          observeEvent(input[[paste0("select_", tool_id)]], {
            updateSelectInput(session, "selectedAsset", selected = tool_name)
          })
        })
      }
    })
    
    # Calculate and display utility for selected asset
    output$utilityDisplay <- renderUI({
      req(input$selectedAsset)
      
      # Get the selected asset details
      selected_asset <- NULL
      if (input$auctionType == "investment") {
        for (asset in auctionData$investment_assets) {
          if (asset$name == input$selectedAsset) {
            selected_asset <- asset
            break
          }
        }
      } else {
        for (tool in auctionData$risk_tools) {
          if (tool$name == input$selectedAsset) {
            selected_asset <- tool
            break
          }
        }
      }
      
      if (is.null(selected_asset)) {
        return(NULL)
      }
      
      # Calculate utility based on player skills and item properties
      if (input$auctionType == "investment") {
        # For investment assets, utility is based on investment skill
        investment_skill <- if (!is.null(userProfile$skills)) userProfile$skills$investing else 5
        utility <- calculate_investment_utility(selected_asset, investment_skill, input$bidAmount)
      } else {
        # For risk management tools, utility is based on risk management skill
        risk_skill <- if (!is.null(userProfile$skills)) userProfile$skills$riskManagement else 5
        utility <- calculate_risk_utility(selected_asset, risk_skill, input$bidAmount)
      }
      
      # Display utility value
      div(
        span("Utility Score: "),
        span(class = "utility-value", format(utility, digits = 2))
      )
    })
    
    # Handle bid placement
    observeEvent(input$placeBid, {
      req(input$selectedAsset, input$bidAmount)
      
      # Validate that the user has a profile
      if (!userProfile$initialized) {
        showNotification("You must create a profile before bidding.", type = "error")
        return()
      }
      
      # Validate bid amount is positive
      if (input$bidAmount <= 0) {
        showNotification("Bid amount must be greater than zero.", type = "error")
        return()
      }
      
      # Get the selected asset details
      selected_asset <- NULL
      if (input$auctionType == "investment") {
        for (asset in auctionData$investment_assets) {
          if (asset$name == input$selectedAsset) {
            selected_asset <- asset
            break
          }
        }
      } else {
        for (tool in auctionData$risk_tools) {
          if (tool$name == input$selectedAsset) {
            selected_asset <- tool
            break
          }
        }
      }
      
      if (is.null(selected_asset)) {
        showNotification("Invalid selection. Please try again.", type = "error")
        return()
      }
      
      # Record the bid
      new_bid <- list(
        player_id = userProfile$player_id,
        auction_type = input$auctionType,
        asset_id = selected_asset$id,
        asset_name = selected_asset$name,
        bid_amount = input$bidAmount,
        timestamp = Sys.time()
      )
      
      # Add to bids list
      auctionData$bids[[length(auctionData$bids) + 1]] <- new_bid
      
      # Calculate outcome (simplified for now - based on random chance with skill influence)
      if (input$auctionType == "investment") {
        investment_skill <- if (!is.null(userProfile$skills)) userProfile$skills$investing else 5
        success_probability <- min(0.9, 0.5 + (investment_skill - 5) * 0.05)
      } else {
        risk_skill <- if (!is.null(userProfile$skills)) userProfile$skills$riskManagement else 5
        success_probability <- min(0.9, 0.5 + (risk_skill - 5) * 0.05)
      }
      
      # Simple outcome determination (would be more complex in full implementation)
      result <- if (runif(1) < success_probability) "Won" else "Lost"
      
      # Add to history
      auctionData$history <- rbind(
        auctionData$history,
        data.frame(
          auction_type = input$auctionType,
          asset_name = selected_asset$name,
          bid_amount = input$bidAmount,
          result = result,
          turn = gameData$currentTurn,
          stringsAsFactors = FALSE
        )
      )
      
      # Show notification of result
      showNotification(
        paste0(
          "Bid placed successfully for ", selected_asset$name, ". ",
          "Result: ", result
        ),
        type = if (result == "Won") "message" else "warning"
      )
    })
    
    # Render auction history data table
    output$auctionHistory <- renderDataTable({
      auctionData$history
    })
    
    # Return auction data
    return(auctionData)
  })
}

#' Generate a list of investment assets for the current game state
#' 
#' @param game_state The current game state
#' @return A list of investment assets
generate_investment_assets <- function(game_state) {
  # In a full implementation, these would be based on game_state
  # For now, we'll create a simple static list
  assets <- list(
    list(
      id = "equity_index",
      name = "Equity Index Fund",
      description = "A diversified portfolio of large-cap stocks with moderate risk and growth potential.",
      base_price = 50000,
      expected_return = 8.0,
      risk_level = "Medium",
      volatility = 15.0
    ),
    list(
      id = "govt_bonds",
      name = "Government Bond Portfolio",
      description = "Long-term treasury bonds with stable returns and low risk.",
      base_price = 75000,
      expected_return = 3.5,
      risk_level = "Low",
      volatility = 5.0
    ),
    list(
      id = "corp_bonds",
      name = "Corporate Bond Fund",
      description = "Investment-grade corporate bonds with moderate yields.",
      base_price = 60000,
      expected_return = 5.0,
      risk_level = "Medium-Low",
      volatility = 8.0
    ),
    list(
      id = "growth_stocks",
      name = "Growth Stock Portfolio",
      description = "High-growth technology and healthcare stocks with higher volatility.",
      base_price = 40000,
      expected_return = 12.0,
      risk_level = "High",
      volatility = 22.0
    )
  )
  
  return(assets)
}

#' Generate a list of risk management tools for the current game state
#' 
#' @param game_state The current game state
#' @return A list of risk management tools
generate_risk_tools <- function(game_state) {
  # In a full implementation, these would be based on game_state
  # For now, we'll create a simple static list
  tools <- list(
    list(
      id = "catastrophe_reinsurance",
      name = "Catastrophe Reinsurance",
      description = "Coverage for extreme natural disaster events that exceed normal claims levels.",
      base_price = 30000,
      risk_reduction = 0.25,
      coverage = "Catastrophic Events",
      region = "All Regions"
    ),
    list(
      id = "hurricane_derivative",
      name = "Hurricane Derivative",
      description = "Financial instrument that pays out based on hurricane intensity in Florida.",
      base_price = 20000,
      risk_reduction = 0.30,
      coverage = "Hurricane Risk",
      region = "Florida"
    ),
    list(
      id = "quota_share",
      name = "Quota Share Treaty",
      description = "Basic reinsurance that covers a percentage of all claims across all lines.",
      base_price = 45000,
      risk_reduction = 0.20,
      coverage = "All Lines",
      region = "All Regions"
    ),
    list(
      id = "excess_of_loss",
      name = "Excess of Loss Cover",
      description = "Covers claims that exceed a specified threshold in any given loss event.",
      base_price = 35000,
      risk_reduction = 0.15,
      coverage = "Major Claims",
      region = "All Regions"
    )
  )
  
  return(tools)
}

#' Calculate utility for an investment asset
#' 
#' @param asset The investment asset
#' @param investment_skill The player's investment skill level
#' @param bid_amount The amount being bid
#' @return Calculated utility value
calculate_investment_utility <- function(asset, investment_skill, bid_amount) {
  # Base utility from expected return
  base_utility <- asset$expected_return * 10
  
  # Skill adjustment - higher skill means better evaluation of assets
  skill_multiplier <- 0.8 + 0.04 * investment_skill
  
  # Price efficiency - how good is the bid relative to base price
  # A good investor gets more utility from bidding close to true value
  price_efficiency <- 1 - abs(bid_amount - asset$base_price) / asset$base_price
  price_efficiency <- max(0, price_efficiency)
  
  # Risk-adjusted utility based on skill
  # Higher skill allows handling higher risk better
  risk_adjustment <- 1 - (0.1 * switch(asset$risk_level,
                                      "Low" = 1,
                                      "Medium-Low" = 2,
                                      "Medium" = 3,
                                      "Medium-High" = 4,
                                      "High" = 5,
                                      3)) * (1 - (investment_skill / 10))
  
  # Calculate final utility
  utility <- base_utility * skill_multiplier * price_efficiency * risk_adjustment
  
  return(utility)
}

#' Calculate utility for a risk management tool
#' 
#' @param tool The risk management tool
#' @param risk_skill The player's risk management skill level
#' @param bid_amount The amount being bid
#' @return Calculated utility value
calculate_risk_utility <- function(tool, risk_skill, bid_amount) {
  # Base utility from risk reduction
  base_utility <- tool$risk_reduction * 100
  
  # Skill adjustment - higher skill means better risk assessment
  skill_multiplier <- 0.8 + 0.04 * risk_skill
  
  # Price efficiency - how good is the bid relative to base price
  price_efficiency <- 1 - abs(bid_amount - tool$base_price) / tool$base_price
  price_efficiency <- max(0, price_efficiency)
  
  # Coverage breadth value
  # Specialists value targeted coverage, while generalists value broader coverage
  coverage_value <- if (tool$coverage == "All Lines" || tool$coverage == "All Regions") {
    0.9 + (risk_skill / 100)  # Higher skill slightly prefers specialized tools
  } else {
    0.8 + (risk_skill / 50)   # Higher skill more strongly prefers specialized tools
  }
  
  # Calculate final utility
  utility <- base_utility * skill_multiplier * price_efficiency * coverage_value
  
  return(utility)
}

#' Calculate combined ratio adjustment from risk management tools
#' 
#' @param tools List of risk management tools acquired
#' @param base_combined_ratio The base combined ratio before adjustments
#' @param region The region to calculate for
#' @return Adjusted combined ratio
calculate_rm_combined_ratio_adjustment <- function(tools, base_combined_ratio, region) {
  # Start with no adjustment
  adjustment <- 0
  
  # Loop through tools and calculate cumulative adjustment
  for (tool in tools) {
    # Check if tool applies to this region
    if (tool$region == "All Regions" || tool$region == region) {
      # Calculate effect on combined ratio
      effect <- tool$risk_reduction * base_combined_ratio * 0.5
      
      # Add to total adjustment (diminishing returns for multiple tools)
      adjustment <- adjustment + effect * (1 - adjustment/100)
    }
  }
  
  # Ensure adjustment doesn't exceed reasonable limits
  adjustment <- min(adjustment, base_combined_ratio * 0.3)  # Max 30% reduction
  
  # Return adjusted combined ratio
  return(base_combined_ratio - adjustment)
}

#' Apply investment returns based on acquired assets
#' 
#' @param assets List of investment assets acquired
#' @param base_return Base investment return
#' @param market_condition Current market condition (-1 to 1)
#' @return Adjusted investment return
calculate_investment_return_adjustment <- function(assets, base_return, market_condition) {
  # Start with base return
  total_investment <- 0
  weighted_return <- 0
  
  # Loop through assets and calculate weighted return
  for (asset in assets) {
    # Calculate market-adjusted expected return
    adjusted_return <- asset$expected_return
    
    # Adjust based on market conditions
    if (asset$risk_level == "High") {
      adjusted_return <- adjusted_return + (market_condition * 5)
    } else if (asset$risk_level == "Medium-High" || asset$risk_level == "Medium") {
      adjusted_return <- adjusted_return + (market_condition * 3)
    } else if (asset$risk_level == "Medium-Low") {
      adjusted_return <- adjusted_return + (market_condition * 1)
    } else {
      adjusted_return <- adjusted_return + (market_condition * 0.5)
    }
    
    # Add to weighted calculation
    total_investment <- total_investment + asset$base_price
    weighted_return <- weighted_return + (adjusted_return * asset$base_price)
  }
  
  # If no assets, return base return
  if (total_investment == 0) {
    return(base_return)
  }
  
  # Calculate weighted average return
  average_return <- weighted_return / total_investment
  
  # Blend with base return
  return(0.5 * base_return + 0.5 * average_return)
} 