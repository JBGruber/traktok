
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
#> 1 6584647400055…  1.53e9      14 #MakeE… US       393200    5276   34000 3500000
#> 2 6584647400055…  1.53e9      14 #MakeE… US       393200    5276   34000 3500000
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
#>  ...waiting 3.4 seconds
#> Getting comments for video 6584647400055377158...
#>  ...retrieving comments 0+
#>  ...waiting 0.3 seconds
#> # A tibble: 100 × 8
#>    comment…¹ comme…² comment_create_time comme…³ video…⁴ user_id user_…⁵ user_…⁶
#>    <chr>     <chr>   <dttm>                <int> <chr>   <chr>   <chr>   <chr>  
#>  1 16078623… bring … 2018-08-04 10:03:18    6559 https:… 192652… josie<3 "15"   
#>  2 16075803… Honest… 2018-08-01 07:21:22    4773 https:… 190023… gabby   ""     
#>  3 16076610… Who el… 2018-08-02 04:43:41    5189 https:… 137403… Sam     "you’r…
#>  4 16076240… I’m so… 2018-08-01 18:55:27    4698 https:… 698813… <3      ""     
#>  5 16076299… Tomorr… 2018-08-01 20:30:28    4402 https:… 101389… rapids… "posti…
#>  6 16079175… Ughhh … 2018-08-05 00:41:43    3225 https:… 654478… Bye     ""     
#>  7 16077433… :( bri… 2018-08-03 02:32:59    3082 https:… 269099… Ary     ""     
#>  8 16075941… It’s t… 2018-08-01 11:01:08    2700 https:… 9579681 Erick … "🇵🇭🇺🇸\…
#>  9 16075812… Omg I … 2018-08-01 07:36:03    2433 https:… 280746… Anneli… "Oh he…
#> 10 16077413… musica… 2018-08-03 02:00:40    2672 https:… 244550… lizzie… "snap …
#> # … with 90 more rows, and abbreviated variable names ¹​comment_id,
#> #   ²​comment_text, ³​comment_diggcount, ⁴​video_url, ⁵​user_nickname,
#> #   ⁶​user_signature
```

### User accounts

``` r
tt_user_videos("https://www.tiktok.com/@tiktok")
#> Getting user videos from ...
#>  ...waiting 2.9 seconds
#> # A tibble: 30 × 2
#>    user_id `video_urls <- ...`                                     
#>    <chr>   <chr>                                                   
#>  1 tiktok  https://www.tiktok.com/@tiktok/video/7156386170123963691
#>  2 tiktok  https://www.tiktok.com/@tiktok/video/7156280167344688426
#>  3 tiktok  https://www.tiktok.com/@tiktok/video/7156015329771162926
#>  4 tiktok  https://www.tiktok.com/@tiktok/video/7155922851088829739
#>  5 tiktok  https://www.tiktok.com/@tiktok/video/7154462247560203566
#>  6 tiktok  https://www.tiktok.com/@tiktok/video/7153692206270778670
#>  7 tiktok  https://www.tiktok.com/@tiktok/video/7153312158837804334
#>  8 tiktok  https://www.tiktok.com/@tiktok/video/7152988552224148779
#>  9 tiktok  https://www.tiktok.com/@tiktok/video/7152957403066158378
#> 10 tiktok  https://www.tiktok.com/@tiktok/video/7151807169850051883
#> # … with 20 more rows
```

### Json data

``` r
video_json <- tt_json("https://www.tiktok.com/@tiktok/video/7106594312292453675?is_copy_url=1&is_from_webapp=v1")
user_json <- tt_json("https://www.tiktok.com/@tiktok")
```
