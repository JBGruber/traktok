test_that("vpluck", {
  expect_equal(
    vpluck(list(list(c("A", NA)), list(NULL)), 1, 1),
    c("A", NA_character_)
  )
  expect_equal(
    vpluck(list(list(c("A", NA)), list(NULL)), 1, 2),
    c(NA_character_, NA_character_)
  )
  expect_equal(
    vpluck(list(list(c(1L, NA)), list(NULL)), 1, 1, val = "integer"),
    c(1L, NA_integer_)
  )
  expect_equal(
    vpluck(list(list(c(TRUE, NA)), list(NULL)), 1, 1, val = "logical"),
    c(TRUE, NA)
  )
})

test_that("convert scroll to timestamp", {
  expect_equal(scroll2timestamp("1s"), Sys.time() + 1)
  expect_equal(scroll2timestamp("1m"), Sys.time() + 60)
  expect_equal(scroll2timestamp("1h"), Sys.time() + 60 * 60)
  expect_equal(scroll2timestamp("1d"), Sys.time() + 60 * 60 * 24)
  expect_equal(scroll2timestamp(72), Sys.time() + 72)
  expect_error(scroll2timestamp("1jiffy"), "Invalid.unit")
})


test_that("extract_regex", {
  expect_equal(
    extract_regex("hello123world", "[0-9]+"),
    "123"
  )
  # Test no match returns empty character
  expect_equal(
    extract_regex("nodigits", "[0-9]+"),
    character(0)
  )
  # Test with multiple potential matches (only first is returned)
  expect_equal(
    extract_regex("abc123def456", "[0-9]+"),
    "123"
  )
})


test_that("check_dir", {
  # Test with existing directory
  temp_dir <- tempdir()
  expect_silent(check_dir(temp_dir, "test"))

  # Test with NULL (should not error)
  expect_silent(check_dir(NULL, "test"))
})


test_that("wait", {
  # Test that wait actually waits
  sleep_pool <- c(0.1, 0.2)
  start_time <- Sys.time()
  wait(sleep_pool, verbose = FALSE)
  end_time <- Sys.time()
  elapsed <- as.numeric(difftime(end_time, start_time, units = "secs"))

  # Should have waited between 0 and max(sleep_pool)
  expect_true(elapsed >= 0)
  expect_true(elapsed <= max(sleep_pool))
})


test_that("spluck", {
  test_list <- list(a = list(b = list(c = "value")))

  # Test successful pluck
  expect_equal(spluck(test_list, "a", "b", "c"), "value")

  # Test with missing element returns NA
  expect_equal(spluck(test_list, "a", "b", "d"), NA)
  expect_equal(spluck(test_list, "x", "y", "z"), NA)

  # Test with NULL
  expect_equal(spluck(NULL, "a"), NA)
})


test_that("as_tibble_onerow", {
  # Test with list that has single values
  l1 <- list(a = 1, b = "text", c = TRUE)
  result1 <- as_tibble_onerow(l1)
  expect_s3_class(result1, "tbl_df")
  expect_equal(nrow(result1), 1)
  expect_equal(result1$a, 1)

  # Test with list that has vectors (should be wrapped in list columns)
  l2 <- list(a = 1:3, b = "text")
  result2 <- as_tibble_onerow(l2)
  expect_s3_class(result2, "tbl_df")
  expect_equal(nrow(result2), 1)
  expect_equal(result2$a[[1]], 1:3)

  # Test with mixed lengths
  l3 <- list(single = 5, multiple = c("a", "b", "c"))
  result3 <- as_tibble_onerow(l3)
  expect_equal(nrow(result3), 1)
  expect_equal(result3$single, 5)
  expect_equal(result3$multiple[[1]], c("a", "b", "c"))
})


test_that("is_datetime", {
  # Test POSIXct
  expect_true(is_datetime(as.POSIXct("2024-01-01")))

  # Test POSIXlt
  expect_true(is_datetime(as.POSIXlt("2024-01-01")))

  # Test Date
  expect_true(is_datetime(as.Date("2024-01-01")))

  # Test non-datetime objects
  expect_false(is_datetime("2024-01-01"))
  expect_false(is_datetime(123))
  expect_false(is_datetime(NULL))
})


test_that("as_datetime", {
  # Test with valid timestamp
  timestamp <- 1609459200 # 2021-01-01 00:00:00 UTC
  result <- as_datetime(timestamp)
  expect_s3_class(result, "POSIXct")
  expect_equal(as.numeric(result), timestamp)

  # Test with zero (TikTok missing value)
  expect_equal(as_datetime(0), NA)

  # Test with negative value
  expect_equal(as_datetime(-1), NA)

  # Test with vector containing zero
  expect_equal(as_datetime(c(0, 1609459200)), NA)
})


test_that("id2url", {
  # Test with video IDs (numeric strings)
  expect_equal(
    id2url("1234567890"),
    "https://www.tiktok.com/@/video/1234567890"
  )

  # Test with already formatted URLs (should remain unchanged)
  url <- "https://www.tiktok.com/@user/video/1234567890"
  expect_equal(id2url(url), url)

  # Test with vector of mixed IDs and URLs
  input <- c("1234567890", "https://www.tiktok.com/@user/video/9876543210")
  output <- id2url(input)
  expect_equal(output[1], "https://www.tiktok.com/@/video/1234567890")
  expect_equal(output[2], "https://www.tiktok.com/@user/video/9876543210")

  # Test error with non-character input
  expect_error(
    id2url(123),
    "character vector"
  )
})


test_that("clean_names", {
  # Test basic camelCase to snake_case
  expect_equal(clean_names("camelCase"), "camel_case")

  # Test PascalCase (note: function adds leading underscore for initial caps)
  expect_equal(clean_names("PascalCase"), "pascal_case")

  # Test multiple capital letters
  expect_equal(clean_names("thisIsATest"), "this_is_a_test")

  # Test already lowercase
  expect_equal(clean_names("lowercase"), "lowercase")

  # Test with numbers
  expect_equal(clean_names("test123Value"), "test123_value")

  # Test vector of names
  input <- c("firstName", "lastName", "emailAddress")
  expected <- c("first_name", "last_name", "email_address")
  expect_equal(clean_names(input), expected)
})


test_that("extract_urls_sess", {
  # This function requires an rvest session object
  # Create a mock HTML structure
  html <- '
    <html>
      <body>
        <div id="column-item-video-container-1">
          <a href="https://www.tiktok.com/@user1/video/1234567890">Video 1</a>
        </div>
        <div id="column-item-video-container-2">
          <a href="https://www.tiktok.com/@user2/video/9876543210">Video 2</a>
        </div>
        <div id="other-container">
          <a href="https://www.tiktok.com/@user3/photo/1111111111">Photo</a>
        </div>
      </body>
    </html>
  '

  # Parse HTML
  sess <- rvest::read_html(html)

  # Test extraction
  urls <- extract_urls_sess(sess)
  expect_length(urls, 2)
  expect_true(all(grepl("/video/", urls)))
  expect_true(any(grepl("/photo/", urls)))
})
