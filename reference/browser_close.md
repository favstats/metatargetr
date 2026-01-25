# Closes a Playwright browser instance

This function safely closes the browser instance associated with the
provided browser object. It's designed to handle cases where the browser
may have already been closed, preventing errors.

## Usage

``` r
browser_close(browser_df)
```

## Arguments

- browser_df:

  A tibble returned by `browser_launch()`, which contains the
  `browser_id` of the instance to be closed.

## Value

Invisibly returns `NULL`. This function is called for its side effect of
closing the browser.

## Examples

``` r
if (FALSE) { # \dontrun{
# Launch a browser
browser <- browser_launch()

# ... perform actions with the browser ...

# Close the browser instance when done
browser_close(browser)
} # }
```
