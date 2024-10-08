#' Check whether you are authenticated
#'
#' @description \ifelse{html}{\figure{api-both.svg}{options:
#'   alt='[Both]'}}{\strong{[Both]}}
#'
#'   Check if the necessary token or cookies are stored on your computer
#'   already. By default, the function checks for the authentication of the
#'   research and hidden API. To learn how you can authenticate, look at the
#'   vignette for the research (\code{vignette("research-api", package =
#'   "traktok")}) or hidden (\code{vignette("unofficial-api", package =
#'   "traktok")}) API.
#'
#' @param research,hidden turn check on/off for the research or hidden API.
#' @param silent only return if check(s) were successful, no status on the
#'   screen
#'
#' @return logical vector (invisible)
#' @export
#'
#' @examples
#' auth_check()
auth_check <- function(research = TRUE, hidden = TRUE, silent = FALSE) {
  auth <- vector()
  if (research) {
    if (!isFALSE(get_token(auth = FALSE))) {
      auth <- c(research = TRUE)
      if (!silent) cli::cli_alert_success("Research API authenticated")
    }
  }
  if (hidden) {
    cookies <- try(cookiemonster::get_cookies("^(www.)*tiktok.com"))
    if (is.data.frame(cookies) && "tt_chain_token" %in% cookies$name) {
      auth <- c(auth, hidden = TRUE)
      if (!silent) cli::cli_alert_success("Hidden API authenticated")
    }
  }
  invisible(auth)
}
