#' Get video metadata and video files from URLs
#'
#' @description \ifelse{html}{\figure{api-unofficial}{options: alt='[Works on:
#'   Unofficial API]'}}{\strong{[Works on: Unofficial API]}}
#'
#' @param video_urls vector of URLs or IDs to TikTok videos.
#' @param save_video logical. Should the videos be downloaded.
#' @param overwrite logical. If save_video=TRUE and the file already exists,
#'   should it be overwritten?
#' @param dir directory to save videos files to.
#' @param cache_dir if set to a path, one RDS file with metadata will be written
#'   to disk for each video. This is useful if you have many videos and want to
#'   pick up where you left if something goes wrong.
#' @param sleep_pool a vector of numbers from which a waiting period is randomly
#'   drawn.
#' @param max_tries how often to retry if a request fails.
#' @param cookiefile path to your cookiefile. See
#'   \code{vignette("unofficial-api", package = "traktok")} for more information
#'   on authentication.
#' @param verbose should the function print status updates to the screen?
#' @param ... handed to \code{tt_videos_hidden} (for tt_videos) and (further) to
#'   \link{tt_request_hidden}.
#'
#' @details The function will wait between scraping two videos to make it less
#'   obvious that a scraper is accessing the site. The period is drawn randomly
#'   from the `sleep_pool` and multiplied by a random fraction.
#'
#' @details Note that the video file has to be requested in the same session as
#'   the metadata. So while the URL to the video file is included in the
#'   metadata, this link will not work in most cases.
#'
#'
#' @return a data.frame
#' @export
#'
#' @examples
#' \dontrun{
#' tt_videos("https://www.tiktok.com/@tiktok/video/7106594312292453675")
#' }
tt_videos_hidden <- function(video_urls,
                             save_video = TRUE,
                             overwrite = FALSE,
                             dir = ".",
                             cache_dir = NULL,
                             sleep_pool = 1:10,
                             max_tries = 5L,
                             cookiefile = NULL,
                             verbose = TRUE,
                             ...) {

  video_urls <- unique(video_urls)
  n_urls <- length(video_urls)
  video_urls <- id2url(video_urls)

  if (verbose) cli::cli_alert_info("Getting {n_urls} unique link{?s}")
  if (!is.null(cookiefile)) cookiemonster::add_cookies(cookiefile)
  cookies <- cookiemonster::get_cookies("^(www.)*tiktok.com", as = "string")
  f_name <- ""

  check_dir(dir, "dir")
  check_dir(cache_dir, "cache_dir")

  dplyr::bind_rows(purrr::map(video_urls, function(u) {
    video_id <- extract_regex(
      u,
      "(?<=/video/)(.+?)(?=\\?|$)|(?<=/photo/)(.+?)(?=\\?|$)|(?<=https://vm.tiktok.com/).+?(?=/|$)"
    )
    i <- which(u == video_urls)
    done_msg <- ""
    if (verbose) cli::cli_progress_step(
      "Getting video {video_id}",
      msg_done = "Got video {video_id} ({i}/{n_urls}). {done_msg}"
    )

    the$retries <- 5L
    video_dat <- get_video(url = u,
                           video_id = video_id,
                           overwrite = overwrite,
                           cache_dir = cache_dir,
                           max_tries = max_tries,
                           cookies = cookies,
                           verbose = verbose)

    if (isTRUE(video_dat$video_status_code == 0L)) {
      if (save_video) {
        if (!isTRUE(video_dat$is_slides)) {
          video_fn <- file.path(dir, paste0(video_dat$author_username, "_video_",
                                            video_dat$video_id, ".mp4"))

          f_name <- save_video(video_dat = video_dat,
                               video_fn = video_fn,
                               overwrite = overwrite,
                               max_tries = max_tries,
                               cookies = cookies)

          f_size <- file.size(f_name)
          if (isTRUE(f_size > 1000)) {
            done_msg <- glue::glue("File size: {utils:::format.object_size(f_size, 'auto')}.")
          } else {
            cli::cli_warn("Video {video_id} has a very small file size (less than 1kB) and is likely corrupt.")
          }
          video_dat$video_fn <- video_fn
        } else { # for slides
          download_urls <- strsplit(video_dat$download_url, ", ", fixed = TRUE) |>
            unlist()
          video_fns <- file.path(dir, paste0(video_dat$author_username,
                                             "_video_",
                                             video_dat$video_id,
                                             "_",
                                             seq_along(download_urls),
                                             ".jpeg"))
          purrr::walk2(download_urls, video_fns, function(u, f) {
            curl::curl_download(url = u, destfile = f, quiet = TRUE)
          })
        }
      }
    }

    if (all(i != n_urls, !isTRUE(the$skipped))) {
      wait(sleep_pool, verbose)
    }
    the$skipped <- FALSE # reset skipped

    return(video_dat)
  }))

}


#' @noRd
get_video <- function(url,
                      video_id,
                      overwrite,
                      cache_dir,
                      max_tries,
                      cookies,
                      verbose) {

  json_fn <- ""
  if (!is.null(cache_dir)) json_fn <- file.path(cache_dir,
                                                paste0(video_id, ".json"))

  if (overwrite || !file.exists(json_fn)) {
    tt_json <- tt_request_hidden(url, max_tries = max_tries)
    if (!is.null(cache_dir)) writeLines(tt_json, json_fn, useBytes = TRUE)
  } else {
    tt_json <- readChar(json_fn, nchars = file.size(json_fn), useBytes = TRUE)
    # TODO: not ideal as not consistent with request
    attr(tt_json,"url_full") <- url
    attr(tt_json,"html_status") <- 200L
    the$skipped <- TRUE
  }
  # make sure json can be parsed, otherwise retry
  out <- try(parse_video(tt_json, video_id), silent = TRUE)
  if (methods::is(out, "try-error") && the$retries > 0) {
    the$retries <- the$retries - 1
    out <- get_video(url,
                     video_id,
                     overwrite = TRUE, # most common reason for failure here is a malformed cached json
                     cache_dir,
                     max_tries,
                     cookies,
                     verbose)
  }
  return(out)
}


#' @noRd
save_video <- function(video_dat,
                       video_fn,
                       overwrite,
                       max_tries,
                       cookies) {

  video_url <- video_dat$download_url
  f <- structure("", class = "try-error")
  if (!is.null(video_url)) {

    if (overwrite || !file.exists(video_fn)) {
      while (methods::is(f, "try-error") && max_tries > 0) {
        the$skipped <- FALSE
        h <- curl::handle_setopt(
          curl::new_handle(),
          cookie = cookies,
          referer = "https://www.tiktok.com/"
        )
        f <- try(curl::curl_download(
          video_url, video_fn, quiet = TRUE, handle = h
        ), silent = TRUE)

        if (methods::is(f, "try-error")) {
          cli::cli_alert_warning(
            "Download failed, retrying after 10 seconds. {max_tries} left."
          )
          # if this fails, the download link has likely expired, so better get a
          # new one
          video_url <- get_video(url = video_dat$video_url,
                                 video_id = video_dat$video_id,
                                 overwrite = TRUE,
                                 cache_dir = NULL,
                                 max_tries = 1,
                                 cookies = NULL,
                                 verbose = FALSE)$download_url
          Sys.sleep(10)
        }

        max_tries <- max_tries - 1
      }
    } else if (file.exists(video_fn)) {
      f <- video_fn
      the$skipped <- TRUE
    }

  } else {
    cli::cli_warn("No valid video URL found for download.")
  }
  return(f)

}


#' Get json string from a TikTok URL using the hidden API
#'
#' @description \ifelse{html}{\figure{api-unofficial}{options:
#'   alt='[Works on: Unofficial API]'}}{\strong{[Works on: Unofficial API]}}
#'
#'   Use this function in case you want to check the full data for a given
#'   TikTok video or account. In tt_videos, only an opinionated selection of
#'   data is included in the final object. If you want some different
#'   information, you can use this function.
#'
#' @param url a URL to a TikTok video or account
#'
#' @inheritParams tt_videos_hidden
#' @export
tt_request_hidden <- function(url,
                              max_tries = 5L,
                              cookiefile = NULL) {

  if (!is.null(cookiefile)) cookiemonster::add_cookies(cookiefile)
  cookies <- cookiemonster::get_cookies("^(www.)*tiktok.com", as = "string")

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
    httr2::req_options(cookie = cookies) |>
    httr2::req_retry(max_tries = max_tries) |>
    httr2::req_timeout(seconds = 60L) |>
    httr2::req_error(is_error = function(x) FALSE)

  res <- httr2::req_perform(req)
  status <- httr2::resp_status(res)
  if (status >= 400) {
    cli::cli_warn("Retrieving {url} resulted in html status {status}, the row will contain NAs.")
    out <- paste0('{"__DEFAULT_SCOPE__":{"webapp.video-detail":{"statusCode":"', status, '","statusMsg":"html_error"}}}')
  } else {
    out <- res |>
      httr2::resp_body_html() |>
      rvest::html_node("#SIGI_STATE,#__UNIVERSAL_DATA_FOR_REHYDRATION__") |>
      rvest::html_text()
  }

  if (isFALSE(nchar(out) > 10)) stop("no json found")

  attr(out, "url_full") <- res$url
  attr(out, "html_status") <- status
  attr(out, "set-cookies") <- httr2::resp_headers(res)[["set-cookie"]]
  return(out)
}


#' Search videos
#'
#' @description \ifelse{html}{\figure{api-unofficial}{options: alt='[Works on:
#'   Unofficial API]'}}{\strong{[Works on: Unofficial API]}}
#'
#'   This is the version of \link{tt_search} that explicitly uses the unofficial
#'   API. Use \link{tt_search_api} for the Research API version.
#'
#' @param query query as one string
#' @param offset how many videos to skip. For example, if you already have the
#'   first X of a search.
#' @param max_pages how many pages to get before stopping the search.
#'
#' @inheritParams tt_videos_hidden
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

  if (!is.null(cookiefile)) cookiemonster::add_cookies(cookiefile)
  cookies <- cookiemonster::get_cookies("^(www.)*tiktok.com", as = "string")

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
      httr2::req_options(cookie = cookies) |>
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


#' Get infos about a user from the hidden API
#'
#' @param username A URL to a video or username.
#' @param parse Whether to parse the data into a data.frame (set to FALSE to get
#'   the full list).
#'
#' @return A data.frame of user info.
#' @export
#'
#' @examples
#' \dontrun{
#' df <- tt_user_info_hidden("https://www.tiktok.com/@fpoe_at")
#' }
tt_user_info_hidden <- function(username,
                                parse = TRUE) {

  rlang::check_installed("rvest", reason = "to use this function", version = "1.0.4")

  if (!grepl("^http[s]*://", username)) {
    username <- paste0("https://www.tiktok.com/@", username)
  }

  if (!grepl("^http[s]*://[www.]*tiktok\\.com/@.+", username)) {
    cli::cli_abort("The provided username does not resolve to a TikTok account URL: {username}")
  }

  sess <- rvest::read_html_live(username)

  json <- sess |>
    rvest::html_element("#__UNIVERSAL_DATA_FOR_REHYDRATION__") |>
    rvest::html_text()

  if (!is.na(json)) {
    user_data <- json |>
      jsonlite::fromJSON()
  } else {
    cli::cli_alert_warning("Could not retrieve data for user")
    user_data <- list()
  }

  if (parse) {
    return(parse_user(user_data))
  } else {
    return(user_data)
  }

}


#' @title Get followers and following of a user from the hidden API
#'
#' @description \ifelse{html}{\figure{api-unofficial}{options: alt='[Works on:
#'   Unofficial API]'}}{\strong{[Works on: Unofficial API]}}
#'
#'   Get up to 5,000 accounts who follow a user or accounts a user follows.
#'
#' @param secuid The secuid of a user. You can get it with \link{tt_videos} by
#'   querying the video of an account.
#' @inheritParams tt_search_hidden
#'
#' @return a data.frame of followers
#' @export
#'
#' @examples
#' \dontrun{
#' df <- tt_user_info_hidden("https://www.tiktok.com/@fpoe_at")
#' tt_get_follower_hidden(df$secUid)
#' }
tt_get_following_hidden <- function(secuid,
                                    sleep_pool = 1:10,
                                    max_tries = 5L,
                                    cookiefile = NULL,
                                    verbose = TRUE) {

  if (!is.null(cookiefile)) cookiemonster::add_cookies(cookiefile)
  cookies <- cookiemonster::get_cookies("^(www.)*tiktok.com", as = "string")

  new_data <- list(minCursor = 0,
                   total = Inf,
                   hasMore = TRUE)
  follower_data <- list()

  while (isTRUE(new_data$hasMore)) {
    if (verbose) cli::cli_progress_step(
      msg = ifelse(length(follower_data) == 0L, "Getting followers...", "Getting more followers..."),
      msg_done = "Got {length(follower_data)} followers."
    )
    resp <- httr2::request("https://www.tiktok.com/api/user/list/") |>
      httr2::req_url_query(
        count = "30",
        minCursor = new_data$minCursor,
        scene = "21",
        secUid = secuid,
      ) |>
      httr2::req_options(cookie = cookies) |>
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
    if (isTRUE(new_data$hasMore)) wait(sleep_pool)
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

  if (!is.null(cookiefile)) cookiemonster::add_cookies(cookiefile)
  cookies <- cookiemonster::get_cookies("^(www.)*tiktok.com", as = "string")

  new_data <- list(minCursor = 0,
                   total = Inf,
                   hasMore = TRUE)
  follower_data <- list()

  while (isTRUE(new_data$hasMore)) {
    if (verbose) cli::cli_progress_step(
      msg = ifelse(length(follower_data) == 0L, "Getting followers...", "Getting more followers..."),
      msg_done = "Got {length(follower_data)} followers."
    )
    resp <- httr2::request("https://www.tiktok.com/api/user/list/") |>
      httr2::req_url_query(
        count = "30",
        minCursor = new_data$minCursor,
        scene = "67",
        secUid = secuid,
      ) |>
      httr2::req_options(cookie = cookies) |>
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
    if (isTRUE(new_data$hasMore)) wait(sleep_pool)
  }
  if (verbose) cli::cli_progress_done()

  if (verbose) cli::cli_progress_step(
    msg = "Parsing results"
  )
  return(parse_followers(follower_data))

}


#' Get videos from a TikTok user's profile
#'
#' This function uses rvest to scrape a TikTok user's profile and retrieve any hidden videos.
#' @description \ifelse{html}{\figure{api-unofficial}{options: alt='[Works on:
#'   Unofficial API]'}}{\strong{[Works on: Unofficial API]}}
#'
#'   Get all videos posted by a TikTok user.
#'
#' @param username The username of the TikTok user whose hidden videos you want to retrieve.
#' @param solve_captchas open browser to solve appearing captchas manually.
#' @param return_urls return video URLs instead of downloading the vidoes.
#' @param timeout time (in seconds) to wait between scrolling and solving captchas.
#' @param verbose should the function print status updates to the screen?
#' @param ... Additional arguments to be passed to the \code{\link{tt_videos_hidden}} function.
#'
#' @return A list of video data or URLs, depending on the value of \code{return_urls}.
#'
#' @examples
#' \dontrun{
#' # Get hidden videos from the user "fpoe_at"
#' tt_user_videos_hidden("fpoe_at")
#' }
#' @export
tt_user_videos_hidden <- function(username,
                                  solve_captchas = FALSE,
                                  return_urls = FALSE,
                                  timeout = 5L,
                                  verbose = TRUE,
                                  ...) {

  rlang::check_installed("rvest", reason = "to use this function", version = "1.0.4")

  if (!grepl("^http[s]*://", username)) {
    username <- paste0("https://www.tiktok.com/@", username)
  }

  #TODO: check if username is a valid tiktok link now
  if (verbose) cli::cli_progress_step("Opening {username}")
  # reset captcha warning
  the$captcha <- NULL
  sess <- rvest::read_html_live(username)
  last_y <- -1
  #scroll as far as possible
  if (verbose) cli::cli_progress_bar(format = "{cli::pb_spin} Scrolling down (y={last_y})")
  while (sess$get_scroll_position()$y > last_y) {
    solve_captcha(sess, solve = solve_captchas)
    last_y <- sess$get_scroll_position()$y
    sess$scroll_to(top = 10 ^ 5)
    if (verbose) cli::cli_progress_update()
    Sys.sleep(timeout * stats::runif(1, 1, 3))
  }
  if (verbose) cli::cli_progress_step("Collecting discovered URLs")
  urls <- sess |>
    rvest::html_elements("a") |>
    rvest::html_attr("href")
  urls <- grep(username, x = urls, value = TRUE) |>
    unique()
  if (verbose) {
    cli::cli_progress_done()
    cli::cli_alert_success("{length(urls)} URLs discovered")
  }
  if (return_urls) return(urls)
  tt_videos_hidden(urls, ...)
}

solve_captcha <- function(sess, solve) {
  captcha <- rvest::html_element(sess, "#captcha-verify-image,.captcha-verify-container")
  if (length(captcha) == 0L) {
    the$view <- NULL
    the$captcha <- NULL
    return(TRUE)
  }
  # display status once
  if (is.null(the$captcha)) {
    cli::cli_alert_info("Captcha discovered")
    the$captcha <- TRUE
  }
  if (solve) {
    if (is.null(the$view))
      the$view <- sess$view()
    solve_captcha(sess, solve = solve)
  }
}
