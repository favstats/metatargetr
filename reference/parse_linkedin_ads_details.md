# Parse Important Information from an Ad Detail HTML Page

This function takes the HTML content from a LinkedIn Ad Library detail
page and extracts key information like advertiser, targeting, and
impressions.

## Usage

``` r
parse_linkedin_ads_details(html_content)
```

## Arguments

- html_content:

  An `xml_document` object, typically read from an HTML file or obtained
  from an HTTP response.

## Value

A list containing the extracted ad details.

## Examples

``` r
if (FALSE) { # \dontrun{
  # Assuming you have saved the HTML of a detail page to "ad_detail.html"
  ad_html <- rvest::read_html("ad_detail.html")
  details <- parse_ad_details(ad_html)
  print(details)
} # }
```
