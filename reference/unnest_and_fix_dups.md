# Unnest interest targeting data

unnest and fix duplicates in interest targeting data from Ad Targeting
Dataset

The function unnests "include" and "exclude" columns in the Ad Targeting
Dataset, and removes duplicates.

## Usage

``` r
unnest_and_fix_dups(dat, the_list, new_name)
```

## Arguments

- dat:

  a data frame

- the_list:

  the column name to unnest

- new_name:

  the name of the new column after unnesting and fixing duplicates

## Value

a modified data frame with unnested and deduplicated values

## Examples

``` r
### example usage:
## make sure you have the variable 'archive_id' in your data
ad_targeting_data %>%
    rowwise() %>%
    mutate(include_list = fix_json(include)) %>%
    ungroup() %>%
    ## the_list: the parsed list of JSON, new_name: what the parsed column should be called
   unnest_and_fix_dups(the_list = include_list, new_name = "parsed_include")
#> Error in ungroup(.): could not find function "ungroup"
```
