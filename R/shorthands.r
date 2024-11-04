#' Search videos
#'
#' @description \ifelse{html}{\figure{api-both.svg}{options:
#'   alt='[Works on: Both]'}}{\strong{[Works on: Both]}}
#'
#'   Searches videos using either the Research API (if an authentication token
#'   is present, see \link{auth_research}) or otherwise the unofficial hidden
#'   API. See \link{tt_search_api} or \link{tt_search_hidden} respectively for
#'   information about these functions.
#'
#' @param ... arguments passed to \link{tt_search_api} or
#'   \link{tt_search_hidden}. To use the research API, include \code{token}
#'   (e.g., \code{token = NULL}).
#'
#' @return a data.frame
#' @export
tt_search <- function(...) {

  params <- list(...)
  token <- params$token
  params$token <- NULL
  if (is.null(token)) token <- get_token(auth = FALSE)
  if (isFALSE(token)) {
    tt_search_hidden(...)
  } else {
    tt_search_api(..., token)
  }

}


#' Get videos from a TikTok user's profile
#'
#' @description \ifelse{html}{\figure{api-both.svg}{options:
#'   alt='[Works on: Both]'}}{\strong{[Works on: Both]}}
#'
#'   Get all videos posted by a user (or multiple user's for the Research API).
#'   Searches videos using either the Research API (if an authentication token
#'   is present, see \link{auth_research}) or otherwise the unofficial hidden
#'   API. See \link{tt_user_videos_api} or \link{tt_user_videos_hidden} respectively for
#'   information about these functions.
#'
#' @param username The username or usernames whose videos you want to retrieve.
#' @param ... Additional arguments to be passed to the \code{\link{tt_user_videos_hidden}} or
#'   \code{\link{tt_user_videos_api}} function.
#'
#' @examples
#' \dontrun{
#' # Get hidden videos from the user "fpoe_at"
#' tt_user_videos("fpoe_at")
#' }
#' @export
tt_user_videos <- function(username, ...) {
  params <- list(...)
  token <- params$token
  params$token <- NULL
  if (is.null(token)) token <- get_token(auth = FALSE)
  if (isFALSE(token)) {
    tt_search_hidden(username, ...)
  } else {
    tt_user_videos_api(username, ...)
  }
}


#' @rdname tt_videos_hidden
#' @export
tt_videos <- function(...) {
  # mainly here in case the research API gains the ability to dowload videos
  tt_videos_hidden(...)
}


#' @rdname tt_user_info_api
#' @export
tt_user_info <- tt_user_info_api


#' @rdname tt_playlist_api
#' @export
tt_playlist <- tt_playlist_api


#' @rdname tt_user_liked_videos_api
#' @export
tt_get_liked <- tt_user_liked_videos_api


#' @rdname tt_user_reposted_api
#' @export
tt_get_reposted <- tt_user_reposted_api


#' @rdname tt_user_pinned_videos_api
#' @export
tt_get_pinned <- tt_user_pinned_videos_api


#' @rdname tt_comments_api
#' @export
tt_comments <- tt_comments_api


#' Get followers and following of users
#'
#' @description \ifelse{html}{\figure{api-both.svg}{options:
#'   alt='[Works on: Both]'}}{\strong{[Works on: Both]}}
#'
#'   Get usernames of users who follows a user (tt_get_follower) or get who a
#'   user is following (tt_get_following).
#'
#' @param ... arguments passed to \link{tt_user_follower_api} or
#'   \link{tt_get_follower_hidden}. To use the research API, include \code{token}
#'   (e.g., \code{token = NULL}).
#'
#' @return a data.frame
#' @export
tt_get_follower <- function(...) {

  params <- list(...)
  token <- params$token
  params$token <- NULL
  if (is.null(token)) token <- get_token(auth = FALSE)
  if (isFALSE(token)) {
    tt_get_follower_hidden(...)
  } else {
    tt_user_follower_api(..., token)
  }

}


#' @rdname tt_get_follower
#' @export
tt_get_following <- function(...) {

  params <- list(...)
  token <- params$token
  params$token <- NULL
  if (is.null(token)) token <- get_token(auth = FALSE)
  if (isFALSE(token)) {
    tt_get_following_hidden(...)
  } else {
    tt_user_following_api(..., token)
  }

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

