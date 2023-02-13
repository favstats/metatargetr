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
