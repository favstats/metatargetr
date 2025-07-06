#' Closes a Playwright browser instance
#'
#' @description
#' This function safely closes the browser instance associated with the provided
#' browser object. It's designed to handle cases where the browser may have
#' already been closed, preventing errors.
#'
#' @param browser_df A tibble returned by `browser_launch()`, which contains
#'   the `browser_id` of the instance to be closed.
#'
#' @return Invisibly returns `NULL`. This function is called for its side effect
#'   of closing the browser.
#'
#' @examples
#' \dontrun{
#' # Launch a browser
#' browser <- browser_launch()
#'
#' # ... perform actions with the browser ...
#'
#' # Close the browser instance when done
#' browser_close(browser)
#' }
#'
#' @importFrom glue glue
#' @export
browser_close <- function(browser_df) {
  # Validate that the input is the correct object
  if (!is.data.frame(browser_df) || !"browser_id" %in% names(browser_df)) {
    stop("Input must be the tibble object returned by `browser_launch()`.")
  }

  browser_id <- browser_df$browser_id

  # Construct the Python command to close the browser context
  close_command <- glue::glue("{browser_id}.close()")

  # Execute the command, wrapping it in try() to suppress
  # errors if the browser target has already been closed.
  try(
    playwrightr:::py_run(close_command),
    silent = TRUE
  )

  # Return NULL invisibly, as the function is used for its side effect
  invisible(NULL)
}

# Helper functions for playwrightr
on <- function(page_df, event, lambda_string) {
  the_page_id <- page_df$page_id
  playwrightr:::py_run(glue::glue('{the_page_id}.on("{event}", {lambda_string})'))
  return(page_df)
}
off <- function(page_df, event, lambda_string) {
  the_page_id <- page_df$page_id

  playwrightr:::py_run(glue::glue(
    '{the_page_id}.remove_listener("{event}", {lambda_string})'
  ))
  return(page_df)
}

execute_script <- function (page_df, script) {
  the_page_id <- page_df$page_id

  playwrightr:::py_run(glue("d = {{the_page_id}}.evaluate('{{script}}')"))
}

#' Set up and initialize the playwrightr environment
#'
#' @keywords internal
setup_playwright <- function() {
  if (!require("pacman")) install.packages("pacman")
  pacman::p_load(reticulate, playwrightr, cli)
  cli_h2("Checking Playwright Setup")
  if (!py_module_available("playwright")) {
    cli_alert_info("Python 'playwright' module not found. Installing now...")
    tryCatch({
      py_install("playwright", pip = TRUE)
    }, error = function(e) {
      stop("Failed to install 'playwright' Python module.")
    })
  }
  cli_alert_info("Checking for browser binaries...")
  tryCatch({
    system("playwright install --force")
  }, error = function(e) {
    stop("Failed to install playwright browser binaries.")
  })
  cli_alert_info("Initializing Playwright...")
  tryCatch({
    if (Sys.info()[["sysname"]] == "Darwin") {
      pw_init(use_xvfb = FALSE)
    } else {
      if (!py_module_available("xvfbwrapper")) {
        py_install("xvfbwrapper", pip = TRUE)
      }
      pw_init(use_xvfb = TRUE)
    }
    cli_alert_success("Playwright initialized successfully.")
  }, error = function(e) {
    stop("Playwright initialization failed. Error: ", e$message)
  })
  invisible(TRUE)
}

#' Get Facebook Ad Library Report Data
#'
#' Automates downloading Facebook Ad Library reports for vectors of countries,
#' timeframes, and dates. It uses a robust tryCatch block for each request
#' to ensure cleanup and prevent hanging processes.
#'
#' @param country A character vector of two-letter ISO country codes.
#' @param timeframe A character vector of time windows (e.g., "last_7_days").
#' @param date A character vector of report dates in "YYYY-MM-DD" format.
#'
#' @return A single tibble containing the combined data for all successful requests.
#'
get_ad_report <- function(country, timeframe, date) {

  # --- 1. SETUP ---
  cli_h1("Step 1: Setting up Environment")
  if (!require("pacman")) install.packages("pacman")
  if (!"playwrightr" %in% installed.packages()) remotes::install_github("benjaminguinaudeau/playwrightr")
  if (!"purrr" %in% installed.packages()) install.packages("purrr")


  setup_playwright()

  # --- 2. INITIALIZATION & TEMPLATE CAPTURE ---
  cli_h1("Step 2: Initializing Browser and Capturing API Template")
  browser_df <- browser_launch(headless = TRUE, browser = "firefox")
  on.exit(browser_df %>% browser_close(), add = TRUE)

  page_df <- browser_df # Use the main page from the persistent context
  page_df %>% goto("https://www.facebook.com/ads/library/report")
  Sys.sleep(3)
  try(page_df %>% get_by_test_id("cookie-policy-manage-dialog-accept-button") %>% slice(1) %>% click(), silent = TRUE)

  tmp_post_data_string <- tempfile(fileext = ".txt")
  page_df %>% on("request", glue('lambda request: open("{tmp_post_data_string}", "w").write(request.post_data) if (request.method == "POST" and "graphql" in request.url) else None'))
  page_df %>% get_by_text("Download report") %>% slice(2) %>% click()
  Sys.sleep(4)
  data_string <- readLines(tmp_post_data_string, warn = FALSE) %>% str_squish()
  unlink(tmp_post_data_string)

  if (length(data_string) == 0) {
    cli_alert_danger("Fatal: Could not capture the initial API request data. Cannot proceed.")
    return(NULL)
  }

  # *** FIX: Create a clean template by removing the original variables ***
  data_string_template <- stringr::str_replace(data_string, "&variables=%7B.*?%7D", "")

  tmp_download_link <- tempfile(fileext = ".txt")
  page_df %>% on("console", glue::glue("lambda msg: open('{tmp_download_link}', 'w').write(msg.text)"))

  # --- 3. EXECUTION LOOP ---
  request_grid <- tidyr::expand_grid(country, timeframe, date)
  cli_h1("Step 3: Processing {nrow(request_grid)} Report(s)")

  results <- purrr::map_dfr(split(request_grid, 1:nrow(request_grid)), function(params) {

    # Use standard assignment, not global assignment (<<-)
    current_country <- params$country
    current_timeframe <- params$timeframe
    current_date <- params$date

    cli_h2("Requesting: {current_country} | {current_timeframe} | {current_date}")

    # *** FIX: Use the clean template and append new variables ***
    js_code <- paste0(
      'fetch("https://www.facebook.com/api/graphql/", {"headers": {"accept": "*/*", "content-type": "application/x-www-form-urlencoded"}, "body": "',
      # Use the template here
      data_string_template,
      # Append the new, correct variables for this iteration
      "&variables=%7B%22country%22%3A%22", current_country ,"%22%2C%22reportDS%22%3A%22", current_date ,"%22%2C%22timePreset%22%3A%22", current_timeframe,"%22%7D",
      '", "method": "POST", "mode": "cors", "credentials": "include" }).then(resp => resp.text()).then(data => console.log(data));'
    )

    page_df %>% execute_script(js_code)
    Sys.sleep(5)

    # Read and process download link
    download_url <- readLines(tmp_download_link, warn = FALSE) %>% str_extract("\"https.*?\"") %>% str_remove_all("(^\"|(\"|\\\\)$)")

    if (is.na(download_url) || str_detect(download_url, "facebook.com/help/contact/")) {
      cli_alert_danger("Failed to get a download link for {current_country} on {current_date}. Skipping.")
      return(NULL)
    }

    # --- Data Processing ---
    temp_zip_file <- tempfile(fileext = ".zip")
    download.file(download_url, temp_zip_file, mode = "wb", quiet = TRUE)
    temp_extract_dir <- tempfile()
    unzip(temp_zip_file, exdir = temp_extract_dir)
    csv_path <- dir(temp_extract_dir, pattern = "advertisers.csv", full.names = TRUE, recursive = TRUE)

    if (length(csv_path) == 0) {
      cli_alert_warning("Report ZIP for {current_country} on {current_date} was empty. Skipping.")
      unlink(c(temp_zip_file, temp_extract_dir), recursive = TRUE)
      return(NULL)
    }

    report_data <- vroom(csv_path[1], show_col_types = FALSE) %>%
      clean_names() %>%
      mutate(
        report_date = current_date,
        report_timeframe = current_timeframe,
        report_country = current_country
      )

    unlink(c(temp_zip_file, temp_extract_dir), recursive = TRUE)
    cli_alert_success("Successfully processed report for {current_country} on {current_date}.")

    return(report_data)
  })

  # The page is part of the persistent context and is closed when the browser is closed
  # No need for a separate page_df %>% close_page() call

  cli_h1("All Requests Complete")
  return(results)
}

# debugonce(get_ad_report)
# report_data <- get_ad_report(
#   country = "US",
#   timeframe = "lifelong",
#   date = c("2025-01-20")
# )
#
# report_data <- get_ad_report(
#   country = c("US"),
#   timeframe = "lifelong",
#   date = c("2025-01-20", "2025-06-30")
# )
