#' @noRd
parse_api_search <- function(x) {

  out <- tibble::tibble(
    video_id          = as.character(vpluck(x, "video_id", val = "double")),
    author_name       = vpluck(x, "username", val = "character"),
    view_count        = vpluck(x, "view_count", val = "integer"),
    comment_count     = vpluck(x, "comment_count", val = "integer"),
    region_code       = vpluck(x, "region_code", val = "character"),
    create_time       = as.POSIXct(vpluck(x, "create_time", val = "integer"),
                                   tz = "UTC", origin = "1970-01-01"),
    effect_ids        = vpluck(x, "effect_ids", val = "list"),
    music_id          = as.character(vpluck(x, "music_id", val = "double")),
    video_description = vpluck(x, "video_description", val = "character"),
    hashtag_names     = vpluck(x, "hashtag_names", val = "list"),
    voice_to_text     = vpluck(x, "voice_to_text", val = "character"),
  )

  out$video_id <- ifelse(is.na(out$video_id),
                         as.character(vpluck(x, "id", val = "double")),
                         out$video_id)

  class(out) <- c("tt_results", class(out))

  return(out)
}


#' @title Print search result
#' @description Print a traktok search results
#' @param x An object of class \code{tt_results}
#' @param ... not used.
#' @export
print.tt_results <- function(x, ...) {
  cli::cat_rule(paste("search id:",  cli::col_red(attr(x, "search_id"))))
  print(tibble::as_tibble(x))
}i
