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
              
              selectInput(ns("secondaryMajor"), "Secondary Major:", 
                         choices = c("Finance", "Actuarial Science", "Business Analytics", "Marketing", "Management"))
            )
          )
        ),
        column(6,
          div(class = "executive-card",
            h3("Education"),
            div(class = "form-group",
              selectInput(ns("gradSchool"), "Graduate School Option:", 
                         choices = c("MBA", "MS in Risk Management", "MS in Finance", "MS in Actuarial Science", "PhD")),
              
              selectInput(ns("university"), "University:", 
                         choices = c("Wisconsin", "Wharton", "Chicago", "Stanford", "Harvard"))
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
      Wisconsin = list(
        investing = 1,
        riskManagement = 2,
        marketing = 1
      ),
      Wharton = list(
        investing = 3,
        riskManagement = 1,
        marketing = 1
      ),
      Chicago = list(
        investing = 2,
        riskManagement = 2,
        marketing = 1
      ),
      Stanford = list(
        investing = 2,
        riskManagement = 1,
        marketing = 2
      ),
      Harvard = list(
        investing = 2,
        riskManagement = 1,
        marketing = 2
      )
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
        "Wisconsin" = 1.05,
        "Wharton" = 1.2,
        "Chicago" = 1.15,
        "Stanford" = 1.15,
        "Harvard" = 1.2,
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
        "Wisconsin" = "Strong actuarial connections",
        "Wharton" = "Elite investment network",
        "Chicago" = "Advanced risk modeling",
        "Stanford" = "Innovation and tech advantage",
        "Harvard" = "Executive leadership network",
        "None"
      )
      
      # Determine regional strength
      regionalStrength <- switch(university,
        "Wisconsin" = "Iowa",
        "Wharton" = "Georgia",
        "Chicago" = "Iowa",
        "Stanford" = "Florida",
        "Harvard" = "Georgia",
        "None"
      )
      
      return(list(
        majorAdvantage = majorAdvantage,
        gradSchoolAdvantage = gradSchoolAdvantage,
        universityAdvantage = universityAdvantage,
        regionalStrength = regionalStrength
      ))
    }
    
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