# Retrieve Ad Data from the LinkedIn Ad Library with Pagination

This function scrapes ad data from the LinkedIn Ad Library, handling
pagination to retrieve all available results for a given search query.
It first collects all ad detail links and then scrapes each detail page
with a configurable timeout and retry mechanism.

## Usage

``` r
get_linkedin_ads(
  keyword,
  countries,
  start_date,
  end_date,
  account_owner = NULL,
  max_pages = 100,
  max_retries = 5,
  timeout_seconds = 15
)
```

## Arguments

- keyword:

  A character string for the keyword to search for (e.g., "Habeck").

- countries:

  A character vector of two-letter country codes (e.g., "DE").

- start_date:

  The start date of the search range in "YYYY-MM-DD" format.

- end_date:

  The end date of the search range in "YYYY-MM-DD" format.

- account_owner:

  Optional. A character string for the ad account owner.

- max_pages:

  The maximum number of pages to scrape. Defaults to 100.

- max_retries:

  The maximum number of retries for each detail page request. Defaults
  to 5.

- timeout_seconds:

  The timeout in seconds for each detail page request. Defaults to 15.

## Value

A tibble containing the detailed scraped ad information from all pages.

## Examples

``` r
if (FALSE) { # \dontrun{
  ads_data <- get_linkedin_ads(
    keyword = "Habeck",
    countries = "DE",
    start_date = "2025-01-01",
    end_date = "2025-02-23",
    account_owner = "INSM",
    max_pages = 5,
    max_retries = 3,
    timeout_seconds = 20
  )
  print(ads_data)
} # }
```
