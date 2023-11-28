#' Search videos
#'
#' @description \ifelse{html}{\figure{api-both.svg}{options:
#'   alt='[Both]'}}{\strong{[Both]}}
#'
#'   Searches videos using either the Research API (if an authentication token
#'   is present, see \link{auth_research}) or otherwise the unofficial hidden
#'   API. See \link{tt_search_api} or \link{tt_search_hidden} respectively for
#'   information about these functions.
#'
#' @param ... arguments passed to \link{tt_search_api} or \link{tt_search_hidden}
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


#' @rdname tt_videos_hidden
#' @export
tt_videos <- function(...) {
  # mainly here in case the research API gains the ability to dowload videos
  tt_videos_hidden(...)
}


#' @rdname tt_user_videos_api
#' @export
tt_user_videos <- tt_user_videos_api


#' @rdname tt_comments_api
#' @export
tt_comments <- tt_comments_api


#' @rdname tt_get_following_hidden
#' @export
tt_get_follower <- tt_get_follower_hidden


#' @rdname tt_get_following_hidden
#' @export
tt_get_following <- tt_get_following_hidden


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

