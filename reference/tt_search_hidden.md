# Search videos

![\[Works on: Unofficial API\]](figures/api-unofficial.svg)

This is the version of
[tt_search](https://jbgruber.github.io/traktok/reference/tt_search.md)
that explicitly uses the unofficial API. Use
[tt_search_api](https://jbgruber.github.io/traktok/reference/tt_search_api.md)
for the Research API version.

## Usage

``` r
tt_search_hidden(
  query,
  solve_captchas = FALSE,
  timeout = 5L,
  scroll = "5m",
  return_urls = FALSE,
  save_video = FALSE,
  verbose = interactive(),
  headless = TRUE,
  ...
)
```

## Arguments

- query:

  query as one string.

- solve_captchas:

  open browser to solve appearing captchas manually.

- timeout:

  time (in seconds) to wait between scrolling and solving captchas.

- scroll:

  how long to keep scrolling before returning results. Can be a numeric
  value of seconds or a string with seconds, minutes, hours or days (see
  examples).

- return_urls:

  return video URLs instead of downloading the vidoes.

- save_video:

  passed to
  [`tt_videos_hidden`](https://jbgruber.github.io/traktok/reference/tt_videos_hidden.md)
  if `return_urls = FALSE`.

- verbose:

  should the function print status updates to the screen?

- headless:

  open the browser to show the scrolling.

- ...:

  Additional arguments to be passed to the
  [`tt_videos_hidden`](https://jbgruber.github.io/traktok/reference/tt_videos_hidden.md)
  function.

## Value

a data.frame containing metadata searched posts or character vector of
URLs.

## Details

The function will wait between scraping search results. To get more than
6 videos, you need to provide cookies of a logged in account. For more
details see the unofficial-api vignette:
[`vignette("unofficial-api", package = "traktok")`](https://jbgruber.github.io/traktok/articles/unofficial-api.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# search videos with hastag #rstats for default time
tt_search_hidden("#rstats")

# search videos for 10 seconds
tt_search_hidden("#rstats", scroll = "10s")
tt_search_hidden("#rstats", scroll = 10)

# search videos for 10 minutes
tt_search_hidden("#rstats", scroll = "10m")
tt_search_hidden("#rstats", scroll = "10mins")

# search videos for 10 hours
tt_search_hidden("#rstats", scroll = "10h")
tt_search_hidden("#rstats", scroll = "10hours")

# search videos until all are found
tt_search_hidden("#rstats", scroll = Inf)
# the functions runs until the end of all search results, which can take a
# long time. You can cancel the search and retrieve all collected results
# with last_query though!
last_query()
} # }
```
