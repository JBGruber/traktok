
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

- ~~[Download TikTok videos](#videos)~~ (see
  [\#5](https://github.com/JBGruber/traktok/issues/5))
- [Download video metadata](#videos)
- ~~[Download all available video comments](#comments)~~ (see
  [\#5](https://github.com/JBGruber/traktok/issues/5))
- [Download up to 30 most recent user video URLs](#user-accounts)
- ~~[Search for videos by hashtag](#search-for-hashtags)~~
  (see[\#4](https://github.com/JBGruber/traktok/issues/4))
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

There are two ways to authentication: an automated one which gives you
anonymous cookies and a manual one which gives you user cookies.
`traktok` uses these cookies to make request appear as they come from
your ordinary browser. However, since some request require a logged in
user, the respective functions need cookies from an authenticated user.

#### Anonymous cookies

Authentication happens automatically the first time you run a function.
If you want to do this explicitly, use this function:

`{r} tt_get_cookies()`

It will guide you through the process. If you want to create multiple
cookie files, you can use the `name` argument:

`{r} tt_get_cookies(name = "cookies_new")`

#### Logged in user

Pyktok uses the module
[browser_cookie3](https://github.com/borisbabic/browser_cookie3) to
directly access the cookies saved in your browser. Such an
infrastructure does not exists, to my knowledge, in `R` (tell me if I’m
wrong!). Instead, you can export the necessary cookies from your browser
using a browser extension (after logging in at TikTok.com at least
once). I can recommend [“Get
cookies.txt”](https://chrome.google.com/webstore/detail/get-cookiestxt/bgaddhkoddajcdgocldbbfleckgcbcid)
for Chromium based browsers or
[“cookies.txt”](https://addons.mozilla.org/en-US/firefox/addon/cookies-txt/)
for Firefox.

![](vignettes/cookies.png)

Once you’ve saved this file, you read it into `traktok`, which will
store it permanently.

`{r} tt_get_cookies(x = "tiktok.com_cookies.txt")`

If you want to create multiple cookie files, you can use the `name`
argument:

`{r} tt_get_cookies(x = "tiktok.com_cookies.txt", name = "cookies_new")`

#### Multiple cookie files

`tt_get_cookies` will save a cookie file in the location returned by
`tools::R_user_dir("traktok", "config")`. Set `save = FALSE` if you want
to prevent this. Using `options(tt_cookiefile = "some\path")`, you can
change the default location. If you have, for example, multiple cookie
files in the default location:

`{r} options(tt_cookiefile = file.path(tools::R_user_dir("traktok", "config"), paste0(cookies_new, ".rds")))`

Alternatively, you can also set cookies for every function:

`{r} cookie_files <- list.files(tools::R_user_dir("traktok", "config"), full.names = TRUE) tt_videos(video_urls = "https://www.tiktok.com/@tiktok/video/6584647400055377158?is_copy_url=1&is_from_webapp=v1",           cookiefile = cookie_files[1]) tt_videos(video_urls = "https://www.tiktok.com/@tiktok/video/6584647400055377158?is_copy_url=1&is_from_webapp=v1",           cookiefile = cookie_files[2])`

If you ever run into problems due to an expired cookie, you might want
to delete the files in the default folder to get a fresh start.

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
#>   video_id video_times…¹ video…² video…³ video…⁴ video…⁵ video…⁶ video…⁷ video…⁸
#>   <chr>            <dbl> <lgl>   <lgl>   <lgl>   <lgl>   <lgl>   <lgl>   <lgl>  
#> 1 ""                  NA NA      NA      NA      NA      NA      NA      NA     
#> 2 ""                  NA NA      NA      NA      NA      NA      NA      NA     
#> # … with 10 more variables: video_description <lgl>, video_is_ad <lgl>,
#> #   video_fn <chr>, author_username <lgl>, author_name <lgl>,
#> #   author_followercount <lgl>, author_followingcount <lgl>,
#> #   author_heartcount <lgl>, author_videocount <lgl>, author_diggcount <lgl>,
#> #   and abbreviated variable names ¹​video_timestamp, ²​video_length,
#> #   ³​video_title, ⁴​video_locationcreated, ⁵​video_diggcount, ⁶​video_sharecount,
#> #   ⁷​video_commentcount, ⁸​video_playcount
```

You can download the videos by either setting `save_video` to `TRUE` or
by exporting the URLs and downloading them with an external tool.

### Comments

**Currently not working**

``` r
tt_comments(example_urls, max_comments = 50L)
#> Getting comments for video 6584647400055377158...
#>  ...retrieving comments 0+
#> Error in resp_body_raw(resp) : Can not retrieve empty body
#>  ...waiting 2.8 seconds
#> Getting comments for video 6584647400055377158...
#>  ...retrieving comments 0+
#> Error in resp_body_raw(resp) : Can not retrieve empty body
#>  ...waiting 0.3 seconds
#> # A tibble: 0 × 0
```

### User accounts

``` r
tt_user_videos("https://www.tiktok.com/@tiktok")
#> Getting user videos from ...
#>  ...waiting 0.2 seconds
#> # A tibble: 30 × 2
#>    user_id `video_urls <- ...`                                     
#>    <chr>   <chr>                                                   
#>  1 tiktok  https://www.tiktok.com/@tiktok/video/7200075941727440170
#>  2 tiktok  https://www.tiktok.com/@tiktok/video/7200073950645194026
#>  3 tiktok  https://www.tiktok.com/@tiktok/video/7200058371028962606
#>  4 tiktok  https://www.tiktok.com/@tiktok/video/7199799408270052651
#>  5 tiktok  https://www.tiktok.com/@tiktok/video/7199792050412375342
#>  6 tiktok  https://www.tiktok.com/@tiktok/video/7199773494802910506
#>  7 tiktok  https://www.tiktok.com/@tiktok/video/7199713922167934251
#>  8 tiktok  https://www.tiktok.com/@tiktok/video/7199700619102309674
#>  9 tiktok  https://www.tiktok.com/@tiktok/video/7199529679915715882
#> 10 tiktok  https://www.tiktok.com/@tiktok/video/7199433286928878894
#> # … with 20 more rows
```

### Search for Hashtags

**Currently not working**

``` r
tt_search_hashtag("rstats", max_videos = 15L)
```

### Json data

``` r
video_json <- tt_json("https://www.tiktok.com/@tiktok/video/7106594312292453675?is_copy_url=1&is_from_webapp=v1")
user_json <- tt_json("https://www.tiktok.com/@tiktok")
```
