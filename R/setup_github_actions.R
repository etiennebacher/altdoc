#' Create a Github Actions workflow
#'
#' This function creates a Github Actions workflow in
#' ".github/workflows/altdoc.yaml". This workflow will automatically render the
#' website using the setup specified in the folder "altdoc" and will push the
#' output to the branch "gh-pages".
#'
#'
#' @return No value returned. Creates the file ".github/workflows/altdoc.yaml"
#' @export
#'
#' @examples
#' if (interactive()) {
#'   setup_github_actions()
#' }
setup_github_actions <- function() {

  .check_is_package(getwd())

  tar_file <- ".github/workflows/altdoc.yaml"

  if (!fs::dir_exists(".github/workflows")) {
    fs::dir_create(".github/workflows")
  }
  if (fs::file_exists(tar_file)) {
    cli::cli_abort("{.file .github/workflows/altdoc.yaml} already exists.")
  }

  fs::file_copy(
    system.file("gha/altdoc.yaml", package = "altdoc"),
    ".github/workflows/altdoc.yaml"
  )

  # Deal with mkdocs installation in workflow
  doctype <- .doc_type()
  workflow <- .readlines(tar_file)
  start <- grep("\\$ALTDOC_MKDOCS_START", workflow)
  end <- grep("\\$ALTDOC_MKDOCS_END", workflow)
  if (doctype == "mkdocs") {
    workflow <- workflow[-c(start, end)]
  } else {
    workflow <- workflow[-(start:end)]
  }
  writeLines(workflow, tar)

  invisible(desc::desc_set_dep("altdoc", "Suggests"))

  cli::cli_alert_success("{.file .github/workflows/altdoc.yaml} created.")
  cli::cli_alert_success("Added {.code altdoc} in Suggests.")
}

