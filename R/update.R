#' Update documentation
#'
#' Update README, Changelog and Reference sections. This will leave every
#' other files unmodified.

update_docs <- function() {

  update_file("README.md")
  move_img_readme()
  replace_img_paths_readme()
  reformat_md("docs/README.md")

  update_file("NEWS.md")

  make_reference()

  message_validate("Documentation updated. See `?altdoc::update_docs` to know
                   what files are concerned.")

}


update_file <- function(filename) {

  orig_file <- filename
  docs_file <- paste0("docs/", filename)

  if (fs::file_exists(docs_file)) {
    if (fs::file_exists(orig_file)) {
      fs::file_copy(orig_file, docs_file, overwrite = TRUE)
    }
  }

}
