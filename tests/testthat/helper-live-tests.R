skip_if_no_live_tests <- function() {
  run_live <- tolower(Sys.getenv("METATARGETR_RUN_LIVE_TESTS", "false"))
  if (!identical(run_live, "true")) {
    testthat::skip("Live browser/network tests disabled; set METATARGETR_RUN_LIVE_TESTS=true to run.")
  }
}
