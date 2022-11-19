test_that("get user videos", {
  skip_if(Sys.getenv("TT_COOKIES") == "")
  options(tt_cookiefile = Sys.getenv("TT_COOKIES"))
  df <- tt_user_videos(user_url = c("https://www.tiktok.com/@tiktok"))
  expect_equal(nrow(df) >= 1L, TRUE)
  expect_equal(ncol(df), 2L)
})
