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
  search_id <- NULL

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
        "offset" = offset,
        search_id = search_id
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
    search_id <- attr(results[[page]], "search_id")
    has_more <- attr(results[[page]], "has_more")
    done_msg <- glue::glue("Found {nrow(results[[page]])} videos.")
    page <- page + 1
    if (!has_more) {
      if (verbose) cli::cli_progress_done("Reached end of results")
      break
    }
    if (page <= max_pages) wait(sleep_pool)
  }

  video_id <- NULL
  dplyr::bind_rows(results) |>
    dplyr::filter(!is.na(video_id))
}


### does not work because of code challenge happening in the browser
# #' Get infos about a user from the hidden API
# #'
# #' @param username A URL to a video. Currently does not work with the user's
# #'   page.
# #' @param parse Whether to parse the data into a data.frame (set to FALSE to get
# #'   the full list).
# #'
# #' @return A data.frame or list, depending on the parse setting.
# #' @export
# #' @inheritParams tt_search_hidden
# tt_user_info_hidden <- function(username,
#                                 parse = TRUE,
#                                 sleep_pool = 1:10,
#                                 max_tries = 5L,
#                                 cookiefile = NULL,
#                                 verbose = TRUE) {
#
#   cookies <- auth_hidden(cookiefile)
#
#   purrr::map(username, function(u) {
#     u <- sub("^@", "", urltools::domain(u))
#     if (verbose) cli::cli_progress_step("Getting user {u}")
#     html <- httr2::request(glue::glue("https://www.tiktok.com/@{u}")) |>
#       httr2::req_headers(
#         "User-Agent" = "Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/117.0",
#         "Accept" = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
#         "Accept-Language" = "en-US,en;q=0.5",
#         "Accept-Encoding" = "gzip, deflate, br",
#         "Upgrade-Insecure-Requests" = "1",
#         "Sec-Fetch-Dest" = "document",
#         "Sec-Fetch-Mode" = "navigate",
#         "Sec-Fetch-Site" = "cross-site",
#         "Connection" = "keep-alive"
#       ) |>
#       httr2::req_options(cookie = cookies) |>
#       httr2::req_perform() |>
#       httr2::resp_body_html()
#
#     json <- html |>
#       rvest::html_element("#__UNIVERSAL_DATA_FOR_REHYDRATION__") |>
#       rvest::html_text()
#
#     if (!is.na(json)) {
#       user_data <- json |>
#         jsonlite::fromJSON()
#     } else {
#       cli::cli_alert_warning("Could not retrieve data for user {u}")
#       user_data <- list()
#     }
#
#     wait(sleep_pool)
#     if (parse) {
#       return(parse_user(user_data))
#     } else {
#       return(user_data)
#     }
#   }) |>
#     dplyr::bind_rows()
# }


#' Get followers and following of a user from the hidden API
#'
#' @param secuid The secuid of a user. Currently no better way to obtain it than
#'   opening a users site in the browser, right click to to view page source,
#'   then search for "secUid".
#' @inheritParams tt_search_hidden
#'
#' @return a data.frame of followers
#' @export
#'
#' @examples
#' \dontrun{
#' tt_get_follower_hidden("MS4wLjABAAAAun-1Cl5bjjlMXYCkKo58aPekMkPkkFkWB0y0-lSIJ-EMQ_1RLj1slviOVj0Vpuv9")
#' }
tt_get_following_hidden <- function(secuid,
                                    sleep_pool = 1:10,
                                    max_tries = 5L,
                                    cookiefile = NULL,
                                    verbose = TRUE) {

  cookies <- auth_hidden(cookiefile)

  new_data <- list(minCursor = 0,
                   total = Inf,
                   hasMore = TRUE)
  follower_data <- list()

  while (new_data$hasMore) {
    if (verbose) cli::cli_progress_step(
      msg = ifelse(length(follower_data) == 0L, "Getting followers...", "Getting more followers..."),
      msg_done = "Got {length(follower_data)} followers."
    )
    resp <- httr2::request("https://www.tiktok.com/api/user/list/") |>
      httr2::req_url_query(
        count = "198", # for some reason this is the highest number that works
        from_page = "user",
        history_len = "3",
        minCursor = new_data$minCursor,
        secUid = secuid
      ) |>
      httr2::req_headers(
        `User-Agent` = "Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/117.0",
        Accept = "*/*",
        `Accept-Language` = "en-US,en;q=0.5",
        `Accept-Encoding` = "gzip, deflate, br",
        TE = "trailers",
      ) |>
      httr2::req_options(cookie = prep_cookies(cookies)) |>
      httr2::req_retry(max_tries = max_tries) |>
      httr2::req_perform()

    new_data <- try(httr2::resp_body_json(resp), silent = TRUE)
    if (methods::is(new_data, "try-error")) {
      new_data <- list(minCursor = 0,
                       total = Inf,
                       hasMore = TRUE)
    } else {
      follower_data <- c(follower_data, purrr::pluck(new_data, "userList", .default = list()))
    }
    if (new_data$hasMore) wait(sleep_pool)
  }
  if (verbose) cli::cli_progress_done()

  if (verbose) cli::cli_progress_step(
    msg = "Parsing results"
  )
  return(parse_followers(follower_data))

}

#' @rdname tt_get_following_hidden
#' @export
tt_get_follower_hidden <- function(secuid,
                                   sleep_pool = 1:10,
                                   max_tries = 5L,
                                   cookiefile = NULL,
                                   verbose = TRUE) {

  cookies <- auth_hidden(cookiefile)

  new_data <- list(minCursor = 0,
                   total = Inf,
                   hasMore = TRUE)
  follower_data <- list()

  while (new_data$hasMore) {
    if (verbose) cli::cli_progress_step(
      msg = ifelse(length(follower_data) == 0L, "Getting followers...", "Getting more followers..."),
      msg_done = "Got {length(follower_data)} followers."
    )
    resp <- httr2::request("https://www.tiktok.com/api/user/list/") |>
      httr2::req_url_query(
        count = "198", # for some reason this is the highest number that works
        from_page = "user",
        history_len = "3",
        scene = "67",
        minCursor = new_data$minCursor,
        secUid = secuid
      ) |>
      httr2::req_headers(
        `User-Agent` = "Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/117.0",
        Accept = "*/*",
        `Accept-Language` = "en-US,en;q=0.5",
        `Accept-Encoding` = "gzip, deflate, br",
        TE = "trailers",
      ) |>
      httr2::req_options(cookie = prep_cookies(cookies)) |>
      httr2::req_retry(max_tries = max_tries) |>
      httr2::req_perform()

    new_data <- try(httr2::resp_body_json(resp), silent = TRUE)
    if (methods::is(new_data, "try-error")) {
      new_data <- list(minCursor = 0,
                       total = Inf,
                       hasMore = TRUE)
    } else {
      follower_data <- c(follower_data, purrr::pluck(new_data, "userList", .default = list()))
    }
    if (new_data$hasMore) wait(sleep_pool)
  }
  if (verbose) cli::cli_progress_done()

  if (verbose) cli::cli_progress_step(
    msg = "Parsing results"
  )
  return(parse_followers(follower_data))

}
