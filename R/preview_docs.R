#' Preview the documentation in a webpage or in viewer
#'
#' @inheritParams setup_docs
#' @export
#'
#' @return No value returned. If RStudio is used, it shows a site preview in 
#' Viewer. To preview the site in a browser or in another text editor (ex: VS Code),
#' see the vignette on the `altdoc` website.
#' @examples
#' if (interactive()) {
#' 
#'   preview_docs()
#' 
#' }
preview_docs <- function(path = ".") {
  # conditional dependencies
  # .assert_dependency("servr", install = TRUE)
  # .assert_dependency("rstudioapi", install = TRUE)

  doctype <- .doc_type(path)

  if (rstudioapi::isAvailable()) {
    if (doctype %in% c("docute", "docsify")) {
      servr::httw(fs::path_abs("docs/"))
    } else if (doctype == "mkdocs") {
      # first build
      if (.is_windows()) {
        shell(paste("cd", fs::path_abs("docs", start = path), " && mkdocs build -q"))
      } else {
        system2("cd", paste(fs::path_abs("docs", start = path), " && mkdocs build -q"))
      }
      # stop it directly to avoid opening the browser
      servr::daemon_stop()

      # getwd has to be used outside of httw, not working otherwise
      servr::httw(
        fs::path_abs("docs/site", start = path),
        watch = fs::path_abs("docs/", start = path),
        handler = function(files) {
          system2("cd", ".. && mkdocs build -q")
        }
      )
    } else {
      cli::cli_alert_danger("{.file index.html} was not found. You can run one of {.code altdoc::use_*} functions to create it.")
    }
  } else {
    if (fs::file_exists(fs::path_abs("docs/index.html", start = path))) {
      utils::browseURL(fs::path_abs("docs/index.html", start = path))
    } else if (fs::file_exists(fs::path_abs("docs/site/index.html", start = path))) {
      utils::browseURL(fs::path_abs("docs/site/index.html", start = path))
    }
  }
}