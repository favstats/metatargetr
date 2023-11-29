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
    body <- sprintf('f.req={"1":{"1":"%s","6":%d,"7":%d,"8":%s},"3":{"1":%d}}',
                    advertiser_id, start_date, end_date, jsonlite::toJSON(cntry), 2)

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
