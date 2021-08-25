# @keywords internal
get_pkg_name <- function() {

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
get_pkg_version <- function() {

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
get_github_url <- function() {

  description <- readLines("DESCRIPTION", warn = FALSE)
  line_with_url <- description[
    which(startsWith(description, "URL:"))
  ]

  check <- length(line_with_url)
  if (check > 0) {
    gh_urls <- gsub("URL: ", "", line_with_url)
    gh_url <- unlist(strsplit(gh_urls, ","))
    gh_url <- gh_url[which(grepl("github.com/", gh_url))]
    gh_url <- gsub(" ", "", gh_url)

    if (grepl("/issues", gh_url))
      gh_url <- gsub("/issues", "", gh_url)

    return(gh_url)
  }

}
