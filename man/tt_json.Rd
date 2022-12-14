% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/traktok.R
\name{tt_json}
\alias{tt_json}
\title{Get json file from a TikTok URL}
\usage{
tt_json(url, cookiefile = NULL)
}
\arguments{
\item{url}{a URL to a TikTok video or account}

\item{cookiefile}{path to your cookiefile. Default is to request a new one
from TikTok.com and place it in the location returned by
\code{tools::R_user_dir("traktok", "config")} and set the option cookiefile
to this location.}
}
\description{
Get json file from a TikTok URL
}
