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

test_that("parsing", {
  expect_equal({
    out <- jsonlite::read_json("example_resp.json") |>
      purrr::pluck("data", "videos") |>
      parse_api_search()
    c(out$video_id, nrow(out), ncol(out))
  }, c("702874395068494976", "702874395068494976", "2", "9"))
})
