
<!-- README.md is generated from README.Rmd. Please edit that file -->

# traktok

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/JBGruber/traktok/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/JBGruber/traktok/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/JBGruber/traktok/branch/main/graph/badge.svg)](https://codecov.io/gh/JBGruber/traktok?branch=main)
[![Twitter](https://img.shields.io/twitter/url/https/twitter.com/JohannesBGruber.svg?style=social&label=Follow%20%40JohannesBGruber)](https://twitter.com/JohannesBGruber)
<!-- badges: end -->

The goal of traktok is to provide easy access to TikTok data. This
package is an R port of Deen Freelon’s
[Pyktok](https://github.com/dfreelon/pyktok) Python module. It can

- [Download TikTok videos](#videos)
- [Download video metadata](#videos)
- ~~[Download all available video comments](#comments)~~ (see \#5)
- [Download up to 30 most recent user video URLs](#user-accounts)
- ~~[Search for videos by hashtag](#search-for-hashtags)~~ (see \#4)
- [Download full TikTok JSON data objects (in case you want to extract
  data from parts of the object not included in the above
  functions)](#json-data)

The same disclaimer as for Pyktok applies:

> This program may stop working suddenly if TikTok changes how it stores
> its data ([see Freelon,
> 2018](https://osf.io/preprints/socarxiv/56f4q/)).

I check automatically every day if the approach is still working.
Current status:
[![Still-Working?](https://github.com/JBGruber/traktok/actions/workflows/still-working.yaml/badge.svg)](https://github.com/JBGruber/traktok/actions/workflows/still-working.yaml)

## Installation

You can install the development version of traktok from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("JBGruber/traktok")
```

## Usage

### Authentication

Authentication for `traktok` happens automatically the first time you
run a function. To TikTok, this will make it look as if `traktok`
requests come from your ordinary browser. `traktok` will save a cookie
file in the location returned by
`tools::R_user_dir("traktok", "config")`. If you ever run into problems
due to an expired cookie, you might want to delete the files in this
folder to get a fresh start.

### Videos

You can get data from videos like this:

``` r
library(traktok)
example_urls <- c(
  "https://www.tiktok.com/@tiktok/video/6584647400055377158?is_copy_url=1&is_from_webapp=v1",
  "https://www.tiktok.com/@tiktok/video/6584647400055377158?is_copy_url=1&is_from_webapp=v1"
)
tt_videos(example_urls, save_video = FALSE)
#> Getting video 6584647400055377158
#> Getting video 6584647400055377158
#> # A tibble: 2 × 19
#>   video_id       video…¹ video…² video…³ video…⁴ video…⁵ video…⁶ video…⁷ video…⁸
#>   <chr>            <dbl>   <int> <chr>   <chr>     <int>   <int>   <int>   <int>
#> 1 6584647400055…  1.53e9      14 #MakeE… US       393400    5278   33900 3500000
#> 2 6584647400055…  1.53e9      14 #MakeE… US       393400    5278   33900 3500000
#> # … with 10 more variables: video_description <chr>, video_is_ad <lgl>,
#> #   video_fn <chr>, author_username <chr>, author_name <lgl>,
#> #   author_followercount <int>, author_followingcount <int>,
#> #   author_heartcount <int>, author_videocount <int>, author_diggcount <int>,
#> #   and abbreviated variable names ¹​video_timestamp, ²​video_length,
#> #   ³​video_title, ⁴​video_locationcreated, ⁵​video_diggcount, ⁶​video_sharecount,
#> #   ⁷​video_commentcount, ⁸​video_playcount
```

You can download the videos by either setting `save_video` to `TRUE` or
by exporting the URLs and downloading them with an external tool.

### Comments

``` r
tt_comments(example_urls, max_comments = 50L)
#> Getting comments for video 6584647400055377158...
#>  ...retrieving comments 0+
#> Error in resp_body_raw(resp) : Can not retrieve empty body
#>  ...waiting 1 seconds
#> Getting comments for video 6584647400055377158...
#>  ...retrieving comments 0+
#> Error in resp_body_raw(resp) : Can not retrieve empty body
#>  ...waiting 2 seconds
#> # A tibble: 0 × 0
```

### User accounts

``` r
tt_user_videos("https://www.tiktok.com/@tiktok")
#> Getting user videos from ...
#>  ...waiting 1.5 seconds
#> # A tibble: 30 × 2
#>    user_id `video_urls <- ...`                                     
#>    <chr>   <chr>                                                   
#>  1 tiktok  https://www.tiktok.com/@tiktok/video/7165922997524516138
#>  2 tiktok  https://www.tiktok.com/@tiktok/video/7165648964333718827
#>  3 tiktok  https://www.tiktok.com/@tiktok/video/7164906805590527275
#>  4 tiktok  https://www.tiktok.com/@tiktok/video/7164830301753986350
#>  5 tiktok  https://www.tiktok.com/@tiktok/video/7164471429289790763
#>  6 tiktok  https://www.tiktok.com/@tiktok/video/7164102890544450859
#>  7 tiktok  https://www.tiktok.com/@tiktok/video/7162562810231246122
#>  8 tiktok  https://www.tiktok.com/@tiktok/video/7161881635972123950
#>  9 tiktok  https://www.tiktok.com/@tiktok/video/7161465157351247147
#> 10 tiktok  https://www.tiktok.com/@tiktok/video/7161100682450259242
#> # … with 20 more rows
```

### Search for Hashtags

``` r
tt_search_hashtag("rstats", max_videos = 15L)
#> 0 videos found for rstats
#> # A tibble: 15 × 17
#>    video_id  video_timestamp     video…¹ video…² video…³ video…⁴ video…⁵ video…⁶
#>    <chr>     <dttm>              <chr>     <int> <chr>     <int>   <int>   <int>
#>  1 70071974… 2021-09-12 23:44:54 https:…      11 "vean …   16200     157     106
#>  2 69930983… 2021-08-05 23:53:10 https:…      28 "#Mach…   12100     271       0
#>  3 71299257… 2022-08-09 17:13:15 https:…      71 "Data …    8099     222     116
#>  4 71569523… 2022-10-21 13:10:48 https:…      48 "#NBA …    7669      13      56
#>  5 70085355… 2021-09-16 14:17:32 https:…       6 "i’m n…    2325     180      27
#>  6 70067232… 2021-09-11 17:04:49 https:…      10 "#taco…    2263      11      40
#>  7 70053274… 2021-09-07 22:48:14 https:…      15 "Reply…    2263     138      12
#>  8 70081900… 2021-09-15 15:56:44 https:…      15 "Reply…    2187     213      16
#>  9 70030125… 2021-09-01 17:05:29 https:…      15 "Reply…    1322      12     144
#> 10 70153977… 2021-10-05 02:06:19 https:…     180 "Reply…     958      94      30
#> 11 70075221… 2021-09-13 20:44:58 https:…      59 "Reply…     892      13      41
#> 12 71611406… 2022-11-01 20:03:25 https:…      13 "#codi…     829      10      20
#> 13 70038738… 2021-09-04 00:47:42 https:…      15 "Answe…     513      42       4
#> 14 70042142… 2021-09-04 22:48:33 https:…       8 "#Apre…     482      12      16
#> 15 70038136… 2021-09-03 20:53:59 https:…      15 "Reply…     445      15       8
#> # … with 9 more variables: video_playcount <int>, video_description <chr>,
#> #   video_is_ad <lgl>, author_name <chr>, author_followercount <int>,
#> #   author_followingcount <int>, author_heartcount <int>,
#> #   author_videocount <int>, author_diggcount <int>, and abbreviated variable
#> #   names ¹​video_url, ²​video_length, ³​video_title, ⁴​video_diggcount,
#> #   ⁵​video_sharecount, ⁶​video_commentcount
```

### Json data

``` r
video_json <- tt_json("https://www.tiktok.com/@tiktok/video/7106594312292453675?is_copy_url=1&is_from_webapp=v1")
user_json <- tt_json("https://www.tiktok.com/@tiktok")
```
