#' Read in cookie file
#'
#' This functions reads in and parses a cookies.txt file. You can get these
#' files, for example, with the Browser extension "Get cookies.txt" (available
#' for Chromium based Browsers an Firefox).
#'
#' @param cookiefile path to a cookies.txt file.
#'
#' @return a vector of named cookie values.
#' @importFrom utils read.delim
#' @export
#'
#' @examples
#'
#' cookies <- pb_read_cookies(system.file("extdata", "example_cookies.txt", package = "paperboy"))
#' df <- pb_collect("https://httpbin.org/cookies", cookies = cookies)
#' df$content_raw
#'
tik_read_cookies <- function(cookiefile) {

  lines <- readLines(cookiefile, warn = FALSE)

  df <- read.delim(text = lines[grep("\t", lines)], header = FALSE)

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
