test_that("get meta and download", {
  skip_if(Sys.getenv("TT_COOKIES") == "")
  options(tt_cookiefile = Sys.getenv("TT_COOKIES"))
  df <- tt_videos(video_urls = c("https://www.tiktok.com/@tiktok/video/6584647400055377158?is_copy_url=1&is_from_webapp=v1",
                                 "https://www.tiktok.com/@tiktok/video/6584647400055377158?is_copy_url=1&is_from_webapp=v1"),
                  save_video = FALSE,
                  dir = tempdir())
  expect_equal(nrow(df), 2L)
  expect_equal(ncol(df), 16L)
  # expect_equal(file.exists(df[["video_fn"]][1]), TRUE)
  expect_lte(sum(is.na(df)), 2L)
  expect_warning(tt_videos("https://www.tiktok.com/"),
                 "https://www.tiktok.com/ can't be reached.")
  expect_warning(tt_videos("https://www.tiktok.com/@test/video/6"),
                 "html status 404, the row will contain NAs")
})
