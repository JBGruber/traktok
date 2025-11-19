# Check whether you are authenticated

![\[Works on: Both\]](figures/api-both.svg)

Check if the necessary token or cookies are stored on your computer
already. By default, the function checks for the authentication of the
research and hidden API. To learn how you can authenticate, see the
[research API
vignette](https://jbgruber.github.io/traktok/articles/research-api.html#authentication)
or [hidden API
vignette](https://jbgruber.github.io/traktok/articles/unofficial-api.html#authentication).
You can also view these locally with
[`vignette("research-api", package = "traktok")`](https://jbgruber.github.io/traktok/articles/research-api.md)
and
[`vignette("unofficial-api", package = "traktok")`](https://jbgruber.github.io/traktok/articles/unofficial-api.md).

## Usage

``` r
auth_check(research = TRUE, hidden = TRUE, silent = FALSE, fail = FALSE)
```

## Arguments

- research, hidden:

  turn check on/off for the research or hidden API.

- silent:

  only return if check(s) were successful, no status on the screen

- fail:

  fail if even basic authentication for the hidden API is missing.

## Value

logical vector (invisible)

## Examples

``` r
auth_check()
#> ✖ It looks like you are using traktok for the first time. You need to add some basic authentication for this function to work. See `?auth_check()`.

au <- auth_check()
#> ✖ It looks like you are using traktok for the first time. You need to add some basic authentication for this function to work. See `?auth_check()`.
if (isTRUE(au["research"])) {
  message("Ready to use the research API!")
}
if (isTRUE(au["hidden"])) {
  message("Ready to use all function of unofficial the API!")
}
```
