
<!-- README.md is generated from README.Rmd. Please edit that file -->

# traktok <img src="man/figures/logo.png" align="right" height="138" alt="" />

<!-- badges: start -->

[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-green.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![R-CMD-check](https://github.com/JBGruber/traktok/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/JBGruber/traktok/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/JBGruber/traktok/branch/main/graph/badge.svg)](https://app.codecov.io/gh/JBGruber/traktok?branch=main)
[![arXiv:10.48550/arXiv.2404.07654](https://img.shields.io/badge/DOI-arXiv.2404.07654-B31B1B?logo=arxiv)](https://doi.org/10.48550/arXiv.2404.07654)
[![say-thanks](https://img.shields.io/badge/Say%20Thanks-!-1EAEDB.svg)](https://saythanks.io/to/JBGruber)
<!-- badges: end -->

## Feature overview

| Description | Shorthand | Research API | Hidden API |
|:---|:---|:---|:---|
| search videos | [tt_search](https://jbgruber.github.io/traktok/reference/tt_search.html) | [tt_search_api](https://jbgruber.github.io/traktok/reference/tt_search_api.html) | [tt_search_hidden](https://jbgruber.github.io/traktok/reference/tt_search_hidden.html) |
| get video detail (+file) | [tt_videos](https://jbgruber.github.io/traktok/reference/tt_videos.html) | \- | [tt_videos_hidden](https://jbgruber.github.io/traktok/reference/tt_videos_hidden.html) |
| get user videos | [tt_user_videos](https://jbgruber.github.io/traktok/reference/tt_user_videos.html) | [tt_user_videos_api](https://jbgruber.github.io/traktok/reference/tt_user_videos_api.html) | [tt_user_videos_hidden](https://jbgruber.github.io/traktok/reference/tt_user_videos_hidden.html) |
| get user info | [tt_user_info](https://jbgruber.github.io/traktok/reference/tt_user_info.html) | [tt_user_info_api](https://jbgruber.github.io/traktok/reference/tt_user_info_api.html) | [tt_user_info_hidden](https://jbgruber.github.io/traktok/reference/tt_user_info_hidden.html) |
| get comments under a video | [tt_comments](https://jbgruber.github.io/traktok/reference/tt_comments.html) | [tt_comments_api](https://jbgruber.github.io/traktok/reference/tt_comments_api.html) | \- |
| get who follows a user | [tt_get_follower](https://jbgruber.github.io/traktok/reference/tt_get_follower.html) | [tt_user_follower_api](https://jbgruber.github.io/traktok/reference/tt_user_follower_api.html) | [tt_get_follower_hidden](https://jbgruber.github.io/traktok/reference/tt_get_follower_hidden.html) |
| get who a user is following | [tt_get_following](https://jbgruber.github.io/traktok/reference/tt_get_following.html) | [tt_user_following_api](https://jbgruber.github.io/traktok/reference/tt_user_following_api.html) | [tt_get_following_hidden](https://jbgruber.github.io/traktok/reference/tt_get_following_hidden.html) |
| get videos a user liked | [tt_get_liked](https://jbgruber.github.io/traktok/reference/tt_get_liked.html) | [tt_user_liked_videos_api](https://jbgruber.github.io/traktok/reference/tt_user_liked_videos_api.html) | \- |
| get videos a user reposted | [tt_get_reposted](https://jbgruber.github.io/traktok/reference/tt_get_reposted.html) | [tt_user_reposted_api](https://jbgruber.github.io/traktok/reference/tt_user_reposted_api.html) | \- |
| get pinned videos of users | [tt_get_pinned](https://jbgruber.github.io/traktok/reference/tt_get_pinned.html) | [tt_user_pinned_videos_api](https://jbgruber.github.io/traktok/reference/tt_user_pinned_videos_api.html) | \- |
| get videos in a playlist | [tt_playlist](https://jbgruber.github.io/traktok/reference/tt_playlist.html) | [tt_playlist_api](https://jbgruber.github.io/traktok/reference/tt_playlist_api.html) | \- |
| build query objects | [query](https://jbgruber.github.io/traktok/reference/query.html) | ([query_and](https://jbgruber.github.io/traktok/reference/query_and.html), [query_or](https://jbgruber.github.io/traktok/reference/query_or.html), [query_not](https://jbgruber.github.io/traktok/reference/query_not.html)) | \- |
| get raw post data | \- | \- | [tt_request_hidden](https://jbgruber.github.io/traktok/reference/tt_request_hidden.html) |
| retrieve last query/results | [last_query](https://jbgruber.github.io/traktok/reference/last_query.html), [last_comments](https://jbgruber.github.io/traktok/reference/last_comments.html) | \- | \- |
| authenticate a session | \- | [auth_research](https://jbgruber.github.io/traktok/reference/auth_research.html) | [auth_hidden](https://jbgruber.github.io/traktok/reference/auth_hidden.html) |

The goal of traktok is to provide easy access to TikTok data. This
package once started as an R port of Deen Freelon’s
[Pyktok](https://github.com/dfreelon/pyktok) Python module (though it is
a complete rewrite without Python dependencies). It now covers functions
from the secret hidden API that TikTok is using to show/search/play
videos on their Website and the official [Research
API](https://developers.tiktok.com/products/research-api/). To learn
about both access pathways, you should check out the [Research
API](https://jbgruber.github.io/traktok/articles/research-api.html) and
[Unofficial
API](https://jbgruber.github.io/traktok/articles/unofficial-api.html)
vignettes. Since the Research API misses some important features (and
since not everyone has access to it) it can often make sense to still
use the hidden API that mocks requests from a browser. However, an
important disclaimer for the hidden API applies:

> This program may stop working suddenly if TikTok changes how it stores
> its data ([see Freelon,
> 2018](https://osf.io/preprints/socarxiv/56f4q/)).

However, the last times, it was fixed rather quickly (e.g., \#12).

## Installation

You can install the development version of traktok from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("JBGruber/traktok")
```

## In Research

The research papers and projects below have used traktok to gather their
data:

1.  Hohner, J., Kakavand, A., & Rothut, S. (2024). Analyzing Radical
    Visuals at Scale: How Far-Right Groups Mobilize on TikTok. Journal
    of Digital Social Research, 6(1), 10–30.
    <https://doi.org/10.33621/jdsr.v6i1.200>
2.  Wirz, D. S., Zai, F., Vogler, D., Urman, A., & Eisenegger, M.
    (2023). Die Qualität von Schweizer Medien auf Instagram und TikTok.
    <https://doi.org/10.5167/UZH-238605>
3.  Giglietto, F. (2024). Dashboard: TikTok Coordinated Sharing Network.
    <https://fabiogiglietto.github.io/tiktok_csbn/tt_viz.html>
4.  Widholm, A., Ekman, M., & Larsson, A. O. (2024). A Right-Wing Wave
    on TikTok? Ideological Orientations, Platform Features, and User
    Engagement During the Early 2022 Election Campaign in Sweden. Social
    Media + Society, 10(3). <https://doi.org/10.1177/20563051241269266>
5.  Blakeman, J. R., Carpenter, N., & Calderon, S. J. (2025). Describing
    acute coronary syndrome symptom information on social media
    platforms. Heart & Lung, 70, 112–121.
    <https://doi.org/10.1016/j.hrtlng.2024.11.021>
6.  Donaldson, S. I., La Capria, K., DeJesus, A., Ganz, O., Delnevo, C.
    D., & Allem, J.-P. (2025). Describing ZYN-Related Content on TikTok:
    Content Analysis. Nicotine and Tobacco Research, ntaf016.
    <https://doi.org/10.1093/ntr/ntaf016>
7.  Peterson-Salahuddin, C. (2025). Teachable moments: TikTok social
    drama as a site of Black feminist intellectual production.
    Information, Communication & Society, 28(3), 417–434.
    <https://doi.org/10.1080/1369118X.2024.2388093>
8.  Wirz, D. S., & Zai, F. (2025). Infotainment on Social Media: How
    News Companies Combine Information and Entertainment in News Stories
    on Instagram and TikTok. Digital Journalism, 13(7), 1249–1270.
    <https://doi.org/10.1080/21670811.2025.2464062>

If you have used traktok in your research paper or project, please
extend this list through a Pull Request or create an issue And ideally,
also cite the package/paper:

``` bib
To cite traktok in publications use:

  Gruber, Johannes B. (2025). traktok — Making TikTok Data
  Accessible for Research. SocArXiv.
  https://doi.org/10.31235/osf.io/xrgc6_v1

A BibTeX entry for LaTeX users is

  @Article{,
    title = {traktok — Making TikTok Data Accessible for Research},
    author = {Johannes B. Gruber},
    year = {2025},
    month = {jun},
    journal = {SocArXiv},
    doi = {10.31235/osf.io/xrgc6_v1},
    url = {https://osf.io/xrgc6_v1},
  }
```
