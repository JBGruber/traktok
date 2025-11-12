# Search videos

![\[Works on: Unofficial API\]](figures/api-unofficial)

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
  verbose = TRUE,
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

- verbose:

  should the function print status updates to the screen?

- headless:

  open the browser to show the scrolling.

- ...:

  here to absorb parameters of the old function.

## Value

a character vector of URLs.

## Details

The function will wait between scraping search results. To get more than
6 videos, you need to provide cookies of a logged in account. For more
details see the unofficial-api vignette:
[`vignette("unofficial-api", package = "traktok")`](https://jbgruber.github.io/traktok/articles/unofficial-api.md)

## Examples

``` r
if (FALSE) { # \dontrun{
tt_search_hidden("#rstats")
# the functions runs until the end of all search results, which can take a
# long time. You can cancel the search and retrieve all collected results
# with last_query though!
last_query()
} # }
```
