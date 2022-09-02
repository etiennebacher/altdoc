<div align="center">

<h1> altdoc </h1>

<img src="https://github.com/etiennebacher/altdoc/workflows/R-CMD-check/badge.svg">
<img src="https://codecov.io/gh/etiennebacher/altdoc/branch/master/graph/badge.svg">
<img src="https://img.shields.io/badge/license-MIT-blue">
<a href = "https://altdoc.etiennebacher.com/#/" target = "_blank"><img src="https://img.shields.io/static/v1?label=Website&message=Visit&color=blue"></a>
  
</div>

The goal of `altdoc` is to facilitate the use of documentation generators as alternatives to `pkgdown` websites (hence the *alt* in `altdoc`). For now, it provides helper functions to use [docute](https://docute.org/), [docsify](https://docsify.js.org/#/), and [mkdocs](https://www.mkdocs.org/). 

## Installation

You can install the CRAN version:
```r
install.packages("altdoc")
```

You can also install the development version to have the latest bug fixes:
```r
# install.packages("remotes")
remotes::install_github("etiennebacher/altdoc")
```

## Features

**What this package can do:**

* automatically import core files to use `docute`, `docsify`, or `mkdocs`

* automatically generate Changelog and Code of Conduct sections

* automatically create function reference

* link towards your package's repo

* preview the site in RStudio Viewer pane


**Experimental feature (feedback needed):**

* automatically import vignettes, render them to Markdown, and add them to the 
sidebar or navbar. *This feature requires `rmarkdown` version 2.15 or higher*.
More details in the section "Get started" on the website.


## Functions

Main functions:

* `use_*()` to create the documentation with `docute`, `docsify` or `mkdocs`
* `preview()` to show the site
* `update_docs()` 


## More

More details on the package and the deployment are available on the [website](https://altdoc.etiennebacher.com/#/). 

Options for each site generator can be found on their own website:

* [Docute](https://docute.org/)

* [Docsify](https://docsify.js.org/)

* [Mkdocs](https://www.mkdocs.org/) ([Material for Mkdocs](https://squidfunk.github.io/mkdocs-material/))

