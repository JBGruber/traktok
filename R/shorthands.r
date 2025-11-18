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
#' @return a data.frame of video metadata
#' @export
tt_search <- function(...) {
  auth <- auth_check(silent = TRUE)
  if (isTRUE(auth["research"])) {
    tt_search_api(...)
  } else {
    tt_search_hidden(...)
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
#' @return a data.frame containing metadata of user posts.
#' @examples
#' \dontrun{
#' # Get hidden videos from the user "fpoe_at"
#' tt_user_videos("fpoe_at")
#' }
#' @export
tt_user_videos <- function(username, ...) {
  auth <- auth_check(silent = TRUE)
  if (isTRUE(auth["research"])) {
    tt_user_videos_api(username, ...)
  } else {
    tt_user_videos_hidden(username, ...)
  }
}


#' @rdname tt_videos_hidden
#' @export
tt_videos <- function(...) {
  # mainly here in case the research API gains the ability to download videos
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
#' @return a data.frame of followers and following of users
#' @export
tt_get_follower <- function(...) {
  auth <- auth_check(silent = TRUE)
  if (isTRUE(auth["research"])) {
    tt_user_follower_api(...)
  } else {
    tt_get_follower_hidden(...)
  }
}


#' @rdname tt_get_follower
#' @export
tt_get_following <- function(...) {
  auth <- auth_check(silent = TRUE)
  if (isTRUE(auth["research"])) {
    tt_user_following_api(...)
  } else {
    tt_get_following_hidden(...)
  }
}
