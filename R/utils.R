import_readme <- function() {

  good_path <- doc_path()
  if (fs::file_exists("README.md")) {
    fs::file_copy("README.md", paste0(good_path, "/README.md"), overwrite = TRUE)
  } else {
    fs::file_copy(
      system.file("docsify/README.md", package = "altdoc"),
      paste0(good_path, "/README.md")
    )
  }

}

import_changelog <- function() {

  good_path <- doc_path()
  if (fs::file_exists("NEWS.md")) {
    fs::file_copy("NEWS.md", paste0(good_path, "/NEWS.md"))
    changelog <- readLines("NEWS.md", warn = FALSE)
    changelog <- gsub("^## ", "### ", changelog)
    changelog <- gsub("^# ", "## ", changelog)
    writeLines(changelog, paste0(good_path, "/NEWS.md"))
  }

}

import_coc <- function() {

  good_path <- doc_path()
  if (fs::file_exists("CODE_OF_CONDUCT.md")) {
    fs::file_copy("CODE_OF_CONDUCT.md", paste0(good_path, "/CODE_OF_CONDUCT.md"))
  }

}

# Last things to do in initialization

final_steps <- function(x) {

  usethis::use_build_ignore("docs")

  message_validate(sprintf("%s initialized.", x))
  message_validate("Folder 'docs' put in and .Rbuildignore.")
  reformat_md("docs/README.md") # placed here so that message is displayed after init message

  if (x == "Docute") {
    index <- readLines("docs/index.html")
    if (!fs::file_exists("NEWS.md")) {
      index <- index[-which(grepl("/NEWS", index))]
      message_info("No changelog to include.")
    }
    if (!fs::file_exists("CODE_OF_CONDUCT.md")) {
      index <- index[-which(grepl("/CODE_OF_CONDUCT", index))]
      message_info("No code of conduct to include.")
    }
    writeLines(index, "docs/index.html")
  }


}


# Check that folder 'docs' does not already exist, or is empty.

check_docs_exists <- function() {

  if (fs::dir_exists("docs") && !folder_is_empty("docs")) {
    delete_docs <- yesno::yesno(
      "Folder 'docs' already exists. Do you want to delete it?"
    )
    if (delete_docs) {
      fs::dir_delete("docs")
    } else {
      stop("Nothing was modified.")
    }
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
  cli::cli_alert_danger(
    strwrap(prefix = " ", initial = "", x)
  )
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

# Get package name
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

# Get package version
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

# Get package Github URL
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


# Get the tool that was used
doc_type <- function() {

  if (!fs::dir_exists("docs")) return(NULL)

  if (fs::file_exists("docs/mkdocs.yml")) return("mkdocs")

  if (fs::file_exists("docs/index.html")) {
    file <- paste(readLines("docs/index.html"), collapse = "")
    if (grepl("docute", file)) return("docute")
    if (grepl("docsify", file)) return("docsify")
  }

}

# Get the path for files
doc_path <- function() {
  doc_type <- doc_type()
  if (doc_type == "mkdocs") {
    return("docs/docs")
  } else if (doc_type %in% c("docsify", "docute")) {
    return("docs")
  }
}
