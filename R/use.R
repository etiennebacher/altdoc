#' Init Docute, Docsify, or Mkdocs
#'
#' @param overwrite Overwrite the folder 'docs' if it already exists. If `FALSE`
#' (default), there will be an interactive choice to make in the console to
#' overwrite. If `TRUE`, the folder 'docs' is automatically overwritten.
#' @param path Path. Default is the package root (detected with `here::here()`).
#' @param custom_reference Path to the file that will be sourced to generate the
#' "Reference" section.
#' @param quarto Logical. Whether to use quarto to render Rd documentation files
#' @param preview Logical. Whether a preview of the documentation should be displayed in a browser window.
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
use_docute <- function(path = ".", overwrite = FALSE,
                       custom_reference = NULL,
                       quarto = getOption("altdoc_quarto", default = TRUE),
                       preview = getOption("altdoc_preview", default = FALSE)) {
  path <- .convert_path(path)
  .check_is_package(path)
  .check_docs_exists(overwrite, path)

  .create_settings(path = path, doctype = "docute")

  update_docs(path = path, custom_reference = custom_reference, quarto = quarto)
}

#' @export
#'
#' @rdname init

use_docsify <- function(path = ".", overwrite = FALSE,
                        custom_reference = NULL,
                        quarto = getOption("altdoc_quarto", default = TRUE),
                        preview = getOption("altdoc_preview", default = FALSE)) {
  path <- .convert_path(path)
  .check_is_package(path)
  .check_docs_exists(overwrite, path)

  .create_settings(path = path, doctype = "docsify")

  update_docs(path = path, custom_reference = custom_reference, quarto = quarto)
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

use_mkdocs <- function(theme = NULL,
                       path = ".",
                       overwrite = FALSE,
                       custom_reference = NULL,
                       quarto = getOption("altdoc_quarto", default = TRUE),
                       preview = getOption("altdoc_preview", default = FALSE)) {
  path <- .convert_path(path)
  .check_is_package(path)
  .check_docs_exists(overwrite, path)
  .check_tools("mkdocs", theme)

  .create_settings(path = path, doctype = "mkdocs")

  # after creating the structure
  update_docs(path = path, custom_reference = custom_reference, quarto = quarto)

  # render mkdocs
  if (.is_windows() & interactive()) {
    cmd <- paste(fs::path_abs(.doc_path(path)), "&& mkdocs build -q")
    shell("cd", cmd)
  } else {
    goback <- getwd()
    cmd <- paste(fs::path_abs(path), "&& mkdocs build -q")
    system2("cd", cmd)
    system2("cd", goback)
  }

  fs::file_move(fs::path_join(c(path, "mkdocs.yml")), .doc_path(path))

  # move site/ to docs/
  tmp <- fs::path_join(c(path, "site/"))
  src <- fs::dir_ls(tmp, recurse = TRUE)
  tar <- sub("site\\/", "docs\\/", src)
  for (i in seq_along(src)) {
    fs::dir_create(fs::path_dir(tar[i]))  # Create the directory if it doesn't exist
    if (fs::is_file(src[i])) {
      fs::file_copy(src[i], tar[i], overwrite = TRUE)
    }
  }
  fs::dir_delete(fs::path_join(c(path, "site")))
}
