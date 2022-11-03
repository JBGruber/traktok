#' @noRd
tt_read_cookies <- function(cookiefile) {

  # try to check if the value is already a valid cookie string
  if (grepl("(.+?=.+;){2,}", cookiefile, perl = TRUE)) {
    cookie <- cookiefile
  } else {
    if (!file.exists(cookiefile)) {
      stop("cookiefile ", cookiefile, " does not exist")
    }

    lines <- readLines(cookiefile, warn = FALSE)

    df <- utils::read.delim(text = lines[grep("\t", lines)], header = FALSE)

    cookies <- df[, 7]
    names(cookies) <- df[, 6]

    cookies_str <- vapply(cookies, curl::curl_escape, FUN.VALUE = character(1))
    cookie <- paste(names(cookies), cookies_str, sep = "=", collapse = ";")
  }

  return(cookie)
}

#' @noRd
extract_regex <- function(str, pattern) {
  regmatches(
    str,
    regexpr(pattern, str, perl = TRUE)
  )
}

#' @noRd
wait <- function(sleep_pool) {
  sleep <- stats::runif(1) * sample(sleep_pool, 1L)
  message("\t...waiting ", round(sleep, 1), " seconds")
  Sys.sleep(sleep)
}

#' @noRd
vpluck <- function(x, ..., val = "character") {
  dots <- list(...)
  if (val == "character") {
    def <- NA_character_
    val <- character(1)
  } else if (val == "integer") {
    def <- NA_integer_
    val <- integer(1)
  } else if (val == "logical") {
    def <- NA
    val <- logical(1)
  }
  vapply(x, purrr::pluck, !!!dots, .default = def, FUN.VALUE = val)
}
