# Check that project is a package -------------------------

.check_is_package <- function(path) {
  if (!.dir_is_package(path)) {
    cli::cli_alert_danger("{.code altdoc} only works in packages.")
    .stop_quietly()
  }
}


# 
# Check that mkdocs/sphinx are installed -------------------------

.check_tools <- function(tool) {
  if (tool == "mkdocs") {
    if (!.is_mkdocs()) {
      cli::cli_alert_danger("Apparently, {.code mkdocs} is not installed on your system.")
      cli::cli_alert_info("You can install it with {.code pip3 install mkdocs} in your terminal.")
      cli::cli_alert_info("More information: {.url https://www.mkdocs.org/user-guide/installation/}")
      .stop_quietly()
    }

  } else if (tool == "sphinx") {
    if (!.is_sphinx()) {
      cli::cli_alert_danger("Apparently, {.code sphinx} is not installed on your system.")
      cli::cli_alert_info("See here to know how to install it: {.url https://www.sphinx-doc.org/en/master/usage/installation.html}")
      .stop_quietly()
    }
  }
}


.check_dependency <- function(library_name) {
  requireNamespace(library_name, quietly = TRUE)
}


.assert_dependency <- function(library_name, install = FALSE) {
  flag <- .check_dependency(library_name)
  msg <- sprintf("This functionality requires the `%s` package.", library_name)
  if (!isTRUE(flag)) {
    if (isTRUE(install)) {
      msg <- sprintf("This functionality requires the `%s` package. Do you want to install it?", library_name)
      if (isTRUE(utils::askYesNo(msg, default = TRUE))) {
        utils::install.packages(library_name)
        return(invisible())
      }
    }
    stop(msg, call. = FALSE)
  }
}
