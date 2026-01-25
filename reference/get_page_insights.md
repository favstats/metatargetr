# Get Page Insights

Retrieves insights for a given Facebook page within a specified
timeframe, language, and country. It allows for fetching specific types
of information and optionally joining page info with targeting info.

## Usage

``` r
get_page_insights(
  pageid,
  timeframe = "LAST_30_DAYS",
  lang = "en-GB",
  iso2c = "US",
  include_info = c("page_info", "targeting_info"),
  join_info = T
)
```

## Arguments

- pageid:

  A string specifying the unique identifier of the Facebook page.

- timeframe:

  A string indicating the timeframe for the insights. Valid options
  include predefined timeframes such as "LAST_30_DAYS". The default
  value is "LAST_30_DAYS".

- lang:

  A string representing the language locale to use for the request,
  formatted as language code followed by country code (e.g., "en-GB" for
  English, United Kingdom). The default is "en-GB".

- iso2c:

  A string specifying the ISO-3166-1 alpha-2 country code for which
  insights are requested. The default is "US".

- include_info:

  A character vector specifying the types of information to include in
  the output. Possible values are "page_info" and "targeting_info". By
  default, both types of information are included.

- join_info:

  A logical value indicating whether to join page info and targeting
  info into a single data frame (if TRUE) or return them as separate
  elements in a list (if FALSE). The default is TRUE.

## Value

If `join_info` is TRUE, returns a data frame combining page and
targeting information for the specified Facebook page. If `join_info` is
FALSE, returns a list with two elements: `page_info` and
`targeting_info`, each containing the respective data as a data frame.
In case of errors or no data available, the function may return a
simplified data frame or list indicating the absence of data.

## Examples

``` r
insights <- get_page_insights(pageid="123456789", timeframe="LAST_30_DAYS", lang="en-GB", iso2c="US",
                              include_info=c("page_info", "targeting_info"), join_info=TRUE)
```
