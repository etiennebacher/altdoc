#' Init Docute, Docsify, or Mkdocs
#'
#' @param convert_vignettes Automatically convert and import vignettes if you
#' have some. This will not modify files in the folder 'vignettes'.
#' @param overwrite Overwrite the folder 'docs' if it already exists. If `FALSE`
#' (default), there will be an interactive choice to make in the console to
#' overwrite. If `TRUE`, the folder 'docs' is automatically overwritten.
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

use_docute <- function(convert_vignettes = FALSE, overwrite = FALSE) {

  x <- check_docs_exists(overwrite = overwrite)
  if (!is.null(x)) return(invisible())

  ### INDEX
  index <- htmltools::htmlTemplate(
    system.file("docute/index.html", package = "altdoc"),
    title = pkg_name(),
    footer = sprintf(
      "<a href='%s'> <code>%s</code> v. %s </a> | Documentation made with <a href='https://github.com/etiennebacher/altdoc'> <code>altdoc</code> v. %s</a>",
      gh_url(), pkg_name(), pkg_version(),
      utils::packageVersion("altdoc")
    ),
    github_link = gh_url()
  )
  # regex stuff to correct footer
  index <- as.character(index)
  index <- gsub("&lt;", "<", index)
  index <- gsub("&gt;", ">", index)
  index <- gsub("\\r\\n", "\\\n", index)

  writeLines(index, "docs/index.html")

  build_docs()

  ### VIGNETTES
  if (isTRUE(convert_vignettes)) {
    cli::cli_h1("Vignettes")
    transform_vignettes()
    add_vignettes()
  }

  final_steps(x = "docute")

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


use_docsify <- function(convert_vignettes = FALSE, overwrite = FALSE) {

  x <- check_docs_exists(overwrite = overwrite)
  if (!is.null(x)) return(invisible())

  ### INDEX
  index <- htmltools::htmlTemplate(
    system.file("docsify/index.html", package = "altdoc"),
    title = pkg_name(),
    footer = sprintf(
      "<hr/><a href='%s'> <code>%s</code> v. %s </a> | Documentation made with <a href='https://github.com/etiennebacher/altdoc'> <code>altdoc</code> v. %s</a>",
      gh_url(), pkg_name(), pkg_version(),
      utils::packageVersion("altdoc")
    ),
    repo = gh_url()
  )
  # regex stuff to correct footer
  index <- as.character(index)
  index <- gsub("&lt;", "<", index)
  index <- gsub("&gt;", ">", index)
  index <- gsub("\\r\\n", "\\\n", index)

  writeLines(index, "docs/index.html")

  build_docs()

  ### SIDEBAR
  fs::file_copy(
    system.file("docsify/_sidebar.md", package = "altdoc"),
    "docs/_sidebar.md"
  )
  sidebar <- readLines("docs/_sidebar.md", warn = FALSE)
  if (!fs::file_exists("docs/NEWS.md")) {
    sidebar <- sidebar[-which(grepl("NEWS.md", sidebar))]
  }
  if (!fs::file_exists("docs/LICENSE.md")) {
    sidebar <- sidebar[-which(grepl("LICENSE.md", sidebar))]
  }
  if (!fs::file_exists("docs/CODE_OF_CONDUCT.md")) {
    sidebar <- sidebar[-which(grepl("CODE_OF_CONDUCT.md", sidebar))]
  }
  if (!fs::file_exists("docs/reference.md")) {
    sidebar <- sidebar[-which(grepl("reference.md", sidebar))]
  }
  cat(sidebar, file = "docs/_sidebar.md", sep = "\n")


  ### VIGNETTES
  if (isTRUE(convert_vignettes)) {
    cli::cli_h1("Vignettes")
    transform_vignettes()
    add_vignettes()
  }

  final_steps(x = "docsify")

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

use_mkdocs <- function(theme = NULL, convert_vignettes = FALSE, overwrite = FALSE) {

  x <- check_docs_exists(overwrite = overwrite)
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

  system("mkdocs new docs -q")
  system("cd docs && mkdocs build -q")

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
  cat(yaml, file = "docs/mkdocs.yml")

  yaml <- readLines("docs/mkdocs.yml", warn = FALSE)
  if (!fs::file_exists("docs/NEWS.md")) {
    yaml <- yaml[-which(grepl("NEWS.md", yaml))]
  }
  if (!fs::file_exists("docs/LICENSE.md")) {
    yaml <- yaml[-which(grepl("LICENSE.md", yaml))]
  }
  if (!fs::file_exists("docs/CODE_OF_CONDUCT.md")) {
    yaml <- yaml[-which(grepl("CODE_OF_CONDUCT.md", yaml))]
  }
  if (!fs::file_exists("docs/reference.md")) {
    yaml <- yaml[-which(grepl("reference.md", yaml))]
  }
  cat(yaml, file = "docs/mkdocs.yml", sep = "\n")


  fs::file_delete("docs/docs/index.md")
  build_docs()

  ### VIGNETTES
  if (isTRUE(convert_vignettes)) {
    cli::cli_h1("Vignettes")
    transform_vignettes()
    add_vignettes()
  }

  final_steps(x = "mkdocs")

  if (interactive()) {
    cli::cli_par()
    cli::cli_end()
    cli::cli_alert("Running preview...")
    preview()
  }
}
