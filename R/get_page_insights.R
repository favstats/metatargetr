#' Get Page Insights
#'
#' Retrieves insights for a given Facebook page within a specified timeframe, language, and country.
#' It allows for fetching specific types of information and optionally joining page info with targeting info.
#'
#' @param pageid A string specifying the unique identifier of the Facebook page.
#' @param timeframe A string indicating the timeframe for the insights. Valid options include predefined
#'        timeframes such as "LAST_30_DAYS". The default value is "LAST_30_DAYS".
#' @param lang A string representing the language locale to use for the request, formatted as language
#'        code followed by country code (e.g., "en-GB" for English, United Kingdom). The default is "en-GB".
#' @param iso2c A string specifying the ISO-3166-1 alpha-2 country code for which insights are requested.
#'        The default is "US".
#' @param include_info A character vector specifying the types of information to include in the output.
#'        Possible values are "page_info" and "targeting_info". By default, both types of information are included.
#' @param join_info A logical value indicating whether to join page info and targeting info into a single
#'        data frame (if TRUE) or return them as separate elements in a list (if FALSE). The default is TRUE.
#'
#' @return If \code{join_info} is TRUE, returns a data frame combining page and targeting information for
#'         the specified Facebook page. If \code{join_info} is FALSE, returns a list with two elements:
#'         \code{page_info} and \code{targeting_info}, each containing the respective data as a data frame.
#'         In case of errors or no data available, the function may return a simplified data frame or list
#'         indicating the absence of data.
#'
#' @examples
#' insights <- get_page_insights(pageid="123456789", timeframe="LAST_30_DAYS", lang="en-GB", iso2c="US",
#'                               include_info=c("page_info", "targeting_info"), join_info=TRUE)
#'
#' @export
#'
#' @importFrom httr2 request req_headers req_body_raw req_perform
#' @importFrom jsonlite fromJSON
#' @importFrom rvest html_element html_text
#' @importFrom dplyr mutate_all select bind_cols left_join slice
#' @importFrom purrr set_names flatten discard imap_dfr is_empty
#' @importFrom stringr str_split str_remove
#' @importFrom tibble as_tibble
get_page_insights <- function(pageid, timeframe = "LAST_30_DAYS", lang = "en-GB", iso2c = "US", include_info = c("page_info", "targeting_info"), join_info = T) {

  # Randomize the user agent
ua_list <- c(
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.82 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.77 Safari/537.36"
)

if("page_info" %in% include_info ){
  include_page_info <- T
} else {
  include_page_info <- F

}

ua <- sample(ua_list, 1)
# print(ua)

# Define static parameters
static_params <- list(
  av = "0",                        # Likely application version; may not change often. Optional.
  "_aaid" = "0",                   # Anonymous Advertising ID; unique to the visitor. Required for tracking purposes.
  user = "0",                      # User identifier; likely session-based or placeholder. Required.
  a = "1",                         # Arbitrary request parameter; purpose unclear but likely required.
  req = "3",                       # Request parameter; often a sequence or batch request identifier. Likely required.
  hs = "19797.BP%3ADEFAULT.2.0..0.0", # Host session or configuration metadata; required for server-side routing.
  ccg = "EXCELLENT",               # Connection grade; describes network quality. Optional but useful for server-side optimizations.
  csr = "",                        # CSRF token; placeholder here, likely required in some contexts.
  `_jssesw` = "1",                 # Encoded session value. Required for session management.
  fb_api_caller_class = "RelayModern", # API metadata describing the client. Required.
  fb_api_req_friendly_name = "AdLibraryMobileFocusedStateProviderQuery", # API-friendly name for request logging. Optional.
  server_timestamps = "true",      # Flag indicating server timestamps should be included. Likely required.
  doc_id = "7193625857423421"      # Unique document ID for the query. Required for identifying the request schema.
)

# Construct variables
variables <- jsonlite::toJSON(
  list(
    adType = "POLITICAL_AND_ISSUE_ADS",      # Type of ads to query. Required.
    audienceTimeframe = timeframe,          # Timeframe for audience data (e.g., LAST_30_DAYS). Required.
    country = iso2c,                        # Country ISO code (e.g., "DE"). Required.
    viewAllPageID = pageid,                 # Page ID for which data is being queried. Required.
    fetchPageInfo = include_page_info,      # Boolean flag to fetch page-specific information. Optional.
    fetchSharedDisclaimers = TRUE,          # Boolean flag to include shared disclaimers. Optional but useful.
    active_status = "ALL",                  # Filter for active/inactive ads. Required.
    ad_type = "POLITICAL_AND_ISSUE_ADS",    # Type of ads (repeated for clarity). Required.
    bylines = list(),                       # List of bylines to filter ads. Optional.
    content_languages = list(),             # Filter for content languages. Optional.
    count = 30,                             # Number of results to fetch. Optional but usually required for pagination.
    countries = list(iso2c),                # List of countries for filtering (repeated for clarity). Required.
    excluded_ids = list(),                  # IDs to exclude from results. Optional.
    full_text_search_field = "ALL",         # Full-text search field filter. Optional.
    group_by_modes = list(),                # Grouping modes for results. Optional.
    search_type = "PAGE",                   # Type of search (e.g., by page). Required.
    sort_data = list(
      mode = "SORT_BY_RELEVANCY_MONTHLY_GROUPED", # Sorting mode. Required.
      direction = "ASCENDING"                    # Sorting direction. Required.
    )
  ),
  auto_unbox = TRUE
)

static_params$variables <- URLencode(variables)
body <- paste(names(static_params), static_params, sep = "=", collapse = "&")

# print("Constructed body:")
# print(body)

resp <- httr2::request("https://www.facebook.com/api/graphql/") %>%
  httr2::req_headers(
    `Accept-Language` = paste0(
      lang, ",", stringr::str_split(lang, "-") %>% unlist() %>% .[1], ";q=0.5"
    ),
    `sec-fetch-site` = "same-origin",
    `user-agent` = ua
  ) %>%
  httr2::req_body_raw(body, "application/x-www-form-urlencoded") %>%
  httr2::req_perform()

out <- resp %>%
  httr2::resp_body_html() %>%
  rvest::html_element("p") %>%
  rvest::html_text() %>%
  stringr::str_split_1('(?<=\\})\\s*(?=\\{)') %>%
  purrr::map(jsonlite::fromJSON)

if(!is.null(out[[1]][["errors"]][["description"]])){
  message(out[[1]][["errors"]][["description"]])
}

if( "page_info" %in% include_info) {
  page_info1 <-
    out[[1]][["data"]][["ad_library_page_info"]][["page_info"]]

  if(is.null(page_info1)){

    if ("page_info" %in% include_info & "targeting_info" %in% include_info) {
      if (join_info) {
        return(tibble::tibble(page_id = pageid, no_data = T))
      } else {
        return(list(page_info = tibble::tibble(page_id = pageid, no_data = T),
                    targeting_info = tibble::tibble(page_id = pageid, no_data = T)))
      }

    } else {
      return(tibble::tibble(page_id = pageid, no_data = T))
    }



  }

  my_dataframe <-
    as.data.frame(t(unlist(page_info1)), stringsAsFactors = FALSE) %>%
    dplyr::mutate_all(as.character)

  page_info2_raw <-
    out[[2]][["data"]][["page"]][["shared_disclaimer_info"]][["shared_disclaimer_pages"]][["page_info"]]
  if (!is.null(page_info2_raw)) {
    page_info2 <- page_info2_raw   %>%
      tibble::as_tibble() %>%
      dplyr::mutate_all(as.character) %>%
      dplyr::mutate(shared_disclaimer_info = my_dataframe$page_id[1])
  } else {
    page_info2 <- tibble::tibble(no_shared_disclaimer  = T)
  }



    creat_times <- out[[1]][["data"]][["page"]][["pages_transparency_info"]][["history_items"]]

    if (!is.null(creat_times)) {
      creat_times <- creat_times %>%  dplyr::mutate(event = paste0(item_type, ": ", as.POSIXct(event_time,
                                                                                                origin = "1970-01-01", tz = "UTC"))) %>% dplyr::select(event) %>%
        unlist() %>% t() %>% as.data.frame()
    }  else {
      creat_times <- tibble(no_times = T)
    }

    about_text <- out[[1]][["data"]][["page"]][["about"]]

    if (!is.null(about_text)) {
      about_text <- about_text  %>%
        purrr::set_names("about")
    } else {
      about_text <- tibble(no_about = T)
    }

  address_raw <- out[[1]][["data"]][["page"]][["confirmed_page_owner"]][["information"]]
  if(!is.null(address_raw)){
      address <- address_raw %>% purrr::flatten()
  } else {
    address <- tibble::tibble(no_address  = T)
  }


  sdis_raw <-  out[[2]][["data"]][["page"]][["shared_disclaimer_info"]][["shared_disclaimer_pages"]][["page_info"]]
  if(!is.null(sdis_raw)){
      sdis <-    sdis_raw %>%
    dplyr::mutate_all(as.character) %>%
    dplyr::mutate(shared_disclaimer_page_id = pageid[1]) %>%
    jsonlite::toJSON() %>%
    as.character()
  } else {
    sdis <- "[]"
  }

  page_info <- my_dataframe %>%
    dplyr::mutate(shared_disclaimer_info = sdis) %>%
    dplyr::bind_cols(about_text) %>%
    dplyr::bind_cols(creat_times) %>%
    dplyr::bind_cols(address)

}


if("targeting_info" %in% include_info ) {
  out_raw <-
    out[[1]][["data"]][["page"]][["ad_library_page_targeting_insight"]]

  summary_dat <- out_raw %>%
    purrr::pluck("ad_library_page_targeting_summary") %>%
    dplyr::bind_rows()

  if (nrow(summary_dat) > 1) {
    summary_dat <- summary_dat %>%
      dplyr::slice(which(
        summary_dat$detailed_spend$currency == summary_dat$main_currency
      )) %>%
      dplyr::select(-detailed_spend)

  }

  targeting_details_raw <-
    out_raw[!(
      names(out_raw) %in% c(
        "ad_library_page_targeting_summary",
        "ad_library_page_has_siep_ads"
      )
    )]

  # names(targeting_details_raw)

  targeting_info <- targeting_details_raw %>%
    purrr::discard(purrr::is_empty) %>%
    purrr::imap_dfr( ~ {
      .x %>% dplyr::mutate(type = .y %>% stringr::str_remove("ad_library_page_targeting_"))
    }) %>%
    dplyr::bind_cols(summary_dat) %>%
    dplyr::mutate(page_id = pageid)


}


if( "page_info" %in% include_info & "targeting_info" %in% include_info  ) {

  if(join_info){
    fin <- page_info %>%
      dplyr::left_join(targeting_info, by = "page_id")
  } else {
    fin <- list(page_info, targeting_info)
  }

} else if ("page_info" %in% include_info) {
  return(page_info)
}  else if ("targeting_info" %in% include_info) {
  return(targeting_info)
}

return(fin)


}


#' Get Page Info Dataset for a Specific Country
#'
#' Downloads the historical Facebook or Instagram page info dataset for a given ISO2C country code.
#' The data is retrieved from a fixed GitHub release URL in `.parquet` format. It includes information on:
#' - Page-level metadata (e.g., name, verification status, profile type)
#' - Audience metrics (e.g., number of likes, Instagram followers)
#' - Shared disclaimers (if applicable)
#' - Page creation and name change events with timestamps
#' - Contact and address information (if available)
#' - Free-text descriptions ("about" section)
#'
#'
#' @param iso2c A string specifying the ISO-3166-1 alpha-2 country code (e.g., "DE", "FR", "US").
#' @param verbose Logical. If TRUE (default), prints a status message when downloading.
#'
#' @return A tibble containing Facebook page info for the specified country.
#'         If the dataset is not available or cannot be retrieved, a tibble with \code{no_data = TRUE}
#'         and the given \code{iso2c} code is returned.
#'
#' @examples
#' \dontrun{
#'   de_info <- get_page_info_db("DE")
#'   fr_info <- get_page_info_db("FR")
#' }
#'
#' @export
#'
#' @importFrom arrow read_parquet
#' @importFrom tibble tibble
#' @importFrom dplyr mutate
get_page_info_db <- function(iso2c, verbose = TRUE) {
  # Validate input
  if (missing(iso2c) || !is.character(iso2c) || nchar(iso2c) != 2) {
    stop("Please provide a valid ISO2C country code, e.g., 'DE', 'FR', 'US'.")
  }

  # Construct URL
  url <- sprintf(
    "https://github.com/favstats/meta_ad_targeting/releases/download/PageInfo/%s-page_info.parquet",
    iso2c
  )

  # Try to read
  if (verbose) message("Downloading: ", url)

  tryCatch({
    df <- arrow::read_parquet(url)
    dplyr::mutate(df, country_code = iso2c)
  },
  error = function(e) {
    if (verbose) message("No data found for ", iso2c, ". Returning placeholder.")
    tibble::tibble(country_code = iso2c, no_data = TRUE)
  })
}
