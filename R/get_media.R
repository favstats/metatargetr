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

#' Updated function to detect the JSON code on Facebook ad websites
#'
#' @inheritParams detectmysnap_dep
#' @return A parsed JSON object.
detectmysnap <- function(rawhtmlascharacter) {
    haystackpart <-
        rawhtmlascharacter %>%
        stringr::str_split('"snapshot":') %>%
        purrr::pluck(1) %>%
        purrr::pluck(2)

    # Detect the position of the snapshot json entry
    detection <-
        haystackpart %>%
        regexpr(
            text = .,
            pattern = "\\{(?:[^}{]+|(?R))*+\\}",
            perl = T
        )

    # Extract the json that follows snapshot (without then name, 'snapshot')
    haystackpart %>%
        stringr::str_sub(detection[1], detection[1] + attr(detection, "match.length") - 1) %>%
        stringr::str_remove('"snapshot":') %>%
        jsonlite::fromJSON() %>%
        return()
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


#' Get ad snapshots from Facebook ad library
#'
#' @param ad_id A character string specifying the ad ID.
#' @param download Logical, whether to download media files.
#' @param mediadir Directory to save media files.
#' @param hashing Logical, whether to hash the files. RECOMMENDED!
#' @return A tibble with ad details.
#' @export
get_ad_snapshots <- function(ad_id, download = F, mediadir = "data/media", hashing = F) {

    html_raw <- rvest::read_html(glue::glue("https://www.facebook.com/ads/library/?id={ad_id}"))
    script_seg <- html_raw %>%
        rvest::html_nodes("script") %>%
        as.character() %>%
        .[stringr::str_detect(., "snapshot")]
    dataasjson <- detectmysnap(script_seg)
    fin <- dataasjson %>%
        stupid_conversion() %>%
        dplyr::mutate(id = ad_id)

    if (download) {
        # try({
        fin %>% download_media(mediadir = mediadir,
                               hashing)
        # })
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

# Read file endings from r object
get_file_ending <- function(file_full_path) {

    file_mime_type <- system2(command = "file",
                              args = paste0(" -b --mime-type ", file_full_path), stdout = TRUE) # "text/rtf"
    # Gives the list of potentially allowed extension for this mime type:
    file_possible_ext <- system2(command = "file",
                                 args = paste0(" -b --extension ", file_full_path),
                                 stdout = TRUE) # "???". "doc/dot" for MsWord files.

    return(file_possible_ext)

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
