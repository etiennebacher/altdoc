#' Preview the documentation in a webpage or in viewer
#'
#' @param path Path. Default is the package root (detected with `here::here()`).
#' @export
#'
#' @return No value returned. If RStudio is used, it shows a site preview in
#' Viewer.
#'
#' @examples
#'
#' \dontrun{
#' # Preview documentation
#' preview()
#' }

preview <- function(path = ".") {

  if (rstudioapi::isAvailable()) {
    if (fs::file_exists(paste0(path, "/docs/index.html"))) {
      servr::httw(paste0(path, "/docs/"))
    } else if (fs::file_exists(paste0(path, "/docs/site/index.html"))) {
      # first build
      # parenthesis in bash script keep "cd docs" only temporary
      system(paste0("(cd ", path, "/docs && mkdocs build -q)"))
      # stop it directly to avoid opening the browser
      servr::daemon_stop()

      # getwd has to be used outside of httw, not working otherwise
      servr::httw(
        paste0(path, "/docs/site"),
        watch = paste0(path, "/docs/"),
        handler = function(files) {
          system("cd .. && mkdocs build -q")
        }
      )
    } else {
      cli::cli_alert_danger("{.file index.html} was not found. You can run one of {.code altdoc::use_*} functions to create it.")
    }
  } else {
    if (fs::file_exists(paste0(path, "/docs/index.html"))) {
      utils::browseURL(paste0(path, "/docs/index.html"))
    } else if (fs::file_exists(paste0(path, "/docs/site/index.html"))) {
      utils::browseURL(paste0(path, "/docs/site/index.html"))
    }
  }
}
