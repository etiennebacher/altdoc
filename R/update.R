#' Update documentation
#'
#' Update README, Changelog and Reference sections. This will leave every
#' other files unmodified.
#'
#' @export
#'
#' @return No value returned. Updates files in folder 'docs'.
#'
#' @examples
#' \dontrun{
#' # Update documentation
#' update_docs()
#' }


update_docs <- function() {

  good_path <- doc_path()

  # Update README
  update_file("README.md")
  move_img_readme()
  replace_img_paths_readme()
  reformat_md(paste0(good_path, "/README.md"))

  # Update changelog
  update_file("NEWS.md")

  # Update functions reference
  make_reference()

  # Finish
  message_validate("Documentation updated. See `?altdoc::update_docs` to know
                   what files are concerned.")

}


update_file <- function(filename) {

  orig_file <- filename
  good_path <- doc_path()
  docs_file <- paste0(good_path, "/", filename)
  if (fs::file_exists(filename)) {
    fs::file_copy(orig_file, docs_file, overwrite = TRUE)
    if (filename == "NEWS.md") {
      if (!fs::file_exists(docs_file)) {
        message_info("NEWS.md was imported for the first time. You should also update {.code docs/mkdocs.yml}.")
      }
      changelog <- readLines("NEWS.md", warn = FALSE)
      changelog <- gsub("^## ", "### ", changelog)
      changelog <- gsub("^# ", "## ", changelog)
      writeLines(changelog, docs_file)
    }
  }
}
