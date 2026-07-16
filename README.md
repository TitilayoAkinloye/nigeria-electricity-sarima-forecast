# Time Series Analysis of Electricity Distribution in Nigeria

## Overview
This project applies time series forecasting to electricity distribution 
data in Nigeria, using the Box-Jenkins methodology to build a Seasonal 
ARIMA model capable of predicting future distribution patterns. The model 
was developed as a final year dissertation in Statistics at the Federal 
University of Agriculture, Abeokuta (FUNAAB).

Electricity distribution in Nigeria is notoriously volatile — supply 
shortages, seasonal demand shifts, and infrastructure constraints all 
make it difficult to plan around. This project explores whether a 
statistical model can bring some predictability to that volatility.

## Methodology
The analysis followed the **Box-Jenkins methodology**, a structured 
approach to time series modeling with three main stages:

1. **Identification** — analyzing 120 monthly observations to determine 
   the appropriate model structure, including tests for stationarity 
   and seasonality
2. **Estimation** — fitting a **SARIMA(2,1,1)(2,0,0)[12]** model 
   (Seasonal Autoregressive Integrated Moving Average) to the data
3. **Diagnostic checking** — validating the model through residual 
   analysis to confirm it captures the underlying patterns without 
   leaving unexplained structure behind

The model was then used to generate a **60-month forecast**, projecting 
electricity distribution trends five years into the future.

**Tools used:** R (time series analysis, model fitting, forecasting)

## Key Findings
- Nigeria's electricity distribution showed a statistically significant 
  upward trend from 2015–2024, alongside a strong, stable seasonal 
  pattern — supply consistently peaks in December/January and dips in 
  February/May.
- The best-fit model, SARIMA(2,1,1)(2,0,0)[12], outperformed a naive 
  seasonal forecast by 52% (MASE = 0.48) with a MAPE of 4.87% — placing 
  it in the "good accuracy" range for time series forecasting.
- The 5-year forecast (2025–2029) projects distribution stabilizing at 
  ~1,956–1,968 GWh/month rather than continuing to climb, suggesting 
  current infrastructure has plateaued.
- The findings point to distribution infrastructure — not generation 
  capacity — as Nigeria's binding constraint on electricity access, 
  since the forecast plateau sits well below installed generation 
  capacity (13,597 MW).

## Skills Demonstrated
- Time series analysis and forecasting
- Statistical modeling (SARIMA/Box-Jenkins methodology)
- Data cleaning and preparation
- R programming
- Technical writing and research documentation

## Author
**Akinloye Titilayo Faith**
BSc Statistics, Federal University of Agriculture, Abeokuta (FUNAAB)
Supervised by Prof. O.M. Olayiwola

www.linkedin.com/in/titilayoakinloye
