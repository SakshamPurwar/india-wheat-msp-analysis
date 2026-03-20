# Load packages
library(tidyverse)
library(readxl)
library(lubridate)
library(forecast)
library(tseries)
library(here)
# ── 1. Load the two raw datasets ──────────────────────────────────────────────

wheat_prod <- read_csv(here("data_raw", "wheat_production.csv"))
wheat_msp  <- read_csv(here("data_raw", "wheat_msp.csv"))

# ── 2. Quick look at both ────────────────────────────────────────────────────

glimpse(wheat_prod)
glimpse(wheat_msp)
# ── 3. Fix the year column ────────────────────────────────────────────────────

# Extract the starting year from "2000-01" → 2000
# substr() extracts characters from a string
# substr(x, start_position, end_position)

wheat_prod <- wheat_prod %>%
  mutate(year_num = as.integer(substr(year, 1, 4)))

wheat_msp <- wheat_msp %>%
  mutate(year_num = as.integer(substr(year, 1, 4)))
# Check the new column
select(wheat_prod, year, year_num)
# ── 4. Merge production and MSP data ─────────────────────────────────────────

# left_join keeps all rows from the left table (wheat_prod)
# and brings in matching columns from the right table (wheat_msp)

wheat <- left_join(wheat_prod, wheat_msp, by = "year_num")

# Check the merged table
glimpse(wheat)
# ── 5. Clean the merged table ─────────────────────────────────────────────────

wheat <- wheat %>%
  # Drop the duplicate year.y column, rename year.x back to year
  select(-year.y) %>%
  rename(year = year.x) %>%
  # Reorder columns so year_num comes first
  select(year_num, year, area_lakh_ha, production_lakh_tonnes,
         yield_kg_per_ha, msp_rs_per_quintal)

# Final look
print(wheat)
# ── 6. Add calculated columns ─────────────────────────────────────────────────

wheat <- wheat %>%
  mutate(
    # Convert production from lakh tonnes to million tonnes (easier to read)
    # 1 lakh = 100,000 = 0.1 million, so divide by 10
    production_mt = production_lakh_tonnes / 1000,
    
    # Year-on-year % change in production
    # lag() gives the previous row's value
    # so prod_growth = ((this year - last year) / last year) * 100
    prod_growth_pct = ((production_mt - lag(production_mt)) / lag(production_mt)) * 100,
    
    # Year-on-year % change in MSP
    msp_growth_pct = ((msp_rs_per_quintal - lag(msp_rs_per_quintal)) / lag(msp_rs_per_quintal)) * 100,
    
    # Log of production (used in econometrics to reduce skewness)
    log_production = log(production_mt),
    
    # Log of MSP (same reason)
    log_msp = log(msp_rs_per_quintal)
  )

glimpse(wheat)
# ── 7. Save clean data ────────────────────────────────────────────────────────

write_csv(wheat, here("data_clean", "wheat_clean.csv"))

# Confirm it saved
cat("Clean data saved! Rows:", nrow(wheat), "Columns:", ncol(wheat), "\n")
