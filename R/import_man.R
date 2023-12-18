# Convert and unite .Rd files to 'docs/reference.md'.
.import_man <- function(
  src_dir,
  tar_dir,
  tool = "docsify",
  verbose = FALSE,
  parallel = FALSE,
  freeze = FALSE) {

  # source and target file paths
  # using here::here() breaks tests, so we rely on directory check higher up
  man_source <- list.files(path = "man", pattern = "\\.Rd$")
  man_target <- list.files(path = fs::path_join(c(tar_dir, "man")), pattern = "\\.md$")
  man_source <- fs::path_ext_remove(man_source)
  man_target <- fs::path_ext_remove(man_target)

  # copy the full content of the `man/` directory because developers often store
  # static files there for their README and other files.
  # but we don't want all those raw man pages.
  a <- fs::path_join(c(src_dir, "man"))
  b <- fs::path_join(c(tar_dir, "man"))
  if (fs::file_exists(a)) {
    fs::dir_copy(a, b, overwrite = TRUE)
    cruft <- fs::dir_ls(fs::path_join(c(tar_dir, "man")), regexp = "\\.Rd$")
    cruft <- Filter(fs::is_file, cruft)
    fs::file_delete(cruft)
  }

  n <- length(man_source)

  if (n == 0) {
    cli::cli_alert_info("No man pages to convert.")
    return(invisible())
  } else {
    cli::cli_alert_info("Found {n} man page{?s} to convert.")
  }

  # Read the hashes, used when freeze = TRUE
  hashes <- .get_hashes(src_dir = src_dir, freeze = freeze)

  if (isTRUE(parallel)) {
    .assert_dependency("future.apply", install = TRUE)
    conversion_worked <- future.apply::future_sapply(
      man_source,
      .render_one_man,
      tool = tool,
      src_dir = src_dir,
      tar_dir = tar_dir,
      freeze = freeze,
      hashes = hashes,
      verbose = verbose,
      future.seed = NULL
    )
  } else {
    conversion_worked <- vapply(
      seq_along(man_source),
      function(x) {
        cli::cli_progress_step("Converting function reference {x}/{n}: {basename(man_source[x])}", spinner = TRUE)
        out <- .render_one_man(
          man_source[x],
          tool = tool,
          src_dir = src_dir,
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
  skipped_internal <- which(conversion_worked == "skipped_internal")
  skipped_unchanged <- which(conversion_worked == "skipped_unchanged")

  .update_freeze(src_dir, man_source, successes, fails, type = "man")

  cli::cli_progress_done()

  # indent bullet points
  cli::cli_div(theme = list(ul = list(`margin-left` = 2, before = "")))

  if (length(skipped_internal) > 0) {
    cli::cli_alert("{length(skipped_internal)} .Rd files skipped because they document internal functions.")
  }

  if (length(skipped_unchanged) > 0) {
    cli::cli_alert("{length(skipped_unchanged)} .Rd files skipped because they didn't change.")
  }

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

  fails
}


.render_one_man <- function(fn, tool, src_dir, tar_dir, freeze, hashes = NULL, verbose = FALSE) {
  # fs::path_ext_set breaks filenames with dots, ex: 'foo.bar.Rd'
  origin_Rd <- fs::path_join(c("man", paste0(fn, ".Rd")))
  destination_dir <- fs::path_join(c(tar_dir, "man"))
  destination_qmd <- fs::path_join(c(destination_dir, paste0(fn, ".qmd")))
  destination_md <- fs::path_join(c(destination_dir, paste0(fn, ".md")))

  # Skip internal functions
  flag <- tryCatch(
    any(grepl("\\keyword\\{internal\\}", .readlines(origin_Rd))),
    error = function(e) FALSE
  )
  if (isTRUE(flag)) {
    return("skipped_internal")
  }

  # Skip file when frozen
  if (isTRUE(freeze)) {
    flag <- .is_frozen(input = origin_Rd, output = destination_md, hashes = hashes)
    if (isTRUE(flag)) {
      return("skipped_unchanged")
    }
  }

  fs::dir_create(destination_dir)
  .rd2qmd(origin_Rd, destination_dir, path = src_dir)

  if (tool != "quarto_website") {
    pre <- fs::path_join(c(src_dir, "altdoc", "preamble_man_qmd.yml"))
    if (fs::file_exists(pre)) {
      pre <- .readlines(pre)
    } else {
      pre <- NULL
    }
    worked <- .qmd2md(destination_qmd, destination_dir, verbose = verbose, preamble = pre)
    fs::file_delete(destination_qmd)
  } else {
    worked <- TRUE
  }

  github_source <- .find_github_source(fn)
  if (!is.null(github_source)) {
    to_insert <- paste0("[**Source code**](", github_source, ")")
    rendered_man <- gsub("\\.qmd$", ".md", destination_qmd)
    if (fs::file_exists(rendered_man)) {
      temp <- .readlines(rendered_man)
      header_idx <- grep("^## ", temp)[1]
      new <- c(temp[1:header_idx], "", to_insert, temp[(header_idx + 1): length(temp)])
      writeLines(new, rendered_man)
    }
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

  return(ifelse(worked, "success", "failure"))
}



.find_github_source <- function(fn) {
  head_branch <- .find_head_branch(path = ".")
  if (is.null(head_branch)) {
    return(NULL)
  }
  # find file and row location
  fn <- try(eval(parse(text = paste0(.pkg_name("."), ":::", fn))), silent = TRUE)
  if (inherits(fn, "try-error")) {
    return(NULL)
  }
  line <- utils::getSrcLocation(fn, "line")
  file <- paste0("R/", utils::getSrcFilename(fn))

  # build URL
  gh_link <- .gh_url(".")
  if (is.na(gh_link)) {
    return(NULL)
  }
  final_link <- paste0(gh_link, "/tree/", head_branch, "/", file, "#L", line)

  # test URL
  is_404 <- FALSE
  tryCatch(
    {
      connection <- file(final_link, "rt", encoding = "")
      close(connection)
    },
    warning = function(w) {
      is_404 <<- grepl("404", w)
    }
  )

  if (is_404) {
    return(NULL)
  } else {
    final_link
  }
}
