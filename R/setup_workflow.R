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
#'   setup_workflow()
#' }
setup_workflow <- function(path = ".") {

  if (!fs::dir_exists(".github/workflows")) {
    fs::dir_create(".github/workflows")
  }
  path <- .convert_path(path)

  src <- system.file("misc/altdoc.yaml", package = "altdoc")
  tar <- fs::path_join(c(path, ".github/workflows/altdoc.yaml"))
  fs::file_copy(src, tar)

  # Deal with mkdocs installation in workflow
  doctype <- .doc_type(path)
  workflow <- .readlines(tar)
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
