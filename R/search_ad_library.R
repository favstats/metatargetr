# Search Ad Library
# =================
#
# Search Facebook's Ad Library by page ID or text query.
# Returns rich ad data including snapshot (creative content), dates,
# spend, categories, impressions, and more — all without an API key.


#' Extract the search_results_connection JSON from the browser (internal)
#'
#' Uses JavaScript to find and extract the full `search_results_connection`
#' object from Facebook's SSR script tags. This contains all ad metadata
#' (dates, spend, categories, impressions) plus the snapshot (creative data).
#'
#' @param b A chromote session object.
#' @return A parsed list from the JSON, or NULL.
#' @keywords internal
.extract_search_results <- function(b) {
    json_str <- tryCatch({
        result <- b$Runtime$evaluate("
            (function() {
                var scripts = document.querySelectorAll('script');
                for (var i = 0; i < scripts.length; i++) {
                    var text = scripts[i].textContent;
                    var idx = text.indexOf('\"search_results_connection\"');
                    if (idx === -1) continue;
                    var start = text.indexOf('{', idx);
                    var depth = 0;
                    for (var j = start; j < text.length; j++) {
                        if (text[j] === '{') depth++;
                        if (text[j] === '}') depth--;
                        if (depth === 0) {
                            return text.substring(start, j + 1);
                        }
                    }
                }
                return null;
            })();
        ")
        result$result$value
    }, error = function(e) NULL)

    if (is.null(json_str)) return(NULL)

    tryCatch(
        jsonlite::fromJSON(json_str, simplifyDataFrame = FALSE),
        error = function(e) {
            cli::cli_alert_warning("Failed to parse search_results JSON: {e$message}")
            NULL
        }
    )
}


#' Convert a collated_result list into a 1-row tibble (internal)
#'
#' Flattens the nested collated_result structure (which contains snapshot
#' data, dates, spend, etc.) into a single tibble row.
#'
#' @param cr A single collated_result list from the SSR.
#' @return A 1-row tibble, or NULL on failure.
#' @keywords internal
.flatten_collated_result <- function(cr) {
    tryCatch({
        # Separate snapshot from metadata
        snap <- cr$snapshot
        cr$snapshot <- NULL

        # Build metadata tibble
        meta <- list()
        meta$ad_archive_id <- cr$ad_archive_id
        meta$id <- cr$ad_archive_id
        meta$collation_id <- cr$collation_id
        meta$collation_count <- cr$collation_count %||% NA_integer_
        meta$library_page_id <- cr$page_id
        meta$library_page_name <- cr$page_name %||% snap$page_name
        meta$is_active <- cr$is_active %||% NA
        meta$categories <- if (!is.null(cr$categories)) paste(cr$categories, collapse = ", ") else NA_character_
        meta$start_date <- if (!is.null(cr$start_date)) as.POSIXct(cr$start_date, origin = "1970-01-01", tz = "UTC") else as.POSIXct(NA)
        meta$end_date <- if (!is.null(cr$end_date)) as.POSIXct(cr$end_date, origin = "1970-01-01", tz = "UTC") else as.POSIXct(NA)
        meta$spend <- cr$spend %||% NA_character_
        meta$currency <- cr$currency %||% NA_character_
        meta$reach_estimate <- cr$reach_estimate %||% NA_character_
        meta$publisher_platform <- if (!is.null(cr$publisher_platform)) paste(cr$publisher_platform, collapse = ", ") else NA_character_
        meta$contains_sensitive_content <- cr$contains_sensitive_content %||% NA
        meta$gated_type <- cr$gated_type %||% NA_character_
        meta$is_aaa_eligible <- cr$is_aaa_eligible %||% NA
        meta$contains_digital_created_media <- cr$contains_digital_created_media %||% NA

        # Impressions (shape varies across responses)
        if (!is.null(cr$impressions_with_index)) {
            imp <- cr$impressions_with_index
            if (is.list(imp)) {
                meta$impressions_lower <- imp$impressions_lower_bound %||% NA_character_
                meta$impressions_upper <- imp$impressions_upper_bound %||% NA_character_
                meta$impressions_text <- imp$impressions_text %||% NA_character_
                meta$impressions_index <- imp$impressions_index %||% NA_integer_

                # Legacy fallback: older structures may store bounds in nested lists.
                if (is.na(meta$impressions_lower) || is.na(meta$impressions_upper)) {
                    first_imp <- imp[[1]]
                    if (is.list(first_imp)) {
                        if (is.na(meta$impressions_lower)) {
                            meta$impressions_lower <- first_imp$lower_bound %||% NA_character_
                        }
                        if (is.na(meta$impressions_upper)) {
                            meta$impressions_upper <- first_imp$upper_bound %||% NA_character_
                        }
                    }
                }
            }
        }

        # Targeted/reached countries
        if (!is.null(cr$targeted_or_reached_countries) && length(cr$targeted_or_reached_countries) > 0) {
            meta$targeted_countries <- paste(cr$targeted_or_reached_countries, collapse = ", ")
        } else {
            meta$targeted_countries <- NA_character_
        }

        # Ad library URL
        meta$ad_library_url <- paste0(
            "https://www.facebook.com/ads/library/?id=", cr$ad_archive_id
        )

        # Now flatten the snapshot
        if (!is.null(snap)) {
            # Unwrap nested text fields: Facebook wraps some fields like
            # body as {"text": "actual text"} instead of plain strings.
            for (text_field in c("body", "link_description")) {
                fval <- snap[[text_field]]
                if (is.list(fval) && !is.null(fval$text)) {
                    snap[[text_field]] <- fval$text
                }
            }

            # Re-serialize and re-parse with default fromJSON settings
            # (simplifyDataFrame = TRUE) to match detectmysnap() behavior.
            # This ensures stupid_conversion() gets the exact same structure
            # as it does when called from get_ad_snapshots().
            snap_json <- jsonlite::toJSON(snap, auto_unbox = TRUE, null = "null")
            snap_reparsed <- jsonlite::fromJSON(snap_json)
            snap_df <- stupid_conversion(snap_reparsed)
            # Normalize complex columns
            snap_df <- .normalize_row(snap_df)
            # Combine meta + snapshot
            meta_df <- tibble::as_tibble(meta)
            result <- dplyr::bind_cols(meta_df, snap_df)
        } else {
            result <- tibble::as_tibble(meta)
        }

        result
    }, error = function(e) {
        # Fallback: return just the basic info
        tryCatch(
            tibble::tibble(
                ad_archive_id = cr$ad_archive_id %||% NA_character_,
                page_name = cr$page_name %||% NA_character_,
                page_id = cr$page_id %||% NA_character_,
                ad_library_url = paste0("https://www.facebook.com/ads/library/?id=",
                                        cr$ad_archive_id %||% "")
            ),
            error = function(e2) NULL
        )
    })
}


#' Extract fb_dtsg token from browser context (internal helper)
#'
#' @param b A chromote session object.
#' @return Character string (the token) or NULL.
#' @keywords internal
.extract_fb_dtsg <- function(b) {
    tryCatch({
        result <- b$Runtime$evaluate("
            (function() {
                var scripts = document.querySelectorAll('script');
                for (var i = 0; i < scripts.length; i++) {
                    var match = scripts[i].textContent.match(
                        /\"DTSGInitialData\".*?\"token\":\"([^\"]+)\"/
                    );
                    if (match) return match[1];
                }
                var input = document.querySelector('input[name=\"fb_dtsg\"]');
                if (input) return input.value;
                return null;
            })();
        ")
        result$result$value
    }, error = function(e) {
        NULL
    })
}


#' Extract GraphQL doc_id for ad library search from SSR (internal helper)
#'
#' @param b A chromote session object.
#' @return Character string (the doc_id) or NULL.
#' @keywords internal
.extract_doc_id <- function(b) {
    tryCatch({
        result <- b$Runtime$evaluate("
            (function() {
                var scripts = document.querySelectorAll('script');
                for (var i = 0; i < scripts.length; i++) {
                    var text = scripts[i].textContent;
                    var match = text.match(
                        /adp_AdLibrary[^\"]*[Pp]reloader[^\"]*\"\\s*,\\s*\"queryID\"\\s*:\\s*\"(\\d{10,25})\"/i
                    );
                    if (match) return match[1];
                    match = text.match(
                        /queryID[\"']?\\s*[:=]\\s*[\"'](\\d{10,25})[\"'][^}]*AdLibrary/i
                    );
                    if (match) return match[1];
                }
                return null;
            })();
        ")
        result$result$value
    }, error = function(e) {
        NULL
    })
}


#' Parse an URL-encoded form body into a named list (internal)
#'
#' @param body Character string (URL-encoded form body).
#' @return Named list of decoded key/value pairs, or NULL.
#' @keywords internal
.parse_form_body_params <- function(body) {
    if (is.null(body) || !nzchar(body)) return(NULL)

    parts <- strsplit(body, "&", fixed = TRUE)[[1]]
    out <- list()
    for (part in parts) {
        kv <- strsplit(part, "=", fixed = TRUE)[[1]]
        key <- utils::URLdecode(kv[1])
        val <- if (length(kv) > 1) {
            utils::URLdecode(paste(kv[-1], collapse = "="))
        } else {
            ""
        }
        out[[key]] <- val
    }
    out
}


#' Encode a named list to an URL-encoded form body (internal)
#'
#' @param params Named list of form fields.
#' @return URL-encoded form body string.
#' @keywords internal
.encode_form_body_params <- function(params) {
    if (length(params) == 0) return("")

    keys <- names(params)
    pairs <- vapply(keys, function(k) {
        v <- params[[k]]
        if (is.null(v)) v <- ""
        paste0(
            utils::URLencode(k, reserved = TRUE),
            "=",
            utils::URLencode(as.character(v), reserved = TRUE)
        )
    }, character(1))
    paste(pairs, collapse = "&")
}


#' Extract a balanced JSON object starting at a `{` position (internal)
#'
#' @param text Character string containing JSON text.
#' @param start_pos Integer index (1-based) where the opening brace starts.
#' @return Character JSON object substring, or NULL.
#' @keywords internal
.extract_balanced_json_object <- function(text, start_pos) {
    if (is.null(text) || !nzchar(text) || is.null(start_pos) || start_pos < 1) {
        return(NULL)
    }

    n <- nchar(text, type = "chars")
    if (start_pos > n || substr(text, start_pos, start_pos) != "{") {
        return(NULL)
    }

    depth <- 0L
    in_string <- FALSE
    escaped <- FALSE

    for (i in start_pos:n) {
        ch <- substr(text, i, i)

        if (in_string) {
            if (escaped) {
                escaped <- FALSE
            } else if (ch == "\\") {
                escaped <- TRUE
            } else if (ch == "\"") {
                in_string <- FALSE
            }
            next
        }

        if (ch == "\"") {
            in_string <- TRUE
        } else if (ch == "{") {
            depth <- depth + 1L
        } else if (ch == "}") {
            depth <- depth - 1L
            if (depth == 0L) {
                return(substr(text, start_pos, i))
            }
        }
    }

    NULL
}


#' Extract search_results_connection object from GraphQL response text (internal)
#'
#' @param body Character response text from `/api/graphql/`.
#' @return Parsed `search_results_connection` list, or NULL.
#' @keywords internal
.extract_search_connection_from_graphql <- function(body) {
    if (is.null(body) || !nzchar(body)) return(NULL)

    matches <- gregexpr('"search_results_connection"\\s*:\\s*\\{', body, perl = TRUE)[[1]]
    if (length(matches) == 0 || matches[1] == -1) return(NULL)

    for (m in matches) {
        segment <- substring(body, m, min(nchar(body), m + 300))
        brace_offset <- regexpr("\\{", segment, perl = TRUE)[1] - 1L
        if (brace_offset < 0) next
        start_pos <- m + brace_offset
        conn_json <- .extract_balanced_json_object(body, start_pos)
        if (is.null(conn_json)) next

        parsed <- tryCatch(
            jsonlite::fromJSON(conn_json, simplifyDataFrame = FALSE),
            error = function(e) NULL
        )
        if (!is.null(parsed) && !is.null(parsed$edges)) return(parsed)
    }

    NULL
}


#' Capture native AdLibrary pagination request template from browser runtime
#'
#' @param b A chromote session object.
#' @param max_scrolls Integer. Max scroll attempts while waiting for capture.
#' @param scroll_wait_sec Numeric. Seconds to wait between scroll attempts.
#' @return A list with `params` and metadata, or NULL.
#' @keywords internal
.capture_pagination_template <- function(b, max_scrolls = 8L, scroll_wait_sec = 2) {
    # Install interceptor once per page; reset captured events for this call.
    b$Runtime$evaluate("
        (function() {
            window.__adlibPagCaps = [];
            if (window.__adlibPagInterceptorInstalled) return true;

            var oopen = XMLHttpRequest.prototype.open;
            var osend = XMLHttpRequest.prototype.send;

            XMLHttpRequest.prototype.open = function(method, url) {
                this.__adlib_url = url || '';
                this.__adlib_method = method || '';
                return oopen.apply(this, arguments);
            };

            XMLHttpRequest.prototype.send = function(body) {
                var bodyStr = '';
                try { bodyStr = body ? body.toString() : ''; } catch (e) {}
                var isPaginationReq =
                    (this.__adlib_url || '').indexOf('graphql') !== -1 &&
                    bodyStr.indexOf('AdLibrarySearchPaginationQuery') !== -1 &&
                    bodyStr.indexOf('doc_id=') !== -1;

                if (isPaginationReq) {
                    var xhr = this;
                    xhr.addEventListener('loadend', function() {
                        window.__adlibPagCaps.push({
                            body: bodyStr,
                            status: xhr.status,
                            url: xhr.__adlib_url || '',
                            ts: Date.now()
                        });
                    });
                }

                return osend.apply(this, arguments);
            };

            window.__adlibPagInterceptorInstalled = true;
            return true;
        })();
    ")

    for (i in seq_len(max_scrolls)) {
        b$Runtime$evaluate("
            window.scrollTo(0, document.body.scrollHeight);
            window.dispatchEvent(new Event('scroll'));
            document.dispatchEvent(new Event('scroll'));
        ")
        Sys.sleep(scroll_wait_sec)
        n_caps <- tryCatch(
            b$Runtime$evaluate("(window.__adlibPagCaps || []).length")$result$value,
            error = function(e) 0L
        )
        if (!is.null(n_caps) && n_caps > 0) break
    }

    caps_json <- tryCatch(
        b$Runtime$evaluate("JSON.stringify(window.__adlibPagCaps || [])")$result$value,
        error = function(e) "[]"
    )
    caps <- tryCatch(jsonlite::fromJSON(caps_json), error = function(e) NULL)

    if (is.null(caps)) return(NULL)

    body <- NULL
    if (is.data.frame(caps) && nrow(caps) > 0 && "body" %in% names(caps)) {
        body <- caps$body[1]
    } else if (is.list(caps) && length(caps) > 0 && !is.null(caps[[1]]$body)) {
        body <- caps[[1]]$body
    }
    if (is.null(body) || !nzchar(body)) return(NULL)

    params <- .parse_form_body_params(body)
    if (is.null(params) || is.null(params$doc_id) || is.null(params$variables)) {
        return(NULL)
    }

    list(
        params = params,
        doc_id = params$doc_id,
        friendly_name = params$fb_api_req_friendly_name %||% NA_character_
    )
}


#' Search the Facebook Ad Library
#'
#' Retrieves ads from the Facebook Ad Library by page ID or text query,
#' **without requiring an API key**. Uses headless Chrome to load the
#' Ad Library search page, which embeds ~30 ads with rich metadata in its
#' server-side rendered HTML.
#'
#' ## Data returned
#'
#' Each ad includes:
#' - **Metadata**: `ad_archive_id`, `page_name`, `page_id`, `categories`
#'   (e.g., `"POLITICAL"`), `is_active`, `start_date`, `end_date`, `spend`,
#'   `currency`, `reach_estimate`, `publisher_platform`, `impressions_lower`,
#'   `impressions_upper`, `targeted_countries`
#' - **Creative (snapshot)**: `body`, `title`, `display_format`, `link_url`,
#'   `cta_text`, `images`, `videos`, `cards`, `page_profile_picture_url`
#' - **Link**: `ad_library_url` — direct URL to the ad in Facebook's Ad Library
#'
#' ## Important notes
#'
#' - Uses `active_status="all"` by default (full history)
#' - Use `active_status="active"` to focus on ads currently running
#' - Each page load yields ~30 ads from the server-side rendered HTML
#' - Pagination beyond page 1 reuses Facebook's own pagination request shape
#'   captured from browser runtime (still experimental)
#' - The `categories` field can identify political ads (`"POLITICAL"`)
#'
#' @param page_id Character. Facebook page ID to search for all ads from
#'   that page (e.g., `"52985377549"` for D66). Use this for targeted
#'   searches of a specific advertiser. Mutually exclusive with `query`.
#' @param query Character. Text search query (e.g., `"Rob Jetten"`,
#'   `"coca-cola"`). Returns ads mentioning the query from any advertiser.
#'   Mutually exclusive with `page_id`.
#' @param country Character. ISO country code filter (default `"ALL"`).
#'   Use `"NL"` for Netherlands, `"US"` for United States, etc.
#' @param ad_type Character. Ad type filter (default `"all"`).
#'   Options: `"all"`, `"political_and_issue_ads"`.
#' @param active_status Character. Delivery status filter (default `"all"`).
#'   Options: `"all"`, `"active"`, `"inactive"`.
#' @param date_min Character or NULL. Minimum start date filter in
#'   `YYYY-MM-DD` format. Maps to `start_date[min]` in the Ad Library URL.
#' @param date_max Character or NULL. Maximum start date filter in
#'   `YYYY-MM-DD` format. Maps to `start_date[max]` in the Ad Library URL.
#' @param media_type Character. Media type filter (default `"all"`).
#'   Common options: `"all"`, `"image"`, `"video"`.
#' @param publisher_platforms Character vector or NULL. Platform filters.
#'   Example: `c("facebook", "instagram")`.
#' @param content_languages Character vector or NULL. Content language filters.
#'   Example: `c("nl", "en")`.
#' @param search_type Character or NULL. Search type override.
#'   Common options: `"keyword_unordered"`, `"keyword_exact_phrase"`, `"page"`.
#'   If `NULL` (default), inferred from `page_id`/`query`.
#' @param sort_mode Character or NULL. Sort mode for `sort_data[mode]`.
#'   Default `"total_impressions"`.
#' @param sort_direction Character or NULL. Sort direction for
#'   `sort_data[direction]`. Default `"desc"`.
#' @param max_pages Integer. Number of pages to fetch, each containing
#'   ~30 ads (default 1). Set higher to paginate (experimental).
#' @param wait_sec Numeric. Seconds to wait for the page to load
#'   (default 12). Increase if getting empty results.
#' @return A tibble with one row per ad. Returns an empty tibble if no
#'   ads are found. See **Data returned** section for column details.
#' @export
#'
#' @examples
#' \dontrun{
#' browser_session_start()
#'
#' # Search by page ID (all D66 ads)
#' d66_ads <- search_ad_library(page_id = "52985377549")
#'
#' # Search by keyword in the Netherlands
#' ads <- search_ad_library(query = "Rob Jetten", country = "NL")
#'
#' # Check which ads are political
#' ads %>% dplyr::filter(categories == "POLITICAL")
#'
#' # Check ad dates and spend
#' ads %>% dplyr::select(page_name, start_date, end_date, spend, categories)
#'
#' browser_session_close()
#' }
search_ad_library <- function(page_id = NULL,
                              query = NULL,
                              country = "ALL",
                              ad_type = "all",
                              active_status = "all",
                              date_min = NULL,
                              date_max = NULL,
                              media_type = "all",
                              publisher_platforms = NULL,
                              content_languages = NULL,
                              search_type = NULL,
                              sort_mode = "total_impressions",
                              sort_direction = "desc",
                              max_pages = 1,
                              wait_sec = 12) {

    if (!requireNamespace("chromote", quietly = TRUE)) {
        stop("Package 'chromote' is required. Install with: install.packages('chromote')")
    }

    if (is.null(page_id) && is.null(query)) {
        stop("Either page_id or query must be provided.")
    }
    if (!is.null(page_id) && !is.null(query)) {
        stop("Provide either page_id or query, not both.")
    }

    active_status <- tolower(active_status)
    if (!active_status %in% c("all", "active", "inactive")) {
        stop("active_status must be one of: 'all', 'active', 'inactive'.")
    }

    # Build URL
    base_url <- "https://www.facebook.com/ads/library/"
    search_type_effective <- search_type %||% if (!is.null(page_id)) "page" else "keyword_unordered"

    param_parts <- c(
        sprintf("active_status=%s", utils::URLencode(active_status)),
        sprintf("ad_type=%s", utils::URLencode(ad_type)),
        sprintf("country=%s", utils::URLencode(toupper(country))),
        sprintf("media_type=%s", utils::URLencode(media_type)),
        sprintf("search_type=%s", utils::URLencode(search_type_effective))
    )

    if (!is.null(sort_mode) && nzchar(sort_mode)) {
        param_parts <- c(
            param_parts,
            sprintf("sort_data[mode]=%s", utils::URLencode(sort_mode))
        )
    }
    if (!is.null(sort_direction) && nzchar(sort_direction)) {
        param_parts <- c(
            param_parts,
            sprintf("sort_data[direction]=%s", utils::URLencode(sort_direction))
        )
    }

    if (!is.null(date_min) && nzchar(date_min)) {
        param_parts <- c(
            param_parts,
            sprintf("start_date[min]=%s", utils::URLencode(date_min))
        )
    }
    if (!is.null(date_max) && nzchar(date_max)) {
        param_parts <- c(
            param_parts,
            sprintf("start_date[max]=%s", utils::URLencode(date_max))
        )
    }

    if (!is.null(publisher_platforms) && length(publisher_platforms) > 0) {
        for (i in seq_along(publisher_platforms)) {
            param_parts <- c(
                param_parts,
                sprintf(
                    "publisher_platforms[%d]=%s",
                    i - 1L,
                    utils::URLencode(as.character(publisher_platforms[[i]]))
                )
            )
        }
    }

    if (!is.null(content_languages) && length(content_languages) > 0) {
        for (i in seq_along(content_languages)) {
            param_parts <- c(
                param_parts,
                sprintf(
                    "content_languages[%d]=%s",
                    i - 1L,
                    utils::URLencode(as.character(content_languages[[i]]))
                )
            )
        }
    }

    if (!is.null(page_id)) {
        param_parts <- c(
            param_parts,
            sprintf("view_all_page_id=%s", utils::URLencode(as.character(page_id)))
        )
    } else {
        param_parts <- c(param_parts, sprintf("q=%s", utils::URLencode(query)))
    }
    url <- paste0(base_url, "?", paste(param_parts, collapse = "&"))

    # Get or create browser session
    persistent_session <- get_browser_session()
    if (!is.null(persistent_session)) {
        b <- persistent_session
        close_on_exit <- FALSE
    } else {
        b <- chromote::ChromoteSession$new()
        close_on_exit <- TRUE
        tryCatch({
            b$Page$navigate("https://www.facebook.com/ads/library/")
            Sys.sleep(wait_sec)
        }, error = function(e) NULL)
    }

    if (close_on_exit) {
        on.exit(b$close(), add = TRUE)
    }

    # Navigate to search page
    cli::cli_alert_info("Loading Ad Library search page...")
    nav_ok <- tryCatch({
        b$Runtime$evaluate(sprintf("window.location.replace('%s')", url))
        TRUE
    }, error = function(e) {
        cli::cli_alert_danger("Browser navigation failed: {e$message}")
        FALSE
    })

    if (!nav_ok) return(tibble::tibble())

    Sys.sleep(wait_sec)

    # Extract the full search_results_connection from SSR
    cli::cli_alert_info("Extracting ad data from page 1...")
    search_results <- .extract_search_results(b)

    if (is.null(search_results)) {
        # Check if we can at least see the HTML
        html_check <- tryCatch(
            b$Runtime$evaluate("document.documentElement.outerHTML")$result$value,
            error = function(e) ""
        )
        if (grepl("No ads match", html_check, fixed = TRUE)) {
            cli::cli_alert_warning("No ads found matching your search criteria.")
        } else if (grepl("__rd_verify_", html_check)) {
            cli::cli_alert_warning(
                "Facebook JS challenge not completed. Try increasing wait_sec."
            )
        } else {
            cli::cli_alert_warning("No ad data found in page SSR.")
        }
        return(tibble::tibble())
    }

    total_count <- search_results$count %||% NA
    if (!is.na(total_count)) {
        cli::cli_alert_info("Total ads available: {total_count}")
    }

    # Process edges -> nodes -> collated_results
    edges <- search_results$edges %||% list()
    page_info <- search_results$page_info %||% list()

    # Detect rate limiting: count > 0 but edges are empty
    if (length(edges) == 0 && !is.na(total_count) && total_count > 0) {
        cli::cli_alert_danger(paste0(
            "Facebook returned count={total_count} but 0 ads. ",
            "This usually means your IP is rate-limited (error 1675004). ",
            "Try: (1) wait a few hours, (2) use a VPN/different IP, ",
            "(3) use a different Facebook account."
        ))
        return(tibble::tibble())
    }

    rows <- list()
    for (edge in edges) {
        node <- edge$node
        if (is.null(node)) next
        crs <- node$collated_results %||% list()
        for (cr in crs) {
            row <- .flatten_collated_result(cr)
            if (!is.null(row) && nrow(row) > 0) {
                rows[[length(rows) + 1]] <- row
            }
        }
    }

    page1_empty <- length(rows) == 0
    if (page1_empty) {
        cli::cli_alert_warning(
            "No ads could be extracted from page 1 SSR. Trying GraphQL pagination fallback."
        )
        all_ads <- tibble::tibble()
    } else {
        # Bind rows with type normalization
        all_ads <- .bind_ad_rows(rows)
        cli::cli_alert_success("Page 1: {nrow(all_ads)} ads extracted.")
    }

    # --- Pagination (pages 2+) ---
    has_next <- isTRUE(page_info$has_next_page)
    cursor <- page_info$end_cursor

    if ((max_pages > 1 || page1_empty) && has_next && !is.null(cursor)) {
        cli::cli_alert_info("Preparing pagination request template from browser runtime...")
        pagination_template <- .capture_pagination_template(b)
        if (is.null(pagination_template)) {
            cli::cli_alert_warning(
                "Could not capture pagination request template. Returning page 1 only."
            )
            return(all_ads)
        }
        cli::cli_alert_info(
            "Captured pagination request: {pagination_template$friendly_name} (doc_id {pagination_template$doc_id})"
        )

        # If page 1 SSR was empty, treat the first GraphQL fetch as page 1.
        current_page <- if (page1_empty) 0 else 1
        while (current_page < max_pages && !is.null(cursor)) {
            current_page <- current_page + 1
            cli::cli_alert_info("Fetching page {current_page}...")

            page_result <- .fetch_graphql_page(
                b = b,
                pagination_template = pagination_template,
                cursor = cursor
            )

            if (is.null(page_result) || nrow(page_result$ads) == 0) {
                cli::cli_alert_warning(
                    "Pagination stopped at page {current_page}. Returning {nrow(all_ads)} ads."
                )
                break
            }

            cli::cli_alert_success(
                "Page {current_page}: {nrow(page_result$ads)} ads extracted."
            )

            new_ads <- page_result$ads
            if ("ad_archive_id" %in% names(new_ads) && "ad_archive_id" %in% names(all_ads)) {
                new_ads <- dplyr::filter(
                    new_ads,
                    !ad_archive_id %in% all_ads$ad_archive_id
                )
                if (nrow(new_ads) == 0) {
                    cli::cli_alert_warning(
                        "Pagination returned no new ads at page {current_page}; stopping."
                    )
                    break
                }
            }

            all_ads <- .safe_bind_rows(all_ads, new_ads)

            if (!page_result$has_next_page || is.null(page_result$end_cursor)) {
                cli::cli_alert_info("No more pages available.")
                break
            }

            cursor <- page_result$end_cursor
            Sys.sleep(2)
        }
    }

    # Enforce active_status semantics on returned rows.
    # Facebook can occasionally return mixed rows despite the URL filter.
    if ("is_active" %in% names(all_ads)) {
        n_before <- nrow(all_ads)
        if (identical(active_status, "active")) {
            all_ads <- dplyr::filter(all_ads, is_active %in% TRUE)
            if (nrow(all_ads) < n_before) {
                cli::cli_alert_info(
                    "Filtered {n_before - nrow(all_ads)} non-active rows from output."
                )
            }
        } else if (identical(active_status, "inactive")) {
            all_ads <- dplyr::filter(all_ads, is_active %in% FALSE)
            if (nrow(all_ads) < n_before) {
                cli::cli_alert_info(
                    "Filtered {n_before - nrow(all_ads)} active rows from output."
                )
            }
        }
    }

    cli::cli_alert_success("Total: {nrow(all_ads)} ads retrieved.")
    all_ads
}


#' Fetch page 2+ via GraphQL from browser context (internal)
#'
#' @param b A chromote session object.
#' @param pagination_template List returned by `.capture_pagination_template()`.
#' @param cursor Character. The pagination cursor.
#' @return A list with `ads` (tibble), `has_next_page`, `end_cursor`, or NULL.
#' @keywords internal
.fetch_graphql_page <- function(b, pagination_template, cursor) {
    if (is.null(pagination_template) || is.null(pagination_template$params)) {
        cli::cli_alert_warning("Missing pagination request template.")
        return(NULL)
    }

    params <- pagination_template$params
    if (is.null(params$variables)) {
        cli::cli_alert_warning("Pagination template has no variables payload.")
        return(NULL)
    }

    variables <- tryCatch(
        jsonlite::fromJSON(params$variables, simplifyDataFrame = FALSE),
        error = function(e) NULL
    )
    if (is.null(variables)) {
        cli::cli_alert_warning("Could not parse template variables for pagination.")
        return(NULL)
    }

    variables$cursor <- cursor
    params$variables <- jsonlite::toJSON(variables, auto_unbox = TRUE, null = "null")

    # Minor entropy bump to mimic browser request progression.
    if (!is.null(params$`__req`) && nzchar(params$`__req`)) {
        params$`__req` <- as.character(as.hexmode(sample.int(120, 1) + 8))
    }

    form_body <- .encode_form_body_params(params)
    form_body_safe <- jsonlite::toJSON(form_body, auto_unbox = TRUE)

    js_code <- sprintf("
        (async function() {
            try {
                var resp = await fetch('/api/graphql/', {
                    method: 'POST',
                    body: %s,
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    credentials: 'include'
                });
                return await resp.text();
            } catch (e) {
                return JSON.stringify({error: e.message});
            }
        })();
    ", form_body_safe)

    resp <- tryCatch(
        b$Runtime$evaluate(js_code, awaitPromise = TRUE),
        error = function(e) NULL
    )
    if (is.null(resp) || is.null(resp$result$value)) return(NULL)

    body <- resp$result$value

    # Detect rate limiting explicitly
    if (grepl("Rate limit exceeded", body, fixed = TRUE) ||
        grepl("1675004", body, fixed = TRUE)) {
        cli::cli_alert_danger(paste0(
            "Facebook rate limit exceeded (error 1675004). ",
            "Your IP is temporarily blocked from fetching ad data. ",
            "Try: (1) wait a few hours, (2) use a VPN/different IP, ",
            "(3) use a different Facebook account."
        ))
        return(NULL)
    }

    if (grepl('"error"', body, fixed = TRUE) && !grepl("search_results_connection", body, fixed = TRUE)) {
        cli::cli_alert_warning("GraphQL pagination response contains errors and no search connection.")
        return(NULL)
    }

    search_conn <- .extract_search_connection_from_graphql(body)
    if (is.null(search_conn)) {
        cli::cli_alert_warning("Could not locate search_results_connection in pagination response.")
        return(NULL)
    }

    edges <- search_conn$edges %||% list()
    page_info <- search_conn$page_info %||% list()

    rows <- list()
    for (edge in edges) {
        node <- edge$node
        if (is.null(node)) next
        crs <- node$collated_results %||% list()
        for (cr in crs) {
            row <- .flatten_collated_result(cr)
            if (!is.null(row) && nrow(row) > 0) {
                rows[[length(rows) + 1]] <- row
            }
        }
    }

    ads <- if (length(rows) > 0) .bind_ad_rows(rows) else tibble::tibble()
    list(
        ads = ads,
        has_next_page = isTRUE(page_info$has_next_page),
        end_cursor = page_info$end_cursor %||% NULL
    )
}


#' Bind a list of 1-row ad tibbles with type normalization (internal)
#'
#' Handles the common issue where snapshot columns have inconsistent types
#' across different ads (e.g., `page_categories` is character in one ad
#' and list in another, `videos` is a data.frame vs NULL).
#'
#' @param rows A list of 1-row tibbles.
#' @return A combined tibble.
#' @keywords internal
.bind_ad_rows <- function(rows) {
    if (length(rows) == 0) return(tibble::tibble())

    # Detect and fix inconsistent column types
    all_col_names <- unique(unlist(lapply(rows, names)))
    for (col in all_col_names) {
        types <- vapply(rows, function(row) {
            if (col %in% names(row)) class(row[[col]])[1] else NA_character_
        }, character(1))
        types <- types[!is.na(types)]
        if (length(unique(types)) > 1) {
            for (i in seq_along(rows)) {
                if (col %in% names(rows[[i]])) {
                    val <- rows[[i]][[col]]
                    if (!is.list(val)) {
                        rows[[i]][[col]] <- list(val)
                    }
                }
            }
        }
    }

    result <- tryCatch(
        dplyr::bind_rows(rows),
        error = function(e) {
            cli::cli_alert_warning("bind_rows failed ({e$message}), using safe fallback")
            # Fallback: keep only scalar columns
            purrr::map_dfr(rows, function(row) {
                out <- list()
                for (col in names(row)) {
                    val <- row[[col]]
                    if (is.atomic(val) && length(val) == 1) {
                        out[[col]] <- val
                    }
                }
                tibble::as_tibble(out)
            })
        }
    )

    # Simplify list-columns that contain only scalars back to atomic vectors.
    # This happens when some ads have e.g. title = "text" and others title = NA
    # (logical), causing the type-harmonisation above to wrap both in list().
    .simplify_list_columns(result)
}


#' Simplify list-columns that contain only scalar values (internal)
#'
#' After type-harmonisation, columns like `title` or `caption` may become
#' list-columns even though every element is a length-1 atomic value (or NULL).
#' This function detects those and converts them back to character vectors.
#'
#' @param df A tibble.
#' @return The tibble with simplified columns.
#' @keywords internal
.simplify_list_columns <- function(df) {
    for (col in names(df)) {
        vals <- df[[col]]
        if (!is.list(vals)) next

        # Check if every element is a scalar atomic (length 0 or 1) or NULL
        all_scalar <- all(vapply(vals, function(v) {
            is.null(v) || (is.atomic(v) && length(v) <= 1)
        }, logical(1)))

        if (!all_scalar) next

        # Determine the dominant type (ignoring NULLs and NAs)
        types <- vapply(vals, function(v) {
            if (is.null(v) || (is.atomic(v) && length(v) == 1 && is.na(v))) {
                return("na")
            }
            class(v)[1]
        }, character(1))
        real_types <- unique(types[types != "na"])

        if (length(real_types) == 0) {
            # All NULL/NA → character NA column
            df[[col]] <- NA_character_
        } else if (length(real_types) == 1 && real_types == "character") {
            df[[col]] <- vapply(vals, function(v) {
                if (is.null(v)) NA_character_ else as.character(v)
            }, character(1))
        } else if (length(real_types) == 1 && real_types %in% c("numeric", "integer", "double")) {
            df[[col]] <- vapply(vals, function(v) {
                if (is.null(v)) NA_real_ else as.numeric(v)
            }, numeric(1))
        } else if (length(real_types) == 1 && real_types == "logical") {
            df[[col]] <- vapply(vals, function(v) {
                if (is.null(v)) NA else as.logical(v)
            }, logical(1))
        } else {
            # Mixed types → coerce to character
            df[[col]] <- vapply(vals, function(v) {
                if (is.null(v)) NA_character_ else as.character(v)
            }, character(1))
        }
    }
    df
}


#' Normalize a 1-row tibble's complex columns to list-columns (internal)
#'
#' @param row A 1-row tibble.
#' @return The tibble with data.frame columns wrapped as list-columns.
#' @keywords internal
.normalize_row <- function(row) {
    for (col in names(row)) {
        val <- row[[col]]
        if (is.data.frame(val)) {
            row[[col]] <- list(val)
        } else if (is.list(val) && !inherits(val, "AsIs")) {
            if (length(val) == 0) {
                row[[col]] <- list(NULL)
            } else if (length(val) > 1) {
                row[[col]] <- list(val)
            }
        }
    }
    row
}


#' Safely bind two tibbles with potentially mismatched column types (internal)
#'
#' @param df1 First tibble.
#' @param df2 Second tibble.
#' @return Combined tibble.
#' @keywords internal
.safe_bind_rows <- function(df1, df2) {
    if (nrow(df1) == 0) return(df2)
    if (nrow(df2) == 0) return(df1)

    for (col in union(names(df1), names(df2))) {
        if (col %in% names(df1) && col %in% names(df2)) {
            t1 <- class(df1[[col]])[1]
            t2 <- class(df2[[col]])[1]
            if (t1 != t2) {
                if (!is.list(df1[[col]])) df1[[col]] <- as.list(df1[[col]])
                if (!is.list(df2[[col]])) df2[[col]] <- as.list(df2[[col]])
            }
        }
    }

    tryCatch(
        dplyr::bind_rows(df1, df2),
        error = function(e) {
            cli::cli_alert_warning("bind_rows failed: {e$message}")
            dplyr::bind_rows(df1, df2)
        }
    )
}
