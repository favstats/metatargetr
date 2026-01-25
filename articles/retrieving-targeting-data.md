# Retrieving Targeting Data

## Getting Recent Targeting Data

The [`get_targeting()`](../reference/get_targeting.md) function allows
you to retrieve targeting data for specific time windows:

``` r
library(metatargetr)

# Last 7 days
last7 <- get_targeting("121264564551002", timeframe = "LAST_7_DAYS")

# Last 30 days
last30 <- get_targeting("121264564551002", timeframe = "LAST_30_DAYS")

# Last 90 days
last90 <- get_targeting("121264564551002", timeframe = "LAST_90_DAYS")
```

## Understanding the Output

The function returns a data frame containing:

- Basic targeting information (gender, age, location)
- Detailed targeting options (interests, behaviors)
- Custom audience information
- Spending and reach metrics

## Getting Page Information

Use [`get_page_insights()`](../reference/get_page_insights.md) to
retrieve additional page information:

``` r
page_info <- get_page_insights("121264564551002", include_info = "page_info")
```

This returns details such as:

- Page name and verification status

- Follower counts

- Page category

- Creation date
