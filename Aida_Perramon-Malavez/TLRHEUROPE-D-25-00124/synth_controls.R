# Install and load packages

if (!require("readxl")) install.packages("readxl")
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("data.table")) install.packages("data.table")
if (!require("ggplot2")) install.packages("ggplot2")
if (!require("Synth")) install.packages("Synth")

suppressWarnings({
  library(readxl)
  library(tidyverse)
  library(data.table)
  library(ggplot2)
  library(Synth)
})

# Load the dataset
data <- read_excel("attendancesED.xlsx")
# data <- read_excel("admissionsED.xlsx")

head(data) # Visualize

# Population denominators for each place (approx. year_0/2 because we deal with 
# <6m data)
pop_denominators <- c(
  "Edinburgh" = 3994,
  "Glasgow" = 5392.5,
  "Leicester Royal" = 2192.5,
  "Bristol Hospital" = 2468,
  "Rome" = 12760.5,
  "Catalonia" = 27501.5
)


# Age group of interest, rename columns and build incidence variables
df_under6m <- data %>%
  filter(age_group == "<6m") %>%
  group_by(Place, Season) %>%
  summarise(
    bronchiolitis = sum(bronquis),
    all_diagnoses = sum(all_diag),
    RVI = sum(`Respiratory Diasgnoses (not including Bronchiolitis)`),
    .groups = "drop"
  ) %>%
  mutate(
    treated = ifelse(Place == "Catalonia" & Season == "2023-2024", 1, 0),
    inc_bronchiolitis = 1e5* bronchiolitis / pop_denominators[Place],
    inc_all_diag = 1e5* all_diagnoses / pop_denominators[Place],
    inc_RVI = 1e5* RVI / pop_denominators[Place]
  )

# We need time and Place as numeric for synth, and data to be dataframe
df_under6m <- df_under6m %>%
  mutate(
    PlaceID = as.numeric(as.factor(Place)),
    SeasonID = as.numeric(substr(Season, 1, 4))
    )

df_under6m <- as.data.frame(df_under6m) 

# We reshape the data for Synthetic control method with the dataprep function
dataprep_out <- dataprep(
  foo = df_under6m,
  predictors = c("bronchiolitis", "all_diagnoses", "RVI"),          
  predictors.op = "sum", # this could be "mean", "median", "sd", "sum"...          
  dependent = "bronchiolitis",               
  unit.variable = "PlaceID",          
  time.variable = "SeasonID",
  treatment.identifier = unique(df_under6m$PlaceID[df_under6m$Place == "Catalonia"]),
  controls.identifier = unique(df_under6m$PlaceID[df_under6m$Place != "Catalonia"]),
  time.predictors.prior = c(2018, 2019, 2020, 2021, 2022),
  time.optimize.ssr = c(2018, 2019, 2020, 2021, 2022),
  unit.names.variable = "Place",
  time.plot = c(2018, 2019, 2020, 2021, 2022, 2023)
)

# Synthetic control model fitting
synth_out <- synth(
  data.prep.obj = dataprep_out, 
  optimxmethod = 'All',
  #genoud = TRUE high computational cost for no differences in output
  )

# Weights for control units
synth_tables <- synth.tab(dataprep.res = dataprep_out, synth.res = synth_out)
print(synth_tables$tab.w)   # Weights assigned to control regions

# Observed values for the treated unit (Catalonia)
observed_data <- dataprep_out$Y1

# Synthetic control values for the treated unit
synthetic_data <- dataprep_out$Y0 %*% synth_out$solution.w

# Time periods
time_periods <- dataprep_out$tag$time.plot

# Data table for simplicity of use
scm_data <- data.table(
  Season = time_periods,
  Observed = as.vector(observed_data),
  Synthetic = as.vector(synthetic_data)
)
head(scm_data)

diff <- max(scm_data$Observed)/max(scm_data$Synthetic)
scm_data[,Synthetic_scaled:= Synthetic*diff]

# Plot the data
ggplot(scm_data, aes(x = Season)) +
  geom_line(aes(y = Observed, color = "Observed"), size = 1) +
  geom_line(aes(y = Synthetic, color = "Synthetic"), size = 1, linetype = "dashed") +  
  geom_line(aes(y = Synthetic_scaled, color = "Synthetic (Scaled)"), size = 1, linetype = "dashed") +
  labs(y = "Bronchiolitis attendances at ED (<6m)", 
       x = "Season", 
       title = "Estimated bronchiolitis diagnoses in Catalonia using synthetic controls (<6m)") +
  scale_color_manual(values = c("Observed" = "blue","Synthetic" = "green", "Synthetic (Scaled)" = "red")) + 
  theme_minimal() +
  theme(legend.title = element_blank(), 
        legend.position = "top")

print(paste("Difference between synthetic and observed in Catalonia 2023 (<6m): ", 
            round(scm_data[Season == 2023, Synthetic_scaled] - scm_data[Season == 2023, Observed])))




#### INCIDENCES

dataprep_out2 <- dataprep(
  foo = df_under6m,
  predictors = c("inc_bronchiolitis", "inc_all_diag", "inc_RVI"),          
  predictors.op = "sum", # this could be "mean", "median", "sd", "sum"...          
  dependent = "inc_bronchiolitis",               
  unit.variable = "PlaceID",          
  time.variable = "SeasonID",
  treatment.identifier = unique(df_under6m$PlaceID[df_under6m$Place == "Catalonia"]),
  controls.identifier = unique(df_under6m$PlaceID[df_under6m$Place != "Catalonia"]),
  time.predictors.prior = c(2018, 2019, 2020, 2021, 2022),
  time.optimize.ssr = c(2018, 2019, 2020, 2021, 2022),
  unit.names.variable = "Place",
  time.plot = c(2018, 2019, 2020, 2021, 2022, 2023)
)

synth_out2 <- synth(
  data.prep.obj = dataprep_out2, 
  optimxmethod = 'All',
  #genoud = TRUE high computational cost for no differences in output
)

synth_tables2 <- synth.tab(dataprep.res = dataprep_out2, synth.res = synth_out2)
print(synth_tables2$tab.w)   # Weights assigned to control regions

observed_data2 <- dataprep_out2$Y1
synthetic_data2 <- dataprep_out2$Y0 %*% synth_out2$solution.w
time_periods2 <- dataprep_out2$tag$time.plot

scm_data2 <- data.table(
  Season = time_periods2,
  Observed = as.vector(observed_data2),
  Synthetic = as.vector(synthetic_data2)
)
head(scm_data2)

diff2 <- max(scm_data2$Observed)/max(scm_data2$Synthetic)
scm_data2[,Synthetic_scaled:= Synthetic*diff2]

ggplot(scm_data2, aes(x = Season)) +
  geom_line(aes(y = Observed, color = "Observed"), size = 1) +
  geom_line(aes(y = Synthetic, color = "Synthetic"), size = 1, linetype = "dashed") +  
  geom_line(aes(y = Synthetic_scaled, color = "Synthetic (Scaled)"), size = 1, linetype = "dashed") +
  labs(y = "Bronchiolitis attendances at ED per 100,000 inh. (<6m)", 
       x = "Season", 
       title = "Estimated incidence of bronchiolitis diagnoses in Catalonia using synthetic controls (<6m)") +
  scale_color_manual(values = c("Observed" = "blue","Synthetic" = "green", "Synthetic (Scaled)" = "red")) + 
  theme_minimal() +
  theme(legend.title = element_blank(), 
        legend.position = "top")

print(paste("Difference between synthetic and observed in Catalonia 2023 (<6m): ", 
            round(scm_data2[Season == 2023, Synthetic_scaled] - scm_data2[Season == 2023, Observed])))
