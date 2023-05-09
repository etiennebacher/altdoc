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
#' # Preview documentation
#' preview()

preview <- function(path = ".") {

  doctype <- .doc_type(path)

  if (rstudioapi::isAvailable()) {
    if (doctype %in% c("docute", "docsify")) {

      servr::httw(fs::path_abs("docs/"))

    } else if (doctype == "mkdocs") {

      # first build
      cli::cli_alert_info("Rendering the website...")
      system2("python", paste0("-m mkdocs build -f ",
                               fs::path_abs("docs"),
                               "/mkdocs.yml -q"))
      invisible(capture.output(
        processx::process$new("python", paste0("-m mkdocs serve -f ",
                                               fs::path_abs("docs"),
                                               "/mkdocs.yml"))
      ))

      cli::cli_alert_info("Previewing the website...")
      servr::httw(fs::path_abs("docs/site"))

    } else if (doctype == "quarto") {

      cli::cli_alert_info("Rendering the website...")
      x <- processx::run("quarto", c("render", "docs"), echo = FALSE, spinner = TRUE)
      cli::cli_alert_info("Previewing the website...")
      invisible(capture.output(
        processx::process$new("quarto", c("preview", "docs"))
      ))

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
