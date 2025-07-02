strip_css <- function(html_txt) {
  doc <- xml2::read_html(html_txt,
    options = c("RECOVER", "NOERROR", "NOWARNING")
  )
  xml2::xml_remove(xml2::xml_find_all(doc, ".//style"))
  css_xpath <- ".//link[translate(@rel,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='stylesheet']"
  xml2::xml_remove(xml2::xml_find_all(doc, css_xpath))
  as.character(doc)
}


fetch_ad_html <- function(cntry,
                          ad_ids,
                          use_cache = TRUE,
                          overwrite = FALSE,
                          clean_css = TRUE,
                          cache_dir = here::here("data", "html_cache"),
                          return_type = c("list", "files"),
                          delay_sec = 1,
                          ua = "MetaResearchR_1.0",
                          timeout_sec = 15,
                          idle_cores = 2,
                          verbose = TRUE) {
  # ── 1. Input validation ──────────────────────────────────────────────────────
  if (!requireNamespace("checkmate", quietly = TRUE)) stop("Install 'checkmate'")
  checkmate::assert_string(cntry, pattern = "^[A-Za-z]{2}$")
  checkmate::assert_character(ad_ids, min.len = 1, any.missing = FALSE)
  checkmate::assert_flag(use_cache)
  checkmate::assert_flag(overwrite)
  return_type <- match.arg(return_type)
  checkmate::assert_string(cache_dir)
  checkmate::assert_number(delay_sec, lower = 0)
  checkmate::assert_string(ua)
  checkmate::assert_number(timeout_sec, lower = 0)
  checkmate::assert_count(idle_cores, positive = TRUE)
  checkmate::assert_flag(verbose)

  # ── 2. Parallel auto-setup if >10 IDs ──────────────────────────────────────
  if (length(ad_ids) > 10) {
    for (pkg in c("future", "furrr")) {
      if (!requireNamespace(pkg, quietly = TRUE)) {
        stop(sprintf("Install '%s'", pkg))
      }
    }
    cores <- max(1, future::availableCores() - idle_cores)
    future::plan(multisession, workers = cores)
    on.exit(future::plan(sequential), add = TRUE)
    if (verbose) message("→ Running in parallel on ", cores, " workers.")
  }

  # ── 3. Prepare cache paths & skip logic ─────────────────────────────────────
  if (use_cache) fs::dir_create(cache_dir, recurse = TRUE)
  safe_ids <- gsub("[^A-Za-z0-9_\\-]", "_", ad_ids)
  cache_paths <- fs::path(cache_dir, paste0(cntry, "_", safe_ids, ".html"))
  names(cache_paths) <- ad_ids

  if (use_cache && !overwrite) {
    exists <- fs::file_exists(cache_paths)
    ids_skip <- ad_ids[exists]
    ids_proc <- ad_ids[!exists]
  } else {
    ids_skip <- character(0)
    ids_proc <- ad_ids
  }
  if (verbose && length(ids_skip) > 0) {
    message(
      "→ Skipping ", length(ids_skip), " already-cached IDs:",
      "\n   ", paste(cache_paths[ids_skip], collapse = "\n   ")
    )
  }

  # ── 4. Progress handler ─────────────────────────────────────────────────────
  if (!requireNamespace("progressr", quietly = TRUE)) stop("Install 'progressr'")
  p <- progressr::progressor(steps = length(ids_proc))


  # ── 6. Single-ID fetcher (jitter + retry/backoff + cache write) ──────────
  fetch_one <- function(ad_id) {
    Sys.sleep(runif(1, delay_sec * 0.5, delay_sec * 1.5))
    url <- glue::glue(
      "https://www.facebook.com/ads/library/?",
      "active_status=all&ad_type=all&country={cntry}",
      "&id={ad_id}&is_targeted_country=false&media_type=all&search_type=page"
    )
    resp <- httr::RETRY("GET", url,
      httr::user_agent(ua),
      httr::timeout(timeout_sec),
      times      = 3,
      pause_base = 1,
      pause_cap  = 8
    )
    if (httr::http_error(resp)) {
      warning("HTTP error for ID ", ad_id)
      return(NA)
    }
    raw_html <- httr::content(resp, as = "text", encoding = "UTF-8")
    clean <- ifelse(clean_css, strip_css(raw_html), raw_html)

    # only cache if “big enough” to avoid junk files
    cp <- cache_paths[[ad_id]]
    if (use_cache) {
      try(readr::write_file(clean, cp), silent = TRUE)
      if (verbose) message(paste0("   Saved cache: ", cp))
    }

    # return parsed doc or NA
    tryCatch(xml2::read_html(clean),
      error = function(e) {
        warning("Parse error for ID ", ad_id)
        NA
      }
    )
  }

  # ── 7. Dispatch over IDs ────────────────────────────────────────────────────
  if (length(ids_proc) > 0) {
    if (length(ad_ids) > 10) {
      results_proc <- furrr::future_map(
        ids_proc,
        function(id) {
          res <- fetch_one(id)
          p()
          res
        },
        .options = furrr_options(seed = TRUE)
      )
    } else {
      results_proc <- purrr::map(ids_proc, function(id) {
        r <- fetch_one(id)
        p()
        r
      })
    }
    names(results_proc) <- ids_proc
  } else {
    results_proc <- list()
    if (verbose) message("→ Nothing to download.")
  }

  # ── 8. Assemble final output & name it cntry_safeID ───────────────────────
  final <- vector("list", length(ad_ids))
  out_names <- paste0(cntry, "_", safe_ids)
  names(final) <- out_names

  for (i in seq_along(ad_ids)) {
    id <- ad_ids[i]
    if (id %in% ids_proc) {
      val <- results_proc[[id]]
      # if files requested, hand back cache path even on failure
      if (return_type == "files") val <- cache_paths[[id]]
    } else {
      # skipped → read or path
      if (return_type == "files") {
        val <- cache_paths[[id]]
      } else {
        val <- tryCatch(xml2::read_html(cache_paths[[id]]),
          error = function(e) NA
        )
      }
    }
    final[[i]] <- val
  }

  final
}
