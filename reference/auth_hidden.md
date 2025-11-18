# Authenticate for the hidden/unofficial API

Guides you through authentication for the hidden/unofficial API. To
learn more, see the [hidden API
vignette](https://jbgruber.github.io/traktok/articles/unofficial-api.html#authentication)
or view it locally with
[`vignette("unofficial-api", package = "traktok")`](https://jbgruber.github.io/traktok/articles/unofficial-api.md).

## Usage

``` r
auth_hidden(cookiefile, live = interactive())
```

## Arguments

- cookiefile:

  path to your cookiefile. Usually not needed after running auth_hidden
  once. See
  [`vignette("unofficial-api", package = "traktok")`](https://jbgruber.github.io/traktok/articles/unofficial-api.md)
  for more information on authentication.

- live:

  opens Chromium browser to guide you through the auth process
  (experimental).

## Value

nothing. Called to set up authentication

## Examples

``` r
if (FALSE) { # \dontrun{
# to run through the steps of authentication
auth_hidden()
# or point to a cookie file directly
auth_hidden("www.tiktok.com_cookies.txt")
} # }
```
