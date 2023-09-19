
# metatargetr <img src="man/figures/metatargetr_logo.png" width="160px" align="right"/>

<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/metatargetr)](https://CRAN.R-project.org/package=metatargetr)
<!-- badges: end -->

The goal of `metatargetr` is to parse targeting information from the
[Meta Ad Targeting
dataset](https://developers.facebook.com/docs/fort-ads-targeting-dataset/)
as well as retrieve data from the [Audience
tab](https://www.facebook.com/ads/library/?active_status=all&ad_type=political_and_issue_ads&country=NL&view_all_page_id=175740570505&sort_data%5Bdirection%5D=desc&sort_data%5Bmode%5D=relevancy_monthly_grouped&search_type=page&media_type=all)
in the Meta Ad Library. It also includes some helper functions to work with Meta ad library data in general.

## Installation

You can install the development version of metatargetr like so:

``` r
remotes::install_github("favstats/metatargetr")
```

## Load in Package

``` r
library(metatargetr)
#> 
#> Attaching package: 'metatargetr'
#> The following objects are masked _by_ '.GlobalEnv':
#> 
#>     map_dfr_progress, walk_progress
```

## Get Targeting criteria (Last 30 Days)

The following code retrieves the targeting criteria used by the main
page of the VVD (Dutch party) in the last 30 days. Just put in the right
Page ID.

``` r

last30 <- get_targeting("121264564551002", timeframe = "LAST_30_DAYS")

head(last30, 5)
#> # A tibble: 5 × 15
#>   value  num_ads total_spend_pct type  location_type num_obfuscated is_exclusion
#>   <chr>    <int>           <dbl> <chr> <chr>                  <int> <lgl>       
#> 1 All         53           1     gend… <NA>                      NA NA          
#> 2 Women        0           0     gend… <NA>                      NA NA          
#> 3 Men          0           0     gend… <NA>                      NA NA          
#> 4 5453,…      13           0.303 loca… zips                       0 FALSE       
#> 5 4388,…      13           0.196 loca… zips                       0 FALSE       
#> # ℹ 8 more variables: custom_audience_type <chr>, ds <chr>,
#> #   main_currency <chr>, total_num_ads <int>, total_spend_formatted <chr>,
#> #   is_30_day_available <lgl>, is_90_day_available <lgl>, internal_id <chr>
```

## Get Targeting criteria (Last 7 Days)

The following code retrieves the targeting criteria used by the main
page of the VVD (Dutch party) in the last 7 days. Just put in the right
Page ID.

``` r
last7 <- get_targeting("121264564551002", timeframe = "LAST_7_DAYS")


head(last7, 5)
#> # A tibble: 5 × 15
#>   value  num_ads total_spend_pct type  location_type num_obfuscated is_exclusion
#>   <chr>    <int>           <dbl> <chr> <chr>                  <int> <lgl>       
#> 1 All          5           1     gend… <NA>                      NA NA          
#> 2 Women        0           0     gend… <NA>                      NA NA          
#> 3 Men          0           0     gend… <NA>                      NA NA          
#> 4 6816,…       1           0.124 loca… zips                       0 FALSE       
#> 5 8014,…       1           0.188 loca… zips                       0 FALSE       
#> # ℹ 8 more variables: custom_audience_type <chr>, ds <chr>,
#> #   main_currency <chr>, total_num_ads <int>, total_spend_formatted <chr>,
#> #   is_30_day_available <lgl>, is_90_day_available <lgl>, internal_id <chr>
```

## Get Images and Videos

The following code downloads the images and videos of a Meta ad. It also
retrieves additional info not present in the Meta Ad Library API
(e.g. `page_like_count` `cta_type` i.e. call to action button). Just put
in the right Ad Archive ID.

It automatically handles duplicate images and videos (of which there are
many) by hashing the images and videos and making sure they are not
saved twice.

This piece of code was created in collaboration with [Philipp
Mendoza](https://www.uva.nl/en/profile/m/e/p.m.mendoza/p.m.mendoza.html).

Note: You will need the [OpenImageR](https://github.com/mlampros/OpenImageR) R package for hashting to run!

``` r

get_ad_snapshots("561403598962843", download = T, hashing = T, mediadir = "data/media")
#> # A tibble: 1 × 52
#>   name  ad_creative_id cards         body_translations byline caption   cta_text
#>   <chr>          <dbl> <list>        <lgl>             <lgl>  <chr>     <lgl>   
#> 1 f      6269946734162 <df [2 × 16]> NA                NA     worldmil… NA      
#> # ℹ 45 more variables: dynamic_item_flags <lgl>, dynamic_versions <lgl>,
#> #   edited_snapshots <lgl>, effective_authorization_category <chr>,
#> #   event <lgl>, extra_images <lgl>, extra_links <lgl>, extra_texts <lgl>,
#> #   extra_videos <lgl>, instagram_shopping_products <lgl>,
#> #   display_format <chr>, title <chr>, link_description <chr>, link_url <chr>,
#> #   page_welcome_message <lgl>, images <lgl>, videos <lgl>,
#> #   creation_time <int>, page_id <dbl>, page_name <chr>, …
```
