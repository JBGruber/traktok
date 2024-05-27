#' @noRd
parse_video <- function(json_string, video_id) {

  tt_data <- jsonlite::fromJSON(json_string)

  video_url <- attr(json_string, "url_full")
  html_status <- attr(json_string, "html_status")

  video_data <- purrr::pluck(tt_data, "ItemModule")

  if (!is.null(video_data)) {
    video_timestamp <- purrr::pluck(video_data, video_id, "createTime",
                                    .default = NA_character_) |>
      as.integer() |>
      as.POSIXct(tz = "UTC", origin = "1970-01-01")

    return(tibble::tibble(
      video_id              = video_id,
      video_url             = video_url,
      video_timestamp       = video_timestamp,
      video_length          = spluck(video_data, video_id, "video", "duration"),
      video_title           = spluck(video_data, video_id, "desc"),
      video_locationcreated = spluck(video_data, video_id, "locationCreated"),
      video_diggcount       = spluck(video_data, video_id, "stats", "diggCount"),
      video_sharecount      = spluck(video_data, video_id, "stats", "shareCount"),
      video_commentcount    = spluck(video_data, video_id, "stats", "commentCount"),
      video_playcount       = spluck(video_data, video_id, "stats", "playCount"),
      author_username       = spluck(video_data, video_id, "author"),
      author_nickname       = spluck(tt_data, "UserModule", "users", 1, "nickname"),
      author_bio            = spluck(tt_data, "UserModule", "users", 1, "signature"),
      download_url          = spluck(video_data, video_id, "video", "downloadAddr"),
      html_status           = html_status,
      music                 = list(spluck(video_data, video_id, "music")),
      challenges            = list(spluck(video_data, video_id, "challenges")),
      is_classified         = isTRUE(spluck(video_data, video_id, "isContentClassified")),
      video_status          = spluck(tt_data, "__DEFAULT_SCOPE__", "webapp.video-detail", "statusMsg"),
      video_status_code     = spluck(tt_data, "__DEFAULT_SCOPE__", "webapp.video-detail", "statusCode")
    ))
  }

  video_data <- purrr::pluck(tt_data, "__DEFAULT_SCOPE__", "webapp.video-detail", "itemInfo", "itemStruct")

  if (!is.null(video_data)) {
    video_timestamp <- purrr::pluck(video_data, "createTime",
                                    .default = NA_character_) |>
      as.integer() |>
      as.POSIXct(tz = "UTC", origin = "1970-01-01")

    out <- tibble::tibble(
      video_id              = video_id,
      video_url             = video_url,
      video_timestamp       = video_timestamp,
      video_length          = spluck(video_data, "video", "duration"),
      video_title           = spluck(video_data, "desc"),
      video_locationcreated = spluck(video_data, "locationCreated"),
      video_diggcount       = spluck(video_data, "stats", "diggCount"),
      video_sharecount      = spluck(video_data, "stats", "shareCount"),
      video_commentcount    = spluck(video_data, "stats", "commentCount"),
      video_playcount       = spluck(video_data, "stats", "playCount"),
      author_id             = spluck(video_data, "author", "id"),
      author_secuid         = spluck(video_data, "author", "secUid"),
      author_username       = spluck(video_data, "author", "uniqueId"),
      author_nickname       = spluck(video_data, "author", "nickname"),
      author_bio            = spluck(video_data, "author", "signature"),
      download_url          = spluck(video_data, "video", "downloadAddr"),
      html_status           = html_status,
      music                 = list(spluck(video_data, "music")),
      challenges            = list(spluck(video_data, "challenges")),
      is_secret             = isTRUE(spluck(video_data, "secret")),
      is_for_friend         = isTRUE(spluck(video_data, "forFriend")),
      is_slides             = FALSE,
      video_status          = spluck(tt_data, "__DEFAULT_SCOPE__", "webapp.video-detail", "statusMsg"),
      video_status_code     = spluck(tt_data, "__DEFAULT_SCOPE__", "webapp.video-detail", "statusCode")
    )
    if (identical(out$download_url, "")) {
      out$download_url <- purrr::pluck(video_data, "imagePost", "images", "imageURL", "urlList") |>
        purrr::map_chr(1L) |>
        toString()
      out$is_slides <- TRUE
    }

  } else {
    out <- tibble::tibble(
      video_id              = video_id,
      video_url             = video_url,
      video_timestamp       = NA,
      video_length          = NA,
      video_title           = NA,
      video_locationcreated = NA,
      video_diggcount       = NA,
      video_sharecount      = NA,
      video_commentcount    = NA,
      video_playcount       = NA,
      author_id             = NA,
      author_secuid         = NA,
      author_username       = NA,
      author_nickname       = NA,
      author_bio            = NA,
      download_url          = NA,
      html_status           = html_status,
      music                 = NA,
      challenges            = NA,
      is_secret             = NA,
      is_for_friend         = NA,
      is_slides             = NA,
      video_status          = spluck(tt_data, "__DEFAULT_SCOPE__", "webapp.video-detail", "statusMsg"),
      video_status_code     = spluck(tt_data, "__DEFAULT_SCOPE__", "webapp.video-detail", "statusCode")
    )
    cli::cli_warn("No video data found")
  }
  return(out)
}


#' @noRd
parse_search <- function(res) {
  if (length(purrr::pluck(res, "body")) == 0L)
    cli::cli_abort("Unfortunalty, the search endpoint has changed and returns empty results. See {.url https://github.com/JBGruber/traktok/issues/14}.")

  tt_data <- res |>
    httr2::resp_body_json()

  tt_videos <- spluck(tt_data, "data")

  author_name <- vpluck(tt_videos, "item", "author", "uniqueId")
  video_id <- vpluck(tt_videos, "item", "id")
  video_url <- glue::glue("https://www.tiktok.com/@{author_name}/video/{video_id}")
  video_timestamp <- vpluck(tt_videos, "item", "createTime", val = "integer") |>
    as.integer() |>
    as.POSIXct(tz = "UTC", origin = "1970-01-01")

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
  attr(out, "search_id") <- purrr::pluck(tt_data, "log_pb", "impr_id", .default = NA)
  attr(out, "has_more") <- as.logical(purrr::pluck(tt_data, "has_more", .default = FALSE))

  return(out)
}


#' @noRd
parse_user <- function(user_data) {

  user_info <- spluck(user_data, "__DEFAULT_SCOPE__", "webapp.user-detail", "userInfo")

  tibble::tibble(
    user_id           = spluck(user_info, "user", "id"),
    user_name         = spluck(user_info, "user", "uniqueId"),
    user_nickname     = spluck(user_info, "user", "nickname"),
    avatar_url        = spluck(user_info, "user", "avatarLarger"),
    signature         = spluck(user_info, "user", "signature"),
    verified          = spluck(user_info, "user", "verified"),
    secUid            = spluck(user_info, "user", "secUid"),
    bio_link          = spluck(user_info, "user", "bioLink", "link"),
    commerce_user     = spluck(user_info, "user", "commerceUserInfo"),
    region            = spluck(user_info, "user", "region"),
    nickname_modified = as.POSIXct(spluck(user_info, "user", "nickNameModifyTime"),
                                   origin = "1970-01-01"),
    language          = spluck(user_info, "user", "language"),
    follower_count     = spluck(user_info, "stats", "followerCount"),
    following_count    = spluck(user_info, "stats", "followingCount"),
    heart_count        = spluck(user_info, "stats", "heartCount"),
    video_count        = spluck(user_info, "stats", "videoCount"),
    friend_count       = spluck(user_info, "stats", "friendCount"),
  )

}

#' @noRd
parse_followers <- function(follower_data) {

  purrr::map(follower_data, function(f) {
    dplyr::bind_cols(f$user, f$stats)
  }) |>
    dplyr::bind_rows()

}
