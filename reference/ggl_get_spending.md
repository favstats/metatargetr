# Retrieve Google Ad Spending Data

This function queries the Google Ad Library to retrieve information
about advertising spending for a specified advertiser. It supports a
range of countries and can return either aggregated data or time-based
spending data.

## Usage

``` r
ggl_get_spending(
  advertiser_id,
  start_date = 20231029,
  end_date = 20231128,
  cntry = "NL",
  get_times = F
)
```

## Arguments

- advertiser_id:

  A string representing the unique identifier of the advertiser. For
  example "AR14716708051084115969".

- start_date:

  An integer representing the start date for data retrieval in YYYYMMDD
  format. For example 20231029.

- end_date:

  An integer representing the end date for data retrieval in YYYYMMDD
  format. For example 20231128.

- cntry:

  A string representing the country code for which the data is to be
  retrieved. For example "NL" (Netherlands).

- get_times:

  A boolean indicating whether to return time-based spending data. If
  FALSE, returns aggregated data. Default is FALSE.

## Value

A tibble containing advertising spending data. If `get_times` is TRUE,
the function returns a tibble with date-wise spending data. Otherwise,
it returns a tibble with aggregated spending data, including details
like currency, number of ads, ad type breakdown, advertiser details, and
other metrics.

## Examples

``` r
# Retrieve aggregated spending data for a specific advertiser in the Netherlands
spending_data <- ggl_get_spending(advertiser_id = "AR14716708051084115969",
                                  start_date = 20231029, end_date = 20231128,
                                  cntry = "NL")

# Retrieve time-based spending data for the same advertiser and country
time_based_data <- ggl_get_spending(advertiser_id = "AR14716708051084115969",
                                    start_date = 20231029, end_date = 20231128,
                                    cntry = "NL", get_times = TRUE)
```
