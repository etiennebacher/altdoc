#' Update documentation
#'
#' Render and update the function reference manual, vignettes, README, NEWS, CHANGELOG, LICENSE,
#' and CODE_OF_CONDUCT sections, if they exist. This function overwrites the
#' content of the 'docs/' folder. See details below.
#'
#' @param verbose Logical. Print Rmarkdown or Quarto rendering output.
#' @param parallel Logical. Render man pages and vignettes in parallel using the `future` framework. In addition to setting this argument to TRUE, users must define the parallelism plan in `future`. See the examples section below.
#' @param freeze Logical. If TRUE and a man page or vignette has not changed since the last call to `render_docs()`, that file is skipped. File hashes are stored in `altdoc/freeze.rds`. If that file is deleted, all man pages and vignettes will be rendered anew.
#' @param ... Additional arguments are ignored.
#' @inheritParams setup_docs
#' @export
#'
#' @details
#'
#' This function searches the root directory and the `inst/` directory for specific filenames, renders/converts/copies them to the `docs/` directory. The order of priority for each file is established as follows:
#'
#' * `docs/README.md`
#'   - README.md, README.qmd, README.Rmd
#' * `docs/NEWS.md`
#'   - NEWS.md, NEWS.txt, NEWS, NEWS.Rd
#'   - Note: Where possible, Github contributors and issues are linked automatically.
#' * `docs/CHANGELOG.md`
#'   - CHANGELOG.md, CHANGELOG.txt, CHANGELOG
#' * `docs/CODE_OF_CONDUCT.md`
#'   - CODE_OF_CONDUCT.md, CODE_OF_CONDUCT.txt, CODE_OF_CONDUCT
#' * `docs/LICENSE.md`
#'   - LICENSE.md, LICENSE.txt, LICENSE
#' * `docs/LICENCE.md`
#'   - LICENCE.md, LICENCE.txt, LICENCE
#'
#' @return NULL
#' @template altdoc_variables
#' @template altdoc_preambles
#' @template altdoc_freeze
#' @template altdoc_autolink
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
render_docs <- function(path = ".", verbose = FALSE, parallel = FALSE, freeze = FALSE, ...) {

  # Quarto sometimes raises errors encouraging users to set `quiet=FALSE` to get more information. 
  # This is a convenience check to match Quarto's `quiet` and `altdoc`'s `verbose` arguments.
  dots <- list(...)
  if ("quiet" %in% names(dots) && is.logical(dots[["quiet"]]) && isTRUE(length(dots[["quiet"]]) == 1)) {
    verbose <- !dots[["quiet"]]
  }

  path <- .convert_path(path)
  tool <- .doc_type(path)
  dir_altdoc <- fs::path_join(c(path, "altdoc"))

  if (!fs::dir_exists(dir_altdoc) || length(fs::dir_ls(dir_altdoc)) == 0) {
    cli::cli_abort("No settings file found in {dir_altdoc}. Consider running {.code setup_docs()}.")
  }

  # build quarto in a separate folder to use the built-in freeze functionality
  # and to allow moving the _site folder to docs/
  if (tool == "quarto_website") {
    docs_dir <- fs::path_join(c(path, "_quarto"))

    # Delete everything in `_quarto/` besides `_freeze/`
    if (fs::dir_exists(docs_dir)) {
      docs_files <- fs::dir_ls(docs_dir)
      if (freeze == TRUE) {
        docs_files <- Filter(function(f) basename(f) != "_freeze", docs_files)
      } 
      fs::file_delete(docs_files)
    }

  } else {
    docs_dir <- fs::path_join(c(path, "docs"))
  }

  # create `docs_dir/`
  fs::dir_create(docs_dir)

  cli::cli_h1("Basic files")  
  basics <- c("NEWS", "CHANGELOG", "ChangeLog", "CODE_OF_CONDUCT", "LICENSE", "LICENCE")
  for (b in basics) {
    .import_basic(src_dir = path, tar_dir = docs_dir, name = b)
  }
  .import_readme(src_dir = path, tar_dir = docs_dir, tool = tool, freeze = freeze)
  .import_citation(src_dir = path, tar_dir = docs_dir)


  # Update functions reference
  cli::cli_h1("Man pages")
  fail_man <- .import_man(src_dir = path, tar_dir = docs_dir, tool = tool, verbose = verbose, parallel = parallel, freeze = freeze)

  # Update vignettes
  cli::cli_h1("Vignettes")
  fail_vignettes <- .import_vignettes(src_dir = path, tar_dir = docs_dir, tool = tool, verbose = verbose, parallel = parallel, freeze = freeze)


  # Error so that CI fails
  if (length(fail_vignettes) > 0 & length(fail_man) > 0) {
    cli::cli_abort("There were some failures when rendering vignettes and man pages.")
  } else if (length(fail_vignettes) > 0 & length(fail_man) == 0) {
    cli::cli_abort("There were some failures when rendering vignettes.")
  } else if (length(fail_vignettes) == 0 & length(fail_man) > 0) {
    cli::cli_abort("There were some failures when rendering man pages.")
  }

  cli::cli_h1("Update HTML")
  .import_settings(path = path, tool = tool, verbose = verbose, freeze = freeze)

  cli::cli_h1("Complete")
  cli::cli_alert_success("Documentation updated.")
}

