.qmd2md <- function(source_file, tar_dir, verbose = FALSE, preamble = NULL) {

  if (missing(source_file) || !file.exists(source_file)) {
    stop("source_file must be a valid file path.", call. = FALSE)
  }
  if (!fs::dir_exists(tar_dir)) {
    stop("tar_dir must be a valid directory.", call. = FALSE)
  }

  tar_file <- fs::path_join(c(tar_dir, basename(source_file)))
  fs::file_copy(source_file, tar_file, overwrite = TRUE)

  # if there is no YAML header, add prefer-html, because this helps with any
  # function that returns HTML output, which should be supported by our
  # documentation generators, since they get rendered to web.
  if (!is.null(preamble) && !.has_preamble(tar_file)) {
    x <- c(preamble, .readlines(tar_file))
    writeLines(x, tar_file)
  }

  if (isTRUE(verbose)) {
    out <- try(quarto::quarto_render(
      input = path.expand(tar_file),
      output_format = "md",
      quiet = FALSE,
      as_job = FALSE
    ), silent = FALSE)
    success <- !inherits(out, "try-error")
  } else {
    success <- TRUE
    out <- evaluate::evaluate('quarto::quarto_render(
      input = path.expand(tar_file),
      output_format = "md",
      quiet = FALSE,
      as_job = FALSE,
    )', new_device = FALSE)
    is_error <- vapply(
      out,
      function(x) inherits(x, c("error", "rlang_error")),
      FUN.VALUE = logical(1)
    )

    # in "out", first element is the call, 2nd element is output in the console
    # (i.e what we want because it includes the error), 3rd element is the call
    # that triggered the error, if any (i.e quarto_render()).
    if (any(is_error)) {
      cat(out[[2]])
      success <- FALSE
    }
  }

  success
}


