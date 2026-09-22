# Changelog

## traktok (development version)

- new
  [`tt_slideshow_hidden()`](https://jbgruber.github.io/traktok/reference/tt_slideshow_hidden.md)
  collects metadata, images and music of slideshows (photo posts), for
  which TikTok does not include data in the page source. It opens each
  post in a headless browser (needs the `chromote` package) and captures
  the post data the site requests itself
  ([\#23](https://github.com/JBGruber/traktok/issues/23)).
- [`tt_videos_hidden()`](https://jbgruber.github.io/traktok/reference/tt_videos_hidden.md)
  (and
  [`tt_videos()`](https://jbgruber.github.io/traktok/reference/tt_videos_hidden.md))
  now recognise slideshows among the URLs and gained the argument
  `slideshows`: after all other posts are collected, it asks whether to
  collect the slideshows with
  [`tt_slideshow_hidden()`](https://jbgruber.github.io/traktok/reference/tt_slideshow_hidden.md)
  (`"ask"`, the default in interactive sessions), does so directly
  (`TRUE`) or leaves their rows empty with a warning (`FALSE`).
  Slideshow rows are marked with `is_slides = TRUE` either way.
- fixed
  [`tt_search_hidden()`](https://jbgruber.github.io/traktok/reference/tt_search_hidden.md)
  failing to set cookies in the browser session with recent versions of
  `cookiemonster`.
- after a captcha is solved manually, the updated cookies are now
  stored, so that later requests are less likely to hit another captcha.
- [`tt_search_api()`](https://jbgruber.github.io/traktok/reference/tt_search_api.md)
  no longer limits searches to 30 days: longer time spans are
  automatically split into consecutive 30 day windows (the maximum the
  API allows per request) and the results are combined. `max_pages`
  applies per window. The returned object (and
  [`last_query()`](https://jbgruber.github.io/traktok/reference/last_query.md))
  now also carries `start_date` and `end_date` attributes of the last
  queried window, so that interrupted searches can be picked back up.
  [`tt_user_videos_api()`](https://jbgruber.github.io/traktok/reference/tt_user_videos_api.md)
  uses this internally now.
- [`last_query()`](https://jbgruber.github.io/traktok/reference/last_query.md)
  now always attaches the `search_id` and `cursor` attributes
  (previously they were dropped when the cached videos could be parsed).
- the `cursor` attribute of
  [`tt_search_api()`](https://jbgruber.github.io/traktok/reference/tt_search_api.md)
  results now reflects the last page received (it was one page behind
  when `max_pages > 1`).

## traktok 0.1.0

CRAN release: 2025-11-24

- first CRAN release

## traktok 0.0.8.9000

- revive tt_search_hidden
  ([\#14](https://github.com/JBGruber/traktok/issues/14); thanks for th
  hint [@michaelgoodier](https://github.com/michaelgoodier)!)

## traktok 0.0.7.9000

- overhauls tt_user_info_hidden (some breaking changes as names in the
  output have changed)

## traktok 0.0.6.9000

- adds access to additional Research API endpoints
  (tt_user_liked_videos_api, tt_user_pinned_videos_api,
  tt_user_follower_api, tt_user_following_api, tt_user_reposted_api, and
  tt_playlist_info_api)
- tt_videos_hidden now supports Video IDs
- adds tt_user_videos_api, a wrapper around tt_search_api to query user
  videos

## traktok 0.0.5.9000

- adds experimental tt_user_videos_hidden and tt_user_info_hidden that
  rely on chromote
