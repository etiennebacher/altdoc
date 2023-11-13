.qmd2md <- function(source_file, tar_dir, verbose = TRUE) {

  quiet <- !verbose

  if (missing(source_file) || !file.exists(source_file)) {
    stop("source_file must be a valid file path.", call. = FALSE)
  }

  if (!fs::dir_exists(tar_dir)) {
    stop("tar_dir must be a valid directory.", call. = FALSE)
  }

  tar_file <- fs::path_join(c(tar_dir, basename(source_file)))
  fs::file_copy(source_file, tar_file, overwrite = TRUE)

  quarto::quarto_render(
    input = path.expand(tar_file),
    output_format = "md",
    quiet = quiet
  )
}


.rmd2md <- function(source_file, output_dir) {
  if (missing(source_file) || !file.exists(source_file)) {
    stop("source_file must be a valid file path.", call. = FALSE)
  }

  out <- utils::capture.output(
    rmarkdown::render(
      input = path.expand(source_file),
      output_format = "github_document",
      quiet = TRUE,
      envir = new.env()
    )
  )

  # output_dir is apparently not reliable, and creates absolute paths, so we
  # render them in place and move the files and static files directories.
  stem <- fs::path_ext_remove(source_file)
  stem_md <- fs::path_ext_set(stem, "md")
  stem_files <- paste0(stem, "_files")

  if (fs::dir_exists(stem_files)) {
    fs::dir_copy(stem_files, output_dir, overwrite = TRUE)
    fs::dir_delete(stem_files)
  }

  if (fs::file_exists(stem_md)) {
    fs::file_copy(stem_md, output_dir, overwrite = TRUE)
    fs::file_delete(stem_md)
  }
}
