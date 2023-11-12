# Last things to do in initialization -------------------

.final_steps <- function(x, path = ".", preview = TRUE) {
  if (x == "docute") {
    .final_steps_docute(path)
  } else if (x == "docsify") {
    .final_steps_docsify(path)
  }

  .add_rbuildignore("^docs$")

  cli::cli_h1("Complete")
  cli::cli_alert_success("{tools::toTitleCase(x)} initialized.")
  cli::cli_alert_success("Folder {.file docs} put in {.file .Rbuildignore}.")

  if (interactive() && isTRUE(preview)) {
    cli::cli_par()
    cli::cli_end()
    cli::cli_alert("Running preview...")
    preview()
  }
}


.final_steps_docute <- function(path) {
  index <- .readlines(fs::path_abs("docs/index.html", start = path))
  if (!fs::file_exists(fs::path_abs("NEWS.md", start = path))) {
    index <- index[-which(grepl("/NEWS", index))]
  }
  if (!fs::file_exists(fs::path_abs("LICENSE.md", start = path))) {
    index <- index[-which(grepl("/LICENSE", index))]
  }
  if (!fs::file_exists(fs::path_abs("CODE_OF_CONDUCT.md", start = path))) {
    index <- index[-which(grepl("/CODE_OF_CONDUCT", index))]
  }
  writeLines(index, fs::path_abs("docs/index.html", start = path))
}

.final_steps_docsify <- function(path) {
  sidebar <- .readlines(fs::path_abs("docs/_sidebar.md", start = path))
  if (!fs::file_exists(fs::path_abs("docs/NEWS.md", start = path))) {
    sidebar <- sidebar[-which(grepl("NEWS.md", sidebar))]
  }
  if (!fs::file_exists(fs::path_abs("docs/LICENSE.md", start = path))) {
    sidebar <- sidebar[-which(grepl("LICENSE.md", sidebar))]
  }
  if (!fs::file_exists(fs::path_abs("docs/CODE_OF_CONDUCT.md", start = path))) {
    sidebar <- sidebar[-which(grepl("CODE_OF_CONDUCT.md", sidebar))]
  }
  if (!fs::file_exists(fs::path_abs("docs/reference.md", start = path))) {
    sidebar <- sidebar[-which(grepl("reference.md", sidebar))]
  }
  cat(sidebar, file = fs::path_abs("docs/_sidebar.md", start = path), sep = "\n")
}
