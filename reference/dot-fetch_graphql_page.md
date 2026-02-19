# Fetch page 2+ via GraphQL from browser context (internal)

Fetch page 2+ via GraphQL from browser context (internal)

## Usage

``` r
.fetch_graphql_page(b, pagination_template, cursor)
```

## Arguments

- b:

  A chromote session object.

- pagination_template:

  List returned by
  [`.capture_pagination_template()`](dot-capture_pagination_template.md).

- cursor:

  Character. The pagination cursor.

## Value

A list with `ads` (tibble), `has_next_page`, `end_cursor`, or NULL.
