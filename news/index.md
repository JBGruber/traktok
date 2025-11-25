# Changelog

## traktok (development version)

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
