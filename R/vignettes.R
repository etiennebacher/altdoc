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

  articles_path <- paste0(.doc_path(path = path), "/articles")
  vignettes <- list.files(vignettes_path, pattern = ".Rmd$")

  if (!file.exists(articles_path)) {
    fs::dir_create(articles_path)
  }

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
    output_file <- paste0(substr(j, 1, nchar(j)-4), ".md")

    tryCatch(
      {
        suppressMessages(
          suppressWarnings(
            rmarkdown::render(
              origin,
              output_dir = articles_path,
              output_file = output_file,
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
