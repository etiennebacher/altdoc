.qmd2md <- function(source_file, tar_dir, verbose = FALSE) {


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
  x <- .readlines(tar_file)
  first_non_empty <- x[which(!x == "")[1]]
  if (!grepl("^---\\w*", first_non_empty)) {
    x <- c(
      "---",
      "format:",
      "  md:",
      "    prefer-html: true",
      "---",
      "",
      x
    )
    writeLines(x, tar_file)
  }

  if (isTRUE(verbose)) {
    out <- try(quarto::quarto_render(
      input = path.expand(tar_file),
      output_format = "md",
      quiet = FALSE
    ), silent = FALSE)
  } else {
    void <- utils::capture.output(
      out <- try(quarto::quarto_render(
        input = path.expand(tar_file),
        output_format = "md",
        quiet = TRUE
      ), silent = TRUE)
    )
  }


  out <- !inherits(out, "try-error")

  return(out)
}


