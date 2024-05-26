---
title: 'rollama: An R package for using generative large language models through Ollama'
tags:
  - R
  - TikTok
  - social media
  - data access
  -webscraping
authors:
  - name: Johannes B. Gruber
    orcid: 0000-0001-9177-1772
    corresponding: true # (This is how to denote the corresponding author)
    equal-contrib: false
    affiliation: 1
affiliations:
 - name: Vrije Universiteit Amsterdam
   index: 1
date: 18 March 2024
bibliography: paper.bib
---

# Summary

`traktok` provides access to data from TikTok.
It does so by combining a wrapper for the TikTok Research API, as well as using requests to the TikTok servers that mimic the behaviour of a browser.
Users can choose to employ either one of these paths to access data, depending on their access and research questions.


# Statement of need

Work that cites `traktok`

# Legal and Ethical Issues

`traktok` does not provide any capabilities to users that they would otherwise not have.
To access the Research API, researchers must first apply for access 
To access the unofficial API users employ their regular account.
Users essentially mimic a browser, which means that `traktok` inherits only what the company allows users to do anyway.
Depending on the purpose of data aquiration and jurisdiction, this might still be an issue.
Research purposes are generally covered by fair use and as Deelon writes, whether TikTok takes legal actions against a researchers is yet another question.
- don't collect data you don't need
- do not expose or shame users, honor the fact that they did not produce the data for you

# Background: The two APIs

# Usage

The R-package `traktok` can be installed from CRAN (the Comprehensive R Archive Network):

```r
install.packages("traktok")
```

or from GitHub using remotes:

``` r
# install.packages("remotes")
remotes::install_github("JBGruber/traktok")
```

After that, the user should check whether the `Ollama` API is up and running.

``` r
library(traktok)

```


## Analyses with the Research API


## Analyses with the Unofficial API

# Learning material

# References
