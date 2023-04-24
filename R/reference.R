# Convert and unite .Rd files to 'docs/reference.md'.
.make_reference <- function(update = FALSE, path = ".",
                            custom_reference = NULL) {

  doc_type <- .doc_type(path)

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

  files <- list.files("man", full.names = TRUE)
  files <- files[grepl("\\.Rd", files)]

  all_rd_as_md <- lapply(files, function(x){
    .rd2md(x, doc_type = doc_type)
  })

  if (doc_type %in% c("docute", "docsify", "mkdocs")) {

    fs::file_create(paste0(good_path, "/reference.md"))
    writeLines(c("# Reference \n", unlist(all_rd_as_md)), paste0(good_path, "/reference.md"))

  } else {

    all_rd_as_md <- lapply(all_rd_as_md, paste, collapse = "\n")
    file_names <- gsub("^man/", "", files)
    file_names <- tools::file_path_sans_ext(file_names)

    # create reference file for each Rd file
    for (i in seq_along(files)) {
      fs::dir_create(paste0(good_path, "/reference"))
      cat(all_rd_as_md[[i]], file = paste0(good_path, "/reference/", file_names[i], ".md"))
    }

    # create the "Reference" homepage
    bullets <- paste(
      paste0("  * [", file_names, "](", paste0("reference/", file_names, ".md"), ")\n"),
      collapse = ""
    )
    bullets <- gsub("^ ", "", bullets)
    content <- paste("Functions in the package:\n\n", bullets)
    cat(content, file = paste0(good_path, "/reference.md"))
  }

  cli::cli_alert_success("Functions reference {if (update) 'updated' else 'created'}.")
}


# Convert Rd file to Markdown
.rd2md <- function(rdfile, doc_type) {

  tmp_html <- tempfile(fileext = ".html")
  tmp_md <- tempfile(fileext = ".md")

  tools::Rd2HTML(rdfile, out = tmp_html, permissive = TRUE)
  rmarkdown::pandoc_convert(tmp_html, "markdown_strict", output = tmp_md)

  if (doc_type %in% c("docute", "docsify", "mkdocs")) {
    cat("\n\n---", file = tmp_md, append = TRUE)
  } else {
    cat("\n", file = tmp_md, append = TRUE)
  }

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
    examples[length(examples)] <- paste0(examples[length(examples)], "\n```")
    md[start_examples:length(md)] <- examples
    for (i in start_examples:length(md)) {
      md[i] <- gsub("    ", "", md[i])
    }
  }
  md
}


