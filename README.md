
<!-- README.md is generated from README.Rmd. Please edit that file -->

# metatargetr

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/metatargetr)](https://CRAN.R-project.org/package=metatargetr)
<!-- badges: end -->

The goal of metatargetr is to …

## Installation

You can install the development version of metatargetr like so:

``` r
remotes::install_github("favstats/metatargetr")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(metatargetr)
## basic example code
```

## Get Targeting criteria (Last 30 Days)

The following code retrieves the targeting criteria used by the Social
Democrats in Denmark in the last 30 days. Just put in the right Page ID.

``` r
last30<- get_targeting("41459763029", timeframe = "LAST_30_DAYS")
#> Warning: Outer names are only allowed for unnamed scalar atomic inputs

head(last30, 5)
#>              value num_ads total_spend_pct     type location_type
#> 1              All     117      1.00000000   gender          <NA>
#> 2            Women       0      0.00000000   gender          <NA>
#> 3              Men       0      0.00000000   gender          <NA>
#> 4           Danish       8      0.05181978 language          <NA>
#> 5 Esbjerg, Denmark       3      0.01058574 location          CITY
#>   num_obfuscated is_exclusion detailed_type         ds main_currency
#> 1             NA           NA          <NA> 2022-10-17           DKK
#> 2             NA           NA          <NA> 2022-10-17           DKK
#> 3             NA           NA          <NA> 2022-10-17           DKK
#> 4             NA           NA          <NA> 2022-10-17           DKK
#> 5              1        FALSE          <NA> 2022-10-17           DKK
#>   total_num_ads total_spend_formatted is_30_day_available is_90_day_available
#> 1           117            DKK383,759                TRUE                TRUE
#> 2           117            DKK383,759                TRUE                TRUE
#> 3           117            DKK383,759                TRUE                TRUE
#> 4           117            DKK383,759                TRUE                TRUE
#> 5           117            DKK383,759                TRUE                TRUE
#>   internal_id
#> 1 41459763029
#> 2 41459763029
#> 3 41459763029
#> 4 41459763029
#> 5 41459763029
```

## Get Targeting criteria (Last 7 Days)

The following code retrieves the targeting criteria used by the Social
Democrats in Denmark in the last 7 days. Just put in the right Page ID.

``` r
last7 <- get_targeting("41459763029", timeframe = "LAST_7_DAYS")
#> Warning: Outer names are only allowed for unnamed scalar atomic inputs


head(last7, 5)
#>           value num_ads total_spend_pct     type location_type num_obfuscated
#> 1           All      77      1.00000000   gender          <NA>             NA
#> 2         Women       0      0.00000000   gender          <NA>             NA
#> 3           Men       0      0.00000000   gender          <NA>             NA
#> 4 5884, Denmark       1      0.01705735 location          zips              0
#> 5 5882, Denmark       1      0.01705735 location          zips              0
#>   is_exclusion detailed_type         ds main_currency total_num_ads
#> 1           NA          <NA> 2022-10-17           DKK            77
#> 2           NA          <NA> 2022-10-17           DKK            77
#> 3           NA          <NA> 2022-10-17           DKK            77
#> 4        FALSE          <NA> 2022-10-17           DKK            77
#> 5        FALSE          <NA> 2022-10-17           DKK            77
#>   total_spend_formatted is_30_day_available is_90_day_available internal_id
#> 1            DKK200,281                TRUE                TRUE 41459763029
#> 2            DKK200,281                TRUE                TRUE 41459763029
#> 3            DKK200,281                TRUE                TRUE 41459763029
#> 4            DKK200,281                TRUE                TRUE 41459763029
#> 5            DKK200,281                TRUE                TRUE 41459763029
```
