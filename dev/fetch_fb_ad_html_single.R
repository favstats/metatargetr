# fetch_fb_ad_html_single() ---------------------------------------------------------------------------
#' Fetch a single Facebook Ad-Library page
#'
#' @param ad_id        Character scalar, the Ad Library ID.
#' @param country      Two-letter country code (e.g. "US").
#' @param path         Optional file path.  If supplied, HTML is **gzip-compressed**
#'                     and written there; the function still *returns* the string
#'                     invisibly.  If `NULL` (default) nothing is written.
#' @param strip_css    Logical.  If TRUE run a very fast CSS-removal pass so the
#'                     cached file is smaller and later HTML parsing is lighter.
#' @param ua           User-Agent header.
#' @param timeout_sec  Request timeout.
#' @param retries      How many 5xx / network failures before giving up.
#' @param delay_sec    Mean delay (in seconds) added **before** the request –
#'                     a uniform jitter in [0.5×, 1.5×] · `delay_sec`.
#' @param quiet        Suppress progress messages.
#'
#' @return A character scalar containing the HTML.  If `path` is non-NULL the
#'         string is returned *invisibly* (so you can still capture it while
#'         caching to disk).
#' @export
fetch_fb_ad_html_single <- function(ad_id,
                                    country,
                                    path = NULL,
                                    strip_css = FALSE,
                                    ua = "MetaResearchR/1.1 (+https://example.org)",
                                    timeout_sec = 15,
                                    retries = 3L,
                                    delay_sec = 1,
                                    quiet = FALSE) {
    stopifnot(
        is.character(ad_id) && length(ad_id) == 1,
        grepl("^[A-Za-z]{2}$", country)
    )

    # ---- 1. Be polite ---------------------------------------------------------
    Sys.sleep(runif(1, 0.5 * delay_sec, 1.5 * delay_sec))

    # ---- 2. Build request -----------------------------------------------------
    url <- glue::glue(
        "https://www.facebook.com/ads/library/?",
        "active_status=all&ad_type=all&country={country}",
        "&id={ad_id}&is_targeted_country=false&media_type=all&search_type=page"
    )

    req <- httr2::request(url) |>
        httr2::req_user_agent(ua) |>
        httr2::req_timeout(timeout_sec) |>
        httr2::req_retry(max_tries = retries)

    # --- perform ---------------------------------------------------------------
    resp <- httr2::req_perform(req)

    # ---- 4. Status check ------------------------------------------------------
    if (httr2::resp_status(resp) >= 400) {
        stop("HTTP ", httr2::resp_status(resp), " for ad ID ", ad_id)
    }

    html_raw <- httr2::resp_body_string(resp)

    # ---- 5. Optional CSS strip (≈ 5–10 × faster than re-parse with xml2) ------
    if (strip_css) {
        # quick & dirty: drop <style>…</style> and <link rel=stylesheet …>
        html_raw <- sub("(?s)<style[^>]*>.*?</style>", "", html_raw, perl = TRUE)
        html_raw <- sub("(?is)<link[^>]*?rel=[\"']?stylesheet[\"']?[^>]*>", "", html_raw, perl = TRUE)
    }

    # ---- 6. Optional cache write ---------------------------------------------
    if (!is.null(path)) {
        dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
        con <- gzfile(path, open = "wb")
        writeBin(charToRaw(html_raw), con)
        close(con)
        if (!quiet) message("✔ cached to ", path)
        return(invisible(html_raw))
    } else {
        return(html_raw)
    }
}

fetch_fb_ad_html_single("2279257635801270", country = "AU")
