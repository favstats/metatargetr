utils::globalVariables(c(".", "archive_id", "value", "value_id", "tframe", "ds",
                         "file_name", "filename", "desc", "tag", "total_spend",
                         "perc_spend", "item_type", "event", "event_time",
                         "snapshot", "data", "no_data", "release", "name",
                         "hash", "thefiles", "unique_counter", "hash_table_rows"))

# Helper for yes/no questions, similar to usethis::ui_yeah()
cli_ask_yes_no <- function(question) {
    # Ask the question
    cli::cli_text(question, " (y/n)")

    # Loop until a valid answer is given
    while (TRUE) {
        ans <- tolower(readline("Selection: "))
        if (ans %in% c("y", "yes")) return(TRUE)
        if (ans %in% c("n", "no")) return(FALSE)
        cli::cli_alert_warning("Please answer 'yes' or 'no'.")
    }
}


# Helper function to get a random user agent
get_random_ua <- function() {
    # A short list of common user agents. This could be expanded.
    user_agents <- c(
        "Mozilla", "Chrome", "Motorola",
        "iPhone", "LG", "Safari", "Edge", "Firefox", "Samsung", "Pixel", "OnePlus", "Huawei", "HTC", "Nokia", "Xiaomi", "Redmi", "Oppo", "Vivo", "Lenovo", "Realme", "PlayStation", "Xbox", "Linux", "Macintosh", "Android", "iOS", "Dalvik", "Gecko", "KHTML", "AppleWebKit", "Trident", "EdgeHTML", "SamsungBrowser", "PS5", "iPad", "MacBookPro", "MacIntel", "Win64", "X11", "Ubuntu", "Fedora", "Arch", "Manjaro",
        "wv",
        "PostmanRuntime"
    )
    sample(user_agents, 1)
}

read_gz_char <- function(path) {
    con <- gzfile(path, "rb")
    on.exit(close(con), add = TRUE)
    rawToChar(readBin(con, what = "raw", n = 1e9))   # 1 GB upper bound
}


build_req <- function(id, country, randomize_ua, ua, timeout_sec, retries) {
    url <- glue::glue(
        "https://www.facebook.com/ads/library/?",
        "active_status=all&ad_type=all&country={country}",
        "&id={id}&is_targeted_country=false&media_type=all&search_type=page"
    )


    # Set the user agent for this specific request
    current_ua <- if (randomize_ua) get_random_ua() else ua
    # print(current_ua)
    httr2::request(url) |>
        httr2::req_user_agent(current_ua) |>
        httr2::req_timeout(timeout_sec) |>
        httr2::req_retry(max_tries = retries)
}


walk_progress <- function(.x, .f, ...) {
    .f <- purrr::as_mapper(.f, ...)
    pb <- progress::progress_bar$new(
        total = length(.x),
        format = " (:spin) [:bar] :percent | :current / :total | eta: :eta",
        # format = " downloading [:bar] :percent eta: :eta",
        force = TRUE)

    f <- function(...) {
        pb$tick()
        .f(...)
    }
    purrr::walk(.x, f, ...)
}

map_dfr_progress <- function(.x, .f, ...) {
    .f <- purrr::as_mapper(.f, ...)
    pb <- progress::progress_bar$new(
        total = length(.x),
        format = " (:spin) [:bar] :percent | :current / :total | eta: :eta",
        # format = " downloading [:bar] :percent eta: :eta",
        force = TRUE)

    f <- function(...) {
        pb$tick()
        .f(...)
    }
    purrr::map_dfr(.x, f, ...)
}
