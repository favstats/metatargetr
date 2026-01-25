# Introduction to metatargetr

## Overview

metatargetr is an R package designed to parse and analyze targeting
information from the Meta Ad Library dataset and retrieve data from the
Audience tab. It provides tools for working with Meta ad library data
and includes integration with the Google Transparency Report.

## Installation

You can install the development version of metatargetr from GitHub:

``` r
# install.packages("remotes")
remotes::install_github("favstats/metatargetr")
```

## Basic Usage

First, load the package:

``` r
library(metatargetr)
```

The package provides several core functions:

1.  [`get_targeting()`](../reference/get_targeting.md): Retrieve recent
    targeting data
2.  [`get_targeting_db()`](../reference/get_targeting_db.md): Access
    historical targeting data
3.  [`get_page_insights()`](../reference/get_page_insights.md): Get page
    information
4.  [`get_ad_snapshots()`](../reference/get_ad_snapshots.md): Download
    ad creatives
5.  [`ggl_get_spending()`](../reference/ggl_get_spending.md): Access
    Google Transparency Report data

Each of these functions is documented in detail in the following
sections.
