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

  if (!file.exists("vignettes") || folder_is_empty("vignettes")) {
    message_info("No vignettes to transform.")
  } else {

    list_vignettes <- list.files("vignettes", pattern = ".Rmd")

    if (!file.exists("docs/articles")) {
      fs::dir_create("docs/articles")
    }

    for (i in seq_along(list_vignettes)) {

      first_vignette <- paste0("vignettes/", list_vignettes[i])
      second_vignette <- paste0("docs/articles/", list_vignettes[i])

      if (vignettes_differ(first_vignette, second_vignette)) {

        fs::file_copy(
          first_vignette,
          second_vignette,
          overwrite = TRUE
        )

        original_vignette <- readLines(second_vignette, warn = FALSE)

        start_of_output <- which(startsWith(original_vignette, "output:"))
        end_of_output <- which(startsWith(original_vignette, "vignette:")) - 1
        output_chunk <- original_vignette[start_of_output:end_of_output]

        # Remove output chunk and insert the new output
        modified_vignette <- original_vignette[-c(start_of_output:end_of_output)]
        modified_vignette[start_of_output] <- paste0(
          "output:\n  rmarkdown::github_document: \n    html_preview: false\n",
          modified_vignette[start_of_output]
        )
        modified_vignette <- paste(modified_vignette, collapse = "\n")
        cat(modified_vignette, file = second_vignette)

        # Store vignettes in .md format in "docs/articles"
        output_file <- paste0(
          substr(list_vignettes[i], 1, nchar(list_vignettes[i])-4),
          ".md"
        )

        suppressMessages(
          rmarkdown::render(
            second_vignette,
            output_dir = "docs/articles",
            output_file = output_file,
            quiet = TRUE
          )
        )

      }

    }

    message_validate("Vignettes have been converted and put in 'docs/articles'.")

  }

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

  if (!file.exists(x) || !file.exists(y)) {
    return(TRUE)
  }

  x_file <- readLines(x, warn = FALSE)
  x_content <- gsub("---(.*?)---", "", paste(x_file, collapse = " "))

  y_file <- readLines(y, warn = FALSE)
  y_content <- gsub("---(.*?)---", "", paste(y_file, collapse = " "))

  return(!identical(x_content, y_content))
}
