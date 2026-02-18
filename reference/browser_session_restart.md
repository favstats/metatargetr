# Restart the persistent browser session

Closes the current session (if any) and starts a fresh one with warm-up.
Useful when Chrome has become unresponsive or after errors mid-batch.

## Usage

``` r
browser_session_restart(warm_up = TRUE, warm_up_wait = 8)
```

## Arguments

- warm_up:

  Logical. If TRUE (default), navigates to the Facebook Ad Library
  landing page on startup to pass the JS challenge and set cookies.

- warm_up_wait:

  Seconds to wait during warm-up (default 8).

## Value

Invisibly returns TRUE on success.

## Examples

``` r
if (FALSE) { # \dontrun{
browser_session_start()
# ... Chrome becomes unresponsive ...
browser_session_restart()
# ... continue working ...
browser_session_close()
} # }
```
