# Lookup TikTok information about a user using the research API

![\[Works on: Research API\]](figures/api-research.svg)

## Usage

``` r
tt_user_info_api(username, fields = "all", verbose = TRUE, token = NULL)

tt_user_info(username, fields = "all", verbose = TRUE, token = NULL)
```

## Arguments

- username:

  name(s) of the user(s) to be queried

- fields:

  The fields to be returned (defaults to all)

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
tt_user_info_api("jbgruber")
# OR
tt_user_info_api("https://www.tiktok.com/@tiktok")
# OR
tt_user_info("https://www.tiktok.com/@tiktok")
} # }
```
