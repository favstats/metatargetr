# Extract and flatten 'deeplinkAdCard' JSON from a Facebook Ad Library page

This function programmatically retrieves the embedded JSON object
labeled `deeplinkAdCard` from the source code of a Facebook Ad Library
ad page.

## Usage

``` r
get_deeplink(ad_id, wait_sec = 4)
```

## Arguments

- ad_id:

  Character string specifying the Facebook ad ID (as shown in the Ad
  Library URL).

- wait_sec:

  Seconds to wait for page to load (default 4). Increase if getting
  errors.

## Value

A tibble with one row, containing flattened columns extracted from the
deeplink JSON object. Columns depend on the structure of the JSON and
may include fields like `fevInfo_*`,
`fevInfo_free_form_additional_info_*`, `fevInfo_learn_more_content_*`,
and snapshot-related columns.

## Details

The function performs the following steps internally:

1.  Fetches the ad page HTML from Facebook's Ad Library using headless
    Chrome.

2.  Locates the `<script>` tag containing the `deeplinkAdCard` object.

3.  Uses a recursive regular expression to extract the full JSON object
    following `deeplinkAdCard`.

4.  Parses the JSON string into a nested R list.

5.  Flattens the JSON into a tidy tibble row, unnesting nested
    sub-objects such as `fevInfo`, `free_form_additional_info`,
    `learn_more_content`, and optionally `snapshot` if present.

The output is designed for downstream analysis: each ad is represented
as **one row** in a tibble, with nested JSON fields expanded into their
own columns via
[`tidyr::unnest_wider()`](https://tidyr.tidyverse.org/reference/unnest_wider.html).

This function complements [`get_ad_snapshots()`](get_ad_snapshots.md),
which extracts the `snapshot` JSON. Use `get_deeplink()` when additional
metadata embedded under `deeplinkAdCard` is required.

## See also

[`get_ad_snapshots()`](get_ad_snapshots.md) for extracting snapshot
JSON; [`detectmysnap()`](detectmysnap.md) for raw JSON detection.

## Examples

``` r
if (FALSE) { # \dontrun{
df <- get_deeplink("1103135646905363")
glimpse(df)
} # }
```
