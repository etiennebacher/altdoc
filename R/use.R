#' Init Docute, Docsify, or Mkdocs
#'
#' @param convert_vignettes Automatically convert and import vignettes if you
#' have some. This will not modify files in the folder 'vignettes'.
#' @param overwrite Overwrite the folder 'docs' if it already exists. If `FALSE`
#' (default), there will be an interactive choice to make in the console to
#' overwrite. If `TRUE`, the folder 'docs' is automatically overwritten.
#' @param path Path. Default is the package root (detected with `here::here()`).
#'
#' @export
#'
#' @return No value returned. Creates files in folder 'docs'. Other files and
#' folders are not modified.
#' @rdname init
#'
#' @examples
#' \dontrun{
#' # Create docute documentation
#' use_docute()
#' }

use_docute <- function(convert_vignettes = FALSE, overwrite = FALSE,
                       path = ".") {

  path <- convert_path(path)

  x <- check_docs_exists(overwrite = overwrite, path = path)
  if (!is.null(x)) return(invisible())

  create_index("docute", path = path)

  build_docs(path = path)

  ### VIGNETTES
  if (isTRUE(convert_vignettes)) {
    cli::cli_h1("Vignettes")
    transform_vignettes(path = path)
    add_vignettes(path = path)
  }

  final_steps(x = "docute", path = path)

  if (interactive()) {
    cli::cli_par()
    cli::cli_end()
    cli::cli_alert("Running preview...")
    preview()
  }
}

#' @export
#'
#' @rdname init
#'
#' @examples
#' \dontrun{
#' # Create docsify documentation
#' use_docsify()
#' }


use_docsify <- function(convert_vignettes = FALSE, overwrite = FALSE,
                        path = ".") {

  path <- convert_path(path)

  x <- check_docs_exists(overwrite = overwrite, path = path)
  if (!is.null(x)) return(invisible())

  create_index("docsify", path = path)

  build_docs(path = path)

  fs::file_copy(
    system.file("docsify/_sidebar.md", package = "altdoc"),
    fs::path_abs("docs/_sidebar.md", start = path)
  )

  ### VIGNETTES
  if (isTRUE(convert_vignettes)) {
    cli::cli_h1("Vignettes")
    transform_vignettes(path = path)
    add_vignettes(path = path)
  }

  final_steps(x = "docsify", path = path)

  if (interactive()) {
    cli::cli_par()
    cli::cli_end()
    cli::cli_alert("Running preview...")
    preview()
  }
}


#' @export
#'
#' @param theme Name of the theme to use. Default is basic theme. See Details
#' section.
#'
#' @param convert_vignettes Do you want to convert and import vignettes if you have
#' some? This will not modify files in the folder 'vignettes'. This feature
#' is experimental.
#'
#' @details
#' If you are new to Mkdocs, the themes "readthedocs" and "material" are among the most popular and developed. You can also see a list of themes here: https://github.com/mkdocs/mkdocs/wiki/MkDocs-Themes.
#' @rdname init
#' @examples
#' \dontrun{
#' # Create mkdocs documentation
#' use_mkdocs()
#' }

use_mkdocs <- function(theme = NULL, convert_vignettes = FALSE,
                       overwrite = FALSE, path = ".") {

  path <- convert_path(path)

  x <- check_docs_exists(overwrite = overwrite, path = path)
  if (!is.null(x)) return(invisible())

  # Create basic structure
  if (!is_mkdocs()) {
    cli::cli_alert_danger("Apparently, {.code mkdocs} is not installed on your system.")
    cli::cli_alert_info("You can install it with {.code pip3 install mkdocs} in your terminal.")
    cli::cli_alert_info("More information: {.url https://www.mkdocs.org/user-guide/installation/}")
    return(invisible())
  }

  if (!is.null(theme) && theme == "material") {
    if (!is_mkdocs_material()) {
      cli::cli_alert_danger("Apparently, {.code mkdocs-material} is not installed on your system.")
      cli::cli_alert_info("You can install it with {.code pip3 install mkdocs-material} in your terminal.")
      return(invisible())
    }
  }

  system(paste0("mkdocs new ", path, "/docs -q"))
  system(paste0("cd ", path, "/docs && mkdocs build -q"))

  yaml <- paste0(
    "
### Basic information
site_name: ", pkg_name(),
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
repo_url: ", gh_url(), "
repo_name: ", pkg_name(), "

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

  yaml <- readLines(fs::path_abs("docs/mkdocs.yml", start = path), warn = FALSE)
  if (!fs::file_exists(fs::path_abs("docs/NEWS.md", start = path))) {
    yaml <- yaml[-which(grepl("NEWS.md", yaml))]
  }
  if (!fs::file_exists(fs::path_abs("docs/LICENSE.md", start = path))) {
    yaml <- yaml[-which(grepl("LICENSE.md", yaml))]
  }
  if (!fs::file_exists(fs::path_abs("docs/CODE_OF_CONDUCT.md", start = path))) {
    yaml <- yaml[-which(grepl("CODE_OF_CONDUCT.md", yaml))]
  }
  if (!fs::file_exists(fs::path_abs("docs/reference.md", start = path))) {
    yaml <- yaml[-which(grepl("reference.md", yaml))]
  }
  cat(yaml, file = fs::path_abs("docs/mkdocs.yml", start = path), sep = "\n")


  fs::file_delete(fs::path_abs("docs/docs/index.md", start = path))
  build_docs(path = path)

  ### VIGNETTES
  if (isTRUE(convert_vignettes)) {
    cli::cli_h1("Vignettes")
    transform_vignettes(path = path)
    add_vignettes(path = path)
  }

  final_steps(x = "mkdocs", path = path)

  if (interactive()) {
    cli::cli_par()
    cli::cli_end()
    cli::cli_alert("Running preview...")
    preview()
  }
}
