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

  # input sanity checks
  if (missing(tool) ||
      !is.character(tool) ||
      length(tool) != 1 ||
      !tool %in% c("docute", "docsify", "mkdocs", "quarto_website")) {
    cli::cli_abort(
      'The `tool` argument must be "docsify", "docute", "mkdocs", or "quarto_website".')
  }

  if (tool == "mkdocs") {
    if (!.venv_exists(path)) {
      cli::cli_abort(
        c(
          "x" = "`altdoc` needs `mkdocs` to be installed in a Python virtual environment. The best way to create the required {.code .venv_altdoc} directory depends on your development environment. It usually involves executing commands like the following from the root directory of your R package.",
          " " = "",
          " " = "On Linux or MacOS:",
          " " = "",
          " " = "python -m venv .venv_altdoc",
          " " = ".venv_altdoc/bin/pip install mkdocs mkdocs-material",
          " " = "",
          " " = "On Windows:",
          " " = "",
          " " = "python -m venv .venv_altdoc",
          " " = ".venv_altdoc\\Scripts\\pip.exe install mkdocs mkdocs-material",
          " " = "",
          "i" = " If these commands do not work or you want learn more, visit this link: {.url https://docs.python.org/3/library/venv.html#how-venvs-work}"
        )
      )
    }
    .add_gitignore(".venv_altdoc", path = path)
    .add_rbuildignore(".venv_altdoc", path = path)
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
      if (isTRUE(fs::dir_exists(docs_dir))) {
        fs::dir_delete(docs_dir)
      }

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
  .add_pkgdown(path = path)
  if (tool == "quarto_website") {
    .add_rbuildignore("^_quarto$", path = path)
    .add_gitignore("_quarto/*", path = path)
    .add_gitignore("!_quarto/_freeze/", path = path)
  }

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
  fn <- "README.md"
  msg <- sprintf("%s is mandatory. `altdoc` created a dummy README file in the package directory.", fn)
  fn <- fs::path_join(c(path, fn))
  if (!fs::file_exists(fn)) {
    cli::cli_alert_info(msg)
    writeLines("Hello World!", fn)
  }
}


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
