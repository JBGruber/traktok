test_that("wait", {
  expect_message(traktok:::wait(1:2), "...waiting \\d+\\.\\d seconds")
  expect_error(traktok:::tt_read_cookies("test"),
               "cookiefile test does not exist")
  expect_equal(
    {
      tmp <- tempfile()
      writeLines("t\te\ts\tt\tt\te\ts\tt", tmp)
      traktok:::tt_read_cookies(tmp)
    }, "e=s")
})
