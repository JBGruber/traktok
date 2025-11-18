test_that("search keywords", {
  skip_if(
    !isTRUE(auth_check(research = FALSE, hidden = TRUE, silent = TRUE)[
      "hidden"
    ])
  )
  skip_if(check_live_setup() < 2L)
  # test
  start_time <- Sys.time()
  search_urls <- tt_search_hidden(
    query = "#rstats",
    solve_captchas = FALSE,
    scroll = "1s",
    return_urls = TRUE
  )
  end_time <- Sys.time()
  elapsed <- as.numeric(difftime(end_time, start_time, units = "secs"))
  expect_lte(elapsed, 60L)
  expect_type(search_urls, "character")
  skip_if(isTRUE(the$captcha))
  expect_gt(length(search_urls), 1L)
})

test_that("search user videos", {
  skip_if(
    !isTRUE(auth_check(research = FALSE, hidden = TRUE, silent = TRUE)[
      "hidden"
    ])
  )
  skip_if(check_live_setup() < 2L)
  # test
  start_time <- Sys.time()
  search_urls <- tt_user_videos_hidden(
    username = "tiktok",
    solve_captchas = FALSE,
    scroll = "1s",
    return_urls = TRUE
  )
  end_time <- Sys.time()
  elapsed <- as.numeric(difftime(end_time, start_time, units = "secs"))
  expect_lte(elapsed, 60L)
  expect_type(search_urls, "character")
  skip_if(isTRUE(the$captcha))
  expect_gt(length(search_urls), 1L)
})
