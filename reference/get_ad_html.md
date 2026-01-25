# Fetch Facebook Ad-Library pages (with caching)

Retrieves HTML content for Facebook Ad Library pages using headless
Chrome to bypass JavaScript-based bot detection. Results are cached to
disk.

## Usage

``` r
get_ad_html(
  ad_ids,
  country,
  cache_dir = NULL,
  overwrite = FALSE,
  strip_css = TRUE,
  wait_sec = 3,
  log_failed_ids = NULL,
  quiet = FALSE,
  return_type = c("paths", "list")
)
```

## Arguments

- ad_ids:

  Character vector of Ad-Library IDs.

- country:

  Two-letter country code.

- cache_dir:

  Directory where *.html.gz* files will be stored. Defaults to the value
  set during interactive setup, or "html_cache".

- overwrite:

  If FALSE (default) keep already-cached files.

- strip_css:

  Run fast regex-based CSS removal on downloaded pages.

- wait_sec:

  Seconds to wait for each page to load (default 3).

- log_failed_ids:

  If a character path is provided (e.g., "log.txt"), failed IDs will be
  appended to that file.

- quiet:

  Suppress progress messages.

- return_type:

  `"paths"` (default) or `"list"` for in-memory strings.

## Value

Either a named character vector of file paths or a named list of HTML
strings, in the *same order* as `ad_ids`.
