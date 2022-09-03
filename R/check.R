# Check that project is a package -------------------------

.check_is_package <- function(path) {
  if (!.dir_is_package(path)) {
    cli::cli_alert_danger("{.code altdoc} only works in packages.")
    .stop_quietly()
  }
}


# Check that folder is empty or doesn't exist -------------------------

.check_docs_exists <- function(overwrite = FALSE, path = ".") {

  path_to_docs <- fs::path_abs("docs", start = path)

  if (fs::dir_exists(path_to_docs) && !.folder_is_empty(path_to_docs)) {
    if (isTRUE(overwrite)) {
      fs::dir_delete(path_to_docs)
    } else {
      delete_docs <- usethis::ui_yeah(
        "Folder {usethis::ui_value('docs')} already exists. Do you want to replace it?"
      )
      if (delete_docs) {
        fs::dir_delete(path_to_docs)
      } else {
        cli::cli_alert_info("Nothing was modified.")
        .stop_quietly()
      }
    }
  }

  if (!fs::dir_exists(path_to_docs)) {
    fs::dir_create(path_to_docs)
  }
}


# Check that mkdocs/sphinx are installed -------------------------

.check_tools <- function(tool, theme) {
  if (tool == "mkdocs") {
    if (!.is_mkdocs()) {
      cli::cli_alert_danger("Apparently, {.code mkdocs} is not installed on your system.")
      cli::cli_alert_info("You can install it with {.code pip3 install mkdocs} in your terminal.")
      cli::cli_alert_info("More information: {.url https://www.mkdocs.org/user-guide/installation/}")
      .stop_quietly()
    }

    if (!is.null(theme) && theme == "material") {
      if (!..is_mkdocs_material()) {
        cli::cli_alert_danger("Apparently, {.code mkdocs-material} is not installed on your system.")
        cli::cli_alert_info("You can install it with {.code pip3 install mkdocs-material} in your terminal.")
        .stop_quietly()
      }
    }
  } else if (tool == "sphinx") {
    if (!.is_sphinx()) {
      cli::cli_alert_danger("Apparently, {.code sphinx} is not installed on your system.")
      cli::cli_alert_info("See here to know how to install it: {.url https://www.sphinx-doc.org/en/master/usage/installation.html}")
      .stop_quietly()
    }
  }
}
