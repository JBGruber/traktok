#' Retrieve most recent query
#'
#' If \code{tt_search_api} or \code{tt_comments_api} fail after already getting
#' several pages, you can use this function to get all videos that have been
#' retrieved so far from memory. Does not work when the session has crashed. In
#' that case, look in \code{tempdir()} for an RDS file as a last resort.
#'
#' For \code{tt_search_api}, the returned object carries the
#' \code{search_id}, \code{cursor}, \code{start_date} and \code{end_date} of
#' the time window that was being queried when the error occurred as
#' attributes, so the search can be picked back up (see
#' \code{\link{tt_search_api}}).
#'
#' @return a list of unparsed videos or comments.
#' @export
last_query <- function() {
  q <- the$videos
  # for searches from the hidden API, only URLs are cached
  if (isTRUE(is.character(q))) {
    return(q)
  }
  out <- try(parse_api_search(q), silent = TRUE)
  if (methods::is(out, "try-error")) {
    return(add_search_attrs(q))
  }
  return(add_search_attrs(out))
}


#' @rdname last_query
#' @export
last_comments <- function() {
  the$comments
}
