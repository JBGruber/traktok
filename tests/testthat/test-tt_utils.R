test_that("wait", {
  expect_message(traktok:::wait(1:2), "...waiting (\\d+\\.\\d|\\d+) seconds")
  expect_gt(nchar(traktok:::tt_get_cookies()),
            100)
  expect_equal(
    {
      tmp <- tempfile()
      writeLines("t\te\ts\tt\tt\te\ts\tt", tmp)
      traktok:::tt_get_cookies(tmp)
    }, "e=s")
})
