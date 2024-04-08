#' @section Auto-link:
#' 
#' When the `autolink` argument is `TRUE`, `altdoc` will use the `downlit` package to replace the function names on the package website by links to web-based package documentation. This works for base R libraries and any package published on CRAN.
#'
#' To allow internal links to functions documented by `altdoc`, we need to include links to correct URLs in the `altdoc/pkgdown.yml` file. By default, this file is populated with links to the first URL in the `DESCRIPTION`. When calling `render_docs(autolink=TRUE)`, the `pkgdown.yml` file is moved to the root of the website.
#'
#' Importantly, `downlit` requires the `pkgdown.yml` to be live on the website to create links. This means that links will generally not be updated when making purely local changes. Also, links may not be updated the first time an `altdoc` website is published to the web.
#'
#' Note that the `autolink` argument works best for Quarto-based websites. `mkdocs` appears to ignore `downlit` annotations altogether. `docute` and `docsify` display `downlit` annotations, but CSS styling and code highlighting sometimes suffer.
