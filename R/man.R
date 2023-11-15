# Convert and unite .Rd files to 'docs/reference.md'.
.import_man <- function(update = FALSE, path = ".", verbose = FALSE) {
  cli::cli_h1("Building reference")

  # source and target file paths
  # using here::here() breaks tests, so we rely on directory check higher up
  man_source <- list.files(path = "man", pattern = "\\.Rd$")
  man_target <- list.files(path = fs::path_join(c(.doc_path("."), "man")), pattern = "\\.md$")
  man_source <- fs::path_ext_remove(man_source)
  man_target <- fs::path_ext_remove(man_target)

  # warning about conflicts
  if (!isTRUE(update)) {
    man_conflict <- intersect(man_source, man_target)
    if (length(man_conflict) > 0) {
      man_conflict <- paste(man_conflict, collapse = ", ")
      usethis::ui_yeah("These files already exist and will be overwritten: {man_conflict}")
    }
  }

  n <- length(man_source)
  cli::cli_alert_info("Found {n} man page{?s} to convert.")
  i <- 0
  cli::cli_progress_step("Converting {cli::qty(n)}vignette{?s}: {i}/{n}", spinner = TRUE)

  # process man pages one by one
  for (i in seq_along(man_source)) {
    f <- man_source[i]
    origin_Rd <- fs::path_join(c("man", fs::path_ext_set(f, ".Rd")))
    destination_dir <- fs::path_join(c(.doc_path(path = "."), "man"))
    destination_qmd <- fs::path_join(c(destination_dir, fs::path_ext_set(f, ".qmd")))
    destination_md <- fs::path_join(c(destination_dir, fs::path_ext_set(f, ".md")))
    fs::dir_create(destination_dir)
    .rd2qmd(origin_Rd, destination_dir)
    .qmd2md(destination_qmd, destination_dir, verbose = verbose)
    fs::file_delete(destination_qmd)

    # section headings are too deeply nested by default
    # this is a hack because it may remove one # from comments. But that's
    # probably not the end of the world, because the line stick stays commented
    # out.
    tmp <- readLines(destination_md)
    tmp <- gsub("^##", "#", tmp)
    writeLines(tmp, destination_md)
    cli::cli_progress_update(inc = 1)
  }

  cli::cli_progress_done()

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
  start_examples <- grep("^### Examples$", md)
  if (length(start_examples) != 0) {
    examples <- md[start_examples:length(md)]
    not_empty_lines <- which(examples != "")[-1]
    examples[not_empty_lines[1]] <-
      paste0("```r\n", examples[not_empty_lines[1]])
    examples[not_empty_lines[length(not_empty_lines) - 1]] <-
      paste0(examples[not_empty_lines[length(not_empty_lines) - 1]], "\n```")
    md[start_examples:length(md)] <- examples
    for (i in start_examples:length(md)) {
      md[i] <- gsub("    ", "", md[i])
    }
  }
  md
}


.rd2qmd <- function(source_file, target_dir) {
  if (missing(source_file) || !file.exists(source_file)) {
    stop("source_file must be a valid file path.", call. = FALSE)
  }
  if (missing(source_file) || !dir.exists(target_dir)) {
    stop("target_dir must be a valid directory.", call. = FALSE)
  }

  # Rd -> html
  rd <- tools::parse_Rd(source_file)
  tmp_html <- paste0(tempfile(), ".html")
  tools::Rd2HTML(rd, out = tmp_html)

  # superfluous header and footer
  tmp <- readLines(tmp_html)
  tmp <- tmp[(grep("</table>$", tmp)[1] + 1):length(tmp)]
  tmp <- tmp[seq_len(which("</div>" == tmp) - 3)]

  # first column (odd entries) of table in Arguments should not be wrapped
  idx <- grep("<td>", tmp)
  idx <- idx[seq_along(idx) %% 2 == 1]
  tmp[idx] <- sub("<td>", '<td style = "white-space: nowrap; font-family: monospace; vertical-align: top">', tmp[idx])

  # math in Equivalence section
  idx <- grepl("<.code", tmp)

  # examples: evaluate code blocks (assume examples are always last)
  pkg <- basename(getwd())
  pkg_load <- paste0("library(", pkg, ")")
  idx <- which(tmp == "<h3>Examples</h3>")
  if (length(idx) == 1) {
    ex <- tmp[(idx + 1):length(tmp)]
    ex <- gsub("<.*>", "", ex)
    ex <- gsub("&lt;", "<", ex)
    ex <- gsub("&gt;", ">", ex)
    ex <- gsub("&gt;", ">", ex)
    ex <- ex[!grepl("## Not run:", ex)]
    ex <- ex[!grepl("## End", ex)]
    tmp <- c(tmp[2:idx], "```{r, warning=FALSE, message=FALSE}", pkg_load, ex, "```")
  }

  # cleanup equations
  tmp <- gsub(
    '<code class="reqn">(.*?)&gt;(.*?)</code>',
    '<code class="reqn">\\1>\\2</code>',
    tmp
  )
  tmp <- gsub(
    '<code class="reqn">(.*?)&lt;(.*?)</code>',
    '<code class="reqn">\\1<\\2</code>',
    tmp
  )
  tmp <- gsub('<code class="reqn">(.*?)</code>', "\\$\\1\\$", tmp)

  # title
  # warning: Undefined global functions or variables: title
  title <- "not NULL"
  funname <- tools::file_path_sans_ext(basename(source_file))
  if (!is.null(title)) {
    tmp <- tmp[!grepl("h1", tmp)]
    tmp <- c(paste("##", funname, "{.unnumbered}\n"), tmp)
  }

  # Fix title level (use ## and not <h2> so that the TOC can be generated by
  # mkdocs)
  tmp <- gsub("<h2[^>]*>", "", tmp, perl = TRUE)
  tmp <- gsub("<.h2>", "", tmp)
  tmp <- gsub("<h3>", "### ", tmp)
  tmp <- gsub("</h3>", "", tmp)

  # paragraph tags are unnecessary in markdown
  tmp <- gsub("<p>", "", tmp, fixed = TRUE)
  tmp <- gsub("</p>", "", tmp, fixed = TRUE)

  # write to file
  fn <- file.path(target_dir, sub("Rd$", "qmd", basename(source_file)))
  writeLines(tmp, con = fn)
}
