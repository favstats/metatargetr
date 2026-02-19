# Convert a collated_result list into a 1-row tibble (internal)

Flattens the nested collated_result structure (which contains snapshot
data, dates, spend, etc.) into a single tibble row.

## Usage

``` r
.flatten_collated_result(cr)
```

## Arguments

- cr:

  A single collated_result list from the SSR.

## Value

A 1-row tibble, or NULL on failure.
