# base function for extracting regex
#' @noRd
extract_regex <- function(str, pattern) {
  regmatches(
    str,
    regexpr(pattern, str, perl = TRUE)
  )
}


#' @noRd
wait <- function(sleep_pool, verbose = TRUE) {
  sleep <- stats::runif(1) * sample(sleep_pool, 1L)
  if (verbose) cli::cli_progress_message("\U23F2 waiting {round(sleep, 1)} seconds", current = FALSE)
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


