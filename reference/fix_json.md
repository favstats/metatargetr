# Parse JSON-formatted strings into named character vectors

Parse JSON-formatted strings into named character vectors

## Usage

``` r
fix_json(include)
```

## Arguments

- include:

  A character vector of JSON-formatted strings

## Value

A list of named character vectors, where each vector represents a parsed
JSON object

## Examples

``` r
if (FALSE) { # \dontrun{
# Parse an example character vector
example_json <- c("{\"city\":\"Berlin\",\"zip_code\":\"12345\"}",
                  "{\"city\":\"Munich\",\"zip_code\":\"67890\"}")
parsed_json <- fix_json(example_json)

# Check the resulting list of named character vectors
parsed_json
} # }
```
