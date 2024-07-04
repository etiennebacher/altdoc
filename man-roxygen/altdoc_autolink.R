#' @section Auto-link for Quarto websites:
#'
#' When the `code-link` format setting is `true` in `altdoc/quarto_website.yml` and the `downlit` package is installed, `altdoc` will use the `downlit` package to replace the function names on the package website by links to web-based package documentation. This works for base R libraries and any package published on CRAN.
#'
#' To allow internal links to functions documented by `altdoc`, we need to include links to correct URLs in the `altdoc/pkgdown.yml` file. By default, this file is populated with links to the first URL in the `DESCRIPTION`.
#'
#' Importantly, `downlit` requires the `pkgdown.yml` file to be live on the website to create links. This means that links will generally not be updated when making purely local changes. Also, links may not be updated the first time an `altdoc` website is published to the web.
#'
