# Detect and parse the snapshot JSON from a Facebook Ad Library script tag

Splits the raw HTML on `"snapshot":`, extracts the first JSON object
using a recursive regex, and parses it with
[`jsonlite::fromJSON()`](https://jeroen.r-universe.dev/jsonlite/reference/fromJSON.html).
Includes input validation at each step to produce clear error messages
instead of cryptic JSON parse failures.

## Usage

``` r
detectmysnap(rawhtmlascharacter)
```

## Arguments

- rawhtmlascharacter:

  Raw HTML content as character string.

## Value

A parsed JSON object (list).

## See also

[`get_ad_snapshots()`](get_ad_snapshots.md) which calls this function
internally.
