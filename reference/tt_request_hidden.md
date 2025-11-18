# Get json string from a TikTok URL using the hidden API

![\[Works on: Unofficial API\]](figures/api-unofficial.svg)

Use this function in case you want to check the full data for a given
TikTok video or account. In tt_videos, only an opinionated selection of
data is included in the final object. If you want some different
information, you can use this function.

## Usage

``` r
tt_request_hidden(url, max_tries = 5L, cookiefile = NULL)
```

## Arguments

- url:

  a URL to a TikTok video or account

- max_tries:

  how often to retry if a request fails.

- cookiefile:

  path to your cookiefile. Usually not needed after running
  [auth_hidden](https://jbgruber.github.io/traktok/reference/auth_hidden.md)
  once. See
  [`vignette("unofficial-api", package = "traktok")`](https://jbgruber.github.io/traktok/articles/unofficial-api.md)
  for more information on authentication.

## Value

a json string containing post or account data.
