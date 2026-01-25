# Check if a persistent browser session is active

Check if a persistent browser session is active

## Usage

``` r
browser_session_active()
```

## Value

Logical, TRUE if a session is active.

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
