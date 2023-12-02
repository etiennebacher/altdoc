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

  # relative_links <- function(fn) {
  #   content <- .readlines(fn)
  #   # we try both syntaxes because it seems to depend on Quarto version or other
  #   # system-dependent factor
  #   content <- gsub('src="altdoc/', 'src="', content, fixed = TRUE)
  #   content <- gsub("![](altdoc/", "![](", content, fixed = TRUE)
  #   content <- gsub('src="README.markdown_strict_files/', 'src="man/figures/README/', content, fixed = TRUE)
  #   content <- gsub("![](README.markdown_strict_files/", "![](man/figures/README/", content, fixed = TRUE)
  #   writeLines(content, fn)
  # }
  # relative_links(tar_file) # for website
  # relative_links(src_file) # for CRAN

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

  # cleanup
  fs::dir_delete(src_dir)
}
