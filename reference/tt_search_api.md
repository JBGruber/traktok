# Query TikTok videos using the research API

![\[Works on: Research API\]](figures/api-research.svg)

This is the version of
[tt_search](https://jbgruber.github.io/traktok/reference/tt_search.md)
that explicitly uses Research API. Use
[tt_search_hidden](https://jbgruber.github.io/traktok/reference/tt_search_hidden.md)
for the unofficial API version.

## Usage

``` r
tt_search_api(
  query,
  start_date = Sys.Date() - 1,
  end_date = Sys.Date(),
  fields = "all",
  start_cursor = 0L,
  search_id = NULL,
  is_random = FALSE,
  max_pages = 1,
  parse = TRUE,
  cache = TRUE,
  verbose = interactive(),
  token = NULL
)

tt_query_videos(
  query,
  start_date = Sys.Date() - 1,
  end_date = Sys.Date(),
  fields = "all",
  start_cursor = 0L,
  search_id = NULL,
  is_random = FALSE,
  max_pages = 1,
  parse = TRUE,
  cache = TRUE,
  verbose = interactive(),
  token = NULL
)
```

## Arguments

- query:

  A query string or object (see
  [query](https://jbgruber.github.io/traktok/reference/query.md)).

- start_date, end_date:

  A start and end date to narrow the search (required; can be a maximum
  of 30 days apart).

- fields:

  The fields to be returned (defaults to all)

- start_cursor:

  The starting cursor, i.e., how many results to skip (for picking up an
  old search).

- search_id:

  The search id (for picking up an old search).

- is_random:

  Whether the query is random (defaults to FALSE).

- max_pages:

  results are returned in batches/pages with 100 videos. How many should
  be requested before the function stops?

- parse:

  Should the results be parsed? Otherwise, the original JSON object is
  returned as a nested list.

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

A data.frame of parsed TikTok videos (or a nested list).

## Examples

``` r
if (FALSE) { # \dontrun{
# look for a keyword or hashtag by default
tt_search_api("rstats")

# or build a more elaborate query
query() |>
  query_and(field_name = "region_code",
            operation = "IN",
            field_values = c("JP", "US")) |>
  query_or(field_name = "hashtag_name",
            operation = "EQ", # rstats is the only hashtag
            field_values = "rstats") |>
  query_or(field_name = "keyword",
           operation = "IN", # rstats is one of the keywords
           field_values = "rstats") |>
  query_not(operation = "EQ",
            field_name = "video_length",
            field_values = "SHORT") |>
  tt_search_api()

# when a search fails after a while, get the results and pick it back up
# (only work with same parameters)
last_pull <- last_query()
query() |>
  query_and(field_name = "region_code",
            operation = "IN",
            field_values = c("JP", "US")) |>
  query_or(field_name = "hashtag_name",
            operation = "EQ", # rstats is the only hashtag
            field_values = "rstats") |>
  query_or(field_name = "keyword",
           operation = "IN", # rstats is one of the keywords
           field_values = "rstats") |>
  query_not(operation = "EQ",
            field_name = "video_length",
            field_values = "SHORT") |>
  tt_search_api(start_cursor = length(last_pull) + 1,
                search_id = attr(last_pull, "search_id"))
} # }
```
