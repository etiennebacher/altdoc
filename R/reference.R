#' @title Create 'Reference' tab
#'
#' @description
#' Function adapted from [John Coene's code](https://github.com/devOpifex/leprechaun/blob/master/docs/docify.R).
#'
#' Convert .Rd to .md files, move them in 'docs/reference', and generate
#' the JSON to put in 'docs/index.html'

make_reference <- function() {

  if (fs::dir_exists("docs/reference")) fs::dir_delete("docs/reference")
  fs::dir_create("docs/reference")

  files <- list.files("man")
  files <- files[grepl("\\.Rd", files)]

  lapply(files, function(x){
    input <- paste0("man/", x)
    nm <- gsub("\\.Rd", ".md", x)
    output <- paste0("docs/reference/", nm)
    Rd2md::Rd2markdown(input, output)

    list(name = nm, output = output)
  })

  json <- lapply(files, function(x){
    link <- gsub("\\.Rd", "", x)
    list(title = link, link = sprintf("/reference/%s", link))
  })

  jsonlite::toJSON(json, pretty = TRUE, auto_unbox = TRUE)

}




