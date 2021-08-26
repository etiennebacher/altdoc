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

# @keywords internal
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

# @keywords internal
pkg_version <- function() {

  pkgname <- NULL

  if (file.exists("DESCRIPTION")) {
    description <- readLines("DESCRIPTION", warn = FALSE)
    line_with_name <- description[
      which(startsWith(description, "Version:"))
    ]
    pkgname <- gsub("Version: ", "", line_with_name)
  }

  return(pkgname)

}

# @keywords internal
gh_url <- function() {

  description <- readLines("DESCRIPTION", warn = FALSE)
  line_with_url <- description[
    which(startsWith(description, "URL:"))
  ]

  check <- length(line_with_url)
  if (check > 0) {
    gh_urls <- gsub("URL: ", "", line_with_url)
    gh_urls <- unlist(strsplit(gh_urls, ","))
    gh_url <- gh_urls[which(grepl("github.com/", gh_urls))]
    if (length(gh_url) == 0)
      gh_url <- gh_urls[which(grepl("github.io/", gh_urls))]
    gh_url <- gsub(" ", "", gh_url)

    if (grepl("/issues", gh_url))
      gh_url <- gsub("/issues", "", gh_url)

    return(gh_url)
  }

}
