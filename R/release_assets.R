#' Parse the asset table of a GitHub release "expanded_assets" page
#'
#' Reads the filename, size and upload timestamp out of the DOM rather than out
#' of fixed line offsets in the row text. GitHub added a sha256 digest line to
#' these rows at the end of August 2026, which shifted the offsets this code
#' used to rely on (filename `x[3]`, size `x[6]`, timestamp `x[7]`). The parse
#' then silently returned empty filenames instead of failing, so every lookup
#' of "the latest available release asset" quietly stopped finding one.
#'
#' @param html_content A parsed HTML document, e.g. `xml2::read_html(...)`.
#' @return A tibble with `filename`, `file_size` and `timestamp`. Rows that are
#'   not downloadable assets (the two "Source code" entries) get an `NA`
#'   filename.
#' @noRd
parse_release_assets <- function(html_content) {
  rows <- rvest::html_elements(html_content, ".Box-row")

  if (length(rows) == 0) {
    return(tibble::tibble(
      filename = character(),
      file_size = character(),
      timestamp = character()
    ))
  }

  href <- rows %>%
    rvest::html_element("a[href*='/releases/download/']") %>%
    rvest::html_attr("href")

  # A release page always carries two non-asset "Source code" rows. If there are
  # more rows than that and not one of them is a download link, the selector no
  # longer matches GitHub's markup. Say so, rather than quietly returning
  # nothing and letting callers build a download URL with an empty filename -
  # that silent mode is what turned the August 2026 markup change into a
  # nine-day outage nobody noticed.
  if (length(rows) > 2 && !any(!is.na(href))) {
    stop(
      "Parsed ", length(rows), " release rows but found no download links. ",
      "GitHub's release asset markup has changed; parse_release_assets() needs updating.",
      call. = FALSE
    )
  }

  timestamp <- rows %>%
    rvest::html_element("relative-time") %>%
    rvest::html_attr("datetime")

  file_size <- rows %>%
    rvest::html_text() %>%
    strsplit("\n") %>%
    vapply(function(x) {
      x <- trimws(x)
      hit <- grep("^[0-9.,]+ ?(Bytes|KB|MB|GB|TB)$", x)
      if (length(hit)) x[[hit[[1]]]] else NA_character_
    }, character(1))

  tibble::tibble(
    filename = ifelse(is.na(href), NA_character_, basename(href)),
    file_size = file_size,
    timestamp = timestamp
  )
}
