# Apply a function to each element of a list with a progress bar

Adding a progress bar to the map_dfr function
https://www.jamesatkins.net/posts/progress-bar-in-purrr-map-df/

## Usage

``` r
map_dfr_progress(.x, .f, ...)
```

## Arguments

- .x:

  List to iterate over.

- .f:

  Function to apply.

- ...:

  Other parameters passed to
  [`purrr::map_dfr`](https://purrr.tidyverse.org/reference/map_dfr.html).

- .id:

  An identifier.

## Value

An aggregated data frame.
