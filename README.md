

<img src="man/figures/altdoc_logo_web.png" height = "125"><br>

<img src="https://github.com/etiennebacher/altdoc/workflows/R-CMD-check/badge.svg">
<img src="https://codecov.io/gh/etiennebacher/altdoc/branch/master/graph/badge.svg">
<img src="https://img.shields.io/badge/license-MIT-blue">
<a href = "https://altdoc.etiennebacher.com/#/" target = "_blank"><img src="https://img.shields.io/static/v1?label=Website&message=Visit&color=blue"></a>

`altdoc` is a simple and powerful package to create documentation
websites for `R` packages. `altdoc` makes it trivial to create beautiful
websites for simple `R` packages, and it can efficiently organize
documentation for complex projects with hundreds of functions or dozens
vignettes. Its features include:

-   Support for several documentation frameworks:
    -   [Quarto websites](https://quarto.org/docs/websites/)
    -   [Docsify](https://docsify.js.org/#/)
    -   [MkDocs](https://www.mkdocs.org/).
    -   [Docute](https://docute.egoist.dev//)
-   Render:
    -   Quarto and Rmarkdown vignettes.
    -   Reference pages for exported functions, along with evaluated
        examples.
    -   Common sections: `README.md`, `NEWS.md`, `CHANGELOG.md`,
        `CODE_OF_CONDUCT.md`, `CITATION.md`, etc.
-   Preview the site:
    -   Browser
    -   RStudio Viewer
-   Deploy the website:
    -   Github pages
    -   Other platforms

## Installation

You can install the CRAN version:

``` r
install.packages("altdoc")
```

You can also install the development version to benefit from the latest
bug fixes:

``` r
remotes::install_github("etiennebacher/altdoc")
```

## Quick start

A typical workflow with `altdoc` is to execute these commands from the
root directory of the package:

``` r
### Create the website structure for one of the documentation generators
setup_docs(tool = "docsify")
# setup_docs(tool = "docute")
# setup_docs(tool = "mkdocs")
# setup_docs(tool = "quarto_website")

### Render the vignettes and man pages
render_docs()

### Preview the website
preview_docs()
```

See [the Get Started
vignette](https://altdoc.etiennebacher.com/#/vignettes/get-started.md)
for more details.

## Demos

The websites in this table were created using Altdoc:

<table border=".5">
<tr>
<th>
Document Generator
</th>
<th>
<code>R</code> Package
</th>
<th>
Website
</th>
<th>
Settings
</th>
</tr>
<tr>
<td>
Docute
</td>
<td>
<code>altdoc</code>
</td>
<td>
🌐<a href="https://altdoc.etiennebacher.com">altdoc.etiennebacher.com</a>
</td>
<td>
<a href="https://github.com/etiennebacher/altdoc/tree/main/altdoc">Altdoc
Settings</a>
</td>
</tr>
<tr>
<td>
Quarto
</td>
<td>
<code>modelsummary</code>
</td>
<td>
🌐<a href="https://modelsummary.com">modelsummary.com</a>
</td>
<td>
<a href="https://github.com/vincentarelbundock/modelsummary/tree/main/altdoc">Altdoc
settings</a>
</td>
</tr>
<tr>
<td>
Quarto
</td>
<td>
<code>marginaleffects</code>
</td>
<td>
🌐<a href="https://marginaleffects.com">marginaleffects.com</a>
</td>
<td>
<a href="https://github.com/vincentarelbundock/marginaleffects/tree/main/altdoc">Altdoc
Settings</a>
</td>
</tr>
<tr>
<td>
Quarto
</td>
<td>
<code>tinytable</code>
</td>
<td>
🌐<a href="https://vincentarelbundock.github.io/tinytable/">vincentarelbundock.github.io/tinytable/</a>
</td>
<td>
<a href="https://github.com/vincentarelbundock/tinytable/tree/main/altdoc">Altdoc
Settings</a>
</td>
</tr>
<tr>
<td>
Quarto
</td>
<td>
<code>tinyplot</code>
</td>
<td>
🌐<a href="https://grantmcdermott.com/tinyplot/">grantmcdermott.com/tinyplot</a>
</td>
<td>
<a href="https://github.com/grantmcdermott/tinyplot/tree/main/altdoc">Altdoc
Settings</a>
</td>
</tr>
<tr>
<td>
MkDocs
</td>
<td>
<code>polars</code>
</td>
<td>
🌐<a href="https://pola-rs.github.io/r-polars/">pola-rs.github.io/r-polars</a>
</td>
<td>
<a href="https://github.com/pola-rs/r-polars">Github Repository</a>
</td>
</tr>
<tr>
<td>
Docsify
</td>
<td>
<code>conductor</code>
</td>
<td>
🌐<a href="https://conductor.etiennebacher.com">conductor.etiennebacher.com</a>
</td>
<td>
<a href="https://github.com/etiennebacher/conductor">GitHub
Repository</a>
</td>
</tr>
<tr>
<td>
Docsify
</td>
<td>
<code>countrycode</code>
</td>
<td>
🌐<a href="https://vincentarelbundock.github.io/countrycode/">vincentarelbundock.github.io/countrycode</a>
</td>
<td>
<a href="https://github.com/vincentarelbundock/countrycode/tree/main/altdoc">Altdoc
Settings</a>
</td>
</tr>
<tr>
<td>
Docsify
</td>
<td>
<code>WDI</code>
</td>
<td>
🌐<a href="https://vincentarelbundock.github.io/WDI/">vincentarelbundock.github.io/WDI</a>
</td>
<td>
<a href="https://github.com/vincentarelbundock/WDI/tree/main/altdoc">Altdoc
Settings</a>
</td>
</tr>
</table>

## More

### Tutorials

[The `altdoc` website](https://altdoc.etiennebacher.com/) includes more
information on topics like:

-   [How to get
    started](https://altdoc.etiennebacher.com/#/vignettes/get-started.md)
-   [How to customize your
    website](https://altdoc.etiennebacher.com/#/vignettes/customize.md)
-   [How to deploy your
    website](https://altdoc.etiennebacher.com/#/vignettes/deploy.md)

### Logo

The initial version of the logo was created with Chat-GPT and edited in
Gimp by Vincent Arel-Bundock.
