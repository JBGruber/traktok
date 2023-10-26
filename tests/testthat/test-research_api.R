test_that("query", {
  expect_equal({
    query() |>
      query_and(field_name = "region_code",
                operation = "IN",
                field_values = c("JP", "US")) |>
      query_and(field_name = "hashtag_name",
                operation = "EQ",
                field_values = "animal") |>
      query_not(operation = "EQ",
                field_name = "video_length",
                field_values = "SHORT") |>
      unclass()
  }, jsonlite::read_json("example_query.json"))
})

test_that("request", {
  mock_success <- function(req) {
    req <<- req # use this to test request below
    httr2::response(status_code = 200,
                    headers = "Content-Type: application/json",
                    body = charToRaw(
                      paste0(
                        readLines("example_resp_q_videos.json"), collapse = "")
                      )
                    )
  }
  # mock a query to check against example
  q <- query() |>
    query_and(field_name = "region_code",
              operation = "IN",
              field_values = c("JP", "US")) |>
    query_and(field_name = "hashtag_name",
              operation = "EQ",
              field_values = "animal") |>
    query_not(field_name = "video_length",
              operation = "EQ",
              field_values = "SHORT")

  httr2::with_mock(
    mock_success,
    tt_query_videos(q,
                    start_date = "20230101",
                    end_date = "20230115",
                    is_random = NULL,
                    token = list(access_token = "test"))
  )

  ex <- jsonlite::read_json("example_request.json")

  expect_equal({
    sort(names(req$body$data))
  }, sort(names(ex)))

  expect_equal({
    req$body$data$query
  }, ex$query)

  expect_equal({
    req$body$data$start_date
  }, ex$start_date)

  expect_equal({
    req$body$data$end_date
  }, ex$end_date)

  expect_equal({
    df <- httr2::with_mock(
      mock_success,
      tt_query_videos(q,
                      start_date = "20230101",
                      end_date = "20230115",
                      is_random = NULL,
                      max_pages = 20,
                      verbose = FALSE,
                      token = list(access_token = "test"))
    )
    nrow(df)
  }, 40)

})

test_that("parsing", {
  expect_equal({
    out <- jsonlite::read_json("example_resp_q_videos.json", bigint_as_char = TRUE) |>
      purrr::pluck("data", "videos") |>
      parse_api_search()
    c(out$video_id, nrow(out), ncol(out))
  }, c("702874395068494965", "702874395068494965", "2", "11"))
  # apparently, sometimes the video_id is just called id
  expect_equal({
    out <- list(list(id = "1"), list(video_id = "2")) |>
      parse_api_search()
    out$video_id
  }, c("1", "2"))
  expect_equal({
    out <- jsonlite::read_json("example_resp_q_user.json", bigint_as_char = TRUE) |>
      purrr::pluck("data") |>
      tibble::as_tibble()
    c(nrow(out), ncol(out))
  }, c(1, 8))
  expect_equal({
    out <- jsonlite::read_json("example_resp_comments.json", bigint_as_char = TRUE) |>
      purrr::pluck("data", "comments") |>
      parse_api_comments()
    c(out$video_id, nrow(out), ncol(out))
  }, c("1234563451201523412", "1", "7"))
})
