# Resolve Facebook Handles to Ad Library Page IDs

Translates Facebook page handles (or profile URLs) into the numeric Ad
Library page identifier used as `view_all_page_id` in
`https://www.facebook.com/ads/library/` URLs.

## Usage

``` r
get_ad_library_page_id(
  handles,
  wait_sec = 8,
  max_retries = 1,
  country = "ALL",
  quiet = FALSE
)
```

## Arguments

- handles:

  Character vector of Facebook handles, profile URLs, profile
  transparency URLs, Ad Library URLs, or numeric page IDs.

- wait_sec:

  Numeric. Seconds to wait after each page navigation before extracting
  content. Default is `8`.

- max_retries:

  Integer. Number of retries per handle when extraction fails. Default
  is `1`.

- country:

  Character. Country code used when constructing `ad_library_url` output
  (default `"ALL"`).

- quiet:

  Logical. If `TRUE`, suppresses progress messages.

## Value

A tibble with one row per input and columns:

- input:

  Original input value.

- handle:

  Normalized handle or numeric ID extracted from input.

- page_id:

  Resolved Ad Library page ID (same as `view_all_page_id`).

- ad_library_page_id:

  Alias of `page_id` for clarity.

- is_running_ads:

  Logical/`NA`: whether transparency text indicates the page is
  currently running ads.

- transparency_url:

  Profile transparency URL used for extraction.

- ad_library_url:

  Convenience Ad Library page URL for the resolved ID.

- ok:

  Logical success flag for each input.

- error:

  Error message when resolution fails.

## Details

The function loads each page's **Profile Transparency** tab in a
headless browser and extracts the `Page ID` from rendered text.

## Examples

``` r
# Numeric IDs are returned directly (no browser needed)
get_ad_library_page_id(c("121264564551002", "106359662726593"))
#> # A tibble: 2 × 9
#>   input        handle page_id ad_library_page_id is_running_ads transparency_url
#>   <chr>        <chr>  <chr>   <chr>              <lgl>          <chr>           
#> 1 12126456455… 12126… 121264… 121264564551002    NA             NA              
#> 2 10635966272… 10635… 106359… 106359662726593    NA             NA              
#> # ℹ 3 more variables: ad_library_url <chr>, ok <lgl>, error <chr>

if (FALSE) { # \dontrun{
# Resolve from handles / URLs
get_ad_library_page_id(c("VVD", "https://www.facebook.com/TeachGoldenApple/"))
} # }
```
