#' Retrieve Ad Data from the LinkedIn Ad Library with Pagination
#'
#' This function scrapes ad data from the LinkedIn Ad Library, handling pagination
#' to retrieve all available results for a given search query. It first collects
#' all ad detail links and then scrapes each detail page with a configurable
#' timeout and retry mechanism.
#'
#' @param keyword A character string for the keyword to search for (e.g., "Habeck").
#' @param countries A character vector of two-letter country codes (e.g., "DE").
#' @param start_date The start date of the search range in "YYYY-MM-DD" format.
#' @param end_date The end date of the search range in "YYYY-MM-DD" format.
#' @param account_owner Optional. A character string for the ad account owner.
#' @param max_pages The maximum number of pages to scrape. Defaults to 100.
#' @param max_retries The maximum number of retries for each detail page request. Defaults to 5.
#' @param timeout_seconds The timeout in seconds for each detail page request. Defaults to 15.
#'
#' @return A tibble containing the detailed scraped ad information from all pages.
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   ads_data <- get_linkedin_ads(
#'     keyword = "Habeck",
#'     countries = "DE",
#'     start_date = "2025-01-01",
#'     end_date = "2025-02-23",
#'     account_owner = "INSM",
#'     max_pages = 5,
#'     max_retries = 3,
#'     timeout_seconds = 20
#'   )
#'   print(ads_data)
#' }
get_linkedin_ads <- function(keyword,
                             countries,
                             start_date,
                             end_date,
                             account_owner = NULL,
                             max_pages = 100,
                             max_retries = 5,
                             timeout_seconds = 15) {

    # --- 1. Initial Setup ---
    base_search_url <- "https://www.linkedin.com/ad-library/search"
    pagination_url <- "https://www.linkedin.com/ad-library/searchPaginationFragment"

    start_date_str <- tryCatch(format(as.Date(start_date), "%Y-%m-%d"),
                               error = function(e) stop("Invalid start_date format. Please use 'YYYY-MM-DD'."))
    end_date_str <- tryCatch(format(as.Date(end_date), "%Y-%m-%d"),
                             error = function(e) stop("Invalid end_date format. Please use 'YYYY-MM-DD'."))

    query_params <- list(
        keyword = keyword,
        countries = I(countries),
        dateOption = "custom-date-range",
        startdate = start_date_str,
        enddate = end_date_str,
        accountOwner = account_owner
    ) %>% purrr::compact()

    # --- 2. Make Initial Request ---
    message("Fetching first page...")
    req <- httr2::request(base_search_url) %>%
        httr2::req_url_query(!!!query_params) %>%
        httr2::req_user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36") %>%
        httr2::req_timeout(timeout_seconds) %>%
        httr2::req_retry(max_tries = max_retries)

    resp <- tryCatch(httr2::req_perform(req), error = function(e) {
        warning(paste("Failed to retrieve data from LinkedIn. Error:", e$message))
        return(NULL)
    })

    if (is.null(resp)) {
        return(tibble::tibble())
    }

    # --- Helper function to extract token from HTML ---
    extract_pagination_data <- function(html_doc) {
        token_node <- html_doc %>% rvest::html_element("code#paginationMetadata")
        if (is.na(token_node)) return(list(isLastPage = TRUE, paginationToken = NA))

        token_comment <- token_node %>%
            xml2::xml_contents() %>%
            as.character()

        json_str <- stringr::str_remove_all(token_comment, "<!--|-->")

        jsonlite::fromJSON(json_str)
    }

    # --- 3. Collect all detail links, handling pagination ---
    all_detail_paths <- list()
    page_count <- 1

    html_content <- httr2::resp_body_html(resp)
    all_detail_paths[[page_count]] <- html_content %>%
        rvest::html_elements("a[data-tracking-control-name='ad_library_view_ad_detail']") %>%
        rvest::html_attr("href")

    pagination_data <- extract_pagination_data(html_content)
    pagination_token <- pagination_data$paginationToken

    while (!pagination_data$isLastPage && !is.na(pagination_token) && page_count < max_pages) {
        page_count <- page_count + 1
        message(paste("Fetching page", page_count, "..."))

        pag_req <- httr2::request(pagination_url) %>%
            httr2::req_url_query(!!!query_params, paginationToken = pagination_token) %>%
            httr2::req_user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36") %>%
            httr2::req_timeout(timeout_seconds) %>%
            httr2::req_retry(max_tries = max_retries)

        pag_resp <- tryCatch(httr2::req_perform(pag_req), error = function(e) NULL)

        if (is.null(pag_resp)) {
            warning("Failed to fetch a subsequent page. Stopping pagination.")
            break
        }

        html_content <- httr2::resp_body_html(pag_resp)
        all_detail_paths[[page_count]] <- html_content %>%
            rvest::html_elements("a[data-tracking-control-name='ad_library_view_ad_detail']") %>%
            rvest::html_attr("href")

        pagination_data <- extract_pagination_data(html_content)
        pagination_token <- pagination_data$paginationToken
        Sys.sleep(1)
    }

    # --- 4. Scrape each detail page ---
    detail_path <- unlist(all_detail_paths)
    n_ads <- length(detail_path)

    if (n_ads == 0) {
        message("No ads found.")
        return(tibble::tibble())
    }

    print(paste0("Found ", n_ads, " ads across ", page_count, " page(s). Now scraping details..."))

    # Placeholders for undefined helper functions
    if (!exists("parse_ad_details")) {
        parse_ad_details <- function(html) { tibble(url = rvest::html_element(html, "head > link[rel=canonical]") %>% rvest::html_attr("href")) }
    }
    if (!exists("map_dfr_progress")) {
        map_dfr_progress <- purrr::map_dfr
    }

    result_df <- paste0("https://www.linkedin.com", detail_path) %>%
        map_dfr_progress(~{
            url <- .x
            tryCatch({
                # Build a robust request with timeout and retry logic for each detail page
                req_detail <- httr2::request(url) %>%
                    httr2::req_user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36") %>%
                    httr2::req_timeout(timeout_seconds) %>%
                    httr2::req_retry(max_tries = max_retries)

                # Perform the request and parse the response
                resp_detail <- httr2::req_perform(req_detail)

                resp_detail %>%
                    httr2::resp_body_html() %>%
                    parse_ad_details() # This function needs to be defined in your environment

            }, error = function(e) {
                warning(paste("\nCould not process ad detail for URL after retries:", url, "\nFinal Error:", e$message))
                return(NULL) # Return NULL for failed ads
            })
        })

    cat("\nDone.\n")
    return(result_df)
}


#' Parse Important Information from an Ad Detail HTML Page
#'
#' This function takes the HTML content from a LinkedIn Ad Library detail page
#' and extracts key information like advertiser, targeting, and impressions.
#'
#' @param html_content An `xml_document` object, typically read from an HTML file
#'   or obtained from an HTTP response.
#'
#' @return A list containing the extracted ad details.
#'
#' @importFrom rvest html_element html_elements html_text2
#' @importFrom stringr str_trim str_replace
#' @importFrom tibble tibble
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   # Assuming you have saved the HTML of a detail page to "ad_detail.html"
#'   ad_html <- rvest::read_html("ad_detail.html")
#'   details <- parse_ad_details(ad_html)
#'   print(details)
#' }
parse_linkedin_ads_details <- function(html_content) {


    ad_id <- html_content %>%
        rvest::html_element("link[rel='canonical']") %>%
        rvest::html_attr("href") %>%
        stringr::str_extract("\\d+$") # Extracts the numeric ID from the end of the URL

    ad_type <- html_content %>%
        rvest::html_element(".ad-detail-right-rail .text-sm.mb-1") %>%
        rvest::html_text2() %>%
        stringr::str_trim()

    # --- Advertiser and Disclaimer ---
    advertiser_node <- html_content %>%
        rvest::html_element("a[data-tracking-control-name='ad_library_about_ad_advertiser']")

    advertiser <- advertiser_node %>%
        rvest::html_text2() %>%
        stringr::str_trim()

    advertiser_id <- advertiser_node %>%
        rvest::html_attr("href") %>%
        stringr::str_extract("\\d+") # Extracts the numeric ID from the company URL

    paid_by <- html_content %>%
        rvest::html_element(".about-ad__paying-entity") %>%
        rvest::html_text2() %>%
        stringr::str_trim()

    run_dates <- html_content %>%
        rvest::html_element(".about-ad__availability-duration") %>%
        rvest::html_text2() %>%
        stringr::str_trim()

    # --- Ad Content ---
    ad_text <- html_content %>%
        rvest::html_element("p.commentary__content") %>%
        rvest::html_text2() %>%
        stringr::str_trim()

    # --- Impressions ---
    total_impressions <- html_content %>%
        rvest::html_element("div.flex.justify-between > p.font-semibold:last-child") %>%
        rvest::html_text2()

    impression_nodes <- html_content %>%
        rvest::html_elements("li > span.ad-analytics__country-impressions")

    impressions_by_country <- purrr::map_df(impression_nodes, ~{
        country <- .x %>% rvest::html_element("p") %>% rvest::html_text2()
        percentage_text <- .x %>% rvest::html_element("div:last-child p") %>% rvest::html_text2() %>% stringr::str_trim()
        tibble::tibble(country = country, impressions_pct = percentage_text)
    })


    # --- Targeting ---
    # Helper function to find targeting info by its heading, which handles
    # missing info and different ordering.
    find_targeting_info <- function(heading_text) {
        node <<- purrr::detect(targeting_nodes, ~ {
            .x %>% rvest::html_element("h3") %>% rvest::html_text2() == heading_text
        })

        if (!is.null(node)) {
            # Language and Location have a nested span with the value
            selector <- if (heading_text %in% c("Language", "Location")) "p span" else "p"
            return(node %>% rvest::html_element(selector) %>% rvest::html_text2() %>% stringr::str_trim())
        }
        NA_character_ # Return NA if the targeting section isn't found
    }

    targeting_nodes <- html_content  %>%
        rvest::html_elements(".ad-detail-right-rail > div:last-child > div > div")

    language <- find_targeting_info("Language")
    location <- find_targeting_info("Location")
    job_targeting <- find_targeting_info("Job")

    # --- Compile Results into a Tibble ---
    tibble::tibble(
        ad_id = ad_id,
        ad_type = ad_type,
        advertiser = advertiser,
        advertiser_id = advertiser_id,
        paid_by = paid_by,
        run_dates = run_dates,
        ad_text = ad_text,
        total_impressions = total_impressions,
        # Nest the impressions data frame into a single cell
        impressions_by_country = list(impressions_by_country),
        targeting_language = language,
        targeting_location = location,
        targeting_job = job_targeting
    )
}
