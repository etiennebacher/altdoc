#' Preview the documentation in a webpage or in viewer
#'
#' @export
#'
#' @return No value returned. If RStudio is used, it shows a site preview in Viewer.
#'
#' @examples
#'
#' \dontrun{
#' # Preview documentation
#' preview()
#' }

preview <- function() {

  if (rstudioapi::isAvailable()) {
    if (fs::file_exists("docs/index.html")) {
      servr::httw("docs/")
    } else if (fs::file_exists("docs/site/index.html")) {
      # first build
      # parenthesis in bash script keep "cd docs" only temporary
      system("(cd docs && mkdocs build -q)")
      # stop it directly to avoid opening the browser
      servr::daemon_stop()

      # getwd has to be used outside of httw, not working otherwise
      path <- getwd()
      servr::httw(
        "docs/site",
        watch = paste0(path, "/docs/"),
        handler = function(files) {
          system("cd .. && mkdocs build -q")
        }
      )
    } else {
      cli::cli_alert_danger("index.html was not found. You can run one of `altdoc::use_*` functions to create it.")
    }
  } else {
    cli::cli_alert_danger("This function only works in RStudio.")
  }


}
