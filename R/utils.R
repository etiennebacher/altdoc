# https://github.com/ropenscilabs/r2readthedocs/blob/main/R/utils.R
.convert_path <- function(path = ".") {
  path <- fs::path_abs(path)
  .check_is_package(path = path)
  path <- normalizePath(path)
  return(path)
}

.dir_is_package <- function(path) {
  fs::file_exists(fs::path_abs("DESCRIPTION", start = path))
}

.is_windows <- function() {
  .Platform$OS.type == "windows"
}

.venv_exists <- function(path = ".") {
  fs::dir_exists(fs::path_abs(".venv_altdoc", start = path))
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

  if (length(.gh_urls) == 0) {
    return("")
  }

  .gh_url <- .gh_urls[grep("github.com", .gh_urls)]
  .gh_url <- gsub("/issues", "", .gh_url)
  if (length(.gh_url) == 0) {
    .gh_url <- .gh_urls[grep("github.io", .gh_urls)]
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
  fn <- fs::path_join(c(path, "altdoc", "mkdocs.yml"))
  mkdocs <- fs::file_exists(fn)

  fn <- fs::path_join(c(path, "altdoc", "docsify.md"))
  docsify <- fs::file_exists(fn)

  fn <- fs::path_join(c(path, "altdoc", "docute.html"))
  docute <- fs::file_exists(fn)

  fn <- fs::path_join(c(path, "altdoc", "quarto_website.yml"))
  quarto_website <- fs::file_exists(fn)

  if (sum(c(mkdocs, docsify, docute, quarto_website)) == 0) {
    cli::cli_abort(
      "No documentation tool detected. Please run the {.code setup_docs()} function.",
      .envir = parent.frame(sys.nframe() - 1)
    )
  } else if (sum(c(mkdocs, docsify, docute, quarto_website)) > 1) {
    cli::cli_abort(
      "Settings detected for multiple output formats in `altdoc/`. Please remove all but one or run `setup_docs()` with `overwrite=TRUE`.",
      .envir = parent.frame(sys.nframe() - 1)
    )
  }

  if (mkdocs) return("mkdocs")
  if (docsify) return("docsify")
  if (docute) return("docute")
  if (quarto_website) return("quarto_website")

  return(NULL)
}


# Get the path for files
.doc_path <- function(path = ".") {
  return(fs::path_abs("docs", start = path))
}

# Detect how licence files is called: "LICENSE" or "LICENCE"
.which_license <- function(path = ".") {
  x <- list.files(path = path, pattern = "\\.md$")
  license <- x[grep("license", x, ignore.case = TRUE)]
  licence <- x[grep("licence", x, ignore.case = TRUE)]
  if (length(license) == 1) {
    return(license)
  } else if (length(licence) == 1) {
    return(licence)
  } else {
    return(NULL)
  }
}

.altdoc_version <- function() {
  as.character(utils::packageVersion("altdoc"))
}


.readlines <- function(x) {
  readLines(x, warn = FALSE)
}


.add_pkgdown <- function(path = ".") {
  if (!isTRUE(.dir_is_package(path))) {
    stop(".add_pkgdown() must be run from the root of a package.", call. = FALSE)
  }
  url <- setdiff(desc::desc_get_urls(), .gh_url(path))
  fn <- fs::path_join(c(path, "altdoc/pkgdown.yml"))
  if (!fs::file_exists(fn) && length(url) > 0) {
    url <- url[1]
    vig <- fs::path_join(c(url, "vignettes"))
    man <- fs::path_join(c(url, "man"))
    content <- c(
      "urls:",
      paste("  reference:", man),
      paste("  article:", vig),
      "")
    cli::cli_alert_info("Adding altdoc/pkgdown.yml file.")
    writeLines(content, fn)
  }
}


.add_rbuildignore <- function(x = "^docs$", path = ".") {
  if (!isTRUE(.dir_is_package(path))) {
    stop(".add_rbuildignore() must be run from the root of a package.", call. = FALSE)
  }
  fn <- fs::path_join(c(path, ".Rbuildignore"))
  if (!fs::file_exists(fn)) {
    fs::file_create(fn)
  }
  tmp <- .readlines(fn)
  if (!x %in% tmp) {
    cli::cli_alert_info("Adding {x} to .Rbuildignore")
    tmp <- c(tmp, x)
    writeLines(tmp, fn)
  }
}


.add_gitignore <- function(x = "^docs$", path = ".") {
  if (!isTRUE(.dir_is_package(path))) {
    stop(".add_gitignore() must be run from the root of a package.", call. = FALSE)
  }
  fn <- fs::path_join(c(path, ".gitignore"))
  if (!fs::file_exists(fn)) {
    fs::file_create(fn)
  }
  tmp <- .readlines(fn)
  if (!x %in% tmp) {
    cli::cli_alert_info("Adding {x} to .gitignore")
    tmp <- c(tmp, x)
    writeLines(tmp, fn)
  }
}


.has_preamble <- function(fn) {
  x <- .readlines(fn)
  first_non_empty <- x[which(!x == "")[1]]
  grepl("^---\\w*", first_non_empty)
}

# find the head branch of git repository
.find_head_branch <- function(path = ".") {
  if (!fs::file_exists(".git/HEAD")) {
    return(NULL)
  }
  branch <- .readlines(".git/HEAD")
  gsub("^ref: refs/heads/", "", branch)
}

.on_ci <- function() {
  isTRUE(as.logical(Sys.getenv("CI", "false")))
}
