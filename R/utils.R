# Is pip3 installed?
is_pip3 <- function() {
  x <- try(system2("pip3", args = "--version", stdout = TRUE, stderr = TRUE), silent = TRUE)
  return(!inherits(x, "try-error"))
}

# Is mkdocs installed?
is_mkdocs <- function() {
  x <- try(system2("mkdocs", stdout = TRUE, stderr = TRUE), silent = TRUE)
  return(!inherits(x, "try-error"))
}

# Is mkdocs material installed?
is_mkdocs_material <- function() {
  if (!is_pip3()) {
    cli::cli_alert_danger("Apparently, {.code pip3} is not installed on your system.")
    cli::cli_alert_danger("Could not check whether {.code mkdocs-material} is installed.")
    return(invisible())
  }
  x <- system("pip3 list --local | grep  mkdocs-material", intern = TRUE)
  return(length(x) > 1)
}


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
    reformat_md(paste0(good_path, "/NEWS.md"), first = TRUE)
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
  good_path <- doc_path()

  cli::cli_h1("Docs structure")
  cli::cli_alert_success("{x} initialized.")
  cli::cli_alert_success("Folder {.file {'docs'}} put in {.file {'.Rbuildignore'}}.")
  reformat_md(paste0(good_path, "/README.md"))

  if (x == "Docute") {
    index <- readLines("docs/index.html")
    if (!fs::file_exists("NEWS.md")) {
      index <- index[-which(grepl("/NEWS", index))]
    }
    if (!fs::file_exists("CODE_OF_CONDUCT.md")) {
      index <- index[-which(grepl("/CODE_OF_CONDUCT", index))]
    }
    writeLines(index, "docs/index.html")
  }

  if (!fs::file_exists("NEWS.md")) {
    cli::cli_alert_info("No changelog to include.")
  }
  if (!fs::file_exists("CODE_OF_CONDUCT.md")) {
    cli::cli_alert_info("No code of conduct to include.")
  }
}


# Check that folder 'docs' does not already exist, or is empty.

check_docs_exists <- function(overwrite = FALSE) {
  if (fs::dir_exists("docs") && !folder_is_empty("docs")) {
    if (isTRUE(overwrite)) {
      fs::dir_delete("docs")
      return(NULL)
    } else {
      delete_docs <- usethis::ui_yeah(
        "Folder {usethis::ui_value('docs')} already exists. Do you want to replace it?"
      )
      if (delete_docs) {
        fs::dir_delete("docs")
        return(NULL)
      } else {
        cli::cli_alert_info("Nothing was modified.")
        return(1)
      }
    }
  }
}


# Detect if a folder is empty
#
# @param x Name of the folder

folder_is_empty <- function(x) {

  if (length(list.files(x)) == 0) {
    return(TRUE)
  } else {
    return(FALSE)
  }

}

# Get package name
pkg_name <- function() {

  desc::desc_get_field("Package", default = NULL)

}

# Get package version
pkg_version <- function() {

  as.character(desc::desc_get_version())

}

# Get package Github URL
gh_url <- function() {

  gh_urls <- c(
    desc::desc_get_urls(),
    desc::desc_get_field("BugReports", default = NULL)
  )

  if (length(gh_urls) == 0) return(NULL)

  gh_url <- gh_urls[which(grepl("github.com", gh_urls))]
  gh_url <- gsub("/issues", "", gh_url)
  if (length(gh_url) == 0) {
    gh_url <- gh_urls[which(grepl("github.io", gh_urls))]
    gh_url <- gsub(".github.io", "", gh_url)
    gh_url <- gsub("https://", "https://github.com/", gh_url)
  }
  gh_url <- gsub(" ", "", gh_url)
  gh_url <- gsub("#.*", "", gh_url)

  return(unique(gh_url))

}


# Get the tool that was used
doc_type <- function() {

  if (!fs::dir_exists("docs")) return(NULL)

  if (fs::file_exists("docs/mkdocs.yml")) return("mkdocs")

  if (fs::file_exists("docs/index.html")) {
    file <- paste(readLines("docs/index.html", warn = FALSE), collapse = "")
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
