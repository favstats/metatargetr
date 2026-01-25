# Aggregate a Pre-Combined Targeting Dataset

This function takes a single dataframe, assumed to be the result of
`bind_rows()` on multiple targeting datasets from different time
periods. It correctly aggregates the spending for each unique targeting
criterion and calculates the new totals and percentages based on the
combined data.

## Usage

``` r
aggr_targeting(combined_df)
```

## Arguments

- combined_df:

  A single dataframe that has already been combined from multiple
  sources (e.g., via
  [`dplyr::bind_rows`](https://dplyr.tidyverse.org/reference/bind_rows.html)).

- filter_disclaimer:

  An optional character vector of disclaimers or page names to filter
  the dataset before aggregation. If NULL (default), all data is used.

## Value

A single, aggregated tibble where each row represents a unique targeting
criterion for an advertiser across the combined period.
