# Regression tests for the August 2026 outage: GitHub added a sha256 digest line
# to release asset rows, which shifted the fixed line offsets the old parser
# relied on. It returned empty filenames instead of erroring, so
# get_targeting_metadata() went quiet for nine days.

fixture <- function(name) {
  xml2::read_html(testthat::test_path("fixtures", name))
}

# The committed fixture is real GitHub markup, digest line included.
with_digest <- function() fixture("expanded_assets.html")

# Same page with the digest text removed, to prove the parser does not depend
# on that line being present.
without_digest <- function() {
  raw <- readLines(testthat::test_path("fixtures", "expanded_assets.html"), warn = FALSE)
  xml2::read_html(gsub("sha256:[a-f0-9]{64}", "", paste(raw, collapse = "\n")))
}

test_that("assets are parsed out of real GitHub markup", {
  out <- parse_release_assets(with_digest())

  # three asset rows plus the two "Source code" rows every release page carries
  expect_equal(nrow(out), 5)
  expect_equal(sum(!is.na(out$filename)), 3)
  expect_true(all(grepl("^\\d{4}-\\d{2}-\\d{2}\\.(rds|zip|parquet)$", na.omit(out$filename))))
  expect_true(all(!is.na(out$file_size[1:3])))
  expect_true(all(!is.na(out$timestamp[1:3])))
})

test_that("the digest line is never mistaken for a filename", {
  out <- parse_release_assets(with_digest())
  expect_false(any(grepl("sha256", out$filename), na.rm = TRUE))
  expect_false(any(grepl("sha256", out$file_size), na.rm = TRUE))
})

test_that("parsing does not depend on the digest line being present", {
  expect_identical(
    parse_release_assets(with_digest()),
    parse_release_assets(without_digest())
  )
})

test_that("Source code rows yield NA filenames so callers drop them", {
  out <- parse_release_assets(with_digest())
  expect_equal(sum(is.na(out$filename)), 2)
})

test_that("a further markup change errors loudly instead of returning nothing", {
  raw <- readLines(testthat::test_path("fixtures", "expanded_assets.html"), warn = FALSE)
  moved <- xml2::read_html(
    gsub("/releases/download/", "/releases/artifact/", paste(raw, collapse = "\n"), fixed = TRUE)
  )
  expect_error(parse_release_assets(moved), "markup has changed")
})

test_that("the guard does not fire on a release that simply has no assets", {
  rows <- rvest::html_elements(with_digest(), ".Box-row")
  source_only <- xml2::read_html(paste0(
    "<div class=\"Box\"><ul>",
    paste(vapply(rows[(length(rows) - 1):length(rows)], as.character, character(1)), collapse = "\n"),
    "</ul></div>"
  ))

  out <- expect_no_error(parse_release_assets(source_only))
  expect_equal(sum(!is.na(out$filename)), 0)
})

test_that("a page with no asset table at all returns an empty tibble", {
  out <- parse_release_assets(xml2::read_html("<html><body></body></html>"))
  expect_equal(nrow(out), 0)
  expect_named(out, c("filename", "file_size", "timestamp"))
})
