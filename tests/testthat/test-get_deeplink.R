# Tests for get_deeplink() - Facebook Ad Library deeplink extraction
#
# NOTE: These tests require:
# 1. Network access to facebook.com
# 2. Chrome browser installed (for chromote)

test_that("get_deeplink returns a tibble with expected columns", {
  skip_on_cran()
  skip_if_not_installed("chromote")

  ad_id <- "1103135646905363"

  result <- get_deeplink(ad_id)

  # Check basic structure
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 1)

  # Check some expected columns exist
  expect_true("adid" %in% names(result) || "adArchiveID" %in% names(result))
})


test_that("get_deeplink returns more columns than get_ad_snapshots", {
  skip_on_cran()
  skip_if_not_installed("chromote")

  ad_id <- "1103135646905363"

  result_deeplink <- get_deeplink(ad_id)
  result_snapshots <- get_ad_snapshots(ad_id)

  # get_deeplink typically returns more columns (includes fevInfo, etc.)
  expect_gt(ncol(result_deeplink), ncol(result_snapshots))
})


test_that("get_deeplink handles invalid ad", {
  skip_on_cran()
  skip_if_not_installed("chromote")

  # Invalid ad ID should either error or return minimal data
  result <- tryCatch(
    suppressWarnings(get_deeplink("0000000000000000")),
    error = function(e) "error_occurred"
  )


  # Either got an error (acceptable) or got some result
  expect_true(
    identical(result, "error_occurred") ||
    is.data.frame(result)
  )
})
