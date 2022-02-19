# Transform vignettes to produce Markdown
#
# Transform vignettes to produce Markdown instead of HTML.
#
# Vignettes files (originally placed in the folder "Vignettes") have the output
# "html_vignette", instead of Markdown. This function makes several things:
# * moves the .Rmd files from the "vignettes" folder in "docs/articles"
# * replaces the "output" argument of each .Rmd file (in "docs/articles") so
#  that it is "md_document" instead of "html_vignette"
# * render all of the modified .Rmd files (in "docs/articles"), which produce .md files.

transform_vignettes <- function() {

  if (!file.exists("vignettes") | folder_is_empty("vignettes")) {
    message_info("No vignettes to transform.")
    return(invisible())
  }

  good_path <- doc_path()
  articles_path <- paste0(good_path, "/articles")

  vignettes <- list.files("vignettes", pattern = ".Rmd")

  if (!file.exists(articles_path)) {
    fs::dir_create(articles_path)
  }

  n <- length(vignettes)
  i <- 0
  cli::cli_progress_step("Converting vignettes: {i}/{n}", spinner = TRUE)

  for (i in seq_along(vignettes)) {
    origin <- paste0("vignettes/", vignettes[i])
    destination <- paste0("docs/articles/", vignettes[i])

    if (vignettes_differ(origin, destination)) {

      fs::file_copy(origin, destination, overwrite = TRUE)
      modify_yaml(destination)
      output_file <- paste0(substr(vignettes[i], 1, nchar(vignettes[i])-4), ".md")

      suppressMessages(
        rmarkdown::render(
          destination,
          output_dir = articles_path,
          output_file = output_file,
          quiet = TRUE
        )
      )

      ### If title too long, it was cut in several lines but only the last
      ### one is read by docute so need to paste the title back together
      new_vignette <- readLines(gsub("\\.Rmd", "\\.md", destination), warn = FALSE)
      title_sep <- grep("=====", new_vignette)
      if (length(title_sep) == 1) {
        title <- new_vignette[1:title_sep-1]
        title <- paste(title, collapse = " ")
        new_vignette <- new_vignette[-c(1:title_sep-1)]
        new_vignette <- c(title, new_vignette)
        writeLines(new_vignette, gsub("\\.Rmd", "\\.md", destination))
      }

      cli::cli_progress_update()
    }
  }

  cli::cli_progress_done()
  message_validate(paste0("Vignettes have been converted and put in '",
                          articles_path, "'."))


}


# Check if vignettes in folder "vignettes" and in folder "docs/articles" differ
#
# Since the output of the vignette in the folder "vignette" is "html_vignette"
# and the output of the vignette in the folder "docs/articles" is
# "github_document", there will necessarily be changes. Therefore, the
# comparison is made on the files without the YAML.
#
# @param x,y Names of the two vignettes to compare
#
# @return Boolean
# @keywords internal

vignettes_differ <- function(x, y) {

  if (!file.exists(x) | !file.exists(y)) {
    return(TRUE)
  }

  x_file <- readLines(x, warn = FALSE)
  x_content <- gsub("---(.*?)---", "", paste(x_file, collapse = " "))

  y_file <- readLines(y, warn = FALSE)
  y_content <- gsub("---(.*?)---", "", paste(y_file, collapse = " "))

  return(!identical(x_content, y_content))
}


# Get titles and filenames of the vignettes
# This is used to update the sidebar/navbar in the docs

get_vignettes_titles <- function() {

  if (!file.exists("vignettes") | folder_is_empty("vignettes")) {
    message_info("No vignettes to transform.")
    return(invisible())
  }

  good_path <- doc_path()
  vignettes <- list.files(paste0(good_path, "/articles"), pattern = ".Rmd")

  vignettes_title <- data.frame(title = NULL, link = NULL)
  for (i in seq_along(vignettes)) {
    x <- readLines(paste0(good_path, "/articles/", vignettes[i]), warn = FALSE)
    title <- x[startsWith(x, "title: ")]
    title <- gsub("title: ", "", title)
    vignettes_title[i, "title"] <- title

    link <- paste0("/articles/", vignettes[i])
    link <- gsub("\\.Rmd", "\\.md", link)
    vignettes_title[i, "link"] <- link
  }

  return(
    jsonlite::toJSON(vignettes_title, pretty = TRUE)
  )
}


add_vignettes <- function(doctype) {

  if (doctype == "docute") {
    original_index <- readLines("docs/index.html", warn = FALSE)
    home_line <- which(grepl("\\{title: 'Home', link: '/'\\}", original_index))

    original_index[home_line] <- paste0(
      original_index[home_line],
      "\n{
					   title: \"Articles\",
					   children:",
      get_vignettes_titles(),
      "},\n"
    )

    writeLines(original_index, "docs/index.html")

  } else if (doctype == "docsify") {

  } else if (doctype == "mkdocs") {

  }

}
