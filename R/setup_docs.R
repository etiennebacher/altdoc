#' Initialize documentation website settings
#'
#' @description
#' Creates a subdirectory called `altdoc/` in the package root directory to store the settings files used to by one of the documentation generator utilities (docsify, docute, or mkdocs). The files in this folder are never altered automatically by `altdoc` unless the user explicitly calls `overwrite=TRUE`. They can thus be edited manually to customize the sidebar and website.
#'
#' @param tool String. "docsify", "docute", or "mkdocs".
#' @param path Path to the package root directory.
#' @param overwrite Logical. If TRUE, overwrite existing files.
#'
#' @export
#'
#' @return No value returned.
#' 
#' @examples
#' if (interactive()) {
#' 
#'   # Create docute documentation
#'   setup_docs(tool = "docute")
#'
#'   # Create docsify documentation
#'   setup_docs(tool = "docsify")
#'
#'   # Create mkdocs documentation
#'   setup_docs(tool = "mkdocs")
#' 
#' }
setup_docs <- function(tool, path = ".", overwrite = FALSE) {

  safe.copy <- function(src, tar, overwrite) {
    if (fs::file_exists(tar) && !isTRUE(overwrite)) {
      cli::cli_abort("{tar} already exists. Delete it or set `overwrite=TRUE`.", call = NULL)
    } else {
      file.copy(src, tar, overwrite = TRUE)
    }
  }

  # input sanity checks
  if (!is.character(tool) || length(tool) != 1 || !tool %in% c("docute", "docsify", "mkdocs")) {
    cli::cli_abort(
      'The `tool` argument must be "docsify", "docute", or "mkdocs".')
  }

  # paths
  path <- .convert_path(path)
  .check_is_package(path)
  altdoc_dir <- fs::path_abs(fs::path_join(c(path, "altdoc")))
  docs_dir <- fs::path_abs(fs::path_join(c(path, "docs")))

  if (!fs::dir_exists(altdoc_dir)) {
    cli::cli_alert_info("Creating `altdoc/` directory.")
    fs::dir_create(altdoc_dir)
  } 
  if (!fs::dir_exists(docs_dir)) {
    cli::cli_alert_info("Creating `docs/` directory.")
    fs::dir_create(docs_dir)
  } 


  .add_rbuildignore("^docs$", path = path)
  .add_rbuildignore("^altdoc$", path = path)

  cli::cli_alert_info("Copying default settings file(s) to `altdoc/`")

  if (isTRUE(tool == "docsify")) {
    src <- system.file("docsify/docsify.html", package = "altdoc")
    tar <- fs::path_join(c(altdoc_dir, "docsify.html"))
    safe.copy(src, tar, overwrite = overwrite)

    src <- system.file("docsify/docsify.md", package = "altdoc")
    tar <- fs::path_join(c(altdoc_dir, "docsify.md"))
    safe.copy(src, tar, overwrite = overwrite)

  } else if (isTRUE(tool == "docute")) {
    src <- system.file("docute/docute.html", package = "altdoc")
    tar <- fs::path_join(c(altdoc_dir, "docute.html"))
    safe.copy(src, tar, overwrite = overwrite)

  } else if (isTRUE(tool == "mkdocs")) {
    src <- system.file("mkdocs/mkdocs.yml", package = "altdoc")
    tar <- fs::path_join(c(altdoc_dir, "mkdocs.yml"))
    safe.copy(src, tar, overwrite = overwrite)
  }

  # README.md is mandatory
  fn <- fs::path_join(c(path, "README.md"))
  if (!fs::file_exists(fn)) {
    cli::cli_alert_info("README.md is mandatory. `altdoc` created a dummy README file in the package directory.")
    writeLines("Hello World!", fn)
  }

  return(invisible())
}
