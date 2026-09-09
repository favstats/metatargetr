# Retrieve Metadata for Targeting Data

This function retrieves metadata for targeting data releases for a
specific country and timeframe from a GitHub repository.

## Usage

``` r
get_targeting_metadata(
  country_code,
  timeframe,
  base_url = "https://github.com/favstats/meta_ad_targeting/releases/expanded_assets/"
)
```

## Arguments

- country_code:

  Character. The ISO country code (e.g., "DE", "US").

- timeframe:

  Character. The timeframe to filter (e.g., "7", "30", or "90").

- base_url:

  Character. The base URL for the GitHub repository. Defaults to
  `"https://github.com/favstats/meta_ad_targeting/releases/"`.

## Value

A data frame containing metadata about available targeting data,
including file names, sizes, timestamps, and tags.

## Examples

``` r
# Retrieve metadata for Germany for the last 30 days
metadata <- get_targeting_metadata("DE", "30")
print(metadata)
#> # A tibble: 852 × 3
#>    cntry ds         tframe      
#>    <chr> <chr>      <chr>       
#>  1 DE    2026-08-30 last_30_days
#>  2 DE    2026-08-29 last_30_days
#>  3 DE    2026-08-28 last_30_days
#>  4 DE    2026-08-27 last_30_days
#>  5 DE    2026-08-26 last_30_days
#>  6 DE    2026-08-25 last_30_days
#>  7 DE    2026-08-24 last_30_days
#>  8 DE    2026-08-23 last_30_days
#>  9 DE    2026-08-22 last_30_days
#> 10 DE    2026-08-21 last_30_days
#> # ℹ 842 more rows
```
