# Load required libraries
library(shiny)
library(markovchain)
library(DescTools)

# Define the Markov model structure (number of health states and transitions)
num_states <- 3  # Define the number of health states
states <- c("Healthy", "Sick", "Dead")

# Define transition probabilities (transition matrix)
transition_matrix <- matrix(c(
  0.9, 0.1, 0,    # Transition from Healthy to Healthy, Sick, Dead
  0.2, 0.7, 0.1,  # Transition from Sick to Healthy, Sick, Dead
  0,   0,   1     # Transition from Dead to Dead (absorbing state)
), nrow = num_states, byrow = TRUE)

# Define health state utilities and costs
utilities <- c(1, 0.7, 0)  # Utilities for Healthy, Sick, Dead
costs <- c(0, 1000, 0)     # Costs for Healthy, Sick, Dead

# Define time horizon for modeling
time_horizon <- 10

# Define user input elements
ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      sliderInput("time_horizon", "Time Horizon (years):", min = 1, max = 20, value = 10),
      numericInput("comp_cost", "Comparator Cost:", value = 0),
      numericInput("comp_qalys", "Comparator QALYs:", value = 0),
      actionButton("simulate_button", "Simulate"),
    ),
    mainPanel(
      h3("Cost-Effectiveness Results"),
      dataTableOutput("results_table")
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  observeEvent(input$simulate_button, {
    # Simulate the Markov model over the specified time horizon
    simulation_results <- simulate_markov_model(
      num_states = num_states,
      transition_matrix = transition_matrix,
      utilities = utilities,
      costs = costs,
      time_horizon = input$time_horizon
    )
    
    # Calculate cost-effectiveness metrics (e.g., ICER)
    icer <- calculate_icer(
      total_cost = sum(simulation_results$costs),
      total_qalys = sum(simulation_results$qalys),
      comp_cost = input$comp_cost,
      comp_qalys = input$comp_qalys
    )
    
    # Display simulation results and ICER in a table
    results <- data.frame(
      Year = 1:input$time_horizon,
      Health_State = simulation_results$health_states,
      Cost = simulation_results$costs,
      QALYs = simulation_results$qalys
    )
    
    results <- rbind(
      results,
      c(input$time_horizon, "Total", sum(results$Cost), sum(results$QALYs))
    )
    
    results <- cbind(results, ICER = icer)
    
    output$results_table <- renderDataTable({
      results
    })
  })
}

# Create Shiny app
shinyApp(ui = ui, server = server)

# Function to simulate the Markov model
simulate_markov_model <- function(num_states, transition_matrix, utilities, costs, time_horizon) {
  health_states <- character(time_horizon)
  qalys <- numeric(time_horizon)
  costs <- numeric(time_horizon)
  
  current_state <- "Healthy"
  
  for (year in 1:time_horizon) {
    health_states[year] <- current_state
    qalys[year] <- utilities[which(states == current_state)]
    costs[year] <- costs[which(states == current_state)]
    
    # Simulate transition to the next state
    transition_probabilities <- transition_matrix[which(states == current_state), ]
    next_state <- sample(states, 1, prob = transition_probabilities)
    
    if (next_state == "Dead") {
      break  # Exit the loop if the absorbing state is reached
    }
    
    current_state <- next_state
  }
  
  return(data.frame(health_states, qalys, costs))
}

# Function to calculate Incremental Cost-Effectiveness Ratio (ICER)
calculate_icer <- function(total_cost, total_qalys, comp_cost, comp_qalys) {
  delta_cost <- total_cost - comp_cost
  delta_qalys <- total_qalys - comp_qalys
  
  if (delta_qalys == 0) {
    icer <- NA
  } else {
    icer <- delta_cost / delta_qalys
  }
  
  return(icer)
}
