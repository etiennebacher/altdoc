#' @import cli
#' @import fs
NULL

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
    cli_alert_danger("Apparently, {.code pip3} is not installed on your system.")
    cli_alert_danger("Could not check whether {.code mkdocs-material} is installed.")
    return(invisible())
  }
  x <- grepl("mkdocs-material", system("pip3 list --local", intern = TRUE))
  return(any(x))
}

# create index.html for docute and docsify
create_index <- function(x) {

  index <- htmltools::htmlTemplate(
    system.file(paste0(x, "/index.html"), package = "altdoc"),
    title = pkg_name(),
    footer = sprintf(
      "<hr/><a href='%s'> <code>%s</code> v. %s </a> | Documentation made with <a href='https://github.com/etiennebacher/altdoc'> <code>altdoc</code> v. %s</a>",
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
}


import_readme <- function(path = here::here()) {

  good_path <- doc_path(path = path)
  if (file_exists(paste0(path, "/README.md"))) {
    file_copy(paste0(path, "/README.md"), paste0(good_path, "/README.md"), overwrite = TRUE)
    cli_alert_success("{.file README} imported.")
  } else {
    file_copy(
      system.file("docsify/README.md", package = "altdoc"),
      paste0(good_path, "/README.md")
    )
    cli_alert_info("No {.file README} found. Created a default {.file docs/README}.")
  }
  reformat_md(paste0(good_path, "/README.md"))
  move_img_readme()
  replace_img_paths_readme()

}


import_news <- function(path = here::here()) {

  good_path <- doc_path(path = path)
  file <- which_news()
  if (is.null(file)) {
    cli_alert_info("No {.file NEWS / Changelog} to include.")
    return(invisible())
  }

  if (file_exists(file)) {
    file_copy(file, paste0(good_path, "/NEWS.md"))
    reformat_md(paste0(good_path, "/", file), first = TRUE)
    cli_alert_success("{.file {file}} imported.")
  }

}


import_coc <- function(path = here::here()) {

  good_path <- doc_path(path = path)
  if (file_exists("CODE_OF_CONDUCT.md")) {
    file_copy("CODE_OF_CONDUCT.md", paste0(good_path, "/CODE_OF_CONDUCT.md"))
    cli_alert_success("{.file Code of Conduct} imported.")
  } else {
    cli_alert_info("No {.file Code of Conduct} to include.")
  }

}


import_license <- function(path = here::here()) {

  good_path <- doc_path(path = path)
  file <- which_license()
  if (is.null(file)) {
    cli_alert_info("No {.file License / Licence} to include.")
    return(invisible())
  }

  if (file_exists(file)) {
    file_copy(file, paste0(good_path, "/LICENSE.md"))
    cli_alert_success("{.file {file}} imported.")
  }

}

build_docs <- function(path = here::here()) {

  cli_h1("Docs structure")
  cli_alert_success("Folder {.file docs} created.")

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
    if (!file_exists("NEWS.md")) {
      index <- index[-which(grepl("/NEWS", index))]
    }
    if (!file_exists("LICENSE.md")) {
      index <- index[-which(grepl("/LICENSE", index))]
    }
    if (!file_exists("CODE_OF_CONDUCT.md")) {
      index <- index[-which(grepl("/CODE_OF_CONDUCT", index))]
    }
    writeLines(index, "docs/index.html")
  } else if (x == "docsify") {
    sidebar <- readLines("docs/_sidebar.md", warn = FALSE)
    if (!fs::file_exists("docs/NEWS.md")) {
      sidebar <- sidebar[-which(grepl("NEWS.md", sidebar))]
    }
    if (!fs::file_exists("docs/LICENSE.md")) {
      sidebar <- sidebar[-which(grepl("LICENSE.md", sidebar))]
    }
    if (!fs::file_exists("docs/CODE_OF_CONDUCT.md")) {
      sidebar <- sidebar[-which(grepl("CODE_OF_CONDUCT.md", sidebar))]
    }
    if (!fs::file_exists("docs/reference.md")) {
      sidebar <- sidebar[-which(grepl("reference.md", sidebar))]
    }
    cat(sidebar, file = "docs/_sidebar.md", sep = "\n")
  }

  suppressMessages({
    usethis::use_build_ignore("docs")
  })
  cli_h1("Complete")
  cli_alert_success("{tools::toTitleCase(x)} initialized.")
  cli_alert_success("Folder {.file docs} put in {.file .Rbuildignore}.")

  if (interactive()) {
    cli::cli_par()
    cli::cli_end()
    cli::cli_alert("Running preview...")
    preview()
  }

}


# Check that folder 'docs' does not already exist, or is empty.

check_docs_exists <- function(overwrite = FALSE) {
  if (dir_exists("docs") && !folder_is_empty("docs")) {
    if (isTRUE(overwrite)) {
      fs::dir_delete("docs")
    } else {
      delete_docs <- usethis::ui_yeah(
        "Folder {usethis::ui_value('docs')} already exists. Do you want to replace it?"
      )
      if (delete_docs) {
        fs::dir_delete("docs")
      } else {
        cli_alert_info("Nothing was modified.")
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
doc_type <- function(path = here::here()) {

  if (!dir_exists(paste0(path, "/docs"))) return(NULL)

  if (file_exists(paste0(path, "/docs/mkdocs.yml"))) return("mkdocs")

  if (file_exists(paste0(path, "/docs/index.html"))) {
    file <- paste(readLines(paste0(path, "/docs/index.html"), warn = FALSE),
                  collapse = "")
    if (grepl("docute", file)) return("docute")
    if (grepl("docsify", file)) return("docsify")
  }

}

# Get the path for files
doc_path <- function(path = here::here()) {
  doc_type <- doc_type(path = path)
  if (doc_type == "mkdocs") {
    return(paste0(path, "/docs/docs"))
  } else if (doc_type %in% c("docsify", "docute")) {
    return(paste0(path, "/docs"))
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

# https://github.com/ropenscilabs/r2readthedocs/blob/main/R/utils.R
convert_path <- function (path = ".") {
  if (path == ".") path <- here::here()
  path <- normalizePath(path)
  return(path)
}
