
<!-- README.md is generated from README.Rmd. Please edit that file -->

# traktok

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/JBGruber/traktok/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/JBGruber/traktok/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/JBGruber/traktok/branch/main/graph/badge.svg)](https://codecov.io/gh/JBGruber/traktok?branch=main)
<!-- badges: end -->

## Feature overview

| Description                 | Shorthand        | Research API       | Hidden API              |
|:----------------------------|:-----------------|:-------------------|:------------------------|
| search videos               | tt_search        | tt_search_api      | tt_search_hidden        |
| get video detail (+file)    | tt_videos        | \-                 | tt_videos_hidden        |
| get user videos             | tt_user_videos   | tt_user_videos_api | \-                      |
| get comments under a video  | tt_comments      | tt_comments_api    | \-                      |
| get who follows a user      | tt_get_follower  | \-                 | tt_get_follower_hidden  |
| get who a user is following | tt_get_following | \-                 | tt_get_following_hidden |
| get raw video data          | \-               | \-                 | tt_request_hidden       |
| authenticate a session      | \-               | auth_research      | auth_hidden             |

The goal of traktok is to provide easy access to TikTok data. This
package one started as an R port of Deen Freelon’s
[Pyktok](https://github.com/dfreelon/pyktok) Python module (though it is
a complete rewrite without Python dependencies). It now covers functions
from the secret hidden API that TikTok is using to show/search/play
videos on their Website and the official [Research
API](https://developers.tiktok.com/products/research-api/). Since the
Research API misses some important features (and since not everyone has
access to it) it can often make sense to still use the hidden API that
mocks requests from a browser. However, an important disclaimer for the
hidden API applies:

> This program may stop working suddenly if TikTok changes how it stores
> its data ([see Freelon,
> 2018](https://osf.io/preprints/socarxiv/56f4q/)).

## Installation

You can install the development version of traktok from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("JBGruber/traktok")
```
