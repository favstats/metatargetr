# Debug script for investigating Facebook Ad Library 403 Forbidden error
# Created: 2026-01-25
#
# FINDINGS:
# =========
# Facebook has implemented a JavaScript-based challenge/verification system.
# When accessing the Ad Library pages programmatically via HTTP, Facebook returns:
# - HTTP 403 Forbidden
# - A small HTML page with JavaScript that posts to a verification endpoint
#
# The verification page looks like:
#   fetch('/__rd_verify_...?challenge=3', { method: 'POST' })
#   .finally(() => window.location.reload());
#
# This means pure HTTP requests (rvest, httr, httr2) will NOT work.
# Browser automation that can execute JavaScript IS REQUIRED.

library(rvest)
library(httr)
library(glue)

# Test ad ID (you can change this to any valid ad ID)
ad_id <- "1103135646905363"
url <- glue("https://www.facebook.com/ads/library/?id={ad_id}")

cat("=== Testing Facebook Ad Library Access ===\n\n")
cat("Target URL:", url, "\n\n")

# ============================================
# TEST 1: Basic rvest::read_html() - Current approach
# ============================================
cat("--- TEST 1: rvest::read_html() (current approach used by get_ad_snapshots) ---\n")
tryCatch({
  html_raw <- rvest::read_html(url)
  cat("SUCCESS: Page loaded!\n")
  cat("Content length:", nchar(as.character(html_raw)), "chars\n")
}, error = function(e) {
  cat("ERROR:", conditionMessage(e), "\n")
})

# ============================================
# TEST 2: Using httr::GET() with status info
# ============================================
cat("\n--- TEST 2: httr::GET() for detailed status info ---\n")
tryCatch({
  resp <- httr::GET(url)
  cat("Status code:", httr::status_code(resp), "\n")
  cat("Status message:", httr::http_status(resp)$message, "\n")
  cat("Content type:", httr::headers(resp)$`content-type`, "\n")
  cat("Content length:", nchar(httr::content(resp, as = "text", encoding = "UTF-8")), "chars\n")
}, error = function(e) {
  cat("ERROR:", conditionMessage(e), "\n")
})

# ============================================
# TEST 3: Using httr::GET() with User-Agent header
# ============================================
cat("\n--- TEST 3: httr::GET() with User-Agent (browser spoofing) ---\n")
tryCatch({
  user_agent <- "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
  resp <- httr::GET(url, httr::add_headers(`User-Agent` = user_agent))
  cat("Status code:", httr::status_code(resp), "\n")
  cat("Status message:", httr::http_status(resp)$message, "\n")
  cat("Content length:", nchar(httr::content(resp, as = "text", encoding = "UTF-8")), "chars\n")
}, error = function(e) {
  cat("ERROR:", conditionMessage(e), "\n")
})

# ============================================
# TEST 4: Using httr::GET() with full browser headers
# ============================================
cat("\n--- TEST 4: httr::GET() with complete browser header set ---\n")
tryCatch({
  resp <- httr::GET(
    url,
    httr::add_headers(
      `User-Agent` = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
      `Accept` = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8",
      `Accept-Language` = "en-US,en;q=0.9",
      `Accept-Encoding` = "gzip, deflate, br",
      `Connection` = "keep-alive",
      `Upgrade-Insecure-Requests` = "1",
      `Sec-Fetch-Dest` = "document",
      `Sec-Fetch-Mode` = "navigate",
      `Sec-Fetch-Site` = "none",
      `Sec-Fetch-User` = "?1"
    )
  )
  cat("Status code:", httr::status_code(resp), "\n")
  cat("Status message:", httr::http_status(resp)$message, "\n")
  content_text <- httr::content(resp, as = "text", encoding = "UTF-8")
  cat("Content length:", nchar(content_text), "chars\n")
  
  # Check if it contains the expected JSON
  if (grepl("snapshot", content_text)) {
    cat("FOUND 'snapshot' in response! Method works.\n")
  } else {
    cat("NO 'snapshot' found - page blocked or requires JS execution\n")
  }
}, error = function(e) {
  cat("ERROR:", conditionMessage(e), "\n")
})

# ============================================
# TEST 5: Analyze the response content
# ============================================
cat("\n--- TEST 5: Analyzing response content ---\n")
tryCatch({
  resp <- httr::GET(url)
  content_text <- httr::content(resp, as = "text", encoding = "UTF-8")
  
  # Check for common patterns
  if (grepl("__rd_verify_", content_text)) {
    cat("CONFIRMED: Response contains JavaScript verification challenge!\n")
    cat("Facebook requires JS execution to pass the challenge.\n")
  }
  if (grepl("executeChallenge", content_text)) {
    cat("CONFIRMED: Contains 'executeChallenge' function - this is the bot detection.\n")
  }
  
  # Save response for inspection
  writeLines(content_text, "dev/last_response.html")
  cat("\nFull response saved to: dev/last_response.html\n")
  
}, error = function(e) {
  cat("ERROR:", conditionMessage(e), "\n")
})

# ============================================
# DIAGNOSIS & SOLUTIONS
# ============================================
cat("\n")
cat("================================================================================\n")
cat("                              DIAGNOSIS\n")
cat("================================================================================\n")
cat("\n")
cat("PROBLEM:\n")
cat("  Facebook has implemented JavaScript-based bot detection.\n")
cat("  Pure HTTP requests return 403 + a JS challenge that must be executed.\n")
cat("  The current rvest::read_html() approach cannot execute JavaScript.\n")
cat("\n")
cat("AFFECTED FUNCTIONS:\n")
cat("  - get_ad_snapshots()  [R/get_media.R]\n")
cat("  - get_deeplink()      [R/get_media.R]\n")
cat("  - get_ad_html()       [R/get_ad_html.R] (likely also affected)\n")
cat("\n")
cat("================================================================================\n")
cat("                           PROPOSED SOLUTIONS\n")
cat("================================================================================\n")
cat("\n")
cat("SOLUTION 1: Use Playwright browser automation (RECOMMENDED)\n")
cat("  - The package already has playwrightr integration in get_ad_report()\n")
cat("  - Modify get_ad_snapshots() to use browser automation\n")
cat("  - Pros: Works, reuses existing code patterns\n")
cat("  - Cons: Slower, requires Playwright setup, can't parallelize as easily\n")
cat("\n")
cat("SOLUTION 2: Use chromote (lightweight headless Chrome)\n")
cat("  - chromote is an R package for headless Chrome DevTools Protocol\n")
cat("  - Lighter weight than full Selenium/Playwright\n")
cat("  - Pros: Simpler setup, native R package\n")
cat("  - Cons: Still slower than HTTP, learning curve\n")
cat("\n")
cat("SOLUTION 3: Pre-authenticated sessions with cookies\n")
cat("  - Export cookies from a logged-in browser session\n")
cat("  - Use httr/httr2 with those cookies\n")
cat("  - Pros: Might bypass bot detection\n")
cat("  - Cons: Cookies expire, fragile, may violate TOS\n")
cat("\n")
cat("SOLUTION 4: Use Facebook's Official Ad Library API\n")
cat("  - https://www.facebook.com/ads/library/api/\n")
cat("  - Requires Meta developer account and access token\n")
cat("  - Pros: Legitimate, stable, fast\n")
cat("  - Cons: Requires API setup, may have rate limits, might not provide\n")
cat("          all the same data (e.g., raw HTML/snapshots)\n")
cat("\n")
cat("================================================================================\n")
cat("RECOMMENDATION: Start with Solution 1 (Playwright) since the infrastructure\n")
cat("                already exists in the package.\n")
cat("================================================================================\n")
