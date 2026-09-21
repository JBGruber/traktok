# traktok (development version)

* `tt_search_api()` no longer limits searches to 30 days: longer time spans are automatically split into consecutive 30 day windows (the maximum the API allows per request) and the results are combined. `max_pages` applies per window. The returned object (and `last_query()`) now also carries `start_date` and `end_date` attributes of the last queried window, so that interrupted searches can be picked back up. `tt_user_videos_api()` uses this internally now.
* `last_query()` now always attaches the `search_id` and `cursor` attributes (previously they were dropped when the cached videos could be parsed).
* the `cursor` attribute of `tt_search_api()` results now reflects the last page received (it was one page behind when `max_pages > 1`).

# traktok 0.1.0

* first CRAN release

# traktok 0.0.8.9000

* revive tt_search_hidden (#14; thanks for th hint @michaelgoodier!)

# traktok 0.0.7.9000

* overhauls tt_user_info_hidden (some breaking changes as names in the output have changed)

# traktok 0.0.6.9000

* adds access to additional Research API endpoints (tt_user_liked_videos_api, tt_user_pinned_videos_api, tt_user_follower_api, tt_user_following_api, tt_user_reposted_api, and tt_playlist_info_api)
* tt_videos_hidden now supports Video IDs
* adds tt_user_videos_api, a wrapper around tt_search_api to query user videos

# traktok 0.0.5.9000

* adds experimental tt_user_videos_hidden and tt_user_info_hidden that rely on chromote
