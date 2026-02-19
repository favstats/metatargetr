# Bind a list of 1-row ad tibbles with type normalization (internal)

Handles the common issue where snapshot columns have inconsistent types
across different ads (e.g., `page_categories` is character in one ad and
list in another, `videos` is a data.frame vs NULL).

## Usage

``` r
.bind_ad_rows(rows)
```

## Arguments

- rows:

  A list of 1-row tibbles.

## Value

A combined tibble.
