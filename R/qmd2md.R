.qmd2md <- function(source_file) {

  if (missing(source_file) || !file.exists(source_file)) {
    stop("source_file must be a valid file path.", call. = FALSE)
  }

  quarto::quarto_render(
    input = path.expand(source_file),
    output_format = "md"
  )
}


.rmd2md <- function(source_file) {

  if (missing(source_file) || !file.exists(source_file)) {
    stop("source_file must be a valid file path.", call. = FALSE)
  }

  rmarkdown::render(
    input = path.expand(source_file),
    output_format = "md_document",
    quiet = TRUE,
    envir = new.env()
  )
}
