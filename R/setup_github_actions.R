#' Create a Github Actions workflow
#'
#' This function creates a Github Actions workflow in
#' ".github/workflows/altdoc.yaml". This workflow will automatically render the
#' website using the setup specified in the folder "altdoc" and will push the
#' output to the branch "gh-pages".
#'
#' @inheritParams render_docs
#'
#' @return No value returned. Creates the file ".github/workflows/altdoc.yaml"
#' @export
#'
#' @examples
#' if (interactive()) {
#'   setup_github_actions()
#' }
setup_github_actions <- function(path = ".") {

  path <- .convert_path(path)
  fs::dir_create(fs::path_join(c(path, ".github/workflows")))
  if (fs::file_exists(fs::path_join(c(path, ".github/workflows/altdoc.yaml")))) {
    cli::cli_abort("{.file .github/workflows/altdoc.yaml} already exists.")
  }

  src <- system.file("gha/altdoc.yaml", package = "altdoc")
  tar <- fs::path_join(c(path, ".github/workflows/altdoc.yaml"))
  fs::file_copy(src, tar)

  # Deal with mkdocs installation in workflow
  tool <- .doc_type(path)
  workflow <- .readlines(tar)
  start <- grep("\\$ALTDOC_MKDOCS_START", workflow)
  end <- grep("\\$ALTDOC_MKDOCS_END", workflow)
  if (tool == "mkdocs") {
    workflow <- workflow[-c(start, end)]
  } else {
    workflow <- workflow[-(start:end)]
  }
  writeLines(workflow, tar)

  invisible(desc::desc_set_dep("altdoc", "Suggests"))

  cli::cli_alert_success("{.file .github/workflows/altdoc.yaml} created.")
  cli::cli_alert_success("Added {.code altdoc} in Suggests.")
}

