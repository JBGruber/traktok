item_detail <- '{"statusCode":0,"statusMsg":"","itemInfo":{"itemStruct":{
  "id":"1","desc":"test","createTime":"1760202820",
  "author":{"uniqueId":"user","nickname":"User"},
  "video":{"duration":0},
  "imagePost":{"images":[
    {"imageURL":{"urlList":["https://a/1.jpeg","https://b/1.jpeg"]}},
    {"imageURL":{"urlList":["https://a/2.jpeg"]}}
  ]},
  "music":{"title":"song","playUrl":"https://a/1.mp3"}
}}}'

test_that("parse_item", {
  item <- jsonlite::fromJSON(item_detail)
  df <- parse_item(
    video_data = item$itemInfo$itemStruct,
    video_id = "1",
    video_url = "https://www.tiktok.com/@user/photo/1",
    html_status = 200L,
    video_status_code = item$statusCode
  )
  expect_equal(nrow(df), 1L)
  expect_true(df$is_slides)
  expect_equal(df$download_url, "https://a/1.jpeg, https://a/2.jpeg")
  expect_equal(df$author_username, "user")
  expect_equal(df$music[[1]]$playUrl, "https://a/1.mp3")
  expect_equal(df$video_status_code, 0L)

  # no data: same classes, so that rows can be combined either way round
  empty <- parse_item(NULL, "1", "https://www.tiktok.com/@user/photo/1", 200L)
  expect_equal(nrow(empty), 1L)
  expect_true(is.na(empty$is_slides))
  expect_true(is.na(empty$download_url))
  expect_s3_class(empty$video_timestamp, "POSIXct")
  expect_type(empty$music, "list")
  expect_no_error(dplyr::bind_rows(empty[0, ], df))
  expect_no_error(dplyr::bind_rows(df[0, ], empty))
})

test_that("parse_video flags slideshows", {
  json <- structure(
    '{"test":1}',
    url_full = "https://www.tiktok.com/@user/photo/1",
    html_status = 200L
  )
  expect_no_warning(df <- parse_video(json, video_id = "1"))
  expect_true(df$is_slides)
  expect_true(is.na(df$download_url))
  # regular videos still warn
  attr(json, "url_full") <- "https://www.tiktok.com/@user/video/1"
  expect_warning(parse_video(json, video_id = "1"), "No video data found")
})

test_that("slideshows argument", {
  expect_error(
    tt_videos_hidden(
      "https://www.tiktok.com/@user/photo/1",
      slideshows = "yes"
    ),
    "slideshows"
  )

  # rows as tt_videos_hidden produces them before slideshows are handled
  video_row <- function(id, url) {
    parse_item(
      list(id = id, video = list(downloadAddr = "https://a/v.mp4")),
      video_id = id,
      video_url = url,
      html_status = 200L
    )
  }
  slide_row <- function(id, url) {
    df <- parse_item(NULL, video_id = id, video_url = url, html_status = 200L)
    df$is_slides <- TRUE
    df
  }
  out <- dplyr::bind_rows(
    slide_row("1", "https://www.tiktok.com/@user/photo/1"),
    video_row("2", "https://www.tiktok.com/@user/video/2"),
    slide_row("3", "https://www.tiktok.com/@user/photo/3")
  )
  idx <- which(out$is_slides %in% TRUE & is.na(out$download_url))
  expect_equal(idx, c(1L, 3L))

  # pretend to be tt_slideshow_hidden
  fake_slideshow <- function(slideshow_urls, ...) {
    item <- jsonlite::fromJSON(item_detail)
    dplyr::bind_rows(lapply(slideshow_urls, function(u) {
      df <- parse_item(
        video_data = item$itemInfo$itemStruct,
        video_id = extract_regex(u, "(?<=/photo/)(.+?)(?=\\?|$)"),
        video_url = u,
        html_status = 200L
      )
      df$video_fn <- "img.jpeg"
      df
    }))
  }
  local_mocked_bindings(tt_slideshow_hidden = fake_slideshow)

  # FALSE and non-interactive "ask": warn, keep rows
  rlang::local_interactive(FALSE)
  for (slideshows in list(FALSE, "ask")) {
    expect_warning(
      res <- add_slideshows(
        out,
        idx,
        slideshows,
        save_video = FALSE,
        overwrite = FALSE,
        dir = ".",
        sleep_pool = 1,
        verbose = FALSE
      ),
      "2 URLs are slideshows"
    )
    expect_equal(res, out)
  }

  # TRUE: rows are replaced in place
  res <- add_slideshows(
    out,
    idx,
    TRUE,
    save_video = FALSE,
    overwrite = FALSE,
    dir = ".",
    sleep_pool = 1,
    verbose = FALSE
  )
  expect_equal(res$video_id, c("1", "2", "3"))
  expect_equal(res$is_slides, c(TRUE, FALSE, TRUE))
  expect_equal(res$author_username, c("user", NA, "user"))
  expect_equal(res$video_fn, c("img.jpeg", NA, "img.jpeg"))
  expect_false(".order" %in% names(res))

  # only slideshows (nothing left to combine the results with)
  res <- add_slideshows(
    out[1, ],
    1L,
    TRUE,
    save_video = FALSE,
    overwrite = FALSE,
    dir = ".",
    sleep_pool = 1,
    verbose = FALSE
  )
  expect_equal(nrow(res), 1L)
  expect_equal(res$author_username, "user")

  # interactive "ask" (Enter/default = yes, as readline is non-blocking here)
  rlang::local_interactive(TRUE)
  capture.output(
    res <- add_slideshows(
      out,
      idx,
      "ask",
      save_video = FALSE,
      overwrite = FALSE,
      dir = ".",
      sleep_pool = 1,
      verbose = FALSE
    )
  )
  expect_equal(res$author_username, c("user", NA, "user"))
})

test_that("get slideshow", {
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
  skip_if_not_installed("chromote")
  skip_if_not(
    nzchar(Sys.which("chromium")) || nzchar(Sys.which("google-chrome"))
  )
  on.exit(
    {
      fr <- list.files(
        tempdir(),
        pattern = "7560013468020034848",
        full.names = TRUE
      )
      file.remove(fr)
    },
    add = TRUE,
    after = FALSE
  )
  df <- tt_slideshow_hidden(
    "https://www.tiktok.com/@chriskuvacyt/photo/7560013468020034848",
    dir = tempdir(),
    verbose = FALSE
  )
  expect_equal(nrow(df), 1L)
  expect_true(df$is_slides)
  expect_equal(df$author_username, "chriskuvacyt")
  expect_equal(df$video_status_code, 0L)
  images <- unlist(strsplit(df$video_fn, ", ", fixed = TRUE))
  expect_equal(length(images), 5L)
  expect_true(all(file.exists(images)))
  expect_true(file.exists(df$music_fn))
  expect_gt(file.size(df$music_fn), 1000)
})
