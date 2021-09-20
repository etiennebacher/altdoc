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
    if (!fs::file_exists("docs/index.html")) {
      message_error("index.html was not found.
                  You can run one of `altdoc::use_*` functions to create it.")
    }

    servr::httw("docs/")
  } else {
    message_error("This function only works in RStudio.")
  }


}
