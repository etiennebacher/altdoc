# altdoc


[![R-CMD-check](https://github.com/etiennebacher/altdoc/workflows/R-CMD-check/badge.svg)](https://github.com/etiennebacher/altdoc/actions)

The goal of `altdoc` is to facilitate the use of documentation generators as alternatives to `pkgdown` websites (hence the *alt* in `altdoc`). For now, it provides helper functions to use [`docute`](https://docute.org/) and [`docsify`](https://docsify.js.org/#/). 

## Installation

This package is only available in development version for now:
```r
# install.packages("remotes")
remotes::install_github("etiennebacher/altdoc")
```

## Features

What this package can do:

* automatically import of core files to use `docute` or `docsify`

* automatically generation of Changelog and Code of Conduct sections

* automatically creation of function reference

* link towards your package's repo

* preview the site in RStudio Viewer pane

What this package cannot do: 

* deal with vignettes, you will have to import them and transform them so that they create Markdown files instead of HTML.


## Functions

Main functions:

* `use_*()` to create the documentation with `docute` or `docsify`
* `preview()` to show the site
