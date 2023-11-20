.qmd2md <- function(source_file, tar_dir, verbose = FALSE) {
  if (missing(source_file) || !file.exists(source_file)) {
    stop("source_file must be a valid file path.", call. = FALSE)
  }
  if (!fs::dir_exists(tar_dir)) {
    stop("tar_dir must be a valid directory.", call. = FALSE)
  }

  tar_file <- fs::path_join(c(tar_dir, basename(source_file)))
  fs::file_copy(source_file, tar_file, overwrite = TRUE)

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


.rmd2md <- function(source_file, tar_dir, path = NULL, verbose = FALSE) {

  source_dir <- fs::path_dir(source_file)
  target_file <- gsub("\\.Rmd$", "\\.md", fs::path_join(c(tar_dir, basename(source_file))))

  if (missing(source_file) || !file.exists(source_file)) {
    stop("source_file must be a valid file path.", call. = FALSE)
  }
  if (!fs::dir_exists(tar_dir)) {
    stop("tar_dir must be a valid directory.", call. = FALSE)
  }

  if (isTRUE(verbose)) {
    out <- try(rmarkdown::render(
      input = path.expand(source_file),
      output_format = "github_document",
      output_dir = tar_dir,
      quiet = FALSE,
      envir = new.env()
    ), silent = FALSE)
  } else {
    void <- utils::capture.output({
      out <- try(
        rmarkdown::render(
          input = path.expand(source_file),
          output_dir = tar_dir,
          output_format = "github_document",
          quiet = TRUE,
          envir = new.env()),
        silent = TRUE)
    })
  }


  out <- !inherits(out, "try-error")

  return(out)
}
