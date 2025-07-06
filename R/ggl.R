#' Retrieve Google Ad Spending Data
#'
#' This function queries the Google Ad Library to retrieve information about
#' advertising spending for a specified advertiser. It supports a range of countries
#' and can return either aggregated data or time-based spending data.
#'
#' @param advertiser_id A string representing the unique identifier of the advertiser.
#'   For example "AR14716708051084115969".
#' @param start_date An integer representing the start date for data retrieval
#'   in YYYYMMDD format.  For example 20231029.
#' @param end_date An integer representing the end date for data retrieval
#'   in YYYYMMDD format. For example 20231128.
#' @param cntry A string representing the country code for which the data is to be retrieved.
#'   For example "NL" (Netherlands).
#' @param get_times A boolean indicating whether to return time-based spending data.
#'   If FALSE, returns aggregated data. Default is FALSE.
#'
#' @return A tibble containing advertising spending data. If `get_times` is TRUE,
#'   the function returns a tibble with date-wise spending data. Otherwise, it returns
#'   a tibble with aggregated spending data, including details like currency, number of ads,
#'   ad type breakdown, advertiser details, and other metrics.
#'
#' @examples
#' # Retrieve aggregated spending data for a specific advertiser in the Netherlands
#' spending_data <- ggl_get_spending(advertiser_id = "AR14716708051084115969",
#'                                   start_date = 20231029, end_date = 20231128,
#'                                   cntry = "NL")
#'
#' # Retrieve time-based spending data for the same advertiser and country
#' time_based_data <- ggl_get_spending(advertiser_id = "AR14716708051084115969",
#'                                     start_date = 20231029, end_date = 20231128,
#'                                     cntry = "NL", get_times = TRUE)
#'
#' @export
ggl_get_spending <- function(advertiser_id,
                             start_date = 20231029, end_date = 20231128,
                             cntry = "NL",
                             get_times = F) {

    if(lubridate::is.Date(start_date)|is.character(start_date)){
        start_date <- lubridate::ymd(start_date) %>% stringr::str_remove_all("-") %>% as.numeric()
    }
    if(lubridate::is.Date(end_date)|is.character(end_date)){
        end_date <- lubridate::ymd(end_date) %>% stringr::str_remove_all("-") %>% as.numeric() %>% magrittr::add(1)
    } else if(is.numeric(end_date)){
        end_date <- end_date + 1
    }

    # statsType <- 2
    # advertiser_id = "AR10605432864201768961"
    cntry_dict <- c(NL = "2528", DE = "2276",
                    BE = "2056", AR = "2032",
                    AU = "2036", BR = "2076",
                    CL = "2152", AT = "2040",
                    BG = "2100", HR = "2191",
                    CY = "2196", CZ = "2203",
                    DK = "2208", EE = "2233",
                    FI = "2246", FR = "2250",
                    GR = "2300", HU = "2348",
                    IE = "2372", IT = "2380",
                    LV = "2428", LT = "2440",
                    LU = "2442", MT = "2470",
                    PL = "2616", PT = "2620",
                    RO = "2642", SK = "2703",
                    SI = "2705", ES = "2724",
                    SE = "2752", IN = "2356",
                    IL = "2376", ZA = "2710",
                    TW = "2158", UK = "2826",
                    US = "2826")

    cntry <- cntry_dict[[cntry]]

    # Define the URL
    url <- "https://adstransparency.google.com/anji/_/rpc/StatsService/GetStats?authuser="

    # Define headers
    headers <- c(
        `accept` = "*/*",
        `accept-language` = "en-US,en;q=0.9",
        `content-type` = "application/x-www-form-urlencoded",
        `sec-ch-ua` = "\"Google Chrome\";v=\"119\", \"Chromium\";v=\"119\", \"Not?A_Brand\";v=\"24\"",
        `sec-ch-ua-mobile` = "?0",
        `sec-ch-ua-platform` = "\"Windows\"",
        `sec-fetch-dest` = "empty",
        `sec-fetch-mode` = "cors",
        `sec-fetch-site` = "same-origin",
        `x-framework-xsrf-token` = "",
        `x-same-domain` = "1")


    # Construct the body
    body <- paste0('f.req={"1":{"1":"', advertiser_id,
                   '","6":', start_date,
                   ',"7":', end_date,
                   ',"8":', jsonlite::toJSON(cntry),
                   '},"3":{"1":2}}')

    # Make the POST request
    response <- httr::POST(url, httr::add_headers(.headers = headers), body = body, encode = "form")

    # Extract the content
    res <- httr::content(response, "parsed")

    ress <- res$`1`

    if(length(ress)==0){
        return(tibble::tibble(spend = 0, number_of_ads = 0))
    }

    dat1 <- ress$`1` %>%
        purrr::flatten() %>%
        purrr::flatten() %>%
        purrr::set_names(c("currency", "spend"))

    dat2 <- ress$`2` %>% tibble::as_tibble() %>% purrr::set_names("number_of_ads")




    dat3 <- ress$`3` %>%
        purrr::map(tibble::as_tibble) %>%
        purrr::map_dfc(~{
            if (.x[3] == "3") {
                purrr::set_names(.x, c("text_ad_perc", "text_ad_spend", "text_type"))
            }  else  if (.x[3] == "2") {
                purrr::set_names(.x, c("img_ad_perc", "img_ad_spend", "img_type"))
            } else   if (.x[3] == "1") {
                purrr::set_names(.x, c("vid_ad_perc", "vid_ad_spend", "vid_type"))
            }
        })

    dat4 <-ress$`5`  %>%
        purrr::flatten() %>%
        purrr::flatten() %>%
        purrr::set_names(c("metric", "advertiser_id", "advertiser_name", "cntry"))

    dat5 <-ress$`6`  %>%
        purrr::flatten() %>%
        purrr::flatten() %>%
        purrr::set_names(c("unk1", "unk2", "unk3"))

    timedat <- ress$`7` %>%
        purrr::map_dfr(tibble::as_tibble) %>%
        purrr::set_names(c("perc_spend", "date")) %>%
        dplyr::mutate(total_spend = as.numeric(dat1$spend)) %>%
        dplyr::mutate(spend = total_spend*perc_spend) %>%
        dplyr::mutate(date = lubridate::ymd(date))

    dat6 <-ress$`8`   %>%
        purrr::flatten() %>%
        purrr::flatten() %>%
        purrr::set_names(c("unk4", "unk5"))

    fin <- dat1 %>%
        tibble::as_tibble() %>%
        dplyr::bind_cols(dat2) %>%
        dplyr::bind_cols(dat3) %>%
        dplyr::bind_cols(dat4) %>%
        dplyr::bind_cols(dat5) %>%
        dplyr::bind_cols(dat6)

    if(get_times){
        return(timedat)
    } else {
        return(fin)
    }

}

# library(tidyverse)
# ggl_get_spending(advertiser_id = "AR18091944865565769729", get_times = T) %>%
#     ggplot(aes(date, spend)) +
#     geom_line()
#
# ggl_get_spending(advertiser_id = "AR18091944865565769729", get_times = F)




#' Fetch a Google Ads Transparency Report
#'
#' Downloads the latest Google Political Ads transparency data bundle (a ZIP file),
#' extracts a specific CSV report, reads it into a tibble, and then cleans
#' up the downloaded and extracted files.
#'
#' @description
#' This function automates the process of obtaining data from the Google Ads
#' Transparency report. It targets the main data bundle, which contains several
#' CSV files. The user can specify which file to process using either its full
#' filename or a convenient shorthand. By default, all downloaded files are
#' deleted after the data is read into memory.
#'
#' @details
#' The data bundle contains several files. The user can specify which file to
#' read using a shorthand alias.
#'
#' \strong{Available Reports (Aliases):}
#' \itemize{
#'   \item \strong{`"creatives"` (Default):} `google-political-ads-creative-stats.csv`. The primary and most detailed file. Contains statistics for each ad creative, including advertiser info, targeting details, and spend.
#'   \item \strong{`"advertisers"`:} `google-political-ads-advertiser-stats.csv`. Aggregate statistics for each political advertiser.
#'   \item \strong{`"weekly_spend"`:} `google-political-ads-advertiser-weekly-spend.csv`. Advertiser spending aggregated by week.
#'   \item \strong{`"geo_spend"`:} `google-political-ads-geo-spend.csv`. Overall spending aggregated by geographic location.
#'   \item \strong{`"advertiser_geo_spend"`:} `google-political-ads-advertiser-geo-spend.csv`. Advertiser-specific spending aggregated by US state.
#'   \item \strong{`"declarations"`:} `google-political-ads-advertiser-declared-stats.csv`. Self-declared information from advertisers in certain regions (e.g., California, New Zealand).
#'   \item \strong{`"advertiser_mapping"`:} `advertiser_id_mapping.csv`. A mapping file to reconcile different advertiser identifiers.
#'   \item \strong{`"creative_mapping"`:} `creative_id_mapping.csv`. A mapping file to reconcile different ad creative identifiers.
#'   \item \strong{`"updated_date"`:} `google-political-ads-updated.csv`. A single-entry file indicating the last time the report data was refreshed.
#'   \item \strong{`"campaigns" (Deprecated):`} `google-political-ads-campaign-targeting.csv`. Ad-level targeting is now in the `"creatives"` file.
#'   \item \strong{`"keywords" (Discontinued):`} `google-political-ads-top-keywords-history.csv`. Historical data on top keywords, terminated in Dec 2019.
#' }
#' For more details on the specific fields in each file, please refer to the
#' Google Ads Transparency Report documentation.
#'
#' @param file_to_read A character string specifying which CSV file to read from
#'   the bundle, using either the full filename or a shorthand alias (e.g., `"creatives"`).
#'   Defaults to `"creatives"`.
#' @param keep_file_at A character path to a directory where the selected CSV file
#'   should be saved. If `NULL` (the default), all downloaded and extracted
#'   files are deleted. If a path is provided, the function will save the
#'   specified `file_to_read` to that location.
#' @param quiet A logical value. If `FALSE` (default), the function will print
#'   status messages about downloading and processing.
#'
#' @return A `tibble` (data frame) containing the data from the selected CSV file.
#'
#' @export
#'
#' @importFrom httr2 request req_user_agent req_perform resp_is_error
#' @importFrom readr read_csv
#' @importFrom fs dir_create file_move path_file
#' @importFrom utils unzip
#' @importFrom cli cli_alert_info cli_alert_success cli_alert_danger cli_abort
#'
#' @examples
#' \dontrun{
#'
#' # Fetch the main creative stats report using the default alias
#' creative_stats <- get_ggl_ads()
#'
#' # Fetch the advertiser stats report using its alias
#' advertiser_stats <- get_ggl_ads(file_to_read = "advertisers")
#'
#' # Fetch the advertiser ID mapping file
#' advertiser_map <- get_ggl_ads(file_to_read = "advertiser_mapping")
#'
#' # Fetch the geo spend report using its full filename
#' geo_spend_report <- get_ggl_ads(
#'   file_to_read = "google-political-ads-geo-spend.csv"
#' )
#'
#' # Fetch the main report and save the CSV file to a "data" folder
#' creative_stats_saved <- get_ggl_ads(
#'   file_to_read = "creatives",
#'   keep_file_at = "data/"
#' )
#' }
get_ggl_ads <-  function(file_to_read = "creatives",
                         keep_file_at = NULL,
                         quiet = FALSE) {

    # --- 1. Argument Validation and Mapping ---
    file_map <- c(
        "creatives" = "google-political-ads-creative-stats.csv",
        "advertisers" = "google-political-ads-advertiser-stats.csv",
        "weekly_spend" = "google-political-ads-advertiser-weekly-spend.csv",
        "geo_spend" = "google-political-ads-geo-spend.csv",
        "advertiser_geo_spend" = "google-political-ads-advertiser-geo-spend.csv",
        "declarations" = "google-political-ads-advertiser-declared-stats.csv",
        "advertiser_mapping" = "advertiser_id_mapping.csv",
        "creative_mapping" = "creative_id_mapping.csv",
        "updated_date" = "google-political-ads-updated.csv",
        "campaigns" = "google-political-ads-campaign-targeting.csv",
        "keywords" = "google-political-ads-top-keywords-history.csv"
    )

    # Resolve user input to a full filename
    if (file_to_read %in% names(file_map)) {
        # User provided a valid alias
        target_filename <- file_map[file_to_read]
    } else if (file_to_read %in% unname(file_map)) {
        # User provided a valid full filename
        target_filename <- file_to_read
    } else {
        # Invalid input
        cli::cli_abort(
            c("x" = "Invalid {.arg file_to_read} specified: {.val {file_to_read}}",
              "i" = "Please use one of the following aliases:",
              "*" = "{.val {names(file_map)}}",
              "i" = "Or provide a full, valid filename.")
        )
    }


    # --- 2. Setup Temporary Environment ---
    # Use a temporary directory to ensure all files are isolated and easily cleaned up
    temp_dir <- tempfile(pattern = "google_ads_")
    fs::dir_create(temp_dir)
    # Ensure the temporary directory is deleted when the function exits,
    # regardless of whether it succeeds or fails.
    on.exit(unlink(temp_dir, recursive = TRUE, force = TRUE), add = TRUE)

    zip_url <- "https://storage.googleapis.com/political-csv/google-political-ads-transparency-bundle.zip"
    zip_path <- file.path(temp_dir, "google-political-ads-transparency-bundle.zip")

    # --- 3. Download the Data Bundle ---
    if (!quiet) cli::cli_alert_info("Downloading data bundle from Google... (This may take a moment)")

    req <- httr2::request(zip_url) |>
        httr2::req_user_agent("metatargetr R package (https://github.com/favstats/metatargetr)")

    resp <- try(httr2::req_perform(req, path = zip_path), silent = TRUE)

    if (inherits(resp, "try-error") || httr2::resp_is_error(resp)) {
        cli::cli_abort("Failed to download the data bundle from Google. Please check your internet connection or the URL: {.url {zip_url}}")
    }

    if (!quiet) cli::cli_alert_success("Download complete. Extracting files...")

    # --- 4. Extract and Read the Specified File ---
    tryCatch({
        utils::unzip(zip_path, exdir = temp_dir)
    }, error = function(e) {
        cli::cli_abort("Failed to unzip the downloaded file. It may be corrupt.")
    })

    target_csv_path <- file.path(temp_dir, target_filename)

    if (!file.exists(target_csv_path)) {
        extracted <- list.files(temp_dir, pattern = "\\.csv$")
        cli::cli_abort(
            c("x" = "The specified file {.file {target_filename}} was not found in the downloaded bundle.",
              "i" = "Available CSV files are: {.file {extracted}}")
        )
    }

    if (!quiet) cli::cli_alert_info("Reading data from {.file {target_filename}}...")

    # Read the CSV into memory
    report_data <- readr::read_csv(target_csv_path, show_col_types = FALSE, progress = !quiet)

    # --- 5. Handle File Persistence ---
    if (!is.null(keep_file_at)) {
        # If the user wants to keep the file, move it from the temp dir to their path
        if (!is.character(keep_file_at) || length(keep_file_at) != 1) {
            cli::cli_warn("{.arg keep_file_at} must be a single directory path. Skipping file save.")
        } else {
            fs::dir_create(keep_file_at)
            final_path <- file.path(keep_file_at, fs::path_file(target_csv_path))
            fs::file_move(target_csv_path, final_path)
            if (!quiet) cli::cli_alert_success("CSV file saved to {.path {final_path}}")
        }
    }

    if (!quiet) cli::cli_alert_success("Processing complete.")

    # The on.exit() call will handle cleanup of the temp_dir automatically
    return(report_data)
}

# get_ggl_ads("google-political-ads-creative-stats.csv")
