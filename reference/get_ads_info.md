# Get and Parse Ad Library Data

A wrapper function that downloads ad HTMLs for a given set of IDs and a
country, parses the data, and returns a final, reordered dataframe.

## Usage

``` r
get_ads_info(ad_ids, country, keep_html = TRUE, cache_dir = "html_cache", ...)
```

## Arguments

- ad_ids:

  A character vector of Ad Library IDs.

- country:

  A two-letter country code.

- keep_html:

  A logical flag. If `FALSE` (the default), the cache directory with the
  downloaded HTML files will be deleted after parsing. If `TRUE`, the
  files will be kept.

- cache_dir:

  The directory to store downloaded HTML files. Defaults to
  "html_cache".

- ...:

  Additional arguments to be passed down to
  [`get_ad_html()`](get_ad_html.md) (e.g., `overwrite`, `quiet`,
  `max_active`).

## Value

A single, reordered dataframe containing the parsed ad data.
