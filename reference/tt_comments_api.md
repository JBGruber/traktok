# Retrieve video comments

![\[Works on: Research API\]](figures/api-research.svg)

## Usage

``` r
tt_comments_api(
  video_id,
  fields = "all",
  start_cursor = 0L,
  max_pages = 1L,
  cache = TRUE,
  verbose = TRUE,
  token = NULL
)

tt_comments(
  video_id,
  fields = "all",
  start_cursor = 0L,
  max_pages = 1L,
  cache = TRUE,
  verbose = TRUE,
  token = NULL
)
```

## Arguments

- video_id:

  The id or URL of a video

- fields:

  The fields to be returned (defaults to all)

- start_cursor:

  The starting cursor, i.e., how many results to skip (for picking up an
  old search).

- max_pages:

  results are returned in batches/pages with 100 videos. How many should
  be requested before the function stops?

- cache:

  should progress be saved in the current session? It can then be
  retrieved with
  [`last_query()`](https://jbgruber.github.io/traktok/reference/last_query.md)
  if an error occurs. But the function will use extra memory.

- verbose:

  should the function print status updates to the screen?

- token:

  The authentication token (usually supplied automatically after running
  [auth_research](https://jbgruber.github.io/traktok/reference/auth_research.md)
  once).

## Value

A data.frame of parsed comments.

## Examples

``` r
if (FALSE) { # \dontrun{
tt_comments("https://www.tiktok.com/@tiktok/video/7106594312292453675")
# OR
tt_comments("7106594312292453675")
# OR
tt_comments_api("7106594312292453675")
} # }
```
