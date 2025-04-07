# Insurance Simulation Game - Profile Module
# This file contains a Shiny module for managing player profiles

library(shiny)
library(shinyjs)

#' Player Profile UI Module
#' 
#' @param id Namespace ID for the module
#' @return A UI definition for the player profile setup
profileUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    useShinyjs(),
    div(class = "profile-setup",
      h2("Executive Profile Setup"),
      p("Create your executive identity by selecting your background and education. Your choices will impact your starting conditions and abilities."),
      
      fluidRow(
        column(6,
          div(class = "executive-card",
            h3("Personal Information"),
            div(class = "form-group",
              textInput(ns("username"), "Username:", 
                       placeholder = "Enter your username"),
              
              div(
                title = "Your secondary major affects your starting skills. Hover over each option to see its impact.",
                selectInput(ns("secondaryMajor"), "Secondary Major:", 
                         choices = c("Finance" = "Finance", 
                                    "Actuarial Science" = "Actuarial Science", 
                                    "Business Analytics" = "Business Analytics", 
                                    "Marketing" = "Marketing", 
                                    "Management" = "Management"))
              ),
              
              # Add description for each major option
              div(id = ns("majorDescription"), class = "description-box")
            )
          )
        ),
        column(6,
          div(class = "executive-card",
            h3("Education"),
            div(class = "form-group",
              div(
                title = "Your graduate degree affects your specialized skills. Hover over each option to see its impact.",
                selectInput(ns("gradSchool"), "Graduate School Option:", 
                         choices = c("MBA" = "MBA", 
                                    "MS in Risk Management" = "MS in Risk Management", 
                                    "MS in Finance" = "MS in Finance", 
                                    "MS in Actuarial Science" = "MS in Actuarial Science", 
                                    "PhD" = "PhD"))
              ),
              
              # Add description for each grad school option
              div(id = ns("gradSchoolDescription"), class = "description-box"),
              
              div(
                title = "Your university provides regional advantages and network benefits. Hover over each option to see its impact.",
                selectInput(ns("university"), "University:", 
                         choices = c("University of Iowa" = "University of Iowa", 
                                    "Florida State University" = "Florida State University", 
                                    "University of Georgia" = "University of Georgia"))
              ),
              
              # Add description for each university option
              div(id = ns("universityDescription"), class = "description-box")
            )
          )
        )
      ),
      
      div(id = ns("impactSection"), class = "executive-card", style = "margin-top: 20px; display: none;",
        h3("Impact of Your Choices"),
        fluidRow(
          column(4,
            h4("Starting Skills"),
            div(id = ns("skillsImpact"), class = "impact-details")
          ),
          column(4,
            h4("Financial Impacts"),
            div(id = ns("financialImpact"), class = "impact-details")
          ),
          column(4,
            h4("Market Advantages"),
            div(id = ns("marketImpact"), class = "impact-details")
          )
        )
      ),
      
      div(style = "margin-top: 20px; text-align: center;",
        actionButton(ns("previewImpactBtn"), "Preview Impact", class = "btn-info"),
        actionButton(ns("saveProfileBtn"), "Save Profile", class = "btn-primary")
      )
    )
  )
}

#' Player Profile Server Module
#' 
#' @param id Namespace ID for the module
#' @param userProfile Reactive values containing user profile data
#' @return Server module function
profileServer <- function(id, userProfile) {
  moduleServer(id, function(input, output, session) {
    
    # Initialize reactive values for profile impact
    profileImpact <- reactiveValues(
      skills = NULL,
      financial = NULL,
      market = NULL
    )
    
    # Define impact of different choices
    skillImpacts <- list(
      # Major impacts
      Finance = list(
        investing = 3,
        riskManagement = 2,
        marketing = 1
      ),
      "Actuarial Science" = list(
        investing = 1,
        riskManagement = 3,
        marketing = 0
      ),
      "Business Analytics" = list(
        investing = 2,
        riskManagement = 2,
        marketing = 2
      ),
      Marketing = list(
        investing = 0,
        riskManagement = 1,
        marketing = 3
      ),
      Management = list(
        investing = 1,
        riskManagement = 1,
        marketing = 2
      ),
      
      # Grad school impacts
      MBA = list(
        investing = 2,
        riskManagement = 1,
        marketing = 2
      ),
      "MS in Risk Management" = list(
        investing = 1,
        riskManagement = 3,
        marketing = 0
      ),
      "MS in Finance" = list(
        investing = 3,
        riskManagement = 2,
        marketing = 0
      ),
      "MS in Actuarial Science" = list(
        investing = 1,
        riskManagement = 3,
        marketing = 0
      ),
      PhD = list(
        investing = 2,
        riskManagement = 2,
        marketing = 0
      ),
      
      # University impacts
      "University of Iowa" = list(
        investing = 1,
        riskManagement = 2,
        marketing = 1
      ),
      "Florida State University" = list(
        investing = 2,
        riskManagement = 1,
        marketing = 1
      ),
      "University of Georgia" = list(
        investing = 2,
        riskManagement = 2,
        marketing = 1
      )
    )
    
    # Add descriptions for each option
    majorDescriptions <- list(
      Finance = "Finance specialization enhances your investing skills significantly (+3), with moderate improvements to risk management (+2) and slight marketing benefits (+1).",
      "Actuarial Science" = "Actuarial Science provides strong risk management capabilities (+3), with minor investing benefits (+1) but no marketing advantages.",
      "Business Analytics" = "Business Analytics offers balanced skill development across investing (+2), risk management (+2), and marketing (+2).",
      Marketing = "Marketing specialization maximizes your marketing abilities (+3), with a slight improvement in risk management (+1) but no investment advantages.",
      Management = "Management provides modest skills across all areas with better marketing focus (+2), and basic investing (+1) and risk management (+1) capabilities."
    )
    
    gradSchoolDescriptions <- list(
      MBA = "An MBA provides good all-around business knowledge with strong investing (+2) and marketing skills (+2), and basic risk management (+1).",
      "MS in Risk Management" = "MS in Risk Management maximizes your risk assessment capabilities (+3), with minor investing knowledge (+1) but no marketing advantages.",
      "MS in Finance" = "MS in Finance significantly enhances your investment expertise (+3) and risk management (+2), but offers no marketing benefits.",
      "MS in Actuarial Science" = "MS in Actuarial Science provides excellent risk management skills (+3) with basic investing knowledge (+1) but no marketing advantages.",
      PhD = "A PhD offers advanced analytical skills with strong investing (+2) and risk management (+2) capabilities, but no marketing benefits."
    )
    
    universityDescriptions <- list(
      "University of Iowa" = "University of Iowa provides solid risk management education (+2) with basic investing (+1) and marketing (+1) skills. Regional strength in Iowa.",
      "Florida State University" = "Florida State University offers strong investment education (+2) with basic risk management (+1) and marketing (+1) skills. Regional strength in Florida.",
      "University of Georgia" = "University of Georgia provides balanced training with good investing (+2) and risk management (+2) skills and basic marketing (+1). Regional strength in Georgia."
    )
    
    # Function to calculate skill impact
    calculateSkillImpact <- function(major, gradSchool, university) {
      # Sum up skill impacts from major, grad school, and university
      investing <- skillImpacts[[major]]$investing + 
                  skillImpacts[[gradSchool]]$investing + 
                  skillImpacts[[university]]$investing
      
      riskManagement <- skillImpacts[[major]]$riskManagement + 
                      skillImpacts[[gradSchool]]$riskManagement + 
                      skillImpacts[[university]]$riskManagement
      
      marketing <- skillImpacts[[major]]$marketing + 
                 skillImpacts[[gradSchool]]$marketing + 
                 skillImpacts[[university]]$marketing
      
      # Calculate normalized scores (1-10 scale)
      maxPossible <- 9  # 3 (max per choice) * 3 (choices)
      investing <- round(investing / maxPossible * 10)
      riskManagement <- round(riskManagement / maxPossible * 10)
      marketing <- round(marketing / maxPossible * 10)
      
      return(list(
        investing = investing,
        riskManagement = riskManagement,
        marketing = marketing
      ))
    }
    
    # Function to calculate financial impact
    calculateFinancialImpact <- function(major, gradSchool, university) {
      # Base starting capital
      baseCapital <- 1000000
      
      # Multipliers for different choices
      majorMultiplier <- switch(major,
        "Finance" = 1.2,
        "Actuarial Science" = 1.1,
        "Business Analytics" = 1.15,
        "Marketing" = 1.0,
        "Management" = 1.05,
        1.0
      )
      
      gradSchoolMultiplier <- switch(gradSchool,
        "MBA" = 1.15,
        "MS in Risk Management" = 1.1,
        "MS in Finance" = 1.2,
        "MS in Actuarial Science" = 1.1,
        "PhD" = 1.05,
        1.0
      )
      
      universityMultiplier <- switch(university,
        "University of Iowa" = 1.05,
        "Florida State University" = 1.2,
        "University of Georgia" = 1.2,
        1.0
      )
      
      # Calculate capital
      capital <- baseCapital * majorMultiplier * gradSchoolMultiplier * universityMultiplier
      
      # Calculate salary
      baseSalary <- 120000
      salary <- baseSalary * (majorMultiplier + gradSchoolMultiplier + universityMultiplier) / 3
      
      return(list(
        startingCapital = round(capital),
        annualSalary = round(salary)
      ))
    }
    
    # Function to calculate market impact
    calculateMarketImpact <- function(major, gradSchool, university) {
      # Base market advantage
      baseAdvantage <- 0
      
      # Calculate advantages based on choices
      majorAdvantage <- switch(major,
        "Finance" = "Lower cost of capital",
        "Actuarial Science" = "Better risk assessment",
        "Business Analytics" = "Enhanced data insights",
        "Marketing" = "Improved brand recognition",
        "Management" = "Better operational efficiency",
        "None"
      )
      
      gradSchoolAdvantage <- switch(gradSchool,
        "MBA" = "Better management efficiency",
        "MS in Risk Management" = "Improved risk pricing",
        "MS in Finance" = "Enhanced investment returns",
        "MS in Actuarial Science" = "Precise premium setting",
        "PhD" = "Advanced research capabilities",
        "None"
      )
      
      universityAdvantage <- switch(university,
        "University of Iowa" = "Strong actuarial connections",
        "Florida State University" = "Elite investment network",
        "University of Georgia" = "Executive leadership network",
        "None"
      )
      
      # Determine regional strength
      regionalStrength <- switch(university,
        "University of Iowa" = "Iowa",
        "Florida State University" = "Florida",
        "University of Georgia" = "Georgia",
        "None"
      )
      
      return(list(
        majorAdvantage = majorAdvantage,
        gradSchoolAdvantage = gradSchoolAdvantage,
        universityAdvantage = universityAdvantage,
        regionalStrength = regionalStrength
      ))
    }
    
    # Create skill impact visualization
    renderSkillVisualization <- function(skill_type, skill_value) {
      sprintf(
        '<div class="skill-bar"><span>%s: </span><div class="progress">
         <div class="progress-bar bg-info" role="progressbar" style="width: %d%%;" 
         aria-valuenow="%d" aria-valuemin="0" aria-valuemax="10">%d/10</div>
         </div></div>',
        skill_type, skill_value * 10, skill_value, skill_value
      )
    }
    
    # Update descriptions when options change
    observeEvent(input$secondaryMajor, {
      if (input$secondaryMajor %in% names(majorDescriptions)) {
        description <- majorDescriptions[[input$secondaryMajor]]
        
        # Create skill impact visualization
        skillImpact <- skillImpacts[[input$secondaryMajor]]
        investing_viz <- renderSkillVisualization("Investing", skillImpact$investing)
        risk_viz <- renderSkillVisualization("Risk Management", skillImpact$riskManagement)
        marketing_viz <- renderSkillVisualization("Marketing", skillImpact$marketing)
        
        html_content <- paste0(
          '<div class="option-description">', description, '</div>',
          '<div class="option-skills">', investing_viz, risk_viz, marketing_viz, '</div>'
        )
        
        shinyjs::html("majorDescription", html_content)
        shinyjs::show("majorDescription")
      } else {
        shinyjs::hide("majorDescription")
      }
    })
    
    observeEvent(input$gradSchool, {
      if (input$gradSchool %in% names(gradSchoolDescriptions)) {
        description <- gradSchoolDescriptions[[input$gradSchool]]
        
        # Create skill impact visualization
        skillImpact <- skillImpacts[[input$gradSchool]]
        investing_viz <- renderSkillVisualization("Investing", skillImpact$investing)
        risk_viz <- renderSkillVisualization("Risk Management", skillImpact$riskManagement)
        marketing_viz <- renderSkillVisualization("Marketing", skillImpact$marketing)
        
        html_content <- paste0(
          '<div class="option-description">', description, '</div>',
          '<div class="option-skills">', investing_viz, risk_viz, marketing_viz, '</div>'
        )
        
        shinyjs::html("gradSchoolDescription", html_content)
        shinyjs::show("gradSchoolDescription")
      } else {
        shinyjs::hide("gradSchoolDescription")
      }
    })
    
    observeEvent(input$university, {
      if (input$university %in% names(universityDescriptions)) {
        description <- universityDescriptions[[input$university]]
        
        # Create skill impact visualization
        skillImpact <- skillImpacts[[input$university]]
        investing_viz <- renderSkillVisualization("Investing", skillImpact$investing)
        risk_viz <- renderSkillVisualization("Risk Management", skillImpact$riskManagement)
        marketing_viz <- renderSkillVisualization("Marketing", skillImpact$marketing)
        
        # Get regional strength
        market_impact <- calculateMarketImpact(input$secondaryMajor, input$gradSchool, input$university)
        regional_strength <- paste0("<div><strong>Regional Strength:</strong> ", market_impact$regionalStrength, "</div>")
        
        html_content <- paste0(
          '<div class="option-description">', description, '</div>',
          '<div class="option-skills">', investing_viz, risk_viz, marketing_viz, '</div>',
          regional_strength
        )
        
        shinyjs::html("universityDescription", html_content)
        shinyjs::show("universityDescription")
      } else {
        shinyjs::hide("universityDescription")
      }
    })
    
    # Preview impact of choices
    observeEvent(input$previewImpactBtn, {
      # Calculate impacts
      skills <- calculateSkillImpact(input$secondaryMajor, input$gradSchool, input$university)
      financial <- calculateFinancialImpact(input$secondaryMajor, input$gradSchool, input$university)
      market <- calculateMarketImpact(input$secondaryMajor, input$gradSchool, input$university)
      
      # Store in reactive values
      profileImpact$skills <- skills
      profileImpact$financial <- financial
      profileImpact$market <- market
      
      # Show impact section
      shinyjs::show("impactSection")
      
      # Update impact details
      html_skills <- paste0(
        "<div class='skill-bar'><span>Investing: </span><div class='progress'>",
        "<div class='progress-bar bg-info' role='progressbar' style='width: ", skills$investing * 10, "%;' aria-valuenow='", skills$investing, "' aria-valuemin='0' aria-valuemax='10'>", skills$investing, "/10</div>",
        "</div></div>",
        "<div class='skill-bar'><span>Risk Management: </span><div class='progress'>",
        "<div class='progress-bar bg-info' role='progressbar' style='width: ", skills$riskManagement * 10, "%;' aria-valuenow='", skills$riskManagement, "' aria-valuemin='0' aria-valuemax='10'>", skills$riskManagement, "/10</div>",
        "</div></div>",
        "<div class='skill-bar'><span>Marketing: </span><div class='progress'>",
        "<div class='progress-bar bg-info' role='progressbar' style='width: ", skills$marketing * 10, "%;' aria-valuenow='", skills$marketing, "' aria-valuemin='0' aria-valuemax='10'>", skills$marketing, "/10</div>",
        "</div></div>"
      )
      
      html_financial <- paste0(
        "<p><span class='executive-label'>Starting Capital: </span>$", format(financial$startingCapital, big.mark = ","), "</p>",
        "<p><span class='executive-label'>Annual Salary: </span>$", format(financial$annualSalary, big.mark = ","), "</p>"
      )
      
      html_market <- paste0(
        "<p><span class='executive-label'>From Major: </span>", market$majorAdvantage, "</p>",
        "<p><span class='executive-label'>From Grad School: </span>", market$gradSchoolAdvantage, "</p>",
        "<p><span class='executive-label'>From University: </span>", market$universityAdvantage, "</p>",
        "<p><span class='executive-label'>Regional Strength: </span>", market$regionalStrength, "</p>"
      )
      
      # Update UI
      shinyjs::html("skillsImpact", html_skills)
      shinyjs::html("financialImpact", html_financial)
      shinyjs::html("marketImpact", html_market)
    })
    
    # Save profile
    observeEvent(input$saveProfileBtn, {
      # Validate username
      if (is.null(input$username) || input$username == "") {
        showNotification("Please enter a username.", type = "error")
        return()
      }
      
      # Update user profile
      userProfile$username <- input$username
      userProfile$major <- input$secondaryMajor
      userProfile$gradSchool <- input$gradSchool
      userProfile$university <- input$university
      
      # Calculate skills and impacts for the profile
      skills <- calculateSkillImpact(input$secondaryMajor, input$gradSchool, input$university)
      financial <- calculateFinancialImpact(input$secondaryMajor, input$gradSchool, input$university)
      market <- calculateMarketImpact(input$secondaryMajor, input$gradSchool, input$university)
      
      # Add calculated values to user profile
      userProfile$skills <- skills
      userProfile$financial <- financial
      userProfile$market <- market
      
      # Create full profile data for saving
      profile_data <- list(
        username = userProfile$username,
        major = userProfile$major,
        gradSchool = userProfile$gradSchool,
        university = userProfile$university,
        skills = skills,
        financial = financial,
        market = market,
        timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S")
      )
      
      # Save profile to file using the backend function
      success <- tryCatch({
        source("backend/data_ops.R")  # Ensure the function is available
        save_player_profile(userProfile$username, profile_data)
      }, error = function(e) {
        message("Error saving profile: ", e$message)
        FALSE
      })
      
      if (success) {
        showNotification("Profile saved successfully!", type = "message")
        userProfile$initialized <- TRUE
        userProfile$player_id <- profile_data$player_id
        
        # Initialize skills for new user
        userProfile$skills <- load_player_skills(userProfile$player_id)
        
        # Return TRUE to indicate success
        return(TRUE)
      } else {
        showNotification("Error saving profile. Please try again.", type = "error")
        
        # Return FALSE to indicate failure
        return(FALSE)
      }
    })
    
    # If profile exists, pre-fill the inputs
    observe({
      if (!is.null(userProfile$username) && userProfile$username != "") {
        updateTextInput(session, "username", value = userProfile$username)
      }
      
      if (!is.null(userProfile$major)) {
        updateSelectInput(session, "secondaryMajor", selected = userProfile$major)
      }
      
      if (!is.null(userProfile$gradSchool)) {
        updateSelectInput(session, "gradSchool", selected = userProfile$gradSchool)
      }
      
      if (!is.null(userProfile$university)) {
        updateSelectInput(session, "university", selected = userProfile$university)
      }
    })
    
    # Return reactive expression with current profile status
    return(reactive({
      list(
        username = input$username,
        major = input$secondaryMajor,
        gradSchool = input$gradSchool,
        university = input$university
      )
    }))
  })
} 