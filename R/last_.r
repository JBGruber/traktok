#' Retrieve most recent query
#'
#' If \code{tt_search_api} or \code{tt_comments_api} fail after already getting several pages,
#' you can use this function to get all videos that have been retrieved so far
#' from memory (does not work when the session has crashed).
#'
#' @return a list of unparsed videos
#' @export
last_query <- function() {
  the$videos
}


#' @rdname last_query
#' @export
last_comments <- function() {
  the$comments
}

