# Tech Tree Module for Insurance Simulation Game
# This module allows players to invest in skills and track progression

# UI Component
techTreeUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    h2("Tech Tree - Skill Development"),
    p("Invest in personal and organizational skills to improve your company's performance."),
    
    # Available skill points display
    fluidRow(
      column(12,
        div(class = "skill-points-card",
          h4("Available Skill Points"),
          div(class = "skill-points-display",
            textOutput(ns("availablePoints"), inline = TRUE)
          ),
          actionButton(ns("earnPointsBtn"), "How to Earn Points", class = "btn-sm btn-info"),
          actionButton(ns("viewPointHistoryBtn"), "View Point History", class = "btn-sm btn-info")
        )
      )
    ),
    
    # Basic skills
    h3("Management Skills"),
    fluidRow(
      column(4,
        div(class = "skill-card",
          div(class = "skill-header",
            h4("Operational Efficiency"),
            p(class = "skill-level", "Level: ", 
              span(id = ns("managementEfficiencyLevel"), "0/5"))
          ),
          p("Reduce operational costs across all insurance lines."),
          div(class = "skill-effects",
            p("Effects: -2% operational costs per level")
          ),
          div(class = "skill-actions",
            actionButton(ns("upgradeManagementEfficiency"), "Upgrade (1 Point)", 
                        class = "btn-sm btn-primary")
          )
        )
      ),
      column(4,
        div(class = "skill-card",
          div(class = "skill-header",
            h4("Leadership"),
            p(class = "skill-level", "Level: ", 
              span(id = ns("managementLeadershipLevel"), "0/5"))
          ),
          p("Improve employee productivity and reduce turnover."),
          div(class = "skill-effects",
            p("Effects: +3% productivity per level")
          ),
          div(class = "skill-actions",
            actionButton(ns("upgradeManagementLeadership"), "Upgrade (1 Point)", 
                        class = "btn-sm btn-primary")
          )
        )
      ),
      column(4,
        div(class = "skill-card",
          div(class = "skill-header",
            h4("Regulatory Expertise"),
            p(class = "skill-level", "Level: ", 
              span(id = ns("managementRegulationLevel"), "0/5"))
          ),
          p("Better navigate regulatory requirements and compliance."),
          div(class = "skill-effects",
            p("Effects: -5% compliance costs per level")
          ),
          div(class = "skill-actions",
            actionButton(ns("upgradeManagementRegulation"), "Upgrade (1 Point)", 
                        class = "btn-sm btn-primary")
          )
        )
      )
    ),
    
    h3("Technical Skills"),
    fluidRow(
      column(6,
        div(class = "skill-card",
          div(class = "skill-header",
            h4("Actuarial Science"),
            p(class = "skill-level", "Level: ", 
              span(id = ns("actuarialScienceLevel"), "0/5"))
          ),
          p("Improve pricing accuracy and risk assessment."),
          div(class = "skill-effects",
            p("Effects: +4% pricing accuracy per level")
          ),
          div(class = "skill-actions",
            actionButton(ns("upgradeActuarialScience"), "Upgrade (1 Point)", 
                        class = "btn-sm btn-primary")
          )
        )
      ),
      column(6,
        div(class = "skill-card",
          div(class = "skill-header",
            h4("Risk Analysis"),
            p(class = "skill-level", "Level: ", 
              span(id = ns("riskAnalysisLevel"), "0/5"))
          ),
          p("Better assess and mitigate potential risks."),
          div(class = "skill-effects",
            p("Effects: -3% loss ratio per level")
          ),
          div(class = "skill-actions",
            actionButton(ns("upgradeRiskAnalysis"), "Upgrade (1 Point)", 
                        class = "btn-sm btn-primary")
          )
        )
      )
    )
  )
}

# Server Component
techTreeServer <- function(id, userProfile, gameData) {
  moduleServer(id, function(input, output, session) {
    
    # Initialize reactive values
    skillData <- reactiveValues(
      availablePoints = 3,
      skills = list(
        managementEfficiency = 0,
        managementLeadership = 0,
        managementRegulation = 0,
        actuarialScience = 0,
        riskAnalysis = 0
      ),
      pointHistory = list() # New field for tracking point history
    )
    
    # On initialization, load skills from storage
    observe({
      if (userProfile$initialized && !is.null(userProfile$player_id)) {
        # Load skills from storage
        player_skills <- load_player_skills(userProfile$player_id)
        
        # Update skill data with loaded values
        skillData$availablePoints <- player_skills$availablePoints
        skillData$skills$managementEfficiency <- player_skills$managementEfficiency
        skillData$skills$managementLeadership <- player_skills$managementLeadership
        skillData$skills$managementRegulation <- player_skills$managementRegulation
        skillData$skills$actuarialScience <- player_skills$actuarialScience
        skillData$skills$riskAnalysis <- player_skills$riskAnalysis
        
        # Load point history if it exists
        if (!is.null(player_skills$pointHistory)) {
          skillData$pointHistory <- player_skills$pointHistory
        }
        
        # Update UI to reflect loaded skills
        updateTextInput(session, "managementEfficiencyLevel", 
                      value = paste0(skillData$skills$managementEfficiency, "/5"))
        updateTextInput(session, "managementLeadershipLevel", 
                      value = paste0(skillData$skills$managementLeadership, "/5"))
        updateTextInput(session, "managementRegulationLevel", 
                      value = paste0(skillData$skills$managementRegulation, "/5"))
        updateTextInput(session, "actuarialScienceLevel", 
                      value = paste0(skillData$skills$actuarialScience, "/5"))
        updateTextInput(session, "riskAnalysisLevel", 
                      value = paste0(skillData$skills$riskAnalysis, "/5"))
      }
    })
    
    # Save skills to storage whenever they change
    observe({
      if (userProfile$initialized && !is.null(userProfile$player_id)) {
        # Create skills object for saving
        skills_to_save <- list(
          availablePoints = skillData$availablePoints,
          managementEfficiency = skillData$skills$managementEfficiency,
          managementLeadership = skillData$skills$managementLeadership,
          managementRegulation = skillData$skills$managementRegulation,
          actuarialScience = skillData$skills$actuarialScience,
          riskAnalysis = skillData$skills$riskAnalysis,
          investmentStrategy = 0,
          productInnovation = 0,
          dataAnalytics = 0,
          digitalTransformation = 0,
          pointHistory = skillData$pointHistory
        )
        
        # Save to storage
        save_player_skills(userProfile$player_id, skills_to_save)
      }
    })
    
    # Display available points
    output$availablePoints <- renderText({
      skillData$availablePoints
    })
    
    # Management Efficiency upgrade
    observeEvent(input$upgradeManagementEfficiency, {
      if (skillData$availablePoints > 0 && skillData$skills$managementEfficiency < 5) {
        skillData$availablePoints <- skillData$availablePoints - 1
        skillData$skills$managementEfficiency <- skillData$skills$managementEfficiency + 1
        updateTextInput(session, "managementEfficiencyLevel", 
                       value = paste0(skillData$skills$managementEfficiency, "/5"))
        showNotification("Upgraded Operational Efficiency!", type = "message")
      } else if (skillData$skills$managementEfficiency >= 5) {
        showNotification("Max level reached!", type = "warning")
      } else {
        showNotification("Not enough skill points!", type = "warning")
      }
    })
    
    # Leadership upgrade
    observeEvent(input$upgradeManagementLeadership, {
      if (skillData$availablePoints > 0 && skillData$skills$managementLeadership < 5) {
        skillData$availablePoints <- skillData$availablePoints - 1
        skillData$skills$managementLeadership <- skillData$skills$managementLeadership + 1
        updateTextInput(session, "managementLeadershipLevel", 
                       value = paste0(skillData$skills$managementLeadership, "/5"))
        showNotification("Upgraded Leadership!", type = "message")
      } else if (skillData$skills$managementLeadership >= 5) {
        showNotification("Max level reached!", type = "warning")
      } else {
        showNotification("Not enough skill points!", type = "warning")
      }
    })
    
    # Regulatory Expertise upgrade
    observeEvent(input$upgradeManagementRegulation, {
      if (skillData$availablePoints > 0 && skillData$skills$managementRegulation < 5) {
        skillData$availablePoints <- skillData$availablePoints - 1
        skillData$skills$managementRegulation <- skillData$skills$managementRegulation + 1
        updateTextInput(session, "managementRegulationLevel", 
                       value = paste0(skillData$skills$managementRegulation, "/5"))
        showNotification("Upgraded Regulatory Expertise!", type = "message")
      } else if (skillData$skills$managementRegulation >= 5) {
        showNotification("Max level reached!", type = "warning")
      } else {
        showNotification("Not enough skill points!", type = "warning")
      }
    })
    
    # Actuarial Science upgrade
    observeEvent(input$upgradeActuarialScience, {
      if (skillData$availablePoints > 0 && skillData$skills$actuarialScience < 5) {
        skillData$availablePoints <- skillData$availablePoints - 1
        skillData$skills$actuarialScience <- skillData$skills$actuarialScience + 1
        updateTextInput(session, "actuarialScienceLevel", 
                       value = paste0(skillData$skills$actuarialScience, "/5"))
        showNotification("Upgraded Actuarial Science!", type = "message")
      } else if (skillData$skills$actuarialScience >= 5) {
        showNotification("Max level reached!", type = "warning")
      } else {
        showNotification("Not enough skill points!", type = "warning")
      }
    })
    
    # Risk Analysis upgrade
    observeEvent(input$upgradeRiskAnalysis, {
      if (skillData$availablePoints > 0 && skillData$skills$riskAnalysis < 5) {
        skillData$availablePoints <- skillData$availablePoints - 1
        skillData$skills$riskAnalysis <- skillData$skills$riskAnalysis + 1
        updateTextInput(session, "riskAnalysisLevel", 
                       value = paste0(skillData$skills$riskAnalysis, "/5"))
        showNotification("Upgraded Risk Analysis!", type = "message")
      } else if (skillData$skills$riskAnalysis >= 5) {
        showNotification("Max level reached!", type = "warning")
      } else {
        showNotification("Not enough skill points!", type = "warning")
      }
    })
    
    # Info modal for skill points
    observeEvent(input$earnPointsBtn, {
      showModal(modalDialog(
        title = "How to Earn Skill Points",
        p("Skill points are earned through:"),
        tags$ul(
          tags$li("Company Performance: Points awarded at the end of each year based on financial results"),
          tags$li("Financial Achievements: Meeting specific financial targets"),
          tags$li("Innovation Bonuses: Successfully implementing new strategies"),
          tags$li("Educational Investment: Allocating resources to training and development")
        ),
        easyClose = TRUE,
        footer = modalButton("Close")
      ))
    })
    
    # View point history modal
    observeEvent(input$viewPointHistoryBtn, {
      # Create HTML for point history
      history_html <- ""
      
      if (length(skillData$pointHistory) > 0) {
        history_html <- tags$div(
          tags$table(class = "table table-striped",
            tags$thead(
              tags$tr(
                tags$th("Date"),
                tags$th("Event"),
                tags$th("Points")
              )
            ),
            tags$tbody(
              lapply(skillData$pointHistory, function(event) {
                tags$tr(
                  tags$td(event$date),
                  tags$td(event$description),
                  tags$td(paste0("+", event$points))
                )
              })
            )
          )
        )
      } else {
        history_html <- tags$p("No skill points have been awarded yet.")
      }
      
      showModal(modalDialog(
        title = "Skill Point History",
        history_html,
        easyClose = TRUE,
        footer = modalButton("Close")
      ))
    })
    
    # Function to add skill points with an event entry
    addSkillPointEvent <- function(points, event_description) {
      if (userProfile$initialized && !is.null(userProfile$player_id) && points > 0) {
        # Update available points
        skillData$availablePoints <- skillData$availablePoints + points
        
        # Create event entry
        event_entry <- list(
          date = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
          description = event_description,
          points = points
        )
        
        # Add to history
        skillData$pointHistory <- c(list(event_entry), skillData$pointHistory)
        
        # Show notification
        showNotification(
          paste0("You earned ", points, " skill point", ifelse(points > 1, "s", ""), "!"),
          type = "message"
        )
        
        # Return TRUE for successful award
        return(TRUE)
      }
      
      # Return FALSE if points couldn't be awarded
      return(FALSE)
    }
    
    # Testing function - simulates performance achievement event
    observeEvent(input$testPerformanceEvent, {
      addSkillPointEvent(1, "Achieved quarterly profit target")
    })
    
    # Testing function - simulates innovation event
    observeEvent(input$testInnovationEvent, {
      addSkillPointEvent(2, "Successfully implemented new digital platform")
    })
    
    # Testing function - simulates educational event
    observeEvent(input$testEducationalEvent, {
      addSkillPointEvent(1, "Completed executive training program")
    })
    
    # Return skill data and award function for other modules
    return(reactive({
      list(
        skills = skillData$skills,
        awardPoints = function(points, description) {
          addSkillPointEvent(points, description)
        }
      )
    }))
  })
} 