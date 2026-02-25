test_that("normalize_facebook_handle supports common input formats", {
  expect_equal(metatargetr:::.normalize_facebook_handle("@VVD"), "VVD")
  expect_equal(
    metatargetr:::.normalize_facebook_handle("https://www.facebook.com/VVD/about_profile_transparency/"),
    "VVD"
  )
  expect_equal(
    metatargetr:::.normalize_facebook_handle("https://www.facebook.com/profile.php?id=121264564551002"),
    "121264564551002"
  )
  expect_equal(
    metatargetr:::.normalize_facebook_handle(
      "https://www.facebook.com/ads/library/?active_status=all&view_all_page_id=121264564551002"
    ),
    "121264564551002"
  )
  expect_true(is.na(metatargetr:::.normalize_facebook_handle("")))
})


test_that("parse_profile_transparency_text extracts page id and ad status", {
  txt_active <- paste(
    "Page transparency",
    "106359662726593",
    "Page ID",
    "This Page is currently running ads.",
    sep = "\n"
  )

  parsed_active <- metatargetr:::.parse_profile_transparency_text(txt_active)
  expect_equal(parsed_active$page_id, "106359662726593")
  expect_true(parsed_active$is_running_ads)

  txt_inactive <- paste(
    "Page transparency",
    "121264564551002",
    "Page ID",
    "This Page is not currently running ads.",
    sep = "\n"
  )

  parsed_inactive <- metatargetr:::.parse_profile_transparency_text(txt_inactive)
  expect_equal(parsed_inactive$page_id, "121264564551002")
  expect_false(parsed_inactive$is_running_ads)
})


test_that("get_ad_library_page_id short-circuits numeric IDs", {
  ids <- c("121264564551002", "106359662726593")
  res <- get_ad_library_page_id(ids, quiet = TRUE)

  expect_equal(res$page_id, ids)
  expect_equal(res$ad_library_page_id, ids)
  expect_true(all(res$ok))
  expect_true(all(is.na(res$error)))
  expect_true(all(grepl("view_all_page_id=", res$ad_library_url, fixed = TRUE)))
})
