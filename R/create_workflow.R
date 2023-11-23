create_workflow <- function(path = ".") {

  if (!fs::dir_exists(".github/workflows")) {
    fs::dir_create(".github/workflows")
  }
  src <- system.file("misc/altdoc.yml", package = "altdoc")
  tar <- ".github/workflows/altdoc.yml"
  fs::file_copy(src, tar)
  cli::cli_alert_success("{.file .github/workflows/altdoc.yml} created.")
}
