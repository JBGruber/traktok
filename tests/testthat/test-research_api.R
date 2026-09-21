test_that("query", {
  expect_equal(
    {
      query() |>
        query_and(
          field_name = "region_code",
          operation = "IN",
          field_values = c("JP", "US")
        ) |>
        query_and(
          field_name = "hashtag_name",
          operation = "EQ",
          field_values = "animal"
        ) |>
        query_not(
          operation = "EQ",
          field_name = "video_length",
          field_values = "SHORT"
        ) |>
        unclass()
    },
    jsonlite::read_json("example_query.json")
  )
})

test_that("request", {
  mock_success <- function(req) {
    # don't remove, this needs to be here!
    req <<- req # use this to test request below
    httr2::response(
      status_code = 200,
      headers = "Content-Type: application/json",
      body = charToRaw(
        paste0(
          readLines("example_resp_q_videos.json"),
          collapse = ""
        )
      )
    )
  }
  # mock a query to check against example
  q <- query() |>
    query_and(
      field_name = "region_code",
      operation = "IN",
      field_values = c("JP", "US")
    ) |>
    query_and(
      field_name = "hashtag_name",
      operation = "EQ",
      field_values = "animal"
    ) |>
    query_not(
      field_name = "video_length",
      operation = "EQ",
      field_values = "SHORT"
    )

  httr2::with_mocked_responses(
    mock_success,
    tt_search_api(
      q,
      start_date = "20230101",
      end_date = "20230115",
      is_random = NULL,
      token = list(access_token = "test")
    )
  )

  ex <- jsonlite::read_json("example_request.json")

  expect_equal(
    {
      sort(names(req$body$data))
    },
    sort(names(ex))
  )

  expect_equal(
    {
      req$body$data$query
    },
    ex$query
  )

  expect_equal(
    {
      req$body$data$start_date
    },
    ex$start_date
  )

  expect_equal(
    {
      req$body$data$end_date
    },
    ex$end_date
  )

  expect_equal(
    {
      df <- httr2::with_mocked_responses(
        mock_success,
        tt_search_api(
          q,
          start_date = "20230101",
          end_date = "20230115",
          is_random = NULL,
          max_pages = 20,
          verbose = FALSE,
          token = list(access_token = "test")
        )
      )
      nrow(df)
    },
    40
  )
})


test_that("parsing", {
  expect_equal(
    {
      out <- jsonlite::read_json(
        "example_resp_q_videos.json",
        bigint_as_char = TRUE
      ) |>
        purrr::pluck("data", "videos") |>
        parse_api_search()
      c(out$video_id, nrow(out), ncol(out))
    },
    c("702874395068494965", "702874395068494965", "2", "13")
  )
  # apparently, sometimes the video_id is just called id
  expect_equal(
    {
      out <- list(list(id = "1"), list(video_id = "2")) |>
        parse_api_search()
      out$video_id
    },
    c("1", "2")
  )
  expect_equal(
    {
      out <- jsonlite::read_json(
        "example_resp_q_user.json",
        bigint_as_char = TRUE
      ) |>
        purrr::pluck("data") |>
        tibble::as_tibble()
      c(nrow(out), ncol(out))
    },
    c(1, 8)
  )
  expect_equal(
    {
      out <- jsonlite::read_json(
        "example_resp_comments.json",
        bigint_as_char = TRUE
      ) |>
        purrr::pluck("data", "comments") |>
        parse_api_comments()
      c(out$video_id, nrow(out), ncol(out))
    },
    c("1234563451201523412", "1", "7")
  )
})


test_that("date windows", {
  # up to 30 days apart -> a single window
  w <- date_windows("20230101", "20230131")
  expect_equal(w$from, as.Date("2023-01-01"))
  expect_equal(w$to, as.Date("2023-01-31"))

  # longer spans are split into consecutive, non-overlapping windows that
  # are at most 30 days apart and end on end_date
  w <- date_windows(as.Date("2023-01-01"), as.Date("2023-03-15"))
  expect_equal(
    w$from,
    as.Date(c("2023-01-01", "2023-02-01", "2023-03-04"))
  )
  expect_equal(
    w$to,
    as.Date(c("2023-01-31", "2023-03-03", "2023-03-15"))
  )
  expect_true(all(w$to - w$from <= 30))
  expect_equal(w$from[-1], w$to[-length(w$to)] + 1)

  # same day
  w <- date_windows("2023-01-01", "2023-01-01")
  expect_equal(w$from, w$to)

  # POSIXct input is interpreted in UTC
  expect_equal(
    as_api_date(as.POSIXct("2023-05-05 23:30:00", tz = "America/New_York")),
    as.Date("2023-05-06")
  )

  expect_error(date_windows("20230315", "20230101"), "must not be after")
  expect_error(date_windows("2023", "20230101"), "valid date")
  expect_error(date_windows("20230101", 2023), "valid date")
})


test_that("sliding windows", {
  requests <- list()
  mock_success <- function(req) {
    requests[[length(requests) + 1]] <<- req$body$data
    httr2::response(
      status_code = 200,
      headers = "Content-Type: application/json",
      body = charToRaw(
        paste0(
          readLines("example_resp_q_videos.json"),
          collapse = ""
        )
      )
    )
  }

  df <- httr2::with_mocked_responses(
    mock_success,
    tt_search_api(
      "rstats",
      start_date = "20230101",
      end_date = "20230315",
      start_cursor = 200L,
      search_id = "old_search",
      max_pages = 2,
      verbose = FALSE,
      token = list(access_token = "test")
    )
  )

  # 3 windows x 2 pages x 2 videos in the mock response
  expect_equal(length(requests), 6L)
  expect_equal(nrow(df), 12L)
  expect_s3_class(df, "tt_results")

  expect_equal(
    purrr::map_chr(requests, "start_date"),
    rep(c("20230101", "20230201", "20230304"), each = 2)
  )
  expect_equal(
    purrr::map_chr(requests, "end_date"),
    rep(c("20230131", "20230303", "20230315"), each = 2)
  )

  # search_id and start_cursor are only used for the first request of the
  # first window; the second page of each window uses the cursor and
  # search_id from the (mocked) response
  expect_equal(requests[[1]]$search_id, "old_search")
  expect_equal(requests[[1]]$cursor, 200L)
  expect_equal(requests[[2]]$search_id, "7201388525814961198")
  expect_equal(requests[[2]]$cursor, 100L)
  expect_null(requests[[3]]$search_id)
  expect_equal(requests[[3]]$cursor, 0L)
  expect_null(requests[[5]]$search_id)
  expect_equal(requests[[5]]$cursor, 0L)

  # attributes refer to the last window and the last response
  expect_equal(attr(df, "search_id"), "7201388525814961198")
  expect_equal(attr(df, "cursor"), 100L)
  expect_equal(attr(df, "start_date"), as.Date("2023-03-04"))
  expect_equal(attr(df, "end_date"), as.Date("2023-03-15"))

  # cache accumulates across windows and last_query() can resume
  lq <- last_query()
  expect_equal(nrow(lq), 12L)
  expect_equal(attr(lq, "search_id"), "7201388525814961198")
  expect_equal(attr(lq, "cursor"), 100L)
  expect_equal(attr(lq, "start_date"), as.Date("2023-03-04"))

  # unparsed results are a plain list of all videos
  videos <- httr2::with_mocked_responses(
    mock_success,
    tt_search_api(
      "rstats",
      start_date = "20230101",
      end_date = "20230315",
      parse = FALSE,
      verbose = FALSE,
      token = list(access_token = "test")
    )
  )
  expect_equal(length(videos), 6L)
})


test_that("sliding windows resume after error", {
  n <- 0
  mock_fail_third <- function(req) {
    n <<- n + 1
    # fail on the first request of the second window
    if (n == 3) {
      return(httr2::response(
        status_code = 500,
        headers = "Content-Type: application/json",
        body = charToRaw(
          '{"error":{"code":"internal_error","message":"boom","log_id":"1"}}'
        )
      ))
    }
    httr2::response(
      status_code = 200,
      headers = "Content-Type: application/json",
      body = charToRaw(
        paste0(
          readLines("example_resp_q_videos.json"),
          collapse = ""
        )
      )
    )
  }

  expect_error(
    httr2::with_mocked_responses(
      mock_fail_third,
      tt_search_api(
        "rstats",
        start_date = "20230101",
        end_date = "20230315",
        max_pages = 2,
        verbose = FALSE,
        token = list(access_token = "test")
      )
    )
  )

  # videos from the completed first window are kept and the attributes point
  # to the start of the window that failed, with no stale search_id/cursor
  lq <- last_query()
  expect_equal(nrow(lq), 4L)
  expect_equal(attr(lq, "start_date"), as.Date("2023-02-01"))
  expect_equal(attr(lq, "end_date"), as.Date("2023-03-03"))
  expect_null(attr(lq, "search_id"))
  expect_equal(attr(lq, "cursor"), 0L)
})
