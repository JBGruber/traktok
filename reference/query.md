# Create a traktok query

Create a traktok query from the given parameters.

## Usage

``` r
query(and = NULL, or = NULL, not = NULL)

query_and(q, field_name, operation, field_values)

query_or(q, field_name, operation, field_values)

query_not(q, field_name, operation, field_values)
```

## Arguments

- and, or, not:

  A list of AND/OR/NOT conditions. Must contain one or multiple lists
  with `field_name`, `operation`, and `field_values` each (see example).

- q:

  A traktok query created with `query`.

- field_name:

  The field name to query against. One of: "create_date", "username",
  "region_code", "video_id", "hashtag_name", "keyword", "music_id",
  "effect_id", "video_length".

- operation:

  One of: "EQ", "IN", "GT", "GTE", "LT", "LTE".

- field_values:

  A vector of values to search for.

## Value

A traktok query.

## Details

TikTok's query consists of rather complicated lists dividing query
elements into AND, OR and NOT:

- **and**: The and conditions specify that all the conditions in the
  list must be met

- **or**: The or conditions specify that at least one of the conditions
  in the list must be met

- **not**: The not conditions specify that none of the conditions in the
  list must be met

The query can be constructed by writing the list for each entry
yourself, like in the first example. Alternatively, traktok provides
convenience functions to build up a query using `query_and`, `query_or`,
and `query_not`, which make building a query a little easier. You can
learn more at
<https://developers.tiktok.com/doc/research-api-specs-query-videos#query>.

## Examples

``` r
if (FALSE) { # \dontrun{
# using query directly and supplying the list
query(or = list(
  list(
    field_name = "hashtag_name",
    operation = "EQ",
    field_values = "rstats"
  ),
  list(
    field_name = "keyword",
    operation = "EQ",
    field_values = list("rstats", "API")
  )
))
# starting an empty query and building it up using the query_* functions
query() |>
  query_or(field_name = "hashtag_name",
           operation = "EQ",
           field_values = "rstats") |>
  query_or(field_name = "keyword",
           operation = "IN",
           field_values = c("rstats", "API"))
} # }
```
