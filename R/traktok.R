get_tiktok_json <- function(video_url,
                            cookiefile = getOption("cookiefile")) {

  cookies <- tik_read_cookies(cookiefile)
  cookies_str <- vapply(cookies, curl::curl_escape, FUN.VALUE = character(1))
  cookie <- paste(names(cookies), cookies_str, sep = "=", collapse = ";")
  headers <- getOption("headers")

  req <- httr2::request(video_url) |>
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


get_account_video_urls <- function(user_url) {
  tt_json = get_tiktok_json(user_url)
  video_ids = tt_json[["ItemList"]][["user-post"]][["list"]]
  tt_account = tt_json[["UserPage"]][["uniqueId"]]
  video_urls <- paste0(
    'https://www.tiktok.com/@',
    tt_account,
    '/video/',
    video_ids
  )
  return(video_urls)
}

save_tiktok <- function(video_url,
                        save_video = TRUE,
                        dir = ".") {

  tt_json = get_tiktok_json(video_url)

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

save_tiktok_multi <- function(video_urls,
                              save_video = TRUE,
                              dir = ".",
                              sleep_pool = 1:10) {

  purrr::map_df(video_urls, function(u) {
    video_id = extract_regex(u, "(?<=/video/)(.+?)(?=\\?|$)|(?<=https://vm.tiktok.com/).+?(?=/|$)")
    message("Getting video ", video_id)
    out <- save_tiktok(u, save_video = save_video, dir = dir)
    sleep <- runif(1) * sample(sleep_pool, 1L)
    message("\t...waiting ", sleep, " seconds")
    Sys.sleep(sleep)
    return(out)
  })

}

save_video_comments <- function(video_url,
                                cursor_resume = 0,
                                max_comments = Inf,
                                sleep_pool = 1:10,
                                cookiefile = getOption("cookiefile")) {

  cursor = cursor_resume

  tt_json = get_tiktok_json(video_url)
  video_url <- tt_json$url_full
  video_url = extract_regex(video_url, "(.+?)(?=\\?|$)")
  video_id = extract_regex(video_url, "(?<=/video/)(.+?)(?=\\?|$)")

  cookies <- tik_read_cookies(cookiefile)
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

    if (class(res) != "try-error") {

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

      Sys.sleep(runif(1) * sample(sleep_pool, 1L))

    } else {
      max_comments <-  0
    }

  }

  return(do.call("rbind", data_list))

}

save_comments_multi <- function(video_urls,
                                max_comments = Inf,
                                sleep_pool = 1:10) {

  purrr::map_df(video_urls, function(u) {
    video_id = extract_regex(u, "(?<=/video/)(.+?)(?=\\?|$)")
    message("Getting comments for video ", video_id, "...")
    out <- save_video_comments(u, max_comments = max_comments, sleep_pool = sleep_pool)
    Sys.sleep(runif(1) * sample(sleep_pool, 1L))
    return(out)
  })

}

