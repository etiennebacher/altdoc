#' Init Docute, Docsify, or Mkdocs
#'
#' @export
#'
#' @return No value returned. Creates files in folder 'docs'.
#' @rdname init
#'
#' @examples
#' \dontrun{
#' # Create docute documentation
#' use_docute()
#' }

use_docute <- function() {

  check_docs_exists()

  ### INDEX
  if (!fs::dir_exists("docs")) fs::dir_create("docs")
  index <- htmltools::htmlTemplate(
    system.file("docute/index.html", package = "altdoc"),
    title = pkg_name(),
    footer = sprintf(
      "<a href='%s'> <code> %s </code> v. %s </a> | Documentation made with <a href='https://github.com/etiennebacher/altdoc'> <code> altdoc </code> v. %s</a>",
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

  ### README
  import_readme()
  move_img_readme()
  replace_img_paths_readme()

  ### CHANGELOG
  import_changelog()

  ### CODE OF CONDUCT
  import_coc()

  ### REFERENCE
  make_reference()


  ### FINAL STEPS
  final_steps(x = "Docute")
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


use_docsify <- function() {

  check_docs_exists()

  ### INDEX
  if (!fs::dir_exists("docs")) fs::dir_create("docs")
  index <- htmltools::htmlTemplate(
    system.file("docsify/index.html", package = "altdoc"),
    title = pkg_name(),
    footer = sprintf(
      "<hr/><a href='%s'> <code> %s </code> v. %s </a> | Documentation made with <a href='https://github.com/etiennebacher/altdoc'> <code> altdoc </code> v. %s</a>",
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

  ### README
  import_readme()
  move_img_readme()
  replace_img_paths_readme()

  ### CHANGELOG
  import_changelog()

  ### CODE OF CONDUCT
  import_coc()

  ### REFERENCE
  make_reference()

  ### SIDEBAR
  fs::file_copy(
    system.file("docsify/_sidebar.md", package = "altdoc"),
    "docs/_sidebar.md"
  )
  sidebar <- readLines("docs/_sidebar.md", warn = FALSE)
  if (!fs::file_exists("docs/NEWS.md")) {
    sidebar <- sidebar[-which(grepl("NEWS.md", sidebar))]
  }
  if (!fs::file_exists("docs/CODE_OF_CONDUCT.md")) {
    sidebar <- sidebar[-which(grepl("CODE_OF_CONDUCT.md", sidebar))]
  }
  if (!fs::file_exists("docs/reference.md")) {
    sidebar <- sidebar[-which(grepl("reference.md", sidebar))]
  }
  cat(sidebar, file = "docs/_sidebar.md", sep = "\n")


  ### FINAL STEPS
  final_steps(x = "Docsify")

}


#' @export
#'
#' @param theme Name of the theme to use. Default is basic theme. See Details
#' section.
#'
#'
#' @details
#' If you are new to Mkdocs, the themes "readthedocs" and "material" are among the most popular and developed. You can also see a list of themes here: https://github.com/mkdocs/mkdocs/wiki/MkDocs-Themes.
#' @rdname init
#' @examples
#' \dontrun{
#' # Create mkdocs documentation
#' use_mkdocs()
#' }

use_mkdocs <- function(theme = NULL) {

  check_docs_exists()

  # Create basic structure
  if (!is_mkdocs()) {
    message_error("Apparently, {.code mkdocs} is not installed on your system.")
    message_info("You can install it with {.code pip3 install mkdocs} in your terminal.")
    message_info("More information: {.url https://www.mkdocs.org/user-guide/installation/}")
    return(invisible())
  }

  if (!is.null(theme) && theme == "material") {
    if (!is_mkdocs_material()) {
      message_error("Apparently, {.code mkdocs-material} is not installed on your system.")
      message_info("You can install it with {.code pip3 install mkdocs-material} in your terminal.")
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
  - Reference: reference.md
    "
  )
  cat(yaml, file = "docs/mkdocs.yml")

  ### README
  fs::file_delete("docs/docs/index.md")
  import_readme()
  move_img_readme()
  replace_img_paths_readme()

  ### CHANGELOG
  import_changelog()

  ### CODE OF CONDUCT
  import_coc()

  ### REFERENCE
  make_reference()

  ### FINAL STEPS
  final_steps(x = "Mkdocs")

}
