#' Retrieve most recent query
#'
#' If \code{tt_query_videos} videos failes after already getting several pages,
#' you can use this function to get all videos that have been retrieved to far
#' from memory (does not work when the sesseion has crashed).
#'
#' @return a list of unparsed videos
#' @export
last_query <- function() {
  the$videos
}
