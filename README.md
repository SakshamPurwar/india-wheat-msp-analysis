# MSP Policy and Agricultural Production in India
### A Time Series & Regression Analysis in R

**Author:** [Saksham Purwar](https://github.com/SakshamPurwar)  
**Period Analysed:** 2000-01 to 2024-25 (25 years)  
**Language:** R  
**Status:** Complete

---

## Project Overview

This project quantifies the relationship between India's Minimum Support
Price (MSP) policy for wheat and actual wheat production using time series
econometrics and regression analysis.

**Core Research Question:**  
*Does a higher MSP lead to higher wheat production in India, and by how much?*

**Key Finding:**  
A 1% increase in MSP is associated with a 0.35% increase in wheat
production — an inelastic supply response — suggesting MSP alone cannot
drive large production gains without complementary investments in
irrigation, seeds, and rural credit.


---

## Data Sources

| Dataset | Source | Coverage |
|---------|--------|----------|
| Wheat Production (Area, Yield) | USDA PSD / Ministry of Agriculture & Farmers Welfare | 2000-01 to 2024-25 |
| Minimum Support Price (MSP) | CACP / Dept. of Food & Public Distribution | 2000-01 to 2024-25 |

---

## Methodology

### 1. Data Preparation
- Merged production and MSP datasets on crop year
- Converted production units to million tonnes
- Created derived variables: YoY growth rates, log transformations

### 2. Exploratory Data Analysis
- Trend plots for production and MSP over 25 years
- Scatter plots (levels and log-log) to visualise MSP-production relationship
- Side-by-side bar chart comparing YoY growth rates of MSP and production

### 3. Time Series Analysis
- **ADF Test:** Both series confirmed non-stationary (p > 0.05)
- **ACF/PACF:** Guided ARIMA specification
- **ARIMA(1,1,0):** Best model selected by auto.arima() via AIC criterion
- **Forecast:** Production projected for 2025-26 to 2029-30

### 4. Regression Analysis

Three models estimated:

| Model | Specification | R² | Key Result |
|-------|--------------|-----|-----------|
| Model 1 | OLS: Production ~ MSP | 0.928 | ₹1 MSP rise → +0.026 MT |
| Model 2 | Log-Log: log(Prod) ~ log(MSP) | 0.927 | Elasticity = 0.35 |
| Model 3 | Multiple: Production ~ MSP + Year | 0.930 | MSP p = 0.095 (multicollinearity) |

**Preferred model:** Log-Log (Model 2) for its economic interpretability
as an elasticity measure.

---

## Key Findings

1. **Strong positive relationship:** MSP explains 92.8% of variation in
   wheat production over 25 years (R² = 0.928)

2. **Inelastic supply response:** MSP elasticity of production = **0.35**
   A 10% increase in MSP leads to only a 3.5% increase in production

3. **Asymmetric growth:** MSP grew 292% (₹580 → ₹2,275) while production
   grew only 72.3% (65.8 → 113.3 MT) — confirming inelastic response

4. **ARIMA(1,1,0) forecast:** Production expected to reach ~114.7 MT
   in 2025-26 and ~122.0 MT by 2029-30, comfortably above India's
   food security buffer threshold

5. **Policy implication:** MSP is a necessary but not sufficient condition
   for production growth. Complementary investments in irrigation,
   high-yielding variety seeds, and rural credit are essential

---

## Visualisations

| Plot | Description |
|------|-------------|
| plot1 | Wheat production trend with linear fit (2000-2024) |
| plot2 | MSP trend with 2018-19 policy annotation |
| plot3 | YoY growth comparison: production vs MSP |
| plot4 | Scatter: MSP vs Production (colour = year) |
| plot5 | Log-Log scatter showing elasticity relationship |
| plot6 | ARIMA forecast with 80% and 95% confidence bands |
| plot7 | Actual vs fitted values: OLS vs Multiple Regression |

---

## R Packages Used

| Package | Purpose |
|---------|---------|
| tidyverse | Data manipulation and ggplot2 visualisation |
| readxl | Excel file import |
| lubridate | Date handling |
| forecast | ARIMA modelling and forecasting |
| tseries | ADF stationarity test |
| here | Project-relative file paths |

---

## Limitations

- Only MSP and time trend used as explanatory variables; rainfall,
  irrigation coverage, and input prices are omitted
- 25 annual observations is a relatively small sample for ARIMA
- MSP and year are highly collinear, limiting multiple regression inference
- Production data from USDA PSD may differ marginally from MoAFW
  final estimates
