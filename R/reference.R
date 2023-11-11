# Convert and unite .Rd files to 'docs/reference.md'.
.make_reference <- function(update = FALSE, path = ".",
                            custom_reference = NULL, quarto = FALSE) {

  if (isTRUE(quarto)) {
    .make_reference_quarto(update = update)
  }

  cli::cli_h1("Building reference")
  if (!is.null(custom_reference)) {
    cli::cli_progress_bar("{cli::pb_spin} Running file {.file {custom_reference}}")
    source(custom_reference, echo = FALSE)
    cli::cli_alert_success("Custom file for {.pkg Reference} finished running.")
    return(invisible)
  }

  good_path <- .doc_path(path = path)
  if (fs::file_exists(paste0(good_path, "/reference.md"))) {
    fs::file_delete(paste0(good_path, "/reference.md"))
  }

  files <- list.files("man", pattern = ".Rd", full.names = TRUE)
  pkg <- basename(getwd())

  exported <- readLines("NAMESPACE")
  exported <- grep("^export\\(", exported, value = TRUE)
  exported <- gsub("export\\((.*)\\)", "\\1", exported)

  which.files <- lapply(files, function(x) {
    y <- readLines(x)
    y <- grep("\\name{", y, fixed = TRUE, value = TRUE)
    y <- gsub("\\name{", "", y, fixed = TRUE)
    y <- gsub("}", "", y, fixed = TRUE)
    y %in% exported
  })

  files <- files[unlist(which.files)]

  all_rd_as_md <- lapply(files, .rd2md)

  fs::file_create(paste0(good_path, "/reference.md"))
  writeLines(c("# Reference \n", unlist(all_rd_as_md)), paste0(good_path, "/reference.md"))

  cli::cli_alert_success("Functions reference {if (update) 'updated' else 'created'}.")
}


# Convert Rd file to Markdown
.rd2md <- function(rdfile) {

  tmp_html <- tempfile(fileext = ".html")
  tmp_md <- tempfile(fileext = ".md")

  tools::Rd2HTML(rdfile, out = tmp_html, permissive = TRUE)
  rmarkdown::pandoc_convert(tmp_html, "markdown_strict", output = tmp_md)

  cat("\n\n---", file = tmp_md, append = TRUE)

  # Get function title and remove HTML tags left
  md <- .readlines(tmp_md)
  md <- md[-c(1:10)]

  # Title to put in sidebar
  title <- gsub(".Rd", "", rdfile)
  title <- gsub("man/", "", title)
  title <- gsub("_", " ", title)
  initial <- substr(title, 1, 1)
  title <- paste0(toupper(initial), substr(title, 2, nchar(title)))

  md <- c(
    paste0("## ", title),
    md
  )

  # Syntax used for examples is four spaces, which prevents code
  # highlighting. So I need to put backticks before and after the examples
  # and remove the four spaces.
  start_examples <- which(grepl("^### Examples$", md))
  if (length(start_examples) != 0) {
    examples <- md[start_examples:length(md)]
    not_empty_lines <- which(examples != "")[-1]
    examples[not_empty_lines[1]] <-
      paste0("```r\n", examples[not_empty_lines[1]])
    examples[not_empty_lines[length(not_empty_lines)-1]] <-
      paste0(examples[not_empty_lines[length(not_empty_lines)-1]], "\n```")
    md[start_examples:length(md)] <- examples
    for (i in start_examples:length(md)) {
      md[i] <- gsub("    ", "", md[i])
    }
  }
  md
}


#' Convert .Rd files from man/ to .md files in docs/man/
#' @param update If TRUE, overwrite existing files
#' @keywords internal
.make_reference_quarto <- function(update = FALSE) {

  cli::cli_h1("Building reference")

  # source and target file paths
  # using here::here() breaks tests, so we rely on directory check higher up
  man_source <- list.files(path = "man", pattern = "\\.Rd$")
  man_target <- list.files(path = fs::path_join(c(.doc_path("."), "man")), pattern = "\\.md$")
  man_source <- fs::path_ext_remove(man_source)
  man_target <- fs::path_ext_remove(man_target)

  # exported functions only, otherwise this can get expensive
  # parse NAMESPACE manually to avoid having to install the package
  if (fs::file_exists("NAMESPACE")) {
    exported <- readLines("NAMESPACE")
    exported <- exported[grepl("^export\\(.*\\)$", exported)]
    exported <- gsub("^export\\((.*)\\)$", "\\1", exported)
    man_source <- intersect(man_source, exported)
  }

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
    origin_Rd <- fs::path_join(c("man", fs::path_ext_set(f, ".Rd")))
    destination_dir <- fs::path_join(c(.doc_path(path = "."), "man"))
    destination_qmd <- fs::path_join(c(destination_dir, fs::path_ext_set(f, ".qmd")))
    destination_md <- fs::path_join(c(destination_dir, fs::path_ext_set(f, ".md")))
    fs::dir_create(destination_dir)
    .rd_to_qmd(origin_Rd, destination_dir)
    .qmd_to_md(destination_qmd)
    fs::file_delete(destination_qmd)
  }

  cli::cli_alert_success("Functions reference updated in `docs/man/` directory.")
}