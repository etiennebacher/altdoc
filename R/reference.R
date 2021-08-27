#' @title Create 'Reference' tab
#'
#' @description
#' Function adapted from [John Coene's code](https://github.com/devOpifex/leprechaun/blob/master/docs/docify.R).
#'
#' Convert .Rd to .md files, move them in 'docs/reference', and generate
#' the JSON to put in 'docs/index.html'

make_reference <- function() {

  if (fs::file_exists("docs/reference.md")) fs::file_delete("docs/reference.md")
  fs::file_create("docs/reference.md")

  files <- list.files("man")
  files <- files[grepl("\\.Rd", files)]

  lapply(files, function(x){
    input <- paste0("man/", x)
    nm <- gsub("\\.Rd", ".md", x)
    Rd2md::Rd2markdown(input, "docs/reference.md", append = TRUE)
  })

  reformat_md("docs/reference.md")

}




