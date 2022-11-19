test_that("found some videos", {
  skip("skipped") # see https://github.com/JBGruber/traktok/issues/4
  # df <- tt_search_hashtag("hashtag",
  #                         max_videos = 20,
  #                         cookiefile = Sys.getenv("TT_COOKIES"))
  expect_equal(nrow(df) >= 20L, TRUE)
  expect_equal(ncol(df), 17L)
})
