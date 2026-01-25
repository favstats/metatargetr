# Get ad snapshots from Facebook ad library

Retrieves snapshot data for a Facebook ad from the Ad Library. This
function uses headless Chrome (via chromote) to bypass Facebook's
JavaScript-based bot detection.

## Usage

``` r
get_ad_snapshots(
  ad_id,
  download = FALSE,
  mediadir = "data/media",
  hashing = FALSE,
  wait_sec = 4
)
```

## Arguments

- ad_id:

  A character string specifying the ad ID.

- download:

  Logical, whether to download media files.

- mediadir:

  Directory to save media files.

- hashing:

  Logical, whether to hash the files. RECOMMENDED!

- wait_sec:

  Seconds to wait for page to load (default 4). Increase if you're
  getting empty results.

## Value

A tibble with ad details.
