# Get followers and following of users from the research API

![\[Works on: Research API\]](figures/api-research.svg)

## Usage

``` r
tt_user_follower_api(
  username,
  max_pages = 1,
  cache = TRUE,
  verbose = TRUE,
  token = NULL
)

tt_user_following_api(
  username,
  max_pages = 1,
  cache = TRUE,
  verbose = TRUE,
  token = NULL
)
```

## Arguments

- username:

  name(s) of the user(s) to be queried

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

A data.frame

## Examples

``` r
if (FALSE) { # \dontrun{
tt_user_follower_api("jbgruber")
# OR
tt_user_following_api("https://www.tiktok.com/@tiktok")
# OR
tt_get_follower("https://www.tiktok.com/@tiktok")
} # }
```
