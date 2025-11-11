# Get videos from a TikTok user's profile

![\[Works on: Research API\]](figures/api-research.svg)

Get all videos posted by a user or multiple user's. This is a
convenience wrapper around
[`tt_search_api`](https://jbgruber.github.io/traktok/reference/tt_search_api.md)
that takes care of moving time windows (search is limited to 30 days).
This is the version of
[tt_user_videos](https://jbgruber.github.io/traktok/reference/tt_user_videos.md)
that explicitly uses Research API. Use
[tt_user_videos_hidden](https://jbgruber.github.io/traktok/reference/tt_user_videos_hidden.md)
for the unofficial API version.

## Usage

``` r
tt_user_videos_api(
  username,
  since = "2020-01-01",
  to = Sys.Date(),
  verbose = TRUE,
  ...
)
```

## Arguments

- username:

  The username or usernames whose videos you want to retrieve.

- since, to:

  limits from/to when to go through the account in 30 day windows.

- verbose:

  should the function print status updates to the screen?

- ...:

  Additional arguments to be passed to the
  [`tt_search_api`](https://jbgruber.github.io/traktok/reference/tt_search_api.md)
  function.

## Examples

``` r
if (FALSE) { # \dontrun{
# Get videos from the user "fpoe_at" since October 2024
tt_user_videos_api("fpoe_at", since = "2024-10-01")

# often makes sense to combine this with the account creation time from the
# hidden URL
fpoe_at_info <- tt_user_info_hidden(username = "fpoe_at")
tt_user_videos_api("fpoe_at", since = fpoe_at_info$create_time)

} # }
```
