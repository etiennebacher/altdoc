#' Init Docute, Docsify, or Mkdocs
#'
#' @param overwrite Overwrite the folder 'docs' if it already exists. If `FALSE`
#' (default), there will be an interactive choice to make in the console to
#' overwrite. If `TRUE`, the folder 'docs' is automatically overwritten.
#' @param path Path. Default is the package root (detected with `here::here()`).
#' @param preview Logical. Whether a preview of the documentation should be displayed in a browser window.
#' @param verbose Logical. If true, the function will print the verbose output from Rmarkdown and Quarto rendering.
#' (Reference).
#'
#' @export
#'
#' @return No value returned. Creates files in folder 'docs'. Other files and
#' folders are not modified.
#'
#' @details
#' # Vignettes
#' Note that although vignettes are automatically moved to the `/docs` folder,
#' they are no longer automatically specified in the website structure-defining
#' file. Developers must now manually update this file and the desired order of
#' their articles. This file lives at the root of `/docs` and its name differs
#' based on the selected site builder (`use_docsify()` = `_sidebar.md`;
#' `use_docute()` = `index.html`; `use_mkdocs()` = `mkdocs.yml`).
#'
#' @rdname init
#'
#' @examples
#' if (interactive()) {
#'   # Create docute documentation
#'   use_docute()
#'
#'   # Create docsify documentation
#'   use_docsify()
#'
#'   # Create mkdocs documentation
#'   use_mkdocs()
#' }
use_docute <- function(path = ".",
                       overwrite = FALSE,
                       verbose = FALSE,
                       update = getOption("altdoc_update", default = FALSE),
                       preview = getOption("altdoc_preview", default = FALSE)) {
  path <- .convert_path(path)
  .check_is_package(path)
  .check_docs_exists(overwrite, path)

  .create_settings(path = path, doctype = "docute")

  if (isTRUE(update)) {
    update_docs(path = path)
  }
}


#' @export
#'
#' @rdname init

use_docsify <- function(path = ".",
                        overwrite = FALSE,
                        verbose = FALSE,
                        update = getOption("altdoc_update", default = FALSE),
                        preview = getOption("altdoc_preview", default = FALSE)) {
  path <- .convert_path(path)
  .check_is_package(path)
  .check_docs_exists(overwrite, path)

  .create_settings(path = path, doctype = "docsify")

  if (isTRUE(update)) {
    update_docs(path = path)
  }
}


#' @export
#'
#' @param theme Name of the theme to use. Default is basic theme. See Details
#' section.
#'
#' @details
#' If you are new to Mkdocs, the themes "readthedocs" and "material" are among
#' the most popular and developed. You can also see a list of themes here:
#' <https://github.com/mkdocs/mkdocs/wiki/MkDocs-Themes>.
#' @rdname init

use_mkdocs <- function(path = ".",
                       overwrite = FALSE,
                       verbose = FALSE,
                       update = getOption("altdoc_update", default = FALSE),
                       preview = getOption("altdoc_preview", default = FALSE),
                       theme = NULL) {
  path <- .convert_path(path)
  .check_is_package(path)
  .check_docs_exists(overwrite, path)
  .check_tools("mkdocs", theme)

  .create_settings(path = path, doctype = "mkdocs")

  if (isTRUE(update)) {
    update_docs(path = path)
  }

}
