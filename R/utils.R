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
    cli::cli_alert_success("{.file README} imported.")
  } else {
    fs::file_copy(
      system.file("docsify/README.md", package = "altdoc"),
      paste0(good_path, "/README.md")
    )
    cli::cli_alert_info("No {.file README} found. Created a default {.file docs/README}.")
  }
  reformat_md(paste0(good_path, "/README.md"))
  move_img_readme()
  replace_img_paths_readme()

}


import_news <- function() {

  good_path <- doc_path()
  file <- which_news()
  if (is.null(file)) {
    cli::cli_alert_info("No {.file NEWS / Changelog} to include.")
    return(invisible())
  }

  if (fs::file_exists(file)) {
    fs::file_copy(file, paste0(good_path, "/NEWS.md"))
    reformat_md(paste0(good_path, "/", file), first = TRUE)
    cli::cli_alert_success("{.file {file}} imported.")
  }

}


import_coc <- function() {

  good_path <- doc_path()
  if (fs::file_exists("CODE_OF_CONDUCT.md")) {
    fs::file_copy("CODE_OF_CONDUCT.md", paste0(good_path, "/CODE_OF_CONDUCT.md"))
    cli::cli_alert_success("{.file Code of Conduct} imported.")
  } else {
    cli::cli_alert_info("No {.file Code of Conduct} to include.")
  }

}


import_license <- function() {

  good_path <- doc_path()
  file <- which_license()
  if (is.null(file)) {
    cli::cli_alert_info("No {.file License / Licence} to include.")
    return(invisible())
  }

  if (fs::file_exists(file)) {
    fs::file_copy(file, paste0(good_path, "/LICENSE.md"))
    cli::cli_alert_success("{.file {file}} imported.")
  }

}

build_docs <- function() {

  cli::cli_h1("Docs structure")
  cli::cli_alert_success("Folder {.file docs} created.")

  import_readme()
  import_news()
  import_coc()
  import_license()
  make_reference()
}

# Last things to do in initialization

final_steps <- function(x) {

  if (x == "docute") {
    index <- readLines("docs/index.html")
    if (!fs::file_exists("NEWS.md")) {
      index <- index[-which(grepl("/NEWS", index))]
    }
    if (!fs::file_exists("LICENSE.md")) {
      index <- index[-which(grepl("/LICENSE", index))]
    }
    if (!fs::file_exists("CODE_OF_CONDUCT.md")) {
      index <- index[-which(grepl("/CODE_OF_CONDUCT", index))]
    }
    writeLines(index, "docs/index.html")
  }

  suppressMessages({
    usethis::use_build_ignore("docs")
  })
  cli::cli_h1("Complete")
  cli::cli_alert_success("{tools::toTitleCase(x)} initialized.")
  cli::cli_alert_success("Folder {.file docs} put in {.file .Rbuildignore}.")

}


# Check that folder 'docs' does not already exist, or is empty.

check_docs_exists <- function(overwrite = FALSE) {
  if (fs::dir_exists("docs") && !folder_is_empty("docs")) {
    if (isTRUE(overwrite)) {
      fs::dir_delete("docs")
    } else {
      delete_docs <- usethis::ui_yeah(
        "Folder {usethis::ui_value('docs')} already exists. Do you want to replace it?"
      )
      if (delete_docs) {
        fs::dir_delete("docs")
      } else {
        cli::cli_alert_info("Nothing was modified.")
        return(1)
      }
    }
  }

  if (!fs::dir_exists("docs")) {
    fs::dir_create("docs")
  }

  return(NULL)
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


# Detect how licence files is called: "LICENSE" or "LICENCE"
# If no license, return "license" for cli message in update_file()
which_license <- function() {

  x <- list.files(pattern = "\\.md$")
  license <- x[which(grepl("license", x, ignore.case = TRUE))]
  licence <- x[which(grepl("licence", x, ignore.case = TRUE))]
  if (length(license) == 1) {
    return(license)
  } else if (length(licence) == 1) {
    return(licence)
  } else {
    return(NULL)
  }

}

# Detect how news files is called: "NEWS" or "CHANGELOG"
# If no news, return "news" for cli message in update_file()
which_news <- function() {

  x <- list.files(pattern = "\\.md$")
  news <- x[which(grepl("news", x, ignore.case = TRUE))]
  changelog <- x[which(grepl("changelog", x, ignore.case = TRUE))]
  if (length(news) == 1) {
    return(news)
  } else if (length(changelog) == 1) {
    return(changelog)
  } else {
    return(NULL)
  }

}
