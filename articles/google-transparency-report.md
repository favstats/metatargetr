# Google Transparency Report Integration

## Accessing Google Transparency Data

metatargetr provides integration with the Google Transparency Report
through the [`ggl_get_spending()`](../reference/ggl_get_spending.md)
function:

``` r
library(metatargetr)
library(ggplot2)

# Get aggregated spending data
spending_data <- ggl_get_spending(
  advertiser_id = "AR18091944865565769729",
  start_date = "2023-10-24",
  end_date = "2023-11-22",
  cntry = "NL"
)
```

## Time-Based Analysis

For temporal analysis, use the `get_times` parameter:

``` r
# Get time-series data
timeseries_data <- ggl_get_spending(
  advertiser_id = "AR18091944865565769729",
  start_date = "2023-10-24",
  end_date = "2023-11-22",
  cntry = "NL",
  get_times = TRUE
)

# Create visualization
ggplot(timeseries_data, aes(x = date, y = spend)) +
  geom_col() +
  theme_minimal() +
  labs(
    title = "Ad Spending Over Time",
    x = "Date",
    y = "Spend Amount"
  )
```

## Understanding the Metrics

The Google Transparency Report provides:

- Total spending amounts

- Ad type distribution

- Temporal patterns

- Regional variations
