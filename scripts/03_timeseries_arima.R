# ── Load packages ──────────────────────────────────────────────────────────────
library(tidyverse)
library(forecast)
library(tseries)
library(here)

# ── Load clean data ────────────────────────────────────────────────────────────
wheat <- read_csv(here("data_clean", "wheat_clean.csv"))

# ── Fix production unit (lakh tonnes → million tonnes) ────────────────────────
# 1 lakh = 100,000
# 1 million = 1,000,000
# So 1 million tonnes = 10 lakh tonnes
# Therefore divide lakh tonnes by 10 to get million tonnes

wheat <- wheat %>%
  mutate(production_mt = production_lakh_tonnes / 1000)

# Verify the fix
summary(wheat$production_mt)
# ── Create ts objects ──────────────────────────────────────────────────────────

prod_ts <- ts(wheat$production_mt,
              start     = 2000,
              frequency = 1)

msp_ts <- ts(wheat$msp_rs_per_quintal,
             start     = 2000,
             frequency = 1)

print(prod_ts)
print(msp_ts)
# ── Base R time series plot ────────────────────────────────────────────────────

par(mfrow = c(2, 1))

plot(prod_ts,
     main = "Wheat Production (Million Tonnes)",
     ylab = "Million Tonnes",
     xlab = "Year",
     col  = "steelblue",
     lwd  = 2)

plot(msp_ts,
     main = "Wheat MSP (Rs per Quintal)",
     ylab = "Rs/Quintal",
     xlab = "Year",
     col  = "darkgreen",
     lwd  = 2)

par(mfrow = c(1, 1))
# ── ADF Test ───────────────────────────────────────────────────────────────────

cat("=== ADF Test: Wheat Production ===\n")
adf_prod <- adf.test(prod_ts)
print(adf_prod)

cat("\n=== ADF Test: Wheat MSP ===\n")
adf_msp <- adf.test(msp_ts)
print(adf_msp)
# ── ACF and PACF ───────────────────────────────────────────────────────────────

par(mfrow = c(2, 2))

acf(prod_ts,
    main    = "ACF: Wheat Production",
    lag.max = 15)

pacf(prod_ts,
     main    = "PACF: Wheat Production",
     lag.max = 15)

acf(diff(prod_ts),
    main    = "ACF: Differenced Production",
    lag.max = 15)

pacf(diff(prod_ts),
     main    = "PACF: Differenced Production",
     lag.max = 15)

par(mfrow = c(1, 1))
# ── Fit ARIMA ──────────────────────────────────────────────────────────────────

cat("Fitting ARIMA model...\n")

arima_model <- auto.arima(prod_ts,
                          stepwise      = FALSE,
                          approximation = FALSE,
                          trace         = TRUE)

summary(arima_model)
# ── Residual check ─────────────────────────────────────────────────────────────

checkresiduals(arima_model)
# ── Forecast 2025 to 2029 ──────────────────────────────────────────────────────

wheat_forecast <- forecast(arima_model, h = 5)

print(wheat_forecast)

autoplot(wheat_forecast) +
  labs(
    title    = "Wheat Production Forecast: 2025-26 to 2029-30",
    subtitle = paste0("ARIMA(",
                      arimaorder(arima_model)[1], ",",
                      arimaorder(arima_model)[2], ",",
                      arimaorder(arima_model)[3], ") model"),
    x        = "Year",
    y        = "Production (Million Tonnes)",
    caption  = "Shaded bands = 80% and 95% confidence intervals"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title    = element_text(face = "bold"),
    plot.subtitle = element_text(color = "grey40"),
    plot.caption  = element_text(color = "grey50", size = 9)
  )

ggsave(here("outputs", "plot6_arima_forecast.png"),
       width = 10, height = 6, dpi = 300)
# ── Save forecast values ────────────────────────────────────────────────────────

forecast_df <- data.frame(
  year           = 2025:2029,
  point_forecast = as.numeric(wheat_forecast$mean),
  lower_80       = as.numeric(wheat_forecast$lower[, 1]),
  upper_80       = as.numeric(wheat_forecast$upper[, 1]),
  lower_95       = as.numeric(wheat_forecast$lower[, 2]),
  upper_95       = as.numeric(wheat_forecast$upper[, 2])
)

print(forecast_df)

write_csv(forecast_df, here("data_clean", "wheat_forecast.csv"))
cat("Forecast saved!\n")
