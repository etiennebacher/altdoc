# altdoc

[![R-CMD-check](https://github.com/etiennebacher/altdoc/workflows/R-CMD-check/badge.svg)](https://github.com/etiennebacher/altdoc/actions)

The goal of `altdoc` is to facilitate the use of documentation generators as alternatives to `pkgdown` websites (hence the *alt* in `altdoc`). For now, it provides helper functions to use [`docute`](https://docute.org/) and [`docsify`](https://docsify.js.org/#/). 

### Installation

This package is only available in development version for now:
```r
## install.packages("remotes")
remotes::install_github("etiennebacher/altdoc")
```

### Features

The purpose of this package is to make it easy and fast to use documentation generators. Its features include:

* automatic import of core files to use `docute` or `docsify`

* automatic generation of Changelog and Code of Conduct sections

* automatic creation of function reference

* links towards your package's repo

* `preview()` function to display the site in RStudio Viewer pane.
