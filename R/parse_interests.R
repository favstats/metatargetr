#' Parse JSON-formatted strings into named character vectors
#'
#' @param include A character vector of JSON-formatted strings
#'
#' @return A list of named character vectors, where each vector represents a parsed JSON object
#'
#' @examples
#' \dontrun{
#' # Parse an example character vector
#' example_json <- c("{\"city\":\"Berlin\",\"zip_code\":\"12345\"}",
#'                   "{\"city\":\"Munich\",\"zip_code\":\"67890\"}")
#' parsed_json <- fix_json(example_json)
#'
#' # Check the resulting list of named character vectors
#' parsed_json
#' }
#'
#' @export
fix_json <- function(include) {
    raw <- include %>%
        stringr::str_replace_all("''", ",") %>%
        paste0("[", ., "]") %>%
        stringr::str_remove_all('\\\\"') %>%
        stringr::str_remove_all('\\\\')

    # print(raw)
    # counttt <<- counttt + 1

    if(raw == "[[]]" | raw == "[{}]" | raw == "[]") raw <- NA

    end <- raw %>%
        purrr::map(~{
            if (!is.na(.x)) {
                parsed_json <- jsonlite::fromJSON(.x)
                unlisted_x <- unlist(parsed_json) %>% na.omit()

                return(paste0(as.character(unlisted_x), ": ", unlisted_x %>% names))
            } else {
                return(NA)
            }
        })

    return(end)
}

#' @title Unnest interest targeting data
#' @description unnest and fix duplicates in interest targeting data from Ad Targeting Dataset
#'
#' The function unnests "include" and "exclude" columns in the Ad Targeting Dataset, and removes duplicates.
#'
#' @param dat a data frame
#' @param the_list the column name to unnest
#' @param new_name the name of the new column after unnesting and fixing duplicates
#' @return a modified data frame with unnested and deduplicated values
#'
#' @examples
#'
#'### example usage:
#'## make sure you have the variable 'archive_id' in your data
#' ad_targeting_data %>%
#'     rowwise() %>%
#'     mutate(include_list = fix_json(include)) %>%
#'     ungroup() %>%
#'     ## the_list: the parsed list of JSON, new_name: what the parsed column should be called
#'    unnest_and_fix_dups(the_list = include_list, new_name = "parsed_include")
#'
#' @export
unnest_and_fix_dups <- function(dat, the_list, new_name) {

    dat %>%
        tidyr::unnest_longer({{the_list}})  %>%
        ### this part is necessary because sometimes there are duplicate targeting criteria
        dplyr::mutate(!!rlang::sym(new_name) := ifelse(
            stringr::str_ends({{the_list}}, "[:digit:]"),
            stringr::str_sub({{the_list}}, 1, nchar({{the_list}})-1),
            {{the_list}})) %>%
        dplyr::group_by(archive_id) %>%
        dplyr::distinct(!!rlang::sym(new_name), .keep_all = T) %>%
        dplyr::ungroup() %>%
        dplyr::select(-{{the_list}})
}




#### example usage:
### make sure you have the variable 'archive_id' in your data
# your_data %>%
#     rowwise() %>%
#     mutate(include_list = fix_json(include)) %>%
#     ungroup() %>%
#     ## the_list: the parsed list of JSON, new_name: what the parsed column should be called
#    unnest_and_fix_dups(the_list = include_list, new_name = "parsed_include")
