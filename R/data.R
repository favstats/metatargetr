#' Retrieve Targeting Data from GitHub Repository
#'
#' This function retrieves targeting data for a specific country and timeframe
#' from a GitHub repository hosting parquet files. The function uses the `arrow`
#' package to read the parquet file directly from the specified URL.
#'
#' @param the_cntry Character. The ISO country code (e.g., "DE", "US").
#' @param tf Numeric or character. The timeframe in days (e.g., "30" or "LAST_30_DAYS").
#' @param ds Character. A timestamp or identifier used to construct the file path (e.g., "2024-12-25").
#' @return A data frame containing the targeting data from the parquet file.
#' @importFrom arrow read_parquet
#' @export
#'
#' @examples
#' # Example usage
#' latest_data <- get_targeting_db(
#'   the_cntry = "DE",
#'   tf = 30,
#'   ds = "2024-10-25"
#' )
#' print(head(latest_data))
get_targeting_db <- function(the_cntry, tf, ds, remove_nas = T, verbose = F) {
    # Validate inputs
    if (missing(the_cntry) || missing(tf) || missing(ds)) {
        stop("All parameters (`the_cntry`, `tf`, `ds`) are required.")
    }

    # Construct the URL
    url <- paste0(
        "https://github.com/favstats/meta_ad_targeting/releases/download/",
        the_cntry,        # Country code
        "-last_", tf,     # Timeframe in days
        "_days/",         # Fixed URL segment
        ds,               # Date or identifier
        ".parquet"        # File extension
    )

    if(verbose){
        message("Constructed URL: ", url)
    }
    # Attempt to read the parquet file
    tryCatch({
        data <- arrow::read_parquet(url)
        if(verbose){
            message("Data successfully retrieved.")
        }
        if(remove_nas){
            if("no_data" %in% names(data)){
                data <- data %>% dplyr::filter(is.na(no_data))
                if(verbose){
                    message("Missing data successfully removed.")
                }
            }
        }
        return(data)
    }, error = function(e) {
        stop("Failed to retrieve or parse the parquet file. Error: ", e$message)
    })
}

# # Define example parameters
# the_cntry <- "DE"
# tf <- 30
# ds <- "2024-10-25"
#
# # Call the function
# latest_data <- get_targeting_db(the_cntry, tf, ds)
#
# # Inspect the data
# print(head(latest_data))
# library(tidyverse)
# latest_data %>% filter(is.na(no_data))



#' Retrieve Report Data from GitHub Repository
#'
#' This function retrieves a report for a specific country and timeframe
#' from a GitHub repository hosting RDS files. The file is downloaded
#' to a temporary location, read into R, and then deleted.
#'
#' @param the_cntry Character. The ISO country code (e.g., "DE", "US").
#' @param timeframe Character. One of "-yesterday", "-last_7_days", "-last_30_days", "-last_90_days", or "-lifelong".
#' @param file_name Character. The name of the RDS file to download (e.g., "report_2024-12-25.rds").
#' @param verbose Logical. Whether to print messages about the process. Default is `FALSE`.
#' @return A data frame or object read from the RDS file.
#' @export
#'
#' @examples
#' # Example usage
#' report_data <- get_report_db(
#'   the_cntry = "DE",
#'   timeframe = "-last_30_days",
#'   file_name = "report_2024-12-25.rds",
#'   verbose = TRUE
#' )
#' print(head(report_data))
#' Retrieve Report Data from GitHub Repository
#'
#' This function retrieves a report for a specific country and timeframe
#' from a GitHub repository hosting RDS files. The file is downloaded
#' to a temporary location, read into R, and then deleted.
#'
#' @param the_cntry Character. The ISO country code (e.g., "DE", "US").
#' @param timeframe Character or Numeric. Timeframe in days (e.g., "30", "90") or "yesterday" / "lifelong".
#' @param ds Character. A timestamp or identifier used to construct the file name (e.g., "2024-12-25").
#' @param verbose Logical. Whether to print messages about the process. Default is `FALSE`.
#' @return A data frame or object read from the RDS file.
#' @export
#'
#' @examples
#' # Example usage
#' report_data <- get_report_db(
#'   the_cntry = "DE",
#'   timeframe = 30,
#'   ds = "2024-12-25",
#'   verbose = TRUE
#' )
#' print(head(report_data))
get_report_db <- function(the_cntry, timeframe, ds, verbose = FALSE) {
    # Validate inputs
    if (missing(the_cntry) || missing(timeframe) || missing(ds)) {
        stop("All parameters (`the_cntry`, `timeframe`, `ds`) are required.")
    }

    # Construct the timeframe string
    if (is.numeric(timeframe)) {
        tf_string <- paste0("-last_", timeframe, "_days")
    } else if (timeframe %in% c("yesterday", "lifelong")) {
        tf_string <- paste0("-", timeframe)
    } else {
        stop("Invalid `timeframe` value. Must be numeric (e.g., 30, 90) or 'yesterday' / 'lifelong'.")
    }

    # Construct the file name
    file_name <- paste0(ds, ".rds")

    # Construct the URL
    url <- paste0(
        "https://github.com/favstats/meta_ad_reports/releases/download/",
        the_cntry, tf_string, "/",
        file_name
    )

    # Temporary file path
    temp_file <- tempfile(fileext = ".rds")

    if (verbose) {
        message("Constructed URL: ", url)
        message("Downloading to temporary file: ", temp_file)
    }

    # Attempt to download and read the RDS file
    tryCatch({
        download.file(url, destfile = temp_file, mode = "wb")
        if (verbose) {
            message("File successfully downloaded.")
        }

        # Read the RDS file
        data <- readRDS(temp_file)
        if (verbose) {
            message("Data successfully read from the RDS file.")
        }

        # Return the data
        return(data)
    }, error = function(e) {
        stop("Failed to retrieve or parse the RDS file. Error: ", e$message)
    }, finally = {
        # Ensure the temporary file is deleted
        if (file.exists(temp_file)) {
            file.remove(temp_file)
            if (verbose) {
                message("Temporary file deleted.")
            }
        }
    })
}


# report_data <- get_report_db(
#   the_cntry = "DE",
#   timeframe = 7,
#   ds = "2024-10-25",
#   verbose = TRUE
# )
