# Check if a persistent browser session is active

Verifies both the R-side flag and that Chrome is actually responsive by
sending a lightweight evaluation to the browser. If Chrome has crashed
or the websocket connection has been lost, the stale session is
automatically cleaned up and FALSE is returned.

## Usage

``` r
browser_session_active()
```

## Value

Logical, TRUE if a session is active and responsive.

## Examples

``` r
if (FALSE) { # \dontrun{
browser_session_active()  # FALSE
browser_session_start()
browser_session_active()  # TRUE
browser_session_close()
browser_session_active()  # FALSE
} # }
```
