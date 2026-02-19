# Tests for get_ad_html() - Facebook Ad Library HTML fetching with caching
#
# NOTE: These tests require:
# 1. Network access to facebook.com
# 2. Chrome browser installed (for chromote)

test_that("get_ad_html returns paths by default", {
  skip_on_cran()
  skip_if_no_live_tests()
  skip_if_not_installed("chromote")

  ad_id <- "1103135646905363"
  cache_dir <- tempdir()

  result <- get_ad_html(
    ad_ids = ad_id,
    country = "US",
    cache_dir = cache_dir,
    quiet = TRUE
  )

  # Should return a named character vector
  expect_type(result, "character")
  expect_named(result)
  expect_equal(names(result), ad_id)

  # File should exist
  expect_true(file.exists(result[[1]]))
})


test_that("get_ad_html caching works", {
  skip_on_cran()
  skip_if_no_live_tests()
  skip_if_not_installed("chromote")

  ad_id <- "1103135646905363"
  cache_dir <- file.path(tempdir(), "cache_test")
  unlink(cache_dir, recursive = TRUE)

  # First call - should download
  start1 <- Sys.time()
  result1 <- get_ad_html(
    ad_ids = ad_id,
    country = "US",
    cache_dir = cache_dir,
    quiet = TRUE
  )
  time1 <- as.numeric(Sys.time() - start1)

  # Second call - should use cache (much faster)
  start2 <- Sys.time()
  result2 <- get_ad_html(
    ad_ids = ad_id,
    country = "US",
    cache_dir = cache_dir,
    overwrite = FALSE,
    quiet = TRUE
  )
  time2 <- as.numeric(Sys.time() - start2)

  # Same result (compare as character to avoid fs_path class issues)

  expect_equal(as.character(result1), as.character(result2))

  # Second call should be much faster (cached)
  expect_lt(time2, time1)

  # Cleanup
  unlink(cache_dir, recursive = TRUE)
})


test_that("get_ad_html returns list when return_type='list'", {
  skip_on_cran()
  skip_if_no_live_tests()
  skip_if_not_installed("chromote")

  ad_id <- "1103135646905363"
  cache_dir <- file.path(tempdir(), "list_test")

  result <- get_ad_html(
    ad_ids = ad_id,
    country = "US",
    cache_dir = cache_dir,
    return_type = "list",
    quiet = TRUE
  )

  # Should return a named list
  expect_type(result, "list")
  expect_named(result)

  # Content should be HTML string
  expect_type(result[[1]], "character")
  expect_true(grepl("<html", result[[1]], ignore.case = TRUE))

  # Cleanup
  unlink(cache_dir, recursive = TRUE)
})


test_that("get_ad_html handles multiple ads", {
  skip_on_cran()
  skip_if_no_live_tests()
  skip_if_not_installed("chromote")

  ad_ids <- c("1103135646905363", "561403598962843")
  cache_dir <- file.path(tempdir(), "multi_test")

  result <- get_ad_html(
    ad_ids = ad_ids,
    country = "US",
    cache_dir = cache_dir,
    quiet = TRUE
  )

  # Should return results for both ads
  expect_length(result, 2)
  expect_equal(names(result), ad_ids)

  # Both files should exist
  expect_true(all(file.exists(result)))

  # Cleanup
  unlink(cache_dir, recursive = TRUE)
})


test_that("get_ad_html strip_css removes style tags", {
  skip_on_cran()
  skip_if_no_live_tests()
  skip_if_not_installed("chromote")

  ad_id <- "1103135646905363"

  # With CSS stripping
  result_stripped <- get_ad_html(
    ad_ids = ad_id,
    country = "US",
    cache_dir = file.path(tempdir(), "strip_test"),
    strip_css = TRUE,
    return_type = "list",
    quiet = TRUE
  )

  # Should have minimal/no <style> tags
  style_count <- lengths(regmatches(
    result_stripped[[1]],
    gregexpr("<style", result_stripped[[1]], ignore.case = TRUE)
  ))

  expect_equal(style_count, 0)

  # Cleanup
  unlink(file.path(tempdir(), "strip_test"), recursive = TRUE)
})
