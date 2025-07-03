#' @title Get and Parse Ad Library Data
#'
#' @description
#' A wrapper function that downloads ad HTMLs for a given set of IDs and
#' a country, parses the data, and returns a final, reordered dataframe.
#'
#' @param ad_ids A character vector of Ad Library IDs.
#' @param country A two-letter country code.
#' @param keep_html A logical flag. If `FALSE` (the default), the cache
#'   directory with the downloaded HTML files will be deleted after parsing.
#'   If `TRUE`, the files will be kept.
#' @param cache_dir The directory to store downloaded HTML files. Defaults to
#'   "html_cache".
#' @param ... Additional arguments to be passed down to `get_ad_html()`
#'   (e.g., `overwrite`, `quiet`, `max_active`).
#'
#' @return A single, reordered dataframe containing the parsed ad data.
#'
get_ads_info <- function(ad_ids, country, keep_html = TRUE, cache_dir = "html_cache", ...) {

    # --- 1. Download Step ---
    # Use your existing get_ad_html function to download the files.
    # It will show progress and handle caching.
    # We force return_type to "paths" because the parser reads from disk.
    cli::cli_h1("Step 1: Downloading HTML Files")
    get_ad_html(
        ad_ids = ad_ids,
        country = country,
        cache_dir = cache_dir,
        return_type = "paths", # Force path return for the parser
        ... # Pass along any other user-defined arguments
    )

    # --- 2. Parsing Step ---
    # Use your existing parse_ad_htmls function to process the downloaded files.
    # It will show its own progress and return the final dataframe.
    cli::cli_h1("Step 2: Parsing HTML and Extracting Data")
    parsed_df <- parse_ad_htmls(html_dir = cache_dir)
    cli::cli_alert_success("Successfully parsed {nrow(parsed_df)} ads.")


    # --- 3. Cleanup Step ---
    # If keep_html is FALSE, delete the cache directory.
    if (!keep_html) {
        cli::cli_h1("Step 3: Cleaning Up")
        tryCatch({
            unlink(cache_dir, recursive = TRUE, force = TRUE)
            cli::cli_alert_info("Cache directory '{.path {cache_dir}}' has been deleted.")
        }, error = function(e) {
            cli::cli_alert_warning("Could not delete cache directory: {e$message}")
        })
    } else {
        cli::cli_alert_info("Keeping HTML files in cache directory: '{.path {cache_dir}}'")
    }

    cli::cli_rule(left = "Process Complete!")

    # --- 4. Return Final Dataframe ---
    return(parsed_df)
}



# get_ads_info(sample(ids, 100), country = "AU",
#             interactive = F, log_failed_ids = "log.txt", overwrite = F, quiet = F) -> hi
