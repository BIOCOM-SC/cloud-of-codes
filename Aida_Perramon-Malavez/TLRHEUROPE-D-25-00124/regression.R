
# Install packages if not already installed
required_packages <- c("readxl", "tidyverse", "broom", "glmnet", "sandwich")

new_packages <- required_packages[!(required_packages %in% 
                                      installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages, quietly = TRUE)

# Suppress warnings while loading libraries
suppressWarnings({
  library(readxl)
  library(tidyverse)
  library(broom)
  library(glmnet)
  library(sandwich)
})

# data <- read_excel("admissionsED.xlsx")
data <- read_excel("attendancesED.xlsx")

# Transform the data of total admissions to fit the Poisson model condition
data <- data %>%
  mutate(
    log_total_admissions = log(all_diag), 
    place_fac = as.factor(Place),
    season_fac = as.factor(Season),
    age_fac = as.factor(age_group)
  )

data <- data %>%
  filter(age_fac %in% c("<6m", "6-11m", "12m-23m"))

# Average of pre-nirse seasons
# average_seasons <- data %>%
#   filter(Season %in% c("2018-2019", "2019-2020", "2021-2022", "2022-2023")) %>%
#   group_by(age_group, Place) %>%
#   summarize(
#     all_diag = mean(all_diag, na.rm = TRUE),
#     bronquis = mean(bronquis, na.rm = TRUE),
#     .groups = "drop"
#   ) %>%
#   mutate(Season = "average")  

# data_combined <- bind_rows(data, average_seasons)

# Decide which years to keep 
# data_combined <- data_combined %>%
#   filter(Season %in% c("average", "2020-2021", "2023-2024"))

# data_combined <- data_combined %>%
#   mutate(
#     log_total_admissions = log(all_diag), 
#     place_fac = as.factor(Place),
#     season_fac = as.factor(Season),
#     age_fac = as.factor(age_group)
#   )

# Making the average the reference value
# data_combined <- data_combined %>%
#   mutate(season_fac = relevel(season_fac, ref = "average"))

# Making 2023-2024 the reference value
data <- data %>%
  mutate(season_fac = relevel(season_fac, ref = "2023-2024"))

# Making  12-23m the reference value 
data <- data %>%
  mutate(age_fac = relevel(age_fac, ref = "12m-23m"))

# Model and results of the interaction age*season
model_results2 <- list()

for (place in unique(data$Place)) {
    model1 <- glm(bronquis ~ age_fac*season_fac + offset(log_total_admissions),
                 family = poisson(link = "log"),
                 data = data[data$Place == place, ])
    model_results2[[place]] <- summary(model1)  
}
model_results2


# Model and results of season per age
model_results3 <- list()

for (place in unique(data$Place)) {
  model_results3[[place]] <- list()  
  for (age in unique(data$age_fac)) {
    model2 <- glm(bronquis ~ season_fac + offset(log_total_admissions),
                 family = poisson(link = "log"),
                 data = data[data$Place == place & data$age_fac == age, ])
    model_results3[[place]][[age]] <- summary(model2)  
  }
}
model_results3

# e^beta (RR) with CI and pval for the final table
final_results <- function(model) {
  coef_est <- coef(model)[ , "Estimate"]
  std_err <- coef(model)[ , "Std. Error"]
  pval <- coef(model)[, "Pr(>|z|)"]

  ci_lower <- coef_est - 1.96 * std_err
  ci_upper <- coef_est + 1.96 * std_err
  
  rr <- exp(coef_est)
  ci_lower_exp <- exp(ci_lower)
  ci_upper_exp <- exp(ci_upper)

  result_df <- data.frame(
    Term = names(coef_est),
    RR = rr,
    "CI Lower 95%" = ci_lower_exp,
    "CI Upper 95%" = ci_upper_exp,
    "P-val" = pval
  )
  
  return(result_df)
}


model_rr_results2 <- list()
for (place in names(model_results2)) {
  model_rr_results2[[place]] <- final_results(model_results2[[place]])
}


model_rr_results3 <- list()
for (place in names(model_results3)) {
  model_rr_results3[[place]] <- list()  
  for (age in names(model_results3[[place]])) {
    model_rr_results3[[place]][[age]] <- final_results(model_results3[[place]][[age]])
  }
}

model_rr_results2
model_rr_results3