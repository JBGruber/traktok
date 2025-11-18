# Lookup which videos were liked by a user using the research API

![\[Works on: Research API\]](figures/api-research.svg)

## Usage

``` r
tt_user_liked_videos_api(
  username,
  fields = "all",
  max_pages = 1,
  cache = TRUE,
  verbose = interactive(),
  token = NULL
)

tt_get_liked(
  username,
  fields = "all",
  max_pages = 1,
  cache = TRUE,
  verbose = interactive(),
  token = NULL
)
```

## Arguments

- username:

  name(s) of the user(s) to be queried

- fields:

  The fields to be returned (defaults to all)

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

A data.frame of parsed TikTok videos the user has posted.

## Examples

``` r
if (FALSE) { # \dontrun{
tt_get_liked("jbgruber")
# OR
tt_user_liked_videos_api("https://www.tiktok.com/@tiktok")
# OR
tt_user_liked_videos_api("https://www.tiktok.com/@tiktok")

# note: none of these work because I could not find any account that
# has likes public!
} # }
```
