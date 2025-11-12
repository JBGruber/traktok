# Get video metadata and video files from URLs

![\[Works on: Unofficial API\]](figures/api-unofficial)

## Usage

``` r
tt_videos_hidden(
  video_urls,
  save_video = TRUE,
  overwrite = FALSE,
  dir = ".",
  cache_dir = NULL,
  sleep_pool = 1:10,
  max_tries = 5L,
  cookiefile = NULL,
  verbose = TRUE,
  ...
)

tt_videos(...)
```

## Arguments

- video_urls:

  vector of URLs or IDs to TikTok videos.

- save_video:

  logical. Should the videos be downloaded.

- overwrite:

  logical. If save_video=TRUE and the file already exists, should it be
  overwritten?

- dir:

  directory to save videos files to.

- cache_dir:

  if set to a path, one RDS file with metadata will be written to disk
  for each video. This is useful if you have many videos and want to
  pick up where you left if something goes wrong.

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

- ...:

  handed to `tt_videos_hidden` (for tt_videos) and (further) to
  [tt_request_hidden](https://jbgruber.github.io/traktok/reference/tt_request_hidden.md).

## Value

a data.frame containing post metadata.

## Details

The function will wait between scraping two videos to make it less
obvious that a scraper is accessing the site. The period is drawn
randomly from the \`sleep_pool\` and multiplied by a random fraction.

Note that the video file has to be requested in the same session as the
metadata. So while the URL to the video file is included in the
metadata, this link will not work in most cases.

## Examples

``` r
if (FALSE) { # \dontrun{
tt_videos("https://www.tiktok.com/@tiktok/video/7106594312292453675")
} # }
```
