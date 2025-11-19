test_that("authentication checks", {
  # change paths of token and cookies for tests
  op <- options(cookie_dir = "test")
  old_token <- Sys.getenv("TIKTOK_TOKEN", unset = NA)
  Sys.setenv("TIKTOK_TOKEN" = "test.rds")
  on.exit(
    {
      options(op)
      if (is.na(old_token)) {
        Sys.unsetenv("TIKTOK_TOKEN")
      } else {
        Sys.setenv("TIKTOK_TOKEN" = old_token)
      }
    },
    add = TRUE,
    after = FALSE
  )

  expect_error(
    auth_check(silent = TRUE, fail = TRUE),
    "add.some.basic.authentication"
  )
  expect_warning(
    auth_check(silent = TRUE, fail = FALSE),
    "add.some.basic.authentication"
  )
  au <- suppressWarnings(auth_check(silent = TRUE))
  expect_equal(sum(au), 0L)
  expect_false(isTRUE(au["research"]))
  expect_false(isTRUE(au["hidden"]))
})
