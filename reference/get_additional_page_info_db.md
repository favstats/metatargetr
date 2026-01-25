# Get Page Info Dataset for a Specific Country

Downloads the historical Facebook or Instagram page info dataset for a
given ISO2C country code. The data is retrieved from a fixed GitHub
release URL in `.parquet` format. It includes information on:

- Page-level metadata (e.g., name, verification status, profile type)

- Audience metrics (e.g., number of likes, Instagram followers)

- Shared disclaimers (if applicable)

- Page creation and name change events with timestamps

- Contact and address information (if available)

- Free-text descriptions ("about" section)

## Usage

``` r
get_additional_page_info_db(iso2c, verbose = TRUE)
```

## Arguments

- iso2c:

  A string specifying the ISO-3166-1 alpha-2 country code (e.g., "DE",
  "FR", "US").

- verbose:

  Logical. If TRUE (default), prints a status message when downloading.

## Value

A tibble containing Facebook page info for the specified country. If the
dataset is not available or cannot be retrieved, a tibble with
`no_data = TRUE` and the given `iso2c` code is returned.

## Examples

``` r
if (FALSE) { # \dontrun{
  de_info <- get_page_info_db("DE")
  fr_info <- get_page_info_db("FR")
} # }
```
