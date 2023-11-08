#' Convert .Rd files from man/ to .md files in docs/man/
#' @param update If TRUE, overwrite existing files
.make_reference_quarto <- function(update = FALSE) {

  cli::cli_h1("Building reference")

  # soure and target file paths
  man_source <- list.files(path = here::here("man"), pattern = "\\.Rd$")
  man_target <- list.files(path = here::here("docs/man"), pattern = "\\.md$")
  man_source <- fs::path_ext_remove(man_source)
  man_target <- fs::path_ext_remove(man_target)

  # exported functions only, otherwise this can get expensive
  # parse NAMESPACE manually to avoid having to install the package
  exported <- readLines(here::here("NAMESPACE"))
  exported <- exported[grepl("^export\\(.*\\)$", exported)]
  exported <- gsub("^export\\((.*)\\)$", "\\1", exported)
  man_source <- intersect(man_source, exported)

  # warning about conflicts
  if (!isTRUE(update)) {
    man_conflict <- intersect(man_source, man_target)
    if (length(man_conflict) > 0) {
      man_conflict <- paste(man_conflict, collapse = ", ")
      usethis::ui_yeah("These files already exist and will be overwritten: {man_conflict}")
    }
  }

  # process man pages one by one
  for (f in man_source) {
    origin_Rd <- fs::path_join(c(here::here("man"), fs::path_ext_set(f, ".Rd")))
    destination_dir <- here::here("docs/man")
    destination_qmd <- fs::path_join(c(destination_dir, fs::path_ext_set(f, ".qmd")))
    destination_md <- fs::path_join(c(destination_dir, fs::path_ext_set(f, ".md")))
    fs::dir_create(destination_dir)
    .rd_to_qmd(origin_Rd, destination_dir)
    .qmd_to_md(destination_qmd)
    fs::file_delete(destination_qmd)
  }

  cli::cli_alert_success("Functions reference updated in `docs/man/` directory.")
}
