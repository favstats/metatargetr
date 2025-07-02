parse_ad_htmls <- function(
        html_dir = here::here("data", "html_cache"),
        idle_cores = 2
){
    htmls <- list.files(here::here("data", "html_cache"), full.names = T)
    progressr::handlers(global = TRUE)

    progressr::with_progress({
        p <- progressr::progressor(steps = length(htmls))
        future::plan(future::multisession, workers = parallel::detectCores() - idle_cores)
        htmls %>%
            furrr::future_map_dfr(~{
                read_gz_char(.x) %>%
                    extract_html_and_otherProps()
                p()
            },
            .options = furrr::furrr_options(seed = TRUE)
            )
    })
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
        as.data.frame() %>%
        rename_all(function(x){str_remove_all(x, "deeplinkAdCard\\.|snapshot\\.")})

    # Always return as a tibble, even if NA or empty
    cbind(html = if (!is.null(html_val)) html_val else NA_character_,
          otherProps)
}




# EXAMPLE USEAGE:
# df <- parse_ad_htmls(here::here("data", "html_cache"))
