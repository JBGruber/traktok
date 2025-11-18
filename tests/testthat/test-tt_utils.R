# will be rewritten soon anyway
# test_that("1. cookies as string options", {
#   options(tt_cookiefile = "tt_csrf_token=test;")
#   expect_equal(auth_hidden(save = FALSE), list(tt_csrf_token = "test;"))
#   unlink(list.files(tools::R_user_dir("traktok", "config"), full.names = TRUE))
# })
#
# test_that("2. default cookie file", {
#   tmp <- tempfile()
#   options(tt_cookiefile = tmp)
#   writeLines("\t\t\t\t\ttt_csrf_token\ttest;", tmp)
#   expect_equal(auth_hidden(save = FALSE),
#                list(tt_csrf_token = "test;"))
# })
#
# test_that("3. default directory", {
#   options(tt_cookiefile = NULL)
#   tmp <- file.path(tools::R_user_dir("traktok", "config"), "aaa")
#   writeLines("\t\t\t\t\ttt_csrf_token\ttest;", tmp)
#   expect_equal(auth_hidden(save = FALSE),
#                list(tt_csrf_token = "test;"))
#   unlink(list.files(tools::R_user_dir("traktok", "config"), full.names = TRUE))
# })
#
# test_that("4. no/invalid cookies", {
#   options(tt_cookiefile = NULL)
#   expect_error(auth_hidden(save = FALSE),
#                "No cookies provided or found")
#   expect_error(auth_hidden(x = "test"),
#                "No cookies provided or found")
# })
#
# test_that("5. invalid cookie string/file", {
#   expect_error(auth_hidden(x = "test=test;"),
#                " does not contain valid TikTok cookies")
#
#   expect_error(auth_hidden(x = list()),
#                " does not contain valid TikTok cookies")
#
#   tmp <- tempfile()
#   writeLines("\t\t\t\t\ttest\ttest;", tmp)
#   expect_error(auth_hidden(x = tmp),
#                " does not contain valid TikTok cookies")
# })
#
#
# test_that("vpluck", {
#   expect_equal(
#     vpluck(list(list(c("A", NA)), list(NULL)), 1, 1),
#     c("A", NA_character_)
#   )
#   expect_equal(
#     vpluck(list(list(c("A", NA)), list(NULL)), 1, 2),
#     c(NA_character_, NA_character_)
#   )
#   expect_equal(
#     vpluck(list(list(c(1L, NA)), list(NULL)), 1, 1, val = "integer"),
#     c(1L, NA_integer_)
#   )
#   expect_equal(
#     vpluck(list(list(c(TRUE, NA)), list(NULL)), 1, 1, val = "logical"),
#     c(TRUE, NA)
#   )
# })

test_that("convert scroll to timestamp", {
  expect_equal(scroll2timestamp("1s"), Sys.time() + 1)
  expect_equal(scroll2timestamp("1m"), Sys.time() + 60)
  expect_equal(scroll2timestamp("1h"), Sys.time() + 60 * 60)
  expect_equal(scroll2timestamp("1d"), Sys.time() + 60 * 60 * 24)
  expect_equal(scroll2timestamp(72), Sys.time() + 72)
  expect_error(scroll2timestamp("1jiffy"), "Invalid.unit")
})
