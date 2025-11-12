# Get videos from a TikTok user's profile

![\[Works on: Both\]](figures/api-both.svg)

Get all videos posted by a user (or multiple user's for the Research
API). Searches videos using either the Research API (if an
authentication token is present, see
[auth_research](https://jbgruber.github.io/traktok/reference/auth_research.md))
or otherwise the unofficial hidden API. See
[tt_user_videos_api](https://jbgruber.github.io/traktok/reference/tt_user_videos_api.md)
or
[tt_user_videos_hidden](https://jbgruber.github.io/traktok/reference/tt_user_videos_hidden.md)
respectively for information about these functions.

## Usage

``` r
tt_user_videos(username, ...)
```

## Arguments

- username:

  The username or usernames whose videos you want to retrieve.

- ...:

  Additional arguments to be passed to the
  [`tt_user_videos_hidden`](https://jbgruber.github.io/traktok/reference/tt_user_videos_hidden.md)
  or
  [`tt_user_videos_api`](https://jbgruber.github.io/traktok/reference/tt_user_videos_api.md)
  function.

## Value

a data.frame containing metadata of user posts.

## Examples

``` r
if (FALSE) { # \dontrun{
# Get hidden videos from the user "fpoe_at"
tt_user_videos("fpoe_at")
} # }
```
