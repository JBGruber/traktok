# Retrieve most recent query

If `tt_search_api` or `tt_comments_api` fail after already getting
several pages, you can use this function to get all videos that have
been retrieved so far from memory. Does not work when the session has
crashed. In that case, look in
[`tempdir()`](https://rdrr.io/r/base/tempfile.html) for an RDS file as a
last resort.

## Usage

``` r
last_query()

last_comments()
```

## Value

a list of unparsed videos or comments.
