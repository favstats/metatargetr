# Tests for browser session management

test_that("browser_session_active returns FALSE when no session", {
  # Make sure no session is active
  if (browser_session_active()) {
    browser_session_close()
  }

  expect_false(browser_session_active())
})


test_that("browser_session_start and close work", {
  skip_on_cran()
  skip_if_not_installed("chromote")

  # Start session
  browser_session_start()
  expect_true(browser_session_active())

  # Close session
  browser_session_close()
  expect_false(browser_session_active())
})


test_that("persistent session is reused by get_ad_snapshots", {
  skip_on_cran()
  skip_if_not_installed("chromote")

  # Start persistent session
  browser_session_start()

  ad_id <- "1103135646905363"

  # Time first call (should be fast since session already started)
  start1 <- Sys.time()
  result1 <- get_ad_snapshots(ad_id, wait_sec = 2)
  time1 <- as.numeric(Sys.time() - start1)


  # Time second call (should be similar - both reusing session)
  start2 <- Sys.time()
  result2 <- get_ad_snapshots(ad_id, wait_sec = 2)
  time2 <- as.numeric(Sys.time() - start2)

  # Both should have worked
  expect_s3_class(result1, "tbl_df")
  expect_s3_class(result2, "tbl_df")

  # Session should still be active
  expect_true(browser_session_active())

  # Clean up
  browser_session_close()
  expect_false(browser_session_active())
})


test_that("multiple functions can share a session", {
  skip_on_cran()
  skip_if_not_installed("chromote")

  browser_session_start()

  ad_id <- "1103135646905363"

  # Call different functions
  result1 <- get_ad_snapshots(ad_id, wait_sec = 2)
  result2 <- get_deeplink(ad_id, wait_sec = 2)

  expect_s3_class(result1, "tbl_df")
  expect_s3_class(result2, "tbl_df")

  # Session should still be active after both calls
  expect_true(browser_session_active())

  browser_session_close()
})
