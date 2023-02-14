sign_url <- function(req) {
  sign <- httr2::request("http://localhost/signature") |>
    httr2::req_method("POST") |>
    httr2::req_headers("Content-type" = "application/json") |>
    httr2::req_body_raw(req$url, "application/json") |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  req$url <- sign$data$signed_url
  return(req)
}
