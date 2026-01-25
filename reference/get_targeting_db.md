# Retrieve Targeting Data from GitHub Repository

This function retrieves targeting data for a specific country and
timeframe from a GitHub repository hosting parquet files. The function
uses the `arrow` package to read the parquet file directly from the
specified URL. Note that the retreival of archived data is only possible
three days after a specified date.

## Usage

``` r
get_targeting_db(the_cntry, tf, ds, remove_nas = T, verbose = F)
```

## Arguments

- the_cntry:

  Character. The ISO country code (e.g., "DE", "US").

- tf:

  Numeric or character. The timeframe in days ("yesterday", "7", "30",
  "90", "lifelong"). Note, some data points for lifelong in the past may
  be missing for some countries.

- ds:

  Character. A timestamp or identifier used to construct the file path
  (e.g., "2024-12-25").

## Value

A data frame containing the targeting data from the parquet file.

## Examples

``` r
# Example usage
latest_data <- get_targeting_db(
  the_cntry = "DE",
  tf = 30,
  ds = "2024-10-25"
)
print(head(latest_data))
#> # A tibble: 6 × 37
#>   internal_id no_data tstamp              page_id  cntry page_name partyfacts_id
#>   <chr>       <lgl>   <dttm>              <chr>    <chr> <chr>     <chr>        
#> 1 NA          NA      2024-10-27 18:12:35 7440553… DE    CDU-Frak… 1375         
#> 2 NA          NA      2024-10-27 18:12:35 7440553… DE    CDU-Frak… 1375         
#> 3 NA          NA      2024-10-27 18:12:35 7440553… DE    CDU-Frak… 1375         
#> 4 NA          NA      2024-10-27 18:12:35 7440553… DE    CDU-Frak… 1375         
#> 5 NA          NA      2024-10-27 18:12:35 7440553… DE    CDU-Frak… 1375         
#> 6 NA          NA      2024-10-27 18:12:35 7440553… DE    CDU-Frak… 1375         
#> # ℹ 30 more variables: sources <chr>, country <chr>, party <chr>,
#> #   left_right <dbl>, tags <glue>, tags_ideology <chr>, disclaimer <chr>,
#> #   amount_spent_eur <chr>, number_of_ads_in_library <chr>, date <chr>,
#> #   path <chr>, tf <chr>, remove_em <lgl>, total_n <int>, amount_spent <dbl>,
#> #   value <chr>, num_ads <int>, total_spend_pct <dbl>, type <chr>,
#> #   location_type <chr>, num_obfuscated <int>, is_exclusion <lgl>, ds <chr>,
#> #   main_currency <chr>, total_num_ads <int>, total_spend_formatted <dbl>, …
```
