#' @title Parse Location from Ad Targeting Dataset
#' @description A function to parse the location strings in the Ad Targeting Dataset and split into separate columns for each level of detail.
#' @param .x A data.frame containing the location string
#' @param loc_var A character string specifying the name of the column in .x that contains the location string
#' @param type A character string specifying the prefix to add to each column of split location details. Default is "include". Should be "include" or "exclude".
#' @param verbose A logical flag specifying whether to display a progress bar during processing. Default is `TRUE`.
#' @return A data.frame with columns for each level of detail in the location.
#' @importFrom purrr map_dfr
#' @examples
#' \dontrun{
#'   ### create a dataset with unique include_location values
#'   distinct_data <- targeting_data %>%
#'     distinct(include_location)
#'
#'   #### parse the location data and join in original dataset
#'   distinct_data %>%
#'     parse_location(include_location, type = "include") %>%
#'     right_join(targeting_data)
#'
#'   ###----####
#'
#'   ### create a dataset with unique exclude_location values
#'   distinct_data <- targeting_data %>%
#'     distinct(exclude_location)
#'
#'   #### parse the location data and join in original dataset
#'   distinct_data %>%
#'     parse_location(exclude_location, type = "exclude") %>%
#'     right_join(targeting_data)
#'
#' }
#' @export
parse_location <- function(.x, loc_var, type = "include", verbose = T) {

    if(verbose){
        mapper <- map_dfr_progress
    } else {
        mapper <- purrr::map_dfr
    }

    .x %>%
        dplyr::select({{loc_var}}) %>%
        dplyr::group_by(group = row_number(), .add = T) %>%
        dplyr::group_split() %>%
        mapper(~{

            parse_location_int(.x, {{loc_var}}, type)

        }) %>%
        dplyr::select({{loc_var}}, dplyr::contains("lvl1"), dplyr::contains("lvl2"), dplyr::contains("lvl3"), dplyr::contains("lvl4"))

}

parse_location_int <- function(.x, loc_var, type = "include") {

    val <- .x %>% dplyr::pull({{loc_var}})
    if(is.na(val)) return(NULL)
    json_format <- val %>%
        jsonlite::fromJSON()

    the_depth <- vec_depth(json_format)

    framed <- json_format %>%
        tibble::enframe()


    if(the_depth == 2){
        fin <- framed %>%
            dplyr::rename(lvl1 = name) %>%
            dplyr::select(-value)
    } else if(the_depth == 3){
        fin <- framed %>%
            tidyr::unnest_longer(value) %>%
            dplyr::rename(lvl2 = value_id) %>%
            dplyr::select(-value)%>%
            dplyr::rename(lvl1 = name)
    } else if(the_depth == 4){
        fin <- framed %>%
            tidyr::unnest_longer(value) %>%
            dplyr::rename(lvl2 = value_id) %>%
            tidyr::unnest_longer(value) %>%
            dplyr::rename(lvl3 = value_id) %>%
            tidyr::unnest_longer(value) %>%
            dplyr::rename(lvl1 = name,
                   lvl4 = value)
    }


    fin <-  fin %>%
        dplyr::select(-dplyr::contains("value_id")) %>%
        dplyr::rename_all(~paste0(type, "_location_", .x)) %>%
        dplyr::mutate({{loc_var}} := val)

    return(fin)
}
