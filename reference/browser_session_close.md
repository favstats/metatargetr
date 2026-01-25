# Close the persistent browser session

Closes the browser session started by
[`browser_session_start()`](browser_session_start.md). After calling
this, each function call will start its own browser again.

## Usage

``` r
browser_session_close()
```

## Value

Invisibly returns TRUE on success.

## Examples

``` r
if (FALSE) { # \dontrun{
browser_session_start()
# ... do work ...
browser_session_close()
} # }
```
