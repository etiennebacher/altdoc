#' Preview the documentation in a webpage or in viewer
#'
#' @export
#' @examples

preview <- function() {

  if (!fs::file_exists("docs/index.html")) {
    message_error("index.html was not found.
                  You can run one of `altdoc::use_*` functions to create it.")
  }

  servr::httw("docs/")

}
