#' Interactively Set and Save User Settings
#'
#' Launches an interactive command-line interface to help users configure
#' and save default package options, such as the cache directory and
#' user-agent randomization preference.
#'
#' @details
#' The function will guide the user through setting the following options:
#' \itemize{
#'   \item \code{metatargetr.cache_dir}: The default directory to save HTML files.
#'   \item \code{metatargetr.randomize_ua}: Whether to use random User-Agents by default.
#' }
#' The user will also be prompted to save these settings as environment variables
#' in their personal `.Renviron` file for persistence across R sessions.
#'
#' @export
set_metatargetr_options <- function() {
    cli::cli_h1("Configuring settings for {cli::style_bold('metatargetr')}")

    # --- Ask for cache directory ---
    cli::cli_text("{.field First, where should we save downloaded HTML files?}")
    chosen_dir_raw <- readline(prompt = cli::format_inline("Cache directory (press Enter for default: {.path html_cache}): "))
    chosen_dir <- if (identical(chosen_dir_raw, "")) "html_cache" else chosen_dir_raw
    options(metatargetr.cache_dir = chosen_dir)
    cli::cli_alert_success("Cache directory set to: {.path {chosen_dir}}")

    # --- Ask about randomizing user agents ---
    cli::cli_div(theme = list(body = list(`margin-top` = 1))) # Add a blank line
    cli::cli_text("{.field To make scraping more robust, you can randomize the User-Agent for each request.}")
    random_pref <- cli_ask_yes_no("Would you like to enable randomized User-Agents by default?")
    options(metatargetr.randomize_ua = random_pref)
    cli::cli_alert_success("Randomize User-Agents set to: {.val {random_pref}}")

    # --- Ask to save settings permanently ---
    cli::cli_div(theme = list(body = list(`margin-top` = 1)))
    cli::cli_text("{.field These settings apply to your current R session.}")
    save_pref <- cli_ask_yes_no("Do you want to save these settings to your {.path .Renviron} file for future sessions? (recommended)")

    if (save_pref) {
        if (save_pref) {
            set_renv("METATARGETR_CACHE_DIR" = chosen_dir)
            set_renv("METATARGETR_RANDOMIZE_UA" = random_pref)

        }
    }

    # Mark as configured for this session to avoid asking again
    options(metatargetr.configured = TRUE)
    cli::cli_rule(left = "Configuration complete!")
    invisible()
}
