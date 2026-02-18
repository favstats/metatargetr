# Get ad snapshots from Facebook Ad Library

Retrieves snapshot data (images, videos, cards, body text, etc.) for a
Facebook ad from the Ad Library. Uses headless Chrome via chromote to
bypass Facebook's JavaScript-based bot detection.

## Usage

``` r
get_ad_snapshots(
  ad_id,
  download = FALSE,
  mediadir = "data/media",
  hashing = FALSE,
  wait_sec = 6,
  max_retries = 1
)
```

## Arguments

- ad_id:

  Character string. The Facebook ad ID.

- download:

  Logical. If TRUE, download media files to `mediadir`.

- mediadir:

  Character. Directory to save downloaded media files.

- hashing:

  Logical. If TRUE, hash downloaded files for deduplication. Recommended
  for large-scale data collection.

- wait_sec:

  Numeric. Seconds to wait for the page to load (default 6). Increase if
  you are getting empty results.

- max_retries:

  Integer. Number of retry attempts if data is not found on the first
  try (default 1). Each retry waits progressively longer.

## Value

A tibble with one row containing ad snapshot fields (images, videos,
body, title, display_format, page_name, etc.) and the ad ID. If
retrieval fails, returns a single-column tibble with just the id.

## Details

For best results when processing multiple ads, call
[`browser_session_start()`](browser_session_start.md) before and
[`browser_session_close()`](browser_session_close.md) after. If no
persistent session exists, a temporary one is created and warmed up
automatically (adds ~10 seconds on the first call).

Includes built-in retry logic: if the page loads but snapshot data is
not yet available (e.g., JS challenge still completing), the function
retries with a longer wait before giving up.

## Examples

``` r
if (FALSE) { # \dontrun{
# Single ad
snap <- get_ad_snapshots("1536277920797773")

# Batch processing (recommended)
browser_session_start()
results <- map_dfr_progress(ad_ids, ~get_ad_snapshots(.x))
browser_session_close()
} # }
```
