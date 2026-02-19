#' Find an object in a nested list by name
#'
#' @param haystack A nested list.
#' @param needle Name of the object to find.
#' @return Object in the nested list with the given name or NULL if not found.
#' @export
find_name <- function(haystack, needle) {
    if (hasName(haystack, needle)) {
        haystack[[needle]]
    } else if (is.list(haystack)) {
        for (obj in haystack) {
            ret <- Recall(obj, needle)
            if (!is.null(ret)) {
                return(ret)
            }
        }
    } else {
        NULL
    }
}

#' Detect the JSON code on Facebook ad websites
#'
#' Function to detect the JSON code on facebook ad websites that contains the media URLs
#' This is basically str_extract but with perl!
#'
#' @param rawhtmlascharacter Raw HTML content as character string.
#' @return A parsed JSON object.
#' @seealso \link{detectmysnap}
detectmysnap_dep <- function(rawhtmlascharacter) {

    # Detect the position of the snapshot json entry
    detection <-
        rawhtmlascharacter %>%
        regexpr(
            text = .,
            pattern = '"snapshot":((\\w*)\\s*\\(((?:(?>[^(){}]+)|(?1))*)\\)|\\{((?:(?>[^(){}]+)|(?1))*)\\})',
            perl = T
        )

    # Extract the json that follows snapshot (without then name, 'snapshot')
    rawhtmlascharacter %>%
        stringr::str_sub(detection[1], detection[1] + attr(detection, "match.length") - 1) %>%
        stringr::str_remove('"snapshot":') %>%
        jsonlite::fromJSON() %>%
        return()
}

#' Detect and parse the snapshot JSON from a Facebook Ad Library script tag
#'
#' Facebook's SSR script tags contain a bundle of many ads' snapshot data.
#' This function locates the `"snapshot":` occurrence that belongs to the
#' requested `ad_id` by first finding the ad_id in the raw text and then
#' extracting the nearest `"snapshot":` JSON object after it.
#'
#' Falls back to the original split-based approach when no ad_id is provided.
#'
#' @inheritParams detectmysnap_dep
#' @param ad_id Character string. The Facebook ad ID to find in the bundle.
#'   When provided, the function extracts only the snapshot belonging to this
#'   ad. When NULL, extracts the first snapshot found (legacy behavior).
#' @return A parsed JSON object (list).
#' @seealso [get_ad_snapshots()] which calls this function internally.
detectmysnap <- function(rawhtmlascharacter, ad_id = NULL) {
    # Guard against NA, NULL, or empty input
    if (length(rawhtmlascharacter) == 0 ||
        all(is.na(rawhtmlascharacter)) ||
        all(!nzchar(trimws(rawhtmlascharacter)))) {
        stop("Input is NA or empty")
    }

    # Use the LAST non-NA element
    non_na <- rawhtmlascharacter[!is.na(rawhtmlascharacter)]
    raw_text <- non_na[length(non_na)]

    # Strategy: if ad_id is provided, find the chunk of the script tag that
    # contains this ad_id and extract the "snapshot": JSON from there.
    # Facebook's SSR bundles multiple ads in one script tag; each ad's data
    # block contains the ad_id string near its "snapshot": key.
    if (!is.null(ad_id) && nzchar(ad_id)) {
        # Find ALL positions of the ad_id in the raw text
        ad_id_positions <- gregexpr(ad_id, raw_text, fixed = TRUE)[[1]]

        if (ad_id_positions[1] != -1) {
            # Find ALL positions of "snapshot": in the raw text
            snap_positions <- gregexpr('"snapshot":', raw_text, fixed = TRUE)[[1]]

            if (snap_positions[1] != -1) {
                # For each ad_id occurrence, find the nearest "snapshot": that
                # comes AFTER it. In Facebook's JSON structure, the ad_id
                # appears before its snapshot data in the same data block.
                best_snap_pos <- NULL
                best_distance <- Inf

                for (aid_pos in ad_id_positions) {
                    # Find snapshot positions that come after this ad_id
                    after_snaps <- snap_positions[snap_positions > aid_pos]
                    if (length(after_snaps) > 0) {
                        # Take the closest one after the ad_id
                        closest <- after_snaps[1]
                        distance <- closest - aid_pos
                        if (distance < best_distance) {
                            best_distance <- distance
                            best_snap_pos <- closest
                        }
                    }
                }

                if (!is.null(best_snap_pos)) {
                    # Extract from after "snapshot": (11 chars)
                    after_snap <- substring(raw_text, best_snap_pos + 11)

                    # Extract the JSON object using recursive regex
                    detection <- regexpr(
                        text = after_snap,
                        pattern = "\\{(?:[^}{]+|(?R))*+\\}",
                        perl = TRUE
                    )

                    if (detection[1] != -1) {
                        json_str <- stringr::str_sub(
                            after_snap,
                            detection[1],
                            detection[1] + attr(detection, "match.length") - 1
                        )

                        if (!is.na(json_str) && nzchar(trimws(json_str))) {
                            return(jsonlite::fromJSON(json_str))
                        }
                    }
                }
            }
        }
        # If ad_id-based search failed, fall through to legacy approach
    }

    # Legacy fallback: split on "snapshot": and take the first occurrence
    haystackpart <-
        raw_text %>%
        stringr::str_split('"snapshot":') %>%
        purrr::pluck(1) %>%
        purrr::pluck(2)

    # Guard against failed split (no "snapshot": key found)
    if (is.null(haystackpart) || is.na(haystackpart) || !nzchar(haystackpart)) {
        stop("No '\"snapshot\":' key found in script tag")
    }

    # Detect the position of the snapshot json entry
    detection <-
        haystackpart %>%
        regexpr(
            text = .,
            pattern = "\\{(?:[^}{]+|(?R))*+\\}",
            perl = T
        )

    # Guard against no JSON object found
    if (detection[1] == -1) {
        stop("Could not extract JSON object after 'snapshot'")
    }

    # Extract the json that follows snapshot (without then name, 'snapshot')
    json_str <- haystackpart %>%
        stringr::str_sub(detection[1], detection[1] + attr(detection, "match.length") - 1) %>%
        stringr::str_remove('"snapshot":')

    # Final guard before parsing
    if (is.na(json_str) || !nzchar(trimws(json_str))) {
        stop("Extracted JSON string is empty or NA")
    }

    jsonlite::fromJSON(json_str)
}





#' Convert an entry for an ad into a row in a tibble
#'
#' We did not manage to easily output the entry for one ad as a row in a tibble; this line solves the issue and does exactly that.
#'
#' @param x An object containing data about the ad.
#' @return A tibble row.
#' @export
stupid_conversion <- function(x) {
    list("f" = x) %>%
        tibble::enframe() %>%
        tidyr::unnest_wider(value)
}
# THIS MAY BE AN ALTERNATIVE SOLUTION TO THE PROBLEM
# x <- tibble(data = page_one_content$data)
# df_imp <- x %>%
#   unnest_wider(data)


#' Get ad snapshots from Facebook Ad Library
#'
#' Retrieves snapshot data (images, videos, cards, body text, etc.) for a
#' Facebook ad from the Ad Library. Uses headless Chrome via chromote to
#' bypass Facebook's JavaScript-based bot detection.
#'
#' For best results when processing multiple ads, call
#' `browser_session_start()` before and `browser_session_close()` after.
#' If no persistent session exists, a temporary one is created and warmed
#' up automatically (adds ~10 seconds on the first call).
#'
#' Includes built-in retry logic: if the page loads but snapshot data is
#' not yet available (e.g., JS challenge still completing), the function
#' retries with a longer wait before giving up.
#'
#' @param ad_id Character string. The Facebook ad ID.
#' @param download Logical. If TRUE, download media files to `mediadir`.
#' @param mediadir Character. Directory to save downloaded media files.
#' @param hashing Logical. If TRUE, hash downloaded files for deduplication.
#'   Recommended for large-scale data collection.
#' @param wait_sec Numeric. Seconds to wait for the page to load (default 6).
#'   Increase if you are getting empty results.
#' @param max_retries Integer. Number of retry attempts if data is not found
#'   on the first try (default 1). Each retry waits progressively longer.
#' @return A tibble with one row containing ad snapshot fields (images,
#'   videos, body, title, display_format, page_name, etc.) and the ad ID.
#'   If retrieval fails, returns a single-column tibble with just the id.
#' @export
#'
#' @examples
#' \dontrun{
#' # Single ad
#' snap <- get_ad_snapshots("1536277920797773")
#'
#' # Batch processing (recommended)
#' browser_session_start()
#' results <- map_dfr_progress(ad_ids, ~get_ad_snapshots(.x))
#' browser_session_close()
#' }
get_ad_snapshots <- function(ad_id, download = FALSE, mediadir = "data/media",
                              hashing = FALSE, wait_sec = 6, max_retries = 1) {

    if (!requireNamespace("chromote", quietly = TRUE)) {
        stop("Package 'chromote' is required. Install with: install.packages('chromote')")
    }

    url <- glue::glue("https://www.facebook.com/ads/library/?id={ad_id}")

    # Check for persistent session, otherwise create a temporary one
    persistent_session <- get_browser_session()
    if (!is.null(persistent_session)) {
        b <- persistent_session
        close_on_exit <- FALSE
    } else {
        b <- chromote::ChromoteSession$new()
        close_on_exit <- TRUE

        # Warm up fresh session: navigate to FB Ad Library landing page first
        # so the JS challenge completes and cookies are set
        tryCatch({
            b$Page$navigate("https://www.facebook.com/ads/library/")
            Sys.sleep(wait_sec + 2)
        }, error = function(e) {
            # Warm-up failed, continue anyway
        })
    }

    if (close_on_exit) {
        on.exit(b$close(), add = TRUE)
    }

    # Fetch page HTML with retry logic
    html_content <- NULL
    attempts <- 0

    while (attempts <= max_retries) {
        attempts <- attempts + 1

        # Navigate to the ad page using window.location to force a full page
        # load. Facebook's Ad Library is a SPA; b$Page$navigate() can trigger
        # client-side routing which reuses stale script tags from previous ads.
        nav_ok <- tryCatch({
            b$Runtime$evaluate(sprintf("window.location.replace('%s')", url))
            TRUE
        }, error = function(e) {
            warning("Browser navigation failed for ad ID: ", ad_id,
                    " - ", e$message,
                    "\nThe Chrome process may have crashed. ",
                    "Try: browser_session_close() then browser_session_start()")
            FALSE
        })

        if (!nav_ok) {
            return(tibble::tibble(id = ad_id))
        }

        # Wait longer on retries
        current_wait <- if (attempts == 1) wait_sec else wait_sec + (attempts * 2)
        Sys.sleep(current_wait)

        # Get page HTML after JS execution
        result <- tryCatch({
            b$Runtime$evaluate("document.documentElement.outerHTML")
        }, error = function(e) {
            warning("Browser evaluation failed for ad ID: ", ad_id,
                    " - ", e$message,
                    "\nThe Chrome process may have crashed. ",
                    "Try: browser_session_close() then browser_session_start()")
            NULL
        })

        if (is.null(result)) {
            return(tibble::tibble(id = ad_id))
        }

        html_content <- result$result$value

        # Validate html_content
        if (is.null(html_content) || is.na(html_content) || !nzchar(html_content)) {
            if (attempts <= max_retries) next
            warning("Empty or invalid page content for ad ID: ", ad_id)
            return(tibble::tibble(id = ad_id))
        }

        # Check if we got the actual snapshot data
        if (grepl('"snapshot":', html_content, fixed = TRUE)) {
            break  # Success — data found
        }

        # Not found yet — retry or give up
        if (attempts <= max_retries) {
            # Retry
            next
        }

        # Final failure
        if (grepl("__rd_verify_", html_content)) {
            warning("Facebook JS challenge not completed for ad ID: ", ad_id,
                    ". Try increasing wait_sec or use browser_session_start().")
        } else {
            warning("No snapshot data found for ad ID: ", ad_id)
        }
        return(tibble::tibble(id = ad_id))
    }

    # Extract snapshot from script tags
    # Use specific pattern '"snapshot":' to avoid false positives like "ads/reporting/snapshot"
    script_seg <- html_content %>%
        rvest::read_html() %>%
        rvest::html_nodes("script") %>%
        as.character() %>%
        .[stringr::str_detect(., '"snapshot":')]

    if (length(script_seg) == 0 || all(is.na(script_seg))) {
        warning("No snapshot script tag found for ad ID: ", ad_id)
        return(tibble::tibble(id = ad_id))
    }

    # Try to parse the snapshot JSON, handle errors gracefully
    # Pass ad_id so detectmysnap can find the correct snapshot in the
    # multi-ad bundle that Facebook's SSR embeds in script tags
    dataasjson <- tryCatch({
        detectmysnap(script_seg, ad_id = ad_id)
    }, error = function(e) {
        warning("Failed to parse snapshot JSON for ad ID: ", ad_id, " - ", e$message)
        return(NULL)
    })

    if (is.null(dataasjson)) {
        return(tibble::tibble(id = ad_id))
    }

    fin <- dataasjson %>%
        stupid_conversion() %>%
        dplyr::mutate(id = ad_id)

    if (download) {
        fin %>% download_media(mediadir = mediadir, hashing = hashing)
    }

    return(fin)
}



#' Apply a function to each element of a list with a progress bar
#'
#' Adding a progress bar to the map_dfr function https://www.jamesatkins.net/posts/progress-bar-in-purrr-map-df/
#'
#' @param .x List to iterate over.
#' @param .f Function to apply.
#' @param ... Other parameters passed to \code{purrr::map_dfr}.
#' @param .id An identifier.
#' @return An aggregated data frame.
#' @export
map_dfr_progress <- function(.x, .f, ..., .id = NULL) {
    .f <- purrr::as_mapper(.f, ...)
    pb <- progress::progress_bar$new(
        total = length(.x),
        format = " (:spin) [:bar] :percent | :current / :total | elapsed: :elapsedfull | eta: :eta",
        # format = " downloading [:bar] :percent eta: :eta",
        force = TRUE)

    f <- function(...) {
        pb$tick()
        .f(...)
    }
    purrr::map_dfr(.x, f, ..., .id = .id)
}

#' Walk through a list with a progress bar
#'
#' @inheritParams map_dfr_progress
#' @return None (used for side effects).
#' @export
walk_progress <- function(.x, .f, ..., .id = NULL) {
    .f <- purrr::as_mapper(.f, ...)
    pb <- progress::progress_bar$new(
        total = length(.x),
        format = " (:spin) [:bar] :percent | :current / :total | elapsed: :elapsedfull | eta: :eta",
        # format = " downloading [:bar] :percent eta: :eta",
        force = TRUE)

    f <- function(...) {
        pb$tick()
        .f(...)
    }
    purrr::walk(.x, f, ..., .id = .id)
}


#' Extract media URLs from data
#'
#' @param yo Data containing potential media URLs.
#' @return A character vector of media URLs.
extract_media_urls <- function(yo) {
    yo <- yo
    # print(yo$id)

    if (any(!is.na(yo$images))) {
        # print("image")
        temp <- unlist(yo$images)
        dl_links <- temp[stringr::str_detect(names(temp), "original_image_url")]
        # dl_links <- unlist(yo$images)[["original_image_url"]]
    } else if (any(!is.na(yo$videos))) {
        # print("videos")
        dl_links <- unlist(yo$videos)[["video_hd_url"]]
    } else if (any(!is.na(yo$cards))) {
        # print("cards")
        raw_cards <- unlist(yo$cards) # [["original_image_url"]]

        vi <- raw_cards %>%
            .[stringr::str_detect(names(.), "video_hd")]

        im <- raw_cards %>%
            .[stringr::str_detect(names(.), "original_image")]

        if (!all(is.na(vi))) {
            # print("videos")
            ## sometimes every single vi is the same so only keep unique
            dl_links <- vi %>% unique()
        }

        if (!all(is.na(im))) {
            # print("images")
            ## maybe its possible that there vi and im? then combine!
            if (exists("dl_links")) {

                ## sometimes every single im is the same so only keep unique
                dl_links <- im %>%
                    c(dl_links) %>%
                    unique()
            } else {
                dl_links <- im %>% unique()
            }
        }
    } else {
        dl_links <- ""
    }

    dl_links <- dl_links %>%
        na.omit() %>%
        purrr::discard(~ magrittr::equals(.x, ""))

    return(dl_links)
}

#' Download media files with specified IDs
#'
#' @param id Ad ID.
#' @param x Media URLs to download.
#' @param n Number of URLs.
#' @param mediadir Directory to save media files.
#' @return A character vector with file paths.
download_media_int <- function(id, x, n, mediadir = "data/media") {
    if (n > 1) {
        counter <- 0
    }

    # stage all downloaded media files in a waiting room folder
    thefiles <-
        x %>%
        purrr::map_chr(~ {
            fol <- "waiting_room"
            if (stringr::str_detect(.x, "video")) {
                ending <- "mp4"
                # fol <- "vid_hash"
            } else if (stringr::str_detect(.x, "jpg")) {
                ending <- "jpg"
                # fol <- "img_hash"
            }

            if (n > 1) {
                counter <<- counter + 1
                sub <- glue::glue("_{counter}")
            } else {
                sub <- ""
            }

            thefile <- glue::glue("{mediadir}/{fol}/{id}{sub}.{ending}")

            download.file(
                quiet = T,
                url = .x, mode = "wb",
                destfile = thefile
            )

            return(thefile)
        })
    return(thefiles)
}

# DEPRECATED
download_media_int_dep <- function(id, x, n, mediadir = "data/media") {
    if (n > 1) {
        counter <- 0
    }

    x %>%
        purrr::walk(~ {
            if (stringr::str_detect(.x, "video")) {
                ending <- "mp4"
                fol <- "vid_hash"
            } else if (stringr::str_detect(.x, "jpg")) {
                ending <- "jpg"
                fol <- "img_hash"
            }

            if (n > 1) {
                counter <<- counter + 1
                sub <- glue::glue("_{counter}")
            } else {
                sub <- ""
            }

            download.file(
                url = .x, mode = "wb",
                destfile = glue::glue("{mediadir}/{fol}/{id}{sub}.{ending}")
            )
        })
}

safe_copy <- function(yoooyyy, whereto) {
    file.copy(yoooyyy, whereto)
    return(whereto)
}

# safe_img_read <- possibly(OpenImageR::readImage, otherwise = NULL, quiet = T)

#' Check hash of a media file
#'
#' @param .x Path to the media file.
#' @param hash_table A data frame of existing hashes.
#' @param mediadir Directory to save media files.
#' @return A tibble with file details.
check_hash <- function(.x, hash_table, mediadir){
    if (stringr::str_detect(.x, "mp4")) {
        # print("video")
        hashy <- digest::digest(
            object = .x,
            file = T,
            algo = "md5",
        )
        type <- "vid"
        ending <- "mp4"
    } else if (stringr::str_detect(.x, "jpg")) {
        # print("image")
        img_to_read_in <<- .x

        ending <- get_file_ending(img_to_read_in) %>% stringr::str_split("/") %>% unlist() %>% dplyr::first()

        ## it detects as jpeg all of a sudden?
        if(!ending %in% c("jpeg", "jpg")){ # if the image ending is anything other than jpg|jpeg, then correct it
            file.rename(img_to_read_in, str_replace(img_to_read_in, "jpg", ending))
            img_to_read_in <- str_replace(img_to_read_in, "jpg", ending)
            # accordingly correct the dataframe
        } else {
            ending <- "jpg"
        }

        hashy <- digest::digest(
            object = img_to_read_in,
            file = T,
            algo = "md5",
        )

        type <- "img"
    }

    if(type == "img") {
        path <- img_to_read_in
    } else if (type == "vid"){
        path <- .x
    }

    # print(hashy)
    hash_table_row <- tibble::tibble(
        hash = hashy,
        ad_id = .x %>%
            stringr::str_split("/") %>%
            unlist() %>% dplyr::last() %>%
            stringr::str_remove_all(".jpg|.mp4") %>%
            paste0("adid_", .),
        media_type = type,
        ending,
        filepath = path
    )


    return(hash_table_row)
}


#' Create necessary directories
#'
#' @param x Directory path to check and create.
#' @return None (used for side effects).
create_necessary_dirs <- function(x) {
    if(!file.exists(x)){
        dir.create(x, recursive = T)
    }
}

#' Download media files and potentially hash them
#'
#' @param media_dat Data containing media URLs.
#' @param mediadir Directory to save media files.
#' @param hashing Logical, whether to hash the files.
#' @return None (used for side effects).
#' @export
download_media <- function(media_dat,
                           mediadir = "data/media",
                           hashing = T) {

    c(glue::glue("{mediadir}"),
      glue::glue("{mediadir}/img_hash"),
      glue::glue("{mediadir}/vid_hash"),
      glue::glue("{mediadir}/waiting_room")) %>%
        purrr::walk(create_necessary_dirs)

    if (hashing) {

        hash_table_path <- glue::glue("{mediadir}/hash_table.csv")
        # Check if Hash table file is already existing
        firsthash <- !file.exists(hash_table_path)

        if (firsthash) {
            hash_table <- tibble::tibble(
                hash = NA_character_,
                ad_id = NA_character_,
                media_type = NA_character_,
                ending = NA_character_,
                filepath = NA_character_
            )
            # write_csv(hash_table_row,file = glue("{datadir}/media/hash_table.csv"))
        } else {
            hash_table <- readr::read_csv(hash_table_path, col_types = readr::cols(.default = readr::col_character()))
        }

        # hash_nrow <- nrow(hash_table)
    }

    # take media urls out of media_dat
    the_urls <- media_dat %>%
        extract_media_urls()

    # if at least 1 URL, then start downloading and hashing
    if (length(the_urls) != 0) {
        thefiles <<- download_media_int(media_dat$id, the_urls, length(the_urls), mediadir = mediadir)

        # print(glue::glue("Found {length(thefiles)} media files to download."))

        # Hashing of all media
        if (hashing) {

            unique_counter <<- 0

            hash_table_rows <<- thefiles %>%
                purrr::map_dfr(
                    ~ {check_hash(.x, hash_table, mediadir)}
                )

            # ex <<- hash_table_row %>%
            #   bind_rows(hash_table_row[1,] %>% mutate(ad_id = "yoyo"))

            ### check if hashes are already present and if so copy paste to folder
            hash_table_rows %>%
                dplyr::filter(!(hash %in% hash_table$hash)) %>%
                split(1:nrow(.)) %>%
                purrr::walk(~{
                    filter_again <- .x %>%
                        dplyr::filter(!(hash %in% hash_table$hash))
                    if(nrow(filter_again)!=0){
                        file.copy(from = .x$filepath, to = glue::glue("{mediadir}/{.x$media_type}_hash/{.x$hash}.{.x$ending}"))
                        unique_counter <<- unique_counter + 1
                    }

                    hash_table <<- hash_table %>% dplyr::bind_rows(.x)

                })

            # print(glue::glue("Copied {unique_counter} unique media files."))

            # empty waiting rooms
            dir(glue::glue("{mediadir}/waiting_room"), full.names = T) %>% purrr::walk(file.remove)

            # print(hash_table)
            if(firsthash) {
                readr::write_csv(hash_table %>% tidyr::drop_na() %>% dplyr::distinct(.keep_all = T), hash_table_path)
            } else {
                readr::write_csv(hash_table_rows %>% dplyr::distinct(.keep_all = T), hash_table_path, append = T)
            }

        }
    }
}

# Detect file type from magic bytes (cross-platform, works on Windows too)
get_file_ending <- function(file_full_path) {
    bytes <- tryCatch(
        readBin(file_full_path, "raw", n = 12),
        error = function(e) raw(0)
    )

    if (length(bytes) < 4) return("jpg")

    # JPEG: FF D8 FF
    if (bytes[1] == as.raw(0xFF) && bytes[2] == as.raw(0xD8)) return("jpeg")
    # PNG: 89 50 4E 47
    if (bytes[1] == as.raw(0x89) && bytes[2] == as.raw(0x50) &&
        bytes[3] == as.raw(0x4E) && bytes[4] == as.raw(0x47)) return("png")
    # GIF: 47 49 46
    if (bytes[1] == as.raw(0x47) && bytes[2] == as.raw(0x49) &&
        bytes[3] == as.raw(0x46)) return("gif")
    # WebP: RIFF....WEBP
    if (length(bytes) >= 12 &&
        bytes[1] == as.raw(0x52) && bytes[2] == as.raw(0x49) &&
        bytes[3] == as.raw(0x46) && bytes[4] == as.raw(0x46) &&
        bytes[9] == as.raw(0x57) && bytes[10] == as.raw(0x45) &&
        bytes[11] == as.raw(0x42) && bytes[12] == as.raw(0x50)) return("webp")
    # BMP: 42 4D
    if (bytes[1] == as.raw(0x42) && bytes[2] == as.raw(0x4D)) return("bmp")

    # Default fallback
    "jpg"
}

# datadir <- "data"
#
# library(glue)
# library(rvest)
# library(jsonlite)

# debug section
if(F){
    debugonce(detectmysnap)
    debugonce(get_ad_snapshots)
    get_ad_snapshots("561403598962843", download = T, hashing = T, mediadir = glue("{datadir}/media"))
    ad_id <- "1103135646905363"
    browseURL(glue("https://www.facebook.com/ads/library/?id={ad_id}")) # to browse the specific ad
}
#



#' Extract and flatten 'deeplinkAdCard' JSON from a Facebook Ad Library page
#'
#' This function programmatically retrieves the embedded JSON object labeled `deeplinkAdCard`
#' from the source code of a Facebook Ad Library ad page.
#'
#' The function performs the following steps internally:
#'
#' 1. Fetches the ad page HTML from Facebook's Ad Library using headless Chrome.
#' 2. Locates the `<script>` tag containing the `deeplinkAdCard` object.
#' 3. Uses a recursive regular expression to extract the full JSON object following `deeplinkAdCard`.
#' 4. Parses the JSON string into a nested R list.
#' 5. Flattens the JSON into a tidy tibble row, unnesting nested sub-objects such as `fevInfo`,
#'    `free_form_additional_info`, `learn_more_content`, and optionally `snapshot` if present.
#'
#' The output is designed for downstream analysis: each ad is represented as **one row** in a tibble,
#' with nested JSON fields expanded into their own columns via `tidyr::unnest_wider()`.
#'
#' This function complements `get_ad_snapshots()`, which extracts the `snapshot` JSON.
#' Use `get_deeplink()` when additional metadata embedded under `deeplinkAdCard` is required.
#'
#' @param ad_id Character string specifying the Facebook ad ID (as shown in the Ad Library URL).
#' @param wait_sec Seconds to wait for page to load (default 4). Increase if getting errors.
#' @return A tibble with one row, containing flattened columns extracted from the deeplink JSON object.
#' Columns depend on the structure of the JSON and may include fields like `fevInfo_*`,
#' `fevInfo_free_form_additional_info_*`, `fevInfo_learn_more_content_*`, and snapshot-related columns.
#'
#' @seealso [get_ad_snapshots()] for extracting snapshot JSON; [detectmysnap()] for raw JSON detection.
#'
#' @examples
#' \dontrun{
#' df <- get_deeplink("1103135646905363")
#' glimpse(df)
#' }
#'
#' @export
get_deeplink <- function(ad_id, wait_sec = 4) {

  if (!requireNamespace("chromote", quietly = TRUE)) {
    stop("Package 'chromote' is required. Install with: install.packages('chromote')")
  }

  url <- glue::glue("https://www.facebook.com/ads/library/?id={ad_id}")

  # Check for persistent session, otherwise create a temporary one
  persistent_session <- get_browser_session()
  if (!is.null(persistent_session)) {
    b <- persistent_session
    close_on_exit <- FALSE
  } else {
    b <- chromote::ChromoteSession$new()
    close_on_exit <- TRUE
  }

  if (close_on_exit) {
    on.exit(b$close(), add = TRUE)
  }

  # Navigate and wait for JS challenge to complete
  b$Page$navigate(url)
  Sys.sleep(wait_sec)

  # Get page HTML after JS execution
  result <- b$Runtime$evaluate("document.documentElement.outerHTML")
  html_content <- result$result$value

  # Check if we got past the challenge
  if (grepl("__rd_verify_", html_content) && !grepl("snapshot", html_content)) {
    stop("Facebook JS challenge not completed. Try increasing wait_sec parameter.")
  }

  script_seg <- html_content %>%
    rvest::read_html() %>%
    rvest::html_nodes("script") %>%
    as.character() %>%
    .[stringr::str_detect(., "snapshot")]

  if (length(script_seg) == 0) {
    stop("No script tag with snapshot data found for ad ID: ", ad_id)
  }

  # 1. Extract the part after "deeplinkAdCard":
  haystackpart <- script_seg %>%
    stringr::str_split('"deeplinkAdCard":') %>%
    purrr::pluck(1, 2)

  if (is.null(haystackpart)) {
    stop("No 'deeplinkAdCard' found in input.")
  }

  # 2. Detect the JSON object { ... } using recursive regex
  detection <- regexpr(
    text = haystackpart,
    pattern = "\\{(?:[^}{]+|(?R))*+\\}",
    perl = TRUE
  )

  if (detection[1] == -1) {
    stop("Could not parse JSON object after 'deeplinkAdCard'")
  }

  # 3. Extract JSON substring
  json_string <- haystackpart %>%
    stringr::str_sub(detection[1], detection[1] + attr(detection, "match.length") - 1)

  # 4. Parse JSON into list
  parsed_json <- jsonlite::fromJSON(json_string)

  # 5. Start flattening
  df <- tibble::tibble(data = list(parsed_json)) %>%
    tidyr::unnest_wider(data)

  # 6. Conditional unnesting
  for (col in c("fevInfo", "fevInfo_free_form_additional_info", "fevInfo_learn_more_content")) {
    if (col %in% names(df)) {
      df <- tidyr::unnest_wider(df, {{col}}, names_sep = "_")
    }
  }

  # 7. Flatten snapshot (if exists)
  if ("snapshot" %in% names(parsed_json)) {
    snapshot_flat <- tibble::tibble(snapshot = list(parsed_json$snapshot)) %>%
      tidyr::unnest_wider(snapshot, names_sep = "_")

    df <- dplyr::bind_cols(df, snapshot_flat)
  }

  return(df)
}
