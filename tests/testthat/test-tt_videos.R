test_that("get meta and download", {
  skip_if(
    !isTRUE(auth_check(
      research = FALSE,
      hidden = TRUE,
      silent = TRUE,
      fail = FALSE
    )[
      "hidden"
    ])
  )
  on.exit(
    {
      fr <- list.files(
        tempdir(),
        pattern = "6584647400055377158|7564076741761813782",
        full.names = TRUE
      )
      file.remove(fr)
    },
    add = TRUE,
    after = FALSE
  )
  df <- tt_videos(
    video_urls = c(
      "https://www.tiktok.com/@tiktok/video/6584647400055377158?is_copy_url=1&is_from_webapp=v1",
      "https://www.tiktok.com/@europeanparliament/video/7564076741761813782?_r=1&_t=ZN-90nCXOsNHKI"
    ),
    cache_dir = tempdir(),
    save_video = TRUE,
    dir = tempdir()
  )
  expect_equal(nrow(df), 2L)
  expect_equal(ncol(df), 26L)
  expect_true(all(file.exists(df[["video_fn"]])))
  expect_equal(
    file.exists(paste0(tempdir(), "/6584647400055377158.json")),
    TRUE
  )
  expect_lte(sum(is.na(df)), 2L)
  expect_equal(
    ncol(suppressWarnings(tt_videos("https://www.tiktok.com/"))),
    24L
  )
  expect_warning(tt_videos("https://www.tiktok.com/"), "No.video.data.found")
})


test_that("parse", {
  expect_warning(
    parse_video('{"test":1}', video_id = 1L),
    "No video data found"
  )
  expect_equal(
    dim(parse_video('{"ItemModule":{"test":1}}', video_id = 1L)),
    c(1L, 18L)
  )
  expect_equal(
    dim(parse_video(
      '{"__DEFAULT_SCOPE__":{"webapp.video-detail":{"itemInfo":{"itemStruct":{"test":1}}}}}',
      video_id = 1L
    )),
    c(1L, 23L)
  )
})
