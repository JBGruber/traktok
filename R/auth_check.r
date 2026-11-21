#' Check whether you are authenticated
#'
#' @description \ifelse{html}{\figure{api-both.svg}{options: alt='[Works on:
#'   Both]'}}{\strong{[Works on: Both]}}
#'
#'   Check if the necessary token or cookies are stored on your computer
#'   already. By default, the function checks for the authentication of the
#'   research and hidden API. To learn how you can authenticate, see the
#'   [research API
#'   vignette](https://jbgruber.github.io/traktok/articles/research-api.html#authentication)
#'   or [hidden API
#'   vignette](https://jbgruber.github.io/traktok/articles/unofficial-api.html#authentication).
#'   You can also view these locally with `vignette("research-api", package =
#'   "traktok")` and `vignette("unofficial-api", package = "traktok")`.
#'
#' @param research,hidden turn check on/off for the research or hidden API.
#' @param silent only return if check(s) were successful, no status on the
#'   screen
#' @param fail fail if even basic authentication for the hidden API is missing.
#'
#' @return logical vector (invisible)
#' @export
#'
#' @examples
#' auth_check()
#'
#' au <- auth_check()
#' if (isTRUE(au["research"])) {
#'   message("Ready to use the research API!")
#' }
#' if (isTRUE(au["hidden"])) {
#'   message("Ready to use all function of unofficial the API!")
#' }
auth_check <- function(
  research = TRUE,
  hidden = TRUE,
  silent = FALSE,
  fail = FALSE
) {
  auth <- vector()
  if (research) {
    if (!isFALSE(get_token(auth = FALSE))) {
      auth <- c(research = TRUE)
      if (!silent) cli::cli_alert_success("Research API authenticated")
    }
  }
  if (hidden) {
    cookies <- try(
      cookiemonster::get_cookies("^(www.)*tiktok.com"),
      silent = TRUE
    )
    if (methods::is(cookies, "try-error")) {
      if (grepl("any.cookies.yet", cookies)) {
        msg <- paste(
          "It looks like you are using traktok for the first time. You",
          "need to add some basic authentication for this function to work.",
          "See {.help auth_check}."
        )
        if (fail) {
          cli::cli_abort(msg)
        } else {
          cli::cli_warn(msg)
        }
      }
    }
    auth_cookie_names <- c("tt_chain_token", "sessionid", "sid_guard")
    if (
      is.data.frame(cookies) &&
        all(auth_cookie_names %in% purrr::pluck(cookies, "name", .default = ""))
    ) {
      auth <- c(auth, hidden = TRUE)

      if (
        any(
          dplyr::filter(cookies, name %in% auth_cookie_names) |>
            dplyr::pull(expiration) <
            Sys.time()
        )
      ) {
        cli::cli_warn(c(
          "Some of your TikTok cookies have expired.",
          "i" = paste(
            "Functions that open a browser, like {.fn tt_search_hidden}, discard",
            "expired cookies and run without your account. Other requests may fail",
            "too."
          ),
          "i" = "Get fresh cookies with {.fn auth_hidden}."
        ))
      } else if (!silent) {
        cli::cli_alert_success("Hidden API authenticated")
      }
    }
  }
  invisible(auth)
}
