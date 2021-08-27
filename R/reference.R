#' @title Create 'Reference' tab
#'
#' @description
#' Function adapted from [John Coene's code](https://github.com/devOpifex/leprechaun/blob/master/docs/docify.R).
#'
#' Convert .Rd to .md files, move them in 'docs/reference', and generate
#' the JSON to put in 'docs/index.html'

make_reference <- function() {

  if (fs::file_exists("docs/reference.md")) fs::file_delete("docs/reference.md")

  files <- list.files("man", full.names = TRUE)
  files <- files[grepl("\\.Rd", files)]

  all_rd_as_md <- lapply(files, function(x){
    rd2md(x)
  })

  fs::file_create("docs/reference.md")
  writeLines(unlist(all_rd_as_md), "docs/reference.md")
}


#' Convert Rd files to Markdown
#'
#' @param rdfile Filename
#'

rd2md <- function(rdfile) {

  tmp_html <- tempfile(fileext = ".html")
  tmp_md <- tempfile(fileext = ".md")

  tools::Rd2HTML(rdfile, out = tmp_html, permissive = TRUE)
  rmarkdown::pandoc_convert(tmp_html, "markdown_strict", output = tmp_md)

  # Extract examples
  rd <- paste(readLines(rdfile, warn = FALSE), collapse = "\n")
  pattern = "\\\\dontrun({([^{}]*?(?:(?1)[^{}]*?)*)\\s*})"
  examples <- unlist(regmatches(rd, regexec(pattern, rd, perl = TRUE)))[3]
  if (!is.na(examples)) {
    examples_md <- paste0(
      "\n\n### Examples\n\n```r", examples, "\n```"
    )
    cat(examples_md, file = tmp_md, append = TRUE)
  }

  cat("\n\n---", file = tmp_md, append = TRUE)

  # Get function title and remove HTML tags left
  md <- readLines(tmp_md, warn = FALSE)
  md[-c(1:8)]

}


