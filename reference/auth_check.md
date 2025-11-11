# Check whether you are authenticated

![\[Works on: Both\]](figures/api-both.svg)

Check if the necessary token or cookies are stored on your computer
already. By default, the function checks for the authentication of the
research and hidden API. To learn how you can authenticate, look at the
vignette for the research
([`vignette("research-api", package = "traktok")`](https://jbgruber.github.io/traktok/articles/research-api.md))
or hidden
([`vignette("unofficial-api", package = "traktok")`](https://jbgruber.github.io/traktok/articles/unofficial-api.md))
API.

## Usage

``` r
auth_check(research = TRUE, hidden = TRUE, silent = FALSE)
```

## Arguments

- research, hidden:

  turn check on/off for the research or hidden API.

- silent:

  only return if check(s) were successful, no status on the screen

## Value

logical vector (invisible)

## Examples

``` r
auth_check()
#> Error in cookiemonster::get_cookies("^(www.)*tiktok.com") : 
#>   The directory ~/.cache/r_cookies does not contain any cookies yet. Use
#> `add_cookies()` to store cookies for a website (see `vignette("cookies",
#> "cookiemonster")` for details).
```
