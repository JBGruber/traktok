test_that("authentication works", {
  mock_success <- function(req) {
    httr2::response(
      status_code = 200,
      headers = "Content-Type: application/json",
      body = charToRaw(
        "{
                            \"access_token\": \"clt.example12345Example12345Example\",
                            \"expires_in\": 7200,
                            \"token_type\": \"Bearer\"
                        }"
      )
    )
  }

  Sys.setenv("TIKTOK_TOKEN" = "test.rds")
  on.exit(
    file.remove(file.path(
      tools::R_user_dir("traktok", "cache"),
      "test.rds"
    )),
    add = TRUE,
    after = FALSE
  )

  expect_equal(
    httr2::with_mocked_responses(
      mock_success,
      req_token(client_key = "test", client_secret = "test")
    ),
    list(
      access_token = "clt.example12345Example12345Example",
      expires_in = 7200L,
      token_type = "Bearer"
    )
  )

  expect_equal(
    httr2::with_mocked_responses(
      mock_success,
      auth_research(client_key = "test", client_secret = "test")$token_type
    ),
    "Bearer"
  )

  expect_true(file.exists(file.path(
    tools::R_user_dir("traktok", "cache"),
    "test.rds"
  )))

  expect_true(auth_check(research = TRUE, hidden = FALSE, silent = TRUE))

  expect_equal(
    get_token()$access_token,
    httr2::obfuscated("clt.example12345Example12345Example")
  )
})


test_that("auth error", {
  mock_error <- function(req) {
    httr2::response(
      status_code = 500,
      headers = "Content-Type: application/json",
      body = charToRaw(
        "{
            \"error\": \"invalid_request\",
            \"error_description\": \"Client secret is missed in request.\",
            \"log_id\": \"202206221854370101130062072500FFA2\"
        }"
      )
    )
  }
  expect_error(
    {
      httr2::with_mocked_responses(
        mock_error,
        req_token(client_key = "test", client_secret = "test")
      )
    },
    "Request failed with"
  )
})
