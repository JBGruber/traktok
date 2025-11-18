# Lookup which videos were pinned by a user using the research API

![\[Works on: Research API\]](figures/api-research.svg)

## Usage

``` r
tt_user_pinned_videos_api(
  username,
  fields = "all",
  cache = TRUE,
  verbose = interactive(),
  token = NULL
)

tt_get_pinned(
  username,
  fields = "all",
  cache = TRUE,
  verbose = interactive(),
  token = NULL
)
```

## Arguments

- username:

  vector of user names (handles) or URLs to users' pages.

- fields:

  The fields to be returned (defaults to all)

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
tt_get_pinned("jbgruber")
# OR
tt_user_pinned_videos_api("https://www.tiktok.com/@tiktok")
# OR
tt_user_pinned_videos_api("https://www.tiktok.com/@tiktok")
} # }
```
