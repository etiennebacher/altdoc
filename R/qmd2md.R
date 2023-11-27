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

  .link_functions(tar_file)

  out <- !inherits(out, "try-error")

  return(out)
}

# Custom wrapper around `downlit::downlit_md_path()`
.link_functions <- function(path) {
  op <- "/man"
  names(op) <- .pkg_name(".")
  options(downlit.local_packages = op)
  downlit:::downlit_md_path(path, path)
  content <- .readlines(path)
  # links in code blocks
  fixed <- gsub("/man/reference/([^.]+)\\.html", "#/man/\\1.md", content)
  # links in inline code
  fixed <- gsub("/man/reference/([^.]+)\\.html", "/man/\\1.md", fixed)

  writeLines(fixed, path)
}
