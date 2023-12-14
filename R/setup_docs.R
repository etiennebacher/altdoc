#' Initialize documentation website settings
#'
#' @description
#' Creates a subdirectory called `altdoc/` in the package root directory to
#' store the settings files used to by one of the documentation generator
#' utilities (`docsify`, `docute`, `mkdocs`, or `quarto_website`). The files in this folder are never
#' altered automatically by `altdoc` unless the user explicitly calls
#' `overwrite=TRUE`. They can thus be edited manually to customize the sidebar and
#' website.
#'
#' @param tool String. "docsify", "docute", "mkdocs", or "quarto_website".
#' @param path Path to the package root directory.
#' @param overwrite Logical. If TRUE, overwrite existing files. Warning: This will completely delete the settings files in the `altdoc` directory, including any customizations you may have made.
#'
#' @export
#'
#' @return NULL
#' @template package_structure
#' @template altdoc_variables
#' @template altdoc_preambles
#'
#' @examples
#' if (interactive()) {
#'
#'   # Create docute documentation
#'   setup_docs(tool = "docute")
#'
#'   # Create docsify documentation
#'   setup_docs(tool = "docsify")
#'
#'   # Create mkdocs documentation
#'   setup_docs(tool = "mkdocs")
#'
#'   # Create quarto website documentation
#'   setup_docs(tool = "quarto_website")
#' }
setup_docs <- function(tool, path = ".", overwrite = FALSE) {

  .safe_copy <- function(src, tar, overwrite) {
    if (fs::file_exists(tar) && !isTRUE(overwrite)) {
      cli::cli_abort(
        "{tar} already exists. Delete it or set `overwrite=TRUE`.",
        .envir = parent.frame(1L)
      )
    } else {
      fs::file_copy(src, tar, overwrite = TRUE)
    }
  }

  # input sanity checks
  if (missing(tool) ||
      !is.character(tool) ||
      length(tool) != 1 ||
      !tool %in% c("docute", "docsify", "mkdocs", "quarto_website")) {
    cli::cli_abort(
      'The `tool` argument must be "docsify", "docute", "mkdocs", or "quarto_website".')
  }

  if (tool == "mkdocs") {
    if (!.venv_exists()) {
      cli::cli_abort(
        c(
          "`altdoc` needs `mkdocs` to be installed in a Python virtual environment.",
          "i" = "Set up a Python venv: {.code python -m venv .venv_altdoc}",
          "i" = "Activate the venv (depends on your OS): {.url https://docs.python.org/3/library/venv.html#how-venvs-work}.",
          "i" = "Install `mkdocs`: {.code pip install mkdocs}"
        )
      )
    }
  }


  # paths
  path <- .convert_path(path)
  .check_is_package(path)
  altdoc_dir <- fs::path_abs(fs::path_join(c(path, "altdoc")))
  docs_dir <- fs::path_abs(fs::path_join(c(path, "docs")))

  if (!fs::dir_exists(altdoc_dir)) {
    cli::cli_alert_info("Creating `altdoc/` directory.")
    fs::dir_create(altdoc_dir)
  } else {
    if (isTRUE(overwrite)) {
      # start from zero when the setup is overwritten
      fs::dir_delete(docs_dir)

      file_names <- c(
        "mkdocs.yml", "quarto_website.yml", "docute.html", "docsify.html", "docsify.md", ".nojekyll", "freeze.rds"
      )
      for (file_name in file_names) {
        file_name <- fs::path_join(c(altdoc_dir, file_name))
        if (fs::file_exists(file_name)) {
          fs::file_delete(file_name)
        }
      }
    } else {
      cli::cli_abort(
        "{.file {altdoc_dir}} already exists. Delete it or set `overwrite=TRUE`."
      )
    }
  }

  if (!fs::dir_exists(docs_dir)) {
    cli::cli_alert_info("Creating `docs/` directory.")
    fs::dir_create(docs_dir)
  }

  .add_rbuildignore("^docs$", path = path)
  .add_rbuildignore("^altdoc$", path = path)
  .add_gitignore("altdoc/freeze.rds", path = path)
  if (tool == "quarto_website") .add_rbuildignore("^_quarto$", path = path)

  cli::cli_alert_info("Importing default settings file(s) to `altdoc/`")

  if (isTRUE(tool == "docsify")) {
    src <- system.file("docsify/docsify.html", package = "altdoc")
    tar <- fs::path_join(c(altdoc_dir, "docsify.html"))
    .safe_copy(src, tar, overwrite = overwrite)

    src <- system.file("docsify/docsify.md", package = "altdoc")
    tar <- fs::path_join(c(altdoc_dir, "docsify.md"))
    .safe_copy(src, tar, overwrite = overwrite)

    tar <- fs::path_join(c(altdoc_dir, ".nojekyll"))
    fs::file_create(tar)

  } else if (isTRUE(tool == "docute")) {
    src <- system.file("docute/docute.html", package = "altdoc")
    tar <- fs::path_join(c(altdoc_dir, "docute.html"))
    .safe_copy(src, tar, overwrite = overwrite)

  } else if (isTRUE(tool == "mkdocs")) {
    src <- system.file("mkdocs/mkdocs.yml", package = "altdoc")
    tar <- fs::path_join(c(altdoc_dir, "mkdocs.yml"))
    .safe_copy(src, tar, overwrite = overwrite)

  } else if (isTRUE(tool == "quarto_website")) {
    src <- system.file("quarto_website/quarto_website.yml", package = "altdoc")
    tar <- fs::path_join(c(altdoc_dir, "quarto_website.yml"))
    .safe_copy(src, tar, overwrite = overwrite)
  }

  # preambles
  # quarto_website render directly to HTML, not via markdown
  if (tool != "quarto_website") {
    .safe_copy(
      system.file("preamble/preamble_vignettes_qmd.yml", package = "altdoc"),
      fs::path_join(c(altdoc_dir, "preamble_vignettes_qmd.yml")),
      overwrite = TRUE)
    .safe_copy(
      system.file("preamble/preamble_vignettes_rmd.yml", package = "altdoc"),
      fs::path_join(c(altdoc_dir, "preamble_vignettes_rmd.yml")),
      overwrite = TRUE)
    .safe_copy(
      system.file("preamble/preamble_man_qmd.yml", package = "altdoc"),
      fs::path_join(c(altdoc_dir, "preamble_man_qmd.yml")),
      overwrite = TRUE)
  }

  # README.md is mandatory
  fn <- fs::path_join(c(path, "README.md"))
  if (!fs::file_exists(fn)) {
    cli::cli_alert_info("README.md is mandatory. `altdoc` created a dummy README file in the package directory.")
    writeLines("Hello World!", fn)
  }

  return(invisible())
}
