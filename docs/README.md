<div align="center">

<h1> altdoc </h1>

[![R-CMD-check](https://github.com/etiennebacher/altdoc/workflows/R-CMD-check/badge.svg)](https://github.com/etiennebacher/altdoc/actions) ![](https://img.shields.io/badge/license-MIT-blue)

</div>

The goal of `altdoc` is to facilitate the use of documentation generators as alternatives to `pkgdown` websites (hence the *alt* in `altdoc`). For now, it provides helper functions to use [`docute`](https://docute.org/) and [`docsify`](https://docsify.js.org/#/). 

## Installation

This package is only available in development version for now:
```r
# install.packages("remotes")
remotes::install_github("etiennebacher/altdoc")
```

## Features

What this package can do:

* automatically import core files to use `docute` or `docsify`

* automatically generate Changelog and Code of Conduct sections

* automatically create function reference

* link towards your package's repo

* preview the site in RStudio Viewer pane

What this package cannot do: 

* deal with vignettes. If you already have some, you will have to import them and transform them so that they create Markdown files instead of HTML.


## Functions

Main functions:

* `use_*()` to create the documentation with `docute` or `docsify`
* `preview()` to show the site
* `update_docs()` 


## More

More details on the package and the deployment are available on the [website](https://altdoc.etiennebacher.com/#/). 

Options for each site generator can be found on their own website:

* [https://docute.org/](https://docute.org/)

* [https://docsify.js.org/](https://docsify.js.org/)

