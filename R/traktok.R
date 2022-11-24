#' Get video URLs and metadata from videos
#'
#' @param video_urls vector of URLs to TikTok videos.
#' @param save_video logical. Should the videos be downloaded.
#' @param dir directory to save videos files to.
#' @param sleep_pool a vector of numbers from which a waiting period is randomly
#'   drawn.
#' @param ... handed to \link{tt_json}.
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
    video_id <- extract_regex(u, "(?<=/video/)(.+?)(?=\\?|$)|(?<=https://vm.tiktok.com/).+?(?=/|$)")
    message("Getting video ", video_id)
    out <- save_tiktok(u, save_video = save_video, dir = dir, ...)
    if (u != utils::tail(video_urls, 1)) wait(sleep_pool)
    return(out)
  })

}


#' Get comments under a video.
#'
#' @param video_urls vector of URLs to TikTok videos.
#' @param max_comments max number of comments to return.
#' @param sleep_pool a vector of numbers from which a waiting period is randomly
#'   drawn.
#' @param ... handed to \link{tt_json}.
#'
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
    video_id <- extract_regex(u, "(?<=/video/)(.+?)(?=\\?|$)")
    message("Getting comments for video ", video_id, "...")
    out <- save_video_comments(u, max_comments = max_comments, sleep_pool = sleep_pool, ...)
    wait(sleep_pool)
    return(out)
  })

}


#' Get user videos
#'
#' @param user_url vector of URLs to TikTok accounts.
#' @param sleep_pool a vector of numbers from which a waiting period is randomly
#'   drawn.
#' @param ... handed to \link{tt_json}.
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
    video_id <- extract_regex(u, "(?<=/video/)(.+?)(?=\\?|$)")
    message("Getting user videos from ", video_id, "...")
    out <- get_account_video_urls(u, ...)
    wait(sleep_pool)
    return(out)
  })

}



#' Get json file from a TikTok URL
#'
#' @param url a URL to a TikTok video or account
#' @param cookiefile path to your cookiefile. Default is to request a new one
#'   from TikTok.com and place it in the location returned by
#'   \code{tools::R_user_dir("traktok", "config")} and set the option cookiefile
#'   to this location.
#' @export
tt_json <- function(url,
                    cookiefile = NULL) {

  cookies <- tt_get_cookies(cookiefile)

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

  tt_json <- tt_json(video_url, ...)

  if (tt_json$url_full == "https://www.tiktok.com/") {

    warning(video_url, " can't be reached.")
    return(tibble::tibble())

  } else {

    video_url <- tt_json$url_full
    regex_url <- extract_regex(video_url, "(?<=@).+?(?=\\?|$)")
    video_fn <- paste0(dir, "/", paste0(gsub("/", "_", regex_url), ".mp4"))
    video_id <- vapply(tt_json[["ItemModule"]], function(x) x[["video"]][["id"]],
      FUN.VALUE = character(1)
    )

    tt_video_url <- tt_json[["ItemList"]][["video"]][["preloadList"]][["url"]]


    video_timestamp <- tt_json[["ItemModule"]][[video_id]][["createTime"]] |>
      as.integer() |>
      as.POSIXct(tz = "UTC", origin = "1970-01-01")

    data_list <- list(
      video_id = video_id,
      video_timestamp = video_timestamp,
      video_length = tt_json[["ItemModule"]][[video_id]][["video"]][["duration"]],
      video_title = tt_json[["ItemModule"]][[video_id]][["desc"]],
      video_locationcreated = tt_json[["ItemModule"]][[video_id]][["locationCreated"]],
      video_diggcount = tt_json[["ItemModule"]][[video_id]][["stats"]][["diggCount"]],
      video_sharecount = tt_json[["ItemModule"]][[video_id]][["stats"]][["shareCount"]],
      video_commentcount = tt_json[["ItemModule"]][[video_id]][["stats"]][["commentCount"]],
      video_playcount = tt_json[["ItemModule"]][[video_id]][["stats"]][["playCount"]],
      video_description = tt_json[["ItemModule"]][[video_id]][["desc"]],
      video_is_ad = tt_json[["ItemModule"]][[video_id]][["isAd"]],
      video_fn = video_fn,
      author_username = tt_json[["ItemModule"]][[video_id]][["author"]],
      author_name = tt_json[["ItemModule"]][[video_id]][["authorName"]],
      author_followercount = tt_json[["ItemModule"]][[video_id]][["authorStats"]][["followerCount"]],
      author_followingcount = tt_json[["ItemModule"]][[video_id]][["authorStats"]][["followingCount"]],
      author_heartcount = tt_json[["ItemModule"]][[video_id]][["authorStats"]][["heartCount"]],
      author_videocount = tt_json[["ItemModule"]][[video_id]][["authorStats"]][["videoCount"]],
      author_diggcount = tt_json[["ItemModule"]][[video_id]][["authorStats"]][["diggCount"]]
    )

    if (save_video) curl::curl_download(tt_video_url, video_fn, quiet = FALSE)

    return(tibble::tibble(data.frame(lapply(data_list, function(x) ifelse(is.null(x), NA, x)))))

  }

}


#' @noRd
save_video_comments <- function(video_url,
                                cursor_resume = 0,
                                max_comments = Inf,
                                sleep_pool = 1:10,
                                cookiefile = NULL) {
  cursor <- cursor_resume


  tt_json <- tt_json(video_url, cookiefile = cookiefile)
  video_url <- tt_json$url_full
  video_url <- extract_regex(video_url, "(.+?)(?=\\?|$)")
  video_id <- extract_regex(video_url, "(?<=/video/)(.+?)(?=\\?|$)")

  cookies <- tt_get_cookies(cookiefile)
  data_list <- list()

  while (cursor < max_comments) {
    message("\t...retrieving comments ", cursor, "+")

    req <- httr2::request("https://www.tiktok.com/api/comment/list/") |>
      httr2::req_headers(
        "Accept-Encoding" = "gzip, deflate, sdch",
        "Accept-Language" = "en-US,en;q=0.8",
        "Upgrade-Insecure-Requests" = "1",
        "User-Agent" = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36",
        "Accept" = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
        "Cache-Control" = "max-age=0",
        "Connection" = "keep-alive",
        referer = video_url
      ) |>
      httr2::req_options(cookie = prep_cookies(cookies)) |>
      httr2::req_url_query(
        "aweme_id" = video_id,
        "count" = "50",
        "cursor" = as.character(cursor)
      ) |>
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
        user_nickname = vapply(res[["comments"]], function(x) ifelse(is.null(x[["user"]][["nickname"]]), "", x[["user"]][["nickname"]]),
                               FUN.VALUE = character(1)),
        user_signature = vapply(res[["comments"]], function(x) ifelse(is.null(x[["user"]][["signature"]]), "", x[["user"]][["signature"]]),
                                                                      FUN.VALUE = character(1))
      )

      cursor <- cursor + nrow(data_df)

      data_list <- c(
        data_list,
        list(data_df)
      )

      if (nrow(data_df) == 0) max_comments <- 0

      if (cursor < max_comments) wait(sleep_pool)

    } else {
      max_comments <- 0
    }

  }

  return(data_list)

}


#' @noRd
get_account_video_urls <- function(user_url,
                                   ...) {

  tt_json <- tt_json(user_url, ...)
  video_ids <- tt_json[["ItemList"]][["user-post"]][["list"]]
  user_id <- tt_json[["UserPage"]][["uniqueId"]]

  tibble::tibble(
    user_id = user_id,
    user_name = tt_json[["UserModule"]][["users"]][["jordanalmani"]][["uniqueId"]],
    user_nickname = tt_json[["UserModule"]][["users"]][["jordanalmani"]][["nickname"]],
    user_signature = tt_json[["UserModule"]][["users"]][["jordanalmani"]][["signature"]],
    user_avatar = tt_json[["UserModule"]][["users"]][["jordanalmani"]][["avatarThumb"]],
    user_commercial = tt_json[["UserModule"]][["users"]][["jordanalmani"]][["commerceUserInfo"]][["commerceUser"]],
    user_region = tt_json[["UserModule"]][["users"]][["jordanalmani"]][["region"]],
    video_urls <- paste0(
      "https://www.tiktok.com/@",
      user_id,
      "/video/",
      video_ids
    )
  )

}



#' Search videos
#'
#' @param q query as one string
#' @param scope can be left blank or either "video" or "user" to narrow down the
#'   search.
#' @param max_videos max number of videos to return (the function will usually
#'   return a few more than the exact number).
#' @param offset how many videos to skip. For example, if you already have the
#'   first X of a search.
#' @param cookiefile path to your cookiefile. Default is to request a new one
#'   from TikTok.com and place it in the location returned by
#'   \code{tools::R_user_dir("traktok", "config")} and set the option cookiefile
#'   to this location.
#' @param sleep_pool a vector of numbers from which a waiting period is randomly
#'   drawn.
#' @param ... handed to \link{tt_json}.
#'
#' @return a data.frame
#' @export
#'
#' @examples
#' \dontrun{
#' tt_search("#rstats", max_videos = 5L)
#' }
tt_search <- function(q,
                      scope = "",
                      max_videos = Inf,
                      offset = 0L,
                      cookiefile = NULL,
                      sleep_pool = 1:10,
                      ...) {

  if (length(q) != 1 & !methods::is(q, "character")) {
    stop("Please provide exactly one search string")
  }

  q <- gsub("#", "%23", q, fixed = TRUE)

  cookies <- tt_get_cookies(cookiefile)

  data_list <- list()

  while (offset < max_videos) {

    message("\rretrieving videos with offset=", offset, appendLF = FALSE)

    req <- httr2::request("https://www.tiktok.com/api/search/item/full/") |>
      httr2::req_options(cookie = prep_cookies(cookies, "ttwid")) |>
      httr2::req_url_query(
        "keyword" = q,
        "offset" = as.character(offset)
      ) |>
      httr2::req_timeout(seconds = 30L)

    res <- try(httr2::req_perform(req) |>
      httr2::resp_body_json())

    msg <- "status_msg" %in% names(res)

    if (!methods::is(res, "try-error") | !msg) {

      data_list <- c(
        data_list,
        list(parse_search(res))
      )

      if (as.logical(res[["has_more"]])) {

        offset <- res[["cursor"]]

      } else {

        max_videos <- 0

      }

    } else {

      if (msg) message(res[["status_msg"]])
      max_videos <- 0

    }

    if (offset < max_videos) wait(sleep_pool)

  }

  return(dplyr::bind_rows(data_list))

}

#' @noRd
tt_search_hashtag <- function(hashtag,
                              max_videos = Inf,
                              cookiefile = getOption("cookiefile"),
                              ...) {
  .Deprecated("tt_search")
}

#' @noRd
parse_search <- function(json) {

  video_timestamp <- vpluck(json[["item_list"]], "createTime", val = "integer") |>
    as.integer() |>
    as.POSIXct(tz = "UTC", origin = "1970-01-01")

  tibble::tibble(
    video_id              = vpluck(json[["item_list"]], "video", "id"),
    video_timestamp       = video_timestamp,
    video_url             = vpluck(json[["item_list"]], "video", "downloadAddr"),
    video_length          = vpluck(json[["item_list"]], "video", "duration", val = "integer"),
    video_title           = vpluck(json[["item_list"]], "desc"),
    video_diggcount       = vpluck(json[["item_list"]], "stats", "diggCount", val = "integer"),
    video_sharecount      = vpluck(json[["item_list"]], "stats", "shareCount", val = "integer"),
    video_commentcount    = vpluck(json[["item_list"]], "stats", "commentCount", val = "integer"),
    video_playcount       = vpluck(json[["item_list"]], "stats", "playCount", val = "integer"),
    video_description     = vpluck(json[["item_list"]], "desc"),
    video_is_ad           = vpluck(json[["item_list"]], "isAd", val = "logical"),
    author_name           = vpluck(json[["item_list"]], "author", "uniqueId"),
    author_followercount  = vpluck(json[["item_list"]], "authorStats", "followerCount", val = "integer"),
    author_followingcount = vpluck(json[["item_list"]], "authorStats", "followingCount", val = "integer"),
    author_heartcount     = vpluck(json[["item_list"]], "authorStats", "heartCount", val = "integer"),
    author_videocount     = vpluck(json[["item_list"]], "authorStats", "videoCount", val = "integer"),
    author_diggcount      = vpluck(json[["item_list"]], "authorStats", "diggCount", val = "integer")
  )

}
