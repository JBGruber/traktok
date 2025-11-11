# Get followers and following of users

![\[Works on: Both\]](figures/api-both.svg)

Get usernames of users who follows a user (tt_get_follower) or get who a
user is following (tt_get_following).

## Usage

``` r
tt_get_follower(...)

tt_get_following(...)
```

## Arguments

- ...:

  arguments passed to
  [tt_user_follower_api](https://jbgruber.github.io/traktok/reference/tt_user_follower_api.md)
  or
  [tt_get_follower_hidden](https://jbgruber.github.io/traktok/reference/tt_get_following_hidden.md).
  To use the research API, include `token` (e.g., `token = NULL`).

## Value

a data.frame
