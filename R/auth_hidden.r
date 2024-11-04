#' Authenticate for the hidden/unofficial API
#'
#' @description Guides you through authentication for the hidden/unofficial API
#'
#' @param cookiefile path to your cookiefile. Usually not needed after running
#'   \link{auth_hidden} once. See \code{vignette("unofficial-api", package =
#'   "traktok")} for more information on authentication.
#' @param live opens Chromium browser to guide you through the auth process
#'   (experimental).
#'
#' @return nothing. Called to set up authentication
#' @export
#'
#' @examples
#' \dontrun{
#' # to run through the steps of authentication
#' auth_hidden()
#' # or point to a cookie file directly
#' auth_hidden("www.tiktok.com_cookies.txt")
#' }
auth_hidden <- function(cookiefile, live = interactive()) {

  if (!missing(cookiefile)) {
    cookiemonster::add_cookies(cookiefile)
    return(invisible(TRUE))
  }
  msg <- paste0(
    "Supply either a cookiefile (see {.url https://jbgruber.github.io/traktok/",
    "articles/unofficial-api.html#authentication})"
  )
  if (live && isTRUE(utils::askYesNo("Do you want to try live authentication using Chrome? (experimental)"))) {

    rlang::check_installed("rvest", reason = "to use this function", version = "1.0.4")

    sess <- rvest::read_html_live("https://www.tiktok.com/")
    # TODO: find way to click cookie banner
    # sess$click(".tiktok-cookie-banner>button")
    # sess$session$send_command('const button = document.querySelector("body > tiktok-cookie-banner").shadowRoot.querySelector("div > div.button-wrapper > button:nth-child(2)");')
    if (check_element_exists(sess, "#header-login-button")) {
      sess$click("#header-login-button")
      sess$view()
    }
    cli::cli_progress_bar(format = "{cli::pb_spin} Waiting for login",
                          format_done = "Got cookies!")
    Sys.sleep(5) # give time to load login
    while (check_element_exists(sess, "#loginContainer")) {
      Sys.sleep(1 / 30)
      cli::cli_progress_update()
    }

    cli::cli_progress_done()
    cli::cli_alert_success("Got cookies!")
    cookiemonster::add_cookies(session = sess)
    return(invisible(TRUE))
  } else {
    msg <- paste0(msg, " or set {.code live = TRUE} to use interactive authentication")
  }
  cli::cli_abort(msg)
}


check_element_exists <- function(sess, css) {
  res <- try(rvest::html_element(sess, css), silent = TRUE)
  if (methods::is(res, "try-error")) return(TRUE)
  return(length(rvest::html_element(sess, css)) > 0L)
}

