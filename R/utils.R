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
  x <- grepl("mkdocs-material", system2("pip3", "list --local", stdout = TRUE))
  return(any(x))
}

# Is sphinx installed?
is_sphinx <- function() {
  x <- try(system2("sphinx-build", args = "--version", stdout = TRUE, stderr = TRUE), silent = TRUE)
  return(!inherits(x, "try-error"))
}

# create index.html for docute and docsify
create_index <- function(x, path = ".") {

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

  writeLines(index, fs::path_abs("docs/index.html", start = path))
}


import_readme <- function(path = ".") {

  good_path <- doc_path(path = path)
  if (fs::file_exists(fs::path_abs("README.md", start = path))) {
    fs::file_copy(
      fs::path_abs("README.md", start = path),
      paste0(good_path, "/README.md"),
      overwrite = TRUE
    )
    cli::cli_alert_success("{.file README} imported.")
  } else {
    fs::file_copy(
      system.file("docsify/README.md", package = "altdoc"),
      paste0(good_path, "/README.md")
    )
    cli::cli_alert_info("No {.file README} found. Created a default {.file docs/README}.")
  }
  reformat_md(paste0(good_path, "/README.md"))
  move_img_readme(path = path)
  replace_img_paths_readme(path = path)

}


import_news <- function(path = ".") {

  good_path <- doc_path(path = path)
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


import_coc <- function(path = ".") {

  good_path <- doc_path(path = path)
  if (fs::file_exists("CODE_OF_CONDUCT.md")) {
    fs::file_copy(
      "CODE_OF_CONDUCT.md",
      paste0(good_path, "/CODE_OF_CONDUCT.md")
    )
    cli::cli_alert_success("{.file Code of Conduct} imported.")
  } else {
    cli::cli_alert_info("No {.file Code of Conduct} to include.")
  }

}


import_license <- function(path = ".") {

  good_path <- doc_path(path = path)
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

build_docs <- function(path = ".") {

  cli::cli_h1("Docs structure")
  cli::cli_alert_success("Folder {.file docs} created.")

  import_readme(path)
  import_news(path)
  import_coc(path)
  import_license(path)
  make_reference(update = FALSE, path)
}

# Last things to do in initialization

final_steps <- function(x, path = ".") {

  if (x == "docute") {

    index <- .readlines(fs::path_abs("docs/index.html", start = path))
    if (!fs::file_exists(fs::path_abs("NEWS.md", start = path))) {
      index <- index[-which(grepl("/NEWS", index))]
    }
    if (!fs::file_exists(fs::path_abs("LICENSE.md", start = path))) {
      index <- index[-which(grepl("/LICENSE", index))]
    }
    if (!fs::file_exists(fs::path_abs("CODE_OF_CONDUCT.md", start = path))) {
      index <- index[-which(grepl("/CODE_OF_CONDUCT", index))]
    }
    writeLines(index, fs::path_abs("docs/index.html", start = path))

  } else if (x == "docsify") {

    sidebar <- .readlines(fs::path_abs("docs/_sidebar.md", start = path))
    if (!fs::file_exists(fs::path_abs("docs/NEWS.md", start = path))) {
      sidebar <- sidebar[-which(grepl("NEWS.md", sidebar))]
    }
    if (!fs::file_exists(fs::path_abs("docs/LICENSE.md", start = path))) {
      sidebar <- sidebar[-which(grepl("LICENSE.md", sidebar))]
    }
    if (!fs::file_exists(fs::path_abs("docs/CODE_OF_CONDUCT.md", start = path))) {
      sidebar <- sidebar[-which(grepl("CODE_OF_CONDUCT.md", sidebar))]
    }
    if (!fs::file_exists(fs::path_abs("docs/reference.md", start = path))) {
      sidebar <- sidebar[-which(grepl("reference.md", sidebar))]
    }
    cat(sidebar, file = fs::path_abs("docs/_sidebar.md", start = path), sep = "\n")
  }

  suppressMessages({
    usethis::use_build_ignore("docs")
  })
  cli::cli_h1("Complete")
  cli::cli_alert_success("{tools::toTitleCase(x)} initialized.")
  cli::cli_alert_success("Folder {.file docs} put in {.file .Rbuildignore}.")

  if (interactive()) {
    cli::cli_par()
    cli::cli_end()
    cli::cli_alert("Running preview...")
    preview()
  }

}


# Check that folder 'docs' does not already exist, or is empty.

check_docs_exists <- function(overwrite = FALSE, path = ".") {
  if (fs::dir_exists(fs::path_abs("docs", start = path)) &&
      !folder_is_empty(fs::path_abs("docs", start = path))) {
    if (isTRUE(overwrite)) {
      fs::dir_delete(fs::path_abs("docs", start = path))
    } else {
      delete_docs <- usethis::ui_yeah(
        "Folder {usethis::ui_value('docs')} already exists. Do you want to replace it?"
      )
      if (delete_docs) {
        fs::dir_delete(fs::path_abs("docs", start = path))
      } else {
        cli::cli_alert_info("Nothing was modified.")
        return(1)
      }
    }
  }

  if (!fs::dir_exists(fs::path_abs("docs", start = path))) {
    fs::dir_create(fs::path_abs("docs", start = path))
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
doc_type <- function(path = ".") {

  if (!fs::dir_exists(fs::path_abs("docs", start = path))) return(NULL)

  if (fs::file_exists(fs::path_abs("docs/mkdocs.yml", start = path))) return("mkdocs")

  if (fs::file_exists(fs::path_abs("docs/index.html", start = path))) {
    file <- paste(.readlines(fs::path_abs("docs/index.html", start = path)),
                  collapse = "")
    if (grepl("docute", file)) return("docute")
    if (grepl("docsify", file)) return("docsify")
  }

}

# Get the path for files
doc_path <- function(path = ".") {
  doc_type <- doc_type(path = path)
  if (doc_type == "mkdocs") {
    return(fs::path_abs("docs/docs", start = path))
  } else if (doc_type %in% c("docsify", "docute")) {
    return(fs::path_abs("docs", start = path))
  }
}

# Detect how licence files is called: "LICENSE" or "LICENCE"
# If no license, return "license" for cli message in update_file()
which_license <- function(path = ".") {

  x <- list.files(path = path, pattern = "\\.md$")
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
which_news <- function(path = ".") {

  x <- list.files(path = path, pattern = "\\.md$")
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

dir_is_package <- function(path) {
  fs::file_exists(fs::path_abs("DESCRIPTION", start = path))
}

.readlines <- function(x) {
  readLines(x, warn = FALSE)
}
