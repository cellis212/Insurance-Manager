# Insurance Simulation Game - Admin UI Module
# This file contains the Shiny module for the administrator interface

library(shiny)
library(shinydashboard)

# Source other required modules
# source("backend/data_ops.R")
# source("backend/simulation.R")

#' Administrator UI module
#' 
#' @param id Namespace ID for the module
#' @return A UI definition that can be included in the app
adminUIModule <- function(id) {
  ns <- NS(id)
  
  tagList(
    fluidRow(
      box(
        title = "Game Controls",
        status = "primary",
        solidHeader = TRUE,
        width = 12,
        
        fluidRow(
          column(
            width = 4,
            h4("Current Game Status"),
            verbatimTextOutput(ns("gameStatusOutput")),
            hr(),
            actionButton(ns("initializeGameBtn"), "Initialize New Game", class = "btn-warning"),
            actionButton(ns("advanceTurnBtn"), "Advance to Next Turn", class = "btn-success"),
            hr(),
            selectInput(ns("turnSelector"), "View Turn Data:",
                      choices = c("Latest" = "latest"))
          ),
          
          column(
            width = 8,
            h4("Player Participation"),
            dataTableOutput(ns("playerParticipationTable")),
            hr(),
            actionButton(ns("aggregateDecisionsBtn"), "Aggregate Player Decisions", class = "btn-info")
          )
        )
      )
    ),
    
    fluidRow(
      box(
        title = "Simulation Parameters",
        status = "warning",
        solidHeader = TRUE,
        collapsible = TRUE,
        width = 6,
        
        h4("Market Conditions"),
        
        sliderInput(ns("marketConditionSlider"), "General Market Condition:",
                   min = -1, max = 1, value = 0, step = 0.1),
        
        hr(),
        
        h4("Regulator Strictness"),
        
        fluidRow(
          column(
            width = 4,
            sliderInput(ns("regulatorIowaSlider"), "Iowa:",
                       min = 0, max = 1, value = 0.7, step = 0.1)
          ),
          column(
            width = 4,
            sliderInput(ns("regulatorGeorgiaSlider"), "Georgia:",
                       min = 0, max = 1, value = 0.5, step = 0.1)
          ),
          column(
            width = 4,
            sliderInput(ns("regulatorFloridaSlider"), "Florida:",
                       min = 0, max = 1, value = 0.9, step = 0.1)
          )
        ),
        
        hr(),
        
        actionButton(ns("saveParametersBtn"), "Save Parameters", class = "btn-primary")
      ),
      
      box(
        title = "Event Generation",
        status = "danger",
        solidHeader = TRUE,
        collapsible = TRUE,
        width = 6,
        
        h4("Catastrophic Events"),
        
        fluidRow(
          column(
            width = 4,
            numericInput(ns("catProbIowaInput"), "Iowa Catastrophe Probability:",
                        min = 0, max = 1, value = 0.05, step = 0.01)
          ),
          column(
            width = 4,
            numericInput(ns("catProbGeorgiaInput"), "Georgia Catastrophe Probability:",
                        min = 0, max = 1, value = 0.1, step = 0.01)
          ),
          column(
            width = 4,
            numericInput(ns("catProbFloridaInput"), "Florida Catastrophe Probability:",
                        min = 0, max = 1, value = 0.2, step = 0.01)
          )
        ),
        
        hr(),
        
        h4("Manual Event Creation"),
        
        selectInput(ns("eventTypeSelect"), "Event Type:",
                   choices = c("Natural Disaster", "Regulatory Change", "Economic Shift", "Competitor Action")),
        
        selectInput(ns("eventRegionSelect"), "Region Affected:",
                   choices = c("All", "Iowa", "Georgia", "Florida")),
        
        textAreaInput(ns("eventDescInput"), "Event Description:",
                     rows = 3),
        
        numericInput(ns("eventMagnitudeInput"), "Event Magnitude (1-10):",
                    min = 1, max = 10, value = 5),
        
        actionButton(ns("createEventBtn"), "Create Event", class = "btn-danger")
      )
    ),
    
    fluidRow(
      box(
        title = "Simulation Results",
        status = "success",
        solidHeader = TRUE,
        width = 12,
        
        tabsetPanel(
          tabPanel(
            "Market Overview",
            br(),
            plotOutput(ns("marketSharePlot"), height = "300px"),
            hr(),
            plotOutput(ns("lossRatioPlot"), height = "300px")
          ),
          
          tabPanel(
            "Player Performance",
            br(),
            selectInput(ns("playerSelector"), "Select Player:", choices = c("All Players")),
            hr(),
            plotOutput(ns("playerPerformancePlot"), height = "300px"),
            hr(),
            verbatimTextOutput(ns("playerStatsOutput"))
          ),
          
          tabPanel(
            "Raw Data",
            br(),
            selectInput(ns("rawDataTypeSelect"), "Data Type:",
                       choices = c("Game State", "Player Decisions", "Simulation Results")),
            hr(),
            verbatimTextOutput(ns("rawDataOutput"))
          )
        )
      )
    )
  )
}

#' Administrator server module
#' 
#' @param id Namespace ID for the module
#' @param gameData Reactive values storing game data
#' @return Server module function
adminServerModule <- function(id, gameData) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Initialize reactive values
    localGameData <- reactiveValues(
      currentTurn = 0,
      gameState = NULL,
      players = list(),
      decisions = list(),
      turnChoices = c("Latest" = "latest")
    )
    
    # Update local game data when module initializes
    observe({
      # Get the latest turn
      latestTurn <- get_latest_turn()
      
      if (latestTurn > 0) {
        # Load game state
        gameState <- load_game_state(latestTurn)
        
        if (!is.null(gameState)) {
          localGameData$currentTurn <- latestTurn
          localGameData$gameState <- gameState
          
          # Update turn selector choices
          turns <- c("Latest" = "latest")
          if (latestTurn > 0) {
            for (i in 0:latestTurn) {
              turns <- c(turns, setNames(as.character(i), paste0("Turn ", i)))
            }
          }
          localGameData$turnChoices <- turns
          updateSelectInput(session, "turnSelector", choices = turns)
          
          # Get player decisions for the latest turn
          localGameData$decisions <- aggregate_player_decisions(latestTurn)
          
          # Get all player profiles
          # This would normally scan all profile files, simplified for now
          # localGameData$players <- get_all_players()
        }
      }
    })
    
    # Display game status
    output$gameStatusOutput <- renderText({
      if (is.null(localGameData$gameState)) {
        return("Game not initialized. Please initialize a new game.")
      }
      
      paste0(
        "Current Turn: ", localGameData$currentTurn, "\n",
        "Last Updated: ", localGameData$gameState$timestamp, "\n",
        "Number of Players: ", length(localGameData$players), "\n",
        "Decisions Submitted: ", length(localGameData$decisions), "\n"
      )
    })
    
    # Initialize a new game
    observeEvent(input$initializeGameBtn, {
      showModal(modalDialog(
        title = "Confirm New Game",
        "Are you sure you want to initialize a new game? This will reset all game data.",
        footer = tagList(
          actionButton(ns("confirmInitBtn"), "Yes, Initialize", class = "btn-warning"),
          modalButton("Cancel")
        )
      ))
    })
    
    # Confirm new game initialization
    observeEvent(input$confirmInitBtn, {
      # Initialize new game
      success <- initialize_new_game()
      
      if (success) {
        localGameData$currentTurn <- 0
        localGameData$gameState <- load_game_state(0)
        localGameData$players <- list()
        localGameData$decisions <- list()
        
        # Update turn selector
        localGameData$turnChoices <- c("Latest" = "latest", "Turn 0" = "0")
        updateSelectInput(session, "turnSelector", choices = localGameData$turnChoices)
        
        showNotification("New game initialized successfully!", type = "message")
      } else {
        showNotification("Failed to initialize new game.", type = "error")
      }
      
      removeModal()
    })
    
    # Advance to next turn
    observeEvent(input$advanceTurnBtn, {
      if (is.null(localGameData$gameState)) {
        showNotification("Please initialize a game first.", type = "warning")
        return()
      }
      
      # Check if decisions have been aggregated
      if (length(localGameData$decisions) == 0) {
        showNotification("No player decisions found. Please aggregate decisions first.", type = "warning")
        return()
      }
      
      showModal(modalDialog(
        title = "Confirm Turn Advancement",
        paste0("Are you sure you want to advance from Turn ", localGameData$currentTurn, " to Turn ", localGameData$currentTurn + 1, "?"),
        footer = tagList(
          actionButton(ns("confirmAdvanceBtn"), "Yes, Advance", class = "btn-success"),
          modalButton("Cancel")
        )
      ))
    })
    
    # Confirm turn advancement
    observeEvent(input$confirmAdvanceBtn, {
      # Get current game state
      currentState <- localGameData$gameState
      
      # Update market conditions based on parameters
      currentState$market_conditions$market_condition <- input$marketConditionSlider
      currentState$parameters$regulator_strictness$Iowa <- input$regulatorIowaSlider
      currentState$parameters$regulator_strictness$Georgia <- input$regulatorGeorgiaSlider
      currentState$parameters$regulator_strictness$Florida <- input$regulatorFloridaSlider
      currentState$parameters$catastrophe_probability$Iowa <- input$catProbIowaInput
      currentState$parameters$catastrophe_probability$Georgia <- input$catProbGeorgiaInput
      currentState$parameters$catastrophe_probability$Florida <- input$catProbFloridaInput
      
      # Process player decisions and update simulation
      # This would call the simulation engine and update the game state
      # For now, we'll just increment the turn
      newTurn <- localGameData$currentTurn + 1
      currentState$turn <- newTurn
      
      # Save the new game state
      success <- save_game_state(currentState, newTurn)
      
      if (success) {
        localGameData$currentTurn <- newTurn
        localGameData$gameState <- currentState
        
        # Update turn selector
        turns <- localGameData$turnChoices
        turns <- c(turns, setNames(as.character(newTurn), paste0("Turn ", newTurn)))
        localGameData$turnChoices <- turns
        updateSelectInput(session, "turnSelector", choices = turns)
        
        showNotification(paste0("Advanced to Turn ", newTurn, " successfully!"), type = "message")
      } else {
        showNotification("Failed to advance turn.", type = "error")
      }
      
      removeModal()
    })
    
    # Aggregate player decisions
    observeEvent(input$aggregateDecisionsBtn, {
      if (is.null(localGameData$gameState)) {
        showNotification("Please initialize a game first.", type = "warning")
        return()
      }
      
      # Aggregate decisions for the current turn
      decisions <- aggregate_player_decisions(localGameData$currentTurn)
      
      if (length(decisions) > 0) {
        localGameData$decisions <- decisions
        showNotification(paste0("Aggregated ", length(decisions), " player decisions."), type = "message")
      } else {
        showNotification("No player decisions found for the current turn.", type = "warning")
      }
    })
    
    # Save simulation parameters
    observeEvent(input$saveParametersBtn, {
      if (is.null(localGameData$gameState)) {
        showNotification("Please initialize a game first.", type = "warning")
        return()
      }
      
      # Update parameters in the current game state
      currentState <- localGameData$gameState
      currentState$market_conditions$market_condition <- input$marketConditionSlider
      currentState$parameters$regulator_strictness$Iowa <- input$regulatorIowaSlider
      currentState$parameters$regulator_strictness$Georgia <- input$regulatorGeorgiaSlider
      currentState$parameters$regulator_strictness$Florida <- input$regulatorFloridaSlider
      currentState$parameters$catastrophe_probability$Iowa <- input$catProbIowaInput
      currentState$parameters$catastrophe_probability$Georgia <- input$catProbGeorgiaInput
      currentState$parameters$catastrophe_probability$Florida <- input$catProbFloridaInput
      
      # Save the updated game state
      success <- save_game_state(currentState, localGameData$currentTurn)
      
      if (success) {
        localGameData$gameState <- currentState
        showNotification("Parameters saved successfully!", type = "message")
      } else {
        showNotification("Failed to save parameters.", type = "error")
      }
    })
    
    # Create manual event
    observeEvent(input$createEventBtn, {
      if (is.null(localGameData$gameState)) {
        showNotification("Please initialize a game first.", type = "warning")
        return()
      }
      
      # Create event object
      event <- list(
        type = input$eventTypeSelect,
        region = input$eventRegionSelect,
        description = input$eventDescInput,
        magnitude = input$eventMagnitudeInput,
        timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S")
      )
      
      # Add event to game state
      currentState <- localGameData$gameState
      currentState$events[[length(currentState$events) + 1]] <- event
      
      # Save the updated game state
      success <- save_game_state(currentState, localGameData$currentTurn)
      
      if (success) {
        localGameData$gameState <- currentState
        showNotification("Event created successfully!", type = "message")
      } else {
        showNotification("Failed to create event.", type = "error")
      }
    })
    
    # Player participation table
    output$playerParticipationTable <- renderDataTable({
      if (length(localGameData$decisions) == 0) {
        return(data.frame(
          Player = character(0),
          Submitted = logical(0),
          Timestamp = character(0)
        ))
      }
      
      # Create data frame of player decisions
      players <- names(localGameData$decisions)
      submitted <- rep(TRUE, length(players))
      timestamps <- sapply(localGameData$decisions, function(d) d$timestamp)
      
      data.frame(
        Player = players,
        Submitted = submitted,
        Timestamp = timestamps
      )
    })
    
    # Plot market share (placeholder)
    output$marketSharePlot <- renderPlot({
      # This would be replaced with actual plot generation based on simulation results
      plot(1:5, runif(5, 0, 10), type = "b", 
           main = "Market Share by Insurance Line", 
           xlab = "Insurance Line", ylab = "Market Share (%)",
           xaxt = "n")
      axis(1, at = 1:5, labels = c("Home", "Auto", "Health", "Life", "Annuities"))
    })
    
    # Plot loss ratio (placeholder)
    output$lossRatioPlot <- renderPlot({
      # This would be replaced with actual plot generation based on simulation results
      plot(1:5, runif(5, 60, 100), type = "b", 
           main = "Loss Ratio by Insurance Line", 
           xlab = "Insurance Line", ylab = "Loss Ratio (%)",
           xaxt = "n")
      axis(1, at = 1:5, labels = c("Home", "Auto", "Health", "Life", "Annuities"))
    })
    
    # Player performance plot (placeholder)
    output$playerPerformancePlot <- renderPlot({
      # This would be replaced with actual plot generation based on player performance
      barplot(runif(5, 0, 100), 
              main = "Player Performance Metrics", 
              names.arg = c("ROI", "Market Share", "Loss Ratio", "Combined Ratio", "Profit Margin"),
              col = "steelblue")
    })
    
    # Raw data output (placeholder)
    output$rawDataOutput <- renderPrint({
      if (input$rawDataTypeSelect == "Game State" && !is.null(localGameData$gameState)) {
        return(str(localGameData$gameState))
      } else if (input$rawDataTypeSelect == "Player Decisions" && length(localGameData$decisions) > 0) {
        return(str(localGameData$decisions))
      } else if (input$rawDataTypeSelect == "Simulation Results" && !is.null(localGameData$gameState$results)) {
        return(str(localGameData$gameState$results))
      } else {
        return("No data available.")
      }
    })
    
    # Return any reactive data that should be accessible outside the module
    return(reactive({
      list(
        currentTurn = localGameData$currentTurn,
        gameState = localGameData$gameState
      )
    }))
  })
} 