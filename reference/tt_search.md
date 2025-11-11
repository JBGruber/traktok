# Search videos

![\[Works on: Both\]](figures/api-both.svg)

Searches videos using either the Research API (if an authentication
token is present, see
[auth_research](https://jbgruber.github.io/traktok/reference/auth_research.md))
or otherwise the unofficial hidden API. See
[tt_search_api](https://jbgruber.github.io/traktok/reference/tt_search_api.md)
or
[tt_search_hidden](https://jbgruber.github.io/traktok/reference/tt_search_hidden.md)
respectively for information about these functions.

## Usage

``` r
tt_search(...)
```

## Arguments

- ...:

  arguments passed to
  [tt_search_api](https://jbgruber.github.io/traktok/reference/tt_search_api.md)
  or
  [tt_search_hidden](https://jbgruber.github.io/traktok/reference/tt_search_hidden.md).
  To use the research API, include `token` (e.g., `token = NULL`).

## Value

a data.frame
