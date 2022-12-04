test_that("get comments", {
  skip("skipped") # see https://github.com/JBGruber/traktok/issues/5
  # df <- tt_comments(video_urls = c("https://www.tiktok.com/@tiktok/video/6584647400055377158?is_copy_url=1&is_from_webapp=v1",
  #                                  "https://www.tiktok.com/@tiktok/video/6584647400055377158?is_copy_url=1&is_from_webapp=v1"),
  #                   max_comments = 20)
  expect_equal(nrow(df) >= 20L, TRUE)
  expect_equal(ncol(df), 8L)
})
