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

.import_vignettes <- function(path = path) {
  # source directory
  src_dir <- fs::path_abs("vignettes", start = path)
  if (!fs::dir_exists(src_dir) || .folder_is_empty(src_dir)) {
    cli::cli_alert_info("No vignettes to convert")
    return(invisible())
  }

  # target directory
  tar_dir <- fs::path_join(c(.doc_path(path = path), "/articles"))
  if (!dir.exists(tar_dir)) {
    fs::dir_create(tar_dir)
  }

  # source files
  src_files <- list.files(src_dir, pattern = "\\.Rmd$|\\.qmd$")

  # copy all subdirectories: images, static files, etc.
  # docsify: articles/
  # docute: /
  dir_static <- Filter(fs::is_dir, fs::dir_ls(src_dir))
  if (.doc_type(path) == "docute") {
    tar_dir_static <- gsub("articles$", "", tar_dir)
  } else {
    tar_dir_static <- tar_dir
  }
  for (d in dir_static) {
    fs::dir_copy(
      d,
      fs::path_join(c(tar_dir_static, basename(d))),
      overwrite = TRUE
    )
  }

  n <- length(src_files)

  # can't use message_info with {}
  cli::cli_alert_info("Found {n} vignette{?s} to convert.")
  i <- 0
  cli::cli_progress_step("Converting {cli::qty(n)}vignette{?s}: {i}/{n}", spinner = TRUE)

  conversion_worked <- vector(length = n)

  fs::dir_copy(src_dir, tar_dir, overwrite = TRUE)

  for (i in seq_along(src_files)) {
    # only process new or modified vignettes
    origin <- fs::path_join(c(src_dir, src_files[i]))
    destination <- fs::path_join(c(tar_dir, src_files[i]))

    ## Freeze is currently commented out because it breaks some tests. This is a planned feature
    ## TODO: add a `freeze` argument

    # if (fs::file_exists(destination)) {
    #   # freeze
    #   old <- readLines(destination, warn = FALSE)
    #   new <- readLines(origin, warn = FALSE)
    #   freeze <- identical(old, new)
    #   if (freeze) {
    #     cli::cli_progress_update()
    #     conversion_worked[i] <- TRUE
    #     next
    #   }
    # } else {
    fs::file_copy(origin, destination, overwrite = TRUE)
    # }

    if (fs::path_ext(origin) == "Rmd") {
      tryCatch(
        {
          suppressMessages(
            suppressWarnings(
              .rmd2md(origin, tar_dir)
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
    } else {
      tryCatch(
        {
          suppressMessages(
            suppressWarnings(
              .qmd2md(origin, tar_dir)
            )
          )
          conversion_worked[i] <- TRUE
        },
        error = function(e) {
          conversion_worked[i] <- FALSE
        }
      )
      cli::cli_progress_update()
    }
  }

  successes <- which(conversion_worked == TRUE)
  fails <- which(conversion_worked == FALSE)

  cli::cli_progress_done()
  # indent bullet points
  cli::cli_div(theme = list(ul = list(`margin-left` = 2, before = "")))

  if (length(successes) > 0) {
    cli::cli_par()
    cli::cli_end()
    cli::cli_alert_success("{cli::qty(length(successes))}The following vignette{?s} ha{?s/ve} been converted and put in {.file {tar_dir}}:")
    cli::cli_ul(id = "list-success")
    for (i in seq_along(successes)) {
      cli::cli_li("{.file {src_files[successes[i]]}}")
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
      cli::cli_li("{.file {src_files[fails[i]]}}")
    }
    cli::cli_par()
    cli::cli_end(id = "list-fail")
  }

  cli::cli_alert_info("The folder {.file {src_dir}} was not modified.")
}




# Get a filename with a vignette and try to extract its title

.get_vignettes_titles <- function(fn, path = ".") {

  if (!fs::file_exists(fn)) return(invisible())

  x <- readLines(fn, warn = FALSE)

  # title in vignette of the same name
  vig <- fs::path_ext_remove(basename(fn))
  p <- list.files(fs::path_join(c(path, "vignettes")), pattern = vig)
  if (length(p) == 1) {
    z <- readLines(fs::path_join(c(path, "vignettes", p)))
    title <- z[grepl("^title:\\w*", z)]
    title <- trimws(gsub("^title:\\w*", "", title))
    if (length(title) > 0) return(title)
  }

  # First h1 header
  if (length(title) == 0) {
    idx <- grep("^# \\w+", x)
    if (length(idx) > 0) {
      title <- x[idx[1]]
      title <- gsub("^# ", "", title)
      return(title)
    }
  }

  # file name
  if (length(title) == 0) {
    title <- fs::path_ext_remove(basename(fn))
    title <- gsub("_", " ", title)
    title <- tools::toTitleCase(title)
    return(title)
  }

  return(invisible())
}

