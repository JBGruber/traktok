#' Query TikTok videos using the research API
#'
#' @description \ifelse{html}{\figure{api-research.svg}{options: alt='[Works on:
#'   Research API]'}}{\strong{[Works on: Research API]}}
#'
#'   This is the version of \link{tt_search} that explicitly uses Research API.
#'   Use \link{tt_search_hidden} for the unofficial API version.
#'
#' @param query A query string or object (see \link{query}).
#' @param start_date,end_date A start and end date to narrow the search
#'   (required; can be a maximum of 30 days apart).
#' @param fields The fields to be returned (defaults to all)
#' @param start_cursor The starting cursor, i.e., how many results to skip (for
#'   picking up an old search).
#' @param search_id The search id (for picking up an old search).
#' @param is_random Whether the query is random (defaults to FALSE).
#' @param max_pages results are returned in batches/pages with 100 videos. How
#'   many should be requested before the function stops?
#' @param parse Should the results be parsed? Otherwise, the original JSON
#'   object is returned as a nested list.
#' @param cache should progress be saved in the current session? It can then be
#'   retrieved with \code{last_query()} if an error occurs. But the function
#'   will use extra memory.
#' @param verbose should the function print status updates to the screen?
#' @param token The authentication token (usually supplied automatically after
#'   running \link{auth_research} once).
#'
#' @return A data.frame of parsed TikTok videos (or a nested list).
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
#'
#' # when a search fails after a while, get the results and pick it back up
#' # (only work with same parameters)
#' last_pull <- last_query()
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
#'   tt_search_api(start_cursor = length(last_pull) + 1,
#'                 search_id = attr(last_pull, "search_id"))
#' }
tt_search_api <- function(
  query,
  start_date = Sys.Date() - 1,
  end_date = Sys.Date(),
  fields = "all",
  start_cursor = 0L,
  search_id = NULL,
  is_random = FALSE,
  max_pages = 1,
  parse = TRUE,
  cache = TRUE,
  verbose = TRUE,
  token = NULL
) {
  if (is.character(query)) {
    query <- query(
      or = list(
        list(
          field_name = "hashtag_name",
          operation = "IN",
          field_values = as.list(sub(
            "#",
            "",
            strsplit(query, " ", fixed = TRUE)
          ))
        ),
        list(
          field_name = "keyword",
          operation = "IN",
          field_values = as.list(strsplit(query, " ", fixed = TRUE))
        )
      )
    )
  }

  if (fields == "all") {
    fields <- "id,video_description,create_time,region_code,share_count,view_count,like_count,comment_count,music_id,hashtag_names,username,effect_ids,playlist_id,voice_to_text"
  }

  if (is_datetime(start_date)) {
    start_date <- format(start_date, "%Y%m%d")
  } else if (!grepl("\\d{8}", start_date)) {
    cli::cli_abort(
      "{.code start_date} needs to be a valid date or a string like, e.g., \"20210102\""
    )
  }

  if (is_datetime(end_date)) {
    end_date <- format(end_date, "%Y%m%d")
  } else if (!grepl("\\d{8}", start_date)) {
    cli::cli_abort(
      "{.code start_date} needs to be a valid date or a string like, e.g., \"20210102\""
    )
  }

  if (verbose) {
    cli::cli_progress_step("Making initial request")
  }

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
  videos <- purrr::pluck(res, "data", "videos")
  the$search_id <- spluck(res, "data", "search_id")
  the$cursor <- spluck(res, "data", "cursor")
  the$videos <- videos

  the$page <- 1

  if (verbose) {
    cli::cli_progress_bar(
      format = "{cli::pb_spin} Got {page} page{?s} with {length(videos)} video{?s} {cli::col_silver('[', cli::pb_elapsed, ']')}",
      format_done = "{cli::col_green(cli::symbol$tick)} Got {page} page{?s} with {length(videos)} video{?s}",
      .envir = the
    )
  }

  while (
    purrr::pluck(res, "data", "has_more", .default = FALSE) &&
      the$page < max_pages
  ) {
    the$page <- the$page + 1
    the$cursor <- spluck(res, "data", "cursor")
    if (verbose) {
      cli::cli_progress_update(force = TRUE, .envir = the)
    }
    res <- tt_query_request(
      endpoint = "query/",
      query = query,
      start_date = start_date,
      end_date = end_date,
      fields = fields,
      cursor = the$cursor,
      search_id = the$search_id,
      is_random = is_random,
      token = token
    )
    videos <- c(videos, purrr::pluck(res, "data", "videos"))
    if (cache) {
      the$videos <- videos
    }
    if (verbose) cli::cli_progress_done()
  }

  if (parse) {
    if (verbose) {
      cli::cli_progress_done()
      cli::cli_progress_step("Parsing data")
    }
    videos <- parse_api_search(videos)
    if (verbose) cli::cli_progress_done()
  }
  class(videos) <- c("tt_results", class(videos))
  attr(videos, "search_id") <- the$search_id
  attr(videos, "cursor") <- the$cursor
  return(videos)
}


#' @export
#' @rdname tt_search_api
tt_query_videos <- tt_search_api


# used to iterate over search requests
tt_query_request <- function(
  endpoint,
  query = NULL,
  video_id = NULL,
  start_date = NULL,
  end_date = NULL,
  fields = NULL,
  cursor = NULL,
  search_id = NULL,
  is_random = NULL,
  token = NULL
) {
  if (is.null(token)) {
    token <- get_token()
  }

  if (!is.null(query) && !is_query(query)) {
    cli::cli_abort("query needs to be a query object (see {.code ?query})")
  }

  body <- list(
    query = unclass(query),
    video_id = video_id,
    start_date = start_date,
    end_date = end_date,
    max_count = 100L,
    cursor = cursor,
    search_id = search_id,
    is_random = is_random
  )

  httr2::request("https://open.tiktokapis.com/v2/research/video/") |>
    httr2::req_url_path_append(endpoint) |>
    httr2::req_method("POST") |>
    httr2::req_url_query(fields = fields) |>
    httr2::req_headers("Content-Type" = "application/json") |>
    httr2::req_auth_bearer_token(token$access_token) |>
    httr2::req_body_json(data = purrr::discard(body, is.null)) |>
    httr2::req_error(body = api_error_handler) |>
    httr2::req_retry(
      max_tries = 5L,
      # don't retry when daily quota is reached (429)
      is_transient = function(resp) {
        httr2::resp_status(resp) %in% c(301:399, 401:428, 430:599)
      },
      # increase backoff after each try
      backoff = function(t) t^3
    ) |>
    httr2::req_perform() |>
    httr2::resp_body_json(bigint_as_char = TRUE)
}


#' Lookup which videos were liked by a user using the research API
#'
#' @description \ifelse{html}{\figure{api-research.svg}{options: alt='[Works on:
#'   Research API]'}}{\strong{[Works on: Research API]}}
#'
#' @param username name(s) of the user(s) to be queried
#' @param fields The fields to be returned (defaults to all)
#' @inheritParams tt_search_api
#'
#' @return A data.frame of parsed TikTok videos the user has posted.
#' @export
#'
#' @examples
#' \dontrun{
#' tt_get_liked("jbgruber")
#' # OR
#' tt_user_liked_videos_api("https://www.tiktok.com/@tiktok")
#' # OR
#' tt_user_liked_videos_api("https://www.tiktok.com/@tiktok")
#'
#' # note: none of these work because I could not find any account that
#' # has likes public!
#' }
tt_user_liked_videos_api <- function(
  username,
  fields = "all",
  max_pages = 1,
  cache = TRUE,
  verbose = TRUE,
  token = NULL
) {
  purrr::map(username, function(u) {
    # if username is given as URL
    if (grepl("/", u)) {
      u <- extract_regex(
        u,
        "(?<=.com/@)(.+?)(?=\\?|$|/)"
      )
    }
    if (verbose) {
      cli::cli_progress_step(
        msg = "Getting user {u}",
        msg_done = "Got user {u}"
      )
    }
    the$result <- TRUE
    if (is.null(token)) {
      token <- get_token()
    }

    if (fields == "all") {
      fields <- c(
        "id",
        "create_time",
        "username",
        "region_code",
        "video_description",
        "music_id",
        "like_count",
        "comment_count",
        "share_count",
        "view_count",
        "hashtag_names",
        " is_stem_verified",
        # " favourites_count",
        " video_duration"
      ) |>
        paste0(collapse = ",")
    }

    res <- list(data = list(has_more = TRUE, cursor = NULL))
    the$page <- 0L
    videos <- list()
    # iterate over pages
    while (
      purrr::pluck(res, "data", "has_more", .default = FALSE) &&
        the$page < max_pages
    ) {
      the$page <- the$page + 1
      the$cursor <- purrr::pluck(res, "data", "cursor")

      res <- tt_user_request(
        endpoint = "liked_videos/",
        username = u,
        fields = fields,
        cursor = the$cursor,
        token = token
      )

      videos <- c(videos, purrr::pluck(res, "data", "user_liked_videos"))
      if (cache) {
        the$videos <- videos
      }
    }

    if (length(videos) > 0) {
      videos <- videos |>
        purrr::map(as_tibble_onerow) |>
        dplyr::bind_rows() |>
        # somehow, the order changes between, calls. So I fix it here
        dplyr::relocate(
          "id",
          "username",
          "create_time",
          "video_description",
          "region_code",
          "video_duration",
          "view_count",
          "like_count",
          "comment_count",
          "share_count",
          "music_id"
        )

      videos <- tibble::add_column(videos, liked_by_user = u)
      if (verbose) {
        cli::cli_progress_done(
          result = ifelse(length(videos) > 1, "done", "failed")
        )
      }

      return(videos)
    }
  }) |>
    dplyr::bind_rows()
}


#' Lookup which videos were liked by a user using the research API
#'
#' @description \ifelse{html}{\figure{api-research.svg}{options: alt='[Works on:
#'   Research API]'}}{\strong{[Works on: Research API]}}
#'
#' @param username name(s) of the user(s) to be queried
#' @param fields The fields to be returned (defaults to all)
#' @inheritParams tt_search_api
#'
#' @return A data.frame of parsed TikTok videos the user has posted.
#' @export
#'
#' @examples
#' \dontrun{
#' tt_get_reposted("jbgruber")
#' # OR
#' tt_user_reposted_api("https://www.tiktok.com/@tiktok")
#' # OR
#' tt_user_reposted_api("https://www.tiktok.com/@tiktok")
#'
#' # note: none of these work because nobody has this enabled!
#' }
tt_user_reposted_api <- function(
  username,
  fields = "all",
  max_pages = 1,
  cache = TRUE,
  verbose = TRUE,
  token = NULL
) {
  purrr::map(username, function(u) {
    # if username is given as URL
    if (grepl("/", u)) {
      u <- extract_regex(
        u,
        "(?<=.com/@)(.+?)(?=\\?|$|/)"
      )
    }
    if (verbose) {
      cli::cli_progress_step(
        msg = "Getting user {u}",
        msg_done = "Got user {u}"
      )
    }
    the$result <- TRUE
    if (is.null(token)) {
      token <- get_token()
    }

    if (fields == "all") {
      fields <- c(
        "id",
        "create_time",
        "username",
        "region_code",
        "video_description",
        "music_id",
        "like_count",
        "comment_count",
        "share_count",
        "view_count",
        "hashtag_names",
        "is_stem_verified",
        "favourites_count",
        "video_duration"
      ) |>
        paste0(collapse = ",")
    }

    res <- list(data = list(has_more = TRUE, cursor = NULL))
    the$page <- 0L
    videos <- list()
    # iterate over pages
    while (
      purrr::pluck(res, "data", "has_more", .default = FALSE) &&
        the$page < max_pages
    ) {
      the$page <- the$page + 1
      the$cursor <- purrr::pluck(res, "data", "cursor")

      res <- tt_user_request(
        endpoint = "reposted_videos/",
        username = u,
        fields = fields,
        cursor = the$cursor,
        token = token
      )

      videos <- c(videos, purrr::pluck(res, "data", "reposted_videos"))
      if (cache) {
        the$videos <- videos
      }
    }

    videos2 <- videos |>
      purrr::map(as_tibble_onerow) |>
      dplyr::bind_rows() |>
      # somehow, the order changes between, calls. So I fix it here
      dplyr::relocate(
        "id",
        "username",
        "create_time",
        "video_description",
        "region_code",
        "video_duration",
        "view_count",
        "like_count",
        "comment_count",
        "share_count",
        "music_id"
      )

    videos <- tibble::add_column(videos, reposted_by_user = u)
    if (verbose) {
      cli::cli_progress_done(
        result = ifelse(length(videos) > 1, "done", "failed")
      )
    }

    return(videos)
  }) |>
    dplyr::bind_rows()
}


#' Lookup which videos were pinned by a user using the research API
#'
#' @description \ifelse{html}{\figure{api-research.svg}{options: alt='[Works on:
#'   Research API]'}}{\strong{[Works on: Research API]}}
#'
#' @param username vector of user names (handles) or URLs to users' pages.
#' @inheritParams tt_search_api
#'
#' @return A data.frame of parsed TikTok videos the user has posted.
#' @export
#'
#' @examples
#' \dontrun{
#' tt_get_pinned("jbgruber")
#' # OR
#' tt_user_pinned_videos_api("https://www.tiktok.com/@tiktok")
#' # OR
#' tt_user_pinned_videos_api("https://www.tiktok.com/@tiktok")
#' }
tt_user_pinned_videos_api <- function(
  username,
  fields = "all",
  cache = TRUE,
  verbose = TRUE,
  token = NULL
) {
  purrr::map(username, function(u) {
    # if username is given as URL
    if (grepl("/", u)) {
      u <- extract_regex(
        u,
        "(?<=.com/@)(.+?)(?=\\?|$|/)"
      )
    }
    if (verbose) {
      cli::cli_progress_step(
        msg = "Getting user {u}",
        msg_done = "Got user {u}"
      )
    }
    the$result <- TRUE
    if (is.null(token)) {
      token <- get_token()
    }

    if (fields == "all") {
      fields <- c(
        "id",
        "create_time",
        "username",
        "region_code",
        "video_description",
        "music_id",
        "like_count",
        "comment_count",
        "share_count",
        "view_count",
        "hashtag_names",
        "is_stem_verified",
        # mentioned in docs, but does not work
        # "favourites_count",
        "video_duration"
      ) |>
        paste0(collapse = ",")
    }

    res <- tt_user_request(
      endpoint = "pinned_videos/",
      username = u,
      fields = fields,
      cursor = NULL,
      token = token
    )

    videos <- purrr::pluck(res, "data", "pinned_videos_list") |>
      purrr::map(as_tibble_onerow) |>
      dplyr::bind_rows() |>
      tibble::add_column(pinned_by_user = u)

    if (cache) {
      the$videos <- videos
    }

    if (verbose) {
      cli::cli_progress_done(
        result = ifelse(length(videos) > 1, "done", "failed")
      )
    }

    return(videos)
  }) |>
    dplyr::bind_rows()
}


#' @title Get followers and following of users from the research API
#'
#' @description \ifelse{html}{\figure{api-research.svg}{options: alt='[Works on:
#'   Research API]'}}{\strong{[Works on: Research API]}}
#'
#' @param username name(s) of the user(s) to be queried
#' @inheritParams tt_search_api
#'
#' @return A data.frame containing follower of following account information.
#' @export
#'
#' @examples
#' \dontrun{
#' tt_user_follower_api("jbgruber")
#' # OR
#' tt_user_following_api("https://www.tiktok.com/@tiktok")
#' # OR
#' tt_get_follower("https://www.tiktok.com/@tiktok")
#' }
tt_user_follower_api <- function(
  username,
  max_pages = 1,
  cache = TRUE,
  verbose = TRUE,
  token = NULL
) {
  tt_user_follow(
    endpoint = "followers/",
    username = username,
    max_pages = max_pages,
    cache = cache,
    verbose = verbose,
    token = token
  )
}


#' @rdname tt_user_follower_api
#' @export
tt_user_following_api <- function(
  username,
  max_pages = 1,
  cache = TRUE,
  verbose = TRUE,
  token = NULL
) {
  tt_user_follow(
    endpoint = "following/",
    username = username,
    max_pages = max_pages,
    cache = cache,
    verbose = verbose,
    token = token
  )
}


tt_user_follow <- function(
  endpoint,
  username,
  max_pages = 1,
  cache = TRUE,
  verbose = TRUE,
  token = NULL
) {
  purrr::map(username, function(u) {
    # if username is given as URL
    if (grepl("/", u)) {
      u <- extract_regex(
        u,
        "(?<=.com/@)(.+?)(?=\\?|$|/)"
      )
    }
    if (verbose) {
      cli::cli_progress_step(
        msg = "Getting user {u}",
        msg_done = "Got user {u}"
      )
    }
    the$result <- TRUE
    if (is.null(token)) {
      token <- get_token()
    }

    res <- list(data = list(has_more = TRUE, cursor = NULL))
    the$page <- 0L
    followers <- list()
    # iterate over pages
    while (
      purrr::pluck(res, "data", "has_more", .default = FALSE) &&
        the$page < max_pages
    ) {
      the$page <- the$page + 1
      the$cursor <- purrr::pluck(res, "data", "cursor")

      res <- tt_user_request(
        endpoint = endpoint,
        username = u,
        cursor = the$cursor,
        token = token
      )

      followers <- c(
        followers,
        purrr::pluck(
          res,
          "data",
          ifelse(endpoint == "followers/", "user_followers", "user_following")
        )
      )
      if (cache) {
        the$videos <- followers
      }
    }

    followers <- dplyr::bind_rows(followers)
    followers <- tibble::add_column(followers, following_user = u)
    if (verbose) {
      cli::cli_progress_done(
        result = ifelse(length(followers) > 1, "done", "failed")
      )
    }

    return(followers)
  }) |>
    dplyr::bind_rows()
}

# used to iterate over search requests
tt_user_request <- function(endpoint, username, fields, cursor, token) {
  req <- httr2::request("https://open.tiktokapis.com/v2/research/user/") |>
    httr2::req_url_path_append(endpoint) |>
    httr2::req_method("POST") |>
    httr2::req_headers("Content-Type" = "application/json") |>
    httr2::req_auth_bearer_token(token$access_token) |>
    httr2::req_body_json(
      data = list(username = username, max_count = 100L, cursor = cursor)
    ) |>
    httr2::req_error(
      is_error = api_user_error_checker,
      body = api_error_handler
    ) |>
    httr2::req_retry(max_tries = 5)

  if (!missing(fields)) {
    req <- req |>
      httr2::req_url_query(fields = fields)
  }

  req |>
    httr2::req_perform() |>
    httr2::resp_body_json(bigint_as_char = TRUE)
}


#' Lookup TikTok information about a user using the research API
#'
#' @description \ifelse{html}{\figure{api-research.svg}{options: alt='[Works on:
#'   Research API]'}}{\strong{[Works on: Research API]}}
#'
#' @inheritParams tt_user_liked_videos_api
#'
#' @return A data.frame of parsed TikTok videos the user has posted.
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
tt_user_info_api <- function(
  username,
  fields = "all",
  verbose = TRUE,
  token = NULL
) {
  out <- purrr::map(username, function(u) {
    # if username is given as URL
    if (grepl("/", u)) {
      u <- extract_regex(
        u,
        "(?<=.com/@)(.+?)(?=\\?|$|/)"
      )
    }
    if (verbose) {
      cli::cli_progress_step(
        msg = "Getting user {u}",
        msg_done = "Got user {u}"
      )
    }
    the$result <- TRUE
    if (is.null(token)) {
      token <- get_token()
    }

    if (fields == "all") {
      fields <- c(
        "display_name",
        "bio_description",
        "avatar_url",
        "is_verified",
        "follower_count",
        "following_count",
        "likes_count",
        "video_count"
      ) |>
        paste0(collapse = ",")
    }

    # /tests/testthat/example_resp_q_user.json
    out <- httr2::request(
      "https://open.tiktokapis.com/v2/research/user/info/"
    ) |>
      httr2::req_method("POST") |>
      httr2::req_url_query(fields = fields) |>
      httr2::req_headers("Content-Type" = "application/json") |>
      httr2::req_auth_bearer_token(token$access_token) |>
      httr2::req_body_json(data = list(username = u)) |>
      httr2::req_error(
        is_error = api_user_error_checker,
        body = api_error_handler
      ) |>
      httr2::req_retry(max_tries = 5, backoff = function(t) t^3) |>
      httr2::req_perform() |>
      httr2::resp_body_json(bigint_as_char = TRUE) |>
      purrr::pluck("data") |>
      tibble::as_tibble()
    if (verbose & !the$result) {
      cli::cli_progress_done(result = "failed")
    }
    return(out)
  }) |>
    dplyr::bind_rows()
  if (verbose) {
    cli::cli_progress_done()
  }
  return(out)
}


#' Retrieve video comments
#'
#' @description
#' \ifelse{html}{\figure{api-research.svg}{options: alt='[Works on: Research API]'}}{\strong{[Works on: Research API]}}
#'
#' @param video_id The id or URL of a video
#' @inheritParams tt_search_api
#'
#' @return A data.frame of parsed comments.
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
tt_comments_api <- function(
  video_id,
  fields = "all",
  start_cursor = 0L,
  max_pages = 1L,
  cache = TRUE,
  verbose = TRUE,
  token = NULL
) {
  # if video_id is given as URL
  if (grepl("[^0-9]", video_id)) {
    video_id <- extract_regex(
      video_id,
      "(?<=/video/)(.+?)(?=\\?|$)|(?<=https://vm.tiktok.com/).+?(?=/|$)"
    )
  }

  if (fields == "all") {
    fields <- "id,video_id,text,like_count,reply_count,parent_comment_id,create_time"
  }

  if (verbose) {
    cli::cli_progress_step("Making initial request")
  }

  res <- tt_query_request(
    endpoint = "comment/list/",
    video_id = video_id,
    fields = fields,
    cursor = start_cursor,
    token = token
  )
  comments <- purrr::pluck(res, "data", "comments")
  if (cache) {
    the$comments <- comments
  }
  the$page <- 1

  if (verbose) {
    cli::cli_progress_bar(
      format = "{cli::pb_spin} Got {page} page{?s} with {length(the$comments)} comment{?s} {cli::col_silver('[', cli::pb_elapsed, ']')}",
      format_done = "{cli::col_green(cli::symbol$tick)} Got {page} page{?s} with {length(the$comments)} comment{?s}",
      .envir = the
    )
  }

  while (
    purrr::pluck(res, "data", "has_more", .default = FALSE) &&
      the$page < max_pages
  ) {
    the$page <- the$page + 1
    if (verbose) {
      cli::cli_progress_update(.envir = the)
    }
    res <- tt_query_request(
      endpoint = "comment/list/",
      video_id = video_id,
      fields = fields,
      cursor = purrr::pluck(res, "data", "cursor", .default = NULL),
      token = token
    )
    comments <- c(comments, purrr::pluck(res, "data", "comments"))
    if (cache) {
      the$comments <- comments
    }
    if (verbose) cli::cli_progress_done()
  }

  if (verbose) {
    cli::cli_progress_done()
    cli::cli_progress_step("Parsing data")
  }
  out <- parse_api_comments(comments)

  return(out)
}


#' Lookup TikTok playlist using the research API
#'
#' @description \ifelse{html}{\figure{api-research.svg}{options: alt='[Works on:
#'   Research API]'}}{\strong{[Works on: Research API]}}
#'
#' @param playlist_id playlist ID or URL to a playlist.
#' @inheritParams tt_user_info_api
#'
#' @return A data.frame video metadata.
#' @export
tt_playlist_api <- function(playlist_id, verbose = TRUE, token = NULL) {
  # the docs mention a cursor, but it's not implemented as far as I can tell
  cursor <- NULL

  if (grepl("/", playlist_id)) {
    playlist_id <- extract_regex(
      playlist_id,
      "(?<=-)([0-9]+?)(?=\\?|$|/)"
    )
  }

  if (is.null(token)) {
    token <- get_token()
  }

  out <- httr2::request(
    "https://open.tiktokapis.com/v2/research/playlist/info/"
  ) |>
    httr2::req_method("POST") |>
    httr2::req_headers("Content-Type" = "application/json") |>
    httr2::req_auth_bearer_token(token$access_token) |>
    httr2::req_body_json(
      data = list(playlist_id = playlist_id, cursor = cursor)
    ) |>
    httr2::req_error(
      is_error = function(resp) {
        # API always seems to send 500, even when successful
        !httr2::resp_status(resp) %in% c(100:399, 500)
      },
      body = api_error_handler
    ) |>
    httr2::req_retry(max_tries = 5) |>
    httr2::req_perform() |>
    httr2::resp_body_json(bigint_as_char = TRUE) |>
    purrr::pluck("data") |>
    tibble::as_tibble()

  return(out)
}


api_error_handler <- function(resp) {
  # failsafe save already collected videos to disk
  if (purrr::pluck_exists(the, "videos")) {
    q <- the$videos
    attr(q, "search_id") <- the$search_id
    saveRDS(q, tempfile(fileext = ".rds"))
  }

  if (httr2::resp_content_type(resp) == "application/json") {
    return(
      c(
        paste("status:", httr2::resp_body_json(resp)$error$code),
        paste("message:", httr2::resp_body_json(resp)$error$message),
        paste("log_id:", httr2::resp_body_json(resp)$error$log_id)
      )
    )
  }

  if (httr2::resp_content_type(resp) == "text/html") {
    res <- httr2::resp_body_html(resp)
    return(
      c(
        paste("status:", rvest::html_text2(rvest::html_element(res, "title"))),
        paste("message:", rvest::html_text2(rvest::html_element(res, "body")))
      )
    )
  }
}


api_user_error_checker <- function(resp) {
  if (httr2::resp_status(resp) < 400L) {
    return(FALSE)
  }
  if (httr2::resp_status(resp) == 404L) {
    return(TRUE)
  }
  # it looks like the API sometimes returns 500 falsely, but in these cases, no
  # error message is present
  if (
    httr2::resp_status(resp) == 500L &&
      !purrr::pluck_exists(httr2::resp_body_json(resp), "error", "message")
  ) {
    return(FALSE)
  }
  # if likes can't be accessed, which is true for many users, this should
  # not throw an error
  issue1 <- grepl(
    "information.cannot.be.returned",
    httr2::resp_body_json(resp)$error$message
  )
  # if the user can't be found, this should not throw an error, which
  # would break the loop
  issue2 <- grepl(
    "cannot.find.the.user",
    httr2::resp_body_json(resp)$error$message
  )
  # if account is private
  issue3 <- grepl("is.private", httr2::resp_body_json(resp)$error$message)
  issue4 <- grepl(
    "API.cannot.return.this.user's.information",
    httr2::resp_body_json(resp)$error$message
  )

  if (any(issue1, issue2, issue3, issue4)) {
    cli::cli_alert_warning(httr2::resp_body_json(resp)$error$message)
    the$result <- FALSE
    return(FALSE)
  }
  return(TRUE)
}
