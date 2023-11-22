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
render_docs <- function(path = ".", verbose = FALSE, parallel = FALSE, freeze = FALSE) {

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
  .import_man(src_dir = path, tar_dir = docs_dir, doctype = doctype, verbose = verbose, parallel = parallel, freeze = freeze)

  # Update vignettes
  cli::cli_h1("Vignettes")
  .import_vignettes(src_dir = path, tar_dir = docs_dir, doctype = doctype, verbose = verbose, parallel = parallel, freeze = freeze)

  cli::cli_h1("Update HTML")
  .import_settings(path = path, doctype = doctype, verbose = verbose)

  cli::cli_h1("Complete")
  cli::cli_alert_success("Documentation updated.")
  cli::cli_alert_info("Some files might have been reformatted. Get more info with {.code ?altdoc:::.reformat_md}.")
}

