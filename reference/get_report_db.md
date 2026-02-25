# Retrieve Report Data from GitHub Repository

This function retrieves a report for a specific country and timeframe
from a GitHub repository hosting RDS files. The file is downloaded to a
temporary location, read into R, and then deleted.

## Usage

``` r
get_report_db(the_cntry, timeframe, ds, verbose = FALSE)
```

## Arguments

- the_cntry:

  Character. The ISO country code (e.g., "DE", "US").

- timeframe:

  Character or Numeric. Timeframe in days (e.g., "30", "90") or
  "yesterday" / "lifelong".

- ds:

  Character. A timestamp or identifier used to construct the file name
  (e.g., "2024-12-25").

- verbose:

  Logical. Whether to print messages about the process. Default is
  `FALSE`.

## Value

A data frame or object read from the RDS file.

## Examples

``` r
# Example usage
report_data <- get_report_db(
  the_cntry = "DE",
  timeframe = 30,
  ds = "2024-12-25",
  verbose = TRUE
)
#> Constructed URL: https://github.com/favstats/meta_ad_reports/releases/download/DE-last_30_days/2024-12-25.rds
#> Downloading to temporary file: /tmp/RtmpJeSro8/file24345872dbc0.rds
#> File successfully downloaded.
#> Data successfully read from the RDS file.
#> Temporary file deleted.
print(head(report_data))
#> # A tibble: 6 × 9
#>   page_id     page_name disclaimer amount_spent_eur number_of_ads_in_lib…¹ date 
#>   <chr>       <chr>     <chr>      <chr>            <chr>                  <chr>
#> 1 23216224900 Plan Int… Plan Inte… 233281           62                     2024…
#> 2 3414866596… FDP Frak… Fraktion … 187376           48                     2024…
#> 3 2010653532… yello     yello      181760           26                     2024…
#> 4 4603703838… Robert H… Bündnis 9… 134610           250                    2024…
#> 5 1918513976… VETO – T… VETO - Ti… 118816           112                    2024…
#> 6 21289227249 FDP       FDP        104284           141                    2024…
#> # ℹ abbreviated name: ¹​number_of_ads_in_library
#> # ℹ 3 more variables: path <chr>, tf <chr>, cntry <chr>
```
