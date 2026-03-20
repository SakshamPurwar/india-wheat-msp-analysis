# ── Load packages ──────────────────────────────────────────────────────────────
library(tidyverse)
library(here)

# ── Load data ──────────────────────────────────────────────────────────────────
wheat <- read_csv(here("data_clean", "wheat_clean.csv"))
wheat <- wheat %>%
  mutate(production_mt = production_lakh_tonnes / 1000)

forecast_df <- read_csv(here("data_clean", "wheat_forecast.csv"))

# ── Refit models ───────────────────────────────────────────────────────────────
model1 <- lm(production_mt ~ msp_rs_per_quintal, data = wheat)
model2 <- lm(log(production_mt) ~ log(msp_rs_per_quintal), data = wheat)
model3 <- lm(production_mt ~ msp_rs_per_quintal + year_num, data = wheat)

# ── Print clean findings report ────────────────────────────────────────────────
cat("╔══════════════════════════════════════════════════════╗\n")
cat("║  MSP & WHEAT PRODUCTION IN INDIA: KEY FINDINGS      ║\n")
cat("║  Analysis Period: 2000-01 to 2024-25 (25 years)     ║\n")
cat("╚══════════════════════════════════════════════════════╝\n\n")

cat("── DATA SUMMARY ───────────────────────────────────────\n")
cat("Production range:",
    round(min(wheat$production_mt), 1), "MT to",
    round(max(wheat$production_mt), 1), "MT\n")
cat("MSP range: ₹",
    min(wheat$msp_rs_per_quintal), "to ₹",
    max(wheat$msp_rs_per_quintal), "per quintal\n")
cat("MSP increase over period:",
    round((max(wheat$msp_rs_per_quintal) -
             min(wheat$msp_rs_per_quintal)) /
            min(wheat$msp_rs_per_quintal) * 100, 1), "%\n")
cat("Production increase over period:",
    round((max(wheat$production_mt) -
             min(wheat$production_mt)) /
            min(wheat$production_mt) * 100, 1), "%\n\n")

cat("── STATIONARITY ───────────────────────────────────────\n")
cat("ADF Test - Production: p = 0.1513 → Non-stationary\n")
cat("ADF Test - MSP:        p = 0.1181 → Non-stationary\n")
cat("Implication: First-order differencing required → ARIMA(d=1)\n\n")

cat("── ARIMA FORECAST ─────────────────────────────────────\n")
cat("Best model: ARIMA(1,1,0)\n")
cat("Interpretation: Production follows AR(1) process with differencing\n\n")
print(forecast_df)

cat("\n── REGRESSION RESULTS ─────────────────────────────────\n")
cat("Model 1 (Simple OLS):\n")
cat("  MSP coefficient:", round(coef(model1)[2], 5), "\n")
cat("  R-squared:", round(summary(model1)$r.squared, 4), "\n")
cat("  Interpretation: ₹1 increase in MSP → +0.026 MT production\n\n")

cat("Model 2 (Log-Log Elasticity) — PREFERRED MODEL:\n")
cat("  Elasticity:", round(coef(model2)[2], 4), "\n")
cat("  R-squared:", round(summary(model2)$r.squared, 4), "\n")
cat("  Interpretation: 1% rise in MSP → +0.35% rise in production\n")
cat("  Supply response is INELASTIC (elasticity < 1)\n\n")

cat("Model 3 (Multiple + Year):\n")
cat("  Adj R-squared:", round(summary(model3)$adj.r.squared, 4), "\n")
cat("  MSP p-value:", round(
  summary(model3)$coefficients["msp_rs_per_quintal","Pr(>|t|)"], 4), "\n")
cat("  Note: MSP loses significance due to multicollinearity with Year\n\n")

cat("── POLICY IMPLICATIONS ────────────────────────────────\n")
cat("1. MSP is a significant driver of wheat production (Model 1 & 2)\n")
cat("2. Supply response is inelastic: MSP alone cannot double production\n")
cat("3. Complementary investments (irrigation, seeds) needed\n")
cat("4. ARIMA forecast: Production to reach ~122 MT by 2029-30\n")
cat("5. India's food security buffer (110 MT) achievable per forecast\n\n")

cat("── FILES SAVED ────────────────────────────────────────\n")
cat("data_clean/wheat_clean.csv\n")
cat("data_clean/wheat_forecast.csv\n")
cat("data_clean/regression_results.csv\n")
cat("outputs/plot1_production_trend.png\n")
cat("outputs/plot2_msp_trend.png\n")
cat("outputs/plot3_growth_comparison.png\n")
cat("outputs/plot4_msp_vs_production.png\n")
cat("outputs/plot5_logmsp_vs_logprod.png\n")
cat("outputs/plot6_arima_forecast.png\n")
cat("outputs/plot7_regression_fit.png\n")
