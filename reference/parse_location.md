# Parse Location from Ad Targeting Dataset

A function to parse the location strings in the Ad Targeting Dataset and
split into separate columns for each level of detail.

## Usage

``` r
parse_location(.x, loc_var, type = "include", verbose = T)
```

## Arguments

- .x:

  A data.frame containing the location string

- loc_var:

  A character string specifying the name of the column in .x that
  contains the location string

- type:

  A character string specifying the prefix to add to each column of
  split location details. Default is "include". Should be "include" or
  "exclude".

- verbose:

  A logical flag specifying whether to display a progress bar during
  processing. Default is `TRUE`.

## Value

A data.frame with columns for each level of detail in the location.

## Examples

``` r
if (FALSE) { # \dontrun{
  ### create a dataset with unique include_location values
  distinct_data <- targeting_data %>%
    distinct(include_location)

  #### parse the location data and join in original dataset
  distinct_data %>%
    parse_location(include_location, type = "include") %>%
    right_join(targeting_data)

  ###----####

  ### create a dataset with unique exclude_location values
  distinct_data <- targeting_data %>%
    distinct(exclude_location)

  #### parse the location data and join in original dataset
  distinct_data %>%
    parse_location(exclude_location, type = "exclude") %>%
    right_join(targeting_data)

} # }
```
