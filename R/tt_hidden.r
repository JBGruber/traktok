#' Get video URLs and metadata from videos
#'
#' @param video_urls vector of URLs to TikTok videos.
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
#' @param verbose logical. Print status messages.
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
                      overwrite = FALSE,
                      dir = ".",
                      cache_dir = NULL,
                      sleep_pool = 1:10,
                      max_tries = 5L,
                      cookiefile = NULL,
                      verbose = TRUE,
                      ...) {

  n_urls <- length(video_urls)
  cookies <- auth_hidden(cookiefile)
  f_name <- ""

  dplyr::bind_rows(purrr::map(video_urls, function(u) {
    video_id <- extract_regex(
      u,
      "(?<=/video/)(.+?)(?=\\?|$)|(?<=https://vm.tiktok.com/).+?(?=/|$)"
    )
    i <- which(u == video_urls)
    if (verbose) cli::cli_progress_step(
      "Getting video {video_id}",
      msg_done = "Got video {video_id} ({i}/{n_urls})."
    )

    video_dat <- get_video(url = u,
                           video_id = video_id,
                           overwrite = overwrite,
                           cache_dir = cache_dir,
                           max_tries = max_tries,
                           cookies = cookies,
                           verbose = verbose)

    regex_url <- extract_regex(video_dat$video_url, "(?<=@).+?(?=\\?|$)")
    video_fn <- file.path(dir, paste0(gsub("/", "_", regex_url), ".mp4"))

    if (save_video) {
      f_name <- save_video(video_url = video_dat$download_url,
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
    }

    if (i != n_urls) wait(sleep_pool, verbose)

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
    tt_json <- tt_request_hidden(url, cookiefile = cookies, max_tries = max_tries)
  }

  if (!is.null(cache_dir)) writeLines(tt_json, json_fn, useBytes = TRUE)

  parse_video(tt_json, video_id)
}


#' @noRd
save_video <- function(video_url,
                       video_fn,
                       overwrite,
                       max_tries,
                       cookies) {

  f <- structure("", class = "try-error")
  if (!is.null(video_url)) {

    if (overwrite || !file.exists(video_fn)) {
      while (methods::is(f, "try-error") && max_tries > 0) {

        h <- curl::handle_setopt(
          curl::new_handle(),
          cookie = prep_cookies(cookies),
          referer = "https://www.tiktok.com/"
        )
        f <- try(curl::curl_download(
          video_url, video_fn, quiet = TRUE, handle = h
        ), silent = TRUE)

        if (methods::is(f, "try-error")) {
          cli::cli_alert_warning(
            "Download failed, retrying after 10 seconds. {max_tries} left."
          )
          Sys.sleep(10)
        }

        max_tries <- max_tries - 1
      }
    }

  } else {
    cli::cli_warn("No valid video URL found for download.")
  }
  return(f)

}
