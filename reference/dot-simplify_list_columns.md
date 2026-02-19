# Simplify list-columns that contain only scalar values (internal)

After type-harmonisation, columns like `title` or `caption` may become
list-columns even though every element is a length-1 atomic value (or
NULL). This function detects those and converts them back to character
vectors.

## Usage

``` r
.simplify_list_columns(df)
```

## Arguments

- df:

  A tibble.

## Value

The tibble with simplified columns.
