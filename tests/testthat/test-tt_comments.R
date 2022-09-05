skip_if(Sys.getenv("TT_COOKIES") == "")
df <- tt_comments(video_urls = c("https://www.tiktok.com/@tiktok/video/6584647400055377158?is_copy_url=1&is_from_webapp=v1",
                                 "https://www.tiktok.com/@tiktok/video/6584647400055377158?is_copy_url=1&is_from_webapp=v1"),

                  max_comments = 20,
                  cookiefile = Sys.getenv("TT_COOKIES"))

test_that("get meta and download", {
  expect_equal(nrow(df) >= 20L, TRUE)
  expect_equal(ncol(df), 8L)
})
