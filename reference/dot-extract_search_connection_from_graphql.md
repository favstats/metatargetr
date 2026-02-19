# Extract search_results_connection object from GraphQL response text (internal)

Extract search_results_connection object from GraphQL response text
(internal)

## Usage

``` r
.extract_search_connection_from_graphql(body)
```

## Arguments

- body:

  Character response text from `/api/graphql/`.

## Value

Parsed `search_results_connection` list, or NULL.
