# ── Load packages ─────────────────────────────────────────────────────────────
library(tidyverse)
library(here)

# ── Load clean data ───────────────────────────────────────────────────────────
wheat <- read_csv(here("data_clean", "wheat_clean.csv"))
# ── Plot 1: Production trend ──────────────────────────────────────────────────

ggplot(data = wheat,
       aes(x = year_num, y = production_mt)) +
  geom_line(color = "#2166ac", linewidth = 1.2) +
  geom_point(color = "#2166ac", size = 2.5) +
  geom_smooth(method = "lm", se = TRUE,
              color = "tomato", linetype = "dashed", linewidth = 1) +
  labs(
    title    = "India Wheat Production (2000-01 to 2024-25)",
    subtitle = "Steady upward trend with a dip in 2022-23",
    x        = "Year",
    y        = "Production (Million Tonnes)",
    caption  = "Source: USDA / Ministry of Agriculture & Farmers Welfare"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title    = element_text(face = "bold"),
    plot.subtitle = element_text(color = "grey40"),
    plot.caption  = element_text(color = "grey50", size = 9)
  )

# Save the plot
ggsave(here("outputs", "plot1_production_trend.png"),
       width = 10, height = 6, dpi = 300)
# ── Plot 2: MSP trend ─────────────────────────────────────────────────────────

ggplot(data = wheat,
       aes(x = year_num, y = msp_rs_per_quintal)) +
  geom_line(color = "#4dac26", linewidth = 1.2) +
  geom_point(color = "#4dac26", size = 2.5) +
  annotate("rect",
           xmin = 2018, xmax = 2019,
           ymin = -Inf, ymax = Inf,
           alpha = 0.15, fill = "orange") +
  annotate("text",
           x = 2018.5, y = 500,
           label = "50% cost\nrule (2018-19)",
           size = 3.5, color = "darkorange") +
  labs(
    title   = "Minimum Support Price (MSP) for Wheat (2000-01 to 2024-25)",
    subtitle = "Sharp jump in 2008-09; policy shift in 2018-19",
    x       = "Year",
    y       = "MSP (₹ per quintal)",
    caption = "Source: CACP / Department of Food & Public Distribution"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title    = element_text(face = "bold"),
    plot.subtitle = element_text(color = "grey40"),
    plot.caption  = element_text(color = "grey50", size = 9)
  )

ggsave(here("outputs", "plot2_msp_trend.png"),
       width = 10, height = 6, dpi = 300)
# ── Plot 3: Growth rates comparison ──────────────────────────────────────────

# First reshape the data from wide to long format for ggplot
# pivot_longer() stacks two columns into one
wheat_growth <- wheat %>%
  filter(!is.na(prod_growth_pct)) %>%       # remove first row (NA)
  select(year_num, prod_growth_pct, msp_growth_pct) %>%
  pivot_longer(
    cols      = c(prod_growth_pct, msp_growth_pct),
    names_to  = "variable",
    values_to = "growth_pct"
  ) %>%
  mutate(variable = recode(variable,
                           "prod_growth_pct" = "Production Growth (%)",
                           "msp_growth_pct"  = "MSP Growth (%)"))

ggplot(wheat_growth,
       aes(x = year_num, y = growth_pct, fill = variable)) +
  geom_col(position = "dodge") +
  scale_fill_manual(values = c("Production Growth (%)" = "#2166ac",
                               "MSP Growth (%)"        = "#4dac26")) +
  geom_hline(yintercept = 0, color = "black", linewidth = 0.5) +
  labs(
    title    = "Year-on-Year Growth: Wheat Production vs MSP",
    subtitle = "Does MSP growth lead to production growth?",
    x        = "Year",
    y        = "Growth Rate (%)",
    fill     = NULL,
    caption  = "Source: CACP / Ministry of Agriculture"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title    = element_text(face = "bold"),
    plot.subtitle = element_text(color = "grey40"),
    legend.position = "top"
  )

ggsave(here("outputs", "plot3_growth_comparison.png"),
       width = 11, height = 6, dpi = 300)
# ── Plot 4: Scatter MSP vs Production ────────────────────────────────────────

ggplot(wheat,
       aes(x = msp_rs_per_quintal, y = production_mt)) +
  geom_point(aes(color = year_num), size = 3) +
  scale_color_gradient(low = "#d1e5f0", high = "#2166ac",
                       name = "Year") +
  geom_smooth(method = "lm", se = TRUE,
              color = "tomato", linewidth = 1.1) +
  labs(
    title    = "MSP vs Wheat Production in India",
    subtitle = "Each dot is one year (darker = more recent)",
    x        = "MSP (₹ per quintal)",
    y        = "Production (Million Tonnes)",
    caption  = "Source: CACP / Ministry of Agriculture"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title    = element_text(face = "bold"),
    plot.subtitle = element_text(color = "grey40"),
    plot.caption  = element_text(color = "grey50", size = 9)
  )

ggsave(here("outputs", "plot4_msp_vs_production.png"),
       width = 10, height = 6, dpi = 300)
# ── Plot 5: Log-log scatter ───────────────────────────────────────────────────

ggplot(wheat,
       aes(x = log_msp, y = log_production)) +
  geom_point(aes(color = year_num), size = 3) +
  scale_color_gradient(low = "#d1e5f0", high = "#2166ac",
                       name = "Year") +
  geom_smooth(method = "lm", se = TRUE,
              color = "tomato", linewidth = 1.1) +
  labs(
    title    = "Log MSP vs Log Wheat Production (Elasticity View)",
    subtitle = "Slope of this line = elasticity of production w.r.t. MSP",
    x        = "Log(MSP)",
    y        = "Log(Production)",
    caption  = "Source: CACP / Ministry of Agriculture"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title    = element_text(face = "bold"),
    plot.subtitle = element_text(color = "grey40"),
    plot.caption  = element_text(color = "grey50", size = 9)
  )

ggsave(here("outputs", "plot5_logmsp_vs_logprod.png"),
       width = 10, height = 6, dpi = 300)
