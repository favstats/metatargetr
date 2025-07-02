# fetch_fb_ad_html_many() ---------------------------------------------------------------------------
#' Fetch many Facebook-Ad-Library pages (vectorised, cached, parallel)
#'
#' @param ad_ids       Character vector of Ad-Library IDs.
#' @param country      Two-letter country code.
#' @param cache_dir    Directory where *.html.gz* files will be stored.
#' @param overwrite    If FALSE (default) keep already-cached files.
#' @param strip_css    Run the same fast, regex-based CSS removal as the
#'                     single-ID helper **only on newly-downloaded pages**.
#' @param max_active   Maximum number of concurrent sockets passed to
#'                     `httr2::req_perform_parallel()` (default = 8).
#' @param ua, timeout_sec, retries
#'                     Passed through to the underlying requests.
#' @param quiet        Suppress progress.
#' @param return_type  `"paths"` (default) or `"list"` for in-memory strings.
#'
#' @return Either a named character vector of file paths or a named list of
#'         HTML strings, in the *same order* as `ad_ids`.
#' @export
fetch_fb_ad_html_many <- function(ad_ids,
                                  country,
                                  cache_dir = "html_cache",
                                  overwrite = FALSE,
                                  strip_css = TRUE,
                                  max_active = 8,
                                  ua = "MetaResearchR/1.1 (+https://example.org)",
                                  timeout_sec = 15,
                                  retries = 3L,
                                  quiet = FALSE,
                                  return_type = c("paths", "list")) {
    ## 1. Input checks ------------------------------------------------------
    stopifnot(length(country) == 1, grepl("^[A-Za-z]{2}$", country))
    stopifnot(is.character(ad_ids) && length(ad_ids) > 0)
    return_type <- match.arg(return_type)

    ## 2. Set up cache ------------------------------------------------------
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

    ## 3. Build a vector of httr2 requests ---------------------------------
    build_req <- function(id) {
        url <- glue::glue(
            "https://www.facebook.com/ads/library/?",
            "active_status=all&ad_type=all&country={country}",
            "&id={id}&is_targeted_country=false&media_type=all&search_type=page"
        )
        httr2::request(url) |>
            httr2::req_user_agent(ua) |>
            httr2::req_timeout(timeout_sec) |>
            httr2::req_retry(max_tries = retries)
    }
    reqs <- purrr::map(ids_dl, build_req)

    ## 4. Fire the requests in parallel (C-level curl pool) ----------------
    resps <- httr2::req_perform_parallel(
        reqs,
        on_error = "continue",
        progress = !quiet,
        max_active = max_active # hard cap on open sockets
    ) # :contentReference[oaicite:0]{index=0}

    ## 5. Post-process each response ---------------------------------------
    html_vec <- character(length(ids_dl))
    for (i in seq_along(resps)) {
        resp <- resps[[i]]
        if (inherits(resp, "error") || httr2::resp_status(resp) >= 400) {
            warning("✖ HTTP error for ID ", ids_dl[i])
            html_vec[i] <- NA_character_
            next
        }
        html_raw <- httr2::resp_body_string(resp)

        # very fast regex CSS strip — no xml2 round-trip
        if (strip_css) {
            html_raw <- gsub("(?is)<style[^>]*>.*?</style>", "", html_raw, perl = TRUE)
            html_raw <- gsub("(?is)<link[^>]*?rel=[\"']?stylesheet[\"']?[^>]*>", "",
                             html_raw,
                             perl = TRUE
            )
        }

        # cache as gzip (≈80-90 % smaller on disk) © StackOverflow tip
        con <- gzfile(paths_dl[i], "wb")
        writeBin(charToRaw(html_raw), con) # :contentReference[oaicite:1]{index=1}
        close(con)

        html_vec[i] <- html_raw
        if (!quiet) message("✔ ", ids_dl[i])
    }

    # 6. Assemble results in original order ----------------------------------
    out <- vector("list", length(ad_ids))
    names(out) <- ad_ids

    # fill the entries we just downloaded
    out[ids_dl] <- if (return_type == "paths") paths_dl else html_vec

    # fill the entries that were already on disk
    if (return_type == "paths") {
        out[ad_ids[!need]] <- filepaths[!need]
    } else {
        out[ad_ids[!need]] <- lapply(
            filepaths[!need],
            function(p) readChar(gzfile(p, "rb"), file.info(p)$size)
        )
    }

    # keep original order and return
    if (return_type == "paths") {
        return(unlist(out, use.names = FALSE))
    } else {
        return(out)
    }

}
