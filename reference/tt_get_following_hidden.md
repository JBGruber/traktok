# Get followers and following of a user from the hidden API

![\[Works on: Unofficial API\]](figures/api-unofficial.svg)

Get up to 5,000 accounts who follow a user or accounts a user follows.

## Usage

``` r
tt_get_following_hidden(
  secuid,
  sleep_pool = 1:10,
  max_tries = 5L,
  cookiefile = NULL,
  verbose = interactive()
)

tt_get_follower_hidden(
  secuid,
  sleep_pool = 1:10,
  max_tries = 5L,
  cookiefile = NULL,
  verbose = interactive()
)
```

## Arguments

- secuid:

  The secuid of a user. You can get it with
  [tt_user_info_hidden](https://jbgruber.github.io/traktok/reference/tt_user_info_hidden.md)
  by querying an account (see example).

- sleep_pool:

  a vector of numbers from which a waiting period is randomly drawn.

- max_tries:

  how often to retry if a request fails.

- cookiefile:

  path to your cookiefile. Usually not needed after running
  [auth_hidden](https://jbgruber.github.io/traktok/reference/auth_hidden.md)
  once. See
  [`vignette("unofficial-api", package = "traktok")`](https://jbgruber.github.io/traktok/articles/unofficial-api.md)
  for more information on authentication.

- verbose:

  should the function print status updates to the screen?

## Value

a data.frame of followers

## Examples

``` r
if (FALSE) { # \dontrun{
df <- tt_user_info_hidden("https://www.tiktok.com/@fpoe_at")
tt_get_follower_hidden(df$secUid)
} # }
```
