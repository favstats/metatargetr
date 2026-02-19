# Extract the search_results_connection JSON from the browser (internal)

Uses JavaScript to find and extract the full `search_results_connection`
object from Facebook's SSR script tags. This contains all ad metadata
(dates, spend, categories, impressions) plus the snapshot (creative
data).

## Usage

``` r
.extract_search_results(b)
```

## Arguments

- b:

  A chromote session object.

## Value

A parsed list from the JSON, or NULL.
