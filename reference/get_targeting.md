# Get Meta Ad Library targeting data for a page

This function retrieves data for the targeting criteria of a Facebook
page for a specified timeframe.

## Usage

``` r
get_targeting(id, timeframe = "LAST_30_DAYS", lang = "en-GB", legacy = FALSE)
```

## Arguments

- id:

  A character string representing the Facebook page ID.

- timeframe:

  A character string representing the desired timeframe. Can either be
  "LAST_30_DAYS" or "LAST_7_DAYS". Defaults to "LAST_30_DAYS".

- lang:

  An ISO language code character string representing the desired
  language of the targeting criteria. Defaults to "en-GB" but can be
  "en-US" and many more.

## Value

A `tibble` containing the audience data for the specified Facebook page
and timeframe.

## Examples

``` r
if (FALSE) { # \dontrun{
get_targeting("123456789")
get_targeting("987654321", "LAST_7_DAYS")
} # }
```
