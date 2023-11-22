# Transform vignettes to produce Markdown
#
# Transform vignettes to produce Markdown instead of HTML.
#
# Vignettes files (originally placed in the folder "Vignettes") have the output
# "html_vignette", instead of Markdown. This function makes several things:
# * moves the .Rmd files from the "vignettes" folder in "docs/vignettes"
# * replaces the "output" argument of each .Rmd file (in "docs/vignettes") so
#  that it is "md_document" instead of "html_vignette"
# * render all of the modified .Rmd files (in "docs/vignettes"), which produce .md files.

.import_vignettes <- function(
  src_dir,
  tar_dir,
  tool = "docsify",
  verbose = FALSE,
  parallel = FALSE,
  freeze = FALSE) {

  # quarto vignettes are rendered by quarto itself, so we just need to copy them
  if (tool == "quarto_website") {
    dn_src <- fs::path_join(c(src_dir, "vignettes"))
    dn_tar <- fs::path_join(c(tar_dir, "vignettes"))
    if (fs::dir_exists(dn_tar)) {
      fs::dir_delete(dn_tar)
    }
    if (fs::dir_exists(dn_src)) {
      fs::dir_copy(dn_src, dn_tar)
    }
    return(invisible())
  }

  # source directory
  vig_dir <- fs::path_abs("vignettes", start = src_dir)
  if (!fs::dir_exists(vig_dir) || .folder_is_empty(vig_dir)) {
    cli::cli_alert_info("No vignettes to convert")
    return(invisible())
  }

  # target directory
  tar_dir <- fs::path_join(c(tar_dir, "vignettes"))
  if (!dir.exists(tar_dir)) {
    fs::dir_create(tar_dir)
  }

  # source files
  src_files <- list.files(vig_dir, pattern = "\\.Rmd$|\\.qmd$|\\.md$")

  # copy all subdirectories: images, static files, etc.
  # docsify: vignettes/
  # docute: /
  dir_static <- Filter(fs::is_dir, fs::dir_ls(vig_dir))
  if (tool == "docute") {
    tar_dir_static <- gsub("vignettes$", "", tar_dir)
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

  cli::cli_alert_info("Found {n} vignette{?s} to convert.")

  fs::dir_copy(vig_dir, tar_dir, overwrite = TRUE)

  render_one_vignette <- function(i) {
    # only process new or modified vignettes
    origin <- fs::path_join(c(vig_dir, src_files[i]))
    destination <- fs::path_join(c(tar_dir, src_files[i]))
    fs::file_copy(origin, destination, overwrite = TRUE)

    # Skip file when frozen
    if (isTRUE(freeze)) {
      flag <- .read_freeze(
        input = origin,
        output = destination,
        path = src_dir,
        freeze = freeze
      )
      if (isTRUE(flag)) {
        cli::cli_alert_info("Skipping {basename(origin)} because it already exists.")
        return(TRUE)
      }
    }

    if (fs::path_ext(origin) == "md") {
      fs::file_copy(origin, tar_dir, overwrite = TRUE)

    # We now use Quarto to render all vignettes, even .Rmd ones, because this
    # makes the file structure more uniform, and fixes a lot of the file path
    # issues we'd been having when generating images from code blocks and
    # inserting ones with ![]().
    } else {
      worked <- .qmd2md(origin, tar_dir, verbose = verbose)
    }

    if (isTRUE(worked)) {
      .write_freeze(input = origin, path = src_dir, freeze = freeze)
    }

    return(worked)
  }

  if (isTRUE(parallel)) {
    .assert_dependency("future.apply", install = TRUE)
    conversion_worked <- future.apply::future_sapply(seq_along(src_files), render_one_vignette, future.seed = NULL)
  } else {
    i <- 0
    cli::cli_progress_step("Converting vignette {i}/{n}: {basename(src_files[i])}", spinner = TRUE)
    conversion_worked <- vector(length = n)
    for (i in seq_along(src_files)) {
      conversion_worked[i] <- render_one_vignette(i)
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
    cli::cli_alert_success("{cli::qty(length(successes))}The following vignette{?s} ha{?s/ve} been rendered and put in {.file {tar_dir}}:")
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
}




# Get a filename with a vignette and try to extract its title

.get_vignettes_titles <- function(fn, path = ".") {

  if (!fs::file_exists(fn)) return(invisible())

  x <- .readlines(fn)

  # title in vignette of the same name
  vig <- fs::path_ext_remove(basename(fn))
  p <- list.files(fs::path_join(c(path, "vignettes")), pattern = vig)
  p <- p[grepl("\\.Rmd$|\\.qmd$", p)]
  if (length(p) == 1) {
    z <- .readlines(fs::path_join(c(path, "vignettes", p)))
    title <- z[grepl("^title:\\w*", z)]
    title <- trimws(gsub("^title:\\w*", "", title))
  }

  # First h1 header
  if (length(title) == 0) {
    idx <- grep("^# \\w+", x)
    if (length(idx) > 0) {
      title <- x[idx[1]]
      title <- gsub("^# ", "", title)
    }
  }

  # file name
  if (length(title) == 0) {
    title <- fs::path_ext_remove(basename(fn))
    title <- gsub("_", " ", title)
    title <- tools::toTitleCase(title)
  }

  # Clean up and escape
  if (is.character(title)) {
    title <- gsub('^"|"$', '', title)
  }

  return(title)
}

