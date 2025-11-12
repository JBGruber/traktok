#' Authenticate for the official research API
#'
#' @description
#' Guides you through authentication for the Research API
#'
#'
#' @param client_key Client key for authentication
#' @param client_secret Client secret for authentication
#'
#' @returns An authentication token (invisible).
#'
#' @details You need to apply for access to the API and get the key
#' and secret from TikTok. See
#' \url{https://developers.tiktok.com/products/research-api/} for more
#' information.
#'
#'
#' @export
#'
#' @examples
#' \dontrun{
#' auth_research(client_key, client_secret)
#' }
auth_research <- function(client_key, client_secret) {

  if (missing(client_key)) {
    cli::cli_alert_info(c("Head to {.url https://developers.tiktok.com/research}",
                          " to get your credentials"))
    client_key <- askpass::askpass("Please enter your client key")
  }

  if (missing(client_secret))
    client_secret <- askpass::askpass("Please enter your client secret")

  token <- req_token(client_key, client_secret)

  token$access_token <- httr2::obfuscated(token$access_token)
  token$access_token_expires <- Sys.time() + token$expires_in

  # attach for refresh
  token$client_key <- enc(client_key)
  token$client_secret <- enc(client_secret)

  f <- Sys.getenv("TIKTOK_TOKEN", unset = "token.rds")
  p <- tools::R_user_dir("traktok", "cache")
  dir.create(p, showWarnings = FALSE, recursive = TRUE)
  # store in cache
  rlang::env_poke(env = the, nm = "tiktok_token", value = token, create = TRUE)

  httr2::secret_write_rds(x = token, path = file.path(p, f),
                          key = I(rlang::hash("traktok")))

  cli::cli_alert_success("Succesfully authenticated!")
  invisible(token)
}


req_token <- function(client_key, client_secret) {

  if (methods::is(client_key, "raw")) client_key <- dec(client_key)
  if (methods::is(client_secret, "raw")) client_secret <- dec(client_secret)

  # https://developers.tiktok.com/doc/client-access-token-management
  resp <- httr2::request("https://open.tiktokapis.com/v2/oauth/token/") |>
    httr2::req_method("POST") |>
    httr2::req_headers(
      "Content-Type" = "application/x-www-form-urlencoded",
      "Cache-Control" = "no-cache") |>
    httr2::req_body_form(
      "client_key" = client_key,
      "client_secret" = client_secret,
      "grant_type" = "client_credentials"
    ) |>
    httr2::req_error(is_error = function(x) FALSE) |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  if (!is.null(resp$error))
    cli::cli_abort("Request failed with {.emph {resp$error}}: {.emph {resp$error_description}}")

  invisible(resp)
}


get_token <- function(auth = TRUE) {

  f <- file.path(tools::R_user_dir("traktok", "cache"),
                 Sys.getenv("TIKTOK_TOKEN", unset = "token.rds"))

  if (rlang::env_has(the, nms = "tiktok_token")) {
    token <- rlang::env_get(the, nm = "tiktok_token", I(rlang::hash("traktok")))
  } else if (file.exists(f)) {
    token <- httr2::secret_read_rds(f, I(rlang::hash("traktok")))
  } else if (auth) {
    token <- auth_research()
  } else return(FALSE)

  # refresh token if expired
  if (token$access_token_expires <= Sys.time() + 5) {
    token <- auth_research(client_key = dec(token$client_key),
                           client_secret = dec(token$client_secret))
  }

  return(token)
}


#' encrypt a single element
#' @noRd
enc <- function(x, key = NULL) {
  if (is.null(key)) key <- openssl::sha256(charToRaw(Sys.getenv("COOKIE_KEY", unset = "supergeheim")))
  openssl::aes_ctr_encrypt(charToRaw(x), key)
}

#' decrypt a single element
#' @noRd
dec <- function(x, key = NULL) {
  if (is.null(key)) key <- openssl::sha256(charToRaw(Sys.getenv("COOKIE_KEY", unset = "supergeheim")))
  rawToChar(openssl::aes_ctr_decrypt(x, key))
}

