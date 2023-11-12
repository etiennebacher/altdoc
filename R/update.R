#' Update documentation
#'
#' Update README, Changelog, License, Code of Conduct, and Reference sections (if
#' they exist). Convert and add new of modified vignettes to the documentation.
#' This will leave every other files unmodified.
#'
#' @param path Path. Default is the package root (detected with `here::here()`).
#' @param custom_reference Path to the file that will be sourced to generate the
#' @param quarto TRUE to use the new Quarto engine to render Rd files.
#' "Reference" section.
#'
#' @export
#'
#' @return No value returned. Updates files in folder 'docs'.
#'
#' @examples
#' if (interactive()) {
#'   # Update documentation
#'   update_docs()
#' }
update_docs <- function(path = ".",
                        custom_reference = NULL,
                        quarto = FALSE) {
  path <- .convert_path(path)
  good_path <- .doc_path(path)

  if (!fs::dir_exists(good_path)) {
    fs::dir_create(good_path)
    cli::cli_alert_danger("Folder {.file docs} doesn't exist. You must create it with one of the {.code use_*()} functions first.")
    return(invisible())
  }

  cli::cli_h1("Update basic files")

  # basic files
  .import_readme(path)
  .import_news(path)
  .import_license(path)
  .import_coc(path)

  # version number
  if (.need_to_bump_version(path)) {
    .update_version_number(path)
    cli::cli_alert_success("Bumped version in documentation footer.")
  }
  if (.need_to_bump_altdoc_version(path)) {
    .update_altdoc_version_number(path)
  }

  # Update functions reference
  .import_man(update = TRUE, path, custom_reference, quarto = quarto)

  # Update vignettes
  cli::cli_h1("Update vignettes")
  .import_vignettes(path)
  .add_vignettes(path)

  cli::cli_h1("Complete")
  cli::cli_alert_success("Documentation updated.")
  cli::cli_alert_info("See {.code ?altdoc::update_docs} to know what files are concerned.")
  cli::cli_alert_info("Some files might have been reformatted. Get more info with {.code ?altdoc:::.reformat_md}.")
}

# Check that file exists:
# - if it doesn't, info message
# - if it does, check whether file is in docs:
#     - if it isn't, copy it there.
#     - if it is, check whether it changed:
#         - if it changed: overwrite it
#         - if it didn't: info message

.update_file <- function(file, path = ".", first = FALSE) {
  file_message <- if (file == "NEWS.md") {
    "NEWS / Changelog"
  } else if (file == "LICENSE.md") {
    "License / Licence"
  } else if (file == "CODE_OF_CONDUCT.md") {
    "Code of Conduct"
  } else if (file == "README.md") {
    "README"
  }

  orig_file <- if (file == "NEWS.md") {
    .which_news()
  } else if (file == "LICENSE.md") {
    .which_license()
  } else {
    fs::path_abs(file, start = path)
  }
  docs_file <- paste0(.doc_path(path), "/", file)
  file_to_edit <- if (.doc_type(path) == "docute") {
    fs::path_abs("docs/index.html", start = path)
  } else if (.doc_type(path) == "docsify") {
    fs::path_abs("docs/_sidebar.md", start = path)
  } else if (.doc_type(path) == "mkdocs") {
    fs::path_abs("docs/mkdocs.yml", start = path)
  }

  if (is.null(orig_file) || !fs::file_exists(orig_file)) {
    cli::cli_alert_info("No {.file {file_message}} to include.")
    return(invisible())
  }

  if (fs::file_exists(docs_file)) {
    x <- .readlines(orig_file)
    y <- .readlines(docs_file)
    if (identical(x, y)) {
      cli::cli_alert_info("No changes in {.file {file_message}}.")
      return(invisible())
    } else {
      cli::cli_alert_success("{.file {file_message}} updated.")
    }
  } else {
    cli::cli_alert_info("{.file {file_message}} was imported for the first time. You should also update {.file {file_to_edit}}.")
  }

  fs::file_copy(orig_file, docs_file, overwrite = TRUE)
  .reformat_md(docs_file, first = first)
}

.update_version_number <- function(path) {
  .doc_type <- .doc_type(path)
  if (.doc_type %in% c("docute", "docsify")) {
    index <- .readlines("docs/index.html")
    index2 <- gsub("\\t", "", index)
    index2 <- trimws(index2)
    if (.doc_type == "docsify") {
      footer <- grep("^var footer =", index2)
    } else if (.doc_type == "docute") {
      footer <- grep("^footer:", index2)
    }
    if (length(footer) != 1) {
      return(invisible)
    }
    old_footer <- .get_footer(path)
    new_footer <- gsub(.doc_version(path), .pkg_version(path), old_footer)
    index[footer] <- new_footer
    writeLines(index, "docs/index.html")
  } else if (.doc_type == "mkdocs") {
    # TODO ? Or is it linked to the github page ?
  }
}

.update_altdoc_version_number <- function(path) {
  .doc_type <- .doc_type(path)
  if (.doc_type %in% c("docute", "docsify")) {
    index <- .readlines("docs/index.html")
    index2 <- gsub("\\t", "", index)
    index2 <- trimws(index2)
    if (.doc_type == "docsify") {
      footer <- grep("^var footer =", index2)
    } else if (.doc_type == "docute") {
      footer <- grep("^footer:", index2)
    }
    if (length(footer) != 1) {
      return(invisible)
    }
    old_footer <- .get_footer(path)
    new_footer <- gsub(
      .altdoc_version_in_footer(path),
      .altdoc_version(),
      old_footer
    )
    index[footer] <- new_footer
    writeLines(index, "docs/index.html")
  } else if (.doc_type == "mkdocs") {
    # TODO ? Or is it linked to the github page ?
  }
}
