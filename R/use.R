#' Init docute
#'
#' @export
#'

use_docute <- function() {

  check_docs_exists()

  # INDEX
  if (!fs::dir_exists("docs")) fs::dir_create("docs")
  index <- htmltools::htmlTemplate(
    system.file("docute/index.html", package = "altdoc"),
    title = get_pkg_name(),
    footer = sprintf(
      "<a href=%s> %s v. %s </a>",
      get_github_url(), get_pkg_name(), get_pkg_version()
    )
  )
  index <- as.character(index)
  index <- gsub("&lt;", "<", index)
  index <- gsub("&gt;", ">", index)
  index <- gsub("\\r\\n", "\\\n", index)

  writeLines(index, "docs/index.html")

  # README
  if (fs::file_exists("README.md")) {
    fs::file_copy("README.md", "docs/README.md")
  } else {
    fs::file_copy(
      system.file("docute/README.md", package = "altdoc"),
      "docs/README.md"
    )
  }

  message_validate("Docute initialized.")
}


use_docsify <- function() {

  check_docs_exists()

  # INDEX
  if (!fs::dir_exists("docs")) fs::dir_create("docs")
  fs::file_copy(
    system.file("docsify/index.html", package = "altdoc"),
    "docs/index.html"
  )

  # README
  if (fs::file_exists("README.md")) {
    fs::file_copy("README.md", "docs/README.md")
  } else {
    fs::file_copy(
      system.file("docsify/README.md", package = "altdoc"),
      "docs/README.md"
    )
  }

  message_validate("Docsify initialized.")

}


use_mkdocs <- function() {

  check_docs_exists()

  if (!fs::dir_exists("docs")) fs::dir_create("docs")
  fs::file_copy(
    system.file("mkdocs/index.html", package = "altdoc"),
    "docs/index.html"
  )

  message_validate("Mkdocs initialized.")
}


#' Check that folder 'docs' does not already exist, or is empty.

check_docs_exists <- function() {

  if (fs::dir_exists("docs") && !folder_is_empty("docs")) {
    stop(
      message_error("Folder 'docs' already exists and is not empty.
                    Nothing has been modified.")
    )
  }

}

# Wrappers for cli messages
# @param x Message
# @keywords internal

message_validate <- function(x) {
  cli::cli_alert_success(
    strwrap(prefix = " ", initial = "", x)
  )
}

# @keywords internal
message_info <- function(x) {
  cli::cli_alert_info(
    strwrap(prefix = " ", initial = "", x)
  )
}

# @keywords internal
message_error <- function(x, y) {
  strwrap(prefix = " ", initial = "", x)
}


# Detect if a folder is empty
#
# @param x Name of the folder
# @keywords internal

folder_is_empty <- function(x) {

  if (length(list.files(x)) == 0) {
    is_empty <- TRUE
  } else {
    is_empty <- FALSE
  }
  return(is_empty)

}
