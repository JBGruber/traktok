# Get infos about a user from the hidden API

Get infos about a user from the hidden API

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

A data.frame of user info.

## Examples

``` r
if (FALSE) { # \dontrun{
df <- tt_user_info_hidden("https://www.tiktok.com/@fpoe_at")
} # }
```
