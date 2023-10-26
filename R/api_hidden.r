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
    if (!has_more) {
      if (verbose) cli::cli_progress_done("Reached end of results")
      break
    }
    if (page <= max_pages) wait(sleep_pool)
  }

  dplyr::bind_rows(results)
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


#' Get followers of a user from the hidden API
#'
#' @param secuid The secuid of a user. Currently no better way to obtain it than
#'   opening a users site in the browser, rigtht click to to view page source,
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
    cli::cli_progress_step(
      msg = ifelse(length(follower_data) == 0L, "Getting followers...", "Getting more followers..."),
      msg_done = "Got {length(follower_data)} followers."
    )
    resp <- httr2::request("https://www.tiktok.com/api/user/list/") %>%
      httr2::req_url_query(
        count = "198", # for some reason this is the highest number that works
        from_page = "user",
        history_len = "3",
        minCursor = new_data$minCursor,
        secUid = secuid
      ) %>%
      httr2::req_headers(
        `User-Agent` = "Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/117.0",
        Accept = "*/*",
        `Accept-Language` = "en-US,en;q=0.5",
        `Accept-Encoding` = "gzip, deflate, br",
        #Cookie = "cookie-consent={%22ga%22:true%2C%22af%22:true%2C%22fbp%22:true%2C%22lip%22:true%2C%22bing%22:true%2C%22ttads%22:true%2C%22reddit%22:true%2C%22criteo%22:true%2C%22version%22:%22v9%22}; ttwid=1%7Crew9hB1p8Fr-K81LlWcmFcXaZFkQs9ZJP-OgDn3TRKU%7C1695288093%7C305a893a9fd689457f7a65e443f4d0e1270959c0c4819f94ad6a23b2eab9ab7b; tt_chain_token=26UfEV4jsnRAm77A/cvhig==; __tea_cache_tokens_1988={%22_type_%22:%22default%22%2C%22user_unique_id%22:%227280883409344661025%22%2C%22timestamp%22:1695212781348}; tiktok_webapp_theme=light; odin_tt=7fbff6640c4947318cdd142cf5ba600531ab5b79d84b717b19860d04b95741c590bfde2ddd95ecfc7f573422156bbde96af2eff2b089f9f5eaf00eb6b6e95a7a59f6a1d6dbefb56c8d491611b51c2cf2; msToken=2xSrmNoWbGYpAVws2WULf3cU6ydKK8-7XG6kdS2QSWOsS5hQIb2Pr3rpzt_EjTGMJ-c3y2d_bS1TGCfZPOIEnCrKQtPC6FcHORuW22y6-DejgvvL701I6P8BcqnAjosgPENMVbXDgZ_h; passport_csrf_token=e07d3487c11ce5258a3b85657595a022; passport_csrf_token_default=e07d3487c11ce5258a3b85657595a022; tt_csrf_token=jDRXJy1K-p1fgsXr_skJyKTWtugHO0ziJ-oc; csrfToken=IE1JkDjV-VsqbED4VSl8LRiuCqXCx24_NgMA; s_v_web_id=verify_lmtbja9s_nq8USjA3_9WTw_4sap_AXvc_ufc9X7JO7FCD; multi_sids=7157331086224638981%3A904ec87f0a6c8935f76e6ffb66d233ee; cmpl_token=AgQQAPORF-RO0rNtHBQudR08_2t90T6ZP6MUYMy7TA; sid_guard=904ec87f0a6c8935f76e6ffb66d233ee%7C1695309609%7C15552000%7CTue%2C+19-Mar-2024+15%3A20%3A09+GMT; uid_tt=a690a75b3ec7de59fad6585845759e2cb7c42e87251d9bcb28c2aa09c949845e; uid_tt_ss=a690a75b3ec7de59fad6585845759e2cb7c42e87251d9bcb28c2aa09c949845e; sid_tt=904ec87f0a6c8935f76e6ffb66d233ee; sessionid=904ec87f0a6c8935f76e6ffb66d233ee; sessionid_ss=904ec87f0a6c8935f76e6ffb66d233ee; sid_ucp_v1=1.0.0-KDdlNGI4N2E1ZGIzMjUxM2UwY2Y1NDM1OWIxMWRiM2RkNDVjZmQ3NzIKIAiFiJ-yutb8qWMQqb6xqAYYswsgDDDS5c-aBjgHQPQHEAMaCHVzZWFzdDJhIiA5MDRlYzg3ZjBhNmM4OTM1Zjc2ZTZmZmI2NmQyMzNlZQ; ssid_ucp_v1=1.0.0-KDdlNGI4N2E1ZGIzMjUxM2UwY2Y1NDM1OWIxMWRiM2RkNDVjZmQ3NzIKIAiFiJ-yutb8qWMQqb6xqAYYswsgDDDS5c-aBjgHQPQHEAMaCHVzZWFzdDJhIiA5MDRlYzg3ZjBhNmM4OTM1Zjc2ZTZmZmI2NmQyMzNlZQ; store-idc=useast2a; store-country-code=de; store-country-code-src=uid; tt-target-idc=useast2a; tt-target-idc-sign=WxGDtKcuip-vU4AP6Jvb183wQR1qnbO-KZ3hBQ8Uwee0_SDEh7m6BsqISkCnWTWT9_GIzhqaeNuNbramOjwx29YGNXgAPyk0pPNOxVxuQFGPbNZ54g5te7Bkn4-6_Hoj0TBkfpvz5B5doX4uz8PNNxjfm0m25d9svl3y-P3wTC7kwQxqSvSYZed5poBfjCeisel_kf9AK0EdRlBuXb2EjylSY6Jv-2wIKGfXYer_s9ZOADctAMiw25FvvY1tdgGdTxCo__N9S44qXA14bV9PGR15dG88vinZa8SHxTpQ5oDcdErSZ7DgP0ytYr6Mf44lR3S1V2G-cHP_HUk3E1EQNIi6lnKOaz0VXwKTdcC2--vnaqobz_aCjFfASQVPwvOd-_jxtGaIxNHMOGuEky4OypeoavCZlGJXqI1JZKHZ7KXYeXHZqVgSYvIGBdTqMO0OVguQywbQXFzXof8ePPD3TyuNKDn2rAP1rwBNfNQB1JCUjmdbOjNyVJYiv5id_Fgm; _waftokenid=eyJ2Ijp7ImEiOiJNS0FPWjFGdXg0eW9mOVRQT01qRjkxNVEyRmNscTR4RGtYOGZaclZLckpBPSIsImIiOjE2OTUzMDk2MTIsImMiOiJjcENzc3JPeENpL0xVUm03b3hyNWFVdlpHY2xHcFhBTWM5MDI5YW03WGxrPSJ9LCJzIjoiRUdRd0RUVUt4YklHRzczYTlTT1ZiMHlnb1dpOUhyMllMUDNsVElnVXQycz0ifQ; passport_fe_beating_status=true; perf_feed_cache={%22expireTimestamp%22:1695481200000%2C%22itemIds%22:[%227278220436150783264%22%2C%227279116098820214049%22%2C%227281234108343127329%22]}; msToken=2xSrmNoWbGYpAVws2WULf3cU6ydKK8-7XG6kdS2QSWOsS5hQIb2Pr3rpzt_EjTGMJ-c3y2d_bS1TGCfZPOIEnCrKQtPC6FcHORuW22y6-DejgvvL701I6P8BcqnAjosgPENMVbXDgZ_h",
        TE = "trailers",
      ) %>%
      httr2::req_options(cookie = prep_cookies(cookies)) |>
      httr2::req_perform()

    new_data <- httr2::resp_body_json(resp)
    follower_data <- c(follower_data, purrr::pluck(new_data, "userList", .default = list()))
  }
  cli::cli_progress_done()

  cli::cli_progress_step(
    msg = "Parsing results"
  )
  return(parse_followers(follower_data))

}
