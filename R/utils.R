#' @noRd
tt_read_cookies <- function(cookiefile) {

  # try to check if the value is already a valid cookie string
  if (grepl("(.+?=.+;){2,}", cookiefile, perl = TRUE)) {
    cookie <- cookiefile
  } else {
    lines <- readLines(cookiefile, warn = FALSE)

    df <- utils::read.delim(text = lines[grep("\t", lines)], header = FALSE)

    cookies <- df[, 7]
    names(cookies)  <- df[, 6]

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

wait <- function(sleep_pool) {
  sleep <- stats::runif(1) * sample(sleep_pool, 1L)
  message("\t...waiting ", round(sleep, 1), " seconds")
  Sys.sleep(sleep)
}
