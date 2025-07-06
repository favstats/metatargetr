parse_ad_htmls <- function(
        html_dir = here::here("data", "html_cache"),
        idle_cores = 2
){
    htmls <- list.files(html_dir, full.names = T)
    progressr::handlers(global = TRUE)

    df <- progressr::with_progress({
        p <- progressr::progressor(steps = length(htmls))
        future::plan(future::multisession, workers = parallel::detectCores() - idle_cores)
        htmls %>%
            furrr::future_map_dfr(~{
                end <- read_gz_char(.x) %>%
                    extract_html_and_otherProps()

                p()

                return(end)
            },
            .options = furrr::furrr_options(seed = TRUE)
            )
    })

    # Apply the function to your dataframe
    df_reordered <- reorder_ad_columns(df)

    return(df_reordered)
}


extract_html_and_otherProps <- function(html_txt, marker = "deeplinkAdCard", max_scripts = 20) {
    stopifnot(is.character(html_txt) && length(html_txt) == 1)
    library(xml2)
    library(jsonlite)
    library(tibble)

    # 1. Extract JSON payload as string
    json_str <- get_relevant_json(html_txt, marker = marker, max_scripts = max_scripts)
    if (is.na(json_str) || !nzchar(json_str)) {
        warning("No relevant JSON found")
        return(tibble(html = NA_character_, otherProps = list(list())))
    }
    json_obj <- fromJSON(json_str, simplifyVector = FALSE)

    # 2a. Recursively find the first __html
    find_html_value <- function(x) {
        if (is.list(x)) {
            if ("__html" %in% names(x)) return(x[["__html"]])
            for (item in x) {
                found <- find_html_value(item)
                if (!is.null(found)) return(found)
            }
        }
        NULL
    }

    # 2b. Recursively collect all 'otherProps' elements
    find_all_otherProps <- function(x, acc = list()) {
        if (is.list(x)) {
            if ("otherProps" %in% names(x)) acc <- append(acc, list(x[["otherProps"]]))
            for (item in x) {
                acc <- find_all_otherProps(item, acc)
            }
        }
        acc
    }

    html_val <- find_html_value(json_obj)
    otherProps <- find_all_otherProps(json_obj) %>%
        toJSON() %>%
        fromJSON(flatten = T) %>%
        as_tibble() %>%
        rename_all(function(x){str_remove_all(x, "deeplinkAdCard\\.|snapshot\\.")}) %>%
        mutate_all(as.character)

    # --- Start of the fix ---
    # Identify all columns that need to be gathered
    category_cols <- grep("^page_categories\\.", names(otherProps), value = TRUE)

    # If category columns exist, gather them into a list-column
    if (length(category_cols) > 0) {
        otherProps <- otherProps %>%
            # Use a row-wise operation to gather values
            dplyr::rowwise() %>%
            # Create the new list-column with non-NA category values
            dplyr::mutate(page_categories = list(stats::na.omit(dplyr::c_across(dplyr::all_of(category_cols))))) %>%
            dplyr::ungroup() %>%
            # Remove the original, scattered category columns
            dplyr::select(-dplyr::all_of(category_cols))
    } else {
        # If no category columns were found, add an empty list-column for consistency
        otherProps <- otherProps %>% dplyr::mutate(page_categories = list(NULL))
    }


    category_cols2 <- grep("^branded_content.page_categories\\.", names(otherProps), value = TRUE)

    # If category columns exist, gather them into a list-column
    if (length(category_cols2) > 0) {
        otherProps <- otherProps %>%
            # Use a row-wise operation to gather values
            dplyr::rowwise() %>%
            # Create the new list-column with non-NA category values
            dplyr::mutate(branded_content.page_categories = list(stats::na.omit(dplyr::c_across(dplyr::all_of(category_cols2))))) %>%
            dplyr::ungroup() %>%
            # Remove the original, scattered category columns
            dplyr::select(-dplyr::all_of(category_cols2))
    } else {
        # If no category columns were found, add an empty list-column for consistency
        otherProps <- otherProps %>% dplyr::mutate(branded_content.page_categories = list(NULL))
    }
    # --- End of the fix ---




    # Always return as a tibble, even if NA or empty
    df <- bind_cols(html = if (!is.null(html_val)) html_val else NA_character_,
          otherProps)



    return(df)
}

# get_relevant_json
#  Fast and robust extraction of the JSON payload that contains a marker
#  (defaults to "deeplinkAdCard") from a raw HTML CHARACTER STRING.
#  • xml2 DOM query → no more brittle regex on the whole file
#  • vectorised search   → always returns a SINGLE string or NA
#  • marker is an argument so you can adapt if Meta changes again
get_relevant_json <- function(html_txt,
                              marker      = "deeplinkAdCard",
                              max_scripts = 20) {
    stopifnot(is.character(html_txt), length(html_txt) == 1)

    # 1.  parse once with xml2 (RECOVER avoids choking on FB’s HTML)
    doc <- xml2::read_html(
        html_txt,
        options = c("RECOVER", "NOERROR", "NOWARNING")
    )

    # 2.  collect up to `max_scripts` JSON <script> nodes
    scripts <- xml2::xml_find_all(
        doc,
        sprintf(".//script[@type='application/json'][position()<=%d]", max_scripts)
    )

    if (length(scripts) == 0) return(NA_character_)

    # 3.  pick the FIRST whose text contains the marker
    for (node in scripts) {
        txt <- xml2::xml_text(node)
        if (grepl(marker, txt, fixed = TRUE)) {
            return(txt)           # <- scalar JSON string
        }
    }

    NA_character_              # nothing matched
}



# other version ----
#  locate the *first* JSON script that mentions "deeplinkAdCard" -------------------------------------------------------------------
get_relevant_json_dep <- function(html_txt) {

    stopifnot(is.character(html_txt), length(html_txt) == 1)

    # 1. grab EVERY <script type="application/json">...</script>
    matches <- stringr::str_match_all(
        html_txt,
        "(?is)<script[^>]*type=[\"']application/json[\"'][^>]*>(.*?)</script>"
    )[[1]]              # one matrix; col-2 holds the capture group

    if (nrow(matches) == 0) return(NA_character_)

    # 2. keep only those whose payload contains our marker
    hits <- matches[, 2][stringr::str_detect(matches[, 2], "deeplinkAdCard")]

    if (length(hits) == 0) {
        NA_character_
    } else {
        hits[[1]]         # take the first hit → scalar string
    }
}

# debugonce(parse_ad_htmls)

# EXAMPLE USEAGE:
# df <- parse_ad_htmls("html_cache")
#
# df

reorder_ad_columns <- function(df) {

    # 1. Define the desired order using the correct column names from your data

    # --- Key Identifiers ---
    core_ids <- c(
        "adid", "adArchiveID", "ad_creative_id", "page_id", "pageID", "page_name",
        "pageName", "current_page_name"
    )

    # --- Core Ad Content & Media ---
    ad_content <- c(
        "html", "body.__m", "caption", "title", "link_description", "link_url",
        "byline", "display_format", "mediaType", "cards", "images", "videos",
        "extra_images", "extra_videos", "extra_links", "extra_texts"
    )

    # --- Timeline & Status ---
    timeline <- c(
        "startDate", "endDate", "creation_time", "totalActiveTime",
        "isActive", "activeStatus"
    )

    # --- Spend & Reach ---
    performance <- c(
        "spend", "impressionsWithIndex.impressionsText",
        "impressionsWithIndex.impressionsIndex", "reachEstimate", "currency"
    )

    # --- Targeting & Platforms ---
    delivery <- c(
        "publisherPlatforms", "publisherPlatform", "politicalCountries",
        "targetedOrReachedCountries", "country", "language"
    )

    # --- Disclaimer, Funding & Authorization ---
    funding <- c(
        "disclaimerTexts", "disclaimer_label", "isAAAEligible", "bylines",
        "effective_authorization_category", "funding_entity", "brazil_tax_id"
    )

    # --- Page & Instagram Details ---
    page_details <- c(
        "page_categories", "categories", "page_like_count", "page_entity_type",
        "page_is_profile_page", "page_is_deleted", "instagram_actor_name",
        "instagram_handle", "instagram_profile_pic_url", "instagram_url"
    )

    # 2. Reorder the dataframe using dplyr::select
    df %>%
        select(
            # Select prioritized columns if they exist
            any_of(core_ids),
            any_of(ad_content),
            any_of(timeline),
            any_of(performance),
            any_of(delivery),
            any_of(funding),
            any_of(page_details),

            # Select groups of related columns by their prefix
            starts_with("branded_content"),
            starts_with("instagram_branded_content"),
            starts_with("event"),
            starts_with("fevInfo"),
            starts_with("finServAdData"),
            starts_with("regionalRegulationData"),
            starts_with("dynamic"),

            # Select all remaining columns to place them at the end
            everything()
        )
}
