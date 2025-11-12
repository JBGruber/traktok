# Print a traktok query

Print a traktok query as a tree

## Usage

``` r
# S3 method for class 'traktok_query'
print(x, ...)
```

## Arguments

- x:

  An object of class `traktok_query`

- ...:

  Additional arguments passed to
  [`lobstr::tree`](https://lobstr.r-lib.org/reference/tree.html)

## Value

nothing. Prints traktok query.

## Examples

``` r
query() |>
  query_and(field_name = "hashtag_name",
            operation = "EQ",
            field_values = "rstats") |>
  print()
#> S3<traktok_query>
#> └─and: <list>
#>   └─<list>
#>     ├─field_name: "hashtag_name"
#>     ├─operation: "EQ"
#>     └─field_values: <list>
#>       └─"rstats"
```
