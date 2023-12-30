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
#'
#' # This is an example to illustrate that code-generated images are properly
#' # displayed. See the `altdoc` website for a rendered version.
#' with(mtcars, plot(mpg, wt))
#'
preview_docs <- function(path = ".") {
  .assert_dependency("servr", install = TRUE)

  tool <- .doc_type(path)
  if (.folder_is_empty(fs::path_join(c(path, "docs")))) {
    cli::cli_abort("You must render the docs before previewing them. Use {.code altdoc::render_docs()}.")
  }

  servr::httw(fs::path_join(c(path, "docs")))
}
