#' Resolve Facebook Handles to Ad Library Page IDs
#'
#' Translates Facebook page handles (or profile URLs) into the numeric
#' Ad Library page identifier used as `view_all_page_id` in
#' `https://www.facebook.com/ads/library/` URLs.
#'
#' The function loads each page's **Profile Transparency** tab in a headless
#' browser and extracts the `Page ID` from rendered text.
#'
#' @param handles Character vector of Facebook handles, profile URLs,
#'   profile transparency URLs, Ad Library URLs, or numeric page IDs.
#' @param wait_sec Numeric. Seconds to wait after each page navigation
#'   before extracting content. Default is `8`.
#' @param max_retries Integer. Number of retries per handle when extraction
#'   fails. Default is `1`.
#' @param country Character. Country code used when constructing
#'   `ad_library_url` output (default `"ALL"`).
#' @param quiet Logical. If `TRUE`, suppresses progress messages.
#'
#' @return A tibble with one row per input and columns:
#' \describe{
#'   \item{input}{Original input value.}
#'   \item{handle}{Normalized handle or numeric ID extracted from input.}
#'   \item{page_id}{Resolved Ad Library page ID (same as `view_all_page_id`).}
#'   \item{ad_library_page_id}{Alias of `page_id` for clarity.}
#'   \item{is_running_ads}{Logical/`NA`: whether transparency text indicates
#'   the page is currently running ads.}
#'   \item{transparency_url}{Profile transparency URL used for extraction.}
#'   \item{ad_library_url}{Convenience Ad Library page URL for the resolved ID.}
#'   \item{ok}{Logical success flag for each input.}
#'   \item{error}{Error message when resolution fails.}
#' }
#'
#' @export
#'
#' @examples
#' # Numeric IDs are returned directly (no browser needed)
#' get_ad_library_page_id(c("121264564551002", "106359662726593"))
#'
#' \dontrun{
#' # Resolve from handles / URLs
#' get_ad_library_page_id(c("VVD", "https://www.facebook.com/TeachGoldenApple/"))
#' }
get_ad_library_page_id <- function(handles,
                                   wait_sec = 8,
                                   max_retries = 1,
                                   country = "ALL",
                                   quiet = FALSE) {
    if (missing(handles) || length(handles) == 0) {
        stop("`handles` must contain at least one value.")
    }
    if (!is.numeric(wait_sec) || length(wait_sec) != 1 || is.na(wait_sec) || wait_sec < 0) {
        stop("`wait_sec` must be a single non-negative number.")
    }
    if (!is.numeric(max_retries) || length(max_retries) != 1 || is.na(max_retries) || max_retries < 0) {
        stop("`max_retries` must be a single non-negative number.")
    }

    handles <- as.character(handles)
    max_retries <- as.integer(max_retries)
    country <- toupper(as.character(country)[1])
    if (is.na(country) || !nzchar(country)) country <- "ALL"

    normalized <- vapply(handles, .normalize_facebook_handle, character(1), USE.NAMES = FALSE)
    normalized[!nzchar(normalized)] <- NA_character_

    out <- tibble::tibble(
        input = handles,
        handle = normalized,
        page_id = NA_character_,
        ad_library_page_id = NA_character_,
        is_running_ads = rep(NA, length(handles)),
        transparency_url = NA_character_,
        ad_library_url = NA_character_,
        ok = FALSE,
        error = NA_character_
    )

    invalid_rows <- is.na(out$handle)
    if (any(invalid_rows)) {
        out$error[invalid_rows] <- "Could not parse a Facebook handle from input."
    }

    numeric_rows <- !invalid_rows & grepl("^[0-9]{6,}$", out$handle)
    if (any(numeric_rows)) {
        out$page_id[numeric_rows] <- out$handle[numeric_rows]
        out$ad_library_page_id[numeric_rows] <- out$handle[numeric_rows]
        out$ad_library_url[numeric_rows] <- vapply(
            out$handle[numeric_rows],
            .build_ad_library_page_url,
            character(1),
            country = country
        )
        out$ok[numeric_rows] <- TRUE
        out$error[numeric_rows] <- NA_character_
    }

    pending_rows <- which(!invalid_rows & !numeric_rows)
    if (length(pending_rows) == 0) return(out)

    if (!requireNamespace("chromote", quietly = TRUE)) {
        stop("Package 'chromote' is required for non-numeric handles. Install with: install.packages('chromote')")
    }

    persistent_session <- get_browser_session()
    if (!is.null(persistent_session)) {
        b <- persistent_session
        close_on_exit <- FALSE
        if (!quiet) cli::cli_alert_info("Using active persistent browser session.")
    } else {
        b <- chromote::ChromoteSession$new()
        close_on_exit <- TRUE
    }

    if (close_on_exit) {
        on.exit(b$close(), add = TRUE)
    }

    for (idx in pending_rows) {
        handle_i <- out$handle[[idx]]
        input_i <- out$input[[idx]]
        url_i <- .build_profile_transparency_url(handle_i)
        out$transparency_url[[idx]] <- url_i

        if (!quiet) {
            cli::cli_alert_info("Resolving {.val {input_i}}...")
        }

        resolved <- FALSE
        for (attempt in seq_len(max_retries + 1L)) {
            nav_ok <- tryCatch({
                b$Runtime$evaluate(sprintf("window.location.replace('%s')", url_i))
                TRUE
            }, error = function(e) {
                out$error[[idx]] <<- paste0("Navigation failed: ", e$message)
                FALSE
            })

            if (!nav_ok) break

            Sys.sleep(wait_sec + (attempt - 1L) * 2)
            parsed <- .extract_profile_transparency_data(b)

            pid <- parsed$page_id
            if (!is.na(pid) && nzchar(pid) && grepl("^[0-9]{6,}$", pid)) {
                out$page_id[[idx]] <- pid
                out$ad_library_page_id[[idx]] <- pid
                out$is_running_ads[[idx]] <- parsed$is_running_ads
                out$ad_library_url[[idx]] <- .build_ad_library_page_url(pid, country = country)
                out$ok[[idx]] <- TRUE
                out$error[[idx]] <- NA_character_
                resolved <- TRUE
                break
            }

            html_check <- tryCatch(
                b$Runtime$evaluate("document.documentElement.outerHTML")$result$value,
                error = function(e) ""
            )
            if (is.character(html_check) && grepl("__rd_verify_", html_check, fixed = TRUE)) {
                out$error[[idx]] <- "Facebook JS challenge not completed. Increase `wait_sec` or reuse `browser_session_start()`."
            } else {
                out$error[[idx]] <- "Could not extract Page ID from profile transparency page."
            }
        }

        if (!resolved && is.na(out$error[[idx]])) {
            out$error[[idx]] <- "Could not resolve Page ID."
        }

        if (!quiet) {
            if (resolved) {
                cli::cli_alert_success("Resolved {.val {input_i}} -> {.val {out$page_id[[idx]]}}")
            } else {
                cli::cli_alert_warning("Failed to resolve {.val {input_i}}")
            }
        }
    }

    out
}


#' Normalize a Facebook handle/URL input to a handle or numeric page ID (internal)
#'
#' @param handle Character scalar.
#' @return Character scalar or `NA_character_`.
#' @keywords internal
.normalize_facebook_handle <- function(handle) {
    if (length(handle) == 0 || is.null(handle)) return(NA_character_)
    x <- as.character(handle)[1]
    if (is.na(x)) return(NA_character_)
    x <- trimws(x)
    if (!nzchar(x)) return(NA_character_)

    # Direct Ad Library URL support
    m_view_all <- regexec("(?i)(?:\\?|&)view_all_page_id=([0-9]{6,})", x, perl = TRUE)
    g_view_all <- regmatches(x, m_view_all)[[1]]
    if (length(g_view_all) >= 2) return(g_view_all[2])

    x <- sub("#.*$", "", x)
    x <- sub("^https?://", "", x, ignore.case = TRUE)
    x <- sub("^(www\\.|m\\.)", "", x, ignore.case = TRUE)
    x <- sub("^(?i)facebook\\.com/", "", x, perl = TRUE)

    # profile.php?id=123
    if (grepl("^(?i)profile\\.php", x, perl = TRUE)) {
        m_profile <- regexec("(?i)(?:\\?|&)id=([0-9]{6,})", x, perl = TRUE)
        g_profile <- regmatches(x, m_profile)[[1]]
        if (length(g_profile) >= 2) return(g_profile[2])
    }

    # Remove query string for path-based handles
    x <- sub("\\?.*$", "", x)
    x <- gsub("^/+", "", x)
    x <- gsub("/+$", "", x)
    if (!nzchar(x)) return(NA_character_)

    parts <- strsplit(x, "/", fixed = TRUE)[[1]]
    parts <- parts[nzchar(parts)]
    if (length(parts) == 0) return(NA_character_)

    # pages/<name>/<id>
    if (tolower(parts[1]) == "pages" && length(parts) >= 3 && grepl("^[0-9]{6,}$", parts[3])) {
        return(parts[3])
    }
    # pg/<handle>/...
    if (tolower(parts[1]) == "pg" && length(parts) >= 2) {
        parts <- parts[-1]
    }

    out <- sub("^@", "", parts[1])
    out <- trimws(out)
    if (!nzchar(out)) return(NA_character_)
    out
}


#' Build profile transparency URL from normalized handle (internal)
#'
#' @param handle Character scalar.
#' @return Character scalar URL.
#' @keywords internal
.build_profile_transparency_url <- function(handle) {
    paste0("https://www.facebook.com/", handle, "/about_profile_transparency/")
}


#' Build Ad Library URL from page ID (internal)
#'
#' @param page_id Character page ID.
#' @param country Character country code.
#' @return Character scalar URL.
#' @keywords internal
.build_ad_library_page_url <- function(page_id, country = "ALL") {
    paste0(
        "https://www.facebook.com/ads/library/?",
        "active_status=all&ad_type=all",
        "&country=", utils::URLencode(toupper(country)),
        "&is_targeted_country=false&media_type=all&search_type=page",
        "&view_all_page_id=", utils::URLencode(as.character(page_id))
    )
}


#' Parse rendered profile transparency text (internal)
#'
#' @param text Character scalar (typically `document.body.innerText`).
#' @return List with `page_id` and `is_running_ads`.
#' @keywords internal
.parse_profile_transparency_text <- function(text) {
    if (is.null(text) || length(text) == 0) {
        return(list(page_id = NA_character_, is_running_ads = NA))
    }
    text <- as.character(text)[1]
    if (is.na(text) || !nzchar(text)) {
        return(list(page_id = NA_character_, is_running_ads = NA))
    }

    page_id <- NA_character_

    patterns <- c(
        "(?i)(\\d{6,})\\s*\\n\\s*Page ID",
        "(?i)Page ID\\s*\\n\\s*(\\d{6,})",
        "(?i)Page ID\\s*[:\\-]?\\s*(\\d{6,})"
    )

    for (pat in patterns) {
        m <- regexec(pat, text, perl = TRUE)
        g <- regmatches(text, m)[[1]]
        if (length(g) >= 2 && nzchar(g[2])) {
            page_id <- g[2]
            break
        }
    }

    if (is.na(page_id)) {
        lines <- trimws(strsplit(text, "\n", fixed = TRUE)[[1]])
        label_idx <- which(tolower(lines) == "page id")
        if (length(label_idx) > 0) {
            for (i in label_idx) {
                neighbors <- character(0)
                if (i > 1) neighbors <- c(neighbors, lines[i - 1])
                if (i < length(lines)) neighbors <- c(neighbors, lines[i + 1])
                ids <- unlist(regmatches(neighbors, gregexpr("\\b\\d{6,}\\b", neighbors, perl = TRUE)))
                if (length(ids) > 0) {
                    page_id <- ids[1]
                    break
                }
            }
        }
    }

    if (is.na(page_id)) {
        ids <- unlist(regmatches(text, gregexpr("\\b\\d{10,20}\\b", text, perl = TRUE)))
        if (length(ids) > 0) page_id <- ids[1]
    }

    lower <- tolower(text)
    is_running_ads <- NA
    if (grepl("not currently running ads", lower, fixed = TRUE)) {
        is_running_ads <- FALSE
    } else if (grepl("currently running ads", lower, fixed = TRUE)) {
        is_running_ads <- TRUE
    }

    list(page_id = page_id, is_running_ads = is_running_ads)
}


#' Extract profile transparency data from active browser session (internal)
#'
#' @param b A chromote session object.
#' @return List with `page_id` and `is_running_ads`.
#' @keywords internal
.extract_profile_transparency_data <- function(b) {
    js <- "
        (function() {
            return {
                body_text: (document.body && document.body.innerText) ? document.body.innerText : '',
                page_title: document.title || null,
                page_url: window.location.href || null
            };
        })();
    "

    raw <- tryCatch(
        b$Runtime$evaluate(js, returnByValue = TRUE)$result$value,
        error = function(e) NULL
    )

    if (is.null(raw)) {
        return(list(page_id = NA_character_, is_running_ads = NA))
    }

    parsed <- .parse_profile_transparency_text(raw$body_text)
    parsed$page_title <- if (!is.null(raw$page_title)) as.character(raw$page_title) else NA_character_
    parsed$page_url <- if (!is.null(raw$page_url)) as.character(raw$page_url) else NA_character_
    parsed
}
