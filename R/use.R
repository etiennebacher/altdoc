#' Initialize documentation website settings
#'
#' @param path Path to the package root directory.
#' @param overwrite TRUE/FALSE. Overwrite the settings files stored in `altdoc/`. This is dangerous!
#' @param verbose TRUE/FALSE. Print the verbose output from Rmarkdown and Quarto rendering calls.
#' @param update_docs TRUE/FALSE. Run the `update_docs()` function automatically after `use_*()`.
#' @param preview TRUE/FALSE. Run the `preview()` function automatically after `use_*()`.
#'
#' @export
#'
#' @return 
#' No value returned.
#' 
#' This function creates a subdirectory called `altdoc/` in the package root directory. `altdoc/` stores the settings files used to by each of the documentation generator utilities (docsify, docute, or mkdocs). The files in this folder are never altered automatically by `altdoc` unless the user explicitly calls `overwrite=TRUE`. They can thus be edited manually to customize the sidebar and website.
#'
#' @rdname use
#'
#' @examples
#' if (interactive()) {
#' 
#'   # Create docute documentation
#'   use_docute()
#'
#'   # Create docsify documentation
#'   use_docsify()
#'
#'   # Create mkdocs documentation
#'   use_mkdocs()
#' 
#' }
use_docute <- function(path = ".",
                       overwrite = FALSE,
                       verbose = FALSE,
                       update_docs = getOption("altdoc_update_docs", default = FALSE),
                       preview = getOption("altdoc_preview", default = FALSE)) {
  path <- .convert_path(path)
  .check_is_package(path)
  .create_settings(path = path, doctype = "docute", overwrite = overwrite)

  if (isTRUE(update_docs)) {
    update_docs(path = path)
  }
}


#' @export
#'
#' @rdname use

use_docsify <- function(path = ".",
                        overwrite = FALSE,
                        verbose = FALSE,
                        update_docs = getOption("altdoc_update_docs", default = FALSE),
                        preview = getOption("altdoc_preview", default = FALSE)) {
  path <- .convert_path(path)
  .check_is_package(path)
  .create_settings(path = path, doctype = "docsify", overwrite = overwrite)
  if (isTRUE(update_docs)) {
    update_docs(path = path)
  }
}


#' @export
#'
#' @param theme Name of the theme to use. Default is basic theme. This is only available in `mkdocs`. See Details
#' section.
#'
#' @details
#' If you are new to Mkdocs, the themes "readthedocs" and "material" are among
#' the most popular and developed. You can also see a list of themes here:
#' <https://github.com/mkdocs/mkdocs/wiki/MkDocs-Themes>.
#' @rdname use

use_mkdocs <- function(path = ".",
                       overwrite = FALSE,
                       verbose = FALSE,
                       update_docs = getOption("altdoc_update_docs", default = FALSE),
                       preview = getOption("altdoc_preview", default = FALSE),
                       theme = NULL) {
  path <- .convert_path(path)
  .check_is_package(path)
  .check_tools("mkdocs", theme)
  .create_settings(path = path, doctype = "mkdocs", overwrite = overwrite)
  if (isTRUE(update_docs)) {
    update_docs(path = path)
  }
}
