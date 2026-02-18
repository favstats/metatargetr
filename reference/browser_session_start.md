# Start a persistent browser session

Starts a headless Chrome browser session that will be reused by
[`get_ad_snapshots()`](get_ad_snapshots.md),
[`get_deeplink()`](get_deeplink.md), and
[`get_ad_html()`](get_ad_html.md) until
[`browser_session_close()`](browser_session_close.md) is called.

## Usage

``` r
browser_session_start(warm_up = TRUE, warm_up_wait = 8)
```

## Arguments

- warm_up:

  Logical. If TRUE (default), navigates to the Facebook Ad Library
  landing page on startup to pass the JS challenge and set cookies.

- warm_up_wait:

  Seconds to wait during warm-up (default 8).

## Value

Invisibly returns TRUE on success.

## Details

This significantly improves performance when processing multiple ads, as
browser startup (~2–3 seconds) only happens once. By default the session
is warmed up by navigating to the Facebook Ad Library landing page,
which passes the JS challenge and sets cookies so that subsequent calls
return data immediately.

## Examples

``` r
if (FALSE) { # \dontrun{
# Start session (includes warm-up)
browser_session_start()

# Process multiple ads (each reuses the session)
results <- map_dfr_progress(ad_ids, ~get_ad_snapshots(.x))

# Close when done
browser_session_close()
} # }
```
