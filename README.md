<div align="center">

<h1> altdoc </h1>

<img src="https://github.com/etiennebacher/altdoc/workflows/R-CMD-check/badge.svg">
<img src="https://codecov.io/gh/etiennebacher/altdoc/branch/master/graph/badge.svg">
<img src="https://img.shields.io/badge/license-MIT-blue">
<a href = "https://altdoc.etiennebacher.com/#/" target = "_blank"><img src="https://img.shields.io/static/v1?label=Website&message=Visit&color=blue"></a>
  
</div>

`altdoc` is a simple and powerful package to create documentation websites for `R` packages. It is a lightweight alternative to `pkgdown`, with support for many documentation generator frameworks:

* [docsify](https://docsify.js.org/#/)
* [docute](https://docute.egoist.dev//)
* [mkdocs](https://www.mkdocs.org/). 

## Demos

Websites created with `altdoc`:

* [altdoc](https://altdoc.etiennebacher.com/) itself (Docute)
* [conductor](https://conductor.etiennebacher.com/) (Docsify)

Websites created with the documentation generators supported by `altdoc`:

* [firebase](https://firebase.john-coene.com/) by John Coene (uses Mkdocs, theme Material)
* [sever](https://sever.john-coene.com/) by John Coene (uses Mkdocs, theme readthedocs)


## Installation

You can install the CRAN version:
```r
install.packages("altdoc")
```

You can also install the development version to benefit from the latest bug fixes:
```r
remotes::install_github("etiennebacher/altdoc")
```

## Features

* Import core files to use `docute`, `docsify`, or `mkdocs` documentation formats.
* Render Rmarkdown and Quarto vignettes stored in the package's `vignettes/` directory.
* Convert man pages for all exported functions to HTML with rendered examples.
* Generate pages and links to common sections:
  - README, NEWS, Changelog, Code of Conduct, etc.
* Preview the site in a browser or in the RStudio Viewer pane.
* Facilitate website deployment to Github and other platforms.


## Workflow

A typical workflow with `altdoc` is to execute these commands from the root directory of the package:

```r
### Create the website structure for one of the documentation generators
setup_docs(tool = "docsify")
# setup_docs(tool = "docute")
# setup_docs(tool = "mkdocs")

### Render the vignettes and man pages
render_docs()

### Preview the website
preview_docs()
```

See [the Get Started vignette](vignettes/get-started.md) for more details.


## More

More details on the package and the deployment are available on the [website](https://altdoc.etiennebacher.com/#/). 

Options for each site generator can be found on their own website:

* [Docute](https://docute.egoist.dev//)
* [Docsify](https://docsify.js.org/)
* [Mkdocs](https://www.mkdocs.org/) ([Material for Mkdocs](https://squidfunk.github.io/mkdocs-material/))

