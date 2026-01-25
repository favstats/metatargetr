# Start a persistent browser session

Starts a headless Chrome browser session that will be reused by
[`get_ad_snapshots()`](get_ad_snapshots.md),
[`get_deeplink()`](get_deeplink.md), and
[`get_ad_html()`](get_ad_html.md) until
[`browser_session_close()`](browser_session_close.md) is called.

## Usage

``` r
browser_session_start()
```

## Value

Invisibly returns TRUE on success.

## Details

This significantly improves performance when processing multiple ads, as
browser startup (~2-3 seconds) only happens once.

## Examples

``` r
if (FALSE) { # \dontrun{
# Start session
browser_session_start()

# Process multiple ads (each reuses the session)
result1 <- get_ad_snapshots("1103135646905363")
result2 <- get_ad_snapshots("561403598962843")
result3 <- get_ad_snapshots("711082744873817")

# Close when done
browser_session_close()
} # }
```
