# Search the Facebook Ad Library

Retrieves ads from the Facebook Ad Library by page ID or text query,
**without requiring an API key**. Uses headless Chrome to load the Ad
Library search page, which embeds ~30 ads with rich metadata in its
server-side rendered HTML.

## Usage

``` r
search_ad_library(
  page_id = NULL,
  query = NULL,
  country = "ALL",
  ad_type = "all",
  active_status = "all",
  date_min = NULL,
  date_max = NULL,
  media_type = "all",
  publisher_platforms = NULL,
  content_languages = NULL,
  search_type = NULL,
  sort_mode = "total_impressions",
  sort_direction = "desc",
  max_pages = 1,
  wait_sec = 12
)
```

## Arguments

- page_id:

  Character. Facebook page ID to search for all ads from that page
  (e.g., `"52985377549"` for D66). Use this for targeted searches of a
  specific advertiser. Mutually exclusive with `query`.

- query:

  Character. Text search query (e.g., `"Rob Jetten"`, `"coca-cola"`).
  Returns ads mentioning the query from any advertiser. Mutually
  exclusive with `page_id`.

- country:

  Character. ISO country code filter (default `"ALL"`). Use `"NL"` for
  Netherlands, `"US"` for United States, etc.

- ad_type:

  Character. Ad type filter (default `"all"`). Options: `"all"`,
  `"political_and_issue_ads"`.

- active_status:

  Character. Delivery status filter (default `"all"`). Options: `"all"`,
  `"active"`, `"inactive"`.

- date_min:

  Character or NULL. Minimum start date filter in `YYYY-MM-DD` format.
  Maps to `start_date[min]` in the Ad Library URL.

- date_max:

  Character or NULL. Maximum start date filter in `YYYY-MM-DD` format.
  Maps to `start_date[max]` in the Ad Library URL.

- media_type:

  Character. Media type filter (default `"all"`). Common options:
  `"all"`, `"image"`, `"video"`.

- publisher_platforms:

  Character vector or NULL. Platform filters. Example:
  `c("facebook", "instagram")`.

- content_languages:

  Character vector or NULL. Content language filters. Example:
  `c("nl", "en")`.

- search_type:

  Character or NULL. Search type override. Common options:
  `"keyword_unordered"`, `"keyword_exact_phrase"`, `"page"`. If `NULL`
  (default), inferred from `page_id`/`query`.

- sort_mode:

  Character or NULL. Sort mode for `sort_data[mode]`. Default
  `"total_impressions"`.

- sort_direction:

  Character or NULL. Sort direction for `sort_data[direction]`. Default
  `"desc"`.

- max_pages:

  Integer. Number of pages to fetch, each containing ~30 ads (default
  1). Set higher to paginate (experimental).

- wait_sec:

  Numeric. Seconds to wait for the page to load (default 12). Increase
  if getting empty results.

## Value

A tibble with one row per ad. Returns an empty tibble if no ads are
found. See **Data returned** section for column details.

## Details

### Data returned

Each ad includes:

- **Metadata**: `ad_archive_id`, `page_name`, `page_id`, `categories`
  (e.g., `"POLITICAL"`), `is_active`, `start_date`, `end_date`, `spend`,
  `currency`, `reach_estimate`, `publisher_platform`,
  `impressions_lower`, `impressions_upper`, `targeted_countries`

- **Creative (snapshot)**: `body`, `title`, `display_format`,
  `link_url`, `cta_text`, `images`, `videos`, `cards`,
  `page_profile_picture_url`

- **Link**: `ad_library_url` — direct URL to the ad in Facebook's Ad
  Library

### Important notes

- Uses `active_status="all"` by default (full history)

- Use `active_status="active"` to focus on ads currently running

- Each page load yields ~30 ads from the server-side rendered HTML

- Pagination beyond page 1 reuses Facebook's own pagination request
  shape captured from browser runtime (still experimental)

- The `categories` field can identify political ads (`"POLITICAL"`)

## Examples

``` r
if (FALSE) { # \dontrun{
browser_session_start()

# Search by page ID (all D66 ads)
d66_ads <- search_ad_library(page_id = "52985377549")

# Search by keyword in the Netherlands
ads <- search_ad_library(query = "Rob Jetten", country = "NL")

# Check which ads are political
ads %>% dplyr::filter(categories == "POLITICAL")

# Check ad dates and spend
ads %>% dplyr::select(page_name, start_date, end_date, spend, categories)

browser_session_close()
} # }
```
