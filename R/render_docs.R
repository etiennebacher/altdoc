#' Update documentation
#'
#' Render and update the function reference manual, vignettes, README, NEWS, CHANGELOG, LICENSE,
#' and CODE_OF_CONDUCT sections, if they exist. This function overwrites the
#' content of the 'docs/' folder. See details below.
#'
#' @param verbose Logical. Print Rmarkdown or Quarto rendering output.
#' @param parallel Logical. Render man pages and vignettes in parallel using the `future` framework. In addition to setting this argument to TRUE, users must define the parallelism plan in `future`. See the examples section below.
#' @param freeze Logical. If TRUE and a man page or vignette has not changed since the last call to `render_docs()`, that file is skipped. File hashes are stored in `altdoc/freeze.rds`. If that file is deleted, all man pages and vignettes will be rendered anew.
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
render_docs <- function(verbose = FALSE, parallel = FALSE, freeze = FALSE) {

  .check_is_package(getwd())

  if (!fs::dir_exists("altdoc") || length(fs::dir_ls("altdoc")) == 0) {
    cli::cli_abort("No settings file found in `altdoc`. Consider running {.code setup_docs()}.")
  }

  tool <- .doc_type()

  # build quarto in a separate folder to use the built-in freeze functionality
  # and to allow moving the _site folder to docs/
  if (tool == "quarto_website") {
    docs_dir <- "_quarto"
    # avoid collisions
    if (fs::dir_exists("_quarto")) {
      fs::dir_delete("_quarto")
    }
    .add_gitignore("^_quarto$")
  } else {
    docs_dir <- "docs"
  }

  # create docs/
  if (!fs::dir_exists(docs_dir)) {
    fs::dir_create(docs_dir)
  }

  cli::cli_h1("Basic files")


  basics <- c("NEWS", "CHANGELOG", "ChangeLog", "CODE_OF_CONDUCT", "LICENSE", "LICENCE")
  for (b in basics) {
    .import_basic(tar_dir = docs_dir, name = b)
  }
  .import_readme(tar_dir = docs_dir)
  .import_citation(tar_dir = docs_dir)


  # Update functions reference
  cli::cli_h1("Man pages")
  .import_man(tar_dir = docs_dir, verbose = verbose, parallel = parallel, freeze = freeze)

  # Update vignettes
  cli::cli_h1("Vignettes")
  .import_vignettes(tar_dir = docs_dir, verbose = verbose, parallel = parallel, freeze = freeze)

  cli::cli_h1("Update HTML")
  .import_settings(verbose = verbose, freeze = freeze)

  cli::cli_h1("Complete")
  cli::cli_alert_success("Documentation updated.")
}

