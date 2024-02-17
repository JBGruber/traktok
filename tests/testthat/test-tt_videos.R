test_that("get meta and download", {
  skip("need to rewrite after refactor")
  options(tt_cookiefile = Sys.getenv("TT_COOKIES"))
  df <- tt_videos(video_urls = c("https://www.tiktok.com/@tiktok/video/6584647400055377158?is_copy_url=1&is_from_webapp=v1",
                                 "https://www.tiktok.com/@tiktok/video/6584647400055377158?is_copy_url=1&is_from_webapp=v1"),
                  cache_dir = tempdir(),
                  save_video = FALSE,
                  dir = tempdir())
  expect_equal(nrow(df), 2L)
  expect_equal(ncol(df), 16L)
  # expect_equal(file.exists(df[["video_fn"]][1]), TRUE)
  expect_equal(file.exists(paste0(tempdir(), "/video_meta_6584647400055377158.rds")), TRUE)
  expect_lte(sum(is.na(df)), 2L)
  expect_warning(tt_videos("https://www.tiktok.com/"),
                 "https://www.tiktok.com/ can't be reached.")
  expect_warning(tt_videos("https://www.tiktok.com/@test/video/6"),
                 "html status 404, the row will contain NAs")
})


test_that("parse", {
  expect_warning(parse_video('{"test":1}', video_id = 1L),
                 "No video data found")
  expect_equal(
    dim(parse_video('{"ItemModule":{"test":1}}', video_id = 1L)),
    c(1L, 18L)
  )
  expect_equal(
    dim(parse_video('{"__DEFAULT_SCOPE__":{"webapp.video-detail":{"itemInfo":{"itemStruct":{"test":1}}}}}', video_id = 1L)),
    c(1L, 22L)
  )
})
