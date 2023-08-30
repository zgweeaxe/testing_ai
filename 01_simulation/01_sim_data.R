# Certainly, let's dive into Step 1: Data Generation. In this step, we'll simulate two essential datasets for "Simulated Cost-Effectiveness Modeling with AI." These datasets will represent patient populations and disease progression. We'll also generate a dataset of treatment parameters. Below are detailed technical specifications and R code to simulate these datasets:

# Dataset 1: Patient Population Data

#Summary: This dataset represents a synthetic patient population, including information about patients' demographics, baseline health, and initial treatment.

#Variable Names:

 #   Patient_ID - Unique identifier for each patient.
 #   Age - Patient's age at the start of the study (numeric).
 #   Gender - Patient's gender (categorical: Male, Female).
 #   Baseline_Severity - Baseline disease severity score (numeric).
 #   Comorbidities - Number of comorbid conditions (numeric).
 #   Initial_Treatment - Initial treatment assigned to the patient (categorical: Treatment A, Treatment B, ...).
#


# Define the number of patients in the population
num_patients <- 1000

# Set random seed for reproducibility
set.seed(123)

# Generate synthetic patient data
patient_data <- data.frame(
  Patient_ID = 1:num_patients,
  Age = sample(18:80, num_patients, replace = TRUE),
  Gender = sample(c("Male", "Female"), num_patients, replace = TRUE),
  Baseline_Severity = rnorm(num_patients, mean = 3, sd = 1),
  Comorbidities = sample(0:4, num_patients, replace = TRUE),
  Initial_Treatment = sample(c("Treatment A", "Treatment B", "Treatment C"), num_patients, replace = TRUE)
)

# Save patient population data to a CSV file
write.csv(patient_data, "patient_population.csv", row.names = FALSE)



#Dataset 2: Disease Progression Data

#Summary: This dataset models the progression of the disease over time for each patient, including variables such as time points, health state, and treatment response.

#Variable Names:

 #   Patient_ID - Unique identifier for each patient.
 #   Time_Point - Time points at which data is recorded (numeric, e.g., 0, 1, 2, ...).
 #   Health_State - Patient's health state at each time point (categorical: Stable, Improved, Worsened, ...).
 #   Treatment_Response - Response to treatment at each time point (categorical: Responder, Non-responder, ...).


# Create an empty data frame for disease progression data
disease_data <- data.frame()

# Loop through each patient and simulate disease progression
for (patient_id in 1:num_patients) {
  # Set initial health state
  health_state <- "Stable"
  
  # Simulate disease progression over time
  for (time_point in 0:24) {  # Simulate data for 24 time points
    # Simulate health state transition
    if (runif(1) < 0.1) {
      # 10% chance of health state worsening
      health_state <- "Worsened"
    } else if (runif(1) < 0.2) {
      # 20% chance of health state improvement
      health_state <- "Improved"
    } else {
      # 70% chance of health state remaining stable
      health_state <- "Stable"
    }
    
    # Simulate treatment response
    if (runif(1) < 0.3) {
      # 30% chance of responding to treatment
      treatment_response <- "Responder"
    } else {
      # 70% chance of not responding to treatment
      treatment_response <- "Non-responder"
    }
    
    # Add data for the current time point
    disease_data <- rbind(disease_data, c(patient_id, time_point, health_state, treatment_response))
  }
}

# Assign column names
colnames(disease_data) <- c("Patient_ID", "Time_Point", "Health_State", "Treatment_Response")

# Save disease progression data to a CSV file
write.csv(disease_data, "disease_progression.csv", row.names = FALSE)
