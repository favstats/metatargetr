# Browser Session Management
# ==========================
#
# These functions allow users to maintain a persistent browser session
# across multiple calls to get_ad_snapshots(), get_deeplink(), and get_ad_html().
# This improves performance by avoiding browser startup overhead for each call.
#
# Usage:
#   browser_session_start()
#   get_ad_snapshots("id1")  # reuses session
#   get_ad_snapshots("id2")  # reuses session
#   browser_session_close()

# Package-level environment to store the browser session
.metatargetr_env <- new.env(parent = emptyenv())

#' Start a persistent browser session
#'
#' Starts a headless Chrome browser session that will be reused by
#' `get_ad_snapshots()`, `get_deeplink()`, and `get_ad_html()` until
#' `browser_session_close()` is called.
#'
#' This significantly improves performance when processing multiple ads,
#' as browser startup (~2--3 seconds) only happens once. By default the
#' session is warmed up by navigating to the Facebook Ad Library landing
#' page, which passes the JS challenge and sets cookies so that subsequent
#' calls return data immediately.
#'
#' @param warm_up Logical. If TRUE (default), navigates to the Facebook Ad
#'   Library landing page on startup to pass the JS challenge and set cookies.
#' @param warm_up_wait Seconds to wait during warm-up (default 8).
#' @return Invisibly returns TRUE on success.
#' @export
#'
#' @examples
#' \dontrun{
#' # Start session (includes warm-up)
#' browser_session_start()
#'
#' # Process multiple ads (each reuses the session)
#' results <- map_dfr_progress(ad_ids, ~get_ad_snapshots(.x))
#'
#' # Close when done
#' browser_session_close()
#' }
browser_session_start <- function(warm_up = TRUE, warm_up_wait = 8) {
    if (!requireNamespace("chromote", quietly = TRUE)) {
        stop("Package 'chromote' is required. Install with: install.packages('chromote')")
    }

    # Close existing session if any
    if (browser_session_active()) {
        cli::cli_alert_info("Closing existing browser session...")
        browser_session_close()
    }

    cli::cli_alert_info("Starting persistent browser session...")

    tryCatch({
        .metatargetr_env$browser <- chromote::ChromoteSession$new()
        .metatargetr_env$active <- TRUE
    }, error = function(e) {
        .metatargetr_env$active <- FALSE
        stop("Failed to start browser session: ", e$message)
    })

    # Warm up: navigate to FB Ad Library to pass JS challenge and set cookies
    if (warm_up) {
        cli::cli_alert_info("Warming up session (passing Facebook JS challenge)...")
        tryCatch({
            .metatargetr_env$browser$Page$navigate("https://www.facebook.com/ads/library/")
            Sys.sleep(warm_up_wait)
        }, error = function(e) {
            cli::cli_alert_warning("Warm-up navigation failed: {e$message}")
        })
    }

    cli::cli_alert_success("Browser session ready. It will be reused for all subsequent calls.")
    cli::cli_alert_info("Remember to call {.code browser_session_close()} when done.")

    invisible(TRUE)
}

#' Restart the persistent browser session
#'
#' Closes the current session (if any) and starts a fresh one with warm-up.
#' Useful when Chrome has become unresponsive or after errors mid-batch.
#'
#' @inheritParams browser_session_start
#' @return Invisibly returns TRUE on success.
#' @export
#'
#' @examples
#' \dontrun{
#' browser_session_start()
#' # ... Chrome becomes unresponsive ...
#' browser_session_restart()
#' # ... continue working ...
#' browser_session_close()
#' }
browser_session_restart <- function(warm_up = TRUE, warm_up_wait = 8) {
    cli::cli_alert_info("Restarting browser session...")
    browser_session_close()
    browser_session_start(warm_up = warm_up, warm_up_wait = warm_up_wait)
}


#' Close the persistent browser session
#'
#' Closes the browser session started by `browser_session_start()`.
#' After calling this, each function call will start its own browser again.
#'
#' @return Invisibly returns TRUE on success.
#' @export
#'
#' @examples
#' \dontrun{
#' browser_session_start()
#' # ... do work ...
#' browser_session_close()
#' }
browser_session_close <- function() {
    if (!isTRUE(.metatargetr_env$active) && is.null(.metatargetr_env$browser)) {
        cli::cli_alert_info("No active browser session to close.")
        return(invisible(FALSE))
    }

    tryCatch({
        if (!is.null(.metatargetr_env$browser)) {
            .metatargetr_env$browser$close()
        }
    }, error = function(e) {
        # Ignore errors on close (browser may already be closed/crashed)
    })

    .metatargetr_env$browser <- NULL
    .metatargetr_env$active <- FALSE

    cli::cli_alert_success("Browser session closed.")
    invisible(TRUE)
}


#' Check if a persistent browser session is active
#'
#' Verifies both the R-side flag and that Chrome is actually responsive
#' by sending a lightweight evaluation to the browser. If Chrome has
#' crashed or the websocket connection has been lost, the stale session
#' is automatically cleaned up and FALSE is returned.
#'
#' @return Logical, TRUE if a session is active and responsive.
#' @export
#'
#' @examples
#' \dontrun{
#' browser_session_active()  # FALSE
#' browser_session_start()
#' browser_session_active()  # TRUE
#' browser_session_close()
#' browser_session_active()  # FALSE
#' }
browser_session_active <- function() {
    if (!isTRUE(.metatargetr_env$active) || is.null(.metatargetr_env$browser)) {
        return(FALSE)
    }

    # Actually verify Chrome is responsive
    alive <- tryCatch({
        res <- .metatargetr_env$browser$Runtime$evaluate("1+1")
        !is.null(res$result$value)
    }, error = function(e) {
        FALSE
    })

    if (!alive) {
        cli::cli_alert_warning(
            "Chrome process is no longer responsive. Cleaning up stale session."
        )
        .metatargetr_env$browser <- NULL
        .metatargetr_env$active <- FALSE
        return(FALSE)
    }

    TRUE
}


#' Get the current browser session (internal)
#'
#' Returns the active browser session, or NULL if none is active.
#' If a session was previously started but Chrome has crashed, this
#' will detect the crash (via `browser_session_active()`) and return NULL
#' so a fresh session is created by the caller.
#'
#' @return A chromote session object or NULL.
#' @keywords internal
get_browser_session <- function() {
    if (browser_session_active()) {
        return(.metatargetr_env$browser)
    }
    return(NULL)
}


# Clean up on package unload
.onUnload <- function(libpath) {
    if (browser_session_active()) {
        try(browser_session_close(), silent = TRUE)
    }
}
