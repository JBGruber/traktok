# all fields of the video object, see
# https://developers.tiktok.com/doc/research-api-specs-query-videos
api_video_fields <- c(
  "id",
  "video_description",
  "create_time",
  "region_code",
  "share_count",
  "view_count",
  "like_count",
  "comment_count",
  "music_id",
  "hashtag_names",
  "username",
  "effect_ids",
  "playlist_id",
  "voice_to_text",
  "is_stem_verified",
  "favorites_count",
  "video_duration",
  "hashtag_info_list",
  "sticker_info_list",
  "effect_info_list",
  "video_mention_list",
  "video_label",
  "video_tag"
)


#' @noRd
parse_api_search <- function(x) {
  out <- tibble::tibble(
    video_id = dplyr::coalesce(pluck_id(x, "video_id"), pluck_id(x, "id")),
    author_name = vpluck(x, "username", val = "character"),
    # counts are doubles, since jsonlite returns those as soon as they exceed
    # the integer range, which view counts can
    view_count = vpluck(x, "view_count", val = "double"),
    comment_count = vpluck(x, "comment_count", val = "double"),
    share_count = vpluck(x, "share_count", val = "double"),
    like_count = vpluck(x, "like_count", val = "double"),
    favorites_count = vpluck(x, "favorites_count", val = "double"),
    region_code = vpluck(x, "region_code", val = "character"),
    create_time = as.POSIXct(
      vpluck(x, "create_time", val = "integer"),
      tz = "UTC",
      origin = "1970-01-01"
    ),
    video_duration = vpluck(x, "video_duration", val = "integer"),
    effect_ids = vpluck(x, "effect_ids", val = "list"),
    effect_info_list = pluck_objects(x, "effect_info_list"),
    # 0 means the video has no music or is not part of a playlist
    music_id = dplyr::na_if(pluck_id(x, "music_id"), "0"),
    playlist_id = dplyr::na_if(pluck_id(x, "playlist_id"), "0"),
    video_description = vpluck(x, "video_description", val = "character"),
    hashtag_names = vpluck(x, "hashtag_names", val = "list"),
    hashtag_info_list = pluck_objects(x, "hashtag_info_list"),
    video_mention_list = vpluck(x, "video_mention_list", val = "list"),
    sticker_info_list = pluck_objects(x, "sticker_info_list"),
    voice_to_text = vpluck(x, "voice_to_text", val = "character"),
    is_stem_verified = vpluck(x, "is_stem_verified", val = "logical"),
    video_label = pluck_objects(x, "video_label", single = TRUE),
    video_tag = purrr::map(pluck_objects(x, "video_tag"), label_video_tags)
  )

  # keep fields the parser does not know (yet) instead of dropping them
  extra <- setdiff(
    unique(unlist(purrr::map(x, names))),
    c(api_video_fields, "video_id")
  )
  for (f in extra) {
    col <- purrr::map(x, f)
    is_scalar <- purrr::map_lgl(col, \(v) {
      is.null(v) || (is.atomic(v) && length(v) == 1L)
    })
    if (all(is_scalar)) {
      col <- if (grepl("_id$", f)) {
        purrr::map_chr(col, as_id)
      } else {
        unlist(purrr::map(col, \(v) if (is.null(v)) NA else v))
      }
    }
    out[[f]] <- col
  }

  if (nrow(out) == 1L && is.na(out$video_id)) {
    out <- out[-1, ]
  }
  return(out)
}


# ids are parsed as character, integer or double depending on their size (with
# bigint_as_char = TRUE), so they are all turned into character
#' @noRd
as_id <- function(v) {
  if (length(v) != 1L || is.list(v)) {
    return(NA_character_)
  }
  # as.character would use scientific notation for large doubles
  if (is.double(v)) {
    return(sprintf("%.0f", v))
  }
  as.character(v)
}


#' @noRd
pluck_id <- function(x, field) {
  vapply(x, function(i) as_id(purrr::pluck(i, field)), character(1))
}


# turns a field containing a list of objects (or a single object) into a
# tibble per video with one row per object
#' @noRd
pluck_objects <- function(x, field, single = FALSE) {
  purrr::map(x, function(i) {
    objs <- purrr::pluck(i, field, .default = list())
    if (single && length(objs) > 0L) {
      objs <- list(objs)
    }
    purrr::map(objs, function(o) {
      o <- purrr::compact(o)
      o <- purrr::imap(o, \(v, nm) if (grepl("_id$", nm)) as_id(v) else v)
      as_tibble_onerow(o)
    }) |>
      dplyr::bind_rows()
  })
}


# meaning of video tags as listed in the API documentation
#' @noRd
label_video_tags <- function(tags) {
  if (!all(c("type", "number") %in% colnames(tags))) {
    return(tags)
  }
  labels <- tibble::tibble(
    type = c("AIGC Type", "AIGC Type", "Branded Type", "Branded Type"),
    number = c(1L, 2L, 1L, 7L),
    label = c(
      "Creator Labelled as AI-Generated",
      "AI-Generated",
      "Paid Partnership",
      "Creator Earns Commission"
    )
  )
  tags$number <- as.integer(tags$number)
  dplyr::left_join(tags, labels, by = c("type", "number"))
}


#' @noRd
parse_api_comments <- function(x) {
  out <- x |>
    dplyr::bind_rows()

  class(out) <- c("tt_results", class(out))

  return(out)
}


#' @title Print search result
#' @description Print a traktok search results
#' @param x An object of class \code{tt_results}
#' @param ... not used.
#'
#' @return nothing. Prints search results.
#' @export
print.tt_results <- function(x, ...) {
  # not all endpoints return a search id (e.g., comments)
  search_id <- attr(x, "search_id")
  if (length(search_id) > 0 && !identical(search_id, "")) {
    cli::cat_rule(paste("search id:", cli::col_red(search_id)))
  }
  print(tibble::as_tibble(x, ...))
}
