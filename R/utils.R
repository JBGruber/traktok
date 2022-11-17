#' @noRd
tt_get_cookies <- function(cookiefile = getOption("cookiefile")) {

  if (is.null(cookiefile)) {
    cookiefile <-  file.path(tools::R_user_dir("traktok", "config"), "tiktok.com_cookies.txt")
    options(cookiefile = cookiefile)
  }

  # try to check if the value is already a valid cookie string (meant for testing)
  if (grepl("(.+?=.+;){2,}", cookiefile, perl = TRUE)) {

    cookie <- cookiefile

  } else {

    if (file.exists(cookiefile)) {

      lines <- readLines(cookiefile, warn = FALSE)
      df <- utils::read.delim(text = lines[grep("\t", lines)], header = FALSE)

    } else {

      # request new cookies
      h <- curl::new_handle()
      req <- curl::curl_fetch_memory( "https://www.tiktok.com/", handle = h)
      df <- curl::handle_cookies(h)
      dir.create(dirname(cookiefile), recursive = TRUE, showWarnings = FALSE)
      utils::write.table(df, cookiefile, sep = "\t", row.names = FALSE, quote = FALSE)

    }

    cookies <- df[, 7]
    names(cookies) <- df[, 6]

    cookies_str <- vapply(cookies, curl::curl_escape, FUN.VALUE = character(1))
    cookie <- paste(names(cookies), cookies_str, sep = "=", collapse = "; ")

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
