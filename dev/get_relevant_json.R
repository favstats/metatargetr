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
