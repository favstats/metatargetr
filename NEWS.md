# metatargetr 0.0.10

## Improvements

* Improved `get_ad_library_page_id()` reliability for personal profiles:
  if the profile transparency path fails (often login-gated), it now falls
  back to extracting `delegate_page` / `associated_page_id` from the regular
  profile HTML.

* Added local artifact ignore rules to reduce accidental commits from ad-hoc
  analysis and automation runs (Playwright state, generated HTML/tarballs,
  local mapping/data files).

# metatargetr 0.0.8

## New features

* New `search_ad_library()` function to search the Facebook Ad Library by page
  ID or text query **without an API key**. Uses headless Chrome to extract ad
  data from server-side rendered HTML (~30 ads per page). Supports experimental
  pagination via GraphQL.

  ```r
  browser_session_start()
  # Get all ads from a specific page
  ads <- search_ad_library(page_id = "52985377549")
  # Search by keyword
  ads <- search_ad_library(query = "Rob Jetten", country = "NL")
  # Check for political ads
  ads %>% filter(categories == "POLITICAL")
  browser_session_close()
  ```

  Returns rich metadata per ad:
  - **Ad identity**: `ad_archive_id`, `page_name`, `page_id`, `ad_library_url`
  - **Classification**: `categories` (e.g., `"POLITICAL"`), `is_active`
  - **Dates**: `start_date`, `end_date` (POSIXct)
  - **Spend & reach**: `spend`, `currency`, `reach_estimate`, `impressions_lower`,
    `impressions_upper`
  - **Creative**: `body`, `title`, `caption`, `link_url`, `link_description`,
    `cta_text`, `display_format`, `images`, `videos`, `cards`
  - **Regulation**: `disclaimer_label`, `byline`, `publisher_platform`

  Additional parameters: `active_status`, `date_min`/`date_max`, `media_type`,
  `publisher_platforms`, `content_languages`, `search_type`, `sort_mode`,
  `sort_direction`.

  Detects Facebook rate limiting (error 1675004) and reports it clearly instead
  of returning empty/phantom data.

# metatargetr 0.0.7

## Bug fixes

* Fixed `get_ad_snapshots()` always returning data for the wrong ad (e.g.,
  "Meesho" regardless of requested ad ID). Facebook's server-side rendered
  script tags now contain a bundle of 25+ ads' snapshot data in a single
  `<script>` element. The old `detectmysnap()` always extracted the first
  `"snapshot":` occurrence, which belonged to whichever ad Facebook placed
  first in the bundle. The function now accepts an `ad_id` parameter, locates
  the ad ID in the raw text, and extracts the nearest `"snapshot":` JSON
  object after it, ensuring each ad gets its own correct data.

# metatargetr 0.0.6

## Bug fixes

* Fixed `get_ad_snapshots()` failing with "lexical error: invalid char in json
  text" when Facebook's page structure includes unrelated script tags containing
  the word "snapshot" (e.g., "ads/reporting/snapshot"). The script tag filter now
  matches on `"snapshot":` (the JSON key) instead of bare `snapshot`, avoiding
  false positives (#1).

* Fixed `detectmysnap()` passing NA to `jsonlite::fromJSON()` when the wrong
  script tag was selected. Added input validation at every step (NA/NULL/empty
  checks, split result check, regex match check, pre-parse check) so failures
  produce clear error messages instead of cryptic JSON parse errors.

* Fixed `browser_session_active()` only checking R-side flags without verifying
  that Chrome is actually responsive. It now pings the browser with a lightweight
  evaluation. If Chrome has crashed ("Reconnecting to chrome process"), the stale
  session is automatically cleaned up so callers create a fresh one instead of
  reusing a dead session.

* Fixed `browser_session_close()` failing to clean up R-side state when Chrome
  had already crashed, which could leave the session in a broken state where
  `browser_session_start()` would not work without restarting R.

## New features

* `browser_session_start()` now warms up the session by navigating to the
  Facebook Ad Library landing page on startup. This passes the JS challenge and
  sets cookies so that subsequent `get_ad_snapshots()` calls return data
  immediately. Controlled via `warm_up` (default TRUE) and `warm_up_wait`
  (default 8 seconds) parameters.

* `get_ad_snapshots()` now includes automatic warm-up for temporary (non-
  persistent) sessions. When no persistent session is active, a fresh session
  navigates to the Ad Library landing page before fetching the actual ad,
  ensuring the JS challenge is passed.

* `get_ad_snapshots()` now includes retry logic via the `max_retries` parameter
  (default 1). If the page loads but snapshot data is not yet available, the
  function retries with a progressively longer wait before giving up.

* `get_ad_snapshots()` default `wait_sec` increased from 4 to 6 seconds for
  better reliability with Facebook's current page load times.

* New `browser_session_restart()` function for convenience when Chrome becomes
  unresponsive mid-batch. Equivalent to calling `browser_session_close()` then
  `browser_session_start()`.

* `get_ad_snapshots()` now wraps chromote navigation and evaluation calls in
  tryCatch, producing actionable warnings (suggesting `browser_session_restart()`)
  instead of unhandled errors when Chrome crashes.

# metatargetr 0.0.5

* Initial tracked release.
