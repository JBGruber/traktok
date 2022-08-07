#' @noRd
tt_read_cookies <- function(cookiefile) {

  lines <- readLines(cookiefile, warn = FALSE)

  df <- utils::read.delim(text = lines[grep("\t", lines)], header = FALSE)

  cookies <- df[, 7]
  names(cookies)  <- df[, 6]

  return(cookies)
}

#' @noRd
extract_regex <- function(str, pattern) {
  regmatches(
    str,
    regexpr(pattern, str, perl = TRUE)
  )
}
