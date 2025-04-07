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
          actionButton(ns("earnPointsBtn"), "How to Earn Points", class = "btn-sm btn-info")
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
      )
    )
    
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
    
    # Return skill data for other modules
    return(reactive({
      skillData$skills
    }))
  })
} 