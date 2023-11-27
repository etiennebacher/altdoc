.import_readme <- function(src_dir, tar_dir, tool) {

  # render .Rmd or .qmd file if available
  fn_qmd <- fs::path_join(c(src_dir, "README.qmd"))
  fn_rmd <- fs::path_join(c(src_dir, "README.Rmd"))
  if (fs::file_exists(fn_qmd)) {
    .qmd2md(fn_qmd, src_dir)
  } else if (fs::file_exists(fn_rmd)) {
    .qmd2md(fn_rmd, src_dir)
  }

  src_file <- fs::path_join(c(src_dir, "README.md"))
  if (tool == "quarto_website") {
    tar_file <- fs::path_join(c(tar_dir, "index.md"))
  } else {
    tar_file <- fs::path_join(c(tar_dir, "README.md"))
  }

  # default readme is mandatory for some docs generators
  if (!fs::file_exists(src_file)) {
    writeLines(c("", "Hello world!"), src_file)
  }

  fs::file_copy(src_file, tar_file, overwrite = TRUE)
  .check_md_structure(tar_file)

  # relative links for altdoc/ static files
  content <- .readlines(tar_file)
  content <- gsub('img src="altdoc/', 'img src="', content)
  writeLines(content, tar_file)

  .move_img_readme(path = src_dir, tool = tool)

  cli::cli_alert_success("{.file README} imported.")
}


# Copy images/GIF that are in README in 'docs'

.move_img_readme <- function(path = ".", tool) {
  src_dir <- fs::path_join(c(path, "README.markdown_strict_files"))
  if (!fs::dir_exists(src_dir)) {
    return(invisible())
  }
  is_quarto <- grepl("^quarto", tool)
  if (is_quarto) {
    tar_dir <- fs::path_join(c(path, "_quarto", "docs/README.markdown_strict_files"))
  } else {
    tar_dir <- fs::path_join(c(path, "docs/README.markdown_strict_files"))
  }
  fs::dir_copy(
    src_dir,
    tar_dir,
    overwrite = TRUE
  )
}
