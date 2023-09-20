#' Get json string from a TikTok URL using the hidden API
#'
#' @param url a URL to a TikTok video or account
#' @param max_tries how often should the request be tried before throwing an error
#' @param cookiefile path to your cookiefile. Default is to request a new one
#'   from TikTok.com and place it in the location returned by
#'   \code{tools::R_user_dir("traktok", "config")} and set the option cookiefile
#'   to this location.
#' @export
tt_request_hidden <- function(url,
                              max_tries = 5L,
                              cookiefile = NULL) {

  cookies <- auth_hidden(cookiefile)

  req <- httr2::request(url) |>
    httr2::req_headers(
      "Accept-Encoding" = "gzip, deflate, sdch",
      "Accept-Language" = "en-US,en;q=0.8",
      "Upgrade-Insecure-Requests" = "1",
      "User-Agent" = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36",
      "Accept" = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
      "Cache-Control" = "max-age=0",
      "Connection" = "keep-alive"
    ) |>
    httr2::req_options(cookie = prep_cookies(cookies)) |>
    httr2::req_retry(max_tries = max_tries) |>
    httr2::req_timeout(seconds = 60L) |>
    httr2::req_error(is_error = function(x) FALSE)

  res <- httr2::req_perform(req)
  status <- httr2::resp_status(res)
  if (status >= 400)
    cli::cli_warn("Retrieving {url} resulted in html status {status}, the row will contain NAs.")

  out <- res |>
    httr2::resp_body_html() |>
    rvest::html_node("[id='SIGI_STATE']") |>
    rvest::html_text()

  if (nchar(out) < 10) stop("no json found")

  attr(out, "url_full") <- res$url
  attr(out, "html_status") <- status
  attr(out, "set-cookies") <- httr2::resp_headers(res)[["set-cookie"]]
  return(out)
}


#' Search videos
#'
#' @param query query as one string
#' @param offset how many videos to skip. For example, if you already have the
#'   first X of a search.
#' @param max_pages how many pages to get before stopping the search.
#' @param sleep_pool a vector of numbers from which a waiting period is randomly
#'   drawn.
#' @param max_tries how often to retry if a request fails.
#' @param cookiefile path to your cookiefile. Default is to request a new one
#'   from TikTok.com and place it in the location returned by
#'   \code{tools::R_user_dir("traktok", "config")} and set the option cookiefile
#'   to this location.
#' @param verbose logical. Print status messages.
#'
#' @details The function will wait between scraping two videos to make it less
#'   obvious that a scraper is accessing the site. The period is drawn randomly
#'   from the `sleep_pool` and multiplied by a random fraction.
#'
#' @return a data.frame
#' @export
#'
#' @examples
#' \dontrun{
#' tt_search_hidden("#rstats", max_pages = 2)
#' }
tt_search_hidden <- function(query,
                          offset = 0,
                          max_pages = Inf,
                          sleep_pool = 1:10,
                          max_tries = 5L,
                          cookiefile = NULL,
                          verbose = TRUE) {

  cookies <- auth_hidden(cookiefile)

  results <- list()
  page <- 1
  has_more <- TRUE
  done_msg <- ""
  while(page <= max_pages && has_more) {
    if (verbose) cli::cli_progress_step(
      "Getting page {page}",
      # for some reason already uses updated page value
      msg_done = "Got page {page - 1}. {done_msg}"
    )

    req <- httr2::request("https://www.tiktok.com/api/search/general/full/") |>
      httr2::req_url_query(
        aid = "1988",
        "cookie_enabled" = "true",
        "from_page" = "search",
        "keyword" = query,
        "offset" = offset
      ) |>
      httr2::req_options(cookie = prep_cookies(cookies)) |>
      httr2::req_headers(
        authority = "www.tiktok.com",
        accept = "*/*",
        `accept-language` = "en-GB,en;q=0.9,de-DE;q=0.8,de;q=0.7,en-US;q=0.6",
        `sec-ch-ua` = "\"Chromium\";v=115\", \"Not/A)Brand\";v=\"99",
        `sec-ch-ua-mobile` = "?0",
        `sec-ch-ua-platform` = "\"Linux\"",
        `sec-fetch-dest` = "empty",
        `sec-fetch-mode` = "cors",
        `sec-fetch-site` = "same-origin",
        `user-agent` = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36",
      ) |>
      httr2::req_retry(max_tries = max_tries) |>
      httr2::req_timeout(seconds = 60L) |>
      httr2::req_error(is_error = function(x) FALSE)

    resp <- httr2::req_perform(req)
    status <- httr2::resp_status(resp)
    if (status < 400L) results[[page]] <- parse_search(resp)
    offset <- attr(results[[page]], "cursor")
    has_more <- attr(results[[page]], "has_more")
    done_msg <- glue::glue("Found {nrow(results[[page]])} videos.")
    page <- page + 1
    wait(sleep_pool)
  }

  dplyr::bind_rows(results)
}
