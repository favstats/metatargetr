# Tests for get_ad_snapshots() - Facebook Ad Library scraping with chromote
#
# NOTE: These tests require:
# 1. Network access to facebook.com
# 2. Chrome browser installed (for chromote)
# 3. May be slow (~4-5 seconds per ad due to browser automation)

test_that("get_ad_snapshots returns a tibble with expected columns", {
  skip_on_cran()
  skip_if_not_installed("chromote")

  # Use a known ad ID

  ad_id <- "1103135646905363"

  result <- get_ad_snapshots(ad_id)

  # Check basic structure

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 1)

  # Check required columns exist
  expect_true("id" %in% names(result))
  expect_true("page_name" %in% names(result))
  expect_true("page_id" %in% names(result))
  expect_true("creation_time" %in% names(result))

  # Check id is correctly set
  expect_equal(result$id, ad_id)
})


test_that("get_ad_snapshots handles media columns", {
  skip_on_cran()
  skip_if_not_installed("chromote")

  ad_id <- "1103135646905363"
  result <- get_ad_snapshots(ad_id)

  # These columns should exist (may be NA but should be present)
  expect_true("images" %in% names(result))
  expect_true("videos" %in% names(result))
  expect_true("cards" %in% names(result))
})


test_that("get_ad_snapshots handles invalid ad gracefully", {
  skip_on_cran()
  skip_if_not_installed("chromote")

  # Use a clearly invalid ad ID
  ad_id <- "0000000000000000"

  # Should either return minimal tibble or error
  # (Facebook may show "Ad not found" page which has no snapshot)
  result <- tryCatch(
    suppressWarnings(get_ad_snapshots(ad_id)),
    error = function(e) NULL
  )

  if (!is.null(result)) {
    expect_s3_class(result, "tbl_df")
    expect_true("id" %in% names(result))
  }
  # If NULL, the function errored which is acceptable for invalid ads
})


test_that("get_ad_snapshots respects wait_sec parameter", {
  skip_on_cran()
  skip_if_not_installed("chromote")

  ad_id <- "1103135646905363"

  # Time with default wait
  start_time <- Sys.time()
  result1 <- get_ad_snapshots(ad_id, wait_sec = 2)
  time1 <- as.numeric(Sys.time() - start_time)

  # Should take at least 2 seconds
  expect_gte(time1, 2)
})
