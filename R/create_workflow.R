create_workflow <- function(path = ".") {

  if (!fs::dir_exists(".github/workflows")) {
    fs::dir_create(".github/workflows")
  }
  src <- system.file("misc/altdoc.yml", package = "altdoc")
  tar <- ".github/workflows/altdoc.yml"
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

  cli::cli_alert_success("{.file .github/workflows/altdoc.yml} created.")
}
