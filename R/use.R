#' Init Docute, Docsify, or Mkdocs
#'
#' @param overwrite Overwrite the folder 'docs' if it already exists. If `FALSE`
#' (default), there will be an interactive choice to make in the console to
#' overwrite. If `TRUE`, the folder 'docs' is automatically overwritten.
#' @param path Path. Default is the package root (detected with `here::here()`).
#' @param custom_reference Path to the file that will be sourced to generate the
#' "Reference" section.
#' @param quarto Logical. Whether to use quarto to render Rd documentation files
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
#' # Create docute documentation
#' use_docute()
#'
#' # Create docsify documentation
#' use_docsify()
#'
#' # Create mkdocs documentation
#' use_mkdocs()
#' }

use_docute <- function(path = ".", overwrite = FALSE,
                       custom_reference = NULL, quarto = FALSE) {

  path <- .convert_path(path)
  .check_is_package(path)
  .check_docs_exists(overwrite, path)

  .create_index("docute", path)
  .build_docs(path, custom_reference, quarto = quarto)
  .build_vignettes(path)

  .final_steps(x = "docute", path)
}

#' @export
#'
#' @rdname init

use_docsify <- function(path = ".", overwrite = FALSE,
                        custom_reference = NULL, quarto = FALSE) {

  path <- .convert_path(path)
  .check_is_package(path)
  .check_docs_exists(overwrite, path)

  .create_index("docsify", path = path)

  .build_docs(path = path, custom_reference, quarto = quarto)

  fs::file_copy(
    system.file("docsify/_sidebar.md", package = "altdoc"),
    fs::path_abs("docs/_sidebar.md", start = path)
  )

  .build_vignettes(path)

  .final_steps(x = "docsify", path = path)

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
                       quarto = FALSE) {

  path <- .convert_path(path)
  .check_is_package(path)
  .check_docs_exists(overwrite, path)
  .check_tools("mkdocs", theme)

  if (.is_windows() & interactive()) {
    shell(paste("mkdocs new", fs::path_abs("docs", start = path), "-q"))
    shell(paste("cd", fs::path_abs("docs", start = path), "&& mkdocs build -q"))
  } else {
    system2("mkdocs", paste("new", fs::path_abs("docs", start = path), "-q"))
    system2("cd", paste(fs::path_abs("docs", start = path), "&& mkdocs build -q"))
  }

  yaml <- paste0(
    "
### Basic information
site_name: ", .pkg_name(path),
if (!is.null(theme)) {
  paste0("
theme:
  name: ", theme
  )
},
if (!is.null(theme) && theme == "material") {
  paste0(
    "

  # Dark mode toggle
  palette:
    - media: '(prefers-color-scheme: light)' #
      toggle:
        icon: material/toggle-switch-off-outline
        name: Switch to dark mode
    - media: '(prefers-color-scheme: dark)' #
      scheme: slate
      toggle:
        icon: material/toggle-switch
        name: Switch to light mode
  features:
    - navigation.tabs
    - toc.integrate
    "
  )
},
"

### Repo information
repo_url: ", .gh_url(path), "
repo_name: ", .pkg_name(path), "

### Plugins
plugins:
  - search

### Navigation tree
nav:
  - Home: README.md
  - Changelog: NEWS.md
  - Reference: reference.md
  - Code of Conduct: CODE_OF_CONDUCT.md
  - License: LICENSE.md
    "
  )
  cat(yaml, file = fs::path_abs("docs/mkdocs.yml", start = path))

  fs::file_delete(fs::path_abs("docs/docs/index.md", start = path))
  .build_docs(path = path, quarto = quarto)

  yaml <- .readlines(fs::path_abs("docs/mkdocs.yml", start = path))
  if (!fs::file_exists(fs::path_abs("docs/docs/NEWS.md", start = path))) {
    yaml <- yaml[-which(grepl("NEWS.md", yaml))]
  }
  if (!fs::file_exists(fs::path_abs("docs/docs/LICENSE.md", start = path))) {
    yaml <- yaml[-which(grepl("LICENSE.md", yaml))]
  }
  if (!fs::file_exists(fs::path_abs("docs/docs/CODE_OF_CONDUCT.md", start = path))) {
    yaml <- yaml[-which(grepl("CODE_OF_CONDUCT.md", yaml))]
  }
  if (!fs::file_exists(fs::path_abs("docs/docs/reference.md", start = path))) {
    yaml <- yaml[-which(grepl("reference.md", yaml))]
  }
  cat(yaml, file = fs::path_abs("docs/mkdocs.yml", start = path), sep = "\n")

  .build_vignettes(path)

  .final_steps(x = "mkdocs", path = path)
}
