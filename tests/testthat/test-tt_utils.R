test_that("wait", {
  expect_message(traktok:::wait(1:2), "...waiting \\d+\\.\\d seconds")
})
