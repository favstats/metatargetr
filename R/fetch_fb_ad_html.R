    # fetch_fb_ad_html_many() ---------------------------------------------------------------------------
    #' Fetch many Facebook-Ad-Library pages (vectorised, cached, parallel)
    #'
    #' @param ad_ids         Character vector of Ad-Library IDs.
    #' @param country        Two-letter country code.
    #' @param cache_dir      Directory where *.html.gz* files will be stored.
    #'                       Defaults to the value set during interactive setup,
    #'                       or "html_cache".
    #' @param overwrite      If FALSE (default) keep already-cached files.
    #' @param strip_css      Run the same fast, regex-based CSS removal as the
    #'                       single-ID helper **only on newly-downloaded pages**.
    #' @param max_active     Maximum number of concurrent sockets passed to
    #'                       `httr2::req_perform_parallel()` (default = 8).
    #' @param ua             User-Agent string. If NULL (default), uses a standard
    #'                       or randomized UA based on `randomize_ua`.
    #' @param randomize_ua   Boolean. If TRUE, a random User-Agent is chosen from
    #'                       a predefined list for each request to make it harder
    #'                       to track. Defaults to the value set during
    #'                       interactive setup, or FALSE.
    #' @param log_failed_ids       If a character path is provided (e.g., "log.txt"),
    #'                       a log of failed IDs will be written
    #'                       to that file. Default is NULL (no log file).
    #' @param timeout_sec, retries
    #'                       Passed through to the underlying requests.
    #' @param quiet          Suppress progress messages.
    #' @param return_type    `"paths"` (default) or `"list"` for in-memory strings.
    #' @param interactive    If TRUE, run a one-time interactive setup to configure
    #'                       and save default settings. Default is FALSE.
    #'
    #' @return Either a named character vector of file paths or a named list of
    #'         HTML strings, in the *same order* as `ad_ids`.
    #' @export
    fetch_fb_ad_html <- function(ad_ids,
                                 country,
                                 cache_dir = NULL,
                                 overwrite = FALSE,
                                 strip_css = TRUE,
                                 max_active = 8,
                                 log_failed_ids = NULL,
                                 # Default UA is now handled by options
                                 ua = NULL,
                                 # New arguments start here
                                 randomize_ua = NULL,
                                 interactive = FALSE,
                                 # End new arguments
                                 timeout_sec = 15,
                                 retries = 3L,
                                 quiet = FALSE,
                                 return_type = c("paths", "list")) {

        ## 0. One-time Interactive Setup (using cli) ------------------------------
        # Only runs when interactive = TRUE and settings haven't been configured
        if (interactive && !isTRUE(getOption("metatargetr.configured"))) {



            cli::cli_h1("Welcome! Let's configure your settings.")
            cli::cli_text("This will set session-wide defaults for {.code fetch_fb_ad_html}.")

            # Ask for cache directory, allowing user to skip
            cli::cli_alert_info("You can type {.val skip} at the first prompt to use the default settings.")

            # Construct the prompt manually with cli and readline
            cli::cli_text("{.field First, where should we save the downloaded HTML files?}")
            chosen_dir_raw <- readline(prompt = cli::format_inline("Cache directory (by default: {.path html_cache}): "))

            # Use default if user just presses enter, otherwise use their input
            chosen_dir <- if (identical(chosen_dir_raw, "")) "html_cache" else chosen_dir_raw

            # Check if the user wants to skip
            if (identical(chosen_dir, "skip")) {

                # Set default options
                options(metatargetr.cache_dir = "html_cache")
                options(metatargetr.randomize_ua = FALSE)
                cli::cli_alert_info("Skipping setup and using default settings.")

            } else {

                # Proceed with full configuration
                options(metatargetr.cache_dir = chosen_dir)
                cli::cli_alert_success("Cache directory set to: {.path {chosen_dir}}")

                # Ask about randomizing user agents
                cli::cli_div(theme = list(body = list(`margin-top` = 1))) # Add a blank line
                cli::cli_text("{.field To make scraping more robust, you can randomize the User-Agent for each request.}")
                random_pref <- cli_ask_yes_no("Would you like to enable randomized User-Agents by default?")
                options(metatargetr.randomize_ua = random_pref)
                cli::cli_alert_success("Randomize User-Agents set to: {.val {random_pref}}")

                # Ask to save settings permanently
                cli::cli_div(theme = list(body = list(`margin-top` = 1)))
                cli::cli_text("{.field These settings apply to your current R session.}")
                save_pref <- cli_ask_yes_no("Do you want to save settings to your {.path .Renviron} file for future sessions? (recommended)")

                if (save_pref) {
                    set_renv("METATARGETR_CACHE_DIR" = chosen_dir)
                    set_renv("METATARGETR_RANDOMIZE_UA" = random_pref)

                }

                cli::cli_rule(left = "Configuration complete!")
            }

            # Mark as configured for this session to avoid asking again
            options(metatargetr.configured = TRUE)
        }
        ## 1. Set Defaults from Options -------------------------------------------
        # Use session options if arguments are not provided by the user
        if (is.null(cache_dir)) {
            cache_dir <- getOption("metatargetr.cache_dir", "html_cache")
        }
        if (is.null(randomize_ua)) {
            randomize_ua <- getOption("metatargetr.randomize_ua", FALSE)
        }
        # Default User-Agent if not randomizing and none is provided
        default_ua <- "metatargetr/1.2 (+https://example.org)"
        if (is.null(ua) && !randomize_ua) {
            ua <- default_ua
        }

        ## 2. Input checks --------------------------------------------------------
        stopifnot(length(country) == 1, grepl("^[A-Za-z]{2}$", country))
        stopifnot(is.character(ad_ids) && length(ad_ids) > 0)
        return_type <- match.arg(return_type)


        ## 3. Set up cache --------------------------------------------------------
        fs::dir_create(cache_dir, recurse = TRUE)
        safe_ids <- gsub("[^A-Za-z0-9_\\-]", "_", ad_ids)
        filepaths <- fs::path(cache_dir, sprintf("%s_%s.html.gz", country, safe_ids))
        names(filepaths) <- ad_ids

        need <- !(fs::file_exists(filepaths) & !overwrite)
        ids_dl <- ad_ids[need]
        paths_dl <- filepaths[need]

        if (!quiet) {
            message(
                "✓ ", sum(!need), " already on disk, ",
                length(ids_dl), " to download …"
            )
        }


        ## early exit: nothing left to do -----------------------------------------
        if (length(ids_dl) == 0) {
            return(if (return_type == "paths") {
                filepaths
            } else {
                lapply(filepaths, read_gz_char)
            })
        }

        ## 4. Build a vector of httr2 requests -----------------------------------

        reqs <- ids_dl %>% purrr::map(~build_req(.x, country, randomize_ua, ua, timeout_sec, retries))

        ## 5. Fire the requests in parallel ---------------------------------------
        resps <- httr2::req_perform_parallel(
            reqs,
            on_error = "continue",
            progress = !quiet,
            max_active = max_active
        )



        ## 6. Post-process each response ------------------------------------------
        html_vec <- character(length(ids_dl))

        for (i in seq_along(resps)) {
            # (Inside the for-loop)
            resp <- resps[[i]]
            current_id <- ids_dl[i]

            # Check for a low-level request error first
            if (inherits(resp, "error")) {
                reason <- conditionMessage(resp)
                cli::cli_warn(c("x" = "Request for ID {.val {current_id}} failed.", "!" = "Reason: {reason}"))
                html_vec[i] <- NA_character_
                next
            }

            # If the request succeeded, check for an HTTP error status code
            if (httr2::resp_status(resp) >= 400) {
                reason <- httr2::resp_status_desc(resp)
                cli::cli_warn(c("x" = "HTTP error for ID {.val {current_id}}.", "!" = "Status: {.strong {httr2::resp_status(resp)} {reason}}"))
                html_vec[i] <- NA_character_
                next
        }
            html_raw <- httr2::resp_body_string(resp)

            if (strip_css) {
                html_raw <- gsub("(?is)<style[^>]*>.*?</style>", "", html_raw, perl = TRUE)
                html_raw <- gsub("(?is)<link[^>]*?rel=[\"']?stylesheet[\"']?[^>]*>", "",
                                 html_raw,
                                 perl = TRUE
                )
            }

            con <- gzfile(paths_dl[i], "wb")
            writeBin(charToRaw(html_raw), con)
            close(con)

            html_vec[i] <- html_raw
            # if (!quiet) message("✔ ", ids_dl[i])
        }


        # 7. Assemble results in original order ----------------------------------
        out <- vector("list", length(ad_ids))
        names(out) <- ad_ids

        out[ids_dl] <- if (return_type == "paths") paths_dl else html_vec

        cached_ids <- ad_ids[!need]
        if (length(cached_ids) > 0) {
            if (return_type == "paths") {
                out[cached_ids] <- filepaths[cached_ids]
            } else {
                out[cached_ids] <- lapply(filepaths[cached_ids], read_gz_char)
            }
        }

        # 8. Final Report and Logging ----------------------------------------------

        # Identify final successes and failures from the complete output
        successful_ids <- dir(cache_dir) %>%
            str_remove_all(country) %>%
            str_remove_all(".html.gz|_") %>%
            keep(~.x %in% ad_ids)
        failed_ids <- setdiff(successful_ids, ad_ids)
        n_success <- length(successful_ids)
        n_fail <- length(failed_ids)

        # Display a summary report in the console
        if (!quiet) {
            cli::cli_rule(left = "Download Summary")
            cli::cli_alert_success("{n_success} ID(s) processed successfully.")
            if (n_fail > 0) {
                cli::cli_alert_danger("{n_fail} ID(s) failed.")
            }
        }

        # Write to a log file if a path is provided
        if (!is.null(log_failed_ids) & length(failed_ids) != 0) {
            tryCatch(
                {
                    cat(failed_ids, file = log_failed_ids, append = TRUE, sep = "\n")

                    if (!quiet) cli::cli_alert_info("Failed IDs written to {.path {log_failed_ids}}")
                },
                error = function(e) {
                    if (!quiet) cli::cli_warn("Failed to write log file: {conditionMessage(e)}")
                }
            )
        }

        # 9. return statements

        if (return_type == "paths") {
            # Ensure consistent return type (named char vector) and order
            return(unlist(out)[ad_ids])
        } else {
            # Ensure list is in the correct order
            return(out[ad_ids])
        }
    }

    # ids <- readLines("dev/AU_ids.txt")
    #
    # library(tidyverse)
    # # debugonce(fetch_fb_ad_html)
    #
    # fetch_fb_ad_html(ids[1:5], country = "AU",
    #                  interactive = F, log_failed_ids = "log.txt", overwrite = F) -> hi

