# Detect and parse the snapshot JSON from a Facebook Ad Library script tag

Facebook's SSR script tags contain a bundle of many ads' snapshot data.
This function locates the `"snapshot":` occurrence that belongs to the
requested `ad_id` by first finding the ad_id in the raw text and then
extracting the nearest `"snapshot":` JSON object after it.

## Usage

``` r
detectmysnap(rawhtmlascharacter, ad_id = NULL)
```

## Arguments

- rawhtmlascharacter:

  Raw HTML content as character string.

- ad_id:

  Character string. The Facebook ad ID to find in the bundle. When
  provided, the function extracts only the snapshot belonging to this
  ad. When NULL, extracts the first snapshot found (legacy behavior).

## Value

A parsed JSON object (list).

## Details

Falls back to the original split-based approach when no ad_id is
provided.

## See also

[`get_ad_snapshots()`](get_ad_snapshots.md) which calls this function
internally.
