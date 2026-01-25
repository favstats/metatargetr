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
#' as browser startup (~2-3 seconds) only happens once.
#'
#' @return Invisibly returns TRUE on success.
#' @export
#'
#' @examples
#' \dontrun{
#' # Start session
#' browser_session_start()
#'
#' # Process multiple ads (each reuses the session)
#' result1 <- get_ad_snapshots("1103135646905363")
#' result2 <- get_ad_snapshots("561403598962843")
#' result3 <- get_ad_snapshots("711082744873817")
#'
#' # Close when done
#' browser_session_close()
#' }
browser_session_start <- function() {
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
        cli::cli_alert_success("Browser session started. It will be reused for all subsequent calls.")
        cli::cli_alert_info("Remember to call {.code browser_session_close()} when done.")
    }, error = function(e) {
        .metatargetr_env$active <- FALSE
        stop("Failed to start browser session: ", e$message)
    })

    invisible(TRUE)
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
    if (!browser_session_active()) {
        cli::cli_alert_info("No active browser session to close.")
        return(invisible(FALSE))
    }

    tryCatch({
        .metatargetr_env$browser$close()
    }, error = function(e) {
        # Ignore errors on close (browser may already be closed)
    })

    .metatargetr_env$browser <- NULL
    .metatargetr_env$active <- FALSE

    cli::cli_alert_success("Browser session closed.")
    invisible(TRUE)
}


#' Check if a persistent browser session is active
#'
#' @return Logical, TRUE if a session is active.
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
    isTRUE(.metatargetr_env$active) && !is.null(.metatargetr_env$browser)
}


#' Get the current browser session (internal)
#'
#' Returns the active browser session, or NULL if none is active.
#' This is used internally by other functions.
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
