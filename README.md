
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
- [Download all available video comments](#comments)
- [Download up to 30 most recent user video URLs](#user-accounts)
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

Pyktok uses the module
[browser_cookie3](https://github.com/borisbabic/browser_cookie3) to
directly access the cookies saved in your browser. Such an
infrastructure does not exists, to my knowledge, in `R`. Instead, you
can export the necessary cookies from your browser using a browser
extension (after visiting TikTok.com at least once). I can recommend
[“Get
cookies.txt”](https://chrome.google.com/webstore/detail/get-cookiestxt/bgaddhkoddajcdgocldbbfleckgcbcid)
for Chromium based browsers or
[“cookies.txt”](https://addons.mozilla.org/en-US/firefox/addon/cookies-txt/)
for Firefox.

![](man/figures/cookies.png)

Once you’ve saved this file, you can either provide the path to it in
every function, save it in your working directory or set the respective
option like this:

``` r
options(cookiefile = "path/to/tiktok.com_cookies.txt")
```

To TikTok, this will make it look as if `traktok` requests come from
your ordinary browser. If you experience issues, you can try to repeat
these steps to get a fresh cookie file.

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
#> 1 6584647400055…  1.53e9      14 #MakeE… US       392800    5261   34300 3500000
#> 2 6584647400055…  1.53e9      14 #MakeE… US       392800    5261   34300 3500000
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
tt_videos(example_urls, save_video = FALSE)
#> Getting video 6584647400055377158
#> Getting video 6584647400055377158
#> # A tibble: 2 × 19
#>   video_id       video…¹ video…² video…³ video…⁴ video…⁵ video…⁶ video…⁷ video…⁸
#>   <chr>            <dbl>   <int> <chr>   <chr>     <int>   <int>   <int>   <int>
#> 1 6584647400055…  1.53e9      14 #MakeE… US       392800    5261   34300 3500000
#> 2 6584647400055…  1.53e9      14 #MakeE… US       392800    5261   34300 3500000
#> # … with 10 more variables: video_description <chr>, video_is_ad <lgl>,
#> #   video_fn <chr>, author_username <chr>, author_name <lgl>,
#> #   author_followercount <int>, author_followingcount <int>,
#> #   author_heartcount <int>, author_videocount <int>, author_diggcount <int>,
#> #   and abbreviated variable names ¹​video_timestamp, ²​video_length,
#> #   ³​video_title, ⁴​video_locationcreated, ⁵​video_diggcount, ⁶​video_sharecount,
#> #   ⁷​video_commentcount, ⁸​video_playcount
```

### User accounts

``` r
tt_user_videos("https://www.tiktok.com/@tiktok")
#> Getting user videos from ...
#>  ...waiting 0.9 seconds
#> # A tibble: 30 × 2
#>    user_id `video_urls <- ...`                                     
#>    <chr>   <chr>                                                   
#>  1 tiktok  https://www.tiktok.com/@tiktok/video/7138498200901553454
#>  2 tiktok  https://www.tiktok.com/@tiktok/video/7138179998615227690
#>  3 tiktok  https://www.tiktok.com/@tiktok/video/7138154231256730922
#>  4 tiktok  https://www.tiktok.com/@tiktok/video/7137824586028272942
#>  5 tiktok  https://www.tiktok.com/@tiktok/video/7137427772913290538
#>  6 tiktok  https://www.tiktok.com/@tiktok/video/7137409975189687598
#>  7 tiktok  https://www.tiktok.com/@tiktok/video/7137396335946353966
#>  8 tiktok  https://www.tiktok.com/@tiktok/video/7136319934375873838
#>  9 tiktok  https://www.tiktok.com/@tiktok/video/7136224506342853931
#> 10 tiktok  https://www.tiktok.com/@tiktok/video/7135966049140264238
#> # … with 20 more rows
```

### Json data

``` r
video_json <- tt_json("https://www.tiktok.com/@tiktok/video/7106594312292453675?is_copy_url=1&is_from_webapp=v1")
user_json <- tt_json("https://www.tiktok.com/@tiktok")
```
