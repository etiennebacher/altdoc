#' Update documentation
#'
#' Update README, Changelog, License, Code of Conduct, and Reference sections (if
#' they exist). Convert and add new of modified vignettes to the documentation.
#' This will leave every other files unmodified.
#'
#' @param convert_vignettes Automatically convert and import vignettes if you
#' have some. This will not modify files in the folder 'vignettes'.
#'
#' @export
#'
#' @return No value returned. Updates files in folder 'docs'.
#'
#' @examples
#' \dontrun{
#' # Update documentation
#' update_docs()
#' }
update_docs <- function(convert_vignettes = FALSE) {

  good_path <- doc_path()

  cli_h1("Update basic files")

  # Update README
  update_file("README.md")
  move_img_readme()
  replace_img_paths_readme()
  reformat_md(paste0(good_path, "/README.md"))

  # Update changelog, CoC, License
  update_file("NEWS.md")
  update_file("CODE_OF_CONDUCT.md")
  update_file("LICENSE.md")

  # Update functions reference
  make_reference(update = TRUE)

  # Update vignettes
  if (isTRUE(convert_vignettes)) {
    cli_h1("Update vignettes")
    transform_vignettes()
    add_vignettes()
  }

  cli_h1("Complete")
  cli_alert_success("Documentation updated.")
  cli_alert_info("See {.code ?altdoc::update_docs} to know what files are concerned.")
  cli_alert_info("Some files might have been reformatted. Get more info with {.code ?altdoc:::reformat_md}.")

}

# Check that file exists:
# - if it doesn't, info message
# - if it does, check whether file is in docs:
#     - if it isn't, copy it there.
#     - if it is, check whether it changed:
#         - if it changed: overwrite it
#         - if it didn't: info message

update_file <- function(filename) {

  filename_message <- if (filename == "NEWS.md") {
    "NEWS / Changelog"
  } else if (filename == "LICENSE.md") {
    "License / Licence"
  } else if (filename == "CODE_OF_CONDUCT.md") {
    "Code of Conduct"
  } else if (filename == "README.md") {
    "README"
  }

  orig_file <- if (filename == "NEWS.md") {
    which_news()
  } else if (filename == "LICENSE.md") {
    which_license()
  } else {
    filename
  }
  docs_file <- paste0(doc_path(), "/", filename)
  file_to_edit <- if (doc_type() == "docute") {
    "docs/index.html"
  } else if (doc_type() == "docsify") {
    "docs/_sidebar.md"
  } else if (doc_type() == "mkdocs") {
    "docs/mkdocs.yml"
  }

  if (is.null(orig_file) || !file_exists(orig_file)) {
    cli_alert_info("No {.file {filename_message}} to include.")
    return(invisible())
  }

  if (file_exists(docs_file)) {
    x <- readLines(orig_file, warn = FALSE)
    y <- readLines(docs_file, warn = FALSE)
    if (identical(x, y)) {
      cli_alert_info("No changes in {.file {filename_message}}.")
      return(invisible())
    } else {
      cli_alert_success("{.file {filename_message}} updated.")
    }
  } else {
    cli_alert_info("{.file {filename_message}} was imported for the first time. You should also update {.file {file_to_edit}}.")
  }

  file_copy(orig_file, docs_file, overwrite = TRUE)
  reformat_md(docs_file)
}
