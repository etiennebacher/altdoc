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
    } else if (fs::file_exists("docs/site/index.html")) { # for mkdocs
       # need to rebuild each time
      servr::httw("docs/site", handler = system("cd docs && mkdocs build -q"))
    } else {
      message_error("index.html was not found. You can run one of
                    `altdoc::use_*` functions to create it.")
    }
  } else {
    message_error("This function only works in RStudio.")
  }


}
