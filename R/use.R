#' Init docute
#'
#' @export
#'

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
  if (fs::file_exists("README.md")) {
    fs::file_copy("README.md", "docs/README.md")
  } else {
    fs::file_copy(
      system.file("docute/README.md", package = "altdoc"),
      "docs/README.md"
    )
  }
  move_img_readme()

  ### CHANGELOG
  import_changelog()

  ### CODE OF CONDUCT
  import_coc()

  ### REFERENCE
  make_reference()


  ### FINAL STEPS
  usethis::use_git_ignore("^docs$")
  usethis::use_build_ignore("^docs$")

  message_validate("Docute initialized.")
  message_validate("Folder 'docs' put in .gitignore and .Rbuildignore.")
  reformat_md("docs/README.md") # placed here so that message is displayed after init message
  if (!changelog_exists) {
    message_info("'NEWS.md' does not exist. You can remove the
                 'Changelog' section in 'docs/index.html'.")
  }
  if (!coc_exists) {
    message_info("'CODE_OF_CONDUCT' does not exist. You can remove the
                 'Code of Conduct' section in 'docs/index.html'.")
  }
}

#' Init docsify
#'
#' @export

use_docsify <- function() {

  check_docs_exists()

  ### INDEX
  if (!fs::dir_exists("docs")) fs::dir_create("docs")
  index <- htmltools::htmlTemplate(
    system.file("docsify/index.html", package = "altdoc"),
    title = pkg_name(),
    repo = gh_url()
  )
  index <- as.character(index)
  writeLines(index, "docs/index.html")

  ### README
  if (fs::file_exists("README.md")) {
    fs::file_copy("README.md", "docs/README.md")
  } else {
    fs::file_copy(
      system.file("docsify/README.md", package = "altdoc"),
      "docs/README.md"
    )
  }

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
  if (!fs::file_exists("NEWS.md")) {
    sidebar <- sidebar[-which(grepl("NEWS.md", sidebar))]
  }
  if (!fs::file_exists("CODE_OF_CONDUCT.md")) {
    sidebar <- sidebar[-which(grepl("CODE_OF_CONDUCT.md", sidebar))]
  }
  cat(sidebar, file = "docs/_sidebar.md", sep = "\n")


  ### FINAL STEPS
  usethis::use_git_ignore("^docs$")
  usethis::use_build_ignore("^docs$")

  message_validate("Docsify initialized.")
  message_validate("Folder 'docs' put in .gitignore and .Rbuildignore.")
  reformat_md("docs/README.md") # placed here so that message is displayed after init message
  if (!fs::file_exists("NEWS.md")) {
    message_info("'NEWS.md' does not exist. You can remove the
                 'Changelog' section in 'docs/index.html'.")
  }
  if (!fs::file_exists("CODE_OF_CONDUCT.md")) {
    message_info("'CODE_OF_CONDUCT' does not exist. You can remove the
                 'Code of Conduct' section in 'docs/index.html'.")
  }

}

use_docpress <- function() {

  check_docs_exists()

  if (!fs::dir_exists("docs")) fs::dir_create("docs")

  ### Not as easy as the other ones because there is no index.html file
  ### Everything is done through mkdocs command

}


use_mkdocs <- function() {

  check_docs_exists()

  if (!fs::dir_exists("docs")) fs::dir_create("docs")

  ### Not as easy as the other ones because there is no index.html file
  ### Everything is done through mkdocs command

}

