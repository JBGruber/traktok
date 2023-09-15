#' @noRd
parse_video <- function(json_string, video_id) {

  tt_data <- jsonlite::fromJSON(json_string)

  video_url <- attr(json_string, "url_full")
  html_status <- attr(json_string, "html_status")
  video_timestamp <- purrr::pluck(tt_data, "ItemModule", video_id, "createTime",
                                  .default = NA_character_) |>
    as.integer() |>
    as.POSIXct(tz = "UTC", origin = "1970-01-01")

  tibble::tibble(
    video_id              = video_id,
    video_url             = video_url,
    video_timestamp       = video_timestamp,
    video_length          = spluck(tt_data, "ItemModule", video_id, "video", "duration"),
    video_title           = spluck(tt_data, "ItemModule", video_id, "desc"),
    video_locationcreated = spluck(tt_data, "ItemModule", video_id, "locationCreated"),
    video_diggcount       = spluck(tt_data, "ItemModule", video_id, "stats", "diggCount"),
    video_sharecount      = spluck(tt_data, "ItemModule", video_id, "stats", "shareCount"),
    video_commentcount    = spluck(tt_data, "ItemModule", video_id, "stats", "commentCount"),
    video_playcount       = spluck(tt_data, "ItemModule", video_id, "stats", "playCount"),
    author_username       = spluck(tt_data, "ItemModule", video_id, "author"),
    author_nickname       = spluck(tt_data, "UserModule", "users", 1, "nickname"),
    author_bio            = spluck(tt_data, "UserModule", "users", 1, "signature"),
    download_url          = spluck(tt_data, "ItemModule", video_id, "video", "downloadAddr"),
    html_status           = html_status,
    music                 = list(spluck(tt_data, "ItemModule", video_id, "music")),
    challenges            = list(spluck(tt_data, "ItemModule", video_id, "challenges")),
    is_classified         = isTRUE(spluck(tt_data, "ItemModule", video_id, "isContentClassified"))
  )

}


#' @noRd
parse_search <- function(res) {
  tt_data <- res |>
    httr2::resp_body_json()

  tt_videos <- spluck(tt_data, "data")

  author_name <- vpluck(tt_videos, "item", "author", "uniqueId")
  video_id <- vpluck(tt_videos, "item", "id")
  video_url <- glue::glue("https://www.tiktok.com/@{author_name}/video/{video_id}")
  video_timestamp <- vpluck(tt_videos, "item", "createTime", val = "integer") |>
    as.integer() |>
    as.POSIXct(tz = "UTC", origin = "1970-01-01")
  tt_videos[[1]][["item"]][["video"]][["duration"]]
  out <- tibble::tibble(
    video_id              = video_id,
    video_timestamp       = video_timestamp,
    video_url             = video_url,
    video_length          = vpluck(tt_videos, "item", "video", "duration", val = "integer"),
    video_title           = vpluck(tt_videos, "item", "desc"),
    video_diggcount       = vpluck(tt_videos, "item", "stats", "diggCount", val = "integer"),
    video_sharecount      = vpluck(tt_videos, "item", "stats", "shareCount", val = "integer"),
    video_commentcount    = vpluck(tt_videos, "item", "stats", "commentCount", val = "integer"),
    video_playcount       = vpluck(tt_videos, "item", "stats", "playCount", val = "integer"),
    video_is_ad           = vpluck(tt_videos, "item", "isAd", val = "logical"),
    author_name           = vpluck(tt_videos, "item", "author", "uniqueId"),
    author_nickname       = vpluck(tt_videos, "item", "author", "nickname"),
    author_followercount  = vpluck(tt_videos, "item", "authorStats", "followerCount", val = "integer"),
    author_followingcount = vpluck(tt_videos, "item", "authorStats", "followingCount", val = "integer"),
    author_heartcount     = vpluck(tt_videos, "item", "authorStats", "heartCount", val = "integer"),
    author_videocount     = vpluck(tt_videos, "item", "authorStats", "videoCount", val = "integer"),
    author_diggcount      = vpluck(tt_videos, "item", "authorStats", "diggCount", val = "integer"),
    music                 = vpluck(tt_videos, "item", "music", val = "list"),
    challenges            = vpluck(tt_videos, "item", "challenges", val = "list"),
    download_url          = vpluck(tt_videos, "item", "video", "downloadAddr")
  )

  attr(out, "cursor") <- purrr::pluck(tt_data, "cursor", .default = NA)
  attr(out, "has_more") <- as.logical(purrr::pluck(tt_data, "has_more", .default = FALSE))

  return(out)
}
