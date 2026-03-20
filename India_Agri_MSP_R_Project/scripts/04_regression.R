# ── Load packages ──────────────────────────────────────────────────────────────
library(tidyverse)
library(here)

# ── Load clean data ────────────────────────────────────────────────────────────
wheat <- read_csv(here("data_clean", "wheat_clean.csv"))

# Fix unit again (same fix as before)
wheat <- wheat %>%
  mutate(production_mt = production_lakh_tonnes / 1000)
# ── Model 1: Simple OLS ────────────────────────────────────────────────────────

# lm() = linear model function in R
# Formula syntax: y ~ x
# Here: production_mt ~ msp_rs_per_quintal
# Reads as: "production explained by MSP"

model1 <- lm(production_mt ~ msp_rs_per_quintal, data = wheat)

# summary() gives full regression output
summary(model1)
# ── Model 2: Log-Log regression ────────────────────────────────────────────────

# log() = natural logarithm
# In a log-log model:
# log(Y) = a + b * log(X)
# The coefficient b = elasticity
# Elasticity = "if X increases by 1%, Y changes by b%"

model2 <- lm(log(production_mt) ~ log(msp_rs_per_quintal), data = wheat)

summary(model2)
# ── Model 3: Multiple regression with time trend ────────────────────────────────

# Here we add year_num as a control variable
# This separates the effect of MSP from the general time trend
# (maybe production grew just because of technology, not MSP)

model3 <- lm(production_mt ~ msp_rs_per_quintal + year_num, data = wheat)

summary(model3)
# ── Model comparison ───────────────────────────────────────────────────────────

# Extract key statistics from each model neatly

model_comparison <- data.frame(
  Model = c("Simple OLS", "Log-Log", "Multiple (with Year)"),
  R_squared = c(
    summary(model1)$r.squared,
    summary(model2)$r.squared,
    summary(model3)$r.squared
  ),
  Adj_R_squared = c(
    summary(model1)$adj.r.squared,
    summary(model2)$adj.r.squared,
    summary(model3)$adj.r.squared
  ),
  MSP_Coef = c(
    coef(model1)["msp_rs_per_quintal"],
    coef(model2)["log(msp_rs_per_quintal)"],
    coef(model3)["msp_rs_per_quintal"]
  ),
  MSP_pvalue = c(
    summary(model1)$coefficients["msp_rs_per_quintal", "Pr(>|t|)"],
    summary(model2)$coefficients["log(msp_rs_per_quintal)", "Pr(>|t|)"],
    summary(model3)$coefficients["msp_rs_per_quintal", "Pr(>|t|)"]
  )
)

print(model_comparison)
# ── Plot: Actual vs Fitted values for Model 3 ──────────────────────────────────

wheat <- wheat %>%
  mutate(
    fitted_model1 = fitted(model1),
    fitted_model3 = fitted(model3)
  )

ggplot(wheat, aes(x = year_num)) +
  geom_point(aes(y = production_mt),
             color = "steelblue", size = 3,
             alpha = 0.8) +
  geom_line(aes(y = fitted_model3, color = "Multiple Regression"),
            linewidth = 1.2) +
  geom_line(aes(y = fitted_model1, color = "Simple OLS"),
            linewidth = 1, linetype = "dashed") +
  scale_color_manual(values = c("Multiple Regression" = "tomato",
                                "Simple OLS"          = "darkgreen")) +
  labs(
    title    = "Actual vs Fitted Wheat Production",
    subtitle = "Multiple regression (MSP + Year) fits better than simple OLS",
    x        = "Year",
    y        = "Production (Million Tonnes)",
    color    = "Model",
    caption  = "Source: CACP / Ministry of Agriculture"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title      = element_text(face = "bold"),
    plot.subtitle   = element_text(color = "grey40"),
    legend.position = "top"
  )

ggsave(here("outputs", "plot7_regression_fit.png"),
       width = 10, height = 6, dpi = 300)
# ── Save model comparison table ────────────────────────────────────────────────

write_csv(model_comparison,
          here("data_clean", "regression_results.csv"))

cat("Regression results saved!\n")

# Print a clean interpretation
cat("\n=== KEY FINDINGS ===\n")
cat("Model 1 R-squared:", round(summary(model1)$r.squared, 4), "\n")
cat("Model 2 Elasticity (log-log coef):",
    round(coef(model2)["log(msp_rs_per_quintal)"], 4), "\n")
cat("Model 3 Adj R-squared:", round(summary(model3)$adj.r.squared, 4), "\n")
cat("Model 3 MSP p-value:",
    round(summary(model3)$coefficients["msp_rs_per_quintal","Pr(>|t|)"], 4), "\n")
