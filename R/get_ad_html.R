#' Fetch Facebook Ad-Library pages (with caching)
#'
#' Retrieves HTML content for Facebook Ad Library pages using headless Chrome
#' to bypass JavaScript-based bot detection. Results are cached to disk.
#'
#' @param ad_ids         Character vector of Ad-Library IDs.
#' @param country        Two-letter country code.
#' @param cache_dir      Directory where *.html.gz* files will be stored.
#'                       Defaults to the value set during interactive setup,
#'                       or "html_cache".
#' @param overwrite      If FALSE (default) keep already-cached files.
#' @param strip_css      Run fast regex-based CSS removal on downloaded pages.
#' @param wait_sec       Seconds to wait for each page to load (default 3).
#' @param log_failed_ids If a character path is provided (e.g., "log.txt"),
#'                       failed IDs will be appended to that file.
#' @param quiet          Suppress progress messages.
#' @param return_type    `"paths"` (default) or `"list"` for in-memory strings.
#'
#' @return Either a named character vector of file paths or a named list of
#'         HTML strings, in the *same order* as `ad_ids`.
#' @export
get_ad_html <- function(ad_ids,
                        country,
                        cache_dir = NULL,
                        overwrite = FALSE,
                        strip_css = TRUE,
                        wait_sec = 3,
                        log_failed_ids = NULL,
                        quiet = FALSE,
                        return_type = c("paths", "list")) {

    # Check chromote
    if (!requireNamespace("chromote", quietly = TRUE)) {
        stop("Package 'chromote' is required. Install with: install.packages('chromote')")
    }

    ## 1. Set Defaults from Options -------------------------------------------
    if (is.null(cache_dir)) {
        cache_dir <- getOption("metatargetr.cache_dir", "html_cache")
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
        cli::cli_alert_info("{sum(!need)} already on disk, {length(ids_dl)} to download")
    }

    ## early exit: nothing left to do -----------------------------------------
    if (length(ids_dl) == 0) {
        return(if (return_type == "paths") {
            filepaths
        } else {
            lapply(filepaths, read_gz_char)
        })
    }

    ## 4. Start browser session -----------------------------------------------
    # Check for persistent session, otherwise create a temporary one
    persistent_session <- get_browser_session()
    if (!is.null(persistent_session)) {
        b <- persistent_session
        close_on_exit <- FALSE
        if (!quiet) {
            cli::cli_alert_info("Using persistent browser session...")
        }
    } else {
        if (!quiet) {
            cli::cli_alert_info("Starting browser session...")
        }
        b <- chromote::ChromoteSession$new()
        close_on_exit <- TRUE
    }

    if (close_on_exit) {
        on.exit(b$close(), add = TRUE)
    }

    ## 5. Process each ad -----------------------------------------------------
    html_vec <- character(length(ids_dl))
    failed_ids <- character(0)

    if (!quiet) {
        cli::cli_progress_bar(
            "Fetching ads",
            total = length(ids_dl),
            clear = FALSE
        )
    }

    for (i in seq_along(ids_dl)) {
        current_id <- ids_dl[i]

        url <- glue::glue(
            "https://www.facebook.com/ads/library/?",
            "active_status=all&ad_type=all&country={country}",
            "&id={current_id}&is_targeted_country=false&media_type=all&search_type=page"
        )

        tryCatch({
            b$Page$navigate(url)
            Sys.sleep(wait_sec)

            result <- b$Runtime$evaluate("document.documentElement.outerHTML")
            html_raw <- result$result$value

            # Check if we got blocked
            if (grepl("__rd_verify_", html_raw) && !grepl("snapshot", html_raw)) {
                if (!quiet) cli::cli_alert_warning("JS challenge not passed for {current_id}")
                html_vec[i] <- NA_character_
                failed_ids <- c(failed_ids, current_id)
                if (!quiet) cli::cli_progress_update()
                next
            }

            # Strip CSS if requested
            if (strip_css) {
                html_raw <- gsub("(?is)<style[^>]*>.*?</style>", "", html_raw, perl = TRUE)
                html_raw <- gsub("(?is)<link[^>]*?rel=[\"']?stylesheet[\"']?[^>]*>", "",
                                 html_raw, perl = TRUE)
            }

            # Save to cache
            con <- gzfile(paths_dl[i], "wb")
            writeBin(charToRaw(html_raw), con)
            close(con)

            html_vec[i] <- html_raw

        }, error = function(e) {
            if (!quiet) cli::cli_alert_warning("Error for {current_id}: {e$message}")
            html_vec[i] <<- NA_character_
            failed_ids <<- c(failed_ids, current_id)
        })

        if (!quiet) cli::cli_progress_update()
    }

    ## 6. Assemble results in original order ----------------------------------
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

    ## 7. Final Report and Logging --------------------------------------------
    n_success <- length(ids_dl) - length(failed_ids)
    n_fail <- length(failed_ids)

    if (!quiet) {
        cli::cli_rule(left = "Download Summary")
        cli::cli_alert_success("{n_success} ID(s) processed successfully.")
        if (n_fail > 0) {
            cli::cli_alert_danger("{n_fail} ID(s) failed.")
        }
    }

    # Write to log file if requested
    if (!is.null(log_failed_ids) && length(failed_ids) > 0) {
        tryCatch({
            cat(failed_ids, file = log_failed_ids, append = TRUE, sep = "\n")
            if (!quiet) cli::cli_alert_info("Failed IDs written to {.path {log_failed_ids}}")
        }, error = function(e) {
            if (!quiet) cli::cli_warn("Failed to write log file: {conditionMessage(e)}")
        })
    }

    ## 8. Return --------------------------------------------------------------
    if (return_type == "paths") {
        return(unlist(out)[ad_ids])
    } else {
        return(out[ad_ids])
    }
}
