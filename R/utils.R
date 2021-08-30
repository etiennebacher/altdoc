import_readme <- function() {

  if (fs::file_exists("README.md")) {
    fs::file_copy("README.md", "docs/README.md")
  } else {
    fs::file_copy(
      system.file("docsify/README.md", package = "altdoc"),
      "docs/README.md"
    )
  }

}

import_changelog <- function() {

  if (fs::file_exists("NEWS.md")) {
    fs::file_copy("NEWS.md", "docs/NEWS.md")
    changelog <- readLines("NEWS.md", warn = FALSE)
    changelog <- gsub("^## ", "### ", changelog)
    changelog <- gsub("^# ", "## ", changelog)
    writeLines(changelog, "docs/NEWS.md")
  }

}

import_coc <- function() {

  if (fs::file_exists("CODE_OF_CONDUCT.md")) {
    fs::file_copy("CODE_OF_CONDUCT.md", "docs/CODE_OF_CONDUCT.md")
  }

}

#' Last things to do in initialization

final_steps <- function(x) {

  usethis::use_git_ignore("^docs$")
  usethis::use_build_ignore("^docs$")

  message_validate(sprintf("%s initialized.", x))
  message_validate("Folder 'docs' put in .gitignore and .Rbuildignore.")
  reformat_md("docs/README.md") # placed here so that message is displayed after init message
  if (x == "Docute") {
    if (!fs::file_exists("NEWS.md")) {
      message_info("'NEWS.md' does not exist. You can remove the
                 'Changelog' section in 'docs/index.html'.")
    }
    if (!fs::file_exists("CODE_OF_CONDUCT.md")) {
      message_info("'CODE_OF_CONDUCT' does not exist. You can remove the
                 'Code of Conduct' section in 'docs/index.html'.")
    }
  }


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

message_validate <- function(x) {
  cli::cli_alert_success(
    strwrap(prefix = " ", initial = "", x)
  )
}

message_info <- function(x) {
  cli::cli_alert_info(
    strwrap(prefix = " ", initial = "", x)
  )
}

message_error <- function(x, y) {
  strwrap(prefix = " ", initial = "", x)
}


# Detect if a folder is empty
#
# @param x Name of the folder

folder_is_empty <- function(x) {

  if (length(list.files(x)) == 0) {
    is_empty <- TRUE
  } else {
    is_empty <- FALSE
  }
  return(is_empty)

}


pkg_name <- function() {

  pkgname <- NULL

  if (file.exists("DESCRIPTION")) {
    description <- readLines("DESCRIPTION", warn = FALSE)
    line_with_name <- description[
      which(startsWith(description, "Package:"))
    ]
    pkgname <- gsub("Package: ", "", line_with_name)
  }

  return(pkgname)

}

pkg_version <- function() {

  pkgversion <- NULL

  if (file.exists("DESCRIPTION")) {
    description <- readLines("DESCRIPTION", warn = FALSE)
    line_with_name <- description[
      which(startsWith(description, "Version:"))
    ]
    pkgversion <- gsub("Version: ", "", line_with_name)
  }

  return(pkgversion)

}

gh_url <- function() {

  description <- readLines("DESCRIPTION", warn = FALSE)
  line_with_url <- description[
    c(
      which(startsWith(description, "URL:")),
      which(startsWith(description, "BugReports:"))
    )
  ]

  check <- length(line_with_url)
  if (check > 0) {
    gh_urls <- gsub("URL: ", "", line_with_url)
    gh_urls <- gsub("BugReports: ", "", gh_urls)
    gh_urls <- unlist(strsplit(gh_urls, ","))
    gh_url <- gh_urls[which(grepl("github.com", gh_urls))]
    gh_url <- gsub("/issues", "", gh_url)
    if (length(gh_url) == 0)
      gh_url <- gh_urls[which(grepl("github.io", gh_urls))]
    gh_url <- gsub(" ", "", gh_url)

    return(unique(gh_url))
  }

}
