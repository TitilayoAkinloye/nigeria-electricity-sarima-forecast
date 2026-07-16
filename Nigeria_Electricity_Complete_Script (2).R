# =============================================================================
# Time Series Analysis of Electricity Distribution in Nigeria
# SARIMA(2,1,1)(2,0,0)[12] Forecasting Model
# Author: Akinloye Titilayo Faith
# =============================================================================

# =============================================================================
# SECTION 0: INSTALL AND LOAD LIBRARIES
# =============================================================================
# Run this ONCE to install all packages
install.packages(c(
  "forecast",    # ARIMA/SARIMA modelling, auto.arima, forecast()
  "tseries",     # adf.test(), kpss.test(), jarque.bera.test()
  "aTSA",        # pp.test() Phillips-Perron unit root test
  "ggplot2",     # Publication-quality plots
  "gridExtra",   # Arrange multiple ggplot panels
  "moments",     # skewness(), kurtosis()
  "psych",       # describe() - full descriptive statistics
  "lmtest",      # coeftest() - parameter significance testing
  "urca",        # ur.df() - alternative unit root tests
  "FinTS",       # ArchTest() - ARCH effects test
  "nortest",     # Normality tests
  "readr",       # read_csv() - fast CSV reading
  "dplyr",       # Data manipulation
  "lubridate"    # Date handling
))

# Load libraries
library(forecast)
library(tseries)
library(aTSA)
library(ggplot2)
library(gridExtra)
library(moments)
library(psych)
library(lmtest)
library(FinTS)
library(nortest)
library(readr)
library(dplyr)

# =============================================================================
# SECTION 1: DATA IMPORT AND CLEANING
# =============================================================================
setwd("C:/Users/titil/OneDrive/Documents")
list.files(pattern = "electricity data")

raw_data <- read.csv("electricity data.csv")
head(raw_data)

colnames(raw_data) <- c("Year_Month", "Total_Customers", "Metered_Customers",
                         "Estimated_Customers", "Revenue_MillionNaira", "Electricity_GWh")

# Remove comma separators and convert to numeric
raw_data$Electricity_GWh <- as.numeric(gsub(",", "", raw_data$Electricity_GWh))

# Build initial time series object (Jan 2015 - Dec 2024, monthly frequency)
elec_ts <- ts(raw_data$Electricity_GWh, start = c(2015, 1), frequency = 12)
print(elec_ts)
length(elec_ts)

# Check for outliers / data entry errors
which(elec_ts > 10000)
head(raw_data$Electricity_GWh, 20)
max(raw_data$Electricity_GWh, na.rm = TRUE)
which(raw_data$Electricity_GWh > 5000)
raw_data[100, ]

# Correct known data entry error: April 2023 value was recorded as
# 20,131 GWh (a decimal/scale error) - corrected to 2,013.1 GWh
raw_data$Electricity_GWh[100] <- 2013.1

# Rebuild the time series with the corrected value
elec_ts <- ts(raw_data$Electricity_GWh, start = c(2015, 1), frequency = 12)
max(elec_ts)

# =============================================================================
# SECTION 2: DESCRIPTIVE STATISTICS
# =============================================================================
desc_stats <- data.frame(
  N = length(elec_ts),
  Mean = round(mean(elec_ts, na.rm = TRUE), 4),
  Std_Dev = round(sd(elec_ts, na.rm = TRUE), 4),
  Minimum = round(min(elec_ts, na.rm = TRUE), 4),
  Maximum = round(max(elec_ts, na.rm = TRUE), 4),
  Skewness = round(skewness(elec_ts, na.rm = TRUE), 4),
  Ex_Kurtosis = round(kurtosis(elec_ts, na.rm = TRUE) - 3, 4)
)
print(desc_stats)

# =============================================================================
# SECTION 3: PRELIMINARY VISUALISATION
# =============================================================================
plot(elec_ts,
     main = "Monthly Electricity Distribution in Nigeria (Jan 2015 - Dec 2024)",
     ylab = "Electricity Supplied (GWh)",
     xlab = "Year",
     col = "steelblue",
     lwd = 2)
grid()

# =============================================================================
# SECTION 4: STATIONARITY TESTING
# =============================================================================
adf.test(elec_ts, alternative = "stationary")   # Augmented Dickey-Fuller
kpss.test(elec_ts, null = "Level")              # KPSS
pp.test(elec_ts, alternative = "stationary")    # Phillips-Perron

# Determine required differencing
ndiffs(elec_ts)    # regular differencing
nsdiffs(elec_ts)   # seasonal differencing

# Apply first-order differencing
elec_diff1 <- diff(elec_ts, differences = 1)

# =============================================================================
# SECTION 5: ACF / PACF ANALYSIS (MODEL IDENTIFICATION)
# =============================================================================
par(mfrow = c(2, 2))
acf(elec_ts, lag.max = 36, main = "ACF - Original Series")
pacf(elec_ts, lag.max = 36, main = "PACF - Original Series")
acf(elec_diff1, lag.max = 36, main = "ACF - First Differenced Series")
pacf(elec_diff1, lag.max = 36, main = "PACF - First Differenced Series")
par(mfrow = c(1, 1))

# =============================================================================
# SECTION 6: MODEL ESTIMATION AND SELECTION
# =============================================================================
# Full search across candidate models, selecting on AICc
auto_model <- auto.arima(elec_ts,
                          stepwise = FALSE,
                          approximation = FALSE,
                          seasonal = TRUE,
                          ic = "aicc",
                          trace = TRUE)
summary(auto_model)
# Selected model: SARIMA(2,1,1)(2,0,0)[12]

# =============================================================================
# SECTION 7: DIAGNOSTIC CHECKING
# =============================================================================
res <- residuals(auto_model)

# Ljung-Box test for residual autocorrelation (white noise check)
Box.test(res, lag = 12, type = "Ljung-Box", fitdf = 5)
Box.test(res, lag = 24, type = "Ljung-Box", fitdf = 5)

# Shapiro-Wilk test for normality of residuals
shapiro.test(res)

# Diagnostic plots
par(mfrow = c(2, 2))

std_res <- res / sd(res)
plot(std_res, type = "o", pch = 16, cex = 0.6, col = "steelblue",
     main = "Standardised Residuals", ylab = "Std Residuals", xlab = "Time")
abline(h = c(-3, 0, 3), col = c("red", "black", "red"), lty = c(2, 1, 2))

acf(res, lag.max = 36, main = "ACF of Residuals")

hist(res, freq = FALSE, col = "lightblue", border = "white",
     main = "Histogram of Residuals", xlab = "Residuals")
curve(dnorm(x, mean = mean(res), sd = sd(res)), add = TRUE, col = "red", lwd = 2)

qqnorm(res, main = "Normal Q-Q Plot", col = "steelblue", pch = 16)
qqline(res, col = "red", lwd = 2)

par(mfrow = c(1, 1))

# =============================================================================
# SECTION 8: FORECASTING
# =============================================================================
# 12-month forecast (short horizon check)
fc <- forecast(auto_model, h = 12, level = c(80, 95))
print(fc)
plot(fc,
     main = "12-Month Forecast of Monthly Electricity Distribution in Nigeria",
     ylab = "Electricity Supplied (GWh)",
     xlab = "Year",
     col = "steelblue",
     fcol = "red",
     shadecols = c("lightblue", "lightyellow"))
grid()

# Save workspace image
save.image("C:\\Users\\titil\\OneDrive\\Documents\\titilayo final chapter 4 code")

# 60-month (5-year) forecast - the study's primary forecast horizon
fc60 <- forecast(auto_model, h = 60, level = c(80, 95))
print(fc60)

plot(fc60,
     main = "Figure 4.5: Five-Year Forecast of Monthly Electricity Distribution in Nigeria (2025-2029)",
     ylab = "Electricity Supplied (GWh)",
     xlab = "Year",
     col = "steelblue",
     fcol = "red",
     shadecols = c("lightblue", "lightyellow"),
     lwd = 2)
grid(col = "lightgray", lty = 2)

# =============================================================================
# SECTION 9: ANNUAL FORECAST SUMMARIES (2025-2029)
# =============================================================================
months_60 <- seq(as.Date("2025-01-01"), by = "month", length.out = 60)
years <- 2025:2029

# Annual mean forecast with 95% prediction interval
for (yr in years) {
  idx <- which(format(months_60, "%Y") == as.character(yr))
  cat(sprintf("%d: Mean = %.2f GWh  (Lo95: %.2f - Hi95: %.2f)\n",
              yr,
              mean(as.numeric(fc60$mean)[idx]),
              mean(as.numeric(fc60$lower[, 2])[idx]),
              mean(as.numeric(fc60$upper[, 2])[idx])))
}

# Annual mean forecast with both 80% and 95% prediction intervals (2026-2029)
for (yr in 2026:2029) {
  idx <- which(format(months_60, "%Y") == as.character(yr))
  cat(sprintf("%d: Lo80=%.2f  Hi80=%.2f  Lo95=%.2f  Hi95=%.2f\n",
              yr,
              mean(as.numeric(fc60$lower[, 1])[idx]),
              mean(as.numeric(fc60$upper[, 1])[idx]),
              mean(as.numeric(fc60$lower[, 2])[idx]),
              mean(as.numeric(fc60$upper[, 2])[idx])))
}
