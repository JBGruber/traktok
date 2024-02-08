#' Query TikTok videos using the research API
#'
#' @description \ifelse{html}{\figure{api-research.svg}{options: alt='[Works on:
#'   Research API]'}}{\strong{[Works on: Research API]}}
#'
#'   This is the version of \link{tt_search} that explicitly uses Research
#'   API. Use \link{tt_search_hidden} for the unoffcial API version.
#'
#' @param query A query string or object (see \link{query})
#' @param start_date,end_date A start and end date to narrow the
#'   search (required).
#' @param fields The fields to be returned (defaults to all)
#' @param start_cursor The starting cursor, i.e., how many results to
#'   skip (for picking up an old search)
#' @param search_id The search id (for picking up an old search)
#' @param is_random Whether the query is random (defaults to FALSE)
#' @param max_pages results are returned in batches/pages with 100
#'   videos. How many should be requested before the function stops?
#' @param cache should progress be saved in the current session? It
#'   can then be retrieved with \code{last_query()} if an error
#'   occurs. But the function will use extra memory.
#' @param verbose should the function print status updates to the
#'   screen?
#' @param token The authentication token (usually supplied
#'   automatically after running auth_research once)
#' @return A data.frame of parsed TikTok videos
#' @export
#' @examples
#' \dontrun{
#' # look for a keyword or hashtag by default
#' tt_search_api("rstats")
#'
#' # or build a more elaborate query
#' query() |>
#'   query_and(field_name = "region_code",
#'             operation = "IN",
#'             field_values = c("JP", "US")) |>
#'   query_or(field_name = "hashtag_name",
#'             operation = "EQ", # rstats is the only hashtag
#'             field_values = "rstats") |>
#'   query_or(field_name = "keyword",
#'            operation = "IN", # rstats is one of the keywords
#'            field_values = "rstats") |>
#'   query_not(operation = "EQ",
#'             field_name = "video_length",
#'             field_values = "SHORT") |>
#'   tt_search_api()
#' }
tt_search_api <- function(query,
                          start_date = Sys.Date() - 1,
                          end_date = Sys.Date(),
                          fields = "all",
                          start_cursor = 0L,
                          search_id = NULL,
                          is_random = FALSE,
                          max_pages = 1,
                          cache = TRUE,
                          verbose = TRUE,
                          token = NULL) {

  if (is.character(query)) {
    query <- query(or = list(
      list(
        field_name = "hashtag_name",
        operation = "IN",
        field_values = as.list(sub("#", "", strsplit(query, " ", fixed = TRUE)))
      ),
      list(
        field_name = "keyword",
        operation = "IN",
        field_values = as.list(strsplit(query, " ", fixed = TRUE))
      )
    ))
  }

  if (fields == "all")
    fields <- "id,video_description,create_time,region_code,share_count,view_count,like_count,comment_count,music_id,hashtag_names,username,effect_ids,playlist_id,voice_to_text"

  if (is_datetime(start_date)) {
    start_date <- format(start_date, "%Y%m%d")
  } else if (!grepl("\\d{8}", start_date)) {
    cli::cli_abort("{.code start_date} needs to be a valid date or a string like, e.g., \"20210102\"")
  }

  if (is_datetime(end_date)) {
    end_date <- format(end_date, "%Y%m%d")
  } else if (!grepl("\\d{8}", start_date)) {
    cli::cli_abort("{.code start_date} needs to be a valid date or a string like, e.g., \"20210102\"")
  }

  if (verbose) cli::cli_progress_step("Making initial request")

  res <- tt_query_request(
    endpoint = "query/",
    query = query,
    start_date = start_date,
    end_date = end_date,
    fields = fields,
    cursor = start_cursor,
    search_id = search_id,
    is_random = is_random,
    token = token
  )
  if (verbose) cli::cli_progress_done()
  videos <- purrr::pluck(res, "data", "videos")
  the$search_id <- spluck(res, "data", "search_id")
  the$videos <- videos

  page <- 1
  # res <- jsonlite::read_json("tests/testthat/example_resp.json")
  while (purrr::pluck(res, "data", "has_more", .default = FALSE) && page < max_pages) {
    page <- page + 1
    if (verbose) cli::cli_progress_step("Getting page {page}",
                                        msg_done = "Got page {page}")
    res <- tt_query_request(
      endpoint = "query/",
      query = query,
      start_date = start_date,
      end_date = end_date,
      fields = fields,
      cursor = purrr::pluck(res, "data", "cursor", .default = NULL),
      search_id = purrr::pluck(res, "data", "search_id", .default = NULL),
      is_random = is_random,
      token = token
    )
    videos <- c(videos, purrr::pluck(res, "data", "videos"))
    if (cache) the$videos <- videos
    if (verbose) cli::cli_progress_done()
  }

  if (verbose) cli::cli_progress_step("Parsing data")
  out <- parse_api_search(videos)

  attr(out, "search_id") <- spluck(res, "data", "search_id")

  return(out)
}


#' @export
#' @rdname tt_search_api
tt_query_videos <- tt_search_api


#' Lookup TikTok information about a user using the research API
#'
#' @description \ifelse{html}{\figure{api-research.svg}{options: alt='[Works on:
#'   Research API]'}}{\strong{[Works on: Research API]}}
#'
#' @param username name(s) of the user(s) to be queried
#' @param fields The fields to be returned (defaults to all)
#' @inheritParams tt_search_api
#'
#' @return A data.frame of parsed TikTok videos the user has posted
#' @export
#'
#' @examples
#' \dontrun{
#' tt_user_info_api("jbgruber")
#' # OR
#' tt_user_info_api("https://www.tiktok.com/@tiktok")
#' # OR
#' tt_user_info("https://www.tiktok.com/@tiktok")
#' }
tt_user_info_api <- function(username,
                             fields = "all",
                             verbose = TRUE,
                             token = NULL) {

  purrr::map(username, function(u) {
    # if username is given as URL
    if (grepl("/", u)) {
      u <- extract_regex(
        u,
        "(?<=.com/@)(.+?)(?=\\?|$|/)"
      )
    }

    if (is.null(token)) token <- get_token()

    if (fields == "all")
      fields <- "display_name,bio_description,avatar_url,is_verified,follower_count,following_count,likes_count,video_count"

    # /tests/testthat/example_resp_q_user.json
    httr2::request("https://open.tiktokapis.com/v2/research/user/info/") |>
      httr2::req_method("POST") |>
      httr2::req_url_query(fields = fields) |>
      httr2::req_headers("Content-Type" = "application/json") |>
      httr2::req_auth_bearer_token(token$access_token) |>
      httr2::req_body_json(data = list(username = u)) |>
      httr2::req_error(body = function(resp) {
        c(
          paste("status:", httr2::resp_body_json(resp)$error$code),
          paste("message:", httr2::resp_body_json(resp)$error$message),
          paste("log_id:", httr2::resp_body_json(resp)$error$log_id)
        )
      }) |>
      httr2::req_retry(max_tries = 5) |>
      httr2::req_perform() |>
      httr2::resp_body_json(bigint_as_char = TRUE) |>
      purrr::pluck("data") |>
      tibble::as_tibble()
  }) |>
    dplyr::bind_rows()

}


#' Retrieve video comments
#'
#' @description
#' \ifelse{html}{\figure{api-research.svg}{options: alt='[Works on: Research API]'}}{\strong{[Works on: Research API]}}
#'
#' @param video_id The id or URL of a video
#' @inheritParams tt_search_api
#'
#' @return A data.frame of parsed comments
#' @export
#'
#' @examples
#' \dontrun{
#' tt_comments("https://www.tiktok.com/@tiktok/video/7106594312292453675")
#' # OR
#' tt_comments("7106594312292453675")
#' # OR
#' tt_comments_api("7106594312292453675")
#' }
tt_comments_api <- function(video_id,
                            fields = "all",
                            start_cursor = 0L,
                            max_pages = 1L,
                            cache = TRUE,
                            verbose = TRUE,
                            token = NULL) {

  # if video_id is given as URL
  if (grepl("[^0-9]", video_id)) {
    video_id <- extract_regex(
      video_id,
      "(?<=/video/)(.+?)(?=\\?|$)|(?<=https://vm.tiktok.com/).+?(?=/|$)"
    )
  }

  if (fields == "all")
    fields <- "id,video_id,text,like_count,reply_count,parent_comment_id,create_time"

  if (verbose) cli::cli_progress_step("Making initial request")
  res <- tt_query_request(
    endpoint = "comment/list/",
    video_id = video_id,
    fields = fields,
    cursor = start_cursor,
    token = token
  )
  if (verbose) cli::cli_progress_done()
  comments <- purrr::pluck(res, "data", "comments")
  if (cache) the$comments <- comments
  page <- 1

  # res <- jsonlite::read_json("tests/testthat/example_resp_comments.json")
  while (purrr::pluck(res, "data", "has_more", .default = FALSE) && page < max_pages) {
    page <- page + 1
    if (verbose) cli::cli_progress_step("Getting page {page}",
                                        msg_done = "Got page {page}")
    res <- tt_query_request(
      endpoint = "comment/list/",
      video_id = video_id,
      fields = fields,
      cursor = purrr::pluck(res, "data", "cursor", .default = NULL),
      token = token
    )
    comments <- c(comments, purrr::pluck(res, "data", "comments"))
    if (cache) the$comments <- comments
    if (verbose) cli::cli_progress_done()
  }

  if (verbose) cli::cli_progress_step("Parsing data")
  out <- parse_api_comments(comments)

  return(out)
}


tt_query_request <- function(endpoint,
                             query = NULL,
                             video_id = NULL,
                             start_date = NULL,
                             end_date = NULL,
                             fields = NULL,
                             cursor = NULL,
                             search_id = NULL,
                             is_random = NULL,
                             token) {

  if (is.null(token)) token <- get_token()

  if (!is.null(query) && !is_query(query))
    cli::cli_abort("query needs to be a query object (see {.code ?query})")

  body <- list(query = unclass(query),
               video_id = video_id,
               start_date = start_date,
               end_date = end_date,
               max_count = 100L,
               cursor = cursor,
               search_id = search_id,
               is_random = is_random)

  httr2::request("https://open.tiktokapis.com/v2/research/video/") |>
    httr2::req_url_path_append(endpoint) |>
    httr2::req_method("POST") |>
    httr2::req_url_query(fields = fields) |>
    httr2::req_headers("Content-Type" = "application/json") |>
    httr2::req_auth_bearer_token(token$access_token) |>
    httr2::req_body_json(data = purrr::discard(body, is.null)) |>
    httr2::req_error(body = function(resp) {
      c(
        paste("status:", httr2::resp_body_json(resp)$error$code),
        paste("message:", httr2::resp_body_json(resp)$error$message),
        paste("log_id:", httr2::resp_body_json(resp)$error$log_id)
      )
    }) |>
    httr2::req_perform() |>
    httr2::resp_body_json(bigint_as_char = TRUE)

}
