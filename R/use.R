#' Init docute
#'
#' @export
#'
#' @return No value returned. Creates files in folder 'docs'.
#'
#' @examples
#' \dontrun{
#' # Create a package
#' devtools::create("mypkg")
#'
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

#' Init docsify
#'
#' @export
#'
#' @return No value returned. Creates files in folder 'docs'.
#'
#' @examples
#' \dontrun{
#' # Create a package
#' devtools::create("mypkg")
#'
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

