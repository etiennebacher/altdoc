#' Update documentation
#'
#' Update README, Changelog, License, Code of Conduct, and Reference sections (if
#' they exist). Convert and add new of modified vignettes to the documentation.
#' This will leave every other files unmodified.
#'
#' @param convert_vignettes Automatically convert and import vignettes if you
#' have some. This will not modify files in the folder 'vignettes'.
#' @param path Path. Default is the package root (detected with `here::here()`).
#'
#' @export
#'
#' @return No value returned. Updates files in folder 'docs'.
#'
#' @examples
#' if (interactive()) {
#' # Update documentation
#' update_docs()
#' }

update_docs <- function(convert_vignettes = TRUE, path = ".") {

  path <- convert_path(path)

  if (!fs::dir_exists(fs::path_abs("docs", start = path))) {
    cli::cli_alert_danger("Folder {.file docs} doesn't exist. You must create it with one of the {.code use_*()} functions first.")
    return(invisible())
  }

  good_path <- doc_path(path = path)

  cli::cli_h1("Update basic files")

  # Update README
  update_file("README.md")
  move_img_readme(path = path)
  replace_img_paths_readme(path = path)
  reformat_md(paste0(good_path, "/README.md"))

  # Update changelog, CoC, License
  update_file("NEWS.md", path = path)
  update_file("CODE_OF_CONDUCT.md", path = path)
  update_file("LICENSE.md", path = path)
  if (need_to_bump_version(path)) {
    update_version_number(path)
    cli::cli_alert_success("Bumped version in documentation footer.")
  }

  # Update functions reference
  make_reference(update = TRUE, path = path)

  # Update vignettes
  if (isTRUE(convert_vignettes)) {
    cli::cli_h1("Update vignettes")
    transform_vignettes(path = path)
    add_vignettes(path = path)
  }

  cli::cli_h1("Complete")
  cli::cli_alert_success("Documentation updated.")
  cli::cli_alert_info("See {.code ?altdoc::update_docs} to know what files are concerned.")
  cli::cli_alert_info("Some files might have been reformatted. Get more info with {.code ?altdoc:::reformat_md}.")

}

# Check that file exists:
# - if it doesn't, info message
# - if it does, check whether file is in docs:
#     - if it isn't, copy it there.
#     - if it is, check whether it changed:
#         - if it changed: overwrite it
#         - if it didn't: info message

update_file <- function(filename, path = ".") {

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
    fs::path_abs(filename, start = path)
  }
  docs_file <- paste0(doc_path(path = path), "/", filename)
  file_to_edit <- if (doc_type(path = path) == "docute") {
    fs::path_abs("docs/index.html", start = path)
  } else if (doc_type(path = path) == "docsify") {
    fs::path_abs("docs/_sidebar.md", start = path)
  } else if (doc_type(path = path) == "mkdocs") {
    fs::path_abs("docs/mkdocs.yml", start = path)
  }

  if (is.null(orig_file) || !fs::file_exists(orig_file)) {
    cli::cli_alert_info("No {.file {filename_message}} to include.")
    return(invisible())
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

update_version_number <- function(path) {
  doc_type <- doc_type(path)
  if (doc_type %in% c("docute", "docsify")) {
    index <- readLines("docs/index.html", warn = FALSE)
    index2 <- gsub("\\t", "", index)
    index2 <- trimws(index2)
    if (doc_type == "docsify") {
      footer <- which(grepl("^var footer =", index2))
    } else if (doc_type == "docute") {
      footer <- which(grepl("^footer:", index2))
    }
    if (length(footer) != 1) return(invisible)
    old_footer <- get_footer(path)
    new_footer <- gsub(doc_version(path), pkg_version(path), old_footer)
    index[footer] <- new_footer
    writeLines(index, "docs/index.html")
  } else if (doc_type == "mkdocs") {
    # TODO ? Or is it linked to the github page ?
  }
}
