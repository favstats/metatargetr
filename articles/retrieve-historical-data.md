# Retrieve Historical Data

## Accessing Historical Data

While Meta’s API only provides recent targeting data, metatargetr
maintains an archive of historical targeting data. Access this using
[`get_targeting_db()`](../reference/get_targeting_db.md):

``` r
library(metatargetr)

# Set parameters
country_code <- "DE"
timeframe <- 30
date <- "2024-10-25"

# Retrieve historical data
historical_data <- get_targeting_db(country_code, timeframe, date)
```

## Understanding Historical Data

The historical data includes: - Daily targeting snapshots - Spending
information - Page details - Targeting criteria used

## Getting Report Data

For broader historical analysis, use
[`get_report_db()`](../reference/get_report_db.md):

``` r
report_data <- get_report_db(
  country_code = "DE",
  timeframe = 30,
  date = "2024-10-25"
)
```

This provides aggregated advertising reports including:

- Total spending

- Number of ads

- Page information

- Temporal data
