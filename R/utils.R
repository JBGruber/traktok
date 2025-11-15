the <- new.env()

# base function for extracting regex
#' @noRd
extract_regex <- function(str, pattern) {
  regmatches(
    str,
    regexpr(pattern, str, perl = TRUE)
  )
}


# check if selected directory exists
#' @noRd
check_dir <- function(dir, name) {
  if (!is.null(dir)) {
    if (!dir.exists(dir)) {
      msg <- paste0("The selected `", name, "` directory does not exist.")
      if (utils::askYesNo(paste(msg, "Do you want to create it?"))) {
        dir.create(dir, showWarnings = FALSE)
      } else {
        stop(msg)
      }
    }
  }
}


#' @noRd
wait <- function(sleep_pool, verbose = TRUE) {
  sleep <- stats::runif(1) * sample(sleep_pool, 1L)
  if (verbose) {
    cli::cli_progress_message(
      "\U23F2 waiting {round(sleep, 1)} seconds",
      current = FALSE
    )
  }
  Sys.sleep(sleep)
}


# vectorised safe pluck
#' @noRd
vpluck <- function(x, ..., val = "character") {
  dots <- list(...)
  switch(
    val,
    "character" = {
      def <- NA_character_
      val <- character(1)
    },
    "integer" = {
      def <- NA_integer_
      val <- integer(1)
    },
    "double" = {
      def <- NA_integer_
      val <- numeric(1)
    },
    "logical" = {
      def <- NA
      val <- logical(1)
    },
    "list" = {
      val <- list()
    }
  )
  if (!is.list(val)) {
    vapply(x, purrr::pluck, !!!dots, .default = def, FUN.VALUE = val)
  } else {
    purrr::map(x, purrr::pluck, !!!dots)
  }
}


# safe pluck
#' @noRd
spluck <- function(.x, ...) {
  purrr::pluck(.x, ..., .default = NA)
}


# makes sure list can be turned into tibble
#' @noRd
as_tibble_onerow <- function(l, ...) {
  l <- purrr::map(l, function(c) {
    if (length(c) != 1) {
      return(list(c))
    }
    return(c)
  })
  tibble::as_tibble(l, ...)
}


# checks if object has a data or time class already
#' @noRd
is_datetime <- function(x) {
  methods::is(x, "POSIXct") +
    methods::is(x, "POSIXlt") +
    methods::is(x, "Date") >
    0
}


# converts TikTok timestamp to datetime
#' @noRd
as_datetime <- function(x) {
  # TikTok returns 0 for missing
  if (all(x > 0)) {
    as.POSIXct(x, origin = "1970-01-01")
  } else {
    NA
  }
}


# turns video ids into video URLs
#' @noRd
id2url <- function(x) {
  if (!is.character(x)) {
    cli::cli_abort("You need to supply a character vector of video URLs or IDs")
  }
  x[!grepl("\\D", x)] <- paste0(
    "https://www.tiktok.com/@/video/",
    x[!grepl("\\D", x)]
  )
  return(x)
}


# base R function to get clean column names
#' @noRd
clean_names <- function(x) {
  gsub(pattern = "([A-Z])", replacement = "_\\L\\1", x = x, perl = TRUE)
}


# extract video and photo URLs from a session (might be slow but probably pretty
# robust)
#' @noRd
extract_urls_sess <- function(sess) {
  # TODO: also extract slideshows
  rvest::html_elements(sess, "[id*='column-item-video-container'] a") |>
    rvest::html_attr("href") |>
    grep(pattern = "/video/", x = _, value = TRUE, fixed = TRUE)
}


# converts a scroll time to a timestamp now + scroll time
#' @noRd
scroll2timestamp <- function(scroll) {
  if (is.numeric(scroll)) {
    return(Sys.time() + scroll)
  }
  value <- as.numeric(extract_regex(scroll, "^[0-9.]+"))
  unit <- extract_regex(scroll, "[A-z]+$")
  seconds <- switch(
    tolower(unit),
    "s" = value,
    "sec" = value,
    "secs" = value,
    "second" = value,
    "seconds" = value,
    "m" = value * 60,
    "min" = value * 60,
    "mins" = value * 60,
    "minute" = value * 60,
    "minutes" = value * 60,
    "h" = value * 3600,
    "hr" = value * 3600,
    "hrs" = value * 3600,
    "hour" = value * 3600,
    "hours" = value * 3600,
    "d" = value * 86400,
    "day" = value * 86400,
    "days" = value * 86400,
    cli::cli_abort(
      "Invalid unit. Use 's' (seconds), 'm' (minutes), 'h' (hours), or 'd' (days)"
    )
  )
  Sys.time() + seconds
}
