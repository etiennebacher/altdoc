#' Update documentation
#'
#' Update README, Changelog, License, Code of Conduct, and Reference sections (if
#' they exist). Convert and add new of modified vignettes to the documentation.
#' This will leave every other files unmodified.
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
update_docs <- function() {

  good_path <- doc_path()

  cli::cli_h1("Update basic files")

  # Update README
  update_file("README.md")
  move_img_readme()
  replace_img_paths_readme()
  reformat_md(paste0(good_path, "/README.md"))

  # Update changelog, CoC, License
  update_file(which_news())
  update_file("CODE_OF_CONDUCT.md")
  update_file(which_license())

  # Update functions reference
  make_reference()
  cli::cli_alert_success("Functions reference have been updated.")

  cli::cli_alert_info("Some files might have been reformatted. Get more info with {.code ?altdoc:::reformat_md}.")
  cli::cli_alert_success("Documentation updated. See {.code ?altdoc::update_docs} to know what files are concerned.")

  # Update vignettes
  cli::cli_h1("Update vignettes")
  transform_vignettes()
  add_vignettes()

}

# Check that file exists:
# - if it doesn't, info message
# - if it does, check whether file is in docs:
#     - if it isn't, copy it there.
#     - if it is, check whether it changed:
#         - if it changed: overwrite it
#         - if it didn't: info message

update_file <- function(filename) {

  filename_message <- if (grepl("NEWS|News|CHANGELOG|Changelog", filename, ignore.case = TRUE)) {
    "NEWS / Changelog"
  } else if (grepl("License|Licence", filename, ignore.case = TRUE)) {
    "License / Licence"
  } else if (grepl("conduct", filename, ignore.case = TRUE)) {
    "Code of Conduct"
  } else if (grepl("README", filename, ignore.case = TRUE)) {
    "README"
  }

  if (!fs::file_exists(filename)) {
    cli::cli_alert_info("No {.file {filename_message}} to include.")
    return(invisible())
  }

  orig_file <- filename
  docs_file <- paste0(doc_path(), "/", filename)
  file_to_edit <- if (doc_type() == "docute") {
    "docs/index.html"
  } else if (doc_type() == "docsify") {
    "docs/_sidebar.md"
  } else if (doc_type() == "mkdocs") {
    "docs/mkdocs.yml"
  }

  if (fs::file_exists(docs_file)) {
    x <- readLines(orig_file, warn = FALSE)
    y <- readLines(docs_file, warn = FALSE)
    if (identical(x, y)) {
      cli::cli_alert_info("No changes in {.file {filename_message}}.")
      return(invisible())
    } else {
      cli::cli_alert_success("{.file {filename_message}} updated.")
    }
  } else {
    cli::cli_alert_info("{.file {filename_message}} was imported for the first time. You should also update {.file {file_to_edit}}.")
  }

  fs::file_copy(orig_file, docs_file, overwrite = TRUE)
  reformat_md(docs_file)
}

# Detect how licence files is called: "LICENSE" or "LICENCE"
# If no license, return "license" for cli message in update_file()
which_license <- function() {

  x <- list.files(pattern = "\\.md$")
  license <- x[which(grepl("license", x, ignore.case = TRUE))]
  licence <- x[which(grepl("licence", x, ignore.case = TRUE))]
  if (length(license) == 1) {
    return(license)
  } else if (length(licence) == 1) {
    return(licence)
  } else {
    return("license")
  }

}

# Detect how news files is called: "NEWS" or "CHANGELOG"
# If no news, return "news" for cli message in update_file()
which_news <- function() {

  x <- list.files(pattern = "\\.md$")
  news <- x[which(grepl("news", x, ignore.case = TRUE))]
  changelog <- x[which(grepl("changelog", x, ignore.case = TRUE))]
  if (length(news) == 1) {
    return(news)
  } else if (length(changelog) == 1) {
    return(changelog)
  } else {
    return("news")
  }

}
