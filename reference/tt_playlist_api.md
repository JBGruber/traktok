# Lookup TikTok playlist using the research API

![\[Works on: Research API\]](figures/api-research.svg)

## Usage

``` r
tt_playlist_api(playlist_id, verbose = interactive(), token = NULL)

tt_playlist(playlist_id, verbose = interactive(), token = NULL)
```

## Arguments

- playlist_id:

  playlist ID or URL to a playlist.

- verbose:

  should the function print status updates to the screen?

- token:

  The authentication token (usually supplied automatically after running
  [auth_research](https://jbgruber.github.io/traktok/reference/auth_research.md)
  once).

## Value

A data.frame video metadata.
