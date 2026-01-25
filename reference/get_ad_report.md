# Get Facebook Ad Library Report Data

Automates downloading Facebook Ad Library reports for vectors of
countries, timeframes, and dates. It uses a robust tryCatch block for
each request to ensure cleanup and prevent hanging processes.

## Usage

``` r
get_ad_report(country, timeframe, date)
```

## Arguments

- country:

  A character vector of two-letter ISO country codes.

- timeframe:

  A character vector of time windows (e.g., "last_7_days").

- date:

  A character vector of report dates in "YYYY-MM-DD" format.

## Value

A single tibble containing the combined data for all successful
requests.
