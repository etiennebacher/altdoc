.import_readme <- function(src_dir, tar_dir, tool) {

  # order is important. We want to prioritize .qmd, so we do it last.

  # no extension -> md
  fn <- fs::path_join(c(src_dir, "README"))
  if (fs::file_exists(fn)) {
    fs::file_copy(fn, fs::path_join(c(src_dir, "README.md")))
  }

  # rmd -> md
  fn <- fs::path_join(c(src_dir, "README.Rmd"))
  if (fs::file_exists(fn)) {
    .qmd2md(fn, src_dir)
  }

  # qmd -> md
  fn <- fs::path_join(c(src_dir, "README.qmd"))
  if (fs::file_exists(fn)) {
    if (tool == "quarto_website") {
      # copy to quarto file
      fs::file_copy(
        fn,
        fs::path_join(c(tar_dir, "index.qmd")),
        overwrite = TRUE)
      # process in-place for use on Github
      .qmd2md(fn, src_dir)
    } else {
      .qmd2md(fn, src_dir)
    }
  } else if (tool == "quarto_website") {
    cli::cli_abort("Quarto websites require a README.qmd file in the root of the package directory.", call = NULL)
  }

  # no README -> create a dummy
  fn <- fs::path_join(c(src_dir, "README.md"))
  if (!fs::file_exists(fn)) {
    writeLines(c("", "Hello world!"), fn)
  }

  if (tool == "quarto_website") {
    tar_file <- fs::path_join(c(tar_dir, "index.md"))
  } else {
    tar_file <- fs::path_join(c(tar_dir, "README.md"))
  }

  src_file <- fs::path_join(c(src_dir, "README.md"))
  fs::file_copy(fn, tar_file, overwrite = TRUE)
  .check_md_structure(tar_file)

  tmp <- fs::path_join(c(src_dir, "README.markdown_strict_files"))
  if (fs::dir_exists(tmp)) {
    cli::cli_alert("We recommend using a `knitr` option to set the path of your images to `man/figures/README-`. This would ensure that images are properly stored and displayed on multiple platforms like CRAN, Github, and on your `altdoc` website.")
  }

  cli::cli_alert_success("{.file README} imported.")
}