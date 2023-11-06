# Create index.html for docute and docsify ------------------

.create_index <- function(x, path = ".") {
  index <- htmltools::htmlTemplate(
    system.file(paste0(x, "/index.html"), package = "altdoc"),
    title = .pkg_name(path),
    footer = sprintf(
      "<hr/><a href='%s'> <code>%s</code> v. %s </a> | Documentation made with <a href='https://github.com/etiennebacher/altdoc'> <code>altdoc</code> v. %s</a>",
      .gh_url(path), .pkg_name(path), .pkg_version(path),
      .altdoc_version()
    ),
    github_link = .gh_url(path)
  )

  # regex stuff to correct footer
  index <- as.character(index)
  index <- gsub("&lt;", "<", index)
  index <- gsub("&gt;", ">", index)
  index <- gsub("\\r\\n", "\\\n", index)

  writeLines(index, fs::path_abs("docs/index.html", start = path))
}



# Import files: README, license, news, CoC ------------------

.import_readme <- function(path = ".") {
  good_path <- .doc_path(path)
  if (fs::file_exists(fs::path_abs("README.md", start = path))) {
    fs::file_copy(
      fs::path_abs("README.md", start = path),
      paste0(good_path, "/README.md"),
      overwrite = TRUE
    )
    cli::cli_alert_success("{.file README} imported.")
  } else {
    fs::file_copy(
      system.file("docsify/README.md", package = "altdoc"),
      paste0(good_path, "/README.md")
    )
    cli::cli_alert_info("No {.file README} found. Created a default {.file docs/README}.")
  }
  .reformat_md(paste0(good_path, "/README.md"))
  .move_img_readme(path = path)
  .replace_img_paths_readme(path = path)
}


.import_news <- function(path = ".") {
  good_path <- .doc_path(path)
  file <- .which_news()
  if (is.null(file)) {
    cli::cli_alert_info("No {.file NEWS / Changelog} to include.")
    return(invisible())
  }
  if (fs::file_exists(file)) {
    fs::file_copy(file, paste0(good_path, "/NEWS.md"))
    .reformat_md(paste0(good_path, "/", file), first = TRUE)
    .parse_news(path, paste0(good_path, "/NEWS.md"))
    cli::cli_alert_success("{.file {file}} imported.")
  }
}


.import_coc <- function(path = ".") {
  good_path <- .doc_path(path)
  if (fs::file_exists("CODE_OF_CONDUCT.md")) {
    fs::file_copy(
      "CODE_OF_CONDUCT.md",
      paste0(good_path, "/CODE_OF_CONDUCT.md")
    )
    cli::cli_alert_success("{.file Code of Conduct} imported.")
  } else {
    cli::cli_alert_info("No {.file Code of Conduct} to include.")
  }
}


.import_license <- function(path = ".") {
  good_path <- .doc_path(path)
  file <- .which_license()
  if (is.null(file)) {
    cli::cli_alert_info("No {.file License / Licence} to include.")
    return(invisible())
  }
  if (fs::file_exists(file)) {
    fs::file_copy(file, paste0(good_path, "/LICENSE.md"))
    cli::cli_alert_success("{.file {file}} imported.")
  }
}



# Build docs and vignettes ---------------------

.build_docs <- function(path = ".", custom_reference = NULL, quarto = FALSE) {
  cli::cli_h1("Docs structure")
  cli::cli_alert_success("Folder {.file docs} created.")
  .import_readme(path)
  .import_news(path)
  .import_coc(path)
  .import_license(path)
  .make_reference(update = FALSE, path, custom_reference, quarto = quarto)
}

.build_vignettes <- function(path) {
  cli::cli_h1("Vignettes")
  .transform_vignettes(path = path)
  .add_vignettes(path = path)
}



# Last things to do in initialization -------------------

.final_steps <- function(x, path = ".") {

  if (x == "docute") {
    .final_steps_docute(path)
  } else if (x == "docsify") {
    .final_steps_docsify(path)
  }

  suppressMessages({
    usethis::use_build_ignore("docs")
  })
  cli::cli_h1("Complete")
  cli::cli_alert_success("{tools::toTitleCase(x)} initialized.")
  cli::cli_alert_success("Folder {.file docs} put in {.file .Rbuildignore}.")

  if (interactive()) {
    cli::cli_par()
    cli::cli_end()
    cli::cli_alert("Running preview...")
    preview()
  }

}


.final_steps_docute <- function(path) {
  index <- .readlines(fs::path_abs("docs/index.html", start = path))
  if (!fs::file_exists(fs::path_abs("NEWS.md", start = path))) {
    index <- index[-which(grepl("/NEWS", index))]
  }
  if (!fs::file_exists(fs::path_abs("LICENSE.md", start = path))) {
    index <- index[-which(grepl("/LICENSE", index))]
  }
  if (!fs::file_exists(fs::path_abs("CODE_OF_CONDUCT.md", start = path))) {
    index <- index[-which(grepl("/CODE_OF_CONDUCT", index))]
  }
  writeLines(index, fs::path_abs("docs/index.html", start = path))
}

.final_steps_docsify <- function(path) {
  sidebar <- .readlines(fs::path_abs("docs/_sidebar.md", start = path))
  if (!fs::file_exists(fs::path_abs("docs/NEWS.md", start = path))) {
    sidebar <- sidebar[-which(grepl("NEWS.md", sidebar))]
  }
  if (!fs::file_exists(fs::path_abs("docs/LICENSE.md", start = path))) {
    sidebar <- sidebar[-which(grepl("LICENSE.md", sidebar))]
  }
  if (!fs::file_exists(fs::path_abs("docs/CODE_OF_CONDUCT.md", start = path))) {
    sidebar <- sidebar[-which(grepl("CODE_OF_CONDUCT.md", sidebar))]
  }
  if (!fs::file_exists(fs::path_abs("docs/reference.md", start = path))) {
    sidebar <- sidebar[-which(grepl("reference.md", sidebar))]
  }
  cat(sidebar, file = fs::path_abs("docs/_sidebar.md", start = path), sep = "\n")
}
