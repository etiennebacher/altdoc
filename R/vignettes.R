# Transform vignettes to produce Markdown
#
# Transform vignettes to produce Markdown instead of HTML.
#
# Vignettes files (originally placed in the folder "Vignettes") have the output
# "html_vignette", instead of Markdown. This function makes several things:
# * moves the .Rmd files from the "vignettes" folder in "docs/articles"
# * replaces the "output" argument of each .Rmd file (in "docs/articles") so
#  that it is "md_document" instead of "html_vignette"
# * render all of the modified .Rmd files (in "docs/articles"), which produce .md files.

.transform_vignettes_rmd <- function(path = path) {

  vignettes_path <- fs::path_abs("vignettes", start = path)

  if (!file.exists(vignettes_path) | .folder_is_empty(vignettes_path)) {
    cli::cli_alert_info("No vignettes to convert")
    return(invisible())
  }

  articles_path <- fs::path_join(c(.doc_path(path = path), "/articles"))
  vignettes <- list.files(vignettes_path, pattern = ".Rmd$")

  if (!dir.exists(articles_path)) {
    fs::dir_create(articles_path)
  }

  n <- length(vignettes)

  # can't use message_info with {}
  cli::cli_alert_info("Found {n} vignette{?s} to convert.")
  i <- 0
  cli::cli_progress_step("Converting {cli::qty(n)}vignette{?s}: {i}/{n}", spinner = TRUE)

  conversion_worked <- vector(length = n)

  fs::dir_copy(vignettes_path, articles_path)
  vignettes_path2 <- fs::path_join(c(articles_path, "/vignettes/"))
  figure_path <- fs::path_join(c(articles_path, "/figures/"))

  if (fs::dir_exists(figure_path)) {
    fs::dir_delete(figure_path)
  }
  file.rename(vignettes_path2, figure_path)

  for (i in seq_along(vignettes)) {
    j <- vignettes[i] # do that for cli progress step
    origin <- fs::path_join(c(figure_path, j))
    destination <- fs::path_join(c(articles_path, j))
    output_file <- gsub("\\.Rmd$", ".md", j)

    tryCatch(
      {
        suppressMessages(
          suppressWarnings(
            rmarkdown::render(
              origin,
              output_format = "github_document",
              quiet = TRUE,
              envir = new.env()
            )
          )
        )
        conversion_worked[i] <- TRUE
      },

      error = function(e) {
        fs::file_delete(destination)
        conversion_worked[i] <- FALSE
      }
    )

    md_file <- fs::path_join(c(figure_path, output_file))
    fs::file_move(md_file, articles_path)

    cli::cli_progress_update()
  }

  .replace_figures_rmd()

  successes <- which(conversion_worked == TRUE)
  fails <- which(conversion_worked == FALSE)

  cli::cli_progress_done()
  # indent bullet points
  cli::cli_div(theme = list(ul = list(`margin-left` = 2, before = "")))

  if (length(successes) > 0) {
    cli::cli_par()
    cli::cli_end()
    cli::cli_alert_success("{cli::qty(length(successes))}The following vignette{?s} ha{?s/ve} been converted and put in {.file {articles_path}}:")
    cli::cli_ul(id = "list-success")
    for (i in seq_along(successes)) {
      cli::cli_li("{.file {vignettes[successes[i]]}}")
    }
    cli::cli_par()
    cli::cli_end(id = "list-success")
  }

  if (length(fails) > 0) {
    cli::cli_par()
    cli::cli_end()
    cli::cli_alert_danger("{cli::qty(length(successes))}The conversion failed for the following vignette{?s}:")
    cli::cli_ul(id = "list-fail")
    for (i in seq_along(fails)) {
      cli::cli_li("{.file {vignettes[fails[i]]}}")
    }
    cli::cli_par()
    cli::cli_end(id = "list-fail")
  }

  cli::cli_alert_info("The folder {.file {'vignettes'}} was not modified.")

}



.transform_vignettes_qmd <- function(path = ".") {
  if (!isTRUE(.dir_is_package(path))) {
    stop("This function must be run from the root of a package.", .call = FALSE)
  }

  if (!fs::dir_exists("vignettes")) {
    return(invisible())
  }

  # create destination directory if it does not exist
  fs::dir_create(c(.doc_path(path = path), "vignettes"))

  # copy all directories: images, static files, etc.
  dir_names <- Filter(fs::is_dir, fs::dir_ls("vignettes"))
  for (d in dir_names) {
    fs::dir_copy(
      d, 
      fs::path_join(c(.doc_path(path = path), "vignettes", basename(d))),
      overwrite = TRUE)
  }

  # copy all quarto vignettes
  file_names <- list.files("vignettes", pattern = "\\.qmd$")
  for (f in file_names) {
    src <- fs::path_join(c("vignettes", f))
    des <- fs::path_join(c(.doc_path(path = path), "vignettes", f))
    fs::file_copy(src, des, overwrite = TRUE)
    .qmd_to_md(des)
    fs::file_delete(des)
  }
}




# Get titles and filenames of the vignettes and returns them in a dataframe
# with two columns: title and link.
# This is used to update the sidebar/navbar in the docs.

.get_vignettes_titles <- function(path = path) {

  vignettes_path <- fs::path_abs("vignettes", start = path)

  if (!file.exists(vignettes_path) | .folder_is_empty(vignettes_path)) {
    return(invisible())
  }

  good_path <- .doc_path(path = path)
  vignettes <- list.files(fs::path_join(c(good_path, "/articles/figures")), pattern = ".Rmd")

  vignettes_title <- data.frame(title = NULL, link = NULL)
  for (i in seq_along(vignettes)) {
    x <- .readlines(fs::path_join(c(good_path, "/articles/figures/", vignettes[i])))
    title <- x[startsWith(x, "title: ")]
    title <- gsub("title: ", "", title)
    vignettes_title[i, "title"] <- title

    link <- fs::path_join(c("/articles/", vignettes[i]))
    link <- gsub("\\.Rmd", "\\.md", link)
    vignettes_title[i, "link"] <- link
  }

  return(vignettes_title)
}

# Add vignettes in the index/sidebar/yaml depending on the tool used.
# This creates a section "Articles" with every vignettes in docs/articles

.add_vignettes <- function(path = path) {
  doctype <- .doc_type(path = path)
  vignettes_titles <- .get_vignettes_titles(path = path)

  if (is.null(vignettes_titles)) {
    return(invisible())
  }

  if (!nrow(vignettes_titles) >= 1) {
    return(invisible())
  }

  if (doctype == "docute") {

    original_index <- .readlines(fs::path_abs("docs/index.html", start = path))

    if (any(grepl("title: \"Articles\"", original_index))) {
      cli::cli_alert_info("New vignettes were not added automatically in {.file {'docs/index.html'}}. You need to do it manually.")
      return(invisible())
    }

    home_line <- which(grepl("\\{title: 'Home', link: '/'\\}", original_index))

    .assert_dependency("jsonlite", install = TRUE)
    original_index[home_line] <- paste0(
      original_index[home_line],
      "\n{
					   title: \"Articles\",
					   children:",
      jsonlite::toJSON(vignettes_titles, pretty = TRUE),
      "},\n"
    )

    writeLines(original_index, fs::path_abs("docs/index.html", start = path))

  } else if (doctype == "docsify") {

    original_sidebar <- .readlines(fs::path_abs("docs/_sidebar.md", start = path))

    # Remove the articles / vignettes section to avoid duplicates
    if (any(grepl("^\\* \\[Articles\\]\\(\\)", original_sidebar))) {
      vignette_start <- grep("^\\* \\[Articles\\]\\(\\)", original_sidebar)
      vignette_end <- grep("^\\* \\[", original_sidebar)
      vignette_end <- vignette_end[vignette_end > vignette_start][1]-1
      original_sidebar <- original_sidebar[-c(vignette_start:vignette_end)]
    }

    # Insert articles section just below home
    home_line <- which(grepl("\\[Home\\]", original_sidebar))
    original_sidebar[home_line] <- paste0(
      original_sidebar[home_line],
      "\n* [Articles]()",
      paste("\n  * [", vignettes_titles$title, "](", vignettes_titles$link, ")",
            collapse = "", sep = "")
    )

    writeLines(original_sidebar, fs::path_abs("docs/_sidebar.md", start = path))

  } else if (doctype == "mkdocs") {

    vignettes_titles$link <- gsub("/articles", "articles", vignettes_titles$link)

    original_yaml <- suppressWarnings(
      yaml::read_yaml(fs::path_abs("docs/mkdocs.yml", start = path))
    )

    # If articles are in the navbar, remove them, so that there is no duplicates
    nav_sections <- unlist(lapply(original_yaml$nav, names))
    # I will put reference in a section at the end
    if ("Articles" %in% nav_sections) {
      original_yaml$nav[[which(nav_sections == "Articles")]] <- NULL
    }
    if ("articles" %in% nav_sections) {
      original_yaml$nav[[which(nav_sections == "articles")]] <- NULL
    }

    # yaml::as.yaml doesn't format plugins well when there is only one plugin
    if (length(original_yaml$plugins) == 1) {
      original_yaml$plugins <- list(original_yaml$plugins)
    }

    # Create section "Articles" and add vignettes in it
    list_articles <- list("Articles" = NULL)
    for (i in 1:nrow(vignettes_titles)) {
      x <- list(vignettes_titles[i, 2])
      names(x) <- paste0(vignettes_titles[i, 1])
      list_articles[["Articles"]] <- append(
        list_articles[["Articles"]], x, length(list_articles[["Articles"]])
      )
    }

    new_nav <- append(original_yaml$nav, list(list_articles), 1)
    original_yaml$nav <- new_nav
    new_yaml <- yaml::as.yaml(original_yaml)

    # yaml::as.yaml is quite inconsistent with indents and dash, especially with
    # plugins, so I fix indents and dashes only for things after plugin (i.e
    # plugins and nav)
    # TODO: find a more robust solution
    before_plugin <- gsub("plugins:.*", "", new_yaml)
    after_plugin <- gsub(".*?(plugins:)", "\\1", new_yaml)
    after_plugin <- gsub("- ", "  - ", after_plugin)
    after_plugin <- gsub("    ", "    - ", after_plugin)
    after_plugin <- gsub("- -", "-", after_plugin)

    # Put reference and changelog in a section if it isn't already
    if (length(gregexpr("Reference:", after_plugin)[[1]]) == 1) {
      after_plugin <- gsub("Reference:", "Reference:\n    - Reference:", after_plugin)
    }
    if (length(gregexpr("Changelog:", after_plugin)[[1]]) == 1) {
      after_plugin <- gsub("Changelog:", "Changelog:\n    - Changelog:", after_plugin)
    }
    new_yaml <- paste(before_plugin, after_plugin, sep = "")

    writeLines(new_yaml, fs::path_abs("docs/mkdocs.yml", start = path))
  }

  # file_to_update <- switch(
  #   doctype,
  #   "docute" = fs::path_abs("docs/index.html", start = path),
  #   "docsify" = fs::path_abs("docs/_sidebar.md", start = path),
  #   "mkdocs" = fs::path_abs("docs/mkdocs.yaml", start = path)
  # )
  # cli::cli_alert_warning(
  #   cli::style_bold("Don't forget to check that vignettes are correctly included in {.file {file_to_update}}.")
  # )
}


