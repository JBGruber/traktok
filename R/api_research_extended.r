#' Get videos from a TikTok user's profile
#'
#' @description \ifelse{html}{\figure{api-research.svg}{options: alt='[Works on:
#'   Research API]'}}{\strong{[Works on: Research API]}}
#'
#'   Get all videos posted by a user or multiple user's. This is a convenience
#'   wrapper around \code{\link{tt_search_api}} that takes care of moving time
#'   windows (search is limited to 30 days). This is the version of
#'   \link{tt_user_videos} that explicitly uses Research API. Use
#'   \link{tt_user_videos_hidden} for the unofficial API version.
#'
#' @param username The username or usernames whose videos you want to retrieve.
#' @param since,to limits from/to when to go through the account in 30 day windows.
#' @param ... Additional arguments to be passed to the
#'   \code{\link{tt_search_api}} function.
#'
#' @inheritParams tt_search_api
#'
#' @return a data.frame containing metadata of user posts.
#' @examples
#' \dontrun{
#' # Get videos from the user "fpoe_at" since October 2024
#' tt_user_videos_api("fpoe_at", since = "2024-10-01")
#'
#' # often makes sense to combine this with the account creation time from the
#' # hidden URL
#' fpoe_at_info <- tt_user_info_hidden(username = "fpoe_at")
#' tt_user_videos_api("fpoe_at", since = fpoe_at_info$create_time)
#'
#' }
#' @export
tt_user_videos_api <- function(username,
                               since = "2020-01-01",
                               to = Sys.Date(),
                               verbose = TRUE,
                               ...) {

  dates_from <- seq.Date(from = as.Date(since),
                         to = as.Date(to),
                         by = "31 day")
  dates_to <- dates_from + 30
  # we want the last window to end today
  dates_to[length(dates_to)] <- as.Date(to)

  pb <- FALSE
  if (verbose) {
    pb <- list(
      format = "{cli::pb_spin} searching time window {cli::pb_current} of {cli::pb_total} | {cli::pb_percent} done | ETA: {cli::pb_eta}"
    )
  }

  purrr::map2(dates_from, dates_to, function(from, to) {
    out <- query() |>
      query_or(field_name = "username",
               operation = "IN",
               field_values = username) |>
      tt_search_api(start_date = from,
                    end_date = to,
                    verbose = FALSE,
                    ...)
    if (nrow(out) > 0) return(out)
  }, .progress = pb) |>
    dplyr::bind_rows()

}
