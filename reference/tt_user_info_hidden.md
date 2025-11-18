# Get infos about a user from the hidden API

![\[Works on: Unofficial API\]](figures/api-unofficial.svg)

Access the publicly available information about a user.

## Usage

``` r
tt_user_info_hidden(username, parse = TRUE)
```

## Arguments

- username:

  A URL to a video or username.

- parse:

  Whether to parse the data into a data.frame (set to FALSE to get the
  full list).

## Value

A data.frame or list of user info.

## Examples

``` r
if (FALSE) { # \dontrun{
df <- tt_user_info_hidden("https://www.tiktok.com/@fpoe_at")
} # }
```
