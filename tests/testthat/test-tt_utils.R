test_that("wait", {
  expect_message(traktok:::wait(1:2), "...waiting (\\d+\\.\\d|\\d+) seconds")
})

test_that("1. cookies as string options", {
  options(tt_cookiefile = Sys.getenv("TT_COOKIES"))
  expect_gt(nchar(tt_get_cookies(save = FALSE)), 100)
  unlink(list.files(tools::R_user_dir("traktok", "config"), full.names = TRUE))
})

test_that("2. default cookie file", {
  tmp <- tempfile()
  options(tt_cookiefile = tmp)
  writeLines("\t\t\t\t\ttt_csrf_token\ttest;", tmp)
  expect_equal(tt_get_cookies(save = FALSE),
               list(tt_csrf_token = "test;"))
})

test_that("3. default directory", {
  options(tt_cookiefile = NULL)
  tmp <- file.path(tools::R_user_dir("traktok", "config"), "aaa")
  writeLines("\t\t\t\t\ttt_csrf_token\ttest;", tmp)
  expect_equal(tt_get_cookies(save = FALSE),
               list(tt_csrf_token = "test;"))
  unlink(list.files(tools::R_user_dir("traktok", "config"), full.names = TRUE))
})

test_that("4. no/invalid cookies", {
  options(tt_cookiefile = NULL)
  expect_error(tt_get_cookies(save = FALSE),
               "No cookies provided or found")
  expect_error(tt_get_cookies(x = "test"),
               "No cookies provided or found")
})

test_that("5. invalid cookie string/file", {
  expect_error(tt_get_cookies(x = "test=test;"),
               " does not contain valid TikTok cookies")

  expect_error(tt_get_cookies(x = list()),
               " does not contain valid TikTok cookies")

  tmp <- tempfile()
  writeLines("\t\t\t\t\ttest\ttest;", tmp)
  expect_error(tt_get_cookies(x = tmp),
               " does not contain valid TikTok cookies")
})
