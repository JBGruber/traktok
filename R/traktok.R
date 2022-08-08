#' Get video URLs and metadata from videos
#'
#' @param video_urls vector of URLs to TikTok videos.
#' @param save_video logical. Should the videos be downloaded.
#' @param dir directory to save videos files to.
#' @param sleep_pool a vector of numbers from which a waiting period is randomly
#'   drawn.
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
#' tt_videos("https://www.tiktok.com/@tiktok/video/7106594312292453675")
#' }
tt_videos <- function(video_urls,
                      save_video = FALSE,
                      dir = ".",
                      sleep_pool = 1:10,
                      ...) {

  purrr::map_df(video_urls, function(u) {
    video_id = extract_regex(u, "(?<=/video/)(.+?)(?=\\?|$)|(?<=https://vm.tiktok.com/).+?(?=/|$)")
    message("Getting video ", video_id)
    out <- save_tiktok(u, save_video = save_video, dir = dir)
    sleep <- stats::runif(1) * sample(sleep_pool, 1L)
    message("\t...waiting ", sleep, " seconds")
    Sys.sleep(sleep)
    return(out)
  })

}


#' Get comments under a video.
#'
#' @param video_urls vector of URLs to TikTok videos.
#' @param max_comments number of comments to return.
#' @param sleep_pool a vector of numbers from which a waiting period is randomly
#'   drawn.
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
#' tt_comments("https://www.tiktok.com/@tiktok/video/7106594312292453675")
#' }
tt_comments <- function(video_urls,
                        max_comments = Inf,
                        sleep_pool = 1:10,
                        ...) {

  purrr::map_df(video_urls, function(u) {
    video_id = extract_regex(u, "(?<=/video/)(.+?)(?=\\?|$)")
    message("Getting comments for video ", video_id, "...")
    out <- save_video_comments(u, max_comments = max_comments, sleep_pool = sleep_pool)
    sleep <- stats::runif(1) * sample(sleep_pool, 1L)
    message("\t...waiting ", sleep, " seconds")
    Sys.sleep(sleep)
    return(out)
  })

}


#' Get user videos
#'
#' @param user_url vector of URLs to TikTok accounts.
#' @param sleep_pool a vector of numbers from which a waiting period is randomly
#'   drawn.
#'
#' @details The function will wait between scraping two accounts to make it less
#'   obvious that a scraper is accessing the site. The period is drawn randomly
#'   from the `sleep_pool` and multiplied by a random fraction.
#'
#' @return a data.frame
#' @export
#'
#' @examples
#' \dontrun{
#' tt_user_videos("https://www.tiktok.com/@tiktok")
#' }
tt_user_videos <- function(user_url,
                           sleep_pool = 1:10,
                           ...) {

  purrr::map_df(user_url, function(u) {
    video_id = extract_regex(u, "(?<=/video/)(.+?)(?=\\?|$)")
    message("Getting user videos from ", video_id, "...")
    out <- get_account_video_urls(u, ...)
    sleep <- stats::runif(1) * sample(sleep_pool, 1L)
    message("\t...waiting ", sleep, " seconds")
    Sys.sleep(sleep)
    return(out)
  })

}



#' Get json file from a TikTok URL
#'
#' @param url a URL to a TikTok video or account
#' @param cookiefile path to your cookiefile. See details.
#'
#' @details To get a valid cookiefile, you need to visit TikTok in your browser
#'   and then use, for example, the Browser extension "Get cookies.txt"
#'   (available for Chromium based Browsers an Firefox). If you experience
#'   errors, the cokkies might have expired. Just open TikTok in your browser
#'   again and export a new file in this case.
#'
#' @export
tt_json <- function(url,
                    cookiefile = getOption("cookiefile")) {

  cookies <- tt_read_cookies(cookiefile)
  cookies_str <- vapply(cookies, curl::curl_escape, FUN.VALUE = character(1))
  cookie <- paste(names(cookies), cookies_str, sep = "=", collapse = ";")
  headers <- getOption("headers")

  req <- httr2::request(url) |>
    httr2::req_headers(
      'Accept-Encoding' = 'gzip, deflate, sdch',
      'Accept-Language' = 'en-US,en;q=0.8',
      'Upgrade-Insecure-Requests' = '1',
      'User-Agent' = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36',
      'Accept' = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
      'Cache-Control' = 'max-age=0',
      'Connection' = 'keep-alive'
    ) |>
    httr2::req_options(cookie = cookie) |>
    httr2::req_timeout(seconds = 30L)

  res <- httr2::req_perform(req)

  res |>
    httr2::resp_body_html() |>
    rvest::html_node("[id='SIGI_STATE']") |>
    rvest::html_text() |>
    jsonlite::fromJSON() |>
    c(url_full = res$url)

}


#' @noRd
save_tiktok <- function(video_url,
                        save_video = TRUE,
                        dir = ".",
                        ...) {

  tt_json = tt_json(video_url, ...)

  if (tt_json$url_full == "https://www.tiktok.com/") {

    warning(video_url, " can't be reached.")
    return(tibble::tibble())

  } else {

    video_url <- tt_json$url_full
    regex_url = extract_regex(video_url, "(?<=@).+?(?=\\?|$)")
    video_fn <- paste0(gsub('/', '_', regex_url), '.mp4')
    video_id = vapply(tt_json[["ItemModule"]], function(x) x[["video"]][["id"]],
                      FUN.VALUE = character(1))

    tt_video_url = tt_json[["ItemList"]][["video"]][["preloadList"]][["url"]]


    video_timestamp <- tt_json[["ItemModule"]][[video_id]][["createTime"]] |>
      as.integer() |>
      as.POSIXct(tz = "UTC", origin = "1970-01-01")

    data_list <- list(
      video_id = video_id,
      video_timestamp = video_timestamp,
      video_length = tt_json[["ItemModule"]][[video_id]][["video"]][["duration"]],
      video_title = tt_json[['ItemModule']][[video_id]][['desc']],
      video_locationcreated = tt_json[['ItemModule']][[video_id]][['locationCreated']],
      video_diggcount = tt_json[['ItemModule']][[video_id]][['stats']][['diggCount']],
      video_sharecount = tt_json[['ItemModule']][[video_id]][['stats']][['shareCount']],
      video_commentcount = tt_json[['ItemModule']][[video_id]][['stats']][['commentCount']],
      video_playcount = tt_json[['ItemModule']][[video_id]][['stats']][['playCount']],
      video_description = tt_json[['ItemModule']][[video_id]][['desc']],
      video_is_ad = tt_json[['ItemModule']][[video_id]][['isAd']],
      video_fn = video_fn,
      author_username = tt_json[['ItemModule']][[video_id]][['author']],
      author_name = tt_json[['ItemModule']][[video_id]][['authorName']],
      author_followercount = tt_json[['ItemModule']][[video_id]][['authorStats']][['followerCount']],
      author_followingcount = tt_json[['ItemModule']][[video_id]][['authorStats']][['followingCount']],
      author_heartcount = tt_json[['ItemModule']][[video_id]][['authorStats']][['heartCount']],
      author_videocount = tt_json[['ItemModule']][[video_id]][['authorStats']][['videoCount']],
      author_diggcount = tt_json[['ItemModule']][[video_id]][['authorStats']][['diggCount']]
    )

    if (save_video) curl::curl_download(tt_video_url, paste0(dir, "/", video_fn), quiet = FALSE)

    return(tibble::tibble(data.frame(lapply(data_list, function(x) ifelse(is.null(x), NA, x)))))

  }

}


#' @noRd
save_video_comments <- function(video_url,
                                cursor_resume = 0,
                                max_comments = Inf,
                                sleep_pool = 1:10,
                                cookiefile = getOption("cookiefile")) {

  cursor = cursor_resume

  tt_json = tt_json(video_url, cookiefile = cookiefile)
  video_url <- tt_json$url_full
  video_url = extract_regex(video_url, "(.+?)(?=\\?|$)")
  video_id = extract_regex(video_url, "(?<=/video/)(.+?)(?=\\?|$)")

  cookies <- tt_read_cookies(cookiefile)
  cookies_str <- vapply(cookies, curl::curl_escape, FUN.VALUE = character(1))
  cookie <- paste(names(cookies), cookies_str, sep = "=", collapse = ";")
  data_list <- list()

  while (cursor < max_comments) {
    message("\t...retrieving comments ", cursor, "+")

    req <- httr2::request('https://www.tiktok.com/api/comment/list/') |>
      httr2::req_headers(
        'Accept-Encoding' = 'gzip, deflate, sdch',
        'Accept-Language' = 'en-US,en;q=0.8',
        'Upgrade-Insecure-Requests' = '1',
        'User-Agent' = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36',
        'Accept' = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Cache-Control' = 'max-age=0',
        'Connection' = 'keep-alive',
        referer = video_url
      ) |>
      httr2::req_options(cookie = cookie) |>
      httr2::req_url_query('aweme_id' = video_id,
                           'count' = '20',
                           'cursor' = as.character(cursor)) |>
      httr2::req_timeout(seconds = 30L)

    res <- try(httr2::req_perform(req) |>
                 httr2::resp_body_json())

    if (!methods::is(res, "try-error")) {

      data_df <- tibble::tibble(
        comment_id = vapply(res[["comments"]], function(x) x[["cid"]], FUN.VALUE = character(1)),
        comment_text = vapply(res[["comments"]], function(x) x[["text"]], FUN.VALUE = character(1)),
        comment_create_time = vapply(res[["comments"]], function(x) as.integer(x[["create_time"]]), FUN.VALUE = integer(1)) |>
          as.POSIXct(tz = "UTC", origin = "1970-01-01"),
        comment_diggcount = vapply(res[["comments"]], function(x) x[["digg_count"]], FUN.VALUE = integer(1)),
        video_url = video_url,
        user_id = vapply(res[["comments"]], function(x) x[["user"]][["uid"]], FUN.VALUE = character(1)),
        user_nickname = vapply(res[["comments"]], function(x) x[["user"]][["nickname"]], FUN.VALUE = character(1)),
        user_signature = vapply(res[["comments"]], function(x) x[["user"]][["signature"]], FUN.VALUE = character(1))
      )

      cursor <- cursor + nrow(data_df)

      data_list <- c(
        data_list,
        list(data_df)
      )

      if (nrow(data_df) == 0) max_comments <-  0

      Sys.sleep(stats::runif(1) * sample(sleep_pool, 1L))

    } else {
      max_comments <-  0
    }

  }

  return(do.call("rbind", data_list))

}


#' @noRd
get_account_video_urls <- function(user_url,
                                   ...) {

  tt_json = tt_json(user_url, ...)
  video_ids = tt_json[["ItemList"]][["user-post"]][["list"]]
  user_id = tt_json[["UserPage"]][["uniqueId"]]

  tibble::tibble(
    user_id = user_id,
    user_name = tt_json[["UserModule"]][["users"]][["jordanalmani"]][["uniqueId"]],
    user_nickname = tt_json[["UserModule"]][["users"]][["jordanalmani"]][["nickname"]],
    user_signature = tt_json[["UserModule"]][["users"]][["jordanalmani"]][["signature"]],
    user_avatar = tt_json[["UserModule"]][["users"]][["jordanalmani"]][["avatarThumb"]],
    user_commercial = tt_json[["UserModule"]][["users"]][["jordanalmani"]][["commerceUserInfo"]][["commerceUser"]],
    user_region = tt_json[["UserModule"]][["users"]][["jordanalmani"]][["region"]],
    video_urls <- paste0(
      'https://www.tiktok.com/@',
      user_id,
      '/video/',
      video_ids
    )
  )

}


#' @noRd
get_hashtag_video_urls <- function(hashtag,
                                   max_videos = Inf,
                                   cookiefile = getOption("cookiefile"),
                                   ...) {

  if (length(hashtag) != 1 & !is(hashtag, "character"))
    stop("Please provide exactly one hashtag")

  search_url <- paste0("https://www.tiktok.com/tag/", hashtag)
  # first page
  data1 <- tt_json(search_url)
  challengeID <- data1[["ChallengePage"]][["challengeInfo"]][["challenge"]][["id"]]
  video_count <- data1[["ChallengePage"]][["challengeInfo"]][["challenge"]][["stats"]][["videoCount"]]
  max_videos <- min(c(
    max_videos,
    video_count
  ))

  message(video_count, " videos found for ", hashtag)
  data_list <- list(parse_search(data1, api = FALSE))
  cursor <- nrow(data_list[[1]])

  cookies <- tt_read_cookies(cookiefile)
  cookies_str <- vapply(cookies, curl::curl_escape, FUN.VALUE = character(1))
  cookie <- paste(names(cookies), cookies_str, sep = "=", collapse = ";")

  while (cursor < max_videos) {

    message("\t...retrieving videos ", cursor, "+")

    req <- httr2::request('https://www.tiktok.com/api/challenge/item_list/') |>
      httr2::req_headers(
        'Accept-Encoding' = 'gzip, deflate, sdch',
        'Accept-Language' = 'en-US,en;q=0.8',
        'Upgrade-Insecure-Requests' = '1',
        'User-Agent' = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36',
        'Accept' = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Cache-Control' = 'max-age=0',
        'Connection' = 'keep-alive'
      ) |>
      httr2::req_options(cookie = cookie) |>
      httr2::req_url_query("aid"="1988",
                           'count' = '30',
                           "challengeID" = challengeID,
                           'cursor' = as.character(cursor)) |>
      httr2::req_timeout(seconds = 30L)

    res <- try(httr2::req_perform(req) |>
                 httr2::resp_body_json())

    if (!methods::is(res, "try-error")) {

      data_list <- c(
        data_list,
        list(parse_search(res, api = TRUE))
      )
      cursor <- cursor + nrow(tail(data_list, 1)[[1]])
    } else {
      max_videos <- 0
    }
  }

  return(do.call("rbind", data_list))

}


#' @noRd
parse_search <- function(json, api) {

  if (api) {
    entries <- "itemList"
    date_class <- integer(1)
    auth_name <- function(x) x[['author']][["uniqueId"]]
  } else {
    entries <- "ItemModule"
    date_class <- character(1)
    auth_name <- function(x) x[['author']]

  }

  video_timestamp <- vapply(json[[entries]], function(x) x[["createTime"]], FUN.VALUE = date_class) |>
    as.integer() |>
    as.POSIXct(tz = "UTC", origin = "1970-01-01")

  tibble::tibble(
    video_id = vapply(json[[entries]], function(x) x[["video"]][["id"]], FUN.VALUE = character(1)),
    video_timestamp = video_timestamp,
    video_url = vapply(json[[entries]], function(x) x[["video"]][["downloadAddr"]], FUN.VALUE = character(1)),
    video_length = vapply(json[[entries]], function(x) x[["video"]][["duration"]], FUN.VALUE = integer(1)),
    video_title = vapply(json[[entries]], function(x) x[['desc']], FUN.VALUE = character(1)),
    video_diggcount = vapply(json[[entries]], function(x) x[['stats']][['diggCount']], FUN.VALUE = integer(1)),
    video_sharecount = vapply(json[[entries]], function(x) x[['stats']][['shareCount']], FUN.VALUE = integer(1)),
    video_commentcount = vapply(json[[entries]], function(x) x[['stats']][['commentCount']], FUN.VALUE = integer(1)),
    video_playcount = vapply(json[[entries]], function(x) x[['stats']][['playCount']], FUN.VALUE = integer(1)),
    video_description = vapply(json[[entries]], function(x) x[['desc']], FUN.VALUE = character(1)),
    video_is_ad = vapply(json[[entries]], function(x) x[['isAd']], FUN.VALUE = logical(1)),
    author_name = vapply(json[[entries]], auth_name, FUN.VALUE = character(1)),
    author_followercount = vapply(json[[entries]], function(x) x[['authorStats']][['followerCount']], FUN.VALUE = integer(1)),
    author_followingcount = vapply(json[[entries]], function(x) x[['authorStats']][['followingCount']], FUN.VALUE = integer(1)),
    author_heartcount = vapply(json[[entries]], function(x) x[['authorStats']][['heartCount']], FUN.VALUE = integer(1)),
    author_videocount = vapply(json[[entries]], function(x) x[['authorStats']][['videoCount']], FUN.VALUE = integer(1)),
    author_diggcount = vapply(json[[entries]], function(x) x[['authorStats']][['diggCount']], FUN.VALUE = integer(1))
  )

}
