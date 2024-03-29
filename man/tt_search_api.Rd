% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/api_research.r
\name{tt_search_api}
\alias{tt_search_api}
\alias{tt_query_videos}
\title{Query TikTok videos using the research API}
\usage{
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
  verbose = TRUE,
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
  verbose = TRUE,
  token = NULL
)
}
\arguments{
\item{query}{A query string or object (see \link{query})}

\item{start_date, end_date}{A start and end date to narrow the search
(required).}

\item{fields}{The fields to be returned (defaults to all)}

\item{start_cursor}{The starting cursor, i.e., how many results to skip (for
picking up an old search)}

\item{search_id}{The search id (for picking up an old search)}

\item{is_random}{Whether the query is random (defaults to FALSE)}

\item{max_pages}{results are returned in batches/pages with 100 videos. How
many should be requested before the function stops?}

\item{parse}{Should the results be parsed? Otherwise, the original JSON
object is returned as a nested list.}

\item{cache}{should progress be saved in the current session? It can then be
retrieved with \code{last_query()} if an error occurs. But the function
will use extra memory.}

\item{verbose}{should the function print status updates to the screen?}

\item{token}{The authentication token (usually supplied automatically after
running auth_research once)}
}
\value{
A data.frame of parsed TikTok videos (or a nested list).
}
\description{
\ifelse{html}{\figure{api-research.svg}{options: alt='[Works on:
  Research API]'}}{\strong{[Works on: Research API]}}

  This is the version of \link{tt_search} that explicitly uses Research API.
  Use \link{tt_search_hidden} for the unofficial API version.
}
\examples{
\dontrun{
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
}
}
