#' Authenticate for the hidden/unofficial API
#'
#' @description
#' Guides you through authentication for the hidden/unofficial API#'
#'
#' @param cookiefile optional path to your cookiefile. See
#'   \code{vignette("unofficial-api", package = "traktok")} for more information
#'   on authentication.
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
auth_hidden <- function(cookiefile) {

  if (!missing(cookiefile)) cookiemonster::add_cookies(cookiefile)
  cookies <- cookiemonster::get_cookies("^(www.)*tiktok.com", as = "string")

  cli::cli_alert_info(cli::style_italic("coming soon..."))

}


