# Get the current browser session (internal)

Returns the active browser session, or NULL if none is active. If a
session was previously started but Chrome has crashed, this will detect
the crash (via [`browser_session_active()`](browser_session_active.md))
and return NULL so a fresh session is created by the caller.

## Usage

``` r
get_browser_session()
```

## Value

A chromote session object or NULL.
