% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/traktok.R
\name{tt_search}
\alias{tt_search}
\title{Search videos}
\usage{
tt_search(
  q,
  scope = "",
  max_videos = Inf,
  offset = 0L,
  cookiefile = NULL,
  sleep_pool = 1:10,
  ...
)
}
\arguments{
\item{q}{query as one string}

\item{scope}{can be left blank or either "video" or "user" to narrow down the
search.}

\item{max_videos}{max number of videos to return (the function will usually
return a few more than the exact number).}

\item{offset}{how many videos to skip. For example, if you already have the
first X of a search.}

\item{cookiefile}{path to your cookiefile. Default is to request a new one
from TikTok.com and place it in the location returned by
\code{tools::R_user_dir("traktok", "config")} and set the option cookiefile
to this location.}

\item{sleep_pool}{a vector of numbers from which a waiting period is randomly
drawn.}

\item{...}{handed to \link{tt_json}.}
}
\value{
a data.frame
}
\description{
Search videos
}
\examples{
\dontrun{
tt_search("#rstats", max_videos = 5L)
}
}
