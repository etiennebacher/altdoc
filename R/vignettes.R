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

.transform_vignettes <- function(path = path) {

  vignettes_path <- fs::path_abs("vignettes", start = path)

  if (!file.exists(vignettes_path) | .folder_is_empty(vignettes_path)) {
    cli::cli_alert_info("No vignettes to convert")
    return(invisible())
  }

  good_path <- .doc_path(path = path)
  articles_path <- paste0(good_path, "/articles")

  vignettes <- list.files(vignettes_path, pattern = ".Rmd$")

  if (!file.exists(articles_path)) {
    fs::dir_create(articles_path)
  }

  for (i in seq_along(vignettes)) {
    x <- .manage_child_vignettes(
      paste0(vignettes_path, "/", vignettes[i]),
      path = path
    )
    if (!is.null(x) & x == "stop") return(invisible())
  }

  # needs to be first, otherwise compilation will fail
  .replace_figures_rmd()

  n <- length(vignettes)
  # can't use message_info with {}
  cli::cli_alert_info("Found {n} vignette{?s} to convert.")
  i <- 0
  cli::cli_progress_step("Converting {cli::qty(n)}vignette{?s}: {i}/{n}", spinner = TRUE)

  conversion_worked <- vector(length = n)

  for (i in seq_along(vignettes)) {
    j <- vignettes[i] # do that for cli progress step
    origin <- paste0(vignettes_path, "/", j)
    destination <- paste0(articles_path, "/", j)

    .modify_yaml(destination)
    .extract_import_bib(destination, path = path)
    output_file <- paste0(substr(j, 1, nchar(j)-4), ".md")

    tryCatch(
      {
        suppressMessages(
          suppressWarnings(
            rmarkdown::render(
              destination,
              output_dir = articles_path,
              output_file = output_file,
              quiet = TRUE,
              envir = new.env()
            )
          )
        )

        ### If title too long, it was cut in several lines but only the last
        ### one is read by docute so need to paste the title back together
        new_vignette <- .readlines(gsub("\\.Rmd", "\\.md", destination))
        title_sep <- grep("=====", new_vignette)
        if (length(title_sep) == 1) {
          title <- new_vignette[1:title_sep-1]
          title <- paste(title, collapse = " ")

          # for some reason, having a colon in the title breaks the title when
          # using mkdocs
          if (.doc_type(path = path) == "mkdocs") {
            title <- gsub(":", " - ", title)
          }

          new_vignette <- new_vignette[-c(1:title_sep-1)]
          new_vignette <- c(title, new_vignette)
          writeLines(new_vignette, gsub("\\.Rmd", "\\.md", destination))
        }

        .reformat_md(gsub("\\.Rmd", "\\.md", destination))

        conversion_worked[i] <- TRUE
      },

      error = function(e) {
        fs::file_delete(gsub("\\.md$", "\\.Rmd", destination))
        conversion_worked[i] <- FALSE
      }
    )

    cli::cli_progress_update()
  }

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

  .fix_rmd_figures_path(path)

  cli::cli_alert_info("The folder {.file {'vignettes'}} was not modified.")

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
  vignettes <- list.files(paste0(good_path, "/articles"), pattern = ".Rmd")

  vignettes_title <- data.frame(title = NULL, link = NULL)
  for (i in seq_along(vignettes)) {
    x <- .readlines(paste0(good_path, "/articles/", vignettes[i]))
    title <- x[startsWith(x, "title: ")]
    title <- gsub("title: ", "", title)
    vignettes_title[i, "title"] <- title

    link <- paste0("/articles/", vignettes[i])
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

  file_to_update <- switch(
    doctype,
    "docute" = fs::path_abs("docs/index.html", start = path),
    "docsify" = fs::path_abs("docs/_sidebar.md", start = path),
    "mkdocs" = fs::path_abs("docs/mkdocs.yaml", start = path)
  )
  cli::cli_alert_warning(
    cli::style_bold("Don't forget to check that vignettes are correctly included in {.file {file_to_update}}.")
  )
}



# Check whether vignettes call child documents
.manage_child_vignettes <- function(file, path = path) {

  x <- tinkr::yarn$new(file)

  children <- x$body
  children <- xml2::xml_find_all(children, xpath = ".//md:code_block", x$ns)
  children <- xml2::xml_attr(children, attr = "child")
  children <- children[!is.na(children)]
  children <- gsub("\"", "", children)

  if(length(children) == 0) return("continue")

  if (any(grepl("\\.\\.", children))) {
    cli::cli_alert_danger("Some vignettes call child elements in other folders. {.code altdoc} cannot deal with them.")
    return("stop")
  } else {
    for (i in children) {
      fs::file_copy(children, fs::path_abs(paste0("docs/articles/", children), start = path), overwrite = TRUE)
      return("continue")
    }
  }

}
