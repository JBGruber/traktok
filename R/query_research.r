#' Create a traktok query
#'
#' Create a traktok query from the given parameters.
#'
#' @param and,or,not A list of AND/OR/NOT conditions. Must contain one
#'   or multiple lists with \code{field_name}, \code{operation}, and
#'   \code{field_values} each (see example).
#' @param q A traktok query created with \code{query}.
#' @param field_name The field name to query against. One of:
#'   "create_date", "username", "region_code", "video_id",
#'   "hashtag_name", "keyword", "music_id", "effect_id",
#'   "video_length".
#' @param operation One of: "EQ", "IN", "GT", "GTE", "LT", "LTE".
#' @param field_values A vector of values to search for.
#'
#' @details TikTok's query consists of rather complicated lists
#'   dividing query elements into AND, OR and NOT:
#'
#' - **and**: The and conditions specify that all the conditions in the list must be met
#' - **or**: The or conditions specify that at least one of the conditions in the list must be met
#' - **not**: The not conditions specify that none of the conditions in the list must be met
#'
#' The query can be constructed by writing the list for each entry
#' yourself, like in the first example. Alternatively, traktok
#' provides convenience functions to build up a query using
#' \code{query_and}, \code{query_or}, and \code{query_not}, which
#' make building a query a little easier. You can learn more at
#' <https://developers.tiktok.com/doc/research-api-specs-query-videos#query>.
#'
#' @return A traktok query.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # using query directly and supplying the list
#' query(or = list(
#'   list(
#'     field_name = "hashtag_name",
#'     operation = "EQ",
#'     field_values = "rstats"
#'   ),
#'   list(
#'     field_name = "keyword",
#'     operation = "EQ",
#'     field_values = list("rstats", "API")
#'   )
#' ))
#' # starting an empty query and building it up using the query_* functions
#' query() |>
#'   query_or(field_name = "hashtag_name",
#'            operation = "EQ",
#'            field_values = "rstats") |>
#'   query_or(field_name = "keyword",
#'            operation = "IN",
#'            field_values = c("rstats", "API"))
#' }
#'
#' @md
query <- function(and = NULL, or = NULL, not = NULL) {
  q <- list(and = and, or = or, not = not)
  class(q) <- "traktok_query"
  return(clean_query(q))
}


#' @rdname query
#' @export
query_and <- function(q, field_name, operation, field_values) {
  ield_values <- unname(field_values)
  if (!is_query(q)) {
    cli::cli_abort("{.fn query_and} needs a query as input")
  }

  # TODO: is this really the best way to append the list?
  q$and[[length(q$and) + 1]] <- list(
    field_name = field_name,
    operation = operation,
    field_values = as.list(field_values)
  )

  return(clean_query(q))
}


#' @rdname query
#' @export
query_or <- function(q, field_name, operation, field_values) {
  field_values <- unname(field_values)
  if (!is_query(q)) {
    cli::cli_abort("{.fn query_or} needs a query as input")
  }

  q$or[[length(q$or) + 1]] <- list(
    field_name = field_name,
    operation = operation,
    field_values = as.list(field_values)
  )

  return(clean_query(q))
}


#' @rdname query
#' @export
query_not <- function(q, field_name, operation, field_values) {
  ield_values <- unname(field_values)
  if (!is_query(q)) {
    cli::cli_abort("{.fn query_not} needs a query as input")
  }

  q$not[[length(q$not) + 1]] <- list(
    field_name = field_name,
    operation = operation,
    field_values = as.list(field_values)
  )

  return(clean_query(q))
}


is_query <- function(q) {
  methods::is(q, "traktok_query")
}


# make sure query only consists of valid entries
clean_query <- function(q) {
  for (o in names(q)) {
    q[[o]][purrr::map_int(q[[o]], length) != 3] <- NULL
    q[!purrr::map_int(q, length) > 0] <- NULL
  }

  return(q)
}


#' @title Print a traktok query
#' @description Print a traktok query as a tree
#' @param x An object of class \code{traktok_query}
#' @param ... Additional arguments passed to \code{lobstr::tree}
#'
#' @return nothing. Prints traktok query.
#' @export
#' @examples
#' query() |>
#'   query_and(field_name = "hashtag_name",
#'             operation = "EQ",
#'             field_values = "rstats") |>
#'   print()
print.traktok_query <- function(x, ...) {
  lobstr::tree(as.list(x), ...)
}
