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
    cli::cli_alert_info("No vignettes to convert.")
    return(invisible())
  }

  # target directory
  tar_dir <- fs::path_join(c(tar_dir, "vignettes"))
  fs::dir_create(tar_dir)

  # source files
  # docute can't open PDF in external tab because it adds ".md" after all files
  src_files <- if (tool == "docute") {
    list.files(vig_dir, pattern = "\\.Rmd$|\\.qmd$|\\.md$")
  } else {
    list.files(vig_dir, pattern = "\\.Rmd$|\\.qmd$|\\.md$|\\.pdf$")
  }

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

  if (n == 0) {
    cli::cli_alert_info("No vignettes to convert.")
    return(invisible())
  } else {
    cli::cli_alert_info("Found {n} vignette{?s} to convert.")
  }

  fs::dir_copy(vig_dir, tar_dir, overwrite = TRUE)

  # Read the hashes, used if freeze = TRUE
  hashes <- .get_hashes(src_dir = src_dir, freeze = freeze)

  if (isTRUE(parallel)) {
    .assert_dependency("future.apply", install = TRUE)
    conversion_worked <- future.apply::future_sapply(
      src_files,
      .render_one_vignette,
      src_dir = src_dir,
      vig_dir = vig_dir,
      tar_dir = tar_dir,
      freeze = freeze,
      hashes = hashes,
      verbose = verbose,
      future.seed = NULL
    )
  } else {
    conversion_worked <- vapply(
      seq_along(src_files),
      function(x) {
        cli::cli_progress_step("Converting vignette {x}/{n}: {basename(src_files[x])}", spinner = TRUE)
        out <- .render_one_vignette(
          vignette = src_files[x],
          src_dir = src_dir,
          vig_dir = vig_dir,
          tar_dir = tar_dir,
          freeze = freeze,
          hashes = hashes,
          verbose = verbose
        )
        cli::cli_progress_update(inc = 1)
        out
      },
      FUN.VALUE = character(1L)
    )
  }

  successes <- which(conversion_worked == "success")
  fails <- which(conversion_worked == "failure")
  skipped_unchanged <- which(conversion_worked == "skipped_unchanged")

  .update_freeze(src_dir, src_files, successes, fails, type = "vignettes")

  cli::cli_progress_done()

  if (length(skipped_unchanged) > 0) {
    cli::cli_alert("{length(skipped_unchanged)} vignette{?s} skipped because {?it/they} didn't change.")
  }

  if (length(fails) > 0) {
    # indent bullet points
    cli::cli_div(theme = list(ul = list(`margin-left` = 2, before = "")))
    cli::cli_par()
    cli::cli_end()
    cli::cli_alert_danger("{length(successes)}The conversion failed for the following vignette{?s}:")
    cli::cli_ul(id = "list-fail")
    for (i in seq_along(fails)) {
      cli::cli_li("{.file {src_files[fails[i]]}}")
    }
    cli::cli_par()
    cli::cli_end(id = "list-fail")
  }

  fails
}


.render_one_vignette <- function(vignette, src_dir, vig_dir, tar_dir, freeze, hashes = NULL, verbose = FALSE) {

  worked <- FALSE

  # only process new or modified vignettes
  origin <- fs::path_join(c(vig_dir, vignette))
  destination <- fs::path_join(c(tar_dir, vignette))
  fs::file_copy(origin, destination, overwrite = TRUE)

  # raw markdown should just be copied over
  if (fs::path_ext(vignette) == "md") {
    fs::file_copy(origin, tar_dir, overwrite = TRUE)
    return("success")
  }

  # Skip file when frozen
  if (isTRUE(freeze)) {
    flag <- .is_frozen(input = origin, output = gsub("\\.Rmd$|\\.qmd$", ".md", destination), hashes = hashes)
    if (isTRUE(flag)) {
      return("skipped_unchanged")
    }
  }

  if (fs::path_ext(origin) %in% c("md", "pdf")) {
    fs::file_copy(origin, tar_dir, overwrite = TRUE)
    worked <- TRUE

    # We now use Quarto to render all vignettes, even .Rmd ones, because this
    # makes the file structure more uniform, and fixes a lot of the file path
    # issues we'd been having when generating images from code blocks and
    # inserting ones with ![]().
  } else {
    pre <- fs::path_join(c(src_dir, sprintf("altdoc/preamble_vignettes_%s.yml", fs::path_ext(vignette))))
    if (fs::file_exists(pre)) {
      pre <- .readlines(pre)
    } else {
      pre <- NULL
    }
    worked <- .qmd2md(origin, tar_dir, verbose = verbose, preamble = pre)
  }

  return(ifelse(worked, "success", "failure"))
}




# Get a filename with a vignette and try to extract its title

.get_vignettes_titles <- function(fn, path = ".") {

  if (!fs::file_exists(fn)) return(invisible())

  x <- .readlines(fn)

  out <- gsub("\\.md$", "", basename(fn))

  # title in vignette of the same name
  vig <- fs::path_ext_remove(basename(fn))
  p <- list.files(fs::path_join(c(path, "vignettes")), pattern = vig)
  p <- p[grepl("\\.Rmd$|\\.qmd$", p)]
  if (length(p) == 1) {
    z <- .readlines(fs::path_join(c(path, "vignettes", p)))
    out <- z[grepl("^out:\\w*", z)]
    out <- trimws(gsub("^out:\\w*", "", out))
  }

  # First h1 header
  if (length(out) == 0) {
    idx <- grep("^# \\w+", x)
    if (length(idx) > 0) {
      out <- x[idx[1]]
      out <- gsub("^# ", "", out)
    }
  }

  # file name
  if (length(out) == 0) {
    out <- fs::path_ext_remove(basename(fn))
    out <- gsub("_", " ", out)
    out <- tools::toTitleCase(out)
  }

  # Clean up and escape
  if (is.character(out)) {
    out <- gsub('^"|"$', '', out)
  }

  return(out)
}

