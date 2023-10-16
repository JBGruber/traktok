#' Get cookies for the hidden API
#'
#' @description Wraps different ways to get valid cookies for traktok. See
#'   details.
#'
#' @param x either file location, a cookie string, or can be left blank (see
#'   Details).
#' @param save should a cookie file be saved in the default location. If x is
#'   already the default cookie file, is ignored.
#' @param name name of the cookie file used for loading or saving a specific
#'   cookie file.
#'
#' @details to make requests to TikTok, traktok needs user cookies. By running
#'   \code{auth_hidden()} without arguments, you can obtain anonymous
#'   cookies. Most functions will not work with these, however. To get cookies
#'   for a logged in user, you can use a browser extension to export the
#'   necessary cookies from your browser (after visiting TikTok.com at least
#'   once). I can recommend "Get cookies.txt" for Chromium based browsers or
#'   "cookies.txt" for Firefox. See \code{vignette("authentication", package =
#'   "traktok")} for details. By default, cookies are stored in the location
#'   returned by \code{tools::R_user_dir("traktok", "config")}.
#'
#' @return a named list of cookies
#' @export
#'
#' @examples
#' \dontrun{
#' auth_hidden("www.tiktok.com_cookies.txt")
#' }
auth_hidden <- function(x = NULL, save = TRUE, name = "tiktok.com_cookies") {

  UseMethod("auth_hidden")

}

auth_hidden.character <- function(x = NULL, save = TRUE, name = "tiktok.com_cookies") {

  # set option if not present
  if (is.null(getOption("tt_cookiefile"))) {
    options(tt_cookiefile = file.path(tools::R_user_dir("traktok", "config"),
                                      paste0(name, ".rds")))
  }

  # most likely case: no x
  if (missing(x) | is.null(x)) {

    # look at option first
    x <- getOption("tt_cookiefile")

    if (grepl("(.+?=.+;)", x, perl = TRUE)) { # option can contain cookie string

      cookies <- parse_cookie_str(x)
      options(tt_cookiefile = file.path(tools::R_user_dir("traktok", "config"),
                                        paste0(name, ".rds")))

    } else if (file.exists(x)) {

      cookies <- read_cookiefile(x)

    } else {
      # if file in option does not exist, look for a file with a different name
      x <- list.files(tools::R_user_dir("traktok", "config"), full.names = TRUE)

      if (length(x) > 0L) { # if default location is not empty

        cookies <- read_cookiefile(x[1])

      } else { # if default location is empty, query user

        cookies <- no_cookies()

      }

    }

  } else { # x contains something

    if (is.list(x)) {

      # provided as list (likely already cookie)
      cookies <- test_cookies(x)

    } else if (is.character(x)) {

      # provided as character (likely file)
      if (file.exists(x)) {

        cookies <- read_cookiefile(x)
        # don't overwrite if user entered the default file already
        if (x == getOption("tt_cookiefile")) save <- FALSE

      } else if (grepl("(.+?=.+;)", x, perl = TRUE)) {

        # or a cookie string
        cookies <- parse_cookie_str(x)

      } else {
        no_cookies()
      }
    }
  }

  if (save) {
    dir.create(path = dirname(getOption("tt_cookiefile")),
               showWarnings = FALSE,
               recursive = TRUE)
    saveRDS(cookies, getOption("tt_cookiefile"))
  }

  class(cookies) <- c("tt_cookies", class(cookies))
  return(cookies)

}

auth_hidden.tt_cookies <- function(x = NULL, save = TRUE, name = "tiktok.com_cookies") {

  # set option if not present
  if (is.null(getOption("tt_cookiefile"))) {
    options(tt_cookiefile = file.path(tools::R_user_dir("traktok", "config"),
                                      paste0(name, ".rds")))
  }

  cookies <-  x

  if (save && !file.exists(getOption("tt_cookiefile"))) {
    dir.create(path = dirname(getOption("tt_cookiefile")),
               showWarnings = FALSE,
               recursive = TRUE)
    saveRDS(cookies, getOption("tt_cookiefile"))
  }

  class(cookies) <- c("tt_cookies", class(cookies))
  return(cookies)

}


#' @noRd
parse_cookie_str <- function(x) {
  x <- strsplit(x, "; ")[[1]]
  cookies <- list(gsub("^\\w+=", "", x))
  names(cookies) <- extract_regex(x, "^\\w+(?==)")
  test_cookies(cookies)
  return(cookies)
}


#' test if cookies are valid
#' @noRd
test_cookies <- function(cookies) {
  if (is.null(cookies[["tt_csrf_token"]]))
    stop(cookies, " does not contain valid TikTok cookies")
}

#' read a cookie file
#' @noRd
read_cookiefile <- function(cookiefile) {
  if (tolower(tools::file_ext(cookiefile)) == "rds") {
    cookies <- readRDS(cookiefile)
  } else {
    lines <- readLines(cookiefile, warn = FALSE)
    df <- utils::read.delim(text = lines[grep("\t", lines)], header = FALSE)
    cookies <- as.list(df[, 7])
    names(cookies) <- df[, 6]
  }
  test_cookies(cookies)
  return(cookies)
}


#' convert cookie list into string
#' @noRd
prep_cookies <- function(cookies, ...) {
  if (length(list(...)) > 0L) cookies <- cookies[c(...)]
  paste(names(cookies), cookies, sep = "=", collapse = "; ")
}

#' @noRd
no_cookies <- function() {
  if (interactive()) {
    selection <- utils::menu(
      choices = c("request anonymous token",
                  "show help for auth_hidden to authenticate",
                  "abort"),
      title = paste0("No cookies provided or found in default location. ",
                     "If you are using traktok for the first time, you can")
    )
  } else {
    selection <- 3
  }

  switch (
    selection,
    "1" = cookies <- get_anonymous_cookies(),
    "2" = utils::help(auth_hidden, "traktok"),
    "3" = stop("No cookies provided or found in default location. If you are using",
               " traktok for the first time, see ?auth_hidden."),
  )
  return(cookies)
}

#' @noRd
get_anonymous_cookies <- function() {
  h <- curl::new_handle()
  req <- curl::curl_fetch_memory("https://www.tiktok.com/", handle = h)
  df <- curl::handle_cookies(h)
  cookies <- as.list(df[, "value"])
  names(cookies) <- df[, "name"]
  return(cookies)
}
