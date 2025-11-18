# Get videos from a TikTok user's profile

![\[Works on: Unofficial API\]](figures/api-unofficial.svg)

Get all videos posted by a TikTok user.

## Usage

``` r
tt_user_videos_hidden(
  username,
  solve_captchas = FALSE,
  return_urls = FALSE,
  save_video = FALSE,
  timeout = 5L,
  scroll = "5m",
  verbose = interactive(),
  ...
)
```

## Arguments

- username:

  The username of the TikTok user whose hidden videos you want to
  retrieve.

- solve_captchas:

  open browser to solve appearing captchas manually.

- return_urls:

  return video URLs instead of downloading the vidoes.

- save_video:

  passed to
  [`tt_videos_hidden`](https://jbgruber.github.io/traktok/reference/tt_videos_hidden.md)
  if `return_urls = FALSE`.

- timeout:

  time (in seconds) to wait between scrolling and solving captchas.

- scroll:

  how long to keep scrolling before returning results. Can be a numeric
  value of seconds or a string with seconds, minutes, hours or days (see
  examples).

- verbose:

  should the function print status updates to the screen?

- ...:

  Additional arguments to be passed to the
  [`tt_videos_hidden`](https://jbgruber.github.io/traktok/reference/tt_videos_hidden.md)
  function.

## Value

A list of video data or URLs, depending on the value of `return_urls`.

a data.frame containing metadata of user posts or character vector of
URLs.

## Details

This function uses rvest to scrape a TikTok user's profile and retrieve
any hidden videos.

## Examples

``` r
if (FALSE) { # \dontrun{
# Get hidden videos from the user "fpoe_at"
tt_user_videos_hidden("fpoe_at")
} # }
```
