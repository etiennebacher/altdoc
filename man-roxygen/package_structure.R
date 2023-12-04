#' @section Package structure:
#'
#' `altdoc` makes assumptions about your package structure:
#'
#' * The homepage of the website is stored in `README.qmd`, `README.Rmd`, or `README.md`.
#' * `vignettes/` stores the vignettes in `.md`, `.Rmd` or `.qmd` format.
#' * `docs/` stores the rendered website. This folder is overwritten every time a user calls `render_docs()`, so you should not edit it manually.
#' * `altdoc/` stores the settings files created by `setup_docs()`. These files are never modified automatically after initialization, so you can edit them manually to customize the settings of your documentation and website. All the files stored in `altdoc/` are copied to `docs/` and made available as static files in the root of the website.
#' * These files are imported automatically: `NEWS.md`, `CHANGELOG.md`, `CODE_OF_CONDUCT.md`, `LICENSE.md`, `LICENCE.md`.
#'
