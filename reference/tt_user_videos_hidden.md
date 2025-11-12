# Get videos from a TikTok user's profile

![\[Works on: Unofficial API\]](figures/api-unofficial)

Get all videos posted by a TikTok user.

## Usage

``` r
tt_user_videos_hidden(
  username,
  solve_captchas = FALSE,
  return_urls = FALSE,
  timeout = 5L,
  verbose = TRUE,
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

- timeout:

  time (in seconds) to wait between scrolling and solving captchas.

- verbose:

  should the function print status updates to the screen?

- ...:

  Additional arguments to be passed to the
  [`tt_videos_hidden`](https://jbgruber.github.io/traktok/reference/tt_videos_hidden.md)
  function.

## Value

A list of video data or URLs, depending on the value of `return_urls`.

a data.frame containing metadata of user posts.

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
