# Convert and unite .Rd files to 'docs/reference.md'.
.import_man <- function(
  src_dir,
  tar_dir,
  doctype = "docsify",
  verbose = FALSE,
  parallel = FALSE,
  freeze = FALSE) {

  # source and target file paths
  # using here::here() breaks tests, so we rely on directory check higher up
  man_source <- list.files(path = "man", pattern = "\\.Rd$")
  man_target <- list.files(path = fs::path_join(c(tar_dir, "man")), pattern = "\\.md$")
  man_source <- fs::path_ext_remove(man_source)
  man_target <- fs::path_ext_remove(man_target)

  n <- length(man_source)

  cli::cli_alert_info("Found {n} man page{?s} to convert.")

  render_one_man <- function(fn) {
    # fs::path_ext_set breaks filenames with dots, ex: 'foo.bar.Rd'
    origin_Rd <- fs::path_join(c("man", paste0(fn, ".Rd")))
    destination_dir <- fs::path_join(c(tar_dir, "man"))
    destination_qmd <- fs::path_join(c(destination_dir, paste0(fn, ".qmd")))
    destination_md <- fs::path_join(c(destination_dir, paste0(fn, ".md")))

    # Skip file when frozen
    if (isTRUE(freeze)) {
      flag <- .read_freeze(
        input = origin_Rd,
        output = destination_md,
        path = src_dir,
        freeze = freeze
      )
      if (isTRUE(flag)) {
        cli::cli_alert_info("Skipping {basename(fn)} because it already exists.")
        return(TRUE)
      }
    }

    fs::dir_create(destination_dir)
    .rd2qmd(origin_Rd, destination_dir)

    if (doctype != "quarto_website") {
      worked <- .qmd2md(destination_qmd, destination_dir, verbose = verbose)
      fs::file_delete(destination_qmd)
    } else {
      worked <- TRUE
    }

    # section headings are too deeply nested by default
    # this is a hack because it may remove one # from comments. But that's
    # probably not the end of the world, because the line stick stays commented
    # out.
    if (fs::file_exists(destination_md)) {
      tmp <- .readlines(destination_md)
      tmp <- gsub("^##", "#", tmp)
      writeLines(tmp, destination_md)
    }

    if (isTRUE(worked)) {
      .write_freeze(input = origin_Rd, path = src_dir, freeze = freeze) 
    }

    return(worked)
  }

  if (isTRUE(parallel)) {
    .assert_dependency("future.apply", install = TRUE)
    conversion_worked <- future.apply::future_sapply(
      man_source,
      render_one_man,
      freeze = freeze,
      future.seed = NULL)
  } else {
    # can't use message_info with {}
    i <- 0
    cli::cli_progress_step("Converting function reference {i}/{n}: {basename(man_source[i])}", spinner = TRUE)
    conversion_worked <- vector(length = n)
    for (i in seq_along(man_source)) {
      conversion_worked[i] <- render_one_man(man_source[i])
      cli::cli_progress_update(inc = 1)
    }
  }

  successes <- which(conversion_worked == TRUE)
  fails <- which(conversion_worked == FALSE)
  cli::cli_progress_done()

  # indent bullet points
  cli::cli_div(theme = list(ul = list(`margin-left` = 2, before = "")))

  if (length(fails) > 0) {
    cli::cli_par()
    cli::cli_end()
    cli::cli_alert_danger("{cli::qty(length(successes))}The conversion failed for the following man page{?s}:")
    cli::cli_ul(id = "list-fail")
    for (i in seq_along(fails)) {
      cli::cli_li("{.file {man_source[fails[i]]}}")
    }
    cli::cli_par()
    cli::cli_end(id = "list-fail")
  }
}