# Get slideshow metadata, images and music from URLs

![\[Works on: Unofficial API\]](figures/api-unofficial.svg)

TikTok does not include the data of slideshows (photo posts) in the page
source that
[tt_videos_hidden](https://jbgruber.github.io/traktok/reference/tt_videos_hidden.md)
relies on. This function instead opens each post in a (headless)
browser, waits until the site has requested the post data itself and
collects metadata, images and music from there. This is considerably
slower than
[tt_videos_hidden](https://jbgruber.github.io/traktok/reference/tt_videos_hidden.md)
and needs the `chromote` package (and a Chrome or Chromium browser)
installed.

## Usage

``` r
tt_slideshow_hidden(
  slideshow_urls,
  save_images = TRUE,
  save_music = TRUE,
  overwrite = FALSE,
  dir = ".",
  solve_captchas = FALSE,
  timeout = 30L,
  sleep_pool = 1:10,
  cookiefile = NULL,
  verbose = interactive(),
  headless = TRUE
)
```

## Arguments

- slideshow_urls:

  vector of URLs or IDs to TikTok slideshows (photo posts).

- save_images:

  logical. Should the images be downloaded.

- save_music:

  logical. Should the music of the slideshows be downloaded (as mp3).

- overwrite:

  logical. If save_video=TRUE and the file already exists, should it be
  overwritten?

- dir:

  directory to save videos files to.

- solve_captchas:

  open browser to solve appearing captchas manually.

- timeout:

  maximum time (in seconds) to wait for a post to load.

- sleep_pool:

  a vector of numbers from which a waiting period is randomly drawn.

- cookiefile:

  path to your cookiefile. Usually not needed after running
  [auth_hidden](https://jbgruber.github.io/traktok/reference/auth_hidden.md)
  once. See
  [`vignette("unofficial-api", package = "traktok")`](https://jbgruber.github.io/traktok/articles/unofficial-api.md)
  for more information on authentication.

- verbose:

  should the function print status updates to the screen?

- headless:

  should the browser window stay hidden?

## Value

a data.frame with the same columns as
[tt_videos_hidden](https://jbgruber.github.io/traktok/reference/tt_videos_hidden.md).

## Details

Images are saved as `<author>_video_<id>_<n>.jpeg` and the music as
`<author>_video_<id>.mp3` in `dir`. The paths are returned in the
columns `video_fn` (comma-separated) and `music_fn`. Metadata about the
music is in the `music` column.

## Examples

``` r
if (FALSE) { # \dontrun{
tt_slideshow_hidden(
  "https://www.tiktok.com/@chriskuvacyt/photo/7560013468020034848"
)
} # }
```
