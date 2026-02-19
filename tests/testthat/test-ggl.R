test_that("ggl_get_spending returns zeros for empty payload and builds expected body", {
  posted <- list()

  local_mocked_bindings(
    .ggl_post = function(url, headers, body) {
      posted <<- list(url = url, headers = headers, body = body)
      structure(list(), class = "mock_resp")
    },
    .ggl_content = function(response) {
      list(`1` = list())
    },
    .package = "metatargetr"
  )

  out <- ggl_get_spending(
    advertiser_id = "AR_TEST_1",
    start_date = as.Date("2024-01-01"),
    end_date = as.Date("2024-01-31"),
    cntry = "US"
  )

  expect_equal(out, tibble::tibble(spend = 0, number_of_ads = 0))
  expect_match(posted$url, "StatsService/GetStats")
  expect_match(posted$body, '"6":20240101')
  expect_match(posted$body, '"7":20240201')
  expect_match(posted$body, '"8":"2840"')
})


test_that("ggl_get_spending parses aggregate and time-series data", {
  payload <- list(
    `1` = list("EUR", "100"),
    `2` = list("10"),
    `3` = list(
      list("0.5", "50", "3"),
      list("0.3", "30", "2"),
      list("0.2", "20", "1")
    ),
    `5` = list("metric", "AR123", "Demo Advertiser", "NL"),
    `6` = list("u1", "u2", "u3"),
    `7` = list(
      list("0.6", "20240101"),
      list("0.4", "20240102")
    ),
    `8` = list("u4", "u5")
  )

  local_mocked_bindings(
    .ggl_post = function(url, headers, body) {
      structure(list(), class = "mock_resp")
    },
    .ggl_content = function(response) {
      list(`1` = payload)
    },
    .package = "metatargetr"
  )

  aggregate <- ggl_get_spending(
    advertiser_id = "AR123",
    start_date = 20240101,
    end_date = 20240131,
    cntry = "NL",
    get_times = FALSE
  )

  expect_equal(aggregate$currency, "EUR")
  expect_equal(aggregate$spend, 100)
  expect_equal(aggregate$number_of_ads, 10)
  expect_equal(aggregate$advertiser_id, "AR123")
  expect_equal(aggregate$text_ad_spend, 50)
  expect_equal(aggregate$img_ad_spend, 30)
  expect_equal(aggregate$vid_ad_spend, 20)

  times <- ggl_get_spending(
    advertiser_id = "AR123",
    start_date = 20240101,
    end_date = 20240131,
    cntry = "NL",
    get_times = TRUE
  )

  expect_equal(times$spend, c(60, 40))
  expect_equal(as.character(times$date), c("2024-01-01", "2024-01-02"))
})


test_that("ggl_get_spending validates country codes", {
  local_mocked_bindings(
    .ggl_post = function(url, headers, body) {
      structure(list(), class = "mock_resp")
    },
    .ggl_content = function(response) {
      list(`1` = list())
    },
    .package = "metatargetr"
  )

  expect_error(
    ggl_get_spending(
      advertiser_id = "AR_TEST_2",
      start_date = 20240101,
      end_date = 20240131,
      cntry = "XX"
    ),
    "Unsupported"
  )
})

test_that("ggl_get_spending accepts lowercase country codes", {
  posted <- list()

  local_mocked_bindings(
    .ggl_post = function(url, headers, body) {
      posted <<- list(body = body)
      structure(list(), class = "mock_resp")
    },
    .ggl_content = function(response) {
      list(`1` = list())
    },
    .package = "metatargetr"
  )

  out <- ggl_get_spending(
    advertiser_id = "AR_TEST_3",
    start_date = 20240101,
    end_date = 20240131,
    cntry = "us"
  )

  expect_equal(out, tibble::tibble(spend = 0, number_of_ads = 0))
  expect_match(posted$body, '"8":"2840"')
})

test_that("ggl_get_spending validates advertiser_id and date inputs", {
  local_mocked_bindings(
    .ggl_post = function(url, headers, body) {
      structure(list(), class = "mock_resp")
    },
    .ggl_content = function(response) {
      list(`1` = list())
    },
    .package = "metatargetr"
  )

  expect_error(
    ggl_get_spending(
      advertiser_id = "",
      start_date = 20240101,
      end_date = 20240131,
      cntry = "NL"
    ),
    "advertiser_id"
  )

  expect_error(
    ggl_get_spending(
      advertiser_id = "AR_TEST_4",
      start_date = "not-a-date",
      end_date = 20240131,
      cntry = "NL"
    ),
    "Invalid"
  )
})


test_that("get_ggl_ads resolves aliases and reads requested CSV", {
  local_mocked_bindings(
    .ggl_download_bundle = function(zip_url, zip_path) {
      writeBin(as.raw(c(0L)), zip_path)
      invisible(TRUE)
    },
    .ggl_unzip_bundle = function(zip_path, temp_dir) {
      writeLines(
        c("col_a,col_b", "1,alpha", "2,beta"),
        file.path(temp_dir, "google-political-ads-creative-stats.csv")
      )
    },
    .package = "metatargetr"
  )

  out <- get_ggl_ads(file_to_read = "creatives", quiet = TRUE)
  expect_s3_class(out, "tbl_df")
  expect_equal(names(out), c("col_a", "col_b"))
  expect_equal(out$col_a, c(1, 2))
  expect_equal(out$col_b, c("alpha", "beta"))
})


test_that("get_ggl_ads saves requested file when keep_file_at is provided", {
  save_dir <- tempfile("ggl_save_")

  local_mocked_bindings(
    .ggl_download_bundle = function(zip_url, zip_path) {
      writeBin(as.raw(c(0L)), zip_path)
      invisible(TRUE)
    },
    .ggl_unzip_bundle = function(zip_path, temp_dir) {
      writeLines(
        c("col_a,col_b", "1,alpha"),
        file.path(temp_dir, "google-political-ads-creative-stats.csv")
      )
    },
    .package = "metatargetr"
  )

  out <- get_ggl_ads(
    file_to_read = "creatives",
    keep_file_at = save_dir,
    quiet = TRUE
  )

  expect_s3_class(out, "tbl_df")
  expect_true(file.exists(file.path(save_dir, "google-political-ads-creative-stats.csv")))

  unlink(save_dir, recursive = TRUE, force = TRUE)
})


test_that("get_ggl_ads errors on invalid file aliases", {
  expect_error(
    get_ggl_ads(file_to_read = "not_a_real_report", quiet = TRUE),
    "Invalid"
  )
})


test_that("get_ggl_ads errors when target CSV is missing from the bundle", {
  local_mocked_bindings(
    .ggl_download_bundle = function(zip_url, zip_path) {
      writeBin(as.raw(c(0L)), zip_path)
      invisible(TRUE)
    },
    .ggl_unzip_bundle = function(zip_path, temp_dir) {
      writeLines(
        c("x,y", "1,2"),
        file.path(temp_dir, "some-other-file.csv")
      )
    },
    .package = "metatargetr"
  )

  expect_error(
    get_ggl_ads(file_to_read = "creatives", quiet = TRUE),
    "was not found"
  )
})


test_that("get_ggl_ads surfaces download failures", {
  local_mocked_bindings(
    .ggl_download_bundle = function(zip_url, zip_path) {
      cli::cli_abort("Failed to download the data bundle from Google")
    },
    .package = "metatargetr"
  )

  expect_error(
    get_ggl_ads(file_to_read = "creatives", quiet = TRUE),
    "Failed to download"
  )
})

test_that("get_ggl_ads validates scalar arguments", {
  expect_error(
    get_ggl_ads(file_to_read = c("creatives", "advertisers"), quiet = TRUE),
    "file_to_read"
  )
  expect_error(
    get_ggl_ads(file_to_read = "creatives", quiet = c(TRUE, FALSE)),
    "quiet"
  )
})
