.import_readme <- function(tar_dir) {

  tool <- .doc_type()

  # order is important. We want to prioritize .qmd, so we do it last.

  # no extension -> md
  if (fs::file_exists("README")) {
    fs::file_copy("README", "README.md")
  }

  # rmd -> md
  if (fs::file_exists("README.Rmd")) {
    .qmd2md("README.Rmd", getwd())
  }

  # qmd -> md
  # process in-place for use on Github
  # TODO: preambles inserted in the README often break Quarto websites. It's
  # not a big problem to omit the preamble, but it would be good to
  # investigate this, because I am not sure what is going on -VAB
  if (fs::file_exists("README.qmd")) {
    if (tool == "quarto_website") {
      # copy to quarto file
      fs::file_copy("README.qmd", fs::path_join(c(tar_dir, "index.qmd")), overwrite = TRUE)
      # also render in place for Github
      .qmd2md("README.qmd", getwd())
      cli::cli_alert_success("{.file README} imported.")
      return(invisible())
    } else {
      .qmd2md("README.qmd", getwd())
    }
  } else if (tool == "quarto_website") {
    cli::cli_abort("Quarto websites require a README.qmd file in the root of the package directory.", call = NULL)
  }

  # no README -> create a dummy
  if (!fs::file_exists("README.md")) {
    writeLines(c("", "Hello world!"), "README.md")
  }

  if (tool != "quarto_website") {
    tar_file <- fs::path_join(c(tar_dir, "README.md"))
    fs::file_copy("README.md", tar_file, overwrite = TRUE)
   .check_md_structure(tar_file)
  }


  if (fs::dir_exists("README.markdown_strict_files")) {
    cli::cli_alert("We recommend using a `knitr` option to set the path of your images to `man/figures/README-`. This would ensure that images are properly stored and displayed on multiple platforms like CRAN, Github, and on your `altdoc` website.")
  }

  cli::cli_alert_success("{.file README} imported.")
}
