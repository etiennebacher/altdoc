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
  # conditional dependencies
  .assert_dependency("servr", install = TRUE)
  .assert_dependency("rstudioapi", install = TRUE)

  doctype <- .doc_type(path)

  if (rstudioapi::isAvailable()) {
    if (doctype %in% c("docute", "docsify", "mkdocs")) {
      servr::httw(fs::path_abs("docs/"))
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
