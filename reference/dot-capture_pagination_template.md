# Capture native AdLibrary pagination request template from browser runtime

Capture native AdLibrary pagination request template from browser
runtime

## Usage

``` r
.capture_pagination_template(b, max_scrolls = 8L, scroll_wait_sec = 2)
```

## Arguments

- b:

  A chromote session object.

- max_scrolls:

  Integer. Max scroll attempts while waiting for capture.

- scroll_wait_sec:

  Numeric. Seconds to wait between scroll attempts.

## Value

A list with `params` and metadata, or NULL.
