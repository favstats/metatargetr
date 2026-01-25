# Interactively Set and Save User Settings

Launches an interactive command-line interface to help users configure
and save default package options, such as the cache directory and
user-agent randomization preference.

## Usage

``` r
set_metatargetr_options()
```

## Details

The function will guide the user through setting the following options:

- `metatargetr.cache_dir`: The default directory to save HTML files.

- `metatargetr.randomize_ua`: Whether to use random User-Agents by
  default.

The user will also be prompted to save these settings as environment
variables in their personal `.Renviron` file for persistence across R
sessions.
