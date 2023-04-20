# https://github.com/ropenscilabs/r2readthedocs/blob/main/R/utils.R
.convert_path <- function (path = ".") {
  if (path == ".") path <- here::here()
  path <- normalizePath(path)
  return(path)
}

.dir_is_package <- function(path) {
  fs::file_exists(fs::path_abs("DESCRIPTION", start = path))
}

.is_windows <- function () {
  .Platform$OS.type == "windows"
}

# Is pip3 installed?
.is_pip3 <- function() {
  x <- try(system2("pip3", args = "--version", stdout = TRUE, stderr = TRUE), silent = TRUE)
  return(!inherits(x, "try-error"))
}

# Is mkdocs installed?
.is_mkdocs <- function() {
  x <- try(system2("mkdocs", stdout = TRUE, stderr = TRUE), silent = TRUE)
  return(!inherits(x, "try-error"))
}

# Is mkdocs material installed?
.is_mkdocs_material <- function() {
  if (!.is_pip3()) {
    cli::cli_alert_danger("Apparently, {.code pip3} is not installed on your system.")
    cli::cli_alert_danger("Could not check whether {.code mkdocs-material} is installed.")
    return(invisible())
  }
  x <- grepl("mkdocs-material", system2("pip3", "list --local", stdout = TRUE))
  return(any(x))
}

# Is sphinx installed?
.is_sphinx <- function() {
  x <- try(system2("sphinx-build", args = "--version", stdout = TRUE, stderr = TRUE), silent = TRUE)
  return(!inherits(x, "try-error"))
}


# https://stackoverflow.com/a/42945293/11598948
.stop_quietly <- function() {
  opt <- options(show.error.messages = FALSE)
  on.exit(options(opt))
  stop()
}

.folder_is_empty <- function(x) {
  length(list.files(x)) == 0
}

.pkg_name <- function(path) {
  desc::desc_get_field("Package", default = NULL, file = path)
}

.pkg_version <- function(path) {
  as.character(desc::desc_get_version(path))
}

.gh_url <- function(path) {
  .gh_urls <- c(
    desc::desc_get_urls(path),
    desc::desc_get_field("BugReports", default = NULL, file = path)
  )

  if (length(.gh_urls) == 0) return("")

  .gh_url <- .gh_urls[which(grepl("github.com", .gh_urls))]
  .gh_url <- gsub("/issues", "", .gh_url)
  if (length(.gh_url) == 0) {
    .gh_url <- .gh_urls[which(grepl("github.io", .gh_urls))]
    .gh_url <- gsub(".github.io", "", .gh_url)
    .gh_url <- gsub("https://", "https://github.com/", .gh_url)
  }
  .gh_url <- gsub(" ", "", .gh_url)
  .gh_url <- gsub("#.*", "", .gh_url)
  .gh_url <- unique(.gh_url)

  if (length(.gh_url) == 0) .gh_url <- ""
  return(.gh_url)
}


# Get the tool that was used
.doc_type <- function(path = ".") {
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
.doc_path <- function(path = ".") {
  .doc_type <- .doc_type(path = path)
  if (.doc_type == "mkdocs") {
    return(fs::path_abs("docs/docs", start = path))
  } else if (.doc_type %in% c("docsify", "docute")) {
    return(fs::path_abs("docs", start = path))
  }
}

# Detect how licence files is called: "LICENSE" or "LICENCE"
# If no license, return "license" for cli message in .update_file()
.which_license <- function(path = ".") {
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
# If no news, return "news" for cli message in .update_file()
.which_news <- function(path = ".") {
  x <- list.files(path = path, pattern = "\\.md$")
  news <- x[which(grepl("news.md", x, ignore.case = TRUE))]
  changelog <- x[which(grepl("changelog", x, ignore.case = TRUE))]
  if (length(news) == 1) {
    return(news)
  } else if (length(changelog) == 1) {
    return(changelog)
  } else {
    return(NULL)
  }
}

.get_footer <- function(path) {
  .doc_type <- .doc_type(path)
  if (.doc_type %in% c("docute", "docsify")) {
    index <- .readlines("docs/index.html")
    index <- gsub("\\t", "", index)
    index <- trimws(index)
    if (.doc_type == "docsify") {
      footer <- which(grepl("^var footer =", index))
    } else if (.doc_type == "docute") {
      footer <- which(grepl("^footer:", index))
    }
    if (length(footer) == 1) {
      return(index[footer])
    }
  }
}

.doc_version <- function(path) {
  footer <- .get_footer(path)
  unlist(regmatches(
    footer, gregexpr("(\\d+\\.\\d+\\.\\d+(?:\\.\\d+)?)", footer)
  ))[1]
}

.altdoc_version_in_footer <- function(path) {
  footer <- .get_footer(path)
  unlist(regmatches(
    footer, gregexpr("(\\d+\\.\\d+\\.\\d+(?:\\.\\d+)?)", footer)
  ))[2]
}

.altdoc_version <- function() {
  as.character(utils::packageVersion("altdoc"))
}

.need_to_bump_version <- function(path) {
  if (.doc_type() == "mkdocs") return(FALSE)
  .doc_version(path) != .pkg_version(path)
}

.need_to_bump_altdoc_version <- function(path) {
  if (.doc_type() == "mkdocs") return(FALSE)
  .altdoc_version_in_footer(path) != .altdoc_version()
}

.readlines <- function(x) {
  readLines(x, warn = FALSE)
}

