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
ua <- sample(ua_list, 1)
# print(ua)

# pageid <- "7860876103"
# timeframe <- "90"

fetch_page_info <- ifelse("page_info" %in% include_info, "true", "false")


resp <- request("https://www.facebook.com/api/graphql/") %>%
    httr2::req_headers(
    `Accept-Language` = paste0(lang, ',', stringr::str_split(lang, "-") %>% unlist() %>% .[1],';q=0.5'),
    `sec-fetch-site` = "same-origin",
    `user-agent` = ua
  ) %>%
    httr2::req_body_raw(glue::glue("av=0&_aaid=0&user=0&a=1&req=3&hs=19797.BP%3ADEFAULT.2.0..0.0&dpr=1&ccg=EXCELLENT&rev=1012093869&s=sbbnic%3Awquopy%3A7r1j3c&hsi=7346737420686302672&dyn=7xe6Eiw_K9zo5ObwKBAgc9o2exu13wqojyUW3qi4EoxW4E7SewXwCwfW7oqx60Vo1upEK12wvk1bwbG78b87C2m3K2y11wBw5Zx62G3i1ywdl0Fw4Hwp8kwyx2cU8EmwoHwrUcUjwVw9O7bK2S2W2K4EG1Mxu16wciaw4JwJwSyES0gq0K-1LwqobU2cwmo6O1Fw44wt8&csr=&lsd=AVo6-wl7l1Q&jazoest=2881&spin_r=1012093869&spin_b=trunk&spin_t=1710545602&_jssesw=1&fb_api_caller_class=RelayModern&fb_api_req_friendly_name=AdLibraryMobileFocusedStateProviderQuery&variables=%7B%22adType%22%3A%22POLITICAL_AND_ISSUE_ADS%22%2C%22audienceTimeframe%22%3A%22{timeframe}%22%2C%22country%22%3A%22{iso2c}%22%2C%22viewAllPageID%22%3A%22{pageid}%22%2C%22fetchPageInfo%22%3A{fetch_page_info}%2C%22fetchSharedDisclaimers%22%3Atrue%2C%22active_status%22%3A%22ALL%22%2C%22ad_type%22%3A%22POLITICAL_AND_ISSUE_ADS%22%2C%22bylines%22%3A%5B%5D%2C%22collation_token%22%3A%227ca3912f-0148-43ce-83e4-9a68ef656e4d%22%2C%22content_languages%22%3A%5B%5D%2C%22count%22%3A30%2C%22countries%22%3A%5B%22{iso2c}%22%5D%2C%22excluded_ids%22%3A%5B%5D%2C%22full_text_search_field%22%3A%22ALL%22%2C%22group_by_modes%22%3A%5B%5D%2C%22image_id%22%3Anull%2C%22location%22%3Anull%2C%22media_type%22%3A%22ALL%22%2C%22page_ids%22%3A%5B%5D%2C%22pagination_mode%22%3Anull%2C%22potential_reach_input%22%3Anull%2C%22publisher_platforms%22%3A%5B%5D%2C%22query_string%22%3A%22%22%2C%22regions%22%3A%5B%5D%2C%22search_type%22%3A%22PAGE%22%2C%22session_id%22%3A%221678877b-700b-485a-abb0-60efcb6b4019%22%2C%22sort_data%22%3A%7B%22mode%22%3A%22SORT_BY_RELEVANCY_MONTHLY_GROUPED%22%2C%22direction%22%3A%22ASCENDING%22%7D%2C%22source%22%3Anull%2C%22start_date%22%3Anull%2C%22view_all_page_id%22%3A%22{pageid}%22%7D&server_timestamps=true&doc_id=7193625857423421"), "application/x-www-form-urlencoded") %>%
    httr2::req_perform()

out <- resp %>%
  httr2::resp_body_html() %>%
  rvest::html_element("p") %>%
  rvest::html_text() %>%
  str_split_1('(?<=\\})\\s*(?=\\{)') %>%
  map(jsonlite::fromJSON)

if(!is.null(out[[1]][["errors"]][["description"]])){
  message(out[[1]][["errors"]][["description"]])
}

if( "page_info" %in% include_info) {
  page_info1 <-
    out[[1]][["data"]][["ad_library_page_info"]][["page_info"]]

  if(is.null(page_info1)){

    if ("page_info" %in% include_info & "targeting_info" %in% include_info) {
      if (join_info) {
        return(tibble(page_id = pageid, no_data = T))
      } else {
        return(list(page_info = tibble(page_id = pageid, no_data = T),
                    targeting_info = tibble(page_id = pageid, no_data = T)))
      }

    } else {
      return(tibble(page_id = pageid, no_data = T))
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
    page_info2 <- tibble(no_shared_disclaimer  = T)
  }



  creat_times <-
    out[[1]][["data"]][["page"]][["pages_transparency_info"]][["history_items"]] %>%
    dplyr::mutate(event = paste0(
      item_type,
      ": ",
      as.POSIXct(event_time, origin = "1970-01-01", tz = "UTC")
    )) %>%
    dplyr::select(event) %>%
    unlist() %>% t() %>% as.data.frame()

  about_text <-
    out[[1]][["data"]][["page"]][["about"]] %>% purrr::set_names("about")

  address_raw <- out[[1]][["data"]][["page"]][["confirmed_page_owner"]][["information"]]
  if(!is.null(address_raw)){
      address <- address_raw %>% purrr::flatten()
  } else {
    address <- tibble(no_address  = T)
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
      left_join(targeting_info, by = "page_id")
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
