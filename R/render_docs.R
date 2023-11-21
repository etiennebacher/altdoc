#' Update documentation
#'
#' Render and update the man pages, vignettes, README, Changelog, License, Code
#' of Conduct, and Reference sections (if ' they exist). This section modifies and
#' overwrites the files in the 'docs/' folder.
#'
#' @param verbose Logical. Print Rmarkdown or Quarto rendering output.
#' @param parallel Logical. Render man pages and vignettes in parallel using the `future` framework. In addition to setting this argument to TRUE, users must define the parallelism plan in `future`. See the examples section below.
#' @inheritParams setup_docs
#' @export
#'
#' @return No value returned. Updates and overwrites the files in folder 'docs'.
#'
#' @examples
#' if (interactive()) {
#' 
#'   render_docs()
#' 
#'   # parallel rendering
#'   library(future)
#'   plan(multicore)
#'   render_docs(parallel = TRUE)
#' 
#' }
render_docs <- function(path = ".", verbose = FALSE, parallel = FALSE) {

  path <- .convert_path(path)

  dir_altdoc <- fs::path_join(c(path, "altdoc"))
  if (!fs::dir_exists(dir_altdoc) || length(fs::dir_ls(dir_altdoc)) == 0) {
    cli::cli_abort("No settings file found in {dir_altdoc}. Consider running {.code setup_docs()}.")

  }

  doctype <- .doc_type(path)

  # build quarto in a separate folder to use the built-in freeze functionality
  # and to allow moving the _site folder to docs/
  if (doctype == "quarto_website") {
    docs_parent <- fs::path_join(c(path, "_quarto"))
    # avoid collisions
    if (fs::dir_exists(docs_parent)) {
      fs::dir_delete(docs_parent)
    }
    .add_gitignore("^_quarto$")
  } else {
    docs_parent <- path
  }

  # create docs/
  docs_dir <- fs::path_join(c(docs_parent, "docs"))
  if (!fs::dir_exists(docs_dir)) {
    fs::dir_create(docs_dir)
  }

  cli::cli_h1("Basic files")


  # basic files
  .import_readme(src_dir = path, tar_dir = docs_dir, doctype = doctype)
  .import_news(src_dir = path, tar_dir = docs_dir, doctype = doctype)
  .import_license(src_dir = path, tar_dir = docs_dir, doctype = doctype)
  .import_coc(src_dir = path, tar_dir = docs_dir, doctype = doctype)

  # Update functions reference
  cli::cli_h1("Man pages")
  .import_man(src_dir = path, tar_dir = docs_dir, doctype = doctype, verbose = verbose, parallel = parallel)

  # Update vignettes
  cli::cli_h1("Vignettes")
  .import_vignettes(src_dir = path, tar_dir = docs_dir, doctype = doctype, verbose = verbose, parallel = parallel)

  cli::cli_h1("Update HTML")
  .import_settings(path = path, doctype = doctype, verbose = verbose)

  cli::cli_h1("Complete")
  cli::cli_alert_success("Documentation updated.")
  cli::cli_alert_info("Some files might have been reformatted. Get more info with {.code ?altdoc:::.reformat_md}.")
}

# Check that file exists:
# - if it doesn't, info message
# - if it does, check whether file is in docs:
#     - if it isn't, copy it there.
#     - if it is, check whether it changed:
#         - if it changed: overwrite it
#         - if it didn't: info message

.update_file <- function(file, path = ".", first = FALSE, doctype = NULL) {

  if (is.null(doctype)) {
    doctype <- .doc_type(path)
  }

  # TODO: Refactor with switch()
  file_message <- if (file == "NEWS.md") {
    "NEWS / Changelog"
  } else if (file == "LICENSE.md") {
    "License / Licence"
  } else if (file == "CODE_OF_CONDUCT.md") {
    "Code of Conduct"
  } else if (file == "README.md") {
    "README"
  }

  docs_file <- if (doctype == "docute") {
    fs::path_abs("index.html", start = path)
  } else if (doctype == "docsify") {
    fs::path_abs("_sidebar.md", start = path)
  } else if (doctype == "mkdocs") {
    fs::path_abs("mkdocs.yml", start = path)
  } else if (doctype == "quarto_website") {
    fs::path_abs("_quarto.yml", start = path)
  }

  if (is.null(file) || !fs::file_exists(file)) {
    cli::cli_alert_info("No {.file {file_message}} to include.")
    return(invisible())
  }

  if (fs::file_exists(docs_file)) {
    cli::cli_alert_success("{.file {file_message}} updated.")
  } else {
    cli::cli_alert_info("{.file {file_message}} was imported for the first time.")
  }

  fs::file_copy(file, docs_file, overwrite = TRUE)
  .reformat_md(docs_file, first = first)
}
