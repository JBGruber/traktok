skip_if(Sys.getenv("TT_COOKIES") == "")
df <- tt_videos(video_urls = c("https://www.tiktok.com/@tiktok/video/7125860750463094058?is_copy_url=1&is_from_webapp=v1",
                               "https://www.tiktok.com/@tiktok/video/7125860750463094058?is_copy_url=1&is_from_webapp=v1"),
                save_video = TRUE,
                dir = tempdir(),
                cookiefile = Sys.getenv("TT_COOKIES"))


test_that("get meta and download", {
  expect_equal(nrow(df), 2L)
  expect_equal(ncol(df), 19L)
  expect_equal(file.exists(df[["video_fn"]][1]), TRUE)
})
