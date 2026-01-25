# Fetch a Google Ads Transparency Report

This function automates the process of obtaining data from the Google
Ads Transparency report. It targets the main data bundle, which contains
several CSV files. The user can specify which file to process using
either its full filename or a convenient shorthand. By default, all
downloaded files are deleted after the data is read into memory.

## Usage

``` r
get_ggl_ads(file_to_read = "creatives", keep_file_at = NULL, quiet = FALSE)
```

## Arguments

- file_to_read:

  A character string specifying which CSV file to read from the bundle,
  using either the full filename or a shorthand alias (e.g.,
  `"creatives"`). Defaults to `"creatives"`.

- keep_file_at:

  A character path to a directory where the selected CSV file should be
  saved. If `NULL` (the default), all downloaded and extracted files are
  deleted. If a path is provided, the function will save the specified
  `file_to_read` to that location.

- quiet:

  A logical value. If `FALSE` (default), the function will print status
  messages about downloading and processing.

## Value

A `tibble` (data frame) containing the data from the selected CSV file.

## Details

Downloads the latest Google Political Ads transparency data bundle (a
ZIP file), extracts a specific CSV report, reads it into a tibble, and
then cleans up the downloaded and extracted files.

The data bundle contains several files. The user can specify which file
to read using a shorthand alias.

**Available Reports (Aliases):**

- **`"creatives"` (Default):**
  `google-political-ads-creative-stats.csv`. The primary and most
  detailed file. Contains statistics for each ad creative, including
  advertiser info, targeting details, and spend.

- **`"advertisers"`:** `google-political-ads-advertiser-stats.csv`.
  Aggregate statistics for each political advertiser.

- **`"weekly_spend"`:**
  `google-political-ads-advertiser-weekly-spend.csv`. Advertiser
  spending aggregated by week.

- **`"geo_spend"`:** `google-political-ads-geo-spend.csv`. Overall
  spending aggregated by geographic location.

- **`"advertiser_geo_spend"`:**
  `google-political-ads-advertiser-geo-spend.csv`. Advertiser-specific
  spending aggregated by US state.

- **`"declarations"`:**
  `google-political-ads-advertiser-declared-stats.csv`. Self-declared
  information from advertisers in certain regions (e.g., California, New
  Zealand).

- **`"advertiser_mapping"`:** `advertiser_id_mapping.csv`. A mapping
  file to reconcile different advertiser identifiers.

- **`"creative_mapping"`:** `creative_id_mapping.csv`. A mapping file to
  reconcile different ad creative identifiers.

- **`"updated_date"`:** `google-political-ads-updated.csv`. A
  single-entry file indicating the last time the report data was
  refreshed.

- **`"campaigns" (Deprecated):`**
  `google-political-ads-campaign-targeting.csv`. Ad-level targeting is
  now in the `"creatives"` file.

- **`"keywords" (Discontinued):`**
  `google-political-ads-top-keywords-history.csv`. Historical data on
  top keywords, terminated in Dec 2019.

For more details on the specific fields in each file, please refer to
the Google Ads Transparency Report documentation.

## Examples

``` r
if (FALSE) { # \dontrun{

# Fetch the main creative stats report using the default alias
creative_stats <- get_ggl_ads()

# Fetch the advertiser stats report using its alias
advertiser_stats <- get_ggl_ads(file_to_read = "advertisers")

# Fetch the advertiser ID mapping file
advertiser_map <- get_ggl_ads(file_to_read = "advertiser_mapping")

# Fetch the geo spend report using its full filename
geo_spend_report <- get_ggl_ads(
  file_to_read = "google-political-ads-geo-spend.csv"
)

# Fetch the main report and save the CSV file to a "data" folder
creative_stats_saved <- get_ggl_ads(
  file_to_read = "creatives",
  keep_file_at = "data/"
)
} # }
```
