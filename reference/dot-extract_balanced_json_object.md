# Extract a balanced JSON object starting at a `{` position (internal)

Extract a balanced JSON object starting at a `{` position (internal)

## Usage

``` r
.extract_balanced_json_object(text, start_pos)
```

## Arguments

- text:

  Character string containing JSON text.

- start_pos:

  Integer index (1-based) where the opening brace starts.

## Value

Character JSON object substring, or NULL.
