#' Retrieve most recent query
#'
#' If \code{tt_search_api} or \code{tt_comments_api} fail after already getting
#' several pages, you can use this function to get all videos that have been
#' retrieved so far from memory. Does not work when the session has crashed. In
#' that case, look in \code{tempdir()} for an RDS file as a last resort.
#'
#' @return a list of unparsed videos
#' @export
last_query <- function() {
  q <- the$videos
  out <- try(parse_api_search(q), silent = TRUE)
  if (methods::is(out, "try-error")) {
    attr(q, "search_id") <- the$search_id
    attr(out, "cursor") <- the$cursor
    return(q)
  }
  return(out)
}


#' @rdname last_query
#' @export
last_comments <- function() {
  the$comments
}

