#' Query TikTok videos using the API
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
#' tt_query_videos("rstats")
#'
#' # or build a more elaborate query
#' query() |>
#'   query_and(field_name = "region_code",
#'             operation = "IN",
#'             field_values = c("JP", "US")) |>
#'   query_or(field_name = "hashtag_name",
#'             operation = "EQ",
#'             field_values = "rstats") |>
#'   query_or(field_name = "keyword",
#'            operation = "EQ",
#'            field_values = "rstats") |>
#'   query_not(operation = "EQ",
#'             field_name = "video_length",
#'             field_values = "SHORT") |>
#'   tt_query_videos()
#' }
tt_query_videos <- function(query,
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
        operation = "EQ",
        field_values = as.list(strsplit(query, " ", fixed = TRUE))
      ),
      list(
        field_name = "keyword",
        operation = "EQ",
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

  if (verbose) cli::cli_progress_step("Making first request")

  res <- tt_query_request(
    query = query,
    start_date = start_date,
    end_date = end_date,
    fields = fields,
    cursor = start_cursor,
    search_id = search_id,
    is_random = is_random,
    token = token
  )
  videos <- purrr::pluck(res, "data", "videos")
  if (cache) the$videos <- videos

  page <- 1
  # res <- jsonlite::read_json("tests/testthat/example_resp.json")
  while (purrr::pluck(res, "data", "has_more", .default = FALSE) && page < max_pages) {
    page <- page + 1
    if (verbose) cli::cli_progress_step("Getting page {page}")
    res <- tt_query_request(
      query = query,
      start_date = start_date,
      end_date = end_date,
      fields = fields,
      cursor = purrr::pluck(res, "data", "cursor", .default = NULL),
      search_id = search_id,
      is_random = is_random,
      token = token
    )
    videos <- c(videos, purrr::pluck(res, "data", "videos"))
    if (cache) the$videos <- videos
  }

  if (verbose) cli::cli_progress_step("Parsing data")
  out <- parse_api_search(videos)

  attr(out, "search_id") <- spluck(res, "data", "search_id")

  return(out)
}


tt_query_request <- function(query,
                             start_date,
                             end_date,
                             fields,
                             cursor,
                             search_id,
                             is_random,
                             token) {

  if (is.null(token)) token <- get_token()

  if (!is_query(query))
    cli::cli_abort("query needs to be a query object (see {.code ?query})")

  body <- list(query = unclass(query),
               start_date = start_date,
               end_date = end_date,
               max_count = 100L,
               cursor = cursor,
               search_id = search_id,
               is_random = is_random)

  httr2::request("https://open.tiktokapis.com/v2/research/video/query/") |>
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
    httr2::resp_body_json()

}


#' Create a traktok query
#'
#' Create a traktok query from the given parameters.
#'
#' @param and,or,not A list of AND/OR/NOT conditions. Must contain one
#'   or multiple lists with \code{field_name}, \code{operation}, and
#'   \code{field_values} each (see example).
#' @param q A traktok query created with \code{query}.
#' @param field_name The field name to query against. One of:
#'   "create_date", "username", "region_code", "video_id",
#'   "hashtag_name", "keyword", "music_id", "effect_id",
#'   "video_length".
#' @param operation One of: "EQ", "IN", "GT", "GTE", "LT", "LTE".
#' @param field_values A vector of values to search for.
#'
#' @details TikTok's query consists of rather complicated lists
#'   dividing query elements into AND, OR and NOT:
#'
#' - **and**: The and conditions specify that all the conditions in the list must be met
#' - **or**: The or conditions specify that at least one of the conditions in the list must be met
#' - **not**: The not conditions specify that none of the conditions in the list must be met
#'
#' The query can be constructed by writing the list for each entry
#' yourself, like in the first example. Alternatively, traktok
#' provides convenience functions to build up a query using
#' \code{query_and}, \code{query_or}, and \code{query_not}, which
#' make building a query a little easier. You can learn more at
#' <https://developers.tiktok.com/doc/research-api-specs-query-videos#query>.
#'
#' @return A traktok query.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # using query directly and supplying the list
#' query(or = list(
#'   list(
#'     field_name = "hashtag_name",
#'     operation = "EQ",
#'     field_values = "rstats"
#'   ),
#'   list(
#'     field_name = "keyword",
#'     operation = "EQ",
#'     field_values = list("rstats", "API")
#'   )
#' ))
#' # starting an empty query and building it up using the query_* functions
#' query() |>
#'   query_or(field_name = "hashtag_name",
#'            operation = "EQ",
#'            field_values = "rstats") |>
#'   query_or(field_name = "keyword",
#'            operation = "IN",
#'            field_values = c("rstats", "API"))
#' }
#'
#' @md
query <- function(and = NULL, or = NULL, not = NULL) {
  q <- list(and = and, or = or, not = not)
  class(q) <- "traktok_query"
  return(clean_query(q))
}


#' @rdname query
#' @export
query_and <- function(q, field_name, operation, field_values) {
  if (!is_query(q))
    cli::cli_abort("{.fn query_and} needs a query as input")

  # TODO: is this really the best way to append the list?
  q$and[[length(q$and) + 1]] <- list(field_name = field_name,
                                     operation = operation,
                                     field_values = as.list(field_values))

  return(clean_query(q))
}


#' @rdname query
#' @export
query_or <- function(q, field_name, operation, field_values) {
  if (!is_query(q))
    cli::cli_abort("{.fn query_or} needs a query as input")

  q$or[[length(q$or) + 1]] <- list(field_name = field_name,
                                     operation = operation,
                                     field_values = as.list(field_values))

  return(clean_query(q))
}


#' @rdname query
#' @export
query_not <- function(q, field_name, operation, field_values) {
  if (!is_query(q))
    cli::cli_abort("{.fn query_not} needs a query as input")

  q$not[[length(q$not) + 1]] <- list(field_name = field_name,
                                     operation = operation,
                                     field_values = as.list(field_values))

  return(clean_query(q))
}


is_query <- function(q) {
  methods::is(q, "traktok_query")
}


# make sure query only consists of valid entries
clean_query <- function(q) {

  for (o in names(q)) {
    q[[o]][purrr::map_int(q[[o]], length) != 3] <- NULL
    q[!purrr::map_int(q, length) > 0]  <- NULL
  }

  return(q)
}


#' @title Print a traktok query
#' @description Print a traktok query as a tree
#' @param x An object of class \code{traktok_query}
#' @param ... Additional arguments passed to \code{lobstr::tree}
#' @export
#' @examples
#' query() |>
#'   query_and(field_name = "hashtag_name",
#'             operation = "EQ",
#'             field_values = "rstats") |>
#'   print()
print.traktok_query <- function(x, ...) {
  lobstr::tree(as.list(x), ...)
}

#' @title Print search result
#' @description Print a traktok search results
#' @param x An object of class \code{tt_results}
#' @param ... not used.
#' @export
print.tt_results <- function(x, ...) {
  cli::cat_rule(paste("search id:",  cli::col_red(attr(x, "search_id"))))
  print(tibble::as_tibble(x))
}
