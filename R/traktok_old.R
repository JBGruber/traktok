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

  .Defunct( msg = "retrieving comments no longer works")
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

  .Defunct( msg = "retrieving user videos no longer works")

}


#' Get json file from a TikTok URL
#'
#' This function was replaced by \code{tt_request_hidden()}.
#'
#' @param ... \code{tt_request_hidden()}.
#' @export
tt_json <- function(...) {

  cli::cli_warn("This function has been replaced by {.fn tt_request_hidden}")
  tt_request_hidden(...)
}


#' Search videos
#'
#' This function was replaced by \code{search_hidden()}.
#' @param ... \code{search_hidden()}.
#'
#' @return a data.frame
#' @export
tt_search <- function(...) {

  cli::cli_warn("This function has been replaced by {.fn search_hidden}")
  search_hidden(...)

}
