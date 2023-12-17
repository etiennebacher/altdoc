#' Preview the documentation in a webpage or in viewer
#'
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
#'
#' # This is an example to illustrate that code-generated images are properly
#' # displayed. See the `altdoc` website for a rendered version.
#' with(mtcars, plot(mpg, wt))
#'
preview_docs <- function() {
  .check_is_package(getwd())
  # conditional dependencies
  .assert_dependency("servr", install = TRUE)
  .assert_dependency("rstudioapi", install = TRUE)

  # .doc_type() checks if setup_docs() was called
  tool <- .doc_type()

  if (.folder_is_empty("docs")) {
    cli::cli_abort("You must render the docs before previewing them. Use {.code altdoc::render_docs()}.")
  }

  if (rstudioapi::isAvailable()) {
    servr::httw("docs")
  } else {
    if (fs::file_exists(fs::path_abs("docs/index.html"))) {
      utils::browseURL(fs::path_abs("docs/index.html"))
    }
  }
}
